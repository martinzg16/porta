#!/bin/zsh
set -eu
cd "$(dirname "$0")"
mkdir -p Porta.app/Contents/MacOS
cp Resources/Info.plist Porta.app/Contents/Info.plist
xcrun swiftc -module-cache-path "${SWIFT_MODULECACHE_PATH:-${TMPDIR:-/tmp}/porta-module-cache}" -swift-version 5 -O -target arm64-apple-macosx14.0 Source/main.swift -o Porta.app/Contents/MacOS/Porta -framework AppKit -framework ApplicationServices -framework CryptoKit -framework Carbon
xattr -cr Porta.app
codesign --force --sign - Porta.app
echo "Aplicación compilada: Porta.app"
