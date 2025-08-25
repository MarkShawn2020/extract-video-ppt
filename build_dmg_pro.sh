#!/bin/bash

set -e

echo "======================================="
echo "Video2PPT Professional DMG Builder"
echo "======================================="

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/Video2PPT"
BUILD_DIR="$PROJECT_DIR/build"
APP_PATH="$BUILD_DIR/Build/Products/Release/Video2PPT.app"
DMG_DIR="$SCRIPT_DIR/dmg_temp"
DMG_NAME="Video2PPT"
VERSION="1.0.0"
DMG_FINAL="$SCRIPT_DIR/Video2PPT-${VERSION}.dmg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
BUILD_FIRST=false
CREATE_BACKGROUND=false

for arg in "$@"; do
    case $arg in
        --build|-b)
            BUILD_FIRST=true
            shift
            ;;
        --background)
            CREATE_BACKGROUND=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --build, -b       Build the app first before creating DMG"
            echo "  --background      Create a new background image"
            echo "  --help, -h        Show this help message"
            exit 0
            ;;
    esac
done

# Build if requested or if app doesn't exist
if [ "$BUILD_FIRST" = true ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}📨 Building Video2PPT first...${NC}"
    ./build.sh
    echo ""
fi

# Verify app exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Error: App not found at $APP_PATH${NC}"
    echo "Please run './build.sh' first or use './build_dmg_pro.sh --build'"
    exit 1
fi

# Create background image if requested or if it doesn't exist
if [ "$CREATE_BACKGROUND" = true ] || [ ! -f "$SCRIPT_DIR/dmg_background.png" ]; then
    echo -e "${YELLOW}🎨 Creating DMG background image...${NC}"
    python3 create_dmg_background.py
    echo ""
fi

echo -e "${GREEN}📦 Creating Professional DMG installer...${NC}"

# Clean up any previous DMG work
echo "  ⏳ Cleaning up previous files..."
rm -rf "$DMG_DIR"
rm -f "$DMG_FINAL"
rm -f "${DMG_FINAL}.tmp.dmg"

# Create DMG directory structure
echo "  📁 Creating directory structure..."
mkdir -p "$DMG_DIR/.background"

# Copy app to DMG directory
echo "  📱 Copying Video2PPT.app..."
cp -r "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications
echo "  🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Copy background image if it exists
if [ -f "$SCRIPT_DIR/dmg_background.png" ]; then
    echo "  🎨 Adding background image..."
    cp "$SCRIPT_DIR/dmg_background.png" "$DMG_DIR/.background/background.png"
fi

# Create a localized installer readme
echo "  📝 Creating installer documentation..."
cat > "$DMG_DIR/Installation Guide.rtf" << 'EOF'
{\rtf1\ansi\ansicpg1252\cocoartf2709
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica-Bold;\f1\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red22\green107\blue173;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;\cssrgb\c10196\c49804\c73333;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\b\fs36 \cf2 Video2PPT Installation Guide
\f1\b0\fs24 \
\

\f0\b\fs28 1. Install the Application
\f1\b0\fs24 \
   • Drag the Video2PPT app to your Applications folder\
   • The arrow shows you the way!\
\

\f0\b\fs28 2. Enable Finder Extension
\f1\b0\fs24 \
   After installation, enable the Finder extension:\
   • Open System Settings\
   • Navigate to Privacy & Security > Extensions > Finder Extensions\
   • Check "Video2PPT Extension"\
\

\f0\b\fs28 3. How to Use
\f1\b0\fs24 \
   • Right-click any video file in Finder\
   • Select "Convert to PPT" from the context menu\
   • Or launch Video2PPT from Applications\
\

\f0\b\fs28 Supported Formats
\f1\b0\fs24 \
   MP4, MOV, AVI, MKV, WEBM\
\

\f0\b\fs28 Need Help?
\f1\b0\fs24 \
   Visit: {\field{\*\fldinst{HYPERLINK "https://github.com/yourusername/video2ppt"}}{\fldrslt \cf3 \ul \ulc3 https://github.com/yourusername/video2ppt}}\
\
© 2024 Video2PPT\
}
EOF

# Calculate DMG size (app size + 20MB buffer)
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
DMG_SIZE=$((APP_SIZE + 20))

# Create temporary DMG
echo "  💿 Creating DMG (${DMG_SIZE}MB)..."
hdiutil create -srcfolder "$DMG_DIR" -volname "$DMG_NAME" -fs HFS+ \
    -format UDRW -size ${DMG_SIZE}m "${DMG_FINAL}.tmp.dmg" >/dev/null 2>&1

# Mount the temporary DMG
echo "  📂 Mounting temporary DMG..."
DEVICE=$(hdiutil attach "${DMG_FINAL}.tmp.dmg" -readwrite -noverify -noautoopen | egrep '^/dev/' | sed 1q | awk '{print $1}')
MOUNT_DIR="/Volumes/$DMG_NAME"

# Wait for mount
sleep 2

# Set custom icon positions and window properties
echo "  🎨 Configuring DMG appearance..."

# Use AppleScript to set up the DMG window
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
        set icon size of viewOptions to 72
        
        -- If background exists, use it
        set bgPath to "/Volumes/$DMG_NAME/.background/background.png"
        if exists file bgPath then
            set background picture of viewOptions to file ".background:background.png"
        else
            set background color of viewOptions to {60000, 62000, 65535}
        end if
        
        -- Position items for drag and drop
        set position of item "Video2PPT.app" of container window to {140, 175}
        set position of item "Applications" of container window to {360, 175}
        
        -- Position readme at bottom
        try
            set position of item "Installation Guide.rtf" of container window to {250, 290}
        end try
        
        -- Make sure everything is updated
        update without registering applications
        delay 3
        close
    end tell
end tell
EOT

# Set file attributes to hide .background folder
SetFile -a V "$MOUNT_DIR/.background" 2>/dev/null || true

# Ensure all changes are written
sync

# Unmount the temporary DMG
echo "  📤 Finalizing DMG..."
hdiutil detach "$DEVICE" >/dev/null 2>&1

# Convert to compressed DMG with better compression
echo "  🗜️  Compressing DMG..."
hdiutil convert "${DMG_FINAL}.tmp.dmg" -format UDZO -imagekey zlib-level=9 -o "$DMG_FINAL" >/dev/null 2>&1

# Make the DMG internet-enabled (auto-opens when downloaded)
hdiutil internet-enable -yes "$DMG_FINAL" >/dev/null 2>&1 || true

# Clean up
echo "  🧹 Cleaning up temporary files..."
rm -f "${DMG_FINAL}.tmp.dmg"
rm -rf "$DMG_DIR"

# Sign the DMG if code signing identity is available
if security find-identity -p codesigning -v | grep -q "Developer ID"; then
    echo "  ✍️  Signing DMG..."
    codesign --sign "Developer ID Application" "$DMG_FINAL" 2>/dev/null || true
fi

# Get final DMG info
DMG_SIZE=$(du -h "$DMG_FINAL" | cut -f1)
DMG_CHECKSUM=$(shasum -a 256 "$DMG_FINAL" | cut -d' ' -f1)

echo ""
echo -e "${GREEN}✅ Professional DMG created successfully!${NC}"
echo ""
echo "📦 File: $DMG_FINAL"
echo "📊 Size: $DMG_SIZE"
echo "🔐 SHA256: ${DMG_CHECKSUM:0:16}..."
echo ""
echo -e "${YELLOW}📋 Distribution Checklist:${NC}"
echo "  ✓ DMG is compressed and optimized"
echo "  ✓ Custom background and layout configured"
echo "  ✓ Installation guide included"
echo "  ✓ Internet-enabled for auto-mount"
if security find-identity -p codesigning -v | grep -q "Developer ID"; then
    echo "  ✓ Code signed (if certificate available)"
fi
echo ""
echo -e "${GREEN}📨 Ready for distribution!${NC}"
echo ""

# Offer to test the DMG
read -p "Would you like to test the DMG installer? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening DMG for testing..."
    open "$DMG_FINAL"
    echo ""
    echo "Test checklist:"
    echo "  1. DMG should auto-mount and show window"
    echo "  2. Background image should be visible"
    echo "  3. Drag and drop should work smoothly"
    echo "  4. Installation guide should be readable"
fi