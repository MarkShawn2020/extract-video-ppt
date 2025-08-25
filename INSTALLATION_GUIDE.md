# Video2PPT Installation Guide

## 🚀 Quick Start

Video2PPT now offers multiple installation methods for your convenience:

### Method 1: Automatic Installation (Recommended)
```bash
# Build and install automatically
./build.sh --install

# Or shorter version
./build.sh -i
```
This will:
- Build the app
- Copy to /Applications
- Register the Finder extension
- Guide you to enable the extension in System Settings

### Method 2: DMG Installer (For Distribution)

#### Option A: Simple DMG
```bash
# Create a basic DMG installer
./build_dmg.sh

# Or build and create DMG in one step
./build_dmg.sh --build
```

#### Option B: Professional DMG with Background
```bash
# Create a professional DMG with custom background
./build_dmg_pro.sh

# Build app and create DMG with background
./build_dmg_pro.sh --build --background
```

The professional DMG includes:
- Custom background image with instructions
- Drag-and-drop interface
- Installation guide document
- Optimized compression
- Internet-enabled for auto-mount

### Method 3: Manual Installation
```bash
# Build only
./build.sh

# Then manually copy
cp -r Video2PPT/build/Build/Products/Release/Video2PPT.app /Applications/
```

## 📋 Post-Installation Steps

Regardless of installation method, you must enable the Finder extension:

1. Open **System Settings**
2. Navigate to **Privacy & Security** > **Extensions** > **Finder Extensions**
3. Check **"Video2PPT Extension"**

## 🎯 Usage

After installation and enabling the extension:

### Using Finder Extension
1. Right-click any video file in Finder
2. Select **"Convert to PPT"** from the context menu

### Using the App Directly
1. Open Video2PPT from Applications
2. Select your video file
3. Configure conversion settings
4. Click Convert

## 🔧 Build Options

### build.sh Options
- `--install` or `-i`: Automatically install after building
- `--help` or `-h`: Show help message

### build_dmg.sh Options
- `--build` or `-b`: Build the app before creating DMG
- `--help` or `-h`: Show help message

### build_dmg_pro.sh Options
- `--build` or `-b`: Build the app before creating DMG
- `--background`: Create a new background image
- `--help` or `-h`: Show help message

## 🎨 Customizing the DMG

To customize the DMG background:
1. Edit `create_dmg_background.py` to modify the design
2. Run `python3 create_dmg_background.py` to generate new background
3. Run `./build_dmg_pro.sh` to create DMG with new background

## 📦 Distribution

For distributing Video2PPT to users:

1. **Create Professional DMG**:
   ```bash
   ./build_dmg_pro.sh --build
   ```

2. **Test the DMG**:
   - Double-click to mount
   - Verify drag-and-drop works
   - Check installation guide is readable

3. **Distribute**:
   - Upload `Video2PPT-1.0.0.dmg` to your distribution platform
   - Users can download and install with familiar drag-and-drop interface

## 🐛 Troubleshooting

### Extension Not Appearing
1. Ensure app was launched at least once
2. Check System Settings > Extensions
3. Restart Finder: `killall Finder`

### Build Errors
- Ensure Xcode Command Line Tools are installed:
  ```bash
  xcode-select --install
  ```

### DMG Creation Issues
- For professional DMG, install PIL:
  ```bash
  pip3 install Pillow
  ```
- Or install ImageMagick:
  ```bash
  brew install imagemagick
  ```

## 📊 Comparison of Installation Methods

| Method | Best For | Automation | User-Friendly | Distribution |
|--------|----------|------------|---------------|--------------|
| `build.sh --install` | Developers | ✅ Full | ⭐⭐⭐ | ❌ |
| Simple DMG | Basic distribution | ⭐⭐ | ⭐⭐⭐⭐ | ✅ |
| Professional DMG | Public release | ⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ |
| Manual | Advanced users | ❌ | ⭐⭐ | ❌ |

## 🔐 Security Notes

- The app and extension are sandboxed for security
- First launch may require allowing the app in Security settings
- Finder extension requires explicit user permission
- DMGs can be code-signed for additional trust

## 📝 License

Video2PPT is distributed under the MIT License. See LICENSE file for details.