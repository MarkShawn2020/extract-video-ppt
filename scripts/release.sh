#!/bin/bash

# Release script for Video2PPT
# This script helps create semantic version releases

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate version format
validate_version() {
    if [[ ! "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+\.[0-9]+)?$ ]]; then
        print_color "$RED" "❌ Invalid version format: $1"
        print_color "$YELLOW" "Expected format: v1.0.0 or v1.0.0-beta.1"
        exit 1
    fi
}

# Function to check if tag exists
check_tag_exists() {
    if git rev-parse "$1" >/dev/null 2>&1; then
        print_color "$RED" "❌ Tag $1 already exists"
        exit 1
    fi
}

# Function to get current version
get_current_version() {
    git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
}

# Function to increment version
increment_version() {
    local version=$1
    local type=$2
    
    # Remove 'v' prefix
    version=${version#v}
    
    # Split version
    IFS='.' read -r major minor patch <<< "$version"
    
    case $type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac
    
    echo "v${major}.${minor}.${patch}"
}

# Main script
print_color "$BLUE" "🚀 Video2PPT Release Script"
echo ""

# Check if we're in the right directory
if [ ! -f "build.sh" ] || [ ! -d "video2ppt" ]; then
    print_color "$RED" "❌ Please run this script from the project root directory"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_color "$YELLOW" "⚠️  You have uncommitted changes:"
    git status --short
    echo ""
    read -p "Do you want to commit these changes first? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " commit_msg
        git add -A
        git commit -m "$commit_msg"
    else
        print_color "$RED" "❌ Please commit or stash your changes before releasing"
        exit 1
    fi
fi

# Get current version
CURRENT_VERSION=$(get_current_version)
print_color "$GREEN" "Current version: $CURRENT_VERSION"
echo ""

# Ask for release type or custom version
echo "Select release type:"
echo "1) Major (breaking changes)"
echo "2) Minor (new features)"
echo "3) Patch (bug fixes)"
echo "4) Custom version"
echo "5) Pre-release (beta/alpha)"
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        NEW_VERSION=$(increment_version "$CURRENT_VERSION" "major")
        ;;
    2)
        NEW_VERSION=$(increment_version "$CURRENT_VERSION" "minor")
        ;;
    3)
        NEW_VERSION=$(increment_version "$CURRENT_VERSION" "patch")
        ;;
    4)
        read -p "Enter custom version (e.g., v1.2.3): " NEW_VERSION
        validate_version "$NEW_VERSION"
        ;;
    5)
        BASE_VERSION=$(increment_version "$CURRENT_VERSION" "patch")
        read -p "Enter pre-release type (alpha/beta/rc): " pre_type
        read -p "Enter pre-release number: " pre_num
        NEW_VERSION="${BASE_VERSION}-${pre_type}.${pre_num}"
        validate_version "$NEW_VERSION"
        ;;
    *)
        print_color "$RED" "❌ Invalid choice"
        exit 1
        ;;
esac

# Check if tag already exists
check_tag_exists "$NEW_VERSION"

print_color "$BLUE" "📝 Creating release: $NEW_VERSION"
echo ""

# Update version in files
print_color "$YELLOW" "📝 Updating version in project files..."

# Update Python module version
VERSION_NUMBER=${NEW_VERSION#v}
sed -i '' "s/__version__ = .*/__version__ = \"$VERSION_NUMBER\"/" video2ppt/__init__.py

# Update Info.plist (if exists)
if [ -f "video2ppt/Video2PPT/Info.plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION_NUMBER" \
        "video2ppt/Video2PPT/Info.plist" 2>/dev/null || true
fi

# Commit version changes
git add -A
git commit -m "chore: bump version to $NEW_VERSION" || true

# Generate changelog
print_color "$YELLOW" "📝 Generating changelog..."
echo ""
echo "Enter changelog for $NEW_VERSION (press Ctrl+D when done):"
CHANGELOG=$(cat)

# Create annotated tag
print_color "$YELLOW" "🏷️  Creating tag..."
git tag -a "$NEW_VERSION" -m "$NEW_VERSION

$CHANGELOG"

# Ask to push
echo ""
print_color "$GREEN" "✅ Release $NEW_VERSION prepared locally"
echo ""
read -p "Push to GitHub? This will trigger the release workflow (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_color "$YELLOW" "📤 Pushing to GitHub..."
    git push origin main
    git push origin "$NEW_VERSION"
    
    echo ""
    print_color "$GREEN" "🎉 Release $NEW_VERSION pushed successfully!"
    print_color "$BLUE" "GitHub Actions will now build and publish the release."
    echo ""
    echo "Monitor the release at:"
    echo "https://github.com/markshawn2020/video2ppt/actions"
    echo ""
    echo "Once complete, find the release at:"
    echo "https://github.com/markshawn2020/video2ppt/releases/tag/$NEW_VERSION"
else
    print_color "$YELLOW" "Release created locally. To push later, run:"
    echo "  git push origin main"
    echo "  git push origin $NEW_VERSION"
fi