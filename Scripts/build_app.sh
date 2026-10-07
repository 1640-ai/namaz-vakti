#!/bin/bash
# NamazVakti.app dosyasını üretir (arm64 + x86_64) ve zip'ler.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release --arch arm64 --arch x86_64
BIN=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/NamazVakti

APP="dist/NamazVakti.app"
rm -rf dist
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/NamazVakti"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

(cd dist && ditto -c -k --keepParent NamazVakti.app NamazVakti.zip)
echo "Hazır: dist/NamazVakti.app ve dist/NamazVakti.zip"
