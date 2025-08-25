#!/bin/bash

set -e

echo "=== Video2PPT 完整重建和修复脚本 ==="
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/video2ppt"
BUILD_DIR="$PROJECT_DIR/build"

# 1. 清理旧版本
echo "1. 清理旧版本..."
echo "   - 关闭应用..."
killall Video2PPT 2>/dev/null || true
echo "   - 移除旧应用..."
rm -rf /Applications/Video2PPT.app
echo "   - 清理构建目录..."
rm -rf "$BUILD_DIR"

# 2. 重新构建
echo ""
echo "2. 重新构建应用..."
cd "$PROJECT_DIR"

# 使用开发者签名（允许本地运行）
xcodebuild -project "Video2PPT.xcodeproj" \
    -scheme Video2PPT \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=YES \
    ENABLE_HARDENED_RUNTIME=NO \
    clean build

APP_PATH="$BUILD_DIR/Build/Products/Release/Video2PPT.app"

if [ ! -d "$APP_PATH" ]; then
    echo "错误：构建失败"
    exit 1
fi

# 3. 安装应用
echo ""
echo "3. 安装应用到 /Applications..."
cp -r "$APP_PATH" /Applications/

# 4. 移除隔离属性（避免Gatekeeper问题）
echo ""
echo "4. 移除隔离属性..."
xattr -cr /Applications/Video2PPT.app

# 5. 注册扩展
echo ""
echo "5. 启动应用以注册扩展..."
open /Applications/Video2PPT.app
sleep 3

# 6. 尝试启用扩展
echo ""
echo "6. 尝试启用扩展..."
pluginkit -e use -i com.video2ppt.Video2PPT.FinderExtension 2>/dev/null || true

# 7. 重启Finder
echo ""
echo "7. 重启Finder..."
killall Finder

echo ""
echo "=== 构建完成！==="
echo ""
echo "现在请执行以下操作："
echo ""
echo "1. 系统设置会自动打开"
echo "2. 进入 隐私与安全性 > 扩展 > Finder扩展"
echo "3. 勾选 'Video2PPT Extension'"
echo "4. 如果没有看到扩展，请重启Mac后再试"
echo ""
echo "完成后，右键点击视频文件应该会看到 'Convert to PPT' 选项"
echo ""

# 打开系统设置
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Extensions"