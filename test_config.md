# RocksDB 测试配置指南

## 概述

本文档详细说明了 RocksDB 项目的测试体系，包括单元测试、集成测试、性能测试和内存安全测试的完整配置。

## 测试架构

### 测试分类

| 测试类型 | 目标 | 包含测试 | 运行时间 |
|----------|------|----------|----------|
| **基础测试** | 核心功能验证 | C API, 内存管理, 编码, 哈希 | ~5 分钟 |
| **数据库测试** | 数据库操作 | CRUD, 事务, 版本控制, 日志 | ~15 分钟 |
| **工具测试** | 工具函数 | 线程, 队列, 统计, 定时器 | ~8 分钟 |
| **表格测试** | 存储格式 | 块格式, 合并, 索引, SST | ~10 分钟 |
| **缓存测试** | 缓存机制 | LRU, 分片, 预留管理 | ~6 分钟 |
| **集成测试** | 端到端功能 | 压缩, 外部文件, 导入 | ~20 分钟 |

### 测试工具

- **GoogleTest (gtest)**: 单元测试框架
- **AddressSanitizer**: 内存安全检测
- **Valgrind**: 内存泄漏检测 (Linux)
- **db_bench**: 性能基准测试

## CI/CD 集成

### GitHub Actions 工作流

```yaml
# 单元测试矩阵 (并行执行)
unit-tests:
  strategy:
    matrix:
      test_suite: [basic, db, util, table, cache]
  
# 集成测试 (PR 触发)
integration-tests:
  if: github.event_name == 'pull_request'
  
# 性能测试 (PR 触发)  
performance-tests:
  if: github.event_name == 'pull_request'
  
# 内存测试 (PR 触发)
memory-tests:
  if: github.event_name == 'pull_request'
```

### 测试覆盖

- ✅ **跨平台支持**: Ubuntu, macOS
- ✅ **多编译器**: Clang (推荐)
- ✅ **构建模式**: Debug, Release
- ✅ **内存检测**: AddressSanitizer, Valgrind
- ✅ **并发执行**: 测试套件并行化
- ✅ **超时控制**: 防止测试hang死

## 本地测试

### 快速开始

```bash
# 运行所有基础测试
./scripts/run_unit_tests.sh -s basic

# 运行数据库测试，启用 AddressSanitizer
./scripts/run_unit_tests.sh -s db -a

# Release 构建 + 集成测试
./scripts/run_unit_tests.sh -s integration -t Release

# 并行构建 (8 jobs)
./scripts/run_unit_tests.sh -j 8

# 跳过构建，直接运行缓存测试
./scripts/run_unit_tests.sh --skip-build -s cache
```

### 脚本选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `-t, --type` | 构建类型 (Debug\|Release) | Debug |
| `-s, --suite` | 测试套件 | all |
| `-j, --jobs` | 并行任务数 | CPU 核心数 |
| `-T, --timeout` | 超时时间 (秒) | 300 |
| `-a, --asan` | 启用 AddressSanitizer | false |
| `--skip-build` | 跳过构建阶段 | false |

## 测试详情

### 基础测试套件

**目标**: 验证核心数据结构和算法的正确性

```bash
# 包含的测试
c_test              # C API 兼容性
arena_test          # 内存分配器  
autovector_test     # 自动向量
bloom_test          # 布隆过滤器
coding_test         # 编码/解码
crc32c_test         # 校验和
hash_test           # 哈希函数
random_test         # 随机数生成
slice_test          # 字符串切片
slice_transform_test # 切片变换
```

### 数据库测试套件

**目标**: 验证数据库核心操作的正确性

```bash
# 包含的测试
db_basic_test       # 基础 CRUD 操作
db_test             # 完整数据库功能
dbformat_test       # 数据格式
corruption_test     # 数据损坏恢复
version_edit_test   # 版本编辑
version_set_test    # 版本集合
write_batch_test    # 批量写入
log_test            # 事务日志
```

### 工具测试套件

**目标**: 验证辅助工具和基础设施

```bash
# 包含的测试
thread_local_test   # 线程本地存储
work_queue_test     # 工作队列
histogram_test      # 统计直方图
dynamic_bloom_test  # 动态布隆过滤器
timer_test          # 定时器
thread_list_test    # 线程列表
repeatable_thread_test # 可重复线程
```

### 表格测试套件

**目标**: 验证存储格式和索引机制

```bash
# 包含的测试
table_test          # 表格式
block_test          # 块格式
merger_test         # 合并器
block_fetcher_test  # 块获取器
cleanable_test      # 清理机制
sst_file_reader_test # SST 文件读取
```

### 缓存测试套件

**目标**: 验证缓存算法和内存管理

```bash
# 包含的测试
cache_test          # 基础缓存
lru_cache_test      # LRU 缓存
cache_reservation_manager_test # 缓存预留管理
```

### 集成测试套件

**目标**: 验证端到端功能和复杂操作

```bash
# 包含的测试
db_compaction_test  # 数据压缩
external_sst_file_test # 外部 SST 文件
manual_compaction_test # 手动压缩
import_column_family_test # 列族导入
flush_job_test      # 刷新任务
```

## 性能测试

### db_bench 基准测试

```bash
# 基础性能测试
./db_bench \
  --benchmarks=fillseq,readrandom \
  --num=100000 \
  --threads=1 \
  --db=/tmp/rocksdb_bench \
  --value_size=100

# 支持的基准测试类型
fillseq         # 顺序写入
fillrandom      # 随机写入  
readseq         # 顺序读取
readrandom      # 随机读取
readmissing     # 读取不存在的键
seekrandom      # 随机查找
```

### 性能指标

- **吞吐量**: ops/sec
- **延迟**: P50, P95, P99 延迟
- **内存使用**: RSS, 堆内存
- **I/O**: 读写字节数

## 内存安全测试

### AddressSanitizer (ASAN)

```bash
# 启用 ASAN 构建
COMPILE_WITH_ASAN=1 make db_test

# 运行时配置
export ASAN_OPTIONS="detect_leaks=1:abort_on_error=1"
./db_test
```

**检测能力**:
- 堆内存溢出
- 栈内存溢出  
- 使用已释放内存
- 内存泄漏
- 双重释放

### Valgrind (Linux)

```bash
# 完整内存检查
make valgrind_check

# 指定测试
valgrind --tool=memcheck --leak-check=full ./db_test
```

## 测试最佳实践

### 编写测试

1. **测试命名**: 使用描述性名称，遵循 `TEST(Class, Method)` 格式
2. **断言选择**: 优先使用 `EXPECT_*` 而非 `ASSERT_*`
3. **测试隔离**: 每个测试独立，不依赖其他测试状态
4. **资源清理**: 使用 RAII 或 `TearDown()` 确保资源释放

### 调试失败测试

```bash
# 运行单个测试
./db_test --gtest_filter="DBTest.BasicOperations"

# 启用详细输出
./db_test --gtest_filter="*" --v=1

# 使用 GDB 调试
gdb --args ./db_test --gtest_filter="DBTest.FailingTest"
```

### 性能优化

1. **并行化**: 使用测试套件并行执行
2. **过滤器**: 仅运行相关测试
3. **缓存**: 缓存构建产物
4. **超时**: 设置合理的超时时间

## 故障排查

### 常见问题

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| 链接错误 | `undefined reference` | 检查库依赖，重新构建 |
| 测试超时 | 测试 hang 死 | 减少测试规模或增加超时 |
| 内存不足 | OOM killer | 减少并行度或测试规模 |
| 文件权限 | Permission denied | 检查文件权限和磁盘空间 |

### 调试命令

```bash
# 检查构建状态
make clean && make static_lib

# 验证测试可执行文件
ldd ./db_test  # Linux
otool -L ./db_test  # macOS

# 检查测试列表
./db_test --gtest_list_tests

# 运行特定测试组
./db_test --gtest_filter="DBTest.*Basic*"
```

## 贡献指南

### 添加新测试

1. 在对应的 `*_test.cc` 文件中添加测试用例
2. 更新相关的测试套件配置
3. 确保新测试在所有平台通过
4. 添加必要的文档说明

### 修改现有测试

1. 保持测试的向后兼容性
2. 更新相关的过滤器和超时配置
3. 验证更改不影响其他测试
4. 更新文档和注释

---

## 支持

如有问题，请：
1. 查看 [构建指南](build_fix_guide.md)
2. 检查 [执行指南](执行指南.md)
3. 提交 Issue 或 PR 