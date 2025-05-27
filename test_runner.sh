#!/bin/bash
# Test Runner for Linux CLI Scripting Project
# Runs all scripts and validates their functionality

# Configuration
SCRIPT_NAME="Linux CLI Scripting Test Runner"
VERSION="1.0"
LOG_FILE="test_results.log"
TIMEOUT=30  # seconds for each test

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    echo -e "$log_entry" | tee -a "$LOG_FILE"
    
    # Color output for terminal
    case $level in
        "ERROR")
            echo -e "${RED}$log_entry${NC}" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}$log_entry${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}$log_entry${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}$log_entry${NC}"
            ;;
        "TEST")
            echo -e "${PURPLE}$log_entry${NC}"
            ;;
    esac
}

# Test execution function
run_test() {
    local test_name="$1"
    local test_script="$2"
    local expected_exit_code="${3:-0}"
    
    ((TOTAL_TESTS++))
    
    log_message "TEST" "Running test: $test_name"
    log_message "INFO" "Script: $test_script"
    
    if [[ ! -f "$test_script" ]]; then
        log_message "ERROR" "Test script not found: $test_script"
        ((FAILED_TESTS++))
        return 1
    fi
    
    if [[ ! -x "$test_script" ]]; then
        log_message "WARN" "Making script executable: $test_script"
        chmod +x "$test_script"
    fi
    
    # Run the test with timeout
    local start_time=$(date +%s)
    timeout $TIMEOUT bash "$test_script" >/dev/null 2>&1
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Check results
    if [[ $exit_code -eq 124 ]]; then
        log_message "ERROR" "Test timed out after ${TIMEOUT}s: $test_name"
        ((FAILED_TESTS++))
        return 1
    elif [[ $exit_code -eq $expected_exit_code ]]; then
        log_message "SUCCESS" "Test passed (${duration}s): $test_name"
        ((PASSED_TESTS++))
        return 0
    else
        log_message "ERROR" "Test failed (exit code: $exit_code, expected: $expected_exit_code): $test_name"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Interactive test function
run_interactive_test() {
    local test_name="$1"
    local test_script="$2"
    
    ((TOTAL_TESTS++))
    
    log_message "TEST" "Interactive test: $test_name"
    log_message "INFO" "Script: $test_script"
    
    if [[ ! -f "$test_script" ]]; then
        log_message "ERROR" "Test script not found: $test_script"
        ((FAILED_TESTS++))
        return 1
    fi
    
    echo -e "${CYAN}Running interactive test: $test_name${NC}"
    echo -e "${YELLOW}Press Enter to continue, 's' to skip, or 'q' to quit...${NC}"
    read -r response
    
    case $response in
        "s"|"S")
            log_message "WARN" "Test skipped: $test_name"
            ((SKIPPED_TESTS++))
            return 0
            ;;
        "q"|"Q")
            log_message "INFO" "Testing stopped by user"
            exit 0
            ;;
        *)
            echo -e "${CYAN}Running: $test_script${NC}"
            if bash "$test_script"; then
                log_message "SUCCESS" "Interactive test completed: $test_name"
                ((PASSED_TESTS++))
                return 0
            else
                log_message "ERROR" "Interactive test failed: $test_name"
                ((FAILED_TESTS++))
                return 1
            fi
            ;;
    esac
}

# Syntax check function
check_syntax() {
    local script="$1"
    local script_name=$(basename "$script")
    
    log_message "INFO" "Checking syntax: $script_name"
    
    if bash -n "$script" 2>/dev/null; then
        log_message "SUCCESS" "Syntax OK: $script_name"
        return 0
    else
        log_message "ERROR" "Syntax error in: $script_name"
        return 1
    fi
}

# Test basic scripts
test_basic_scripts() {
    echo -e "\n${CYAN}=== Testing Basic Scripts ===${NC}"
    
    run_test "Variables Script" "practical learning/01_variables.sh"
    run_test "Conditionals Script" "practical learning/02_conditionals.sh"
    run_test "Loops Script" "practical learning/03_loops.sh"
    run_test "Functions Script" "practical learning/04_functions.sh"
    run_test "Arrays Script" "practical learning/05_arrays.sh"
}

# Test file operations
test_file_operations() {
    echo -e "\n${CYAN}=== Testing File Operations ===${NC}"
    
    run_test "Basic File Operations" "file_operations/01_basic_file_ops.sh"
    run_test "Directory Operations" "file_operations/02_directory_ops.sh"
    run_test "Text Processing" "file_operations/03_text_processing.sh"
    run_test "Permissions and Monitoring" "file_operations/04_permissions_monitoring.sh"
}

# Test advanced concepts
test_advanced_concepts() {
    echo -e "\n${CYAN}=== Testing Advanced Concepts ===${NC}"
    
    run_test "Command Arguments" "advanced_concepts/01_command_args.sh"
    run_test "Error Handling" "advanced_concepts/02_error_handling.sh"
    run_test "Process Management" "advanced_concepts/03_process_management.sh"
    run_test "Networking" "advanced_concepts/04_networking.sh"
}

# Test system administration
test_system_admin() {
    echo -e "\n${CYAN}=== Testing System Administration ===${NC}"
    
    run_test "System Monitor" "system_admin/system_monitor.sh"
    run_test "Distro Detector" "system_admin/distro_detector.sh"
}

# Test real world projects
test_real_world_projects() {
    echo -e "\n${CYAN}=== Testing Real World Projects ===${NC}"
    
    # These might need special handling or user interaction
    run_interactive_test "File Organizer" "real_world_projects/file_organizer.sh"
    
    # Test backup script with test command
    if [[ -f "real_world_projects/system_backup.sh" ]]; then
        log_message "TEST" "Testing backup script configuration"
        if timeout 10 bash "real_world_projects/system_backup.sh" test >/dev/null 2>&1; then
            log_message "SUCCESS" "Backup script test passed"
            ((PASSED_TESTS++))
        else
            log_message "ERROR" "Backup script test failed"
            ((FAILED_TESTS++))
        fi
        ((TOTAL_TESTS++))
    fi
}

# Syntax check all scripts
syntax_check_all() {
    echo -e "\n${CYAN}=== Syntax Checking All Scripts ===${NC}"
    
    local syntax_errors=0
    
    # Find all shell scripts
    while IFS= read -r -d '' script; do
        if ! check_syntax "$script"; then
            ((syntax_errors++))
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    if [[ $syntax_errors -eq 0 ]]; then
        log_message "SUCCESS" "All scripts have valid syntax"
    else
        log_message "ERROR" "$syntax_errors scripts have syntax errors"
    fi
    
    return $syntax_errors
}

# Performance test
performance_test() {
    echo -e "\n${CYAN}=== Performance Testing ===${NC}"
    
    # Test a simple script multiple times
    local test_script="practical learning/01_variables.sh"
    local iterations=5
    
    if [[ -f "$test_script" ]]; then
        log_message "INFO" "Running performance test ($iterations iterations)"
        
        local total_time=0
        for ((i=1; i<=iterations; i++)); do
            local start_time=$(date +%s.%N)
            timeout 10 bash "$test_script" >/dev/null 2>&1
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "1")
            total_time=$(echo "$total_time + $duration" | bc 2>/dev/null || echo "$total_time")
            log_message "INFO" "Iteration $i: ${duration}s"
        done
        
        local avg_time=$(echo "scale=3; $total_time / $iterations" | bc 2>/dev/null || echo "N/A")
        log_message "SUCCESS" "Average execution time: ${avg_time}s"
    fi
}

# Generate test report
generate_report() {
    echo -e "\n${CYAN}=== Test Report ===${NC}"
    
    local pass_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_rate=$(echo "scale=1; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc 2>/dev/null || echo "0")
    fi
    
    cat << EOF

╔══════════════════════════════════════╗
║           TEST SUMMARY               ║
╠══════════════════════════════════════╣
║ Total Tests:    $(printf "%3d" $TOTAL_TESTS)                  ║
║ Passed:         $(printf "%3d" $PASSED_TESTS) (${pass_rate}%)           ║
║ Failed:         $(printf "%3d" $FAILED_TESTS)                  ║
║ Skipped:        $(printf "%3d" $SKIPPED_TESTS)                  ║
╚══════════════════════════════════════╝

EOF

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! 🎉${NC}"
    else
        echo -e "${RED}❌ Some tests failed. Check the log for details.${NC}"
    fi
    
    echo -e "\nDetailed log: $LOG_FILE"
}

# Environment check
check_environment() {
    echo -e "\n${CYAN}=== Environment Check ===${NC}"
    
    log_message "INFO" "Checking environment..."
    log_message "INFO" "OS: $(uname -s) $(uname -r)"
    log_message "INFO" "Shell: $SHELL"
    log_message "INFO" "Bash version: $BASH_VERSION"
    log_message "INFO" "User: $(whoami)"
    log_message "INFO" "Working directory: $(pwd)"
    
    # Check required commands
    local required_commands=("bash" "find" "grep" "awk" "sed" "sort" "uniq")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -eq 0 ]]; then
        log_message "SUCCESS" "All required commands are available"
    else
        log_message "ERROR" "Missing commands: ${missing_commands[*]}"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

Usage: $0 [OPTIONS] [TEST_CATEGORY]

Test Categories:
    all                Run all tests (default)
    basic             Run basic script tests
    file              Run file operation tests
    advanced          Run advanced concept tests
    system            Run system administration tests
    projects          Run real world project tests
    syntax            Run syntax checks only
    performance       Run performance tests

Options:
    -h, --help        Show this help message
    -v, --verbose     Enable verbose output
    -i, --interactive Enable interactive mode for all tests
    -t, --timeout N   Set timeout for tests (default: 30s)
    -l, --log FILE    Set log file (default: test_results.log)

Examples:
    $0                    # Run all tests
    $0 basic             # Run only basic tests
    $0 -i projects       # Run project tests interactively
    $0 -t 60 advanced    # Run advanced tests with 60s timeout

EOF
}

# Parse command line arguments
parse_arguments() {
    INTERACTIVE_MODE=false
    TEST_CATEGORY="all"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -i|--interactive)
                INTERACTIVE_MODE=true
                shift
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            all|basic|file|advanced|system|projects|syntax|performance)
                TEST_CATEGORY="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main execution
main() {
    # Initialize log file
    echo "Test run started at $(date)" > "$LOG_FILE"
    
    echo -e "${PURPLE}$SCRIPT_NAME v$VERSION${NC}"
    echo -e "${BLUE}Starting test execution...${NC}\n"
    
    # Check environment
    if ! check_environment; then
        log_message "ERROR" "Environment check failed"
        exit 1
    fi
    
    # Run syntax check first
    if ! syntax_check_all; then
        log_message "ERROR" "Syntax errors found. Fix them before running tests."
        exit 1
    fi
    
    # Run tests based on category
    case "$TEST_CATEGORY" in
        "all")
            test_basic_scripts
            test_file_operations
            test_advanced_concepts
            test_system_admin
            test_real_world_projects
            performance_test
            ;;
        "basic")
            test_basic_scripts
            ;;
        "file")
            test_file_operations
            ;;
        "advanced")
            test_advanced_concepts
            ;;
        "system")
            test_system_admin
            ;;
        "projects")
            test_real_world_projects
            ;;
        "syntax")
            # Already done above
            ;;
        "performance")
            performance_test
            ;;
    esac
    
    # Generate final report
    generate_report
    
    # Exit with appropriate code
    if [[ $FAILED_TESTS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Parse arguments and run
parse_arguments "$@"
main 