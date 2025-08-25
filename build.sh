#!/bin/bash

set -e

echo "Building Video2PPT macOS App and Finder Extension..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/Video2PPT"
BUILD_DIR="$PROJECT_DIR/build"

if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode Command Line Tools are not installed."
    echo "Please install them with: xcode-select --install"
    exit 1
fi

echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"

echo "Building Release configuration..."
xcodebuild -project "$PROJECT_DIR/Video2PPT.xcodeproj" \
    -scheme Video2PPT \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    clean build

echo "Build completed successfully!"

APP_PATH="$BUILD_DIR/Build/Products/Release/Video2PPT.app"

if [ -d "$APP_PATH" ]; then
    echo ""
    echo "App built at: $APP_PATH"
    echo ""
    echo "To install:"
    echo "1. Copy to Applications folder:"
    echo "   cp -r \"$APP_PATH\" /Applications/"
    echo ""
    echo "2. Launch the app once to register the Finder extension:"
    echo "   open /Applications/Video2PPT.app"
    echo ""
    echo "3. Enable the extension in System Settings:"
    echo "   System Settings > Privacy & Security > Extensions > Finder Extensions"
    echo "   Check 'Video2PPT Extension'"
    echo ""
    echo "4. The extension should now appear when right-clicking video files in Finder"
else
    echo "Error: Build failed. App not found at expected location."
    exit 1
fi