#!/bin/bash

# Test script to validate release configuration locally
# This helps ensure the GitHub Actions workflow will succeed

set -e

echo "🔍 Testing Release Configuration Locally"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found. Run this script from the project root.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}1. Checking Node.js and npm...${NC}"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ Node.js $(node --version) installed${NC}"
else
    echo -e "${RED}❌ Node.js not installed${NC}"
    exit 1
fi

if command -v npm &> /dev/null; then
    echo -e "${GREEN}✅ npm $(npm --version) installed${NC}"
else
    echo -e "${RED}❌ npm not installed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. Checking package-lock.json...${NC}"
if [ -f "package-lock.json" ]; then
    echo -e "${GREEN}✅ package-lock.json exists${NC}"
else
    echo -e "${RED}❌ package-lock.json missing - run 'npm install'${NC}"
    exit 1
fi

echo -e "\n${YELLOW}3. Checking Xcode project...${NC}"
if [ -f "video2ppt/Video2PPT.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✅ Xcode project found at correct path${NC}"
else
    echo -e "${RED}❌ Xcode project not found at video2ppt/Video2PPT.xcodeproj${NC}"
    exit 1
fi

echo -e "\n${YELLOW}4. Checking Xcode scheme...${NC}"
if [ -f "video2ppt/Video2PPT.xcodeproj/xcshareddata/xcschemes/Video2PPT.xcscheme" ]; then
    echo -e "${GREEN}✅ Shared Xcode scheme exists${NC}"
else
    echo -e "${RED}❌ Shared Xcode scheme missing${NC}"
    exit 1
fi

echo -e "\n${YELLOW}5. Checking version synchronization...${NC}"
PACKAGE_VERSION=$(grep '"version"' package.json | head -1 | cut -d'"' -f4)
PYTHON_VERSION=$(grep "__version__" video2ppt/__init__.py | cut -d'"' -f2)
SETUP_VERSION=$(grep "version=" setup.py | cut -d"'" -f2)
PLIST_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" video2ppt/Video2PPT/Info.plist 2>/dev/null || echo "")

echo "  package.json: $PACKAGE_VERSION"
echo "  video2ppt/__init__.py: $PYTHON_VERSION"
echo "  setup.py: $SETUP_VERSION"
echo "  Info.plist: $PLIST_VERSION"

if [ "$PACKAGE_VERSION" = "$PYTHON_VERSION" ] && [ "$PYTHON_VERSION" = "$SETUP_VERSION" ] && [ "$SETUP_VERSION" = "$PLIST_VERSION" ]; then
    echo -e "${GREEN}✅ All versions synchronized at $PACKAGE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Version mismatch detected${NC}"
fi

echo -e "\n${YELLOW}6. Testing semantic-release (dry run)...${NC}"
echo "Running semantic-release in dry-run mode..."
if npx semantic-release --dry-run --no-ci; then
    echo -e "${GREEN}✅ Semantic release dry run successful${NC}"
else
    echo -e "${RED}❌ Semantic release dry run failed${NC}"
    echo "Check the error messages above for details"
fi

echo -e "\n${YELLOW}7. Checking update script...${NC}"
if [ -x "scripts/update-version.sh" ]; then
    echo -e "${GREEN}✅ update-version.sh is executable${NC}"
else
    if [ -f "scripts/update-version.sh" ]; then
        echo -e "${YELLOW}⚠️  update-version.sh exists but is not executable${NC}"
        echo "  Fix with: chmod +x scripts/update-version.sh"
    else
        echo -e "${RED}❌ update-version.sh not found${NC}"
    fi
fi

echo -e "\n${YELLOW}8. Testing Xcode build (if Xcode is available)...${NC}"
if command -v xcodebuild &> /dev/null; then
    echo "Testing build configuration..."
    if xcodebuild -project video2ppt/Video2PPT.xcodeproj -scheme Video2PPT -showBuildSettings > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Xcode build configuration valid${NC}"
    else
        echo -e "${RED}❌ Xcode build configuration failed${NC}"
        echo "  Run 'xcodebuild -project video2ppt/Video2PPT.xcodeproj -list' to see available schemes"
    fi
else
    echo -e "${YELLOW}⚠️  Xcode not available on this system${NC}"
fi

echo -e "\n${YELLOW}9. Checking git configuration...${NC}"
CURRENT_BRANCH=$(git branch --show-current)
echo "  Current branch: $CURRENT_BRANCH"
if [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "main" ]; then
    echo -e "${GREEN}✅ On release branch${NC}"
else
    echo -e "${YELLOW}⚠️  Not on master/main branch${NC}"
fi

echo -e "\n========================================"
echo -e "${GREEN}Release configuration test complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Ensure all checks above are green"
echo "2. Commit any pending changes with conventional commit format"
echo "3. Push to master to trigger semantic-release"
echo "4. Monitor GitHub Actions for the workflow status"