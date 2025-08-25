# GitHub Actions Release Workflow Documentation

## ✅ Release Automation Successfully Configured

The video2ppt project now has a fully automated release pipeline using GitHub Actions and semantic-release. 

### 🎉 What Was Accomplished

1. **Fixed Critical Workflow Issues**
   - ✅ Corrected Xcode project paths (`Video2PPT` → `video2ppt`)
   - ✅ Unified branch configuration to use `master` consistently
   - ✅ Updated deprecated GitHub Actions syntax (`::set-output` → `$GITHUB_OUTPUT`)
   - ✅ Synchronized version numbers across all files to 1.0.0
   - ✅ Added missing files to semantic-release git assets
   - ✅ Created and shared Xcode scheme for automated builds
   - ✅ Fixed `.gitignore` to allow shared Xcode schemes

2. **Successful First Release**
   - Version 1.0.1 was automatically released
   - DMG artifact was built and uploaded to GitHub releases
   - Changelog was automatically generated
   - All version files were updated automatically

### 📋 How the Release Process Works

1. **Trigger**: Push commits to `master` branch with conventional commit format
2. **Semantic Release**: Analyzes commits and determines version bump
3. **Version Update**: Updates all version files (Python, Xcode, package.json)
4. **Build**: Compiles macOS app with new version
5. **Package**: Creates DMG installer
6. **Release**: Publishes GitHub release with DMG and changelog

### 🔧 Configuration Files

- `.github/workflows/semantic-release.yml` - Main release workflow
- `.releaserc.json` - Semantic release configuration
- `scripts/update-version.sh` - Version update script
- `scripts/test-release-local.sh` - Local validation script
- `package.json` & `package-lock.json` - Node.js dependencies for tooling
- `commitlint.config.js` - Commit message validation

### 📝 Commit Message Format

Follow conventional commits for automatic versioning:

```
feat: new feature (minor version bump)
fix: bug fix (patch version bump)
docs: documentation only
style: formatting changes
refactor: code restructuring
perf: performance improvements
test: adding tests
build: build system changes
ci: CI/CD changes
chore: maintenance tasks

BREAKING CHANGE: in footer (major version bump)
```

### 🚀 Usage

1. **Make changes** to the codebase
2. **Commit** with conventional commit format:
   ```bash
   git commit -m "feat: add new video format support"
   ```
3. **Push** to master:
   ```bash
   git push origin master
   ```
4. **Monitor** the GitHub Actions workflow
5. **Release** will be created automatically with:
   - Version bump based on commit type
   - Changelog generation
   - DMG build and upload
   - Version file updates

### 🧪 Testing

Run the local test script to validate configuration:

```bash
./scripts/test-release-local.sh
```

This checks:
- Node.js and npm installation
- Package lock file existence
- Xcode project and scheme configuration
- Version synchronization
- Semantic release dry run
- Build configuration

### 📊 Release History

- **v1.0.1** (2025-08-25): Fixed GitHub Actions release workflow
- **v1.0.0**: Initial version with semantic versioning

### 🔗 Links

- [Latest Release](https://github.com/MarkShawn2020/video2ppt/releases/latest)
- [All Releases](https://github.com/MarkShawn2020/video2ppt/releases)
- [Workflow Runs](https://github.com/MarkShawn2020/video2ppt/actions/workflows/semantic-release.yml)