#!/bin/bash
# Advanced Concepts - Lesson 4: Networking and Network Utilities

echo "=== Networking and Network Utilities ==="

echo "=== Basic Network Information ==="

echo "1. Network interface information:"
echo "Available network interfaces:"
if command -v ip >/dev/null 2>&1; then
    ip addr show | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/://'
else
    ifconfig | grep -E "^[a-z]" | awk '{print $1}'
fi

echo ""
echo "2. Current IP addresses:"
if command -v ip >/dev/null 2>&1; then
    ip addr show | grep -E "inet " | awk '{print $2, $NF}'
else
    ifconfig | grep -E "inet " | awk '{print $2, $NF}'
fi

echo ""
echo "3. Default gateway:"
if command -v ip >/dev/null 2>&1; then
    ip route show default | awk '{print $3}'
else
    route -n | grep "^0.0.0.0" | awk '{print $2}'
fi

echo ""
echo "4. DNS servers:"
if [ -f /etc/resolv.conf ]; then
    grep nameserver /etc/resolv.conf | awk '{print $2}'
fi

echo ""
echo "=== Network Connectivity Testing ==="

echo "5. Ping connectivity test:"
test_connectivity() {
    local host="$1"
    local count="${2:-3}"
    
    echo "Testing connectivity to $host..."
    if ping -c $count "$host" >/dev/null 2>&1; then
        echo "✓ $host is reachable"
        return 0
    else
        echo "✗ $host is not reachable"
        return 1
    fi
}

# Test common hosts
test_connectivity "8.8.8.8" 2
test_connectivity "google.com" 2

echo ""
echo "6. Port connectivity testing:"
test_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    echo "Testing port $port on $host..."
    if timeout $timeout bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo "✓ Port $port is open on $host"
        return 0
    else
        echo "✗ Port $port is closed or filtered on $host"
        return 1
    fi
}

# Test common ports
test_port "google.com" 80
test_port "google.com" 443
test_port "google.com" 22

echo ""
echo "=== DNS Operations ==="

echo "7. DNS lookup operations:"
dns_lookup() {
    local domain="$1"
    local record_type="${2:-A}"
    
    echo "DNS lookup for $domain (type: $record_type):"
    
    if command -v nslookup >/dev/null 2>&1; then
        nslookup -type=$record_type "$domain" | grep -A 10 "Non-authoritative answer:"
    elif command -v dig >/dev/null 2>&1; then
        dig "$domain" $record_type +short
    else
        echo "No DNS lookup tools available (nslookup or dig)"
        getent hosts "$domain" 2>/dev/null || echo "getent lookup failed"
    fi
}

dns_lookup "google.com" "A"
echo ""
dns_lookup "google.com" "MX"

echo ""
echo "8. Reverse DNS lookup:"
reverse_dns() {
    local ip="$1"
    echo "Reverse DNS lookup for $ip:"
    
    if command -v nslookup >/dev/null 2>&1; then
        nslookup "$ip" | grep "name =" | awk '{print $4}'
    elif command -v dig >/dev/null 2>&1; then
        dig -x "$ip" +short
    else
        getent hosts "$ip" 2>/dev/null | awk '{print $2}'
    fi
}

reverse_dns "8.8.8.8"

echo ""
echo "=== Network Monitoring ==="

echo "9. Active network connections:"
show_connections() {
    local filter="${1:-all}"
    
    echo "Active network connections ($filter):"
    
    if command -v ss >/dev/null 2>&1; then
        case $filter in
            "tcp")
                ss -tuln | grep tcp
                ;;
            "udp")
                ss -tuln | grep udp
                ;;
            "listening")
                ss -tuln | grep LISTEN
                ;;
            *)
                ss -tuln | head -10
                ;;
        esac
    elif command -v netstat >/dev/null 2>&1; then
        case $filter in
            "tcp")
                netstat -tuln | grep tcp
                ;;
            "udp")
                netstat -tuln | grep udp
                ;;
            "listening")
                netstat -tuln | grep LISTEN
                ;;
            *)
                netstat -tuln | head -10
                ;;
        esac
    else
        echo "No network monitoring tools available (ss or netstat)"
    fi
}

show_connections "listening"

echo ""
echo "10. Network interface statistics:"
show_interface_stats() {
    local interface="${1:-all}"
    
    echo "Network interface statistics:"
    
    if [ "$interface" = "all" ]; then
        if [ -f /proc/net/dev ]; then
            cat /proc/net/dev | grep -E "eth|wlan|enp|wlp" | head -5
        fi
    else
        if [ -f "/sys/class/net/$interface/statistics/rx_bytes" ]; then
            local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
            local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
            echo "$interface: RX: $rx_bytes bytes, TX: $tx_bytes bytes"
        fi
    fi
}

show_interface_stats

echo ""
echo "=== Network Troubleshooting ==="

echo "11. Network path tracing:"
trace_route() {
    local host="$1"
    local max_hops="${2:-10}"
    
    echo "Tracing route to $host (max $max_hops hops):"
    
    if command -v traceroute >/dev/null 2>&1; then
        traceroute -m $max_hops "$host" 2>/dev/null | head -5
    elif command -v tracepath >/dev/null 2>&1; then
        tracepath "$host" | head -5
    else
        echo "No traceroute tools available"
        echo "Attempting basic connectivity test instead:"
        test_connectivity "$host"
    fi
}

trace_route "8.8.8.8" 5

echo ""
echo "12. Network performance testing:"
network_speed_test() {
    local test_file_url="http://speedtest.ftp.otenet.gr/files/test1Mb.db"
    local test_file="test_download.tmp"
    
    echo "Basic network speed test (downloading 1MB file):"
    
    if command -v wget >/dev/null 2>&1; then
        echo "Using wget..."
        time wget -q -O "$test_file" "$test_file_url" 2>&1
        if [ -f "$test_file" ]; then
            local size=$(stat -c%s "$test_file" 2>/dev/null || echo "0")
            echo "Downloaded: $size bytes"
            rm -f "$test_file"
        fi
    elif command -v curl >/dev/null 2>&1; then
        echo "Using curl..."
        time curl -s -o "$test_file" "$test_file_url" 2>&1
        if [ -f "$test_file" ]; then
            local size=$(stat -c%s "$test_file" 2>/dev/null || echo "0")
            echo "Downloaded: $size bytes"
            rm -f "$test_file"
        fi
    else
        echo "No download tools available (wget or curl)"
    fi
}

# Uncomment to run speed test (may take time)
# network_speed_test

echo ""
echo "=== Network Security Scanning ==="

echo "13. Port scanning functions:"
port_scan() {
    local host="$1"
    local start_port="${2:-1}"
    local end_port="${3:-100}"
    local timeout="${4:-1}"
    
    echo "Scanning ports $start_port-$end_port on $host:"
    
    for port in $(seq $start_port $end_port); do
        if timeout $timeout bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            echo "Port $port: OPEN"
        fi
    done
}

echo "Scanning common ports on localhost:"
port_scan "localhost" 20 25 1

echo ""
echo "14. Network service detection:"
detect_services() {
    local host="${1:-localhost}"
    
    echo "Detecting services on $host:"
    
    # Common ports and their services
    declare -A common_ports=(
        [22]="SSH"
        [23]="Telnet"
        [25]="SMTP"
        [53]="DNS"
        [80]="HTTP"
        [110]="POP3"
        [143]="IMAP"
        [443]="HTTPS"
        [993]="IMAPS"
        [995]="POP3S"
    )
    
    for port in "${!common_ports[@]}"; do
        if timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            echo "Port $port (${common_ports[$port]}): OPEN"
        fi
    done
}

detect_services

echo ""
echo "=== Network Configuration ==="

echo "15. Network configuration functions:"
show_network_config() {
    echo "Complete network configuration:"
    
    echo "--- Interfaces ---"
    if command -v ip >/dev/null 2>&1; then
        ip addr show | grep -E "(^[0-9]+:|inet )"
    fi
    
    echo ""
    echo "--- Routing Table ---"
    if command -v ip >/dev/null 2>&1; then
        ip route show | head -5
    fi
    
    echo ""
    echo "--- ARP Table ---"
    if command -v ip >/dev/null 2>&1; then
        ip neigh show | head -5
    elif command -v arp >/dev/null 2>&1; then
        arp -a | head -5
    fi
}

show_network_config

echo ""
echo "=== Wireless Network Information ==="

echo "16. Wireless network scanning (if available):"
scan_wifi() {
    echo "Scanning for wireless networks:"
    
    if command -v iwlist >/dev/null 2>&1; then
        # Find wireless interfaces
        local wireless_interfaces=$(iwconfig 2>/dev/null | grep -o "^[a-z0-9]*" | head -3)
        
        for interface in $wireless_interfaces; do
            echo "Scanning on interface: $interface"
            iwlist "$interface" scan 2>/dev/null | grep -E "(ESSID|Quality|Encryption)" | head -10
        done
    else
        echo "Wireless tools not available (iwlist)"
    fi
}

scan_wifi

echo ""
echo "=== Network Monitoring Scripts ==="

echo "17. Creating network monitoring functions:"

# Function to monitor network traffic
monitor_traffic() {
    local interface="${1:-eth0}"
    local interval="${2:-2}"
    local count="${3:-5}"
    
    echo "Monitoring traffic on $interface for $count intervals:"
    
    if [ -f "/sys/class/net/$interface/statistics/rx_bytes" ]; then
        for i in $(seq 1 $count); do
            local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo "0")
            local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo "0")
            echo "$(date +%H:%M:%S) RX: $rx_bytes TX: $tx_bytes"
            sleep $interval
        done
    else
        echo "Interface $interface not found or statistics not available"
    fi
}

# Function to check internet connectivity
check_internet() {
    local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
    local connected=0
    
    echo "Checking internet connectivity:"
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
            echo "✓ Connected via $host"
            connected=1
            break
        else
            echo "✗ Failed to reach $host"
        fi
    done
    
    if [ $connected -eq 1 ]; then
        echo "Internet connectivity: AVAILABLE"
        return 0
    else
        echo "Internet connectivity: NOT AVAILABLE"
        return 1
    fi
}

check_internet

echo ""
echo "18. Network diagnostic script:"

cat > network_diagnostic.sh << 'EOF'
#!/bin/bash
# Network Diagnostic Script

echo "=== Network Diagnostic Report ==="
echo "Generated: $(date)"
echo ""

echo "=== Basic Information ==="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo ""

echo "=== Network Interfaces ==="
if command -v ip >/dev/null 2>&1; then
    ip addr show | grep -E "(^[0-9]+:|inet )"
fi
echo ""

echo "=== Connectivity Tests ==="
for host in 8.8.8.8 google.com; do
    if ping -c 2 "$host" >/dev/null 2>&1; then
        echo "✓ $host reachable"
    else
        echo "✗ $host unreachable"
    fi
done
echo ""

echo "=== DNS Resolution ==="
if nslookup google.com >/dev/null 2>&1; then
    echo "✓ DNS resolution working"
else
    echo "✗ DNS resolution failed"
fi
echo ""

echo "=== Active Connections ==="
if command -v ss >/dev/null 2>&1; then
    ss -tuln | grep LISTEN | head -5
fi
echo ""

echo "=== End of Report ==="
EOF

chmod +x network_diagnostic.sh
echo "Network diagnostic script created: network_diagnostic.sh"

echo ""
echo "=== Cleanup and Summary ==="

rm -f test_download.tmp 2>/dev/null

echo "=== Networking Summary ==="
echo "✓ Network interface information"
echo "✓ Connectivity testing (ping, port checks)"
echo "✓ DNS operations and lookups"
echo "✓ Network monitoring and statistics"
echo "✓ Network troubleshooting tools"
echo "✓ Port scanning and service detection"
echo "✓ Network configuration display"
echo "✓ Wireless network scanning"
echo "✓ Traffic monitoring functions"
echo "✓ Internet connectivity checking"
echo "✓ Network diagnostic script"
echo ""
echo "Key networking tools:"
echo "• ping - test connectivity"
echo "• nslookup/dig - DNS lookups"
echo "• ss/netstat - show connections"
echo "• ip/ifconfig - interface configuration"
echo "• traceroute - path tracing"
echo "• wget/curl - download testing"
echo ""
echo "Common troubleshooting steps:"
echo "1. Check physical connectivity"
echo "2. Verify IP configuration"
echo "3. Test DNS resolution"
echo "4. Check routing table"
echo "5. Test specific services/ports"
echo "6. Monitor network traffic" 