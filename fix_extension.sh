#!/bin/bash

set -e

echo "=== Video2PPT Finder Extension 修复脚本 ==="
echo ""

# 1. 检查扩展状态
echo "1. 检查扩展注册状态..."
if pluginkit -m | grep -q "com.video2ppt.Video2PPT.FinderExtension"; then
    echo "   ✓ 扩展已注册"
else
    echo "   ✗ 扩展未注册，需要重新安装"
    exit 1
fi

# 2. 启动应用一次以确保扩展注册
echo ""
echo "2. 启动Video2PPT应用以注册扩展..."
open /Applications/Video2PPT.app
sleep 2

# 3. 尝试启用扩展
echo ""
echo "3. 尝试启用扩展..."
pluginkit -e use -i com.video2ppt.Video2PPT.FinderExtension || true

# 4. 重启Finder
echo ""
echo "4. 重启Finder..."
killall Finder

echo ""
echo "=== 接下来需要手动操作 ==="
echo ""
echo "5. 打开系统设置启用扩展："
echo "   a) 打开 系统设置(System Settings)"
echo "   b) 进入 隐私与安全性(Privacy & Security)"
echo "   c) 点击 扩展(Extensions)"
echo "   d) 选择 Finder扩展(Finder Extensions)"
echo "   e) 勾选 'Video2PPT Extension'"
echo ""
echo "6. 如果扩展仍未出现在系统设置中："
echo "   - 重启Mac"
echo "   - 重新运行此脚本"
echo ""
echo "7. 完成后，右键点击任何视频文件应该会看到 'Convert to PPT' 选项"
echo ""

# 打开系统设置的扩展页面
echo "正在打开系统设置的扩展页面..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Extensions"