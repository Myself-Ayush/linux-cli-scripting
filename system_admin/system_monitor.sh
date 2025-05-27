#!/bin/bash
# System Admin - System Monitoring Script

echo "=== System Information Monitor ==="

get_system_info() {
    echo "🖥️  SYSTEM OVERVIEW"
    echo "=================="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || uname -o)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Current User: $(whoami)"
    echo "Date: $(date)"
    echo ""
}

get_cpu_info() {
    echo "🔧 CPU INFORMATION"
    echo "=================="
    echo "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
    echo "CPU Cores: $(nproc)"
    echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)% used"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
}

get_memory_info() {
    echo "💾 MEMORY INFORMATION"
    echo "==================="
    
    # Get memory info from /proc/meminfo
    total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    free_mem=$(grep MemFree /proc/meminfo | awk '{print $2}')
    available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    
    # Convert to MB
    total_mb=$((total_mem / 1024))
    free_mb=$((free_mem / 1024))
    available_mb=$((available_mem / 1024))
    used_mb=$((total_mb - available_mb))
    
    echo "Total Memory: ${total_mb} MB"
    echo "Used Memory: ${used_mb} MB"
    echo "Free Memory: ${free_mb} MB"
    echo "Available Memory: ${available_mb} MB"
    
    # Calculate percentage
    used_percent=$((used_mb * 100 / total_mb))
    echo "Memory Usage: ${used_percent}%"
    echo ""
}

get_disk_info() {
    echo "💿 DISK INFORMATION"
    echo "=================="
    echo "Disk Usage by Filesystem:"
    df -h | grep -E '^(/dev/|tmpfs)' | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' | column -t
    echo ""
    
    echo "Largest directories in current location:"
    du -h --max-depth=1 2>/dev/null | sort -hr | head -5
    echo ""
}

get_network_info() {
    echo "🌐 NETWORK INFORMATION"
    echo "====================="
    echo "Network Interfaces:"
    ip addr show 2>/dev/null | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://' || \
    ifconfig 2>/dev/null | grep '^[a-z]' | awk '{print $1}' || \
    echo "Network info not available"
    
    echo ""
    echo "Active Network Connections:"
    netstat -tuln 2>/dev/null | head -10 || ss -tuln 2>/dev/null | head -10 || echo "Network connections not available"
    echo ""
}

get_process_info() {
    echo "⚙️  PROCESS INFORMATION"
    echo "======================"
    echo "Top 5 CPU consuming processes:"
    ps aux --sort=-%cpu | head -6 | awk '{printf "%-8s %-6s %-6s %-8s %s\n", $1, $2, $3, $4, $11}'
    echo ""
    
    echo "Top 5 Memory consuming processes:"
    ps aux --sort=-%mem | head -6 | awk '{printf "%-8s %-6s %-6s %-8s %s\n", $1, $2, $3, $4, $11}'
    echo ""
    
    echo "Total processes: $(ps aux | wc -l)"
    echo ""
}

get_service_status() {
    echo "🔌 SERVICE STATUS"
    echo "================"
    
    # Check common services
    services=("ssh" "nginx" "apache2" "mysql" "postgresql" "docker")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo "✓ $service: Running"
        elif systemctl list-unit-files --type=service | grep -q "^$service"; then
            echo "✗ $service: Stopped"
        else
            echo "- $service: Not installed"
        fi
    done
    echo ""
}

check_security() {
    echo "🔒 SECURITY CHECK"
    echo "================"
    
    echo "Failed login attempts (last 10):"
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 | awk '{print $1, $2, $3, $9, $11}' || \
    echo "Auth log not accessible"
    
    echo ""
    echo "Currently logged in users:"
    who
    echo ""
    
    echo "Last 5 logins:"
    last -5 2>/dev/null || echo "Login history not available"
    echo ""
}

generate_report() {
    local report_file="system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "Generating comprehensive system report..."
    
    {
        echo "SYSTEM MONITORING REPORT"
        echo "Generated on: $(date)"
        echo "========================================"
        echo ""
        
        get_system_info
        get_cpu_info
        get_memory_info
        get_disk_info
        get_network_info
        get_process_info
        get_service_status
        check_security
        
    } > "$report_file"
    
    echo "Report saved to: $report_file"
    echo "Report size: $(ls -lh $report_file | awk '{print $5}')"
}

# Interactive menu
show_menu() {
    echo "=== SYSTEM MONITORING TOOL ==="
    echo "1. System Overview"
    echo "2. CPU Information"
    echo "3. Memory Information"
    echo "4. Disk Information"
    echo "5. Network Information"
    echo "6. Process Information"
    echo "7. Service Status"
    echo "8. Security Check"
    echo "9. Generate Full Report"
    echo "10. Live Monitor (updates every 5 seconds)"
    echo "0. Exit"
    echo ""
}

live_monitor() {
    echo "Starting live monitor (Press Ctrl+C to stop)..."
    echo ""
    
    while true; do
        clear
        echo "=== LIVE SYSTEM MONITOR ==="
        echo "Updated: $(date)"
        echo ""
        
        get_cpu_info
        get_memory_info
        echo "Top 3 processes by CPU:"
        ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "%-10s %6s%% %6s%% %s\n", $1, $3, $4, $11}'
        echo ""
        
        sleep 5
    done
}

# Main execution
if [ "$#" -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Select option (0-10): " choice
        
        case $choice in
            1) get_system_info ;;
            2) get_cpu_info ;;
            3) get_memory_info ;;
            4) get_disk_info ;;
            5) get_network_info ;;
            6) get_process_info ;;
            7) get_service_status ;;
            8) check_security ;;
            9) generate_report ;;
            10) live_monitor ;;
            0) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
else
    # Command line mode
    case $1 in
        "all"|"report") generate_report ;;
        "system") get_system_info ;;
        "cpu") get_cpu_info ;;
        "memory") get_memory_info ;;
        "disk") get_disk_info ;;
        "network") get_network_info ;;
        "processes") get_process_info ;;
        "services") get_service_status ;;
        "security") check_security ;;
        "live") live_monitor ;;
        *) 
            echo "Usage: $0 [all|system|cpu|memory|disk|network|processes|services|security|live]"
            echo "Or run without arguments for interactive mode"
            ;;
    esac
fi
