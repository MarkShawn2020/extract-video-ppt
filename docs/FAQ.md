# Frequently Asked Questions (FAQ)

## General Questions

### Q: What is Video2PPT?
**A:** Video2PPT is a macOS application that extracts key frames from video files and converts them into presentation slides (PNG images or PDF documents). It's perfect for creating presentations from recorded lectures, tutorials, or any video content with slides.

### Q: What video formats are supported?
**A:** Video2PPT supports most common video formats including:
- MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV, MPG, MPEG

### Q: What output formats are available?
**A:** You can export to:
- **PNG**: Individual images with timestamps in filenames
- **PDF**: Single document with all slides (with or without timestamp overlays)

## Installation Issues

### Q: Why does macOS say the app is from an unidentified developer?
**A:** Video2PPT is currently not signed with an Apple Developer certificate. This is normal for open-source projects. To open it:
1. Right-click the app
2. Select "Open"
3. Click "Open" in the security dialog

### Q: Why doesn't "Convert to PPT" appear in the right-click menu?
**A:** The Finder Extension needs to be manually enabled due to macOS security restrictions:
1. Open Video2PPT app
2. Click the extension status indicator at the top
3. Enable the extension in System Settings
4. Restart Finder if needed

### Q: The extension is enabled but still not working. What should I do?
**A:** This is a known issue with unsigned apps. Try these solutions:
1. **Use the main app instead**: Drag and drop videos into the Video2PPT window
2. **Restart Finder**: Option+Right-click Finder → Relaunch
3. **Restart your Mac**: Sometimes a full restart helps
4. **Build from source**: If you have Xcode, building locally with your own certificate works best

## Usage Questions

### Q: How do I use Video2PPT?
**A:** There are two ways:
1. **Main App**: Open Video2PPT and drag a video file into the window
2. **Right-Click Menu**: Right-click a video file and select "Convert to PPT" (requires extension enabled)

### Q: What does the similarity threshold do?
**A:** The similarity threshold (0.0-1.0) determines how different consecutive frames must be to be considered unique slides:
- **Lower values (0.3-0.5)**: More slides extracted, catches subtle changes
- **Default (0.6)**: Balanced extraction
- **Higher values (0.7-0.9)**: Fewer slides, only major changes

### Q: Can I convert only a portion of a video?
**A:** Yes! Use the time range feature:
- Set start and end times in HH:MM:SS format
- Leave empty to process the entire video

### Q: Where are the converted files saved?
**A:** 
- **PNG Export**: Creates a `frames` subfolder in your chosen output directory
- **PDF Export**: Saves to your chosen output directory with the name you specify

## Technical Questions

### Q: Why is the app not code-signed?
**A:** Code signing requires an Apple Developer account ($99/year). As an open-source project, we currently distribute unsigned builds. This may change in future releases.

### Q: Can I build the app myself?
**A:** Yes! If you have Xcode installed:
```bash
git clone https://github.com/MarkShawn2020/video2ppt.git
cd video2ppt
xcodebuild -project video2ppt/Video2PPT.xcodeproj -scheme Video2PPT build
```

### Q: Is my data safe?
**A:** Yes! Video2PPT:
- Processes everything locally on your Mac
- Doesn't send any data to external servers
- Is open-source so you can verify the code
- Only accesses files you explicitly select

### Q: What are the system requirements?
**A:** 
- macOS 11.0 (Big Sur) or later
- Apple Silicon (M1/M2/M3) or Intel processor
- ~50MB disk space for the app
- Python 3.9+ (only for command-line usage)

## Troubleshooting

### Q: The app crashes on launch. What should I do?
**A:** 
1. Check you're running macOS 11.0 or later
2. Try removing quarantine: `xattr -d com.apple.quarantine /Applications/Video2PPT.app`
3. Check Console.app for error messages
4. Report the issue on GitHub with crash details

### Q: Conversion is very slow. How can I speed it up?
**A:** 
- Increase the similarity threshold to extract fewer frames
- Use a smaller time range if you don't need the entire video
- Close other applications to free up memory
- For long videos, the PNG format is faster than PDF

### Q: The PDF is too large. How can I reduce the size?
**A:** 
- Increase the similarity threshold to include fewer slides
- Use PNG export instead and create PDF with Preview.app
- Future versions may include compression options

## Feature Requests

### Q: Will you add Windows/Linux support?
**A:** The command-line Python version works on all platforms. The GUI app is macOS-only due to using native Apple frameworks.

### Q: Can you add OCR to extract text from slides?
**A:** This is on the roadmap for future versions. For now, you can use macOS's built-in OCR on the exported images.

### Q: Will there be a batch processing feature?
**A:** Batch processing is planned for a future release. Currently, you can use the Python command-line version for batch operations.

## Contributing

### Q: How can I contribute to the project?
**A:** We welcome contributions! You can:
- Report bugs and request features on [GitHub Issues](https://github.com/MarkShawn2020/video2ppt/issues)
- Submit pull requests with improvements
- Help with documentation and translations
- Share the project with others who might find it useful

### Q: I found a bug. Where do I report it?
**A:** Please create an issue on [GitHub](https://github.com/MarkShawn2020/video2ppt/issues) with:
- Your macOS version
- Steps to reproduce the bug
- Any error messages
- Screenshots if applicable

## Legal

### Q: What license is Video2PPT under?
**A:** Video2PPT is released under the MIT License, making it free for personal and commercial use.

### Q: Can I use this for commercial purposes?
**A:** Yes! The MIT License allows commercial use. However, ensure you have the rights to the video content you're converting.

---

*Don't see your question? [Create an issue](https://github.com/MarkShawn2020/video2ppt/issues/new) and we'll add it to the FAQ!*