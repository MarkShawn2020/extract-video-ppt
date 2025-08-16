# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

video2ppt is a Python command-line tool that extracts PowerPoint-like slides from video content by identifying key frames with significant visual differences and converting them to PDF.

## Development Commands

```bash
# Install dependencies locally
python setup.py install --user

# Install in development mode
pip install -e .

# Run the tool - PNG export (default)
video2ppt --format png --similarity 0.6 ./output ./input.mp4
# Or use short alias
v2p --format png --similarity 0.6 ./output ./input.mp4

# Run the tool - PDF export without timestamps
video2ppt --format pdf --pdfname output.pdf --similarity 0.6 ./output ./input.mp4

# Run the tool - PDF export with timestamp overlay
video2ppt --format pdf --add-timestamp --pdfname output.pdf ./output ./input.mp4
```

## Architecture

### Core Modules
- **video2ppt.py**: Main CLI and video processing pipeline. Uses global variables for configuration and implements frame extraction with time-based filtering.
- **compare.py**: Image comparison algorithms including histogram comparison, average hash (aHash), and perceptual hash (pHash). Primary method is `classify_hist_with_split()`.
- **images2pdf.py**: PDF generation using fpdf2, handles landscape orientation and automatic page sizing based on video dimensions.

### Key Patterns
- Pipeline processing: prepare → start → exportPdf → clearEnv
- Module-level globals for configuration management
- Similarity threshold (default 0.6) determines frame uniqueness
- Time range support with HH:MM:SS format parsing

### Dependencies
- opencv-python: Video frame extraction
- numpy: Image processing operations
- fpdf2: PDF generation (uses named parameters in pdf.image calls)
- click: CLI framework
- matplotlib: Visualization support

## Important Implementation Details

- Frame comparison uses `classify_hist_with_split()` which splits images into RGB channels for histogram comparison
- PDF generation creates landscape pages with dimensions based on video aspect ratio
- Time parsing supports formats like "0:00:09" and "00:00:30"
- Frame extraction stores images temporarily in output directory before export
- Cleanup phase removes temporary image files after export
- **Export formats**: PNG (default) saves frames with readable timestamp filenames, PDF creates document
- **Timestamp overlay**: Optional feature (--add-timestamp) adds time overlay on bottom-left of frames
- **PNG export**: Creates 'frames' subdirectory with files named 'timestamp_HH-MM-SS_similarity_X.XX.png'
- **PDF export**: Can include or exclude timestamp titles based on --add-timestamp flag

## Recent Changes
- **Critical Fix**: Fixed cumulative timestamp error by using CAP_PROP_POS_MSEC for accurate timestamps
  - Previously used integer FPS causing up to 15s error in 7-minute videos
  - Now uses float FPS and actual video timestamps
- Fixed timestamp calculation: Use integer division instead of math.ceil
- fpdf2 API updates: Use named parameters when calling pdf.image
- Fixed description errors in setup.py