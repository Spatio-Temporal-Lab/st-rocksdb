# 🚀 新测试快速参考卡片

## 🎯 添加新测试的5个步骤

### 1️⃣ **选择位置**
```bash
# 根据功能选择目录
util/          # 基础工具 → basic/util 套件
db/            # 数据库核心 → db 套件
cache/         # 缓存系统 → cache 套件
table/         # 表格系统 → table 套件
utilities/     # 高级工具 → 各种套件
```

### 2️⃣ **修改 src.mk**
```makefile
# 在 TEST_MAIN_SOURCES 中添加
TEST_MAIN_SOURCES = \
  # ... 现有测试 ...
  util/your_new_test.cc \    # 👈 在这里添加
  # ... 其他测试 ...
```

### 3️⃣ **修改 CI 配置**
```yaml
# 编辑 .github/workflows/ci.yml
"util")
  # 构建部分添加
  make DEBUG_LEVEL=1 -j$(nproc) \
    your_new_test \           # 👈 构建目标
    
  # 执行部分添加  
  ./your_new_test --gtest_color=no   # 👈 运行命令
  ;;
```

### 4️⃣ **创建测试文件**
```cpp
// util/your_new_test.cc
#include <gtest/gtest.h>
#include "rocksdb/rocksdb_namespace.h"
#include "test_util/testharness.h"

namespace ROCKSDB_NAMESPACE {

class YourNewTest : public testing::Test {};

TEST_F(YourNewTest, BasicTest) {
  // 您的测试逻辑
  EXPECT_TRUE(true);
}

}  // namespace ROCKSDB_NAMESPACE

int main(int argc, char** argv) {
  ROCKSDB_NAMESPACE::port::InstallStackTraceHandler();
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

### 5️⃣ **本地验证**
```bash
# 构建和运行
make DEBUG_LEVEL=1 librocksdb_test_debug.so
make DEBUG_LEVEL=1 your_new_test
./your_new_test
```

## 📊 测试套件选择

| 套件 | 目录 | 特点 | 时间限制 |
|------|------|------|----------|
| `basic` | memory/, util/ | 稳定快速 | < 3分钟 |
| `util` | util/ | 工具函数 | < 4分钟 |
| `db` | db/ | 数据库核心 | < 8分钟 |
| `table` | table/ | 表格处理 | < 6分钟 |
| `cache` | cache/, monitoring/ | 缓存监控 | < 5分钟 |

## 🔧 常用命令

```bash
# 列出所有测试
./scripts/list_tests.sh

# 构建特定测试
make DEBUG_LEVEL=1 your_test_name

# 运行测试（各种模式）
./your_test --gtest_list_tests                    # 列出测试用例
./your_test --gtest_filter="*Basic*"              # 过滤运行
./your_test --gtest_color=no                      # 禁用彩色输出
./your_test --gtest_repeat=3                      # 重复运行

# 本地测试完整流程
./scripts/local_build_test.sh
```

## ⚠️ 重要提醒

- ✅ **必须修改** `src.mk` 文件
- ✅ **必须修改** `.github/workflows/ci.yml` 文件  
- ✅ **测试文件命名** 必须以 `_test.cc` 结尾
- ✅ **目录选择** 要与测试内容匹配
- ✅ **本地验证** 确保测试可以运行

## 📖 详细文档

- 📚 完整指南: `UNIT_TEST_CREATION_GUIDE.md`
- 🧪 测试框架: `TESTING_GUIDE.md`
- 📁 测试目录: `./scripts/list_tests.sh` 