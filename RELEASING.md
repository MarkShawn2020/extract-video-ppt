# Release Guide for Video2PPT

This guide explains how to create and publish releases for Video2PPT.

## 🚀 Quick Release

### Automatic Release (Recommended)

```bash
# Use the release script
chmod +x scripts/release.sh
./scripts/release.sh

# Select version type and push
```

### Manual Release

```bash
# Create a semantic version tag
git tag -a v1.0.0 -m "Release v1.0.0: Initial release"

# Push the tag to trigger GitHub Actions
git push origin v1.0.0
```

## 📋 Release Process

### 1. Prepare Release

Before creating a release:

- [ ] All tests pass
- [ ] Code is properly formatted
- [ ] Documentation is updated
- [ ] Changelog is prepared
- [ ] Version numbers are updated

### 2. Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major** (v**X**.0.0): Breaking changes
- **Minor** (v1.**X**.0): New features, backward compatible
- **Patch** (v1.0.**X**): Bug fixes, backward compatible
- **Pre-release**: v1.0.0-**beta.1**, v1.0.0-**alpha.1**

Examples:
```bash
v1.0.0    # First stable release
v1.1.0    # New feature added
v1.1.1    # Bug fix
v2.0.0    # Breaking change
v2.0.0-beta.1  # Beta release
```

### 3. Create Release

#### Option A: Using Release Script (Easiest)

```bash
./scripts/release.sh
```

The script will:
1. Check for uncommitted changes
2. Show current version
3. Ask for new version (major/minor/patch/custom)
4. Update version in all files
5. Create git tag
6. Push to GitHub (triggers workflow)

#### Option B: Manual Git Tag

```bash
# Update version in files
vim video2ppt/__init__.py  # Update __version__

# Commit changes
git add -A
git commit -m "chore: bump version to v1.2.0"

# Create annotated tag
git tag -a v1.2.0 -m "Release v1.2.0

- Feature: Added re-convert button
- Fix: Improved timestamp accuracy
- Enhancement: Better UI design"

# Push
git push origin main
git push origin v1.2.0
```

#### Option C: GitHub Web UI

1. Go to [Releases](https://github.com/markshawn2020/video2ppt/releases)
2. Click "Create a new release"
3. Create new tag (e.g., `v1.2.0`)
4. Fill in release notes
5. Publish (triggers workflow)

## 🤖 Automated Build Process

When you push a version tag (`v*.*.*`), GitHub Actions automatically:

1. **Builds** the macOS app
2. **Creates** DMG installer
3. **Generates** changelog from commits
4. **Publishes** GitHub release
5. **Uploads** DMG as release asset

### Monitor Progress

Watch the build at: [GitHub Actions](https://github.com/markshawn2020/video2ppt/actions)

### Build Outputs

- **DMG File**: `Video2PPT-v1.2.0.dmg`
- **Release Page**: Auto-generated with changelog
- **Download URL**: `https://github.com/markshawn2020/video2ppt/releases/latest`

## 📝 Changelog Format

### Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat: add re-convert button for quick iterations
fix: correct timestamp calculation using float precision
docs: update README with new screenshots
chore: update dependencies
build: improve DMG creation process
ci: add automatic release workflow
```

### Release Notes Template

```markdown
# Video2PPT v1.2.0

## 🚀 What's New
- Added re-convert button for quick iterations
- Improved UI with gradient backgrounds
- Fixed timestamp accuracy issues

## 🐛 Bug Fixes
- Fixed cumulative timestamp error
- Resolved Finder extension registration

## 📦 Installation
1. Download DMG below
2. Drag to Applications
3. Enable Finder extension

## 📊 Stats
- DMG Size: 15MB
- Supported macOS: 11.0+
```

## 🔑 Code Signing (Optional)

### Setup Signed Releases

1. **Get Apple Developer Certificate**
   - Join Apple Developer Program ($99/year)
   - Create "Developer ID Application" certificate

2. **Add GitHub Secrets**
   ```
   APPLE_CERTIFICATE: base64 encoded .p12 file
   APPLE_CERTIFICATE_PASSWORD: certificate password
   APPLE_TEAM_ID: your team ID (e.g., XXXXXXXXXX)
   APPLE_IDENTITY: "Developer ID Application: Your Name (XXXXXXXXXX)"
   ```

3. **Export Certificate**
   ```bash
   # Export from Keychain
   security export -k ~/Library/Keychains/login.keychain-db \
     -t identities -f pkcs12 -o cert.p12

   # Convert to base64
   base64 -i cert.p12 | pbcopy

   # Add to GitHub secrets
   ```

4. **Use Signed Workflow**
   ```bash
   # Trigger signed release manually
   gh workflow run release-signed.yml -f version=v1.2.0
   ```

## 🧪 Testing Releases

### Test Build Locally

```bash
# Test the build process
./build.sh

# Test DMG creation
./build_dmg_pro.sh --build

# Verify DMG
hdiutil verify Video2PPT-*.dmg
```

### Test GitHub Actions

```bash
# Test workflow without creating release
git tag v0.0.1-test
git push origin v0.0.1-test

# Delete test tag after
git tag -d v0.0.1-test
git push origin --delete v0.0.1-test
```

## 📊 Release Checklist

Before releasing:

- [ ] Update version in `video2ppt/__init__.py`
- [ ] Update `CHANGELOG.md`
- [ ] Test build locally
- [ ] Commit all changes
- [ ] Create version tag
- [ ] Push tag to GitHub
- [ ] Verify GitHub Actions build
- [ ] Check release page
- [ ] Test download DMG
- [ ] Announce release

## 🚨 Troubleshooting

### Build Fails on GitHub Actions

```bash
# Check logs
gh run list --workflow=release.yml
gh run view <run-id>

# Re-run failed workflow
gh run rerun <run-id>
```

### DMG Creation Fails

```bash
# Check disk space
df -h

# Clear build cache
rm -rf Video2PPT/build
./build.sh --clean
```

### Tag Already Exists

```bash
# Delete local tag
git tag -d v1.2.0

# Delete remote tag
git push origin --delete v1.2.0

# Recreate tag
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

## 📚 Resources

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Apple Code Signing](https://developer.apple.com/documentation/security/code_signing_services)

## 🎉 Release Announcement Template

After successful release:

```markdown
🎉 Video2PPT v1.2.0 Released!

✨ Highlights:
- Re-convert button for quick iterations
- Beautiful new UI with gradients
- Improved performance

📦 Download: [Video2PPT-v1.2.0.dmg](link)
📝 Changelog: [Full changelog](link)

Thanks to all contributors! 🙏
```

Post to:
- GitHub Discussions
- Twitter/X
- Product Hunt (major releases)
- Reddit r/macapps