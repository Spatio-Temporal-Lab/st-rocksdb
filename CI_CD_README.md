# 🔄 CI/CD 配置详细说明

## 📋 流水线概述

ST-RocksDB 项目使用 GitHub Actions 实现完整的 CI/CD 流水线，确保代码质量和构建稳定性。

## 🚀 流水线组件

### 1. 主 CI 流水线 (`.github/workflows/ci.yml`)

#### 触发条件
- Push 到主要分支: `main`, `master`, `denjixu_dev`
- Pull Request 目标分支: `main`, `master`, `denjixu_dev`

#### 流水线阶段

**阶段 1: 代码格式检查**
- 运行平台: Ubuntu Latest
- 检查工具: clang-format
- 当前状态: 临时跳过 (避免分支引用问题)

**阶段 2: Ubuntu 构建**
- 运行平台: Ubuntu Latest
- 编译器: Clang
- 构建模式: Debug / Release (矩阵构建)
- 构建目标:
  - 静态库 (`librocksdb.a`)
  - 共享库 (`librocksdb.so`)
  - 测试库 (`librocksdb_test.so`)

**阶段 3: macOS 构建**
- 运行平台: macOS Latest
- 编译器: 系统默认 Clang
- 构建模式: Debug / Release (矩阵构建)
- 构建目标:
  - 静态库 (`librocksdb.a`)
  - 共享库 (`librocksdb.dylib`)

**阶段 4: 单元测试**
- 运行平台: Ubuntu Latest
- 依赖: Ubuntu 构建成功
- 测试套件: basic, db, util, table, cache (矩阵构建)
- 当前状态: 构建测试基础设施

### 2. PR 审查流水线 (`.github/workflows/pr-review.yml`)

#### 功能特性
- 代码质量检查
- 安全漏洞扫描 (Trivy)
- 跨平台兼容性验证
- 性能回归测试
- 内存泄漏检测 (Valgrind)
- 文档一致性检查
- 中文测试报告生成

## 🔧 构建配置详解

### 依赖管理

**Ubuntu 依赖:**
```yaml
build-essential cmake libgflags-dev libsnappy-dev 
zlib1g-dev libbz2-dev liblz4-dev libzstd-dev ninja-build clang
```

**macOS 依赖:**
```yaml
cmake gflags snappy lz4 zstd ninja
```

### 编译器配置

**统一使用 Clang:**
- Ubuntu: 显式安装并设置 `CC=clang`, `CXX=clang++`
- macOS: 使用系统默认 Clang
- 原因: 避免 GCC/Clang 混用导致的 PIC 问题

### 构建标志

**静态库构建:**
```bash
make static_lib DEBUG_LEVEL={0|1}
```

**共享库构建:**
```bash
make shared_lib DEBUG_LEVEL={0|1} LIB_MODE=shared
```

**关键修复:**
- 每次共享库构建前执行 `make clean`
- 确保 PIC (Position Independent Code) 正确编译
- 使用并行构建提高效率

## 📊 构建缓存策略

### 缓存配置
```yaml
uses: actions/cache@v3
with:
  path: |
    librocksdb.*
    librocksdb_test.*
    *.o
  key: ubuntu-${{ matrix.build_type }}-${{ hashFiles('**/*.cc', '**/*.h') }}
```

### 缓存优势
- 加速后续构建
- 减少 CI 资源消耗
- 基于源码哈希的智能失效

## 🧪 测试策略

### 当前实现
1. **构建验证测试**
   - 验证静态库存在且非空
   - 验证共享库正确生成
   - 基本链接测试

2. **平台兼容性测试**
   - Ubuntu 20.04+ 兼容性
   - macOS 12+ 兼容性
   - ARM64/x86_64 架构支持

### 计划中的测试
1. **功能测试**
   - 单元测试恢复
   - 集成测试
   - API 兼容性测试

2. **性能测试**
   - 基准测试
   - 回归检测
   - 内存使用分析

## 🚨 已知问题与解决方案

### 1. VLA 编译错误
**问题**: Variable Length Arrays 不兼容标准 C++
**解决**: 替换为 `std::vector`

### 2. 测试链接问题
**问题**: ARM64 架构测试符号未定义
**现状**: 暂时跳过，专注库构建验证

### 3. 共享库 PIC 错误
**问题**: Position Independent Code 编译标志
**解决**: 统一使用 Clang，强制清理重建

## 📈 性能优化

### 并行构建
- Ubuntu: `make -j$(nproc)`
- macOS: `make -j$(sysctl -n hw.ncpu)`
- 默认回退: `make -j4`

### 资源配置
```yaml
env:
  MAKEFLAGS: "-j4"
```

## 🔍 监控与调试

### 查看构建日志
1. 访问 GitHub Actions 页面
2. 点击具体的工作流运行
3. 展开失败的作业查看详细日志

### 本地复现 CI 环境
```bash
# 模拟 Ubuntu 构建
export CC=clang
export CXX=clang++
make clean
make static_lib DEBUG_LEVEL=0

# 模拟 macOS 构建  
make clean
make static_lib DEBUG_LEVEL=0
```

### 常见调试命令
```bash
# 详细构建信息
make static_lib V=1

# 检查编译器
$CC --version
$CXX --version

# 检查链接器
ldd librocksdb.so  # Linux
otool -L librocksdb.dylib  # macOS
```

## 📋 最佳实践

### 开发者工作流
1. **本地验证**: 提交前运行 `./quick_test.sh`
2. **格式检查**: 运行 `make check-format`
3. **小步提交**: 避免大量更改影响 CI 调试
4. **监控 CI**: 提交后及时查看 CI 状态

### CI 优化建议
1. **并行作业**: 最大化利用 GitHub Actions 并发
2. **智能缓存**: 基于文件哈希的精确缓存
3. **早期失败**: 快速失败节省资源
4. **渐进测试**: 先验证基础构建再进行复杂测试

## 🔮 未来规划

### 短期目标 (1-2周)
- [ ] 修复单元测试链接问题
- [ ] 实现完整的测试覆盖率
- [ ] 添加性能基准测试

### 中期目标 (1个月)
- [ ] 实现自动部署流程
- [ ] 添加代码覆盖率报告
- [ ] 集成更多静态分析工具

### 长期目标 (3个月)
- [ ] 多架构支持 (ARM64, x86_64)
- [ ] 容器化构建环境
- [ ] 自动化发布流程

---

**维护者**: 项目团队  
**最后更新**: $(date +'%Y-%m-%d')  
**文档版本**: v1.0 