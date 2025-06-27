#!/bin/bash
# RocksDB 单元测试运行脚本
# 提供本地开发和 CI/CD 环境的完整测试覆盖

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 默认参数
BUILD_TYPE="Debug"
TEST_SUITE="all"
PARALLEL_JOBS=$(nproc 2>/dev/null || echo "4")
TIMEOUT_SECONDS=300
ENABLE_ASAN=false
SKIP_BUILD=false

# 使用说明
usage() {
    cat << EOF
用法: $0 [选项]

选项:
    -t, --type TYPE         构建类型 (Debug|Release) [默认: Debug]
    -s, --suite SUITE       测试套件 (all|basic|db|util|table|cache|integration) [默认: all]
    -j, --jobs N            并行任务数 [默认: $PARALLEL_JOBS]
    -T, --timeout SECONDS   测试超时时间 [默认: $TIMEOUT_SECONDS]
    -a, --asan             启用 AddressSanitizer
    --skip-build           跳过构建，直接运行测试
    -h, --help             显示此帮助信息

测试套件说明:
    basic       - 基础功能测试 (C API, 内存, 编码等)
    db          - 数据库核心测试 (CRUD, 事务, 版本控制等)
    util        - 工具函数测试 (线程, 队列, 统计等)
    table       - 表格式测试 (块, 合并, 索引等)
    cache       - 缓存测试 (LRU, 分片缓存等)
    integration - 集成测试 (压缩, 外部文件等)
    all         - 运行所有测试

示例:
    $0                              # 运行所有测试
    $0 -s basic -t Release          # 运行基础测试，Release 构建
    $0 -s db -a                     # 运行数据库测试，启用 AddressSanitizer
    $0 --skip-build -s util         # 跳过构建，只运行工具测试
EOF
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -s|--suite)
            TEST_SUITE="$2"
            shift 2
            ;;
        -j|--jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        -T|--timeout)
            TIMEOUT_SECONDS="$2"
            shift 2
            ;;
        -a|--asan)
            ENABLE_ASAN=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            usage
            exit 1
            ;;
    esac
done

# 验证参数
if [[ "$BUILD_TYPE" != "Debug" && "$BUILD_TYPE" != "Release" ]]; then
    log_error "无效的构建类型: $BUILD_TYPE"
    exit 1
fi

if [[ ! "$TEST_SUITE" =~ ^(all|basic|db|util|table|cache|integration)$ ]]; then
    log_error "无效的测试套件: $TEST_SUITE"
    exit 1
fi

# 切换到项目根目录
cd "$PROJECT_ROOT"

log_info "RocksDB 单元测试开始"
log_info "构建类型: $BUILD_TYPE"
log_info "测试套件: $TEST_SUITE"
log_info "并行任务: $PARALLEL_JOBS"
log_info "AddressSanitizer: $($ENABLE_ASAN && echo "启用" || echo "禁用")"

# macOS 特定检查
if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v gtimeout >/dev/null 2>&1; then
        log_warning "⚠️ macOS 系统缺少 gtimeout 工具"
        log_warning "建议安装: brew install coreutils"
        log_warning "或运行: ./scripts/check_macos_deps.sh"
        echo
    fi
fi

# 设置环境变量
export GTEST_THROW_ON_FAILURE=1
export GTEST_HAS_EXCEPTIONS=1

if [[ "$ENABLE_ASAN" == "true" ]]; then
    export ASAN_OPTIONS="detect_leaks=1:abort_on_error=1"
    log_info "AddressSanitizer 配置: $ASAN_OPTIONS"
fi

# 跨平台超时函数
run_with_timeout() {
    local timeout_seconds=$1
    shift
    local command=("$@")
    
    if command -v timeout >/dev/null 2>&1; then
        # Linux 系统使用 timeout 命令
        timeout "$timeout_seconds" "${command[@]}"
    elif command -v gtimeout >/dev/null 2>&1; then
        # macOS 使用 gtimeout (brew install coreutils)
        gtimeout "$timeout_seconds" "${command[@]}"
    else
        # 没有超时工具，直接运行
        log_warning "⚠️ 没有找到超时工具，直接运行命令 (无超时保护)"
        "${command[@]}"
    fi
}

# 构建测试基础设施
build_test_infrastructure() {
    if [[ "$SKIP_BUILD" == "true" ]]; then
        log_info "跳过构建步骤"
        return 0
    fi

    log_info "构建测试基础设施..."
    
    local debug_level=1
    if [[ "$BUILD_TYPE" == "Release" ]]; then
        debug_level=0
    fi

    local build_cmd="make DEBUG_LEVEL=$debug_level LIB_MODE=shared -j$PARALLEL_JOBS"
    
    if [[ "$ENABLE_ASAN" == "true" ]]; then
        build_cmd="COMPILE_WITH_ASAN=1 $build_cmd"
    fi

    # 先清理
    log_info "清理之前的构建..."
    make clean

    # 构建核心库
    log_info "构建 RocksDB 库..."
    eval "$build_cmd librocksdb.so librocksdb_test.so"
    
    log_success "测试基础设施构建完成"
}

# 运行基础测试
run_basic_tests() {
    log_info "🔬 运行基础功能测试..."
    
    local tests=(
        "c_test"
        "arena_test" 
        "autovector_test"
        "bloom_test"
        "coding_test"
        "crc32c_test"
        "hash_test"
        "random_test"
        "slice_test"
        "slice_transform_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 运行数据库测试
run_db_tests() {
    log_info "🗄️ 运行数据库核心测试..."
    
    local tests=(
        "db_basic_test"
        "db_test"
        "dbformat_test"
        "corruption_test"
        "version_edit_test"
        "version_set_test"
        "write_batch_test"
        "log_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 运行工具测试
run_util_tests() {
    log_info "🔧 运行工具函数测试..."
    
    local tests=(
        "thread_local_test"
        "work_queue_test"
        "histogram_test"
        "dynamic_bloom_test"
        "timer_test"
        "thread_list_test"
        "repeatable_thread_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 运行表格测试
run_table_tests() {
    log_info "📊 运行表格式测试..."
    
    local tests=(
        "table_test"
        "block_test"
        "merger_test"
        "block_fetcher_test"
        "cleanable_test"
        "sst_file_reader_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 运行缓存测试
run_cache_tests() {
    log_info "💾 运行缓存测试..."
    
    local tests=(
        "cache_test"
        "lru_cache_test"
        "cache_reservation_manager_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 运行集成测试
run_integration_tests() {
    log_info "🔗 运行集成测试..."
    
    local tests=(
        "db_compaction_test"
        "external_sst_file_test"
        "manual_compaction_test" 
        "import_column_family_test"
        "flush_job_test"
    )
    
    build_and_run_tests "${tests[@]}"
}

# 构建并运行测试
build_and_run_tests() {
    local tests=("$@")
    local debug_level=1
    
    if [[ "$BUILD_TYPE" == "Release" ]]; then
        debug_level=0
    fi
    
    local build_cmd="make DEBUG_LEVEL=$debug_level -j$PARALLEL_JOBS"
    
    if [[ "$ENABLE_ASAN" == "true" ]]; then
        build_cmd="COMPILE_WITH_ASAN=1 $build_cmd"
    fi

    # 构建测试可执行文件
    log_info "构建测试可执行文件..."
    if ! eval "$build_cmd ${tests[*]}"; then
        log_error "构建测试失败"
        return 1
    fi
    
    # 运行测试
    local passed=0
    local failed=0
    local failed_tests=()
    
    for test in "${tests[@]}"; do
        if [[ -x "./$test" ]]; then
            log_info "运行测试: $test"
            
            # 根据测试类型设置过滤器
            local filter=""
            case $test in
                *basic*|*c_test*)
                    filter="--gtest_filter=*Basic*:*Simple*"
                    ;;
                *bloom*|*cache*)
                    filter="--gtest_filter=*Basic*"
                    ;;
                *db_test*)
                    filter="--gtest_filter=*Basic*:*Put*:*Get*:*Delete*"
                    ;;
                *compaction*)
                    filter="--gtest_filter=*Basic*:*Simple*"
                    ;;
            esac
            
            if run_with_timeout "$TIMEOUT_SECONDS" "./$test" $filter; then
                log_success "✅ $test 通过"
                ((passed++))
            else
                log_error "❌ $test 失败"
                failed_tests+=("$test")
                ((failed++))
            fi
        else
            log_warning "测试可执行文件不存在: $test"
            ((failed++))
            failed_tests+=("$test")
        fi
    done
    
    # 输出测试结果
    echo
    log_info "测试结果: 通过 $passed, 失败 $failed"
    
    if [[ $failed -gt 0 ]]; then
        log_error "失败的测试:"
        for test in "${failed_tests[@]}"; do
            echo "  - $test"
        done
        return 1
    fi
    
    return 0
}

# 运行所有测试
run_all_tests() {
    log_info "🚀 运行所有测试套件..."
    
    local overall_result=0
    
    if ! run_basic_tests; then
        log_error "基础测试失败"
        overall_result=1
    fi
    
    if ! run_util_tests; then
        log_error "工具测试失败"
        overall_result=1
    fi
    
    if ! run_cache_tests; then
        log_error "缓存测试失败"
        overall_result=1
    fi
    
    if ! run_table_tests; then
        log_error "表格测试失败"
        overall_result=1
    fi
    
    # 数据库和集成测试较重，只在非 CI 环境或明确指定时运行
    if [[ "${CI:-false}" != "true" || "$TEST_SUITE" == "all" ]]; then
        if ! run_db_tests; then
            log_error "数据库测试失败"
            overall_result=1
        fi
        
        if ! run_integration_tests; then
            log_error "集成测试失败"
            overall_result=1
        fi
    else
        log_info "跳过重型测试 (CI 环境)"
    fi
    
    return $overall_result
}

# 主逻辑
main() {
    # 构建测试基础设施
    if ! build_test_infrastructure; then
        log_error "构建失败"
        exit 1
    fi
    
    # 运行指定的测试套件
    case "$TEST_SUITE" in
        "basic")
            run_basic_tests
            ;;
        "db")
            run_db_tests
            ;;
        "util")
            run_util_tests
            ;;
        "table")
            run_table_tests
            ;;
        "cache")
            run_cache_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "all")
            run_all_tests
            ;;
    esac
    
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        log_success "🎉 所有测试通过!"
    else
        log_error "💥 测试失败"
    fi
    
    exit $result
}

# 错误处理
trap 'log_error "脚本异常退出"; exit 1' ERR

# 运行主函数
main "$@" 