# Video2PPT Installation & Setup Guide

## 📥 Installation Steps

### 1. Download the Application
- Download the latest `Video2PPT-vX.X.X.dmg` from [Releases](https://github.com/MarkShawn2020/video2ppt/releases)
- Double-click the DMG file to mount it

### 2. Install the Application
- Drag `Video2PPT.app` to your Applications folder
- Eject the DMG by right-clicking and selecting "Eject"

### 3. First Launch (Important!)
Since Video2PPT is not signed with an Apple Developer certificate, you need to:

1. **Right-click** on Video2PPT.app in Applications folder
2. Select **"Open"** from the context menu
3. Click **"Open"** in the security dialog that appears
4. The app will launch and show the main interface

## 🔧 Enable Right-Click Context Menu

**⚠️ IMPORTANT**: The right-click "Convert to PPT" feature requires enabling the Finder Extension.

### Automatic Setup (Recommended)
1. When you first launch Video2PPT, it will prompt you to enable the extension
2. Click **"Open System Settings"** in the prompt
3. The Extensions settings will open automatically
4. Find **"Video2PPT Extension"** and check the box to enable it
5. You may need to enter your password

### Manual Setup
If you dismissed the prompt or need to enable it later:

#### Method 1: From the App
1. Open Video2PPT
2. Look for the extension status indicator at the top of the window
3. If it shows "Extension Disabled", click on it
4. System Settings will open to the Extensions page
5. Enable "Video2PPT Extension"

#### Method 2: From System Settings
1. Open **System Settings** (or System Preferences on older macOS)
2. Go to **Privacy & Security**
3. Scroll down and click on **Extensions**
4. Select **Finder Extensions** from the sidebar
5. Find **Video2PPT Extension** and check the box

### Verify Extension is Working
1. Right-click on any video file (MP4, MOV, AVI, etc.)
2. You should see **"Convert to PPT"** in the context menu
3. If not, try:
   - Restarting Finder: Hold Option, right-click Finder in Dock, select "Relaunch"
   - Logging out and back in
   - Restarting your Mac

## 🚨 Troubleshooting

### "Convert to PPT" Not Appearing in Right-Click Menu

#### Issue: Extension Not Enabled
**Solution:**
1. Open Video2PPT app
2. Check the extension status indicator at the top
3. If disabled, click it to open settings
4. Enable the extension in System Settings

#### Issue: Security Block
**Solution:**
1. Open System Settings > Privacy & Security
2. Look for a message about Video2PPT being blocked
3. Click "Open Anyway"
4. Try enabling the extension again

#### Issue: App Not Properly Signed
**Current Status:** The app is distributed without an Apple Developer certificate, which may prevent the extension from loading on some systems.

**Workarounds:**
1. Use the main app interface to convert videos (drag & drop)
2. Build from source with your own signing certificate
3. Wait for a future signed release

### App Won't Open

#### Issue: Gatekeeper Blocking
**Solution:**
1. Right-click the app and select "Open"
2. Click "Open" in the security dialog
3. Or go to System Settings > Privacy & Security and click "Open Anyway"

#### Issue: Quarantine Attribute
**Solution (Terminal):**
```bash
xattr -d com.apple.quarantine /Applications/Video2PPT.app
```

### Extension Shows as Enabled but Still Not Working

**Try these steps in order:**
1. **Restart Finder:**
   - Hold Option key
   - Right-click Finder in Dock
   - Select "Relaunch"

2. **Reset Extension:**
   ```bash
   pluginkit -e ignore -i com.video2ppt.Video2PPT.FinderExtension
   pluginkit -e use -i com.video2ppt.Video2PPT.FinderExtension
   ```

3. **Check Console Logs:**
   - Open Console.app
   - Search for "Video2PPT"
   - Look for error messages

4. **Full System Restart:**
   - Save all work
   - Restart your Mac
   - Try again

## 📋 System Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Architecture**: Apple Silicon (M1/M2) or Intel
- **Python**: 3.9+ (for command-line usage)
- **Disk Space**: ~50MB for app + space for converted files

## 🔍 Diagnostic Information

To help troubleshoot issues, Video2PPT includes diagnostic features:

1. **In-App Diagnostics:**
   - Open Video2PPT
   - Click on the extension status indicator
   - View diagnostic information

2. **Terminal Commands:**
   ```bash
   # Check if extension is registered
   pluginkit -m | grep -i video2ppt
   
   # Check app signature
   codesign -dv /Applications/Video2PPT.app
   
   # Check extension signature  
   codesign -dv /Applications/Video2PPT.app/Contents/PlugIns/Video2PPTExtension.appex
   ```

## 📝 Known Limitations

1. **Unsigned App**: The current release is not signed with an Apple Developer certificate, which may cause:
   - Security warnings on first launch
   - Extension may not load on some systems
   - Need to bypass Gatekeeper

2. **Extension Activation**: Requires manual enablement in System Settings

3. **Compatibility**: Some features may not work on older macOS versions

## 🆘 Getting Help

If you're still having issues:

1. Check the [FAQ](FAQ.md)
2. Search [existing issues](https://github.com/MarkShawn2020/video2ppt/issues)
3. Create a [new issue](https://github.com/MarkShawn2020/video2ppt/issues/new) with:
   - Your macOS version
   - Steps you've tried
   - Any error messages
   - Output from diagnostic commands

## 🔐 Security Note

Video2PPT is open-source software. While we strive for security:
- The app is currently unsigned (no Apple Developer certificate)
- You're trusting the build process and GitHub Actions
- For maximum security, build from source yourself
- Future releases may include proper code signing

---

*Last updated: 2025-08-25*