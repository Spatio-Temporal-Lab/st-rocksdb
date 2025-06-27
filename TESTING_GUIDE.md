# 🧪 ST-RocksDB 测试指南

## 📋 项目概述

ST-RocksDB 现已启用真实的单元测试系统，本文档提供完整的测试结构说明和CI集成指导。

## 📁 测试文件目录结构

### 🏗️ 测试源文件分布

```
st-rocksdb/
├── test_util/                     # 测试工具库
│   ├── testharness.cc            # 测试框架核心
│   ├── testutil.cc               # 测试辅助工具
│   ├── sync_point.cc             # 同步点测试工具
│   ├── mock_time_env.cc          # 模拟时间环境
│   └── secondary_cache_test_util.cc
│
├── memory/                        # 内存管理测试
│   ├── arena_test.cc             # ✅ 已启用 - Arena内存管理
│   └── memory_allocator_test.cc  # 内存分配器测试
│
├── util/                          # 基础工具测试  
│   ├── coding_test.cc            # ✅ 已启用 - 编码/解码
│   ├── crc32c_test.cc            # ✅ 已启用 - CRC校验
│   ├── hash_test.cc              # ✅ 已启用 - 哈希函数
│   ├── random_test.cc            # ✅ 已启用 - 随机数生成
│   ├── slice_test.cc             # ✅ 已启用 - 字符串切片
│   ├── autovector_test.cc        # ✅ 已启用 - 自动向量
│   ├── bloom_test.cc             # ✅ 已启用 - Bloom过滤器
│   ├── dynamic_bloom_test.cc     # ✅ 已启用 - 动态Bloom
│   ├── thread_local_test.cc      # ✅ 已启用 - 线程本地存储
│   └── work_queue_test.cc        # ✅ 已启用 - 工作队列
│
├── db/                            # 数据库核心测试
│   ├── db_basic_test.cc          # ✅ 已启用 - 数据库基础操作
│   ├── corruption_test.cc        # ✅ 已启用 - 数据损坏恢复
│   ├── dbformat_test.cc          # ✅ 已启用 - 数据库格式
│   ├── db_test.cc                # 🔄 待启用 - 完整数据库测试
│   ├── db_test2.cc               # 🔄 待启用 - 扩展数据库测试
│   ├── c_test.c                  # C API测试
│   └── column_family_test.cc     # 列族测试
│
├── table/                         # 表格系统测试
│   ├── table_test.cc             # ✅ 已启用 - 表格基础测试
│   ├── block_test.cc             # ✅ 已启用 - 数据块测试
│   ├── merger_test.cc            # ✅ 已启用 - 合并器测试
│   ├── block_fetcher_test.cc     # ✅ 已启用 - 块获取器测试
│   └── sst_file_reader_test.cc   # SST文件读取测试
│
├── cache/                         # 缓存系统测试
│   ├── cache_test.cc             # ✅ 已启用 - 缓存基础测试
│   └── lru_cache_test.cc         # LRU缓存测试
│
├── monitoring/                    # 监控系统测试
│   ├── histogram_test.cc         # ✅ 已启用 - 直方图统计
│   ├── statistics_test.cc        # 统计信息测试
│   └── iostats_context_test.cc   # IO统计测试
│
├── env/                           # 环境抽象测试
│   ├── env_basic_test.cc         # 🔧 已修复 - 基础环境测试
│   └── env_test.cc               # 环境完整测试
│
└── utilities/                     # 工具集测试
    ├── backup/backup_engine_test.cc      # 备份引擎测试
    ├── checkpoint/checkpoint_test.cc      # 检查点测试
    ├── options/options_util_test.cc       # 选项工具测试
    └── transactions/                      # 事务系统测试
        ├── transaction_test.cc
        └── optimistic_transaction_test.cc
```

## 🎯 当前CI测试状态

### ✅ 已启用的测试套件

#### 1. **Basic 套件** (基础功能)
```bash
# 测试文件: 6个测试
arena_test              # 内存Arena管理
coding_test             # 编码解码功能
crc32c_test            # CRC32C校验算法
hash_test              # 哈希函数
random_test            # 随机数生成器
slice_test             # 字符串切片操作

# 运行时间: ~2-3分钟
# 稳定性: 极高
# 失败风险: 极低
```

#### 2. **DB 套件** (数据库核心)
```bash
# 测试文件: 3个测试
db_basic_test          # 数据库基础操作 (过滤: *Basic*:*Put*:*Get*)
corruption_test        # 数据损坏恢复 (过滤: *Recovery*, 超时: 3分钟)
dbformat_test          # 数据库格式验证

# 运行时间: ~5-8分钟
# 稳定性: 高
# 失败风险: 低-中等
```

#### 3. **Util 套件** (工具库)
```bash
# 测试文件: 5个测试
autovector_test        # 自动向量容器
bloom_test             # Bloom过滤器 (过滤: *Basic*)
dynamic_bloom_test     # 动态Bloom过滤器 (过滤: *Basic*)
thread_local_test      # 线程本地存储
work_queue_test        # 工作队列

# 运行时间: ~3-4分钟
# 稳定性: 高
# 失败风险: 低
```

#### 4. **Table 套件** (表格处理)
```bash
# 测试文件: 4个测试
table_test             # 表格基础测试 (过滤: *TableTest.Basic*:*TableTest.Empty*, 超时: 4分钟)
block_test             # 数据块测试 (过滤: *SimpleBlock*)
merger_test            # 合并器测试
block_fetcher_test     # 块获取器测试 (过滤: *Basic*)

# 运行时间: ~4-6分钟
# 稳定性: 中-高
# 失败风险: 低-中等
```

#### 5. **Cache 套件** (缓存系统)
```bash
# 测试文件: 2个测试
cache_test             # 缓存基础测试 (过滤: *Cache.Basic*:*Cache.Simple*, 超时: 3.3分钟)
histogram_test         # 直方图统计测试

# 运行时间: ~3-5分钟
# 稳定性: 高
# 失败风险: 低
```

## 📊 测试构建依赖

### 🏗️ 构建顺序
```bash
1. librocksdb.so              # 主库 (已验证)
2. librocksdb_test_debug.so   # 测试库 (新启用)
3. 各个测试二进制文件          # 单独构建
```

### 📦 测试库组成
```bash
# librocksdb_test_debug.so 包含:
db/db_test_util.o                    # 数据库测试工具
db/db_with_timestamp_test_util.o     # 时间戳测试工具  
test_util/mock_time_env.o            # 模拟时间环境
test_util/testharness.o              # 测试框架
test_util/testutil.o                 # 测试工具集
third-party/gtest-1.8.1/             # Google Test框架
```

## 🔄 扩展测试指南

### 📝 添加新测试到CI的步骤

#### 1. **选择测试分类**
根据测试内容选择合适的套件:
- `basic`: 基础工具、算法、数据结构
- `db`: 数据库核心功能
- `util`: 辅助工具和工具类  
- `table`: 表格格式和处理
- `cache`: 缓存和内存管理

#### 2. **修改CI配置**
编辑 `.github/workflows/ci.yml`:

```yaml
"basic")
  echo "🔬 基础功能测试..."
  make DEBUG_LEVEL=1 -j$(nproc) \
    arena_test \
    coding_test \
    # 在这里添加新的测试目标
    new_test_name
  
  echo "运行基础功能测试..."
  ./arena_test --gtest_brief=1
  ./coding_test --gtest_brief=1
  # 在这里添加新的测试执行
  ./new_test_name --gtest_brief=1
  ;;
```

#### 3. **验证测试可构建性**
```bash
# 本地验证新测试能否构建
make DEBUG_LEVEL=1 new_test_name

# 验证测试能否运行
./new_test_name --gtest_list_tests
```

### 🚀 推荐的扩展优先级

#### **第一优先级** (立即可添加):
```bash
# 这些测试稳定性高，构建简单
c_test                    # C API基础测试
ribbon_test              # Ribbon过滤器
rate_limiter_test        # 速率限制器
defer_test               # 延迟执行测试
filelock_test            # 文件锁测试
```

#### **第二优先级** (需要小心验证):
```bash
# 这些测试可能有平台依赖或时间依赖
env_logger_test          # 环境日志测试
auto_roll_logger_test    # 自动滚动日志
io_posix_test           # POSIX IO测试
options_test            # 选项配置测试
```

#### **第三优先级** (需要充分测试):
```bash
# 这些测试复杂度高，需要仔细调优
db_test                  # 完整数据库测试
db_compaction_test       # 压缩测试
external_sst_file_test   # 外部SST文件测试
backup_engine_test       # 备份引擎测试
```

## 🛠️ 本地测试指南

### 🔧 快速测试命令

```bash
# 构建并运行基础测试套件
./scripts/local_build_test.sh

# 构建测试库
make DEBUG_LEVEL=1 librocksdb_test_debug.so

# 运行单个测试套件
make DEBUG_LEVEL=1 arena_test && ./arena_test

# 运行带过滤的测试
./db_basic_test --gtest_filter="*Basic*"

# 列出测试中的所有用例
./arena_test --gtest_list_tests
```

### 📊 测试性能优化

#### 🎯 GTest 选项优化:
```bash
--gtest_brief=1          # 简洁输出
--gtest_filter="*Basic*" # 过滤测试用例
--gtest_repeat=1         # 重复次数
--gtest_shuffle          # 随机顺序
--gtest_break_on_failure # 首次失败时停止
```

#### ⏱️ 超时设置策略:
- **基础测试**: 无超时 (< 1分钟)
- **工具测试**: 无超时 (< 2分钟)  
- **DB测试**: 3-5分钟超时
- **表格测试**: 4分钟超时
- **缓存测试**: 3.3分钟超时

## 📈 监控和故障排除

### 🔍 常见测试失败原因

1. **超时失败**: 增加timeout时间或添加更严格的过滤
2. **内存不足**: 减少并行测试数量或使用更严格的过滤
3. **平台依赖**: 使用条件编译或平台特定的过滤
4. **竞态条件**: 添加适当的同步或重试机制

### 📊 测试统计信息

```bash
# 当前启用测试数量: 20个
# 预计总运行时间: 15-25分钟 (5个并行套件)
# 平均每个套件: 3-5分钟
# 成功率预期: >95%
```

## 🎯 后续规划

### 📅 短期目标 (1-2周)
- [x] 启用基础测试套件 (20个测试)
- [ ] 添加C API测试
- [ ] 添加更多工具类测试
- [ ] 优化测试超时和过滤策略

### 📅 中期目标 (1个月)
- [ ] 启用完整数据库测试
- [ ] 添加事务系统测试
- [ ] 集成性能基准测试
- [ ] 添加内存泄漏检测

### 📅 长期目标 (3个月)
- [ ] 完整的 `make check` 支持
- [ ] 自动化测试报告生成
- [ ] 测试覆盖率统计
- [ ] 跨平台测试支持

---

**最后更新**: 2024-06-27 17:35  
**状态**: ✅ 基础测试已启用，CI流水线升级完成 