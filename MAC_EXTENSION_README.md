# Video2PPT macOS Finder Extension

A native macOS Finder extension that adds a right-click context menu for converting videos to PowerPoint-like presentations.

## Features

- **Native Finder Integration**: Right-click any video file to convert
- **Beautiful SwiftUI Interface**: Modern, intuitive conversion settings
- **Smart Frame Extraction**: Automatically identifies key frames based on visual differences
- **Multiple Export Formats**: PNG frames or PDF document
- **Customizable Settings**:
  - Similarity threshold (0.1-1.0)
  - PDF filename customization
  - Optional timestamp overlay
- **Background Processing**: Non-blocking conversion with progress tracking
- **Sandboxed & Secure**: Follows Apple's security best practices

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode 15.0 or later (for building)
- Python 3.x with video2ppt installed
- Administrator access (for first-time extension enabling)

## Installation

### Option 1: Build from Source

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd video2ppt/.feats/support-mac-extension
   ```

2. **Install Python dependencies**:
   ```bash
   # Navigate to main project directory
   cd ../../
   pip install -e .
   ```

3. **Build the macOS app**:
   ```bash
   cd .feats/support-mac-extension
   ./build.sh
   ```

4. **Install the app**:
   ```bash
   cp -r Video2PPT/build/Build/Products/Release/Video2PPT.app /Applications/
   ```

5. **Launch the app once** to register the extension:
   ```bash
   open /Applications/Video2PPT.app
   ```

6. **Enable the Finder extension**:
   - Open System Settings
   - Go to Privacy & Security → Extensions → Finder Extensions
   - Check "Video2PPT Extension"
   - You may need to restart Finder: `killall Finder`

### Option 2: Using Xcode

1. Open `Video2PPT/Video2PPT.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run (⌘+R)
4. Follow steps 5-6 from Option 1

## Usage

1. **Right-click any video file** in Finder (supported formats: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV, MPG, MPEG)
2. Select **"Convert to PPT"** from the context menu
3. The Video2PPT window will open with your file loaded
4. **Configure settings**:
   - **Output Format**: Choose PNG (individual frames) or PDF (document)
   - **Similarity**: Adjust threshold (lower = more frames, higher = fewer frames)
   - **PDF Name**: Set output filename (PDF only)
   - **Add Timestamps**: Include time overlay on frames
5. Click **Convert** to start processing
6. The output folder will open automatically when complete

## Architecture

### Components

1. **Main App** (`Video2PPT.app`)
   - SwiftUI-based user interface
   - Manages conversion settings
   - Executes Python script in subprocess
   - Handles file system operations

2. **Finder Sync Extension** (`Video2PPTExtension.appex`)
   - Monitors file selections in Finder
   - Adds context menu for video files
   - Launches main app with selected file

3. **Inter-Process Communication**
   - Uses `DistributedNotificationCenter` for extension→app communication
   - Passes file paths via notification userInfo

### Security & Sandboxing

- Both app and extension are fully sandboxed
- Minimal entitlements requested:
  - File read/write access (user-selected)
  - Network access (for potential updates)
  - Application groups (for shared data)

### Performance Optimizations

- All I/O operations run on background threads
- Progress updates via async dispatch
- Lightweight extension with minimal resource usage
- Smart file type filtering to reduce overhead

## Troubleshooting

### Extension not appearing in right-click menu

1. Ensure the extension is enabled in System Settings
2. Restart Finder: `killall Finder`
3. Check Console.app for any error messages
4. Verify the app is in /Applications/

### Conversion fails

1. Verify Python and video2ppt are installed:
   ```bash
   which video2ppt
   python3 -m video2ppt --help
   ```
2. Check file permissions
3. Ensure sufficient disk space
4. Try running video2ppt directly from terminal

### App doesn't launch

1. Check Gatekeeper settings in Security & Privacy
2. Right-click the app and select "Open" to bypass Gatekeeper once
3. Verify code signing: `codesign -v /Applications/Video2PPT.app`

## Development

### Project Structure

```
Video2PPT/
├── Video2PPT/                    # Main app
│   ├── Video2PPTApp.swift       # App entry point
│   ├── ContentView.swift        # Main UI
│   ├── ConversionManager.swift  # Conversion logic
│   └── Info.plist               # App configuration
├── Video2PPTExtension/           # Finder extension
│   ├── FinderSync.swift         # Extension implementation
│   └── Info.plist               # Extension configuration
└── Video2PPT.xcodeproj/         # Xcode project
```

### Building for Distribution

1. Archive the project in Xcode (Product → Archive)
2. Distribute via Developer ID for notarization
3. Create DMG installer with app and Applications symlink

### Testing

1. Use Xcode's extension debugging:
   - Set Video2PPTExtension as active scheme
   - Run and select Finder as host app
2. Monitor logs in Console.app
3. Test with various video formats and sizes

## Known Issues

- Sandboxing may prevent access to some network locations
- Large video files (>4GB) may require extended processing time
- Some codec formats may not be supported by OpenCV

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow Swift style guidelines
4. Add tests for new functionality
5. Submit a pull request

## License

See main project LICENSE file

## Support

For issues or questions:
- Open an issue on GitHub
- Check existing issues for solutions
- Include system info and error messages