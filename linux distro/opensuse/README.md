# openSUSE Family

openSUSE is a Linux distribution sponsored by SUSE that offers both stable and rolling release versions. It's known for its excellent configuration tools, particularly YaST, and the powerful zypper package manager.

## 🏗️ Distributions Covered

- **openSUSE Leap** - Stable release based on SUSE Linux Enterprise
- **openSUSE Tumbleweed** - Rolling release with latest packages
- **openSUSE MicroOS** - Immutable OS for containers and edge computing
- **SUSE Linux Enterprise** - Commercial enterprise distribution

## 📦 Package Management

### Zypper Package Manager

Zypper is openSUSE's command-line package manager, known for its speed and dependency resolution.

#### Basic Package Operations

```bash
# Update package repositories
sudo zypper refresh
sudo zypper ref

# Update all packages
sudo zypper update
sudo zypper up

# Upgrade distribution
sudo zypper dist-upgrade
sudo zypper dup

# Install a package
sudo zypper install package_name
sudo zypper in package_name

# Install multiple packages
sudo zypper install package1 package2 package3

# Remove a package
sudo zypper remove package_name
sudo zypper rm package_name

# Remove package and dependencies
sudo zypper remove --clean-deps package_name

# Clean package cache
sudo zypper clean
sudo zypper clean --all
```

#### Package Information and Search

```bash
# Search for packages
zypper search keyword
zypper se keyword

# Search in package descriptions
zypper search -d keyword

# Show package information
zypper info package_name

# List installed packages
zypper search --installed-only
zypper se -i

# List available packages
zypper packages

# Show package dependencies
zypper info --requires package_name

# Show what provides a file
zypper what-provides /path/to/file
zypper wp /path/to/file

# Show package history
zypper history
```

#### Repository Management

```bash
# List repositories
zypper repos
zypper lr

# List repositories with details
zypper lr -d

# Add repository
sudo zypper addrepo URL alias
sudo zypper ar URL alias

# Add repository with auto-refresh
sudo zypper ar -f URL alias

# Remove repository
sudo zypper removerepo alias
sudo zypper rr alias

# Enable/disable repository
sudo zypper modifyrepo --enable alias
sudo zypper modifyrepo --disable alias

# Refresh specific repository
sudo zypper refresh alias
```

#### Advanced Zypper Operations

```bash
# Install from specific repository
sudo zypper install -r repository_alias package_name

# Download package without installing
zypper download package_name

# Install local RPM package
sudo zypper install package.rpm

# Verify package integrity
zypper verify

# List patches
zypper list-patches
zypper lp

# Install patches
sudo zypper patch

# Lock package (prevent updates)
sudo zypper addlock package_name

# Unlock package
sudo zypper removelock package_name

# List locked packages
zypper locks
```

### RPM Package Manager

```bash
# Install RPM package
sudo rpm -ivh package.rpm

# Upgrade RPM package
sudo rpm -Uvh package.rpm

# Remove RPM package
sudo rpm -e package_name

# Query installed packages
rpm -qa

# Query package information
rpm -qi package_name

# List package files
rpm -ql package_name

# Find which package owns a file
rpm -qf /path/to/file

# Verify package integrity
rpm -V package_name
```

### Flatpak Support

```bash
# Install flatpak
sudo zypper install flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install application
flatpak install flathub app.name

# List installed flatpaks
flatpak list

# Update flatpaks
flatpak update
```

## 🖥️ Command Line Tools

### System Information

```bash
# System information
uname -a                   # Kernel information
hostnamectl                # System hostname and info
uptime                     # System uptime

# openSUSE-specific information
cat /etc/os-release        # OS information
cat /etc/SuSE-release      # SUSE release info (older versions)
zypper --version           # Zypper version

# Hardware information
lscpu                      # CPU information
lsmem                      # Memory information
lsblk                      # Block devices
lsusb                      # USB devices
lspci                      # PCI devices
hwinfo --short             # Hardware summary (SUSE-specific)
hwinfo --cpu               # Detailed CPU info
hwinfo --memory            # Detailed memory info
```

### File System Operations

```bash
# Disk usage
df -h                      # Disk space usage
du -sh directory/          # Directory size

# File operations
ls -la                     # List files with details
find /path -name "pattern" # Find files
locate filename            # Quick file search
which command              # Find command location
whereis command            # Find command and manual

# File permissions
chmod 755 file             # Change permissions
chown user:group file      # Change ownership
chgrp group file           # Change group

# Extended attributes
getfattr file              # Get extended attributes
setfattr -n name -v value file # Set extended attribute
```

### Process Management

```bash
# Process information
ps aux                     # All running processes
top                        # Real-time process viewer
htop                       # Enhanced process viewer
pgrep process_name         # Find process by name
pidof process_name         # Get process ID

# Process control
kill PID                   # Terminate process
killall process_name       # Kill all instances
pkill process_name         # Kill by name
nohup command &            # Run command in background
jobs                       # List background jobs
fg %1                      # Bring job to foreground
```

### Network Tools

```bash
# Network information
ip addr show               # Network interfaces
ip route show              # Routing table
ss -tuln                   # Network connections
netstat -tuln              # Network connections (legacy)

# Network testing
ping hostname              # Test connectivity
traceroute hostname        # Trace network path
nslookup hostname          # DNS lookup
dig hostname               # DNS information

# Network configuration
sudo ip addr add IP/MASK dev interface
sudo ip route add default via GATEWAY
```

### Service Management (systemd)

```bash
# Service control
sudo systemctl start service_name
sudo systemctl stop service_name
sudo systemctl restart service_name
sudo systemctl reload service_name

# Service status
systemctl status service_name
systemctl is-active service_name
systemctl is-enabled service_name

# Enable/disable services
sudo systemctl enable service_name
sudo systemctl disable service_name

# List services
systemctl list-units --type=service
systemctl list-unit-files --type=service

# View logs
journalctl -u service_name
journalctl -f              # Follow logs
journalctl -b              # Boot logs
```

## ⚙️ System Configuration

### YaST (Yet another Setup Tool)

YaST is openSUSE's comprehensive system configuration tool.

#### YaST Modules

```bash
# Launch YaST control center
sudo yast2

# Network configuration
sudo yast2 lan

# User management
sudo yast2 users

# Software management
sudo yast2 sw_single

# System services
sudo yast2 services-manager

# Firewall configuration
sudo yast2 firewall

# Boot loader configuration
sudo yast2 bootloader

# Partitioning
sudo yast2 disk

# Printer configuration
sudo yast2 printer

# Time and date
sudo yast2 timezone

# Language settings
sudo yast2 language

# Security settings
sudo yast2 security

# System backup
sudo yast2 system_backup
```

#### YaST Command Line Tools

```bash
# List available YaST modules
yast2 --list

# Get help for a module
yast2 module_name --help

# Non-interactive mode
yast2 module_name --ncurses

# Text mode interface
yast2 --ncurses
```

### Network Configuration

#### NetworkManager

```bash
# NetworkManager commands
nmcli device status        # Show network devices
nmcli connection show      # Show connections
nmcli device wifi list    # List WiFi networks

# Connect to WiFi
nmcli device wifi connect SSID password PASSWORD

# Create static IP connection
nmcli connection add type ethernet con-name static-eth0 ifname eth0 \
  ip4 192.168.1.100/24 gw4 192.168.1.1

# Modify connection
nmcli connection modify static-eth0 ipv4.dns "8.8.8.8 8.8.4.4"

# Activate connection
nmcli connection up static-eth0
```

#### Wicked (openSUSE's network manager)

```bash
# Show network configuration
wicked show all

# Bring interface up
sudo wicked ifup eth0

# Bring interface down
sudo wicked ifdown eth0

# Reload configuration
sudo wicked ifreload eth0

# Configuration files location
/etc/sysconfig/network/
```

### Firewall Configuration (SuSEfirewall2/firewalld)

#### firewalld (openSUSE Leap 15+)

```bash
# Check firewall status
sudo firewall-cmd --state

# List all zones
sudo firewall-cmd --get-zones

# Get default zone
sudo firewall-cmd --get-default-zone

# List services in zone
sudo firewall-cmd --list-services

# Add service
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent

# Add port
sudo firewall-cmd --add-port=8080/tcp --permanent

# Reload firewall
sudo firewall-cmd --reload
```

#### SuSEfirewall2 (older versions)

```bash
# Start/stop firewall
sudo systemctl start SuSEfirewall2
sudo systemctl stop SuSEfirewall2

# Configuration file
/etc/sysconfig/SuSEfirewall2

# Restart firewall after configuration changes
sudo systemctl restart SuSEfirewall2
```

### Boot Configuration

#### GRUB2

```bash
# Update GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Edit GRUB defaults
sudo nano /etc/default/grub

# Install GRUB to disk
sudo grub2-install /dev/sdX

# Set default boot entry
sudo grub2-set-default 0

# YaST bootloader configuration
sudo yast2 bootloader
```

### Package Repository Configuration

```bash
# Main openSUSE repositories
# OSS (Open Source Software)
sudo zypper ar -f http://download.opensuse.org/distribution/leap/15.4/repo/oss/ OSS

# Non-OSS
sudo zypper ar -f http://download.opensuse.org/distribution/leap/15.4/repo/non-oss/ Non-OSS

# Update repositories
sudo zypper ar -f http://download.opensuse.org/update/leap/15.4/oss/ Update-OSS
sudo zypper ar -f http://download.opensuse.org/update/leap/15.4/non-oss/ Update-Non-OSS

# Packman repository (multimedia)
sudo zypper ar -f http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.4/ Packman

# Refresh repositories
sudo zypper refresh
```

## 🔧 Development Environment

### Development Tools

```bash
# Development patterns
sudo zypper install -t pattern devel_basis
sudo zypper install -t pattern devel_C_C++
sudo zypper install -t pattern devel_python3

# Essential development packages
sudo zypper install git curl wget vim nano

# Compilers and build tools
sudo zypper install gcc gcc-c++ make cmake
sudo zypper install python3 python3-pip python3-devel
sudo zypper install nodejs npm
sudo zypper install java-11-openjdk java-11-openjdk-devel

# Additional development tools
sudo zypper install gdb valgrind strace
sudo zypper install autoconf automake libtool
```

### Version Control

```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Git GUI tools
sudo zypper install gitg git-cola

# Advanced Git tools
sudo zypper install tig
```

### Container and Virtualization

```bash
# Docker
sudo zypper install docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Podman
sudo zypper install podman podman-compose

# VirtualBox
sudo zypper install virtualbox

# QEMU/KVM
sudo zypper install qemu-kvm libvirt virt-manager
sudo systemctl enable libvirtd
sudo usermod -aG libvirt $USER

# Install virtualization pattern
sudo zypper install -t pattern kvm_server
sudo zypper install -t pattern kvm_tools
```

### Text Editors and IDEs

```bash
# Terminal editors
sudo zypper install vim neovim emacs

# GUI editors
sudo zypper install code          # Visual Studio Code
sudo zypper install gedit         # GNOME Text Editor

# IDEs
sudo zypper install eclipse       # Eclipse IDE
sudo zypper install qtcreator     # Qt Creator
sudo zypper install kdevelop      # KDevelop
```

## 🚨 Troubleshooting

### Common Issues

#### Zypper Issues

```bash
# Clear zypper cache
sudo zypper clean --all

# Rebuild zypper cache
sudo zypper refresh

# Fix broken dependencies
sudo zypper verify

# Check for conflicts
zypper search --conflicts

# Force refresh repositories
sudo zypper refresh -f

# Repair package database
sudo rpm --rebuilddb
```

#### System Recovery

```bash
# Boot into rescue mode
# Add "systemd.unit=rescue.target" to kernel parameters

# Reset root password
# Boot with "init=/bin/bash" parameter
mount -o remount,rw /
passwd root
mount -o remount,ro /
reboot

# Check filesystem
sudo fsck /dev/sdXY

# Repair GRUB
sudo grub2-install /dev/sdX
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

#### Network Issues

```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Restart wicked
sudo systemctl restart wicked

# Reset network configuration
sudo wicked ifreload all

# Check DNS resolution
nslookup google.com
dig google.com
```

### Log Files and Debugging

```bash
# System logs
journalctl -xe             # Recent logs with explanations
journalctl -f              # Follow logs
journalctl -b              # Boot logs
journalctl -u service_name # Service-specific logs

# Zypper logs
/var/log/zypper.log

# YaST logs
/var/log/YaST2/

# Kernel messages
dmesg | tail
dmesg | grep -i error

# Boot issues
journalctl -b -1           # Previous boot logs
```

## 📚 openSUSE-Specific Tools

### System Maintenance

```bash
# Check for package updates
zypper list-updates
zypper lu

# List installed patterns
zypper search -t pattern --installed-only

# Install pattern
sudo zypper install -t pattern pattern_name

# Remove pattern
sudo zypper remove -t pattern pattern_name

# System information
hwinfo --short             # Hardware information
SUSEConnect --status       # Registration status (SLES)

# Clean up old kernels
sudo zypper search -s 'kernel-*'
sudo zypper remove old_kernel_package
```

### Performance Monitoring

```bash
# System monitoring tools
sudo zypper install htop iotop nethogs

# Performance analysis
sudo zypper install perf sysstat

# System activity reporter
sar -u 1 10                # CPU usage
sar -r 1 10                # Memory usage
sar -d 1 10                # Disk I/O
```

### openSUSE Build Service (OBS)

```bash
# Install OBS client tools
sudo zypper install osc

# Configure OBS
osc config

# Search for packages in OBS
osc search package_name

# Add OBS repository
sudo zypper ar obs://Project:Name/openSUSE_Leap_15.4 alias
```

## 🎯 Distribution-Specific Notes

### openSUSE Leap
- Stable release based on SUSE Linux Enterprise
- Regular release cycle (annual major releases)
- Long-term support
- Conservative package selection
- Excellent for servers and workstations

### openSUSE Tumbleweed
- Rolling release distribution
- Latest packages and kernel
- Automated testing before release
- Snapshot system for rollbacks
- Ideal for developers and enthusiasts

### openSUSE MicroOS
- Immutable operating system
- Designed for containers and edge computing
- Transactional updates
- Minimal base system
- Self-healing capabilities

### SUSE Linux Enterprise
- Commercial enterprise distribution
- Long-term support (10+ years)
- Certified hardware and software
- Professional support from SUSE
- Based on openSUSE Leap

## 🔄 Version Upgrade

### openSUSE Leap Upgrade

```bash
# Upgrade to next version
sudo zypper refresh
sudo zypper dup --releasever=15.5

# Alternative method using zypper
sudo zypper ar http://download.opensuse.org/distribution/leap/15.5/repo/oss/ Leap-15.5-OSS
sudo zypper dup --from Leap-15.5-OSS

# Clean up old repositories
sudo zypper lr
sudo zypper rr old_repository_alias
```

### openSUSE Tumbleweed Upgrade

```bash
# Regular update (rolling release)
sudo zypper dup

# Update with vendor change (if needed)
sudo zypper dup --allow-vendor-change
```

## 🔧 Snapper (Snapshot Management)

```bash
# List snapshots
sudo snapper list

# Create snapshot
sudo snapper create --description "Before update"

# Compare snapshots
sudo snapper diff 1..2

# Rollback to snapshot
sudo snapper rollback 1

# Delete snapshot
sudo snapper delete 2

# Configure snapper
sudo snapper -c root create-config /
```

---

*This guide covers the essential aspects of openSUSE distributions. openSUSE is known for its excellent tools like YaST and its robust package management with zypper.* 