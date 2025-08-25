#!/bin/bash

echo "=== Video2PPT Extension 诊断工具 ==="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 检查应用安装
echo "1. 检查应用安装状态:"
if [ -d "/Applications/Video2PPT.app" ]; then
    echo -e "   ${GREEN}✓${NC} Video2PPT.app 已安装"
    
    # 检查签名
    if codesign -dv /Applications/Video2PPT.app 2>&1 | grep -q "adhoc"; then
        echo -e "   ${YELLOW}⚠${NC} 应用使用adhoc签名（本地开发版本）"
    else
        echo -e "   ${GREEN}✓${NC} 应用签名正常"
    fi
else
    echo -e "   ${RED}✗${NC} Video2PPT.app 未安装在 /Applications/"
    echo "   请先运行: ./build.sh"
    exit 1
fi

# 2. 检查扩展文件
echo ""
echo "2. 检查扩展文件:"
EXTENSION_PATH="/Applications/Video2PPT.app/Contents/PlugIns/Video2PPTExtension.appex"
if [ -d "$EXTENSION_PATH" ]; then
    echo -e "   ${GREEN}✓${NC} 扩展文件存在"
else
    echo -e "   ${RED}✗${NC} 扩展文件不存在"
    echo "   需要重新构建应用"
    exit 1
fi

# 3. 检查扩展注册
echo ""
echo "3. 检查扩展注册状态:"
PLUGIN_STATUS=$(pluginkit -m | grep "com.video2ppt.Video2PPT.FinderExtension" || echo "未找到")
if [[ $PLUGIN_STATUS == *"!"* ]]; then
    echo -e "   ${YELLOW}⚠${NC} 扩展已注册但未启用"
    echo "   状态: $PLUGIN_STATUS"
elif [[ $PLUGIN_STATUS == *"+"* ]]; then
    echo -e "   ${GREEN}✓${NC} 扩展已注册并启用"
    echo "   状态: $PLUGIN_STATUS"
elif [[ $PLUGIN_STATUS == "未找到" ]]; then
    echo -e "   ${RED}✗${NC} 扩展未注册"
else
    echo -e "   ${YELLOW}⚠${NC} 扩展状态未知"
    echo "   状态: $PLUGIN_STATUS"
fi

# 4. 检查Python和video2ppt
echo ""
echo "4. 检查Python环境:"
if command -v python3 &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Python3 已安装: $(python3 --version)"
else
    echo -e "   ${RED}✗${NC} Python3 未安装"
fi

if command -v video2ppt &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} video2ppt 命令可用: $(which video2ppt)"
elif command -v v2p &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} v2p 命令可用: $(which v2p)"
else
    echo -e "   ${YELLOW}⚠${NC} video2ppt/v2p 命令未找到"
    echo "   请运行: pip install -e ."
fi

# 5. 检查系统日志中的错误
echo ""
echo "5. 检查最近的扩展相关日志:"
echo "   查找最近5分钟内的相关日志..."
LOG_COUNT=$(log show --last 5m --predicate 'subsystem == "com.video2ppt.Video2PPT"' 2>/dev/null | wc -l)
if [ $LOG_COUNT -gt 0 ]; then
    echo -e "   ${YELLOW}⚠${NC} 发现 $LOG_COUNT 条相关日志"
    echo "   运行以下命令查看详细日志:"
    echo "   log show --last 5m --predicate 'subsystem == \"com.video2ppt.Video2PPT\"'"
else
    echo -e "   ${GREEN}✓${NC} 未发现错误日志"
fi

# 6. 提供解决建议
echo ""
echo "=== 建议的解决步骤 ==="
echo ""

if [[ $PLUGIN_STATUS == *"!"* ]]; then
    echo "扩展未启用，请执行："
    echo "1. 打开 系统设置 > 隐私与安全性 > 扩展 > Finder扩展"
    echo "2. 勾选 'Video2PPT Extension'"
    echo "3. 重启Finder: killall Finder"
    echo ""
    echo "快速打开设置:"
    echo "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Extensions'"
elif [[ $PLUGIN_STATUS == "未找到" ]]; then
    echo "扩展未注册，请执行："
    echo "1. 启动应用: open /Applications/Video2PPT.app"
    echo "2. 等待3秒后关闭应用"
    echo "3. 重新运行此诊断脚本"
fi

echo ""
echo "如果问题持续，尝试："
echo "1. 重启Mac"
echo "2. 运行: ./rebuild_with_fix.sh"
echo ""