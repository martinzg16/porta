#!/bin/zsh
set -eu
cd "$(dirname "$0")"
mkdir -p .build Porta.app/Contents/MacOS
cp Resources/Info.plist Porta.app/Contents/Info.plist
for cpu in arm64 x86_64; do
  xcrun swiftc -module-cache-path "${SWIFT_MODULECACHE_PATH:-${TMPDIR:-/tmp}/porta-module-cache}" -swift-version 5 -O -target "$cpu-apple-macosx14.0" Source/*.swift -o ".build/Porta-$cpu" -framework AppKit -framework ApplicationServices -framework CryptoKit -framework Carbon -framework Security
done
lipo -create .build/Porta-arm64 .build/Porta-x86_64 -output Porta.app/Contents/MacOS/Porta
# Only remove extended attributes from our generated bundle, never from downloads.
xattr -cr Porta.app
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" Porta.app
else
  codesign --force --options runtime --sign - Porta.app
fi
codesign --verify --deep --strict Porta.app
lipo Porta.app/Contents/MacOS/Porta -verify_arch arm64 x86_64
echo "Aplicación universal compilada: Porta.app"
