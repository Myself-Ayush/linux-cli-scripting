#!/bin/bash
# Real World Project: Log Analyzer Script
# Features: Multi-format log parsing, pattern detection, statistics, alerts, reporting

# Configuration
SCRIPT_NAME="Log Analyzer"
VERSION="1.0"
CONFIG_FILE="$HOME/.log_analyzer_config"
OUTPUT_DIR="./log_analysis_reports"
ALERT_THRESHOLD_ERROR=10
ALERT_THRESHOLD_WARN=50

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log patterns for different log types
declare -A LOG_PATTERNS=(
    ["apache"]='^\[([^\]]+)\] \[([^\]]+)\] (.*)$'
    ["nginx"]='([0-9.]+) - - \[([^\]]+)\] "([^"]*)" ([0-9]+) ([0-9]+) "([^"]*)" "([^"]*)"'
    ["syslog"]='([A-Za-z]{3} [0-9 ]{2} [0-9:]{8}) ([^ ]+) ([^:]+): (.*)$'
    ["auth"]='([A-Za-z]{3} [0-9 ]{2} [0-9:]{8}) ([^ ]+) ([^:]+): (.*)$'
    ["generic"]='([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9:]{8}) \[([^\]]+)\] (.*)$'
)

# Common log file locations
declare -A LOG_LOCATIONS=(
    ["apache"]="/var/log/apache2/access.log /var/log/httpd/access_log"
    ["nginx"]="/var/log/nginx/access.log"
    ["syslog"]="/var/log/syslog /var/log/messages"
    ["auth"]="/var/log/auth.log /var/log/secure"
    ["kern"]="/var/log/kern.log"
    ["mail"]="/var/log/mail.log"
    ["cron"]="/var/log/cron.log"
)

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
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
        "DEBUG")
            echo -e "${PURPLE}$log_entry${NC}"
            ;;
    esac
}

# Error handling
error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
    else
        create_default_config
    fi
}

# Create default configuration
create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# Log Analyzer Configuration

# Alert thresholds
ALERT_THRESHOLD_ERROR=10
ALERT_THRESHOLD_WARN=50
ALERT_THRESHOLD_FAILED_LOGIN=5

# Email settings
EMAIL_ENABLED=false
EMAIL_TO="admin@example.com"
SMTP_SERVER="localhost"

# Analysis settings
ANALYZE_LAST_HOURS=24
MAX_LOG_SIZE_MB=100
ENABLE_REAL_TIME=false

# Custom patterns
CUSTOM_ERROR_PATTERNS="fatal|critical|emergency"
CUSTOM_WARN_PATTERNS="warning|deprecated|timeout"
EOF

    log_message "INFO" "Default configuration created: $CONFIG_FILE"
}

# Detect log format
detect_log_format() {
    local log_file="$1"
    local sample_lines=$(head -10 "$log_file")
    
    # Test against known patterns
    for format in "${!LOG_PATTERNS[@]}"; do
        if echo "$sample_lines" | grep -qE "${LOG_PATTERNS[$format]}"; then
            echo "$format"
            return 0
        fi
    done
    
    # Default to generic if no pattern matches
    echo "generic"
}

# Parse log entries
parse_log_entry() {
    local line="$1"
    local format="$2"
    
    case "$format" in
        "apache")
            if [[ $line =~ ^\[([^\]]+)\]\ \[([^\]]+)\]\ (.*)$ ]]; then
                echo "timestamp:${BASH_REMATCH[1]} level:${BASH_REMATCH[2]} message:${BASH_REMATCH[3]}"
            fi
            ;;
        "nginx")
            if [[ $line =~ ([0-9.]+)\ -\ -\ \[([^\]]+)\]\ \"([^\"]*)\"\ ([0-9]+)\ ([0-9]+) ]]; then
                echo "ip:${BASH_REMATCH[1]} timestamp:${BASH_REMATCH[2]} request:${BASH_REMATCH[3]} status:${BASH_REMATCH[4]} size:${BASH_REMATCH[5]}"
            fi
            ;;
        "syslog"|"auth")
            if [[ $line =~ ([A-Za-z]{3}\ [0-9\ ]{2}\ [0-9:]{8})\ ([^\ ]+)\ ([^:]+):\ (.*)$ ]]; then
                echo "timestamp:${BASH_REMATCH[1]} host:${BASH_REMATCH[2]} service:${BASH_REMATCH[3]} message:${BASH_REMATCH[4]}"
            fi
            ;;
        "generic")
            if [[ $line =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9:]{8})\ \[([^\]]+)\]\ (.*)$ ]]; then
                echo "timestamp:${BASH_REMATCH[1]} level:${BASH_REMATCH[2]} message:${BASH_REMATCH[3]}"
            fi
            ;;
    esac
}

# Analyze log statistics
analyze_log_statistics() {
    local log_file="$1"
    local format="$2"
    local output_file="$3"
    
    log_message "INFO" "Analyzing statistics for $log_file"
    
    {
        echo "=== LOG STATISTICS REPORT ==="
        echo "File: $log_file"
        echo "Format: $format"
        echo "Analysis Date: $(date)"
        echo "================================"
        echo ""
        
        # Basic statistics
        local total_lines=$(wc -l < "$log_file")
        local file_size=$(stat -c%s "$log_file" 2>/dev/null || echo "0")
        
        echo "📊 BASIC STATISTICS"
        echo "Total lines: $total_lines"
        echo "File size: $(numfmt --to=iec $file_size)"
        echo ""
        
        # Error analysis
        echo "🚨 ERROR ANALYSIS"
        local error_count=$(grep -ci "error\|fail\|fatal\|critical\|emergency" "$log_file" 2>/dev/null || echo "0")
        local warn_count=$(grep -ci "warn\|warning\|deprecated" "$log_file" 2>/dev/null || echo "0")
        
        echo "Error messages: $error_count"
        echo "Warning messages: $warn_count"
        
        if [[ $error_count -gt $ALERT_THRESHOLD_ERROR ]]; then
            echo "⚠️  HIGH ERROR COUNT DETECTED!"
        fi
        
        echo ""
        
        # Top error messages
        echo "🔍 TOP ERROR PATTERNS"
        grep -i "error\|fail\|fatal" "$log_file" 2>/dev/null | \
            sed 's/.*error[: ]*//i' | \
            sort | uniq -c | sort -nr | head -5
        echo ""
        
        # Time-based analysis
        echo "⏰ TIME-BASED ANALYSIS"
        if [[ "$format" == "syslog" || "$format" == "auth" ]]; then
            echo "Activity by hour:"
            awk '{print $3}' "$log_file" | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
        elif [[ "$format" == "generic" ]]; then
            echo "Activity by hour:"
            awk '{print $2}' "$log_file" | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
        fi
        echo ""
        
        # Service/component analysis
        if [[ "$format" == "syslog" || "$format" == "auth" ]]; then
            echo "🔧 SERVICE ANALYSIS"
            echo "Top services by activity:"
            awk '{print $5}' "$log_file" | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
            echo ""
        fi
        
        # IP analysis for web logs
        if [[ "$format" == "nginx" || "$format" == "apache" ]]; then
            echo "🌐 IP ANALYSIS"
            echo "Top IP addresses:"
            awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | head -10
            echo ""
            
            echo "HTTP status codes:"
            if [[ "$format" == "nginx" ]]; then
                awk '{print $9}' "$log_file" | sort | uniq -c | sort -nr
            fi
            echo ""
        fi
        
        # Security analysis
        echo "🔒 SECURITY ANALYSIS"
        local failed_logins=$(grep -ci "failed\|invalid\|authentication failure" "$log_file" 2>/dev/null || echo "0")
        local sudo_usage=$(grep -ci "sudo" "$log_file" 2>/dev/null || echo "0")
        
        echo "Failed login attempts: $failed_logins"
        echo "Sudo usage: $sudo_usage"
        
        if [[ $failed_logins -gt $ALERT_THRESHOLD_FAILED_LOGIN ]]; then
            echo "⚠️  HIGH FAILED LOGIN COUNT DETECTED!"
        fi
        
        echo ""
        
        # Recent critical events
        echo "🚨 RECENT CRITICAL EVENTS"
        grep -i "critical\|emergency\|fatal" "$log_file" 2>/dev/null | tail -5
        echo ""
        
    } > "$output_file"
    
    log_message "SUCCESS" "Statistics report saved to $output_file"
}

# Real-time log monitoring
monitor_log_realtime() {
    local log_file="$1"
    local pattern="${2:-error|fail|critical}"
    
    log_message "INFO" "Starting real-time monitoring of $log_file"
    log_message "INFO" "Watching for pattern: $pattern"
    log_message "INFO" "Press Ctrl+C to stop"
    
    tail -f "$log_file" | while read -r line; do
        if echo "$line" | grep -qi "$pattern"; then
            local timestamp=$(date '+%H:%M:%S')
            echo -e "${RED}[$timestamp] ALERT: $line${NC}"
            
            # Optional: Send alert notification
            if [[ "$EMAIL_ENABLED" == "true" ]]; then
                echo "Alert from $(hostname): $line" | mail -s "Log Alert" "$EMAIL_TO" 2>/dev/null
            fi
        else
            echo -e "${BLUE}[$timestamp] $line${NC}"
        fi
    done
}

# Generate comprehensive report
generate_comprehensive_report() {
    local log_files=("$@")
    local report_file="$OUTPUT_DIR/comprehensive_report_$(date +%Y%m%d_%H%M%S).html"
    
    mkdir -p "$OUTPUT_DIR"
    
    log_message "INFO" "Generating comprehensive HTML report"
    
    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Log Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #007acc; }
        .error { color: #d32f2f; }
        .warning { color: #f57c00; }
        .success { color: #388e3c; }
        .info { color: #1976d2; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .chart { margin: 20px 0; }
    </style>
</head>
<body>
EOF

    echo "<div class='header'>" >> "$report_file"
    echo "<h1>Log Analysis Report</h1>" >> "$report_file"
    echo "<p>Generated on: $(date)</p>" >> "$report_file"
    echo "<p>Analyzed files: ${#log_files[@]}</p>" >> "$report_file"
    echo "</div>" >> "$report_file"
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            local format=$(detect_log_format "$log_file")
            
            echo "<div class='section'>" >> "$report_file"
            echo "<h2>Analysis: $(basename "$log_file")</h2>" >> "$report_file"
            echo "<p><strong>Format:</strong> $format</p>" >> "$report_file"
            
            # Add statistics
            local temp_stats="/tmp/log_stats_$$.txt"
            analyze_log_statistics "$log_file" "$format" "$temp_stats"
            
            echo "<pre>" >> "$report_file"
            cat "$temp_stats" >> "$report_file"
            echo "</pre>" >> "$report_file"
            echo "</div>" >> "$report_file"
            
            rm -f "$temp_stats"
        fi
    done
    
    echo "</body></html>" >> "$report_file"
    
    log_message "SUCCESS" "Comprehensive report saved to $report_file"
    echo "Report location: $report_file"
}

# Search for specific patterns
search_patterns() {
    local log_file="$1"
    local pattern="$2"
    local context="${3:-0}"
    
    log_message "INFO" "Searching for pattern '$pattern' in $log_file"
    
    if [[ $context -gt 0 ]]; then
        grep -i -C "$context" "$pattern" "$log_file" | while read -r line; do
            if echo "$line" | grep -qi "$pattern"; then
                echo -e "${RED}$line${NC}"
            else
                echo -e "${BLUE}$line${NC}"
            fi
        done
    else
        grep -i --color=always "$pattern" "$log_file"
    fi
}

# Log rotation analysis
analyze_log_rotation() {
    local log_dir="$1"
    
    log_message "INFO" "Analyzing log rotation in $log_dir"
    
    echo "=== LOG ROTATION ANALYSIS ==="
    echo ""
    
    # Find rotated logs
    find "$log_dir" -name "*.log*" -o -name "*.gz" -o -name "*.bz2" | while read -r file; do
        local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        local modified=$(stat -c%y "$file" 2>/dev/null || echo "unknown")
        echo "$(basename "$file"): $(numfmt --to=iec $size) (modified: $modified)"
    done | sort
    
    echo ""
    echo "Total log space usage:"
    du -sh "$log_dir" 2>/dev/null || echo "Cannot access directory"
}

# Interactive menu
show_menu() {
    echo -e "\n${CYAN}=== LOG ANALYZER MENU ===${NC}"
    echo "1. Analyze single log file"
    echo "2. Analyze multiple log files"
    echo "3. Real-time monitoring"
    echo "4. Search for patterns"
    echo "5. Generate comprehensive report"
    echo "6. Analyze log rotation"
    echo "7. Security audit"
    echo "8. Performance analysis"
    echo "9. Configuration"
    echo "0. Exit"
    echo ""
}

# Security audit
security_audit() {
    local log_files=("$@")
    
    log_message "INFO" "Performing security audit"
    
    echo "=== SECURITY AUDIT REPORT ==="
    echo "Generated: $(date)"
    echo "================================"
    echo ""
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            echo "Analyzing: $log_file"
            echo "------------------------"
            
            # Failed login attempts
            local failed_logins=$(grep -ci "failed\|invalid\|authentication failure" "$log_file" 2>/dev/null || echo "0")
            echo "Failed login attempts: $failed_logins"
            
            # Suspicious IP addresses (multiple failed attempts)
            echo "Suspicious IP addresses:"
            grep -i "failed\|invalid" "$log_file" 2>/dev/null | \
                awk '{print $NF}' | sort | uniq -c | sort -nr | head -5
            
            # Privilege escalation
            local sudo_count=$(grep -ci "sudo" "$log_file" 2>/dev/null || echo "0")
            echo "Sudo usage: $sudo_count"
            
            # Root access
            local root_access=$(grep -ci "root" "$log_file" 2>/dev/null || echo "0")
            echo "Root access events: $root_access"
            
            echo ""
        fi
    done
}

# Performance analysis
performance_analysis() {
    local log_file="$1"
    
    log_message "INFO" "Performing performance analysis on $log_file"
    
    echo "=== PERFORMANCE ANALYSIS ==="
    echo "File: $log_file"
    echo "============================="
    echo ""
    
    # Response time analysis for web logs
    if [[ $(detect_log_format "$log_file") == "nginx" ]]; then
        echo "Response time analysis:"
        awk '{print $NF}' "$log_file" | grep -E '^[0-9.]+$' | \
            awk '{sum+=$1; count++} END {print "Average response time: " sum/count "ms"}'
        
        echo ""
        echo "Slow requests (>1000ms):"
        awk '$NF > 1000 {print}' "$log_file" | head -10
    fi
    
    # Error rate analysis
    local total_lines=$(wc -l < "$log_file")
    local error_lines=$(grep -ci "error\|fail" "$log_file" 2>/dev/null || echo "0")
    local error_rate=$(echo "scale=2; $error_lines * 100 / $total_lines" | bc 2>/dev/null || echo "0")
    
    echo "Error rate: $error_rate%"
    
    # Peak activity times
    echo ""
    echo "Peak activity analysis:"
    if [[ $(detect_log_format "$log_file") == "syslog" ]]; then
        awk '{print $3}' "$log_file" | cut -d: -f1 | sort | uniq -c | sort -nr | head -5
    fi
}

# Main execution
main() {
    load_config
    mkdir -p "$OUTPUT_DIR"
    
    if [[ $# -eq 0 ]]; then
        # Interactive mode
        while true; do
            show_menu
            read -p "Select option (0-9): " choice
            
            case $choice in
                1)
                    read -p "Enter log file path: " log_file
                    if [[ -f "$log_file" ]]; then
                        local format=$(detect_log_format "$log_file")
                        local output_file="$OUTPUT_DIR/analysis_$(basename "$log_file")_$(date +%Y%m%d_%H%M%S).txt"
                        analyze_log_statistics "$log_file" "$format" "$output_file"
                        echo "Report saved to: $output_file"
                    else
                        log_message "ERROR" "File not found: $log_file"
                    fi
                    ;;
                2)
                    echo "Enter log file paths (space-separated):"
                    read -a log_files
                    generate_comprehensive_report "${log_files[@]}"
                    ;;
                3)
                    read -p "Enter log file path: " log_file
                    read -p "Enter pattern to watch (default: error|fail|critical): " pattern
                    pattern=${pattern:-"error|fail|critical"}
                    monitor_log_realtime "$log_file" "$pattern"
                    ;;
                4)
                    read -p "Enter log file path: " log_file
                    read -p "Enter search pattern: " pattern
                    read -p "Enter context lines (default: 0): " context
                    context=${context:-0}
                    search_patterns "$log_file" "$pattern" "$context"
                    ;;
                5)
                    echo "Enter log file paths (space-separated):"
                    read -a log_files
                    generate_comprehensive_report "${log_files[@]}"
                    ;;
                6)
                    read -p "Enter log directory path: " log_dir
                    analyze_log_rotation "$log_dir"
                    ;;
                7)
                    echo "Enter log file paths for security audit (space-separated):"
                    read -a log_files
                    security_audit "${log_files[@]}"
                    ;;
                8)
                    read -p "Enter log file path: " log_file
                    performance_analysis "$log_file"
                    ;;
                9)
                    echo "Configuration file: $CONFIG_FILE"
                    echo "Edit this file to customize settings"
                    ;;
                0)
                    log_message "INFO" "Goodbye!"
                    exit 0
                    ;;
                *)
                    log_message "ERROR" "Invalid option"
                    ;;
            esac
            
            echo ""
            read -p "Press Enter to continue..."
        done
    else
        # Command line mode
        case "$1" in
            "analyze")
                if [[ -f "$2" ]]; then
                    local format=$(detect_log_format "$2")
                    local output_file="$OUTPUT_DIR/analysis_$(basename "$2")_$(date +%Y%m%d_%H%M%S).txt"
                    analyze_log_statistics "$2" "$format" "$output_file"
                else
                    error_exit "File not found: $2"
                fi
                ;;
            "monitor")
                monitor_log_realtime "$2" "${3:-error|fail|critical}"
                ;;
            "search")
                search_patterns "$2" "$3" "${4:-0}"
                ;;
            "security")
                shift
                security_audit "$@"
                ;;
            "performance")
                performance_analysis "$2"
                ;;
            "report")
                shift
                generate_comprehensive_report "$@"
                ;;
            *)
                echo "Usage: $0 [analyze|monitor|search|security|performance|report] [options]"
                echo "Or run without arguments for interactive mode"
                exit 1
                ;;
        esac
    fi
}

# Show usage if --help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat << EOF
$SCRIPT_NAME v$VERSION

A comprehensive log analysis tool for system administrators.

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    analyze FILE                 Analyze a single log file
    monitor FILE [PATTERN]       Real-time monitoring with pattern matching
    search FILE PATTERN [CONTEXT] Search for patterns with optional context
    security FILE...             Perform security audit on log files
    performance FILE             Analyze performance metrics
    report FILE...               Generate comprehensive HTML report

Interactive Mode:
    Run without arguments for interactive menu

Examples:
    $0 analyze /var/log/syslog
    $0 monitor /var/log/auth.log "failed"
    $0 search /var/log/apache2/access.log "404" 3
    $0 security /var/log/auth.log /var/log/syslog
    $0 report /var/log/*.log

Configuration:
    Edit $CONFIG_FILE to customize settings

EOF
    exit 0
fi

# Run main function
main "$@" 