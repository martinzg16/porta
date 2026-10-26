#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
zsh build.sh
Porta.app/Contents/MacOS/Porta --self-test
version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Porta.app/Contents/Info.plist)
mkdir -p dist
stage=$(mktemp -d "${TMPDIR:-/tmp}/porta-package.XXXXXX")
trap 'rm -rf "$stage"' EXIT
# Notarization is opt-in and must succeed before a signed package is emitted.
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  : "${NOTARY_PROFILE:?Set a notarytool keychain profile for a signed release}"
  ditto -c -k --keepParent Porta.app "$stage/notarize.zip"
  xcrun notarytool submit "$stage/notarize.zip" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple Porta.app
  xcrun stapler validate Porta.app
  spctl --assess --type execute --verbose Porta.app
  label=universal
else
  label=universal-beta
fi
mkdir "$stage/image"
ditto Porta.app "$stage/image/Porta.app"
ln -s /Applications "$stage/image/Applications"
cp docs/INSTALL.txt "$stage/image/LEEME.txt"
name="Porta-$version-$label"
hdiutil create -ov -volname "Porta $version" -srcfolder "$stage/image" -format UDZO "dist/$name.dmg"
hdiutil verify "dist/$name.dmg"
(cd dist && shasum -a 256 "$name.dmg" > "$name.dmg.sha256")
echo "Paquete: dist/$name.dmg"
