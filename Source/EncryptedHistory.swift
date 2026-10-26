import Foundation
import CryptoKit
import Security
import Darwin

struct HistoryKeychain {
    let service: String
    init(service: String = "local.martin.porta.history-key.v1") { self.service = service }
    var query: [String: Any] {
        // The macOS login keychain supports ad-hoc signed builds. Do not use
        // data-protection-keychain entitlements or relax its default app ACL.
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service, kSecAttrAccount as String: "aes256"]
    }
    func key(create: Bool) throws -> SymmetricKey {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        if status == errSecSuccess {
            guard let bytes = result as? Data, bytes.count == 32 else { throw EncryptedHistory.Failure.invalidKey }
            return SymmetricKey(data: bytes)
        }
        guard status == errSecItemNotFound else { throw EncryptedHistory.Failure.keychain(status) }
        guard create else { throw EncryptedHistory.Failure.missingKey }
        let key = SymmetricKey(size: .bits256)
        var item = query
        item[kSecValueData as String] = key.withUnsafeBytes { Data($0) }
        item[kSecAttrLabel as String] = "Porta — clave del historial cifrado"
        let added = SecItemAdd(item as CFDictionary, nil)
        // A competing initializer must reuse the stored key, never overwrite it.
        guard added == errSecSuccess || added == errSecDuplicateItem else { throw EncryptedHistory.Failure.keychain(added) }
        return try self.key(create: false)
    }
}

final class EncryptedHistory {
    enum Failure: Error { case missingKey, invalidKey, keychain(OSStatus), invalidFormat, conflict, locked, disabled, verification }
    static let header = Data("PORTA-HISTORY-AES256-GCM-1\n".utf8)
    let directory: URL
    let encryptedURL: URL
    let legacyURL: URL
    private let keyProvider: (Bool) throws -> SymmetricKey
    private let writer: (Data, URL) throws -> Void
    private var key: SymmetricKey?
    private var lockFD: Int32 = -1
    private var writable = false

    init(directory: URL, keyProvider: @escaping (Bool) throws -> SymmetricKey = { try HistoryKeychain().key(create: $0) }, writer: @escaping (Data, URL) throws -> Void = { try HistoryStore.write($0, to: $1) }) throws {
        self.directory = directory
        self.encryptedURL = directory.appendingPathComponent("history.porta")
        self.legacyURL = directory.appendingPathComponent("history.json")
        self.keyProvider = keyProvider
        self.writer = writer
        try HistoryStore.prepare(directory)
        lockFD = Darwin.open(directory.appendingPathComponent("history.lock").path, O_CREAT | O_RDWR | O_NOFOLLOW, 0o600)
        guard lockFD >= 0 else { throw Failure.locked }
        guard flock(lockFD, LOCK_EX | LOCK_NB) == 0 else {
            Darwin.close(lockFD); lockFD = -1; throw Failure.locked
        }
    }
    deinit { if lockFD >= 0 { flock(lockFD, LOCK_UN); Darwin.close(lockFD) } }

    static func encode(_ clips: [Clip]) throws -> Data {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(clips)
    }
    static func seal(_ plaintext: Data, key: SymmetricKey) throws -> Data {
        // CryptoKit creates a fresh random 96-bit nonce for every save.
        let box = try AES.GCM.seal(plaintext, using: key, authenticating: header)
        guard let combined = box.combined else { throw Failure.invalidFormat }
        return header + combined
    }
    static func open(_ bytes: Data, key: SymmetricKey) throws -> Data {
        guard bytes.starts(with: header) else { throw Failure.invalidFormat }
        return try AES.GCM.open(AES.GCM.SealedBox(combined: bytes.dropFirst(header.count)), using: key, authenticating: header)
    }
    private func exists(_ url: URL) -> Bool {
        // Detect dangling symlinks as existing entries too, so they fail closed.
        (try? FileManager.default.attributesOfItem(atPath: url.path)) != nil
    }
    private func synchronizeDirectory() throws {
        let fd = Darwin.open(directory.path, O_RDONLY | O_NOFOLLOW)
        guard fd >= 0 else { throw Failure.verification }
        defer { Darwin.close(fd) }
        guard fsync(fd) == 0 else { throw Failure.verification }
    }
    func load() throws -> [Clip] {
        writable = false
        let hasEncrypted = exists(encryptedURL)
        let loadedKey = try keyProvider(!hasEncrypted)
        let result: [Clip]
        if hasEncrypted {
            let plain = try Self.open(HistoryStore.read(from: encryptedURL), key: loadedKey)
            result = try JSONDecoder().decode([Clip].self, from: plain)
            // An interrupted migration may leave both files. Delete the old one
            // only when their complete decoded content matches; never merge or
            // discard divergent data (for example after a downgrade).
            if exists(legacyURL) {
                let legacy = try JSONDecoder().decode([Clip].self, from: HistoryStore.read(from: legacyURL))
                guard try Self.encode(legacy) == Self.encode(result) else { throw Failure.conflict }
                try synchronizeDirectory()
                try FileManager.default.removeItem(at: legacyURL)
            }
        } else {
            result = exists(legacyURL) ? try JSONDecoder().decode([Clip].self, from: HistoryStore.read(from: legacyURL)) : []
            let plaintext = try Self.encode(result)
            let encrypted = try Self.seal(plaintext, key: loadedKey)
            try writer(encrypted, encryptedURL)
            // Read back, authenticate and compare before deleting ANY legacy data.
            guard try Self.open(HistoryStore.read(from: encryptedURL), key: loadedKey) == plaintext else { throw Failure.verification }
            try synchronizeDirectory()
            if exists(legacyURL) { try FileManager.default.removeItem(at: legacyURL) }
        }
        key = loadedKey
        writable = true
        return HistoryStore.bounded(result)
    }
    func save(_ clips: [Clip]) throws {
        guard writable, let key else { throw Failure.disabled }
        do {
            let plaintext = try Self.encode(HistoryStore.bounded(clips))
            try writer(Self.seal(plaintext, key: key), encryptedURL)
        } catch {
            writable = false // queued saves must not overwrite after any failure
            throw error
        }
    }
}
