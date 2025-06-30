# 📝 ST-RocksDB 新单元测试创建指南

## 🎯 概述

本指南详细说明如何在 ST-RocksDB 项目中添加新的单元测试，包括文件位置、配置修改和CI集成。

## 📁 第一步：确定测试文件位置

### 🗂️ 测试文件命名规则

测试文件必须遵循以下命名模式：
```
<功能模块>/<测试名称>_test.cc    # C++测试
<功能模块>/<测试名称>_test.c     # C测试
```

### 📍 推荐的测试目录结构

根据您的测试内容，选择合适的目录：

#### 🧠 **基础功能测试** (`basic` 套件)
```bash
# 内存管理
memory/your_test_name_test.cc

# 基础工具
util/your_utility_test.cc

# 示例：添加新的哈希算法测试
util/new_hash_algorithm_test.cc
```

#### 🗄️ **数据库核心测试** (`db` 套件)
```bash
# 数据库核心功能
db/your_db_feature_test.cc

# 数据库组件测试
db/component/your_component_test.cc

# 示例：添加新的压缩策略测试
db/compaction/new_compaction_strategy_test.cc
```

#### 🔧 **工具库测试** (`util` 套件)
```bash
# 已有工具扩展
util/your_enhanced_utility_test.cc

# 示例：添加新的编码算法测试
util/new_encoding_test.cc
```

#### 📊 **表格系统测试** (`table` 套件)
```bash
# 表格格式测试
table/your_table_format_test.cc

# 块处理测试  
table/block_based/your_block_feature_test.cc

# 示例：添加新的索引类型测试
table/block_based/new_index_type_test.cc
```

#### 💾 **缓存系统测试** (`cache` 套件)
```bash
# 缓存算法测试
cache/your_cache_algorithm_test.cc

# 示例：添加新的缓存策略测试
cache/new_cache_policy_test.cc
```

#### 🛠️ **工具集测试** (`utilities` 套件)
```bash
# 备份恢复测试
utilities/backup/your_backup_feature_test.cc

# 事务系统测试
utilities/transactions/your_transaction_feature_test.cc

# 示例：添加新的备份压缩测试
utilities/backup/backup_compression_test.cc
```

## ⚙️ 第二步：修改配置文件

### 📝 必须修改的文件

#### 1. **添加到 `src.mk`** (最重要)

编辑 `src.mk` 文件，在 `TEST_MAIN_SOURCES` 部分添加您的测试文件：

```makefile
TEST_MAIN_SOURCES =                                                     \
  cache/cache_test.cc                                                   \
  # ... 现有测试 ...
  util/your_new_test.cc                                                \  # 在这里添加
  # ... 其他测试 ...
```

**位置选择**：
- 按字母顺序插入到相应目录分组中
- 保持反斜杠 `\` 续行符的一致性
- 确保目录分组的整洁性

#### 2. **添加到 `Makefile`** (自动生成)

Makefile 中的测试规则通常是自动生成的，但如果需要特殊配置，可以添加：

```makefile
# 在 Makefile 中找到类似的规则，并添加：
your_new_test: $(OBJ_DIR)/util/your_new_test.o $(TEST_LIBRARY) $(LIBRARY)
	$(AM_LINK)
```

#### 3. **添加到 CI 配置** (启用测试)

编辑 `.github/workflows/ci.yml`，在合适的测试套件中添加：

```yaml
"util")
  echo "🔧 工具库测试..."
  make DEBUG_LEVEL=1 -j$(nproc) \
    autovector_test \
    bloom_test \
    your_new_test \          # 在这里添加
    # ... 其他测试
  
  echo "运行工具库测试..."
  ./autovector_test --gtest_color=no
  ./bloom_test --gtest_color=no --gtest_filter="*Basic*"
  ./your_new_test --gtest_color=no    # 在这里添加执行
  # ... 其他测试执行
  ;;
```

## 📋 第三步：创建测试文件

### 🏗️ 测试文件模板

创建 `util/your_new_test.cc`：

```cpp
// your_new_test.cc
#include <gtest/gtest.h>
#include "rocksdb/rocksdb_namespace.h"
#include "test_util/testharness.h"
#include "test_util/testutil.h"

// 包含您要测试的头文件
#include "util/your_feature.h"

namespace ROCKSDB_NAMESPACE {

class YourNewTest : public testing::Test {
 public:
  YourNewTest() {
    // 初始化代码
  }

  ~YourNewTest() override {
    // 清理代码
  }

 protected:
  // 测试辅助函数和成员变量
};

// 基础功能测试
TEST_F(YourNewTest, BasicFunctionality) {
  // 您的测试逻辑
  ASSERT_TRUE(true);
  EXPECT_EQ(1, 1);
}

// 边界条件测试
TEST_F(YourNewTest, BoundaryConditions) {
  // 边界测试逻辑
}

// 错误处理测试
TEST_F(YourNewTest, ErrorHandling) {
  // 错误处理测试逻辑
}

}  // namespace ROCKSDB_NAMESPACE

// 主函数（通常自动处理）
int main(int argc, char** argv) {
  ROCKSDB_NAMESPACE::port::InstallStackTraceHandler();
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

### 📦 必需的包含文件

```cpp
// 核心依赖
#include <gtest/gtest.h>                    // Google Test框架
#include "test_util/testharness.h"          // RocksDB测试框架
#include "rocksdb/rocksdb_namespace.h"      // 命名空间

// 常用测试工具
#include "test_util/testutil.h"             // 测试辅助工具
#include "port/stack_trace.h"               // 堆栈跟踪

// 根据需要包含的功能头文件
#include "util/coding.h"                    // 编码功能
#include "util/random.h"                    // 随机数
#include "rocksdb/db.h"                     // 数据库接口
```

## 🧪 第四步：本地验证

### 🔨 构建验证

```bash
# 1. 构建测试库
make DEBUG_LEVEL=1 librocksdb_test_debug.so

# 2. 构建您的测试
make DEBUG_LEVEL=1 your_new_test

# 3. 运行测试
./your_new_test

# 4. 运行带详细输出的测试
./your_new_test --gtest_list_tests
./your_new_test --gtest_filter="YourNewTest.BasicFunctionality"
```

### 🔍 测试验证检查清单

- [ ] 测试可以成功编译
- [ ] 所有测试用例都能通过
- [ ] 没有内存泄漏（可选运行 valgrind）
- [ ] 测试运行时间合理（< 30秒）
- [ ] 输出格式正确

## 🚀 第五步：集成到CI

### 📊 选择合适的测试套件

根据您的测试特性选择合适的套件：

| 套件 | 适用场景 | 运行时间 | 稳定性要求 |
|------|----------|----------|------------|
| `basic` | 基础算法、数据结构、工具函数 | < 3分钟 | 极高 |
| `util` | 辅助工具、编码解码、格式化 | < 4分钟 | 高 |
| `db` | 数据库核心、存储引擎 | < 8分钟 | 中-高 |
| `table` | 表格格式、索引、压缩 | < 6分钟 | 中-高 |
| `cache` | 缓存算法、内存管理 | < 5分钟 | 高 |

### ⚙️ CI配置最佳实践

```yaml
# 为复杂测试添加超时保护
timeout 300 ./your_complex_test --gtest_color=no || echo "Test completed with timeout"

# 为不稳定测试添加过滤
./your_test --gtest_filter="*Stable*:*Basic*" --gtest_color=no

# 为大型测试限制用例
./your_large_test --gtest_filter="*Essential*" --gtest_color=no
```

## 📈 第六步：最佳实践

### ✅ 测试编写原则

1. **独立性**：每个测试用例独立，不依赖其他测试
2. **可重复性**：多次运行结果一致
3. **快速性**：单个测试用例运行时间 < 5秒
4. **明确性**：测试名称和断言清晰明了
5. **覆盖性**：覆盖正常路径和异常路径

### 🔧 性能优化技巧

```cpp
// 使用内存数据库减少IO
DBOptions db_options;
db_options.create_if_missing = true;
db_options.env = Env::Default();  // 或使用 MockEnv

// 使用临时目录
std::string db_path = test::PerThreadDBPath("your_test_db");

// 限制资源使用
WriteOptions write_options;
write_options.disableWAL = true;  // 禁用WAL提高速度
```

### 🚨 常见陷阱避免

1. **避免全局状态**：不要在测试间共享状态
2. **避免硬编码路径**：使用 `test::TmpDir()` 或 `test::PerThreadDBPath()`
3. **避免无限循环**：设置合理的循环上限
4. **避免竞态条件**：使用适当的同步机制
5. **避免平台依赖**：使用跨平台的 RocksDB 接口

## 📋 完整示例

### 📁 文件结构
```
util/
├── new_compression_test.cc    # 新测试文件
├── compression.cc             # 实现文件
└── compression.h              # 头文件
```

### 📝 src.mk 修改
```makefile
TEST_MAIN_SOURCES =                                                     \
  # ... 现有测试 ...
  util/new_compression_test.cc                                         \
  # ... 其他测试 ...
```

### ⚙️ CI 配置修改
```yaml
"util")
  echo "🔧 工具库测试..."
  make DEBUG_LEVEL=1 -j$(nproc) \
    autovector_test \
    new_compression_test \
    bloom_test \
    # ... 其他测试
  
  echo "运行工具库测试..."
  ./autovector_test --gtest_color=no
  ./new_compression_test --gtest_color=no
  ./bloom_test --gtest_color=no --gtest_filter="*Basic*"
  # ... 其他测试执行
  ;;
```

### 🧪 测试文件内容
```cpp
#include <gtest/gtest.h>
#include "util/compression.h"
#include "test_util/testharness.h"
#include "rocksdb/rocksdb_namespace.h"

namespace ROCKSDB_NAMESPACE {

class NewCompressionTest : public testing::Test {};

TEST_F(NewCompressionTest, BasicCompression) {
  std::string input = "Hello RocksDB";
  std::string compressed = Compress(input);
  std::string decompressed = Decompress(compressed);
  EXPECT_EQ(input, decompressed);
}

}  // namespace ROCKSDB_NAMESPACE

int main(int argc, char** argv) {
  ROCKSDB_NAMESPACE::port::InstallStackTraceHandler();
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

## 🎯 总结

添加新单元测试的核心步骤：

1. **选择位置**：根据功能选择合适的目录和套件
2. **修改配置**：编辑 `src.mk` 和 `.github/workflows/ci.yml`
3. **编写测试**：使用标准模板创建测试文件
4. **本地验证**：确保测试可以构建和运行
5. **集成CI**：选择合适的测试套件并优化配置

遵循这些步骤，您就可以成功地向 ST-RocksDB 项目添加新的单元测试！

---

**最后更新**: 2024-06-27 18:00  
**状态**: ✅ 完整指南已就绪，支持所有测试类型 