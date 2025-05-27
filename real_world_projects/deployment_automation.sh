#!/bin/bash
# Real World Project: Deployment Automation Script
# Features: Multi-environment deployment, rollback, health checks, notifications

# Configuration
SCRIPT_NAME="Deployment Automation"
VERSION="1.0"
CONFIG_FILE="$HOME/.deployment_config"
LOG_FILE="/var/log/deployment.log"
BACKUP_DIR="/backup/deployments"
HEALTH_CHECK_TIMEOUT=60

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Deployment environments
declare -A ENVIRONMENTS=(
    ["dev"]="development"
    ["staging"]="staging"
    ["prod"]="production"
)

# Service management commands
declare -A SERVICE_COMMANDS=(
    ["systemd"]="systemctl"
    ["init"]="service"
    ["docker"]="docker"
    ["pm2"]="pm2"
)

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    echo -e "$log_entry" | tee -a "$LOG_FILE"
    
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
# Deployment Configuration

# Application settings
APP_NAME="myapp"
APP_USER="appuser"
APP_GROUP="appgroup"

# Deployment paths
DEPLOY_BASE_DIR="/opt/applications"
SOURCE_DIR="/tmp/deployment"
BACKUP_RETENTION_DAYS=30

# Git settings
GIT_REPO="https://github.com/user/repo.git"
GIT_BRANCH="main"

# Build settings
BUILD_COMMAND="npm install && npm run build"
BUILD_DIR="dist"

# Service settings
SERVICE_TYPE="systemd"
SERVICE_NAME="myapp"
SERVICE_PORT=3000

# Health check settings
HEALTH_CHECK_URL="http://localhost:3000/health"
HEALTH_CHECK_RETRIES=5
HEALTH_CHECK_INTERVAL=10

# Notification settings
SLACK_WEBHOOK=""
EMAIL_ENABLED=false
EMAIL_TO="admin@example.com"

# Database migration
DB_MIGRATE_COMMAND=""
DB_BACKUP_COMMAND=""

# Environment-specific overrides
DEV_BRANCH="develop"
STAGING_BRANCH="staging"
PROD_BRANCH="main"
EOF

    log_message "INFO" "Default configuration created: $CONFIG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log_message "INFO" "Checking deployment prerequisites"
    
    # Check required commands
    local required_commands=("git" "curl" "tar" "rsync")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        error_exit "Missing required commands: ${missing_commands[*]}"
    fi
    
    # Check deployment directory
    if [[ ! -d "$DEPLOY_BASE_DIR" ]]; then
        log_message "INFO" "Creating deployment directory: $DEPLOY_BASE_DIR"
        sudo mkdir -p "$DEPLOY_BASE_DIR" || error_exit "Failed to create deployment directory"
    fi
    
    # Check backup directory
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_message "INFO" "Creating backup directory: $BACKUP_DIR"
        sudo mkdir -p "$BACKUP_DIR" || error_exit "Failed to create backup directory"
    fi
    
    log_message "SUCCESS" "Prerequisites check completed"
}

# Create backup
create_backup() {
    local environment="$1"
    local app_dir="$DEPLOY_BASE_DIR/$APP_NAME-$environment"
    local backup_name="${APP_NAME}-${environment}-$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name.tar.gz"
    
    if [[ -d "$app_dir" ]]; then
        log_message "INFO" "Creating backup: $backup_name"
        
        if tar -czf "$backup_path" -C "$DEPLOY_BASE_DIR" "$APP_NAME-$environment"; then
            log_message "SUCCESS" "Backup created: $backup_path"
            echo "$backup_path"
        else
            error_exit "Failed to create backup"
        fi
    else
        log_message "WARN" "No existing deployment found to backup"
        echo ""
    fi
}

# Download source code
download_source() {
    local branch="$1"
    local temp_dir="$SOURCE_DIR/$(date +%Y%m%d_%H%M%S)"
    
    log_message "INFO" "Downloading source code from branch: $branch"
    
    mkdir -p "$temp_dir" || error_exit "Failed to create temporary directory"
    
    if git clone --branch "$branch" --depth 1 "$GIT_REPO" "$temp_dir"; then
        log_message "SUCCESS" "Source code downloaded to: $temp_dir"
        echo "$temp_dir"
    else
        error_exit "Failed to download source code"
    fi
}

# Build application
build_application() {
    local source_dir="$1"
    
    if [[ -z "$BUILD_COMMAND" ]]; then
        log_message "INFO" "No build command specified, skipping build"
        return 0
    fi
    
    log_message "INFO" "Building application"
    
    cd "$source_dir" || error_exit "Failed to change to source directory"
    
    if eval "$BUILD_COMMAND"; then
        log_message "SUCCESS" "Application built successfully"
    else
        error_exit "Build failed"
    fi
    
    cd - >/dev/null
}

# Deploy application
deploy_application() {
    local source_dir="$1"
    local environment="$2"
    local app_dir="$DEPLOY_BASE_DIR/$APP_NAME-$environment"
    
    log_message "INFO" "Deploying application to $environment environment"
    
    # Stop service before deployment
    stop_service "$environment"
    
    # Remove old deployment
    if [[ -d "$app_dir" ]]; then
        sudo rm -rf "$app_dir" || error_exit "Failed to remove old deployment"
    fi
    
    # Copy new deployment
    if [[ -n "$BUILD_DIR" && -d "$source_dir/$BUILD_DIR" ]]; then
        sudo cp -r "$source_dir/$BUILD_DIR" "$app_dir" || error_exit "Failed to copy build directory"
    else
        sudo cp -r "$source_dir" "$app_dir" || error_exit "Failed to copy source directory"
    fi
    
    # Set ownership and permissions
    sudo chown -R "$APP_USER:$APP_GROUP" "$app_dir" 2>/dev/null || log_message "WARN" "Failed to set ownership"
    sudo chmod -R 755 "$app_dir" || log_message "WARN" "Failed to set permissions"
    
    log_message "SUCCESS" "Application deployed to: $app_dir"
}

# Database migration
run_database_migration() {
    local environment="$1"
    
    if [[ -z "$DB_MIGRATE_COMMAND" ]]; then
        log_message "INFO" "No database migration command specified"
        return 0
    fi
    
    log_message "INFO" "Running database migration for $environment"
    
    # Create database backup first
    if [[ -n "$DB_BACKUP_COMMAND" ]]; then
        log_message "INFO" "Creating database backup"
        if ! eval "$DB_BACKUP_COMMAND"; then
            log_message "WARN" "Database backup failed"
        fi
    fi
    
    # Run migration
    if eval "$DB_MIGRATE_COMMAND"; then
        log_message "SUCCESS" "Database migration completed"
    else
        error_exit "Database migration failed"
    fi
}

# Service management
start_service() {
    local environment="$1"
    local service_name="${SERVICE_NAME}-${environment}"
    
    log_message "INFO" "Starting service: $service_name"
    
    case "$SERVICE_TYPE" in
        "systemd")
            if sudo systemctl start "$service_name"; then
                log_message "SUCCESS" "Service started: $service_name"
            else
                error_exit "Failed to start service: $service_name"
            fi
            ;;
        "docker")
            if docker start "$service_name"; then
                log_message "SUCCESS" "Docker container started: $service_name"
            else
                error_exit "Failed to start Docker container: $service_name"
            fi
            ;;
        "pm2")
            if pm2 start "$service_name"; then
                log_message "SUCCESS" "PM2 process started: $service_name"
            else
                error_exit "Failed to start PM2 process: $service_name"
            fi
            ;;
        *)
            log_message "WARN" "Unknown service type: $SERVICE_TYPE"
            ;;
    esac
}

stop_service() {
    local environment="$1"
    local service_name="${SERVICE_NAME}-${environment}"
    
    log_message "INFO" "Stopping service: $service_name"
    
    case "$SERVICE_TYPE" in
        "systemd")
            sudo systemctl stop "$service_name" 2>/dev/null || log_message "WARN" "Service may not be running"
            ;;
        "docker")
            docker stop "$service_name" 2>/dev/null || log_message "WARN" "Container may not be running"
            ;;
        "pm2")
            pm2 stop "$service_name" 2>/dev/null || log_message "WARN" "Process may not be running"
            ;;
        *)
            log_message "WARN" "Unknown service type: $SERVICE_TYPE"
            ;;
    esac
}

# Health check
perform_health_check() {
    local environment="$1"
    local retries="$HEALTH_CHECK_RETRIES"
    local interval="$HEALTH_CHECK_INTERVAL"
    
    if [[ -z "$HEALTH_CHECK_URL" ]]; then
        log_message "INFO" "No health check URL specified"
        return 0
    fi
    
    log_message "INFO" "Performing health check for $environment"
    
    local count=0
    while [[ $count -lt $retries ]]; do
        if curl -f -s "$HEALTH_CHECK_URL" >/dev/null; then
            log_message "SUCCESS" "Health check passed"
            return 0
        fi
        
        ((count++))
        log_message "INFO" "Health check attempt $count/$retries failed, retrying in ${interval}s"
        sleep "$interval"
    done
    
    error_exit "Health check failed after $retries attempts"
}

# Rollback deployment
rollback_deployment() {
    local environment="$1"
    local backup_file="$2"
    
    if [[ ! -f "$backup_file" ]]; then
        error_exit "Backup file not found: $backup_file"
    fi
    
    log_message "INFO" "Rolling back deployment for $environment"
    
    # Stop service
    stop_service "$environment"
    
    # Remove current deployment
    local app_dir="$DEPLOY_BASE_DIR/$APP_NAME-$environment"
    if [[ -d "$app_dir" ]]; then
        sudo rm -rf "$app_dir" || error_exit "Failed to remove current deployment"
    fi
    
    # Restore from backup
    if tar -xzf "$backup_file" -C "$DEPLOY_BASE_DIR"; then
        log_message "SUCCESS" "Deployment rolled back from: $backup_file"
    else
        error_exit "Failed to restore from backup"
    fi
    
    # Start service
    start_service "$environment"
    
    # Health check
    perform_health_check "$environment"
    
    log_message "SUCCESS" "Rollback completed successfully"
}

# Send notification
send_notification() {
    local message="$1"
    local status="$2"
    
    # Slack notification
    if [[ -n "$SLACK_WEBHOOK" ]]; then
        local color="good"
        [[ "$status" == "error" ]] && color="danger"
        [[ "$status" == "warning" ]] && color="warning"
        
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\", \"color\":\"$color\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null || log_message "WARN" "Failed to send Slack notification"
    fi
    
    # Email notification
    if [[ "$EMAIL_ENABLED" == "true" ]]; then
        echo "$message" | mail -s "Deployment Notification" "$EMAIL_TO" 2>/dev/null || \
            log_message "WARN" "Failed to send email notification"
    fi
}

# List available backups
list_backups() {
    local environment="$1"
    
    echo "=== Available Backups for $environment ==="
    echo ""
    
    find "$BACKUP_DIR" -name "${APP_NAME}-${environment}-*.tar.gz" -printf "%T@ %Tc %p\n" 2>/dev/null | \
        sort -n | tail -10 | while read -r timestamp date time timezone file; do
        local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        echo "$(basename "$file"): $(numfmt --to=iec $size) ($date $time)"
    done
}

# Cleanup old backups
cleanup_old_backups() {
    log_message "INFO" "Cleaning up old backups"
    
    find "$BACKUP_DIR" -name "${APP_NAME}-*.tar.gz" -mtime +$BACKUP_RETENTION_DAYS -delete 2>/dev/null
    
    log_message "SUCCESS" "Old backup cleanup completed"
}

# Generate deployment report
generate_deployment_report() {
    local environment="$1"
    local status="$2"
    local start_time="$3"
    local end_time="$4"
    
    local duration=$((end_time - start_time))
    local report_file="deployment_report_${environment}_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
=== Deployment Report ===
Environment: $environment
Application: $APP_NAME
Status: $status
Start Time: $(date -d @$start_time)
End Time: $(date -d @$end_time)
Duration: ${duration}s
Deployed By: $(whoami)
Host: $(hostname)
========================

Deployment Details:
- Repository: $GIT_REPO
- Branch: $(get_branch_for_environment "$environment")
- Service Type: $SERVICE_TYPE
- Service Name: $SERVICE_NAME

$(if [[ "$status" == "SUCCESS" ]]; then
    echo "✓ Deployment completed successfully"
else
    echo "✗ Deployment failed"
fi)
EOF

    log_message "INFO" "Deployment report saved: $report_file"
    echo "$report_file"
}

# Get branch for environment
get_branch_for_environment() {
    local environment="$1"
    
    case "$environment" in
        "dev") echo "${DEV_BRANCH:-develop}" ;;
        "staging") echo "${STAGING_BRANCH:-staging}" ;;
        "prod") echo "${PROD_BRANCH:-main}" ;;
        *) echo "main" ;;
    esac
}

# Main deployment function
deploy() {
    local environment="$1"
    local force_deploy="${2:-false}"
    local start_time=$(date +%s)
    
    log_message "INFO" "Starting deployment to $environment environment"
    
    # Load configuration
    load_config
    
    # Check prerequisites
    check_prerequisites
    
    # Confirmation for production
    if [[ "$environment" == "prod" && "$force_deploy" != "true" ]]; then
        echo -e "${YELLOW}WARNING: You are about to deploy to PRODUCTION!${NC}"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            log_message "INFO" "Deployment cancelled by user"
            exit 0
        fi
    fi
    
    # Get branch for environment
    local branch=$(get_branch_for_environment "$environment")
    
    # Create backup
    local backup_file=$(create_backup "$environment")
    
    # Download source
    local source_dir=$(download_source "$branch")
    
    # Build application
    build_application "$source_dir"
    
    # Run database migration
    run_database_migration "$environment"
    
    # Deploy application
    deploy_application "$source_dir" "$environment"
    
    # Start service
    start_service "$environment"
    
    # Health check
    if ! perform_health_check "$environment"; then
        log_message "ERROR" "Health check failed, initiating rollback"
        if [[ -n "$backup_file" ]]; then
            rollback_deployment "$environment" "$backup_file"
        fi
        error_exit "Deployment failed and rolled back"
    fi
    
    # Cleanup
    rm -rf "$source_dir"
    cleanup_old_backups
    
    local end_time=$(date +%s)
    
    # Generate report
    local report_file=$(generate_deployment_report "$environment" "SUCCESS" "$start_time" "$end_time")
    
    # Send notification
    send_notification "✅ Deployment to $environment completed successfully" "good"
    
    log_message "SUCCESS" "Deployment to $environment completed successfully"
}

# Interactive menu
show_menu() {
    echo -e "\n${CYAN}=== DEPLOYMENT AUTOMATION MENU ===${NC}"
    echo "1. Deploy to Development"
    echo "2. Deploy to Staging"
    echo "3. Deploy to Production"
    echo "4. Rollback Deployment"
    echo "5. List Backups"
    echo "6. Health Check"
    echo "7. Service Status"
    echo "8. View Configuration"
    echo "9. Cleanup Old Backups"
    echo "0. Exit"
    echo ""
}

# Show service status
show_service_status() {
    local environment="$1"
    local service_name="${SERVICE_NAME}-${environment}"
    
    echo "=== Service Status for $environment ==="
    
    case "$SERVICE_TYPE" in
        "systemd")
            systemctl status "$service_name" 2>/dev/null || echo "Service not found"
            ;;
        "docker")
            docker ps -f name="$service_name" || echo "Container not found"
            ;;
        "pm2")
            pm2 show "$service_name" 2>/dev/null || echo "Process not found"
            ;;
        *)
            echo "Unknown service type: $SERVICE_TYPE"
            ;;
    esac
}

# Main execution
main() {
    # Create log directory
    sudo mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || LOG_FILE="./deployment.log"
    
    if [[ $# -eq 0 ]]; then
        # Interactive mode
        while true; do
            show_menu
            read -p "Select option (0-9): " choice
            
            case $choice in
                1)
                    deploy "dev"
                    ;;
                2)
                    deploy "staging"
                    ;;
                3)
                    deploy "prod"
                    ;;
                4)
                    echo "Available environments: dev, staging, prod"
                    read -p "Enter environment: " env
                    list_backups "$env"
                    read -p "Enter backup filename: " backup
                    rollback_deployment "$env" "$BACKUP_DIR/$backup"
                    ;;
                5)
                    echo "Available environments: dev, staging, prod"
                    read -p "Enter environment: " env
                    list_backups "$env"
                    ;;
                6)
                    echo "Available environments: dev, staging, prod"
                    read -p "Enter environment: " env
                    perform_health_check "$env"
                    ;;
                7)
                    echo "Available environments: dev, staging, prod"
                    read -p "Enter environment: " env
                    show_service_status "$env"
                    ;;
                8)
                    echo "Configuration file: $CONFIG_FILE"
                    if [[ -f "$CONFIG_FILE" ]]; then
                        echo "Current configuration:"
                        cat "$CONFIG_FILE"
                    else
                        echo "Configuration file not found"
                    fi
                    ;;
                9)
                    cleanup_old_backups
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
            "deploy")
                if [[ -n "$2" ]]; then
                    deploy "$2" "$3"
                else
                    echo "Usage: $0 deploy <environment> [force]"
                    exit 1
                fi
                ;;
            "rollback")
                if [[ -n "$2" && -n "$3" ]]; then
                    rollback_deployment "$2" "$3"
                else
                    echo "Usage: $0 rollback <environment> <backup_file>"
                    exit 1
                fi
                ;;
            "health")
                if [[ -n "$2" ]]; then
                    perform_health_check "$2"
                else
                    echo "Usage: $0 health <environment>"
                    exit 1
                fi
                ;;
            "status")
                if [[ -n "$2" ]]; then
                    show_service_status "$2"
                else
                    echo "Usage: $0 status <environment>"
                    exit 1
                fi
                ;;
            "backups")
                if [[ -n "$2" ]]; then
                    list_backups "$2"
                else
                    echo "Usage: $0 backups <environment>"
                    exit 1
                fi
                ;;
            "cleanup")
                cleanup_old_backups
                ;;
            *)
                echo "Usage: $0 [deploy|rollback|health|status|backups|cleanup] [options]"
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

Automated deployment tool for multi-environment applications.

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    deploy ENV [force]           Deploy to environment (dev/staging/prod)
    rollback ENV BACKUP         Rollback to previous backup
    health ENV                  Perform health check
    status ENV                  Show service status
    backups ENV                 List available backups
    cleanup                     Remove old backups

Interactive Mode:
    Run without arguments for interactive menu

Examples:
    $0 deploy dev
    $0 deploy prod force
    $0 rollback staging myapp-staging-20240101_120000.tar.gz
    $0 health prod
    $0 status dev

Configuration:
    Edit $CONFIG_FILE to customize settings

EOF
    exit 0
fi

# Run main function
main "$@" 