# extract-video-ppt

> Intelligently extract presentation slides from videos and convert them to PDF or PNG format.

[![PyPI version](https://img.shields.io/pypi/v/extract-video-ppt.svg)](https://pypi.org/project/extract-video-ppt/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.x](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/downloads/)

## Features

- 🎯 **Smart Frame Detection** - Uses advanced image similarity algorithms to avoid duplicate slides
- 📄 **Multiple Export Formats** - Export as individual PNG images or combined PDF document
- ⏱️ **Time Range Selection** - Extract slides from specific time segments
- 🏷️ **Timestamp Support** - Optional timestamp overlays on extracted frames
- 🚀 **High Performance** - Efficient frame processing with progress tracking
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

### Basic Command Structure

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

#### Extract frames from specific time range
```bash
evp --start_frame 00:10:00 --end_frame 00:30:00 --format pdf meeting.mp4
```

#### Export as PNG with timestamps
```bash
evp --format png --add-timestamp presentation.mp4
```

#### Custom output location
```bash
evp -o ~/Documents/slides --format pdf video.mp4
```

## How It Works

1. **Frame Extraction**: Processes video at 1 FPS to identify potential slides
2. **Similarity Analysis**: Compares consecutive frames using histogram-based algorithms
3. **Duplicate Removal**: Keeps only frames that differ significantly (based on similarity threshold)
4. **Export**: Saves unique frames as PNG images or combines them into a PDF

### Similarity Threshold

The `--similarity` parameter (0.0-1.0) controls frame detection sensitivity:
- **Lower values (0.3-0.5)**: More sensitive, captures more frames
- **Default (0.6)**: Balanced detection
- **Higher values (0.7-0.9)**: Less sensitive, only major changes

## Output Structure

### PNG Format
```
video_name_frames/
├── timestamp_00-00-01_similarity_0.png
├── timestamp_00-00-05_similarity_0.76.png
└── timestamp_00-00-10_similarity_0.54.png
```

### PDF Format
- Single PDF file with all extracted frames
- Optional timestamp headers on each page
- Landscape orientation optimized for presentations

## Use Cases

- 📚 **Education**: Extract slides from recorded lectures
- 💼 **Business**: Create PDF summaries from video presentations
- 🔬 **Research**: Analyze presentation content from conferences
- 📝 **Documentation**: Convert video tutorials to reference materials
- 🗂️ **Archival**: Transform video presentations into searchable documents

## Requirements

- Python 3.x
- OpenCV
- NumPy
- fpdf2
- Click
- tqdm
- matplotlib

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**wudu** - [296525335@qq.com](mailto:296525335@qq.com)

## Acknowledgments

- OpenCV for video processing capabilities
- fpdf2 for PDF generation
- Click for the elegant CLI interface