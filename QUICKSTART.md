# Quick Start Guide - Video2PPT macOS Extension

## Build and Install

### Using Xcode (Recommended)

1. **Open the project in Xcode**:
   ```bash
   open Video2PPT/Video2PPT.xcodeproj
   ```

2. **Fix file references** (if needed):
   - In the Project Navigator, if any files appear red (missing):
   - Right-click the red file → Delete → Remove Reference
   - Right-click the group → Add Files to "Video2PPT"
   - Navigate to the actual file location and add it

3. **Build the project**:
   - Select "Video2PPT" scheme from the toolbar
   - Press ⌘+B to build
   - Or Product → Build

4. **Run the app**:
   - Press ⌘+R to run
   - The app will launch and register the extension

5. **Enable the Finder Extension**:
   - Open System Settings
   - Privacy & Security → Extensions → Finder Extensions
   - Enable "Video2PPT Extension"
   - Restart Finder: `killall Finder`

## Usage

1. Right-click any video file in Finder
2. Select "Convert to PPT" from the context menu
3. Configure conversion settings in the popup window
4. Click "Convert" to start the process

## Troubleshooting

### If the extension doesn't appear:
1. Make sure the app ran at least once
2. Check System Settings → Extensions
3. Restart Finder: `killall Finder`
4. Check Console.app for errors

### If build fails:
1. Clean build folder: ⌘+Shift+K
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Restart Xcode

## Files Overview

- `Video2PPT/` - Main app with SwiftUI interface
- `Video2PPTExtension/` - Finder Sync extension
- `Video2PPT.xcodeproj` - Xcode project file