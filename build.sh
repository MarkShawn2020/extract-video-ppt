#!/bin/bash

set -e

echo "Building Video2PPT macOS App and Finder Extension..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/Video2PPT"
BUILD_DIR="$PROJECT_DIR/build"

# Parse command line arguments
AUTO_INSTALL=false
for arg in "$@"; do
    case $arg in
        --install|-i)
            AUTO_INSTALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --install, -i    Automatically install to /Applications after building"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
    esac
done

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

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Build failed. App not found at expected location."
    exit 1
fi

echo ""
echo "✅ App built at: $APP_PATH"

# Copy scripts to app bundle Resources
echo "📝 Copying Quick Action scripts to app bundle..."
mkdir -p "$APP_PATH/Contents/Resources/scripts"
cp -r scripts/*.sh "$APP_PATH/Contents/Resources/scripts/" 2>/dev/null || true
cp -r scripts/*.applescript "$APP_PATH/Contents/Resources/scripts/" 2>/dev/null || true
chmod +x "$APP_PATH/Contents/Resources/scripts/"*.sh 2>/dev/null || true

# Auto-install if requested
if [ "$AUTO_INSTALL" = true ]; then
    echo ""
    echo "🚀 Installing Video2PPT..."
    
    # Kill any running instances
    pkill -f Video2PPT 2>/dev/null || true
    
    # Remove old version if exists
    if [ -d "/Applications/Video2PPT.app" ]; then
        echo "  Removing old version..."
        rm -rf "/Applications/Video2PPT.app"
    fi
    
    # Copy new version
    echo "  Copying to Applications folder..."
    cp -r "$APP_PATH" /Applications/
    
    # Set proper permissions
    echo "  Setting permissions..."
    chmod -R 755 /Applications/Video2PPT.app
    
    # Launch once to register extension
    echo "  Registering Finder extension..."
    open /Applications/Video2PPT.app &
    sleep 3
    pkill -f Video2PPT 2>/dev/null || true
    
    echo ""
    echo "✅ Installation completed!"
    echo ""
    echo "⚠️  IMPORTANT: To enable the Finder extension:"
    echo "  1. Open System Settings"
    echo "  2. Go to Privacy & Security > Extensions > Finder Extensions"
    echo "  3. Check 'Video2PPT Extension'"
    echo ""
    echo "  The extension will then appear when right-clicking video files in Finder"
    
    # Try to open System Settings to the right pane (may not work on all macOS versions)
    echo ""
    read -p "Would you like to open System Settings now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "x-apple.systempreferences:com.apple.preference.security?Extensions"
    fi
else
    echo ""
    echo "To install manually:"
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
    echo ""
    echo "💡 Tip: Run './build.sh --install' to automatically install after building"
fi