#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="PomodoroTimer"
APP_BUNDLE_ID="com.pomodorotimer.app"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"
ICONSET_DIR="$ROOT_DIR/.build/AppIcon.iconset"
PLIST_TEMPLATE="$ROOT_DIR/packaging/$APP_NAME-Info.plist"
ICON_SCRIPT="$ROOT_DIR/scripts/generate_app_icon.swift"
ARM64_BUILD_DIR="$ROOT_DIR/.build-arm64"
X86_BUILD_DIR="$ROOT_DIR/.build-x86_64"
UNIVERSAL_BINARY="$ROOT_DIR/.build/$APP_NAME-universal"
MACOS_DEPLOYMENT_TARGET="14.0"

# Clear this Mac's saved preferences so the packaged app starts fresh.
defaults delete "$APP_BUNDLE_ID" >/dev/null 2>&1 || true

swift build -c release --product "$APP_NAME" --scratch-path "$ARM64_BUILD_DIR" --triple "arm64-apple-macosx$MACOS_DEPLOYMENT_TARGET"
swift build -c release --product "$APP_NAME" --scratch-path "$X86_BUILD_DIR" --triple "x86_64-apple-macosx$MACOS_DEPLOYMENT_TARGET"

ARM64_BINARY="$(find "$ARM64_BUILD_DIR" -path "*/release/$APP_NAME" -type f | head -n 1)"
X86_BINARY="$(find "$X86_BUILD_DIR" -path "*/release/$APP_NAME" -type f | head -n 1)"

if [[ -z "$ARM64_BINARY" || -z "$X86_BINARY" ]]; then
    echo "Could not find both release binaries for $APP_NAME." >&2
    exit 1
fi

rm -rf "$APP_DIR"
rm -rf "$ICONSET_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

lipo -create -output "$UNIVERSAL_BINARY" "$ARM64_BINARY" "$X86_BINARY"

cp "$UNIVERSAL_BINARY" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"
cp "$PLIST_TEMPLATE" "$APP_DIR/Contents/Info.plist"

swift "$ICON_SCRIPT" "$ICONSET_DIR"
iconutil --convert icns "$ICONSET_DIR" --output "$RESOURCES_DIR/AppIcon.icns"
touch "$APP_DIR"

echo "Created app bundle:"
echo "  $APP_DIR"
echo "Universal binary slices:"
lipo -info "$MACOS_DIR/$APP_NAME"
