# extract-video-ppt

Extract presentation slides from videos with accurate timestamps.

> Fork of [wudududu/extract-video-ppt](https://github.com/wudududu/extract-video-ppt) with critical accuracy fixes and enhanced features.

## Key Improvements in This Fork

- **Fixed timestamp accuracy**: Resolved cumulative drift issue (up to 15s in 7-minute videos) by using actual video timestamps
- **PNG export support**: Default output format with readable timestamp filenames
- **Simplified CLI**: Single required argument, intelligent defaults
- **Clean progress display**: Non-verbose output with tqdm integration
- **Better error handling**: Improved FPS handling for non-standard frame rates

## Installation

```bash
# Clone and install locally
git clone https://github.com/markshawn2020/extract-video-ppt.git
cd extract-video-ppt
pip install -e .
```

## Usage

```bash
# Basic usage (exports PNG by default)
evp video.mp4

# Export as PDF
evp --format pdf video.mp4

# Extract time range
evp --start_frame 00:05:00 --end_frame 00:10:00 video.mp4

# Adjust similarity threshold
evp --similarity 0.8 video.mp4
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format` | `png` or `pdf` | `png` |
| `--similarity` | Threshold (0.0-1.0) | `0.6` |
| `--start_frame` | Start time (HH:MM:SS) | `00:00:00` |
| `--end_frame` | End time (HH:MM:SS) | `INFINITY` |
| `-o, --output` | Output path | Video directory |
| `--add-timestamp` | Overlay timestamp | `False` |
| `-q, --quiet` | Minimal output | `False` |

## Output

**PNG**: `video_name_frames/timestamp_HH-MM-SS_similarity_X.XX.png`  
**PDF**: Single document with all frames

## Technical Details

- **Frame Detection**: Histogram-based similarity comparison
- **Timestamp Accuracy**: Uses `CAP_PROP_POS_MSEC` for precise timestamps
- **FPS Handling**: Maintains float precision to prevent drift
- **Processing**: Samples at 1 FPS, compares consecutive frames

## Requirements

- Python 3.x
- opencv-python
- fpdf2
- numpy
- click
- tqdm

## Credits

Original implementation by [wudu](https://github.com/wudududu/extract-video-ppt). This fork focuses on accuracy and usability improvements.

## License

MIT