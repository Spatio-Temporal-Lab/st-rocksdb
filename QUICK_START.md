# 🚀 ST-RocksDB 快速开始指南

## 📋 项目概述

ST-RocksDB 是基于 TiKV RocksDB 分支的定制化版本，专门为高性能存储场景优化。

## ⚡ 快速验证

### 1. 系统要求

**macOS:**
```bash
# 安装依赖
brew install cmake gflags snappy lz4 zstd ninja
```

**Ubuntu/Debian:**
```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y build-essential cmake libgflags-dev \
    libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev \
    ninja-build clang
```

### 2. 快速构建测试

```bash
# 克隆仓库
git clone <your-repo-url>
cd st-rocksdb

# 运行快速验证
chmod +x quick_test.sh
./quick_test.sh
```

### 3. 详细构建选项

**构建静态库:**
```bash
make static_lib DEBUG_LEVEL=0
```

**构建共享库:**
```bash
make shared_lib DEBUG_LEVEL=0 LIB_MODE=shared
```

**构建调试版本:**
```bash
make static_lib DEBUG_LEVEL=1
```

## 🔧 本地开发

### 使用本地构建脚本
```bash
# 完整的本地构建测试
./scripts/local_build_test.sh

# 检查代码格式
make check-format

# 修复代码格式
make format
```

### 常见构建问题

1. **编译错误处理**
   - 确保安装了所有依赖项
   - 检查编译器版本 (推荐 Clang)
   - 清理构建缓存: `make clean`

2. **链接错误**
   - 检查库文件路径
   - 确认依赖库版本兼容性

3. **权限问题**
   - 确保脚本有执行权限: `chmod +x script_name.sh`

## 🚀 CI/CD 流水线

项目配置了自动化 CI/CD 流水线：

- **代码格式检查**: 自动验证代码风格
- **多平台构建**: Ubuntu 和 macOS
- **多配置测试**: Debug 和 Release 模式
- **构建验证**: 静态库和共享库

### 触发条件
- Push 到 `main`, `master`, `denjixu_dev` 分支
- 创建 Pull Request

## 📖 更多资源

- [详细构建指南](build_fix_guide.md)
- [CI/CD 配置说明](CI_CD_README.md)
- [执行指南](执行指南.md)

## 🆘 获取帮助

如果遇到问题：

1. 查看 [构建修复指南](build_fix_guide.md)
2. 检查 GitHub Actions 日志
3. 提交 Issue 描述问题

---

**构建状态**: [![CI/CD Pipeline](../../actions/workflows/ci.yml/badge.svg)](../../actions/workflows/ci.yml) 