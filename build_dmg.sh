#!/bin/bash

set -e

echo "==================================="
echo "Video2PPT DMG Installer Builder"
echo "==================================="

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/Video2PPT"
BUILD_DIR="$PROJECT_DIR/build"
APP_PATH="$BUILD_DIR/Build/Products/Release/Video2PPT.app"
DMG_DIR="$SCRIPT_DIR/dmg_temp"
DMG_NAME="Video2PPT-Installer"
DMG_FINAL="$SCRIPT_DIR/Video2PPT-Installer.dmg"

# Parse command line arguments
BUILD_FIRST=false
for arg in "$@"; do
    case $arg in
        --build|-b)
            BUILD_FIRST=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --build, -b    Build the app first before creating DMG"
            echo "  --help, -h     Show this help message"
            exit 0
            ;;
    esac
done

# Build if requested or if app doesn't exist
if [ "$BUILD_FIRST" = true ] || [ ! -d "$APP_PATH" ]; then
    echo "Building Video2PPT first..."
    ./build.sh
    echo ""
fi

# Verify app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    echo "Please run './build.sh' first or use './build_dmg.sh --build'"
    exit 1
fi

echo "📦 Creating DMG installer..."

# Clean up any previous DMG work
echo "  Cleaning up previous DMG files..."
rm -rf "$DMG_DIR"
rm -f "$DMG_FINAL"
rm -f "${DMG_FINAL}.tmp.dmg"

# Create DMG directory structure
echo "  Creating DMG directory structure..."
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
echo "  Copying Video2PPT.app..."
cp -r "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications
echo "  Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Create README file
echo "  Creating README..."
cat > "$DMG_DIR/README.txt" << 'EOF'
Video2PPT Installation Instructions
===================================

1. INSTALL THE APP:
   Drag the Video2PPT app to the Applications folder

2. ENABLE FINDER EXTENSION:
   After installation, you need to enable the Finder extension:
   
   a. Open System Settings
   b. Go to Privacy & Security > Extensions > Finder Extensions
   c. Check "Video2PPT Extension"

3. USAGE:
   - Right-click any video file in Finder
   - Select "Convert to PPT" from the context menu
   - Or launch Video2PPT from Applications

4. SUPPORTED VIDEO FORMATS:
   MP4, MOV, AVI, MKV, WEBM

For more information, visit:
https://github.com/yourusername/video2ppt

© 2024 Video2PPT
EOF

# Create a simple DS_Store for window settings
echo "  Setting up DMG window..."

# Create temporary DMG
echo "  Creating temporary DMG..."
hdiutil create -srcfolder "$DMG_DIR" -volname "$DMG_NAME" -fs HFS+ \
    -format UDRW -size 100m "${DMG_FINAL}.tmp.dmg" >/dev/null 2>&1

# Mount the temporary DMG
echo "  Mounting temporary DMG..."
MOUNT_DIR="/Volumes/$DMG_NAME"
hdiutil attach "${DMG_FINAL}.tmp.dmg" -readwrite -noverify -noautoopen >/dev/null 2>&1

# Wait for mount
sleep 2

# Set custom icon positions and window properties using AppleScript
echo "  Configuring DMG appearance..."
osascript << EOT
tell application "Finder"
    tell disk "$DMG_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 80
        set background color of viewOptions to {65535, 65535, 65535}
        
        -- Set positions
        set position of item "Video2PPT.app" of container window to {125, 180}
        set position of item "Applications" of container window to {375, 180}
        set position of item "README.txt" of container window to {250, 280}
        
        update without registering applications
        delay 2
        close
    end tell
end tell
EOT

# Ensure Finder updates
sync

# Unmount the temporary DMG
echo "  Unmounting temporary DMG..."
hdiutil detach "$MOUNT_DIR" >/dev/null 2>&1

# Convert to compressed DMG
echo "  Creating final compressed DMG..."
hdiutil convert "${DMG_FINAL}.tmp.dmg" -format UDZO -o "$DMG_FINAL" >/dev/null 2>&1

# Clean up
echo "  Cleaning up..."
rm -f "${DMG_FINAL}.tmp.dmg"
rm -rf "$DMG_DIR"

# Get DMG size
DMG_SIZE=$(du -h "$DMG_FINAL" | cut -f1)

echo ""
echo "✅ DMG created successfully!"
echo ""
echo "📦 File: $DMG_FINAL"
echo "📊 Size: $DMG_SIZE"
echo ""
echo "Installation instructions:"
echo "1. Double-click the DMG file to mount it"
echo "2. Drag Video2PPT to the Applications folder"
echo "3. Enable the Finder extension in System Settings"
echo ""
echo "You can now distribute this DMG file to users!"

# Optionally open the DMG
read -p "Would you like to open the DMG now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$DMG_FINAL"
fi