#!/bin/bash

# Update version in all project files
# Called by semantic-release during the release process

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: Version number required"
    echo "Usage: $0 <version>"
    exit 1
fi

echo "📝 Updating project version to $VERSION"

# Update Python module version
if [ -f "video2ppt/__init__.py" ]; then
    echo "  Updating video2ppt/__init__.py"
    sed -i '' "s/__version__ = .*/__version__ = \"$VERSION\"/" video2ppt/__init__.py
fi

# Update Info.plist for macOS app
if [ -f "video2ppt/Video2PPT/Info.plist" ]; then
    echo "  Updating video2ppt/Video2PPT/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" \
        "video2ppt/Video2PPT/Info.plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" \
        "video2ppt/Video2PPT/Info.plist" 2>/dev/null || true
fi

# Update Info.plist for Finder extension
if [ -f "video2ppt/Video2PPTExtension/Info.plist" ]; then
    echo "  Updating video2ppt/Video2PPTExtension/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" \
        "video2ppt/Video2PPTExtension/Info.plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" \
        "video2ppt/Video2PPTExtension/Info.plist" 2>/dev/null || true
fi

# Update package.json if it exists
if [ -f "package.json" ]; then
    echo "  Updating package.json"
    npm version "$VERSION" --no-git-tag-version --allow-same-version 2>/dev/null || true
fi

# Update setup.py if it exists
if [ -f "setup.py" ]; then
    echo "  Updating setup.py"
    sed -i '' "s/version=.*/version='$VERSION',/" setup.py 2>/dev/null || true
fi

echo "✅ Version updated to $VERSION in all files"