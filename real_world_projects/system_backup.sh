#!/bin/bash
# Real World Project: System Backup Automation Script
# Features: Full/Incremental backups, compression, rotation, logging, email notifications

# Configuration
SCRIPT_NAME="System Backup"
VERSION="1.0"
CONFIG_FILE="$HOME/.backup_config"
LOG_FILE="/var/log/backup.log"
BACKUP_BASE_DIR="/backup"
MAX_BACKUP_AGE=30  # days
COMPRESSION_LEVEL=6

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    esac
}

# Error handling
error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

# Check if running as root for system backups
check_permissions() {
    if [[ $EUID -ne 0 ]] && [[ "$BACKUP_TYPE" == "system" ]]; then
        error_exit "System backup requires root privileges. Use sudo."
    fi
}

# Create backup directory structure
setup_backup_dirs() {
    local backup_dir="$1"
    
    log_message "INFO" "Setting up backup directory structure"
    
    mkdir -p "$backup_dir"/{full,incremental,logs,temp} || error_exit "Failed to create backup directories"
    
    # Set appropriate permissions
    chmod 755 "$backup_dir"
    chmod 700 "$backup_dir"/{full,incremental,temp}
    
    log_message "SUCCESS" "Backup directory structure created: $backup_dir"
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
    else
        log_message "WARN" "No configuration file found. Using defaults."
        create_default_config
    fi
}

# Create default configuration
create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# Backup Configuration File

# Backup directories (space-separated)
BACKUP_SOURCES="/home /etc /var/log"

# Exclude patterns (space-separated)
BACKUP_EXCLUDES="*.tmp *.cache *.log /home/*/.cache /home/*/Downloads"

# Email settings
EMAIL_ENABLED=false
EMAIL_TO="admin@example.com"
EMAIL_FROM="backup@$(hostname)"

# Retention settings
FULL_BACKUP_RETENTION=7    # Keep 7 full backups
INCREMENTAL_RETENTION=30   # Keep 30 days of incrementals

# Compression settings
USE_COMPRESSION=true
COMPRESSION_TYPE="gzip"    # gzip, bzip2, xz

# Database backup settings
BACKUP_DATABASES=false
DB_USER="backup_user"
DB_PASSWORD=""
DATABASES="database1 database2"
EOF

    log_message "INFO" "Default configuration created: $CONFIG_FILE"
}

# Get backup size estimation
estimate_backup_size() {
    local sources="$1"
    local total_size=0
    
    log_message "INFO" "Estimating backup size..."
    
    for source in $sources; do
        if [[ -d "$source" ]]; then
            local size=$(du -sb "$source" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
            log_message "INFO" "Source $source: $(numfmt --to=iec $size)"
        fi
    done
    
    log_message "INFO" "Total estimated size: $(numfmt --to=iec $total_size)"
    echo $total_size
}

# Check available disk space
check_disk_space() {
    local backup_dir="$1"
    local required_space="$2"
    
    local available_space=$(df -B1 "$backup_dir" | awk 'NR==2 {print $4}')
    local required_with_margin=$((required_space * 120 / 100))  # 20% margin
    
    if [[ $available_space -lt $required_with_margin ]]; then
        error_exit "Insufficient disk space. Required: $(numfmt --to=iec $required_with_margin), Available: $(numfmt --to=iec $available_space)"
    fi
    
    log_message "SUCCESS" "Disk space check passed. Available: $(numfmt --to=iec $available_space)"
}

# Create full backup
create_full_backup() {
    local backup_dir="$1"
    local sources="$2"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$backup_dir/full/full_backup_$timestamp.tar"
    
    log_message "INFO" "Starting full backup"
    
    # Build exclude options
    local exclude_opts=""
    for pattern in $BACKUP_EXCLUDES; do
        exclude_opts="$exclude_opts --exclude=$pattern"
    done
    
    # Create backup
    if tar $exclude_opts -cf "$backup_file" $sources 2>/dev/null; then
        log_message "SUCCESS" "Full backup created: $backup_file"
        
        # Compress if enabled
        if [[ "$USE_COMPRESSION" == "true" ]]; then
            compress_backup "$backup_file"
        fi
        
        # Create checksum
        create_checksum "$backup_file"
        
        echo "$backup_file"
    else
        error_exit "Failed to create full backup"
    fi
}

# Create incremental backup
create_incremental_backup() {
    local backup_dir="$1"
    local sources="$2"
    local reference_file="$3"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$backup_dir/incremental/incremental_backup_$timestamp.tar"
    
    log_message "INFO" "Starting incremental backup"
    
    # Build exclude options
    local exclude_opts=""
    for pattern in $BACKUP_EXCLUDES; do
        exclude_opts="$exclude_opts --exclude=$pattern"
    done
    
    # Create incremental backup
    if tar $exclude_opts --newer-mtime="$reference_file" -cf "$backup_file" $sources 2>/dev/null; then
        log_message "SUCCESS" "Incremental backup created: $backup_file"
        
        # Compress if enabled
        if [[ "$USE_COMPRESSION" == "true" ]]; then
            compress_backup "$backup_file"
        fi
        
        # Create checksum
        create_checksum "$backup_file"
        
        echo "$backup_file"
    else
        error_exit "Failed to create incremental backup"
    fi
}

# Compress backup
compress_backup() {
    local backup_file="$1"
    
    log_message "INFO" "Compressing backup: $backup_file"
    
    case "$COMPRESSION_TYPE" in
        "gzip")
            gzip -$COMPRESSION_LEVEL "$backup_file" && backup_file="${backup_file}.gz"
            ;;
        "bzip2")
            bzip2 -$COMPRESSION_LEVEL "$backup_file" && backup_file="${backup_file}.bz2"
            ;;
        "xz")
            xz -$COMPRESSION_LEVEL "$backup_file" && backup_file="${backup_file}.xz"
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        log_message "SUCCESS" "Backup compressed: $backup_file"
    else
        log_message "ERROR" "Failed to compress backup"
    fi
}

# Create checksum
create_checksum() {
    local backup_file="$1"
    local checksum_file="${backup_file}.sha256"
    
    if sha256sum "$backup_file" > "$checksum_file"; then
        log_message "INFO" "Checksum created: $checksum_file"
    else
        log_message "WARN" "Failed to create checksum"
    fi
}

# Verify backup integrity
verify_backup() {
    local backup_file="$1"
    local checksum_file="${backup_file}.sha256"
    
    if [[ -f "$checksum_file" ]]; then
        if sha256sum -c "$checksum_file" >/dev/null 2>&1; then
            log_message "SUCCESS" "Backup integrity verified: $backup_file"
            return 0
        else
            log_message "ERROR" "Backup integrity check failed: $backup_file"
            return 1
        fi
    else
        log_message "WARN" "No checksum file found for: $backup_file"
        return 1
    fi
}

# Database backup
backup_databases() {
    local backup_dir="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    
    if [[ "$BACKUP_DATABASES" != "true" ]]; then
        return 0
    fi
    
    log_message "INFO" "Starting database backup"
    
    for db in $DATABASES; do
        local db_backup_file="$backup_dir/full/db_${db}_$timestamp.sql"
        
        if mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$db" > "$db_backup_file" 2>/dev/null; then
            log_message "SUCCESS" "Database backup created: $db_backup_file"
            
            # Compress database backup
            if [[ "$USE_COMPRESSION" == "true" ]]; then
                gzip "$db_backup_file"
            fi
        else
            log_message "ERROR" "Failed to backup database: $db"
        fi
    done
}

# Cleanup old backups
cleanup_old_backups() {
    local backup_dir="$1"
    
    log_message "INFO" "Cleaning up old backups"
    
    # Remove old full backups
    find "$backup_dir/full" -name "full_backup_*" -mtime +$FULL_BACKUP_RETENTION -delete 2>/dev/null
    find "$backup_dir/full" -name "db_*" -mtime +$FULL_BACKUP_RETENTION -delete 2>/dev/null
    
    # Remove old incremental backups
    find "$backup_dir/incremental" -name "incremental_backup_*" -mtime +$INCREMENTAL_RETENTION -delete 2>/dev/null
    
    # Remove old checksums
    find "$backup_dir" -name "*.sha256" -mtime +$MAX_BACKUP_AGE -delete 2>/dev/null
    
    log_message "SUCCESS" "Old backup cleanup completed"
}

# Send email notification
send_email_notification() {
    local subject="$1"
    local message="$2"
    
    if [[ "$EMAIL_ENABLED" != "true" ]]; then
        return 0
    fi
    
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" -r "$EMAIL_FROM" "$EMAIL_TO"
        log_message "INFO" "Email notification sent to $EMAIL_TO"
    else
        log_message "WARN" "Mail command not available. Cannot send email notification."
    fi
}

# Generate backup report
generate_backup_report() {
    local backup_file="$1"
    local backup_type="$2"
    local start_time="$3"
    local end_time="$4"
    
    local duration=$((end_time - start_time))
    local backup_size=$(stat -c%s "$backup_file" 2>/dev/null || echo "0")
    
    cat << EOF
=== Backup Report ===
Backup Type: $backup_type
Backup File: $backup_file
Backup Size: $(numfmt --to=iec $backup_size)
Duration: ${duration}s
Start Time: $(date -d @$start_time)
End Time: $(date -d @$end_time)
Status: SUCCESS
EOF
}

# List available backups
list_backups() {
    local backup_dir="$1"
    
    echo "=== Available Backups ==="
    echo ""
    
    echo "Full Backups:"
    find "$backup_dir/full" -name "full_backup_*" -printf "%T@ %Tc %p\n" 2>/dev/null | sort -n | tail -10
    
    echo ""
    echo "Incremental Backups:"
    find "$backup_dir/incremental" -name "incremental_backup_*" -printf "%T@ %Tc %p\n" 2>/dev/null | sort -n | tail -10
    
    echo ""
    echo "Database Backups:"
    find "$backup_dir/full" -name "db_*" -printf "%T@ %Tc %p\n" 2>/dev/null | sort -n | tail -5
}

# Restore backup
restore_backup() {
    local backup_file="$1"
    local restore_dir="$2"
    
    if [[ ! -f "$backup_file" ]]; then
        error_exit "Backup file not found: $backup_file"
    fi
    
    log_message "INFO" "Starting restore from: $backup_file"
    log_message "INFO" "Restore destination: $restore_dir"
    
    # Verify backup integrity first
    if ! verify_backup "$backup_file"; then
        error_exit "Backup integrity check failed. Aborting restore."
    fi
    
    # Create restore directory
    mkdir -p "$restore_dir" || error_exit "Failed to create restore directory"
    
    # Extract backup
    if tar -xf "$backup_file" -C "$restore_dir"; then
        log_message "SUCCESS" "Backup restored successfully to: $restore_dir"
    else
        error_exit "Failed to restore backup"
    fi
}

# Main backup function
perform_backup() {
    local backup_type="$1"
    local backup_dir="$BACKUP_BASE_DIR/$(date '+%Y%m')"
    local start_time=$(date +%s)
    
    log_message "INFO" "Starting $backup_type backup process"
    
    # Setup
    setup_backup_dirs "$backup_dir"
    load_config
    
    # Check permissions
    check_permissions
    
    # Estimate size and check space
    local estimated_size=$(estimate_backup_size "$BACKUP_SOURCES")
    check_disk_space "$backup_dir" "$estimated_size"
    
    # Perform backup based on type
    local backup_file=""
    case "$backup_type" in
        "full")
            backup_file=$(create_full_backup "$backup_dir" "$BACKUP_SOURCES")
            backup_databases "$backup_dir"
            ;;
        "incremental")
            local latest_full=$(find "$BACKUP_BASE_DIR" -name "full_backup_*" -type f | sort | tail -1)
            if [[ -z "$latest_full" ]]; then
                log_message "WARN" "No full backup found. Creating full backup instead."
                backup_file=$(create_full_backup "$backup_dir" "$BACKUP_SOURCES")
            else
                backup_file=$(create_incremental_backup "$backup_dir" "$BACKUP_SOURCES" "$latest_full")
            fi
            ;;
    esac
    
    # Cleanup old backups
    cleanup_old_backups "$backup_dir"
    
    # Generate report
    local end_time=$(date +%s)
    local report=$(generate_backup_report "$backup_file" "$backup_type" "$start_time" "$end_time")
    
    log_message "SUCCESS" "Backup process completed"
    echo "$report"
    
    # Send email notification
    send_email_notification "Backup Completed - $(hostname)" "$report"
}

# Show usage
show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

Usage: $0 [OPTIONS] COMMAND

Commands:
    full                    Create full backup
    incremental            Create incremental backup
    list                   List available backups
    restore FILE DIR       Restore backup to directory
    config                 Show current configuration
    test                   Test backup configuration

Options:
    -h, --help             Show this help message
    -v, --verbose          Enable verbose output
    -c, --config FILE      Use custom configuration file
    -d, --dir DIR          Use custom backup directory

Examples:
    $0 full                           # Create full backup
    $0 incremental                    # Create incremental backup
    $0 list                          # List available backups
    $0 restore /backup/full_backup.tar /tmp/restore
    $0 -c /etc/backup.conf full      # Use custom config

EOF
}

# Parse command line arguments
parse_arguments() {
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
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--dir)
                BACKUP_BASE_DIR="$2"
                shift 2
                ;;
            full|incremental)
                COMMAND="$1"
                shift
                ;;
            list)
                COMMAND="list"
                shift
                ;;
            restore)
                COMMAND="restore"
                RESTORE_FILE="$2"
                RESTORE_DIR="$3"
                shift 3
                ;;
            config)
                COMMAND="config"
                shift
                ;;
            test)
                COMMAND="test"
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

# Test configuration
test_configuration() {
    log_message "INFO" "Testing backup configuration"
    
    load_config
    
    # Test backup sources
    for source in $BACKUP_SOURCES; do
        if [[ -d "$source" ]]; then
            log_message "SUCCESS" "Source directory exists: $source"
        else
            log_message "ERROR" "Source directory not found: $source"
        fi
    done
    
    # Test backup directory
    if mkdir -p "$BACKUP_BASE_DIR/test" 2>/dev/null; then
        log_message "SUCCESS" "Backup directory is writable: $BACKUP_BASE_DIR"
        rmdir "$BACKUP_BASE_DIR/test"
    else
        log_message "ERROR" "Backup directory is not writable: $BACKUP_BASE_DIR"
    fi
    
    # Test compression tools
    case "$COMPRESSION_TYPE" in
        "gzip")
            command -v gzip >/dev/null && log_message "SUCCESS" "gzip available" || log_message "ERROR" "gzip not found"
            ;;
        "bzip2")
            command -v bzip2 >/dev/null && log_message "SUCCESS" "bzip2 available" || log_message "ERROR" "bzip2 not found"
            ;;
        "xz")
            command -v xz >/dev/null && log_message "SUCCESS" "xz available" || log_message "ERROR" "xz not found"
            ;;
    esac
    
    log_message "INFO" "Configuration test completed"
}

# Main execution
main() {
    # Initialize
    COMMAND=""
    
    # Parse arguments
    parse_arguments "$@"
    
    # Execute command
    case "$COMMAND" in
        "full")
            perform_backup "full"
            ;;
        "incremental")
            perform_backup "incremental"
            ;;
        "list")
            list_backups "$BACKUP_BASE_DIR"
            ;;
        "restore")
            if [[ -z "$RESTORE_FILE" || -z "$RESTORE_DIR" ]]; then
                echo "Error: restore command requires backup file and destination directory"
                show_usage
                exit 1
            fi
            restore_backup "$RESTORE_FILE" "$RESTORE_DIR"
            ;;
        "config")
            load_config
            echo "Current configuration:"
            cat "$CONFIG_FILE"
            ;;
        "test")
            test_configuration
            ;;
        "")
            echo "Error: No command specified"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 