#!/bin/bash

# Script to sign the Video2PPT app and extension for distribution
# This script creates a self-signed certificate if needed and signs the app

set -e

APP_PATH="$1"
OUTPUT_PATH="${2:-$APP_PATH}"

if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <app-path> [output-path]"
    echo "Example: $0 video2ppt/build/Build/Products/Release/Video2PPT.app"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "📝 Preparing to sign Video2PPT app..."

# Check if we have a signing identity
IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk '{print $2}')

if [ -z "$IDENTITY" ]; then
    echo "⚠️ No Developer ID found. Creating self-signed certificate..."
    
    # Check if self-signed certificate already exists
    SELF_SIGNED=$(security find-identity -v -p codesigning | grep "Video2PPT Self-Signed" | head -1 | awk '{print $2}')
    
    if [ -z "$SELF_SIGNED" ]; then
        # Create a self-signed certificate
        cat > /tmp/video2ppt_cert.conf << EOF
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[ req_distinguished_name ]
CN = Video2PPT Self-Signed

[ v3_ca ]
basicConstraints = critical,CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
EOF
        
        # Generate certificate
        openssl req -new -x509 -days 365 -nodes \
            -config /tmp/video2ppt_cert.conf \
            -keyout /tmp/video2ppt.key \
            -out /tmp/video2ppt.crt
        
        # Create p12 file
        openssl pkcs12 -export \
            -inkey /tmp/video2ppt.key \
            -in /tmp/video2ppt.crt \
            -out /tmp/video2ppt.p12 \
            -passout pass:video2ppt
        
        # Import to keychain
        security import /tmp/video2ppt.p12 -P video2ppt -T /usr/bin/codesign
        
        # Clean up
        rm -f /tmp/video2ppt.key /tmp/video2ppt.crt /tmp/video2ppt.p12 /tmp/video2ppt_cert.conf
        
        IDENTITY="Video2PPT Self-Signed"
    else
        IDENTITY="$SELF_SIGNED"
    fi
fi

echo "🔐 Using signing identity: $IDENTITY"

# Copy app to output location if different
if [ "$APP_PATH" != "$OUTPUT_PATH" ]; then
    echo "📋 Copying app to output location..."
    cp -R "$APP_PATH" "$OUTPUT_PATH"
    APP_PATH="$OUTPUT_PATH"
fi

# Sign the extension first
EXTENSION_PATH="$APP_PATH/Contents/PlugIns/Video2PPTExtension.appex"
if [ -d "$EXTENSION_PATH" ]; then
    echo "✍️ Signing Finder Extension..."
    codesign --force --deep --sign "$IDENTITY" \
        --entitlements "video2ppt/Video2PPTExtension/Video2PPTExtension.entitlements" \
        "$EXTENSION_PATH" 2>/dev/null || {
        echo "⚠️ Extension signing with entitlements failed, trying without..."
        codesign --force --deep --sign "$IDENTITY" "$EXTENSION_PATH"
    }
else
    echo "⚠️ Extension not found at $EXTENSION_PATH"
fi

# Sign the main app
echo "✍️ Signing main application..."
codesign --force --deep --sign "$IDENTITY" \
    --entitlements "video2ppt/Video2PPT/Video2PPT.entitlements" \
    "$APP_PATH" 2>/dev/null || {
    echo "⚠️ App signing with entitlements failed, trying without..."
    codesign --force --deep --sign "$IDENTITY" "$APP_PATH"
}

# Verify the signature
echo "🔍 Verifying signature..."
codesign --verify --deep --verbose=2 "$APP_PATH" 2>&1 | head -5

# Check if extension is properly embedded
if [ -d "$EXTENSION_PATH" ]; then
    echo "✅ Extension is embedded"
    codesign --verify --verbose=2 "$EXTENSION_PATH" 2>&1 | head -3
else
    echo "❌ Extension is NOT embedded"
fi

echo ""
echo "✨ Signing complete!"
echo ""
echo "⚠️ Important Notes for Unsigned/Self-Signed Apps:"
echo "1. On first launch, right-click the app and select 'Open'"
echo "2. Click 'Open' in the security dialog"
echo "3. Go to System Settings > Privacy & Security > Extensions"
echo "4. Enable 'Video2PPT Extension' under 'Finder Extensions'"
echo "5. You may need to restart Finder (Option+Right-click Finder, select 'Relaunch')"
echo ""
echo "The signed app is at: $APP_PATH"