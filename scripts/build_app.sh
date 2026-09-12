#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "🔨 Building StashBar (Release)..."
swift build -c release

APP_DIR="$DIR/build/StashBar.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 Assembling StashBar.app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$DIR/.build/release/StashBar" "$MACOS_DIR/StashBar"
chmod +x "$MACOS_DIR/StashBar"

# Copy Info.plist
cp "$DIR/StashBar/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

# Copy AppIcon.icns
if [ -f "$DIR/StashBar/Resources/AppIcon.icns" ]; then
    cp "$DIR/StashBar/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# Ad-hoc sign bundle
echo "🔏 Ad-hoc code signing StashBar.app..."
codesign --force --deep --sign - "$APP_DIR"

echo "✅ StashBar.app successfully built at: $APP_DIR"
echo "To run StashBar, execute:"
echo "  open build/StashBar.app"
