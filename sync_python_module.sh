#!/bin/bash

# Script to ensure Python module structure is correctly synchronized

echo "Synchronizing Python module structure..."

# Ensure the Python module files are in the correct location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR="$SCRIPT_DIR/video2ppt"
RESOURCES_DIR="$MODULE_DIR/Video2PPT/Resources"

# Copy Python files from Resources if they don't exist in module directory
if [ ! -f "$MODULE_DIR/video2ppt.py" ] && [ -f "$RESOURCES_DIR/video2ppt.py" ]; then
    echo "Copying video2ppt.py to module directory..."
    cp "$RESOURCES_DIR/video2ppt.py" "$MODULE_DIR/"
fi

if [ ! -f "$MODULE_DIR/compare.py" ] && [ -f "$RESOURCES_DIR/compare.py" ]; then
    echo "Copying compare.py to module directory..."
    cp "$RESOURCES_DIR/compare.py" "$MODULE_DIR/"
fi

if [ ! -f "$MODULE_DIR/images2pdf.py" ] && [ -f "$RESOURCES_DIR/images2pdf.py" ]; then
    echo "Copying images2pdf.py to module directory..."
    cp "$RESOURCES_DIR/images2pdf.py" "$MODULE_DIR/"
fi

# Ensure __init__.py exists
if [ ! -f "$MODULE_DIR/__init__.py" ]; then
    echo "Creating __init__.py..."
    cat > "$MODULE_DIR/__init__.py" << 'EOF'
"""Video2PPT - Extract PowerPoint-like slides from video content."""

__version__ = "1.0.0"

from .video2ppt import main

__all__ = ['main']
EOF
fi

echo "Python module structure synchronized successfully!"
echo ""
echo "You can now use:"
echo "  - python -m video2ppt"
echo "  - video2ppt"
echo "  - v2p"