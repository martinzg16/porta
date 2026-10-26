import Foundation
import CryptoKit
import Security

func encryptionSelfTest() {
    let fm = FileManager.default
    let root = fm.temporaryDirectory.appendingPathComponent("porta-encryption-" + UUID().uuidString)
    defer { try? fm.removeItem(at: root) }
    let key = SymmetricKey(size: .bits256)
    let wrongKey = SymmetricKey(size: .bits256)
    let clip = Clip(id: "synthetic", date: Date(timeIntervalSince1970: 100), title: "PRIVATE-SYNTHETIC-TEXT", kind: "Texto", items: [["public.utf8-plain-text": Data("PRIVATE-SYNTHETIC-TEXT".utf8), "public.png": Data([1,2,3])]], categoryOverride: "Trabajo")
    let plaintext = try! EncryptedHistory.encode([clip])
    let ciphertext = try! EncryptedHistory.seal(plaintext, key: key)
    precondition(ciphertext.range(of: Data(clip.title.utf8)) == nil)
    precondition(try! EncryptedHistory.open(ciphertext, key: key) == plaintext)
    precondition(try! EncryptedHistory.seal(plaintext, key: key) != ciphertext)
    func rejects(_ action: () throws -> Void) {
        do { try action(); preconditionFailure("Unsafe operation accepted") } catch {}
    }
    rejects { _ = try EncryptedHistory.open(ciphertext, key: wrongKey) }
    var damaged = ciphertext; damaged[damaged.count-1] ^= 1
    rejects { _ = try EncryptedHistory.open(damaged, key: key) }
    rejects { _ = try EncryptedHistory.open(ciphertext.prefix(12), key: key) }
    rejects { _ = try EncryptedHistory.open(Data("PORTA-HISTORY-UNKNOWN".utf8) + ciphertext, key: key) }
    let legacy = root.appendingPathComponent("history.json"), encrypted = root.appendingPathComponent("history.porta")
    try! HistoryStore.write(plaintext, to: legacy)
    var store: EncryptedHistory? = try! EncryptedHistory(directory: root, keyProvider: { _ in key })
    precondition(try! EncryptedHistory.encode(store!.load()) == plaintext)
    precondition(!fm.fileExists(atPath: legacy.path))
    precondition(try! HistoryStore.read(from: encrypted).range(of: Data(clip.title.utf8)) == nil)
    rejects { _ = try EncryptedHistory(directory: root, keyProvider: { _ in key }) }
    try! store!.save([clip]); store = nil
    // Reopen an encrypted history. Generating a new key must never be requested.
    store = try! EncryptedHistory(directory: root, keyProvider: { create in precondition(!create); return key })
    precondition(try! EncryptedHistory.encode(store!.load()) == plaintext); store = nil
    let before = try! HistoryStore.read(from: encrypted)
    store = try! EncryptedHistory(directory: root, keyProvider: { create in precondition(!create); throw EncryptedHistory.Failure.missingKey })
    rejects { _ = try store!.load() }; rejects { try store!.save([]) }; store = nil
    precondition(try! HistoryStore.read(from: encrypted) == before)
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in wrongKey })
    rejects { _ = try store!.load() }; rejects { try store!.save([]) }; store = nil
    precondition(try! HistoryStore.read(from: encrypted) == before)
    // A crash between successful verification and deleting the legacy file.
    try! HistoryStore.write(plaintext, to: legacy)
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in key })
    _ = try! store!.load(); store = nil
    precondition(!fm.fileExists(atPath: legacy.path))
    // A downgrade created divergent plaintext. Preserve both and block writes.
    try! HistoryStore.write(Data("[]".utf8), to: legacy)
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in key })
    rejects { _ = try store!.load() }; rejects { try store!.save([]) }; store = nil
    precondition(try! HistoryStore.read(from: encrypted) == before)
    precondition(fm.fileExists(atPath: legacy.path))
    try! fm.removeItem(at: encrypted); try! HistoryStore.write(plaintext, to: legacy)
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in key }, writer: { _, _ in throw EncryptedHistory.Failure.verification })
    rejects { _ = try store!.load() }; store = nil
    precondition(try! HistoryStore.read(from: legacy) == plaintext)
    // Simulated damaged migration output: never remove original plaintext.
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in key }, writer: { _, url in try HistoryStore.write(Data("bad".utf8), to: url) })
    rejects { _ = try store!.load() }; rejects { try store!.save([]) }; store = nil
    precondition(try! HistoryStore.read(from: legacy) == plaintext)
    try! fm.removeItem(at: encrypted)
    var writes = 0
    store = try! EncryptedHistory(directory: root, keyProvider: { _ in key }, writer: { data, url in
        writes += 1
        if writes > 1 { throw EncryptedHistory.Failure.verification }
        try HistoryStore.write(data, to: url)
    })
    _ = try! store!.load()
    let saved = try! HistoryStore.read(from: encrypted)
    rejects { try store!.save([]) }; rejects { try store!.save([]) }
    precondition(writes == 2)
    precondition(try! HistoryStore.read(from: encrypted) == saved)
    store = nil
    print("PASS: AES-GCM roundtrip, fresh nonce, tamper/wrong-key rejection, migration, restart, missing key, exclusive lock, interrupted/conflicting migration, failed-write protection")
}

func keychainSelfTest() {
    // Never query, modify or delete the real Porta key or personal credentials.
    let vault = HistoryKeychain(service: "local.martin.porta.test." + UUID().uuidString)
    defer { SecItemDelete(vault.query as CFDictionary) }
    do {
        do { _ = try vault.key(create: false); preconditionFailure("Missing test key accepted") }
        catch EncryptedHistory.Failure.missingKey {}
        let first = try vault.key(create: true)
        let again = try vault.key(create: false)
        let sealed = try EncryptedHistory.seal(Data("synthetic-keychain-roundtrip".utf8), key: first)
        precondition(try! EncryptedHistory.open(sealed, key: again) == Data("synthetic-keychain-roundtrip".utf8))
        let reused = try vault.key(create: true)
        precondition(try! EncryptedHistory.open(sealed, key: reused) == Data("synthetic-keychain-roundtrip".utf8))
        let child = Process()
        child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        child.arguments = ["--keychain-read-self-test", vault.service, sealed.base64EncodedString()]
        try child.run(); child.waitUntilExit()
        precondition(child.terminationStatus == 0)
        print("PASS: isolated macOS Keychain creation, retrieval, reuse and separate-process reopen")
    } catch {
        fputs("Keychain test failed: \(error)\n", stderr)
        exit(1)
    }
}

func keychainReadSelfTest() {
    guard CommandLine.arguments.count == 4,
          CommandLine.arguments[2].hasPrefix("local.martin.porta.test."),
          UUID(uuidString: String(CommandLine.arguments[2].dropFirst("local.martin.porta.test.".count))) != nil,
          let sealed = Data(base64Encoded: CommandLine.arguments[3]) else { exit(2) }
    do {
        let key = try HistoryKeychain(service: CommandLine.arguments[2]).key(create: false)
        let plain = try EncryptedHistory.open(sealed, key: key)
        guard plain == Data("synthetic-keychain-roundtrip".utf8) else { exit(3) }
    } catch { exit(4) }
}
