#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
: "${1:?Usage: zsh scripts/verify-package.sh dist/Porta-version.dmg}"
package="${1:A}"
(cd "$(dirname "$package")" && shasum -a 256 -c "$(basename "$package").sha256")
stage=$(mktemp -d "${TMPDIR:-/tmp}/porta-check.XXXXXX")
mounted=0
cleanup() {
  if (( mounted )); then hdiutil detach "$stage/mount"; fi
  rm -rf "$stage"
}
trap cleanup EXIT
mkdir "$stage/mount"
hdiutil attach -readonly -nobrowse -mountpoint "$stage/mount" "$package"
mounted=1
test -L "$stage/mount/Applications"
test -f "$stage/mount/LEEME.txt"
# Simulate copying out of the read-only installer into a path with spaces.
ditto "$stage/mount/Porta.app" "$stage/Installed Apps/Porta.app"
hdiutil detach "$stage/mount"
mounted=0
app="$stage/Installed Apps/Porta.app"
plutil -lint "$app/Contents/Info.plist"
lipo "$app/Contents/MacOS/Porta" -verify_arch arm64 x86_64
codesign --verify --deep --strict "$app"
"$app/Contents/MacOS/Porta" --self-test
echo "PASS: downloaded-package structure, copy, universal binary, signature and native self-tests"
