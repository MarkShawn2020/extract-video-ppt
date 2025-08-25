# Debugging Guide - Video2PPT File Loading Issue

## 问题诊断步骤

### 1. 打开 Console.app 监控日志
```bash
open /System/Applications/Utilities/Console.app
```
在搜索框输入 `Video2PPT` 过滤日志

### 2. 在 Xcode 中运行应用
```bash
open Video2PPT/Video2PPT.xcodeproj
```
按 ⌘+R 运行

### 3. 测试右键菜单
1. 在 Finder 中找到任意 .mp4 文件
2. 右键点击
3. 选择 "Convert to PPT"

### 4. 检查日志输出

应该看到以下日志序列：

**扩展端日志：**
- `Video2PPT Extension: convertToPPT called`
- `Video2PPT Extension: Selected items count: 1`
- `Video2PPT Extension: Converting file: /path/to/video.mp4`
- `Video2PPT Extension: File exists: true`
- `Video2PPT Extension: launchMainApp called with: /path/to/video.mp4`
- `Video2PPT Extension: Opening URL scheme: video2ppt://convert?file=/path/to/video.mp4`
- `Video2PPT Extension: Successfully opened URL scheme`

**主应用端日志：**
- `Video2PPT: AppDelegate init with arguments: ["/path/to/app"]`
- `Video2PPT: Application did finish launching, file path: none`
- `Video2PPT: Received URL scheme with 1 URLs`
- `Video2PPT: Processing URL: video2ppt://convert?file=/path/to/video.mp4`
- `Video2PPT: Extracted file path from URL scheme: /path/to/video.mp4`
- `ContentView: Received file path from notification: /path/to/video.mp4`
- `ContentView: Setting initial file from onAppear: /path/to/video.mp4`

## 可能的问题及解决方案

### 问题1: 扩展未被启用
**症状**: 右键菜单没有 "Convert to PPT" 选项
**解决**:
1. 系统设置 → 隐私与安全 → 扩展 → Finder扩展
2. 勾选 "Video2PPT Extension"
3. 重启 Finder: `killall Finder`

### 问题2: Bundle ID 不匹配
**症状**: 日志显示 "Could not find main app with bundle ID"
**解决**:
检查 Info.plist 中的 Bundle ID 是否为 `com.video2ppt.Video2PPT`

### 问题3: 沙盒限制阻止参数传递
**症状**: 日志显示 arguments 只有应用路径，没有 "--file"
**解决**:
macOS 沙盒限制阻止了 NSWorkspace.OpenConfiguration.arguments 的使用。现已改用 URL scheme (video2ppt://) 方式传递文件路径。

### 问题4: 分布式通知被沙盒阻止
**症状**: 日志显示 "attempt to post distributed notification 'com.video2ppt.convert' thwarted by sandboxing"
**解决**:
使用 URL scheme 替代分布式通知进行进程间通信。

## 手动测试命令

### 测试 URL Scheme：
```bash
# 测试 URL scheme 是否正常工作
open "video2ppt://convert?file=/path/to/test.mp4"
```

### 测试应用是否能接收参数（注意：由于沙盒限制，这可能不工作）：
```bash
/Users/mark/Library/Developer/Xcode/DerivedData/Video2PPT-*/Build/Products/Debug/Video2PPT.app/Contents/MacOS/Video2PPT --file /path/to/test.mp4
```

### 查看应用的 Bundle ID：
```bash
defaults read /Users/mark/Library/Developer/Xcode/DerivedData/Video2PPT-*/Build/Products/Debug/Video2PPT.app/Contents/Info.plist CFBundleIdentifier
```

### 查看扩展是否已注册：
```bash
pluginkit -m | grep -i video2ppt
```

## 核心修复内容总结

1. **URL Scheme** - 使用 URL scheme (video2ppt://) 替代命令行参数，解决沙盒限制
2. **@Published 属性** - 使 initialFilePath 可观察
3. **URL 解析** - 在 AppDelegate 中处理 URL scheme 回调
4. **详细日志** - 每个关键步骤都有日志输出
5. **Info.plist 配置** - 添加 CFBundleURLTypes 注册 URL scheme

## 如果仍然不工作

1. 完全清理并重建：
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
cd /Users/mark/projects/video2ppt/.feats/support-mac-extension/Video2PPT
xcodebuild clean build
```

2. 重新安装扩展：
```bash
# 复制到 Applications
cp -r ~/Library/Developer/Xcode/DerivedData/Video2PPT-*/Build/Products/Debug/Video2PPT.app /Applications/

# 运行一次以注册
open /Applications/Video2PPT.app

# 启用扩展
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Extensions"
```

3. 重启 Mac（某些扩展需要重启才能正常工作）