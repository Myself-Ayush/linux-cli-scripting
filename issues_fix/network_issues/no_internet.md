# No Internet Connection Issues

Internet connectivity problems are among the most common Linux issues. This guide provides systematic troubleshooting steps to diagnose and fix network connectivity problems.

## 🚨 Common Symptoms

- No internet access despite being connected to network
- Can ping local devices but not external websites
- DNS resolution failures
- Intermittent connectivity
- Network interface not detected

## 🔍 Diagnostic Steps

### Step 1: Check Physical Connection

```bash
# Check network interfaces
ip addr show
# or
ifconfig

# Check if interface is up
ip link show

# Check cable connection (for wired)
ethtool eth0

# Check WiFi connection
iwconfig
# or
nmcli device wifi list
```

### Step 2: Check Network Configuration

```bash
# Check IP configuration
ip addr show

# Check routing table
ip route show
# or
route -n

# Check default gateway
ip route | grep default

# Check DNS configuration
cat /etc/resolv.conf

# Check NetworkManager status
systemctl status NetworkManager
```

### Step 3: Test Connectivity

```bash
# Test local connectivity
ping -c 4 127.0.0.1  # Loopback test

# Test gateway connectivity
ping -c 4 $(ip route | grep default | awk '{print $3}')

# Test external IP (bypasses DNS)
ping -c 4 8.8.8.8

# Test DNS resolution
nslookup google.com
# or
dig google.com

# Test specific website
ping -c 4 google.com
```

## 🔧 Solutions

### Solution 1: Restart Network Services

```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Restart networking service (older systems)
sudo systemctl restart networking

# Restart network interface
sudo ip link set eth0 down
sudo ip link set eth0 up

# Or using ifconfig
sudo ifconfig eth0 down
sudo ifconfig eth0 up
```

### Solution 2: Fix IP Configuration

#### Automatic Configuration (DHCP)

```bash
# Release and renew IP address
sudo dhclient -r  # Release
sudo dhclient    # Renew

# Or using NetworkManager
sudo nmcli connection down "connection-name"
sudo nmcli connection up "connection-name"

# Restart DHCP client
sudo systemctl restart dhcpcd  # Arch Linux
sudo systemctl restart dhclient  # Debian/Ubuntu
```

#### Manual IP Configuration

```bash
# Set static IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Set default gateway
sudo ip route add default via 192.168.1.1

# Set DNS servers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
```

### Solution 3: Fix DNS Issues

```bash
# Flush DNS cache
sudo systemctl restart systemd-resolved  # systemd systems
sudo systemctl restart dnsmasq  # if using dnsmasq

# Test different DNS servers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

# Check DNS resolution
nslookup google.com 8.8.8.8
```

### Solution 4: WiFi-Specific Fixes

```bash
# Scan for WiFi networks
sudo iwlist scan | grep ESSID

# Connect to WiFi network
sudo iwconfig wlan0 essid "NetworkName"
sudo iwconfig wlan0 key s:"password"

# Using NetworkManager
nmcli device wifi connect "NetworkName" password "password"

# Check WiFi power management
iwconfig wlan0 | grep "Power Management"

# Disable power management if causing issues
sudo iwconfig wlan0 power off
```

### Solution 5: Driver Issues

```bash
# Check network hardware
lspci | grep -i network
lsusb | grep -i wireless

# Check if driver is loaded
lsmod | grep -i network_driver_name

# Check for missing firmware
dmesg | grep -i firmware

# Install missing drivers (Ubuntu/Debian)
sudo apt update
sudo apt install linux-firmware
sudo apt install firmware-iwlwifi  # Intel WiFi

# Install drivers (Fedora)
sudo dnf install kernel-modules-extra
sudo dnf install iwl*-firmware
```

## 🔧 Advanced Troubleshooting

### Check Network Manager Configuration

```bash
# List all connections
nmcli connection show

# Show connection details
nmcli connection show "connection-name"

# Edit connection
sudo nmcli connection edit "connection-name"

# Delete and recreate connection
sudo nmcli connection delete "connection-name"
sudo nmcli connection add type ethernet con-name "new-name" ifname eth0
```

### Manual Network Configuration Files

#### Ubuntu/Debian (Netplan)

```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
    # Or static configuration:
    # eth0:
    #   addresses:
    #     - 192.168.1.100/24
    #   gateway4: 192.168.1.1
    #   nameservers:
    #     addresses: [8.8.8.8, 8.8.4.4]
```

```bash
# Apply netplan configuration
sudo netplan apply
```

#### RHEL/CentOS/Fedora

```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
NAME=eth0
DEVICE=eth0
ONBOOT=yes

# For static IP:
# BOOTPROTO=static
# IPADDR=192.168.1.100
# NETMASK=255.255.255.0
# GATEWAY=192.168.1.1
# DNS1=8.8.8.8
# DNS2=8.8.4.4
```

#### Arch Linux

```bash
# /etc/systemd/network/20-wired.network
[Match]
Name=eth0

[Network]
DHCP=yes

# For static IP:
# Address=192.168.1.100/24
# Gateway=192.168.1.1
# DNS=8.8.8.8
```

### Firewall Issues

```bash
# Check if firewall is blocking connections
sudo iptables -L

# Temporarily disable firewall for testing
sudo ufw disable  # Ubuntu
sudo systemctl stop firewalld  # Fedora/RHEL
sudo systemctl stop iptables  # Other systems

# Allow specific ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Check for Conflicting Services

```bash
# Check what's managing network
systemctl status NetworkManager
systemctl status networking
systemctl status systemd-networkd
systemctl status wicd

# Disable conflicting services
sudo systemctl disable wicd
sudo systemctl stop wicd
```

## 🛠️ Hardware-Specific Issues

### USB WiFi Adapters

```bash
# Check if USB WiFi is detected
lsusb | grep -i wireless

# Check driver support
dmesg | tail -20

# Install USB WiFi drivers
sudo apt install rtl8812au-dkms  # Realtek
sudo apt install mt7601u-dkms    # MediaTek
```

### Ethernet Issues

```bash
# Check cable and port
ethtool eth0

# Check link status
cat /sys/class/net/eth0/carrier

# Test different cable/port
# Check network switch/router
```

## 📊 Network Monitoring Tools

```bash
# Monitor network traffic
sudo nethogs  # Per-process network usage
sudo iftop    # Network bandwidth usage
sudo tcpdump -i eth0  # Packet capture

# Check network statistics
ss -tuln      # Active connections
netstat -tuln # Legacy version
ip -s link    # Interface statistics
```

## 🔄 Reset Network Configuration

### Complete Network Reset

```bash
# Stop network services
sudo systemctl stop NetworkManager
sudo systemctl stop systemd-networkd

# Remove network configuration
sudo rm /etc/NetworkManager/system-connections/*
sudo rm /etc/systemd/network/*

# Restart services
sudo systemctl start NetworkManager

# Reconfigure network
nmcli device wifi connect "NetworkName" password "password"
```

### Reset to Factory Defaults

```bash
# Backup current configuration
sudo cp -r /etc/NetworkManager /etc/NetworkManager.backup

# Reset NetworkManager
sudo rm -rf /etc/NetworkManager/system-connections/*
sudo systemctl restart NetworkManager

# Reconfigure from scratch
```

## 🛡️ Prevention Tips

### Regular Maintenance

```bash
# Keep network drivers updated
sudo apt update && sudo apt upgrade  # Debian/Ubuntu
sudo dnf update  # Fedora
sudo pacman -Syu  # Arch

# Monitor network performance
ping -c 10 8.8.8.8
speedtest-cli

# Check for hardware issues
dmesg | grep -i error
journalctl -u NetworkManager
```

### Best Practices

1. **Document working configuration** before making changes
2. **Test one change at a time** when troubleshooting
3. **Keep network drivers updated**
4. **Monitor network performance** regularly
5. **Have backup connectivity** (mobile hotspot, etc.)

## 📞 Getting Help

### Log Files to Check

```bash
# NetworkManager logs
journalctl -u NetworkManager

# System logs
journalctl -xe
dmesg | grep -i network

# Kernel ring buffer
dmesg | tail -50
```

### Information to Gather

When seeking help, provide:
- Output of `ip addr show`
- Output of `ip route show`
- Contents of `/etc/resolv.conf`
- Output of `ping 8.8.8.8`
- Relevant log entries

---

*Network issues can be complex, but systematic troubleshooting usually identifies the problem. Start with basic connectivity tests and work your way up the network stack.* 