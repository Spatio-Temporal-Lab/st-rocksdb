#!/bin/bash
# 快速验证构建脚本
set -e

echo "🚀 开始快速构建验证..."

# 1. 清理之前的构建
echo "📦 清理构建缓存..."
make clean || true

# 2. 构建静态库
echo "🔨 构建静态库..."
if make static_lib DEBUG_LEVEL=0 -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4); then
    echo "✅ 静态库构建成功"
    ls -la librocksdb.a
else
    echo "❌ 静态库构建失败"
    exit 1
fi

# 3. 构建共享库
echo "🔨 构建共享库..."
if make shared_lib DEBUG_LEVEL=0 LIB_MODE=shared -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4); then
    echo "✅ 共享库构建成功"
    ls -la librocksdb.*
else
    echo "❌ 共享库构建失败"
    exit 1
fi

# 4. 简单验证
echo "🔍 验证构建结果..."
if [ -f "librocksdb.a" ] && [ -s "librocksdb.a" ]; then
    echo "✅ 静态库文件存在且非空"
else
    echo "❌ 静态库文件有问题"
    exit 1
fi

if ls librocksdb.so* 1> /dev/null 2>&1 || ls librocksdb.dylib* 1> /dev/null 2>&1; then
    echo "✅ 共享库文件存在"
else
    echo "❌ 共享库文件不存在"
    exit 1
fi

echo "�� 快速验证完成！所有基本构建都成功！" 