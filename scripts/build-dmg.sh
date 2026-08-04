#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(grep MARKETING_VERSION project.yml | head -1 | awk '{print $2}')
OUT_DIR="build"
DERIVED="$OUT_DIR/DerivedData"
APP="$DERIVED/Build/Products/Release/LaunchPad.app"
DMG="$OUT_DIR/LaunchPad-$VERSION.dmg"

xcodegen generate

# Use the first available signing identity if present, else ad-hoc.
IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | grep -oE '"[^"]+"' | head -1 | tr -d '"' || true)
SIGN_ARGS=()
if [ -n "$IDENTITY" ]; then
    SIGN_ARGS=(CODE_SIGN_IDENTITY="$IDENTITY")
    echo "Signing with: $IDENTITY"
else
    SIGN_ARGS=(CODE_SIGN_IDENTITY=-)
    echo "No signing identity found, using ad-hoc signing"
fi

xcodebuild \
    -project LaunchPad.xcodeproj \
    -scheme LaunchPad \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    "${SIGN_ARGS[@]}" \
    build

rm -rf "$OUT_DIR/dmg"
mkdir -p "$OUT_DIR/dmg"
cp -R "$APP" "$OUT_DIR/dmg/"
ln -s /Applications "$OUT_DIR/dmg/Applications"

rm -f "$DMG"
hdiutil create \
    -volname "LaunchPad" \
    -srcfolder "$OUT_DIR/dmg" \
    -ov \
    -format UDZO \
    "$DMG" >/dev/null

echo "Done: $DMG"
