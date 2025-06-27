#!/bin/bash
# macOS 依赖检查和安装脚本

echo "🍎 检查 macOS 测试依赖..."

# 检查 Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew 未安装"
    echo "请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
else
    echo "✅ Homebrew 已安装"
fi

# 检查 coreutils (提供 gtimeout)
if ! command -v gtimeout >/dev/null 2>&1; then
    echo "⚠️ coreutils 未安装，这将导致测试超时功能不可用"
    echo "正在安装 coreutils..."
    if brew install coreutils; then
        echo "✅ coreutils 安装成功"
    else
        echo "❌ coreutils 安装失败"
        echo "手动安装: brew install coreutils"
    fi
else
    echo "✅ coreutils (gtimeout) 已安装"
fi

# 检查编译工具
if command -v clang >/dev/null 2>&1; then
    echo "✅ clang 已安装: $(clang --version | head -1)"
else
    echo "❌ clang 未安装，请安装 Xcode Command Line Tools:"
    echo "xcode-select --install"
fi

echo ""
echo "🎉 依赖检查完成！"
echo "现在可以运行: ./scripts/run_unit_tests.sh -s basic" 