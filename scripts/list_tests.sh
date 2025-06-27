#!/bin/bash
# 🧪 ST-RocksDB 测试文件清单生成器

echo "🔍 正在扫描测试文件..."
echo "==============================================="

# 查找所有测试文件
echo ""
echo "📁 测试源文件分布："
echo ""

# Memory tests
echo "🧠 内存管理测试 (memory/):"
find memory/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# Util tests  
echo ""
echo "🔧 基础工具测试 (util/):"
find util/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# DB tests
echo ""
echo "🗄️ 数据库核心测试 (db/):"
find db/ -name "*test.cc" -type f | head -10 | sed 's/^/  ✓ /'
echo "  ... (还有更多DB测试文件)"

# Table tests
echo ""
echo "📊 表格系统测试 (table/):"
find table/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# Cache tests
echo ""
echo "💾 缓存系统测试 (cache/):"
find cache/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# Monitoring tests
echo ""
echo "📈 监控系统测试 (monitoring/):"
find monitoring/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# Env tests
echo ""
echo "🌍 环境抽象测试 (env/):"
find env/ -name "*test.cc" -type f | sed 's/^/  ✓ /' | sort

# Utilities tests
echo ""
echo "🛠️ 工具集测试 (utilities/):"
find utilities/ -name "*test.cc" -type f | head -10 | sed 's/^/  ✓ /'
echo "  ... (还有更多utilities测试文件)"

echo ""
echo "==============================================="
echo ""

# 统计信息
total_tests=$(find . -name "*test.cc" -type f | wc -l)
enabled_tests=20  # 当前启用的测试数量

echo "📊 测试文件统计:"
echo "  总测试文件数: $total_tests"
echo "  已启用测试数: $enabled_tests"
echo "  启用比例: $(echo "scale=1; $enabled_tests * 100 / $total_tests" | bc)%"

echo ""
echo "🎯 当前CI启用的测试文件:"
echo ""

# 已启用的基础测试
echo "✅ Basic套件 (6个):"
echo "  ✓ memory/arena_test.cc"
echo "  ✓ util/coding_test.cc" 
echo "  ✓ util/crc32c_test.cc"
echo "  ✓ util/hash_test.cc"
echo "  ✓ util/random_test.cc"
echo "  ✓ util/slice_test.cc"

echo ""
echo "✅ DB套件 (3个):"
echo "  ✓ db/db_basic_test.cc"
echo "  ✓ db/corruption_test.cc"
echo "  ✓ db/dbformat_test.cc"

echo ""
echo "✅ Util套件 (5个):"
echo "  ✓ util/autovector_test.cc"
echo "  ✓ util/bloom_test.cc"
echo "  ✓ util/dynamic_bloom_test.cc"
echo "  ✓ util/thread_local_test.cc"
echo "  ✓ util/work_queue_test.cc"

echo ""
echo "✅ Table套件 (4个):"
echo "  ✓ table/table_test.cc"
echo "  ✓ table/block_test.cc"
echo "  ✓ table/merger_test.cc"
echo "  ✓ table/block_fetcher_test.cc"

echo ""
echo "✅ Cache套件 (2个):"
echo "  ✓ cache/cache_test.cc"
echo "  ✓ monitoring/histogram_test.cc"

echo ""
echo "==============================================="
echo "📖 详细文档: 查看 TESTING_GUIDE.md"
echo "🚀 快速测试: ./scripts/local_build_test.sh"
echo "⚙️ CI配置: .github/workflows/ci.yml"
echo "===============================================" 