# Video2PPT for macOS

Native macOS Finder integration for extracting presentation slides from videos.

## ✨ Features

### 🖱️ Right-Click Context Menu
Convert videos directly from Finder with a simple right-click → "Convert to PPT"

### 🎯 Smart Frame Extraction
- Automatically detects key frames using histogram-based similarity comparison
- Adjustable similarity threshold (0.0-1.0)
- Accurate timestamp preservation using video metadata

### 📁 Multiple Export Formats
- **PNG**: Individual frames with timestamp filenames
- **PDF**: Combined document with all frames

### 🚀 Native macOS App
- SwiftUI interface with real-time progress
- Finder Sync Extension for seamless integration
- Automatic output folder opening after conversion

## 📦 Installation

### From Release (Recommended)
1. Download the latest `Video2PPT.app` from [Releases](https://github.com/markshawn2020/video2ppt/releases)
2. Move to `/Applications`
3. Open the app once to register the extension
4. Enable in System Settings → Privacy & Security → Extensions → Finder Extensions

### From Source
```bash
git clone https://github.com/markshawn2020/video2ppt.git
cd video2ppt/.feats/support-mac-extension/Video2PPT
open Video2PPT.xcodeproj
# Build and run in Xcode (⌘+R)
```

## 🎬 Usage

### Via Finder (Recommended)
1. Right-click any video file (`.mp4`, `.mov`, `.avi`, etc.)
2. Select **"Convert to PPT"**
3. Adjust settings if needed
4. Click **Convert**
5. Output folder opens automatically

### Via Command Line
```bash
# Install Python package
pip install -e /path/to/video2ppt

# Extract frames
video2ppt --format png --similarity 0.6 video.mp4
```

## ⚙️ Settings

| Option | Description | Default |
|--------|-------------|---------|
| **Format** | PNG (frames) or PDF (document) | PNG |
| **Similarity** | Frame difference threshold (0.0-1.0) | 0.6 |
| **PDF Name** | Output filename (PDF only) | output.pdf |
| **Add Timestamp** | Overlay timestamp on frames | Off |

## 🛠️ Technical Details

### Architecture
- **Main App**: SwiftUI + Python backend via Process
- **Finder Extension**: Finder Sync framework
- **IPC**: URL scheme (`video2ppt://`) for file passing
- **Python Core**: OpenCV + histogram comparison

### Output Structure
```
video_directory/
├── video2ppt_output/
│   ├── videoname_frames/
│   │   ├── timestamp_00-00-00_similarity_0.png
│   │   ├── timestamp_00-00-15_similarity_0.65.png
│   │   └── ...
│   └── conversion_log.txt
```

### Requirements
- macOS 11.0+
- Python 3.x with:
  - opencv-python
  - numpy
  - fpdf2
  - click

## 🐛 Troubleshooting

### Extension Not Appearing
1. Enable in System Settings → Extensions
2. Restart Finder: `killall Finder`
3. Reinstall app to `/Applications`

### No Output Files
1. Check Console.app for "Video2PPT" logs
2. Verify Python dependencies: `pip install opencv-python numpy fpdf2 click`
3. Check `video2ppt_output/conversion_log.txt`

### File Not Loading
- Ensure video file has read permissions
- Try with a different video format
- Check if file path contains special characters

## 📝 Development

### Building
```bash
cd Video2PPT
xcodebuild -quiet build
cp -rf build/Release/Video2PPT.app /Applications/
```

### Testing
```bash
# Test Python module
python3 -m video2ppt --help

# Test URL scheme
open "video2ppt://convert?file=/path/to/video.mp4"
```

### Debug Logs
```bash
# View logs in Console.app
log show --predicate 'process == "Video2PPT"' --last 5m
```

## 🏗️ Project Structure
```
Video2PPT/
├── Video2PPT/              # Main application
│   ├── Video2PPTApp.swift  # App entry & URL handling
│   ├── ContentView.swift   # UI interface
│   └── ConversionManager.swift # Python process management
├── Video2PPTExtension/     # Finder extension
│   └── FinderSync.swift    # Right-click menu integration
└── video2ppt/              # Python module
    ├── video2ppt.py        # Core extraction logic
    ├── compare.py          # Frame comparison
    └── images2pdf.py       # PDF generation
```

## 📜 License

MIT License - See [LICENSE](LICENSE) file

## 🙏 Credits

- Original Python implementation: [wudududu/extract-video-ppt](https://github.com/wudududu/extract-video-ppt)
- macOS integration: [@markshawn2020](https://github.com/markshawn2020)

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

---

<p align="center">
Made with ❤️ for macOS users who need to extract slides from video lectures and presentations
</p>