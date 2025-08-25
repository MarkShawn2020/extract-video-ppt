#!/usr/bin/env python3
"""
Create a professional DMG background image for Video2PPT installer.
"""

import os
import sys

def create_background_image():
    """Create DMG background using PIL if available, otherwise create a simple version."""
    try:
        from PIL import Image, ImageDraw, ImageFont
        create_pil_background()
    except ImportError:
        print("PIL not available, creating simple background with system tools...")
        create_simple_background()

def create_pil_background():
    """Create a professional background image using PIL."""
    from PIL import Image, ImageDraw, ImageFont
    
    # Create a 500x350 image with gradient background
    width, height = 500, 350
    img = Image.new('RGB', (width, height), color='white')
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    for y in range(height):
        # Gradient from light blue to white
        r = 240 + (y * 15 // height)
        g = 245 + (y * 10 // height)
        b = 255
        draw.rectangle([(0, y), (width, y+1)], fill=(r, g, b))
    
    # Draw arrow
    arrow_color = (100, 100, 100)
    arrow_start = (180, 175)
    arrow_end = (320, 175)
    
    # Arrow line
    draw.line([arrow_start, arrow_end], fill=arrow_color, width=3)
    
    # Arrow head
    draw.polygon([
        (arrow_end[0], arrow_end[1]),
        (arrow_end[0] - 15, arrow_end[1] - 10),
        (arrow_end[0] - 15, arrow_end[1] + 10)
    ], fill=arrow_color)
    
    # Add text
    try:
        # Try to use system font
        font_title = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
        font_subtitle = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
        font_instructions = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 12)
    except:
        # Fallback to default font
        font_title = ImageFont.load_default()
        font_subtitle = font_instructions = font_title
    
    # Title
    title_color = (50, 50, 50)
    draw.text((width//2, 40), "Video2PPT", font=font_title, anchor="mm", fill=title_color)
    
    # Subtitle
    subtitle_color = (100, 100, 100)
    draw.text((width//2, 70), "Extract slides from videos", font=font_subtitle, anchor="mm", fill=subtitle_color)
    
    # Instructions
    instruction_color = (80, 80, 80)
    draw.text((width//2, 120), "Drag Video2PPT to Applications folder", font=font_instructions, anchor="mm", fill=instruction_color)
    
    # Footer
    footer_color = (150, 150, 150)
    draw.text((width//2, height - 30), "After installation, enable Finder extension in System Settings", font=font_instructions, anchor="mm", fill=footer_color)
    
    # Save image
    img.save('dmg_background.png')
    print("✅ Created dmg_background.png with PIL")

def create_simple_background():
    """Create a simple background using macOS built-in tools."""
    # Create a simple background using sips and ImageMagick if available
    script = '''
    # Create a simple colored background
    WIDTH=500
    HEIGHT=350
    
    # Check if ImageMagick is installed
    if command -v convert &> /dev/null; then
        # Use ImageMagick to create a gradient background
        convert -size ${WIDTH}x${HEIGHT} \
            gradient:'#f0f5ff'-'#ffffff' \
            -fill '#333333' -pointsize 28 -gravity North -annotate +0+40 'Video2PPT' \
            -fill '#666666' -pointsize 16 -gravity North -annotate +0+75 'Extract slides from videos' \
            -fill '#444444' -pointsize 14 -gravity Center -annotate +0-20 'Drag Video2PPT to Applications folder →' \
            -fill '#888888' -pointsize 11 -gravity South -annotate +0+30 'After installation, enable Finder extension in System Settings' \
            dmg_background.png
        echo "✅ Created dmg_background.png with ImageMagick"
    else
        # Create a solid color background using sips
        # First create a white image
        echo "P3 $WIDTH $HEIGHT 255" > temp.ppm
        for ((i=0; i<$((WIDTH*HEIGHT)); i++)); do
            echo "240 245 255" >> temp.ppm
        done
        
        # Convert to PNG
        sips -s format png temp.ppm --out dmg_background.png &>/dev/null
        rm temp.ppm
        
        echo "✅ Created simple dmg_background.png"
        echo "💡 Tip: Install ImageMagick for a better background (brew install imagemagick)"
    fi
    '''
    
    os.system(script)

if __name__ == "__main__":
    create_background_image()
    
    if os.path.exists('dmg_background.png'):
        print(f"Background image created: {os.path.abspath('dmg_background.png')}")
        print(f"Size: {os.path.getsize('dmg_background.png')} bytes")
    else:
        print("Warning: Could not create background image")