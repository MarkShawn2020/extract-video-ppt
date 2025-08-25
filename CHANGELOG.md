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