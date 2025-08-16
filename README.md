# extract-video-ppt

> Intelligently extract presentation slides from videos and convert them to PDF or PNG format.

[![PyPI version](https://img.shields.io/pypi/v/extract-video-ppt.svg)](https://pypi.org/project/extract-video-ppt/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.x](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/downloads/)

## ✨ What's New

- **v1.1.3** - Critical timestamp accuracy fix for long videos
  - Fixed cumulative timestamp errors (up to 15s drift in 7-minute videos)
  - Now uses precise video timestamps instead of frame counting
  - Improved progress display with cleaner, non-verbose output

## Features

- 🎯 **Smart Frame Detection** - Advanced histogram-based similarity algorithms to identify unique slides
- 📄 **Multiple Export Formats** - Export as individual PNG images or combined PDF document
- ⏱️ **Precise Time Range Selection** - Extract slides from specific time segments with accurate timestamps
- 🏷️ **Optional Timestamp Overlays** - Add time markers to extracted frames
- 🚀 **Optimized Performance** - Efficient processing with clean progress tracking
- 🔧 **Flexible Configuration** - Customizable similarity threshold and output options

## Installation

```bash
# Install from PyPI
pip install extract-video-ppt

# Or install from source
git clone https://github.com/wudududu/extract-video-ppt.git
cd extract-video-ppt
pip install -e .
```

## Quick Start

```bash
# Extract slides from a video (default: PNG format)
evp video.mp4

# Extract as PDF
evp --format pdf presentation.mp4

# Extract specific time range
evp --start_frame 00:05:00 --end_frame 00:15:00 lecture.mp4
```

## Usage

### Basic Command

```bash
evp [OPTIONS] VIDEO_PATH
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format [png\|pdf]` | Output format | `png` |
| `--similarity FLOAT` | Frame similarity threshold (0.0-1.0) | `0.6` |
| `-o, --output PATH` | Output directory or file path | Video's directory |
| `--pdfname TEXT` | PDF filename (when format=pdf) | `video_name.pdf` |
| `--start_frame TIME` | Start time (HH:MM:SS) | `00:00:00` |
| `--end_frame TIME` | End time (HH:MM:SS) | `INFINITY` |
| `--add-timestamp` | Add timestamp overlay on frames | `False` |
| `-q, --quiet` | Minimal output mode | `False` |

### Examples

#### Extract slides from a lecture video
```bash
evp --format pdf --similarity 0.7 lecture.mp4
```
Output: `lecture.pdf` with unique slides

#### Extract specific time range
```bash
evp --start_frame 00:10:00 --end_frame 00:30:00 meeting.mp4
```
Output: PNG frames from the 10-30 minute range

#### Export with timestamp overlays
```bash
evp --format png --add-timestamp presentation.mp4
```
Output: PNG images with time markers

#### Custom output location
```bash
evp -o ~/Documents/slides --format pdf video.mp4
```
Output: PDF saved to specified directory

## How It Works

1. **Frame Sampling**: Processes video at 1 FPS to identify potential slide changes
2. **Similarity Analysis**: Uses histogram-based comparison (`classify_hist_with_split`) to detect unique frames
3. **Duplicate Filtering**: Keeps only frames that differ significantly from previous ones
4. **Accurate Timestamps**: Uses video's actual timestamps (CAP_PROP_POS_MSEC) for precise time marking
5. **Export**: Saves as individual PNGs or combines into a PDF document

### Similarity Threshold

The `--similarity` parameter (0.0-1.0) controls detection sensitivity:
- **0.3-0.5**: High sensitivity, captures subtle changes
- **0.6** (default): Balanced detection for most presentations
- **0.7-0.9**: Low sensitivity, only major slide transitions

## Output Examples

### PNG Format
```
video_name_frames/
├── timestamp_00-00-01_similarity_0.png
├── timestamp_00-05-23_similarity_0.76.png
└── timestamp_00-10-45_similarity_0.54.png
```

### PDF Format
- Single PDF with all extracted slides
- Optional timestamp headers on each page
- Landscape orientation optimized for presentations
- Automatic file size optimization

## Performance

- **Processing Speed**: ~60-120 fps on modern hardware
- **Memory Efficient**: Processes frames sequentially
- **Accurate Timestamps**: No drift even in hours-long videos
- **Clean Output**: Non-verbose progress display

## Use Cases

- 📚 **Education**: Extract slides from recorded lectures and online courses
- 💼 **Business**: Create PDF summaries from video presentations and webinars
- 🔬 **Research**: Analyze presentation content from conferences and seminars
- 📝 **Documentation**: Convert video tutorials to reference materials
- 🗂️ **Archival**: Transform video presentations into searchable documents

## Requirements

- Python 3.x
- OpenCV (`opencv-python`)
- NumPy
- fpdf2
- Click
- tqdm
- matplotlib

## Troubleshooting

### Common Issues

**Q: Timestamps are incorrect in long videos**  
A: Update to v1.1.3+ which fixes cumulative timestamp errors

**Q: Too many/few frames extracted**  
A: Adjust `--similarity` parameter. Lower values capture more frames

**Q: Output directory not created**  
A: The tool automatically creates output directories as needed

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**wudu** - [296525335@qq.com](mailto:296525335@qq.com)

## Acknowledgments

- OpenCV for robust video processing
- fpdf2 for PDF generation capabilities
- Click for the elegant CLI interface
- tqdm for progress visualization