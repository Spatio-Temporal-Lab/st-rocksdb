#!/bin/bash
# RocksDB 测试环境验证脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 RocksDB 测试环境验证${NC}"

# 检查基础工具
echo -e "\n${YELLOW}📋 检查基础工具...${NC}"

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "✅ $1: $(which $1)"
    else
        echo -e "❌ $1: 未找到"
    fi
}

check_command "make"
check_command "clang"

# 检查项目文件
echo -e "\n${YELLOW}📁 检查项目文件...${NC}"

files=("Makefile" "src.mk" "scripts/run_unit_tests.sh")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "✅ $file"
    else
        echo -e "❌ $file"
    fi
done

# 快速构建测试
echo -e "\n${YELLOW}🚀 测试快速构建...${NC}"
if make clean &> /dev/null && make static_lib DEBUG_LEVEL=0 -j4 &> /dev/null; then
    echo -e "✅ 构建成功"
else
    echo -e "❌ 构建失败"
fi

echo -e "\n${GREEN}🎉 验证完成！${NC}"
echo "下一步: ./scripts/run_unit_tests.sh -s basic" 