#!/bin/bash

# Test release process locally before pushing to GitHub

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Release Process Locally${NC}"
echo ""

# 1. Check environment
echo -e "${YELLOW}1. Checking environment...${NC}"
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not installed"
    exit 1
fi
echo "✅ Xcode: $(xcodebuild -version | head -1)"

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not installed"
    exit 1
fi
echo "✅ Python: $(python3 --version)"

# 2. Test build
echo ""
echo -e "${YELLOW}2. Testing build...${NC}"
echo "Building app..."
if ./build.sh > /dev/null 2>&1; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# 3. Test DMG creation
echo ""
echo -e "${YELLOW}3. Testing DMG creation...${NC}"

# Create test version
TEST_VERSION="v99.99.99-test"
export VERSION=$TEST_VERSION

# Test DMG creation script
if [ -f "build_dmg_pro.sh" ]; then
    echo "Creating test DMG..."
    
    # Create a minimal DMG
    APP_PATH="Video2PPT/build/Build/Products/Release/Video2PPT.app"
    if [ -d "$APP_PATH" ]; then
        DMG_NAME="Video2PPT-${TEST_VERSION}.dmg"
        DMG_TEMP="dmg_test_temp"
        
        rm -rf "$DMG_TEMP"
        mkdir -p "$DMG_TEMP"
        cp -r "$APP_PATH" "$DMG_TEMP/"
        ln -s /Applications "$DMG_TEMP/Applications"
        
        hdiutil create -srcfolder "$DMG_TEMP" -volname "Video2PPT" \
            -fs HFS+ -format UDZO -o "$DMG_NAME" > /dev/null 2>&1
        
        if [ -f "$DMG_NAME" ]; then
            echo "✅ DMG created: $DMG_NAME ($(du -h "$DMG_NAME" | cut -f1))"
            rm "$DMG_NAME"
        else
            echo "❌ DMG creation failed"
        fi
        
        rm -rf "$DMG_TEMP"
    else
        echo "❌ App not found"
    fi
else
    echo "⚠️  DMG script not found"
fi

# 4. Test version update
echo ""
echo -e "${YELLOW}4. Testing version update...${NC}"

# Backup current version
if [ -f "video2ppt/__init__.py" ]; then
    cp video2ppt/__init__.py video2ppt/__init__.py.bak
    
    # Test version update
    sed -i '' "s/__version__ = .*/__version__ = \"99.99.99\"/" video2ppt/__init__.py
    
    if grep -q "99.99.99" video2ppt/__init__.py; then
        echo "✅ Version update works"
    else
        echo "❌ Version update failed"
    fi
    
    # Restore
    mv video2ppt/__init__.py.bak video2ppt/__init__.py
else
    echo "⚠️  Python module not found"
fi

# 5. Test changelog generation
echo ""
echo -e "${YELLOW}5. Testing changelog generation...${NC}"

# Get recent commits
COMMITS=$(git log --oneline -5 2>/dev/null | head -5)
if [ -n "$COMMITS" ]; then
    echo "✅ Can read git history"
    echo "Recent commits:"
    echo "$COMMITS" | sed 's/^/  /'
else
    echo "⚠️  No git history"
fi

# 6. Check GitHub configuration
echo ""
echo -e "${YELLOW}6. Checking GitHub configuration...${NC}"

# Check if .github/workflows exists
if [ -d ".github/workflows" ]; then
    echo "✅ GitHub workflows directory exists"
    
    # List workflows
    echo "Workflows:"
    for workflow in .github/workflows/*.yml; do
        if [ -f "$workflow" ]; then
            echo "  - $(basename "$workflow")"
        fi
    done
else
    echo "❌ No .github/workflows directory"
fi

# Check remote
REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE" ]; then
    echo "✅ Git remote: $REMOTE"
else
    echo "⚠️  No git remote configured"
fi

# 7. Simulate release
echo ""
echo -e "${YELLOW}7. Simulating release process...${NC}"

echo "Would perform these steps:"
echo "  1. Update version in files"
echo "  2. Commit version changes"
echo "  3. Create tag: $TEST_VERSION"
echo "  4. Push to GitHub (triggers workflow)"
echo "  5. GitHub Actions builds DMG"
echo "  6. GitHub creates release with DMG"

# Summary
echo ""
echo -e "${GREEN}✅ Release test complete!${NC}"
echo ""
echo "To create a real release:"
echo "  1. Run: ./scripts/release.sh"
echo "  2. Choose version type"
echo "  3. Push to GitHub"
echo ""
echo "Or manually:"
echo "  git tag -a v1.0.0 -m 'Release v1.0.0'"
echo "  git push origin v1.0.0"