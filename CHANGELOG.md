# Changelog

All notable changes to Video2PPT will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.1](https://github.com/markshawn2020/video2ppt/compare/v2.0.0...v2.0.1) (2025-08-25)

### 🐛 Bug Fixes

* update version ([09e8647](https://github.com/markshawn2020/video2ppt/commit/09e864736aeee899fe7fc66a4dfe12be71f0a466))

## [2.0.0](https://github.com/markshawn2020/video2ppt/compare/v1.0.3...v2.0.0) (2025-08-25)

### ⚠ BREAKING CHANGES

* Finder Extension requires manual activation in System Settings

Added features:
- ExtensionManager for detecting and activating Finder Extension
- In-app extension status indicator with direct link to settings
- First-launch prompt to guide users through extension activation
- Self-signing script for better extension compatibility
- Comprehensive installation guide with troubleshooting steps
- FAQ documentation for common issues
- Diagnostic tools for debugging extension problems

Fixed issues:
- Extension not appearing due to unsigned app (documented workaround)
- Version synchronization across all components
- Build workflow now attempts app signing

Documentation:
- Added detailed INSTALLATION_GUIDE.md with step-by-step instructions
- Created FAQ.md addressing common questions and issues
- Updated README with prominent extension activation notice
- Added troubleshooting section for extension problems

This addresses the issue where users couldn't see the right-click
'Convert to PPT' option after installing the app. The root cause is
macOS security restrictions on unsigned Finder Extensions.

### ✨ Features

* add extension activation support and comprehensive documentation ([2c6b459](https://github.com/markshawn2020/video2ppt/commit/2c6b4592415ee873358879e0b14cab7a7896d95e))

## [1.0.3](https://github.com/markshawn2020/video2ppt/compare/v1.0.2...v1.0.3) (2025-08-25)

### 🐛 Bug Fixes

* correct Python module test execution in workflows ([b19a58a](https://github.com/markshawn2020/video2ppt/commit/b19a58a18286589ad9068a964c467c6fea53d362))

## [1.0.2](https://github.com/markshawn2020/video2ppt/compare/v1.0.1...v1.0.2) (2025-08-25)

### 🐛 Bug Fixes

* resolve test build workflow failures ([1bd4ed1](https://github.com/markshawn2020/video2ppt/commit/1bd4ed1538b5a96578a0269efb63b7a95eb551af))

### 📚 Documentation

* add release workflow documentation and test script ([1e0484f](https://github.com/markshawn2020/video2ppt/commit/1e0484fa4b25e75100694abb032d5b194e41adfb))

## [1.0.1](https://github.com/markshawn2020/video2ppt/compare/v1.0.0...v1.0.1) (2025-08-25)

### 🐛 Bug Fixes

* repair GitHub Actions release workflow for automated semantic releases ([bb01889](https://github.com/markshawn2020/video2ppt/commit/bb01889885b6ea91099aa737a92b8638f59a3103))

## 1.0.0 (2025-08-25)

### ✨ Features

* fix frame rate problem ([e59955c](https://github.com/markshawn2020/video2ppt/commit/e59955c93af325698d11474ade2f2fc5770cd4ec))
* init CLAUDE ([74bbc92](https://github.com/markshawn2020/video2ppt/commit/74bbc92b744d6c7a163f8d62c56bab6368e1394f))
* merge support-mac-extension ([92d78a8](https://github.com/markshawn2020/video2ppt/commit/92d78a810502da6a07d828c36fd327ae56c62eff))
* rename evp --> video2ppt/v2p ([d07c9cd](https://github.com/markshawn2020/video2ppt/commit/d07c9cda67d9cc64928e0985fdbfc9106850789e))
* support mac right click ([ab0cd1b](https://github.com/markshawn2020/video2ppt/commit/ab0cd1b5f4dc3eeca9b1236978d3bc56f383fe1f))
* support png export, more friendly, etc. ([51368e8](https://github.com/markshawn2020/video2ppt/commit/51368e8b6a37a5fb012057fa5758dccd7d189724))
* support semantic release ([c857fde](https://github.com/markshawn2020/video2ppt/commit/c857fdee15ecabdd86a8b9b6dd2315079d020aea))
* to support release workflow ([67652e5](https://github.com/markshawn2020/video2ppt/commit/67652e526cea99cf08ed173d49e93464dd7da5d5))
* to support release workflow | update ([9be1cad](https://github.com/markshawn2020/video2ppt/commit/9be1cad5b72422479dcbfa2599abbe02bbee9722))

### 🐛 Bug Fixes

* mac app extension ([9cceee4](https://github.com/markshawn2020/video2ppt/commit/9cceee4ed5e8b0e957d37baa3622e16c346278e5))
* update mac extension ([d4325ce](https://github.com/markshawn2020/video2ppt/commit/d4325cedac80947bde05fbd1947a9adb793a1ba8))

### 📚 Documentation

* update readme ([9c22aa0](https://github.com/markshawn2020/video2ppt/commit/9c22aa0c99aeee125a63973d9390b037725dada8))
* update readme ([3cece13](https://github.com/markshawn2020/video2ppt/commit/3cece13928c6446fea2c6f20a9a1749687bd2cb6))

### 📦 Build System

* add package-lock.json for semantic-release workflow ([9eb9959](https://github.com/markshawn2020/video2ppt/commit/9eb9959368879ef7fd9edd5a8cb85aed2ca2280a))

# Changelog

All notable changes to Video2PPT will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions workflow for automatic releases
- Re-convert button for quick iterations with same file
- Beautiful modern UI with gradient backgrounds
- File size display in the interface
- Smooth animations and transitions
- Three-button action panel after conversion
- Professional DMG installer with background image
- Automatic installation script (`./build.sh --install`)

### Changed
- Improved UI with card-based layout
- Enhanced visual hierarchy with better spacing
- Similarity now displayed as percentage (60% vs 0.6)
- Better status messages with icons

### Fixed
- Finder not automatically opening after conversion
- Window now stays open after conversion completes
- Timestamp accuracy using float-based calculations

## [v1.0.0] - 2024-01-XX

### Added
- Initial release of Video2PPT for macOS
- Native Finder integration with right-click menu
- SwiftUI interface for beautiful native experience
- Smart frame extraction with similarity detection
- Export to PNG frames or PDF document
- Real-time conversion progress tracking
- Automatic output folder organization

### Features
- 🖱️ Right-click any video in Finder to convert
- 🎯 Histogram-based similarity comparison
- 📁 Multiple export formats (PNG/PDF)
- ⏱️ Accurate timestamp preservation
- 🚀 Native macOS app with SwiftUI

### Technical
- Finder Sync Extension implementation
- Python backend integration via Process
- URL scheme for inter-process communication
- OpenCV-based frame extraction
- FPDF2 for PDF generation

## [v0.9.0-beta] - 2024-01-XX

### Added
- Beta release for testing
- Basic frame extraction functionality
- Command-line interface
- Finder extension prototype

### Known Issues
- Extension requires manual enablement
- Some video formats not supported
- Performance optimization needed

---

## Version History Format

### Version Tags
- **Major**: Breaking changes (v**X**.0.0)
- **Minor**: New features (v1.**X**.0)
- **Patch**: Bug fixes (v1.0.**X**)
- **Pre-release**: Beta/Alpha (v1.0.0-**beta.1**)

### Change Categories
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes

## Links

- [Releases](https://github.com/markshawn2020/video2ppt/releases)
- [Compare Versions](https://github.com/markshawn2020/video2ppt/compare)
- [Commit History](https://github.com/markshawn2020/video2ppt/commits/main)
