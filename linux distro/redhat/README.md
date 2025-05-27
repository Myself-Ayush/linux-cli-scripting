# Red Hat Enterprise Linux Family

Red Hat Enterprise Linux (RHEL) is a commercial Linux distribution designed for enterprise environments. This family includes RHEL and its community-supported derivatives.

## 🏗️ Distributions Covered

- **Red Hat Enterprise Linux (RHEL)** - Commercial enterprise distribution
- **CentOS Stream** - Upstream for RHEL development
- **Rocky Linux** - Community-driven RHEL rebuild
- **AlmaLinux** - RHEL-compatible enterprise distribution
- **Oracle Linux** - Oracle's RHEL-compatible distribution

## 📦 Package Management

### YUM/DNF Package Manager

RHEL 8+ uses DNF, while RHEL 7 uses YUM. Commands are largely compatible.

#### Basic Package Operations

```bash
# Update package metadata (RHEL 8+)
sudo dnf check-update
# RHEL 7
sudo yum check-update

# Update all packages
sudo dnf update
sudo yum update

# Install a package
sudo dnf install package_name
sudo yum install package_name

# Install multiple packages
sudo dnf install package1 package2 package3
sudo yum install package1 package2 package3

# Remove a package
sudo dnf remove package_name
sudo yum remove package_name

# Remove package and dependencies
sudo dnf autoremove package_name
sudo yum autoremove package_name

# Clean package cache
sudo dnf clean all
sudo yum clean all

# Remove orphaned packages
sudo dnf autoremove
sudo yum autoremove
```

#### Package Information and Search

```bash
# Search for packages
dnf search keyword
yum search keyword

# Show package information
dnf info package_name
yum info package_name

# List installed packages
dnf list installed
yum list installed

# List available packages
dnf list available
yum list available

# Show package dependencies
dnf repoquery --requires package_name
yum deplist package_name

# Show what provides a file
dnf provides /path/to/file
yum provides /path/to/file

# Show package history
dnf history
yum history

# Undo last transaction
sudo dnf history undo last
sudo yum history undo last
```

#### Repository Management

```bash
# List enabled repositories
dnf repolist
yum repolist

# List all repositories
dnf repolist --all
yum repolist all

# Enable repository
sudo dnf config-manager --enable repository_name
sudo yum-config-manager --enable repository_name

# Disable repository
sudo dnf config-manager --disable repository_name
sudo yum-config-manager --disable repository_name

# Add repository
sudo dnf config-manager --add-repo https://example.com/repo.repo
sudo yum-config-manager --add-repo https://example.com/repo.repo

# Install EPEL repository (Extra Packages for Enterprise Linux)
sudo dnf install epel-release
sudo yum install epel-release
```

### RPM (Red Hat Package Manager)

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

# Import GPG key
sudo rpm --import https://example.com/RPM-GPG-KEY
```

### Subscription Management (RHEL)

```bash
# Register system with Red Hat
sudo subscription-manager register --username=username

# Attach subscription
sudo subscription-manager attach --auto

# List available subscriptions
subscription-manager list --available

# List consumed subscriptions
subscription-manager list --consumed

# Refresh subscriptions
sudo subscription-manager refresh

# Unregister system
sudo subscription-manager unregister
```

## 🖥️ Command Line Tools

### System Information

```bash
# System information
uname -a                   # Kernel information
hostnamectl                # System hostname and info
uptime                     # System uptime

# RHEL-specific information
cat /etc/redhat-release    # RHEL version
cat /etc/os-release        # Detailed OS information
rpm -q redhat-release      # RHEL release package

# Hardware information
lscpu                      # CPU information
lsmem                      # Memory information
lsblk                      # Block devices
lsusb                      # USB devices
lspci                      # PCI devices
dmidecode                  # Hardware details from DMI
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

# SELinux context
ls -Z file                 # Show SELinux context
chcon -t type file         # Change SELinux type
restorecon file            # Restore default context
```

### Process Management

```bash
# Process information
ps aux                     # All running processes
top                        # Real-time process viewer
htop                       # Enhanced process viewer (if installed)
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

### Service Management

#### systemd (RHEL 7+)

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

#### SysV Init (RHEL 6 and earlier)

```bash
# Service control
sudo service service_name start
sudo service service_name stop
sudo service service_name restart
sudo service service_name status

# Enable/disable services
sudo chkconfig service_name on
sudo chkconfig service_name off

# List services
chkconfig --list
```

### User Management

```bash
# User operations
sudo useradd -m username   # Add new user with home directory
sudo userdel -r username   # Delete user and home directory
sudo usermod -aG group user # Add user to group
groups username            # Show user groups

# Password management
passwd                     # Change own password
sudo passwd username       # Change user password
sudo passwd -l username    # Lock user account
sudo passwd -u username    # Unlock user account

# Switch users
su username                # Switch to user
sudo -u username command   # Run command as user
sudo -i                    # Switch to root
```

## ⚙️ System Configuration

### Network Configuration

#### NetworkManager (RHEL 7+)

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

#### Traditional Network Configuration (RHEL 6)

```bash
# Network configuration files
/etc/sysconfig/network-scripts/ifcfg-eth0

# Example static configuration
DEVICE=eth0
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
ONBOOT=yes

# Restart networking
sudo service network restart
```

### Firewall Configuration

#### firewalld (RHEL 7+)

```bash
# Check firewall status
sudo firewall-cmd --state

# List all zones
sudo firewall-cmd --get-zones

# Get default zone
sudo firewall-cmd --get-default-zone

# Set default zone
sudo firewall-cmd --set-default-zone=public

# List services in zone
sudo firewall-cmd --list-services

# Add service
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent

# Add port
sudo firewall-cmd --add-port=8080/tcp --permanent

# Remove service
sudo firewall-cmd --remove-service=http --permanent

# Reload firewall
sudo firewall-cmd --reload
```

#### iptables (RHEL 6)

```bash
# List rules
sudo iptables -L

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
sudo service iptables save

# Start iptables service
sudo chkconfig iptables on
sudo service iptables start
```

### SELinux Configuration

```bash
# SELinux status
sestatus

# Get SELinux mode
getenforce

# Set SELinux mode temporarily
sudo setenforce 0          # Permissive
sudo setenforce 1          # Enforcing

# Set SELinux mode permanently
sudo nano /etc/selinux/config
# SELINUX=enforcing|permissive|disabled

# SELinux contexts
ls -Z                      # Show file contexts
ps -Z                      # Show process contexts

# Manage SELinux booleans
getsebool -a               # List all booleans
sudo setsebool boolean_name on
sudo setsebool -P boolean_name on  # Persistent

# SELinux troubleshooting
sudo ausearch -m avc -ts recent
sudo sealert -a /var/log/audit/audit.log

# Install SELinux tools
sudo dnf install setroubleshoot-server
sudo yum install setroubleshoot-server
```

### Boot Configuration

#### GRUB2 (RHEL 7+)

```bash
# Update GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# For UEFI systems
sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

# Edit GRUB defaults
sudo nano /etc/default/grub

# Install GRUB to disk
sudo grub2-install /dev/sdX

# Set default boot entry
sudo grub2-set-default 0
```

#### GRUB Legacy (RHEL 6)

```bash
# GRUB configuration file
/boot/grub/grub.conf

# Install GRUB
sudo grub-install /dev/sdX
```

## 🔧 Development Environment

### Development Tools

```bash
# Development Tools group
sudo dnf groupinstall "Development Tools"
sudo yum groupinstall "Development Tools"

# Essential development packages
sudo dnf install git curl wget vim
sudo yum install git curl wget vim

# Compilers and build tools
sudo dnf install gcc gcc-c++ make cmake
sudo yum install gcc gcc-c++ make cmake

# Python development
sudo dnf install python3 python3-pip python3-devel
sudo yum install python3 python3-pip python3-devel

# Java development
sudo dnf install java-11-openjdk java-11-openjdk-devel
sudo yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Additional development tools
sudo dnf install gdb valgrind strace
sudo yum install gdb valgrind strace
```

### Version Control

```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install Git from EPEL (if needed)
sudo dnf install epel-release
sudo dnf install git
```

### Container Technologies

```bash
# Podman (RHEL 8+)
sudo dnf install podman podman-compose

# Docker (from Docker repository)
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Buildah and Skopeo
sudo dnf install buildah skopeo
```

### Virtualization

```bash
# KVM/QEMU
sudo dnf install qemu-kvm libvirt virt-manager
sudo yum install qemu-kvm libvirt virt-manager

# Enable libvirt
sudo systemctl enable libvirtd
sudo usermod -aG libvirt $USER

# VirtualBox (from EPEL or VirtualBox repository)
sudo dnf install VirtualBox
```

## 🚨 Troubleshooting

### Common Issues

#### Package Management Issues

```bash
# Clear package cache
sudo dnf clean all
sudo yum clean all

# Rebuild package cache
sudo dnf makecache
sudo yum makecache

# Fix broken dependencies
sudo dnf distro-sync
sudo yum distro-sync

# Check for duplicate packages
package-cleanup --dupes

# Remove duplicate packages
package-cleanup --cleandupes

# Verify package integrity
rpm -Va
```

#### System Recovery

```bash
# Boot into rescue mode
# Add "systemd.unit=rescue.target" to kernel parameters (RHEL 7+)
# Add "single" to kernel parameters (RHEL 6)

# Reset root password (RHEL 7+)
# Boot with "rd.break" parameter
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
exit
exit

# Fix SELinux contexts
sudo restorecon -R /

# Check filesystem
sudo fsck /dev/sdXY
```

#### Network Issues

```bash
# Restart NetworkManager (RHEL 7+)
sudo systemctl restart NetworkManager

# Restart network service (RHEL 6)
sudo service network restart

# Reset network configuration
sudo nmcli connection reload

# Check DNS resolution
nslookup google.com
dig google.com
```

### Log Files and Debugging

```bash
# System logs (RHEL 7+)
journalctl -xe             # Recent logs with explanations
journalctl -f              # Follow logs
journalctl -b              # Boot logs
journalctl -u service_name # Service-specific logs

# System logs (RHEL 6)
/var/log/messages          # General system log
/var/log/secure            # Authentication log
/var/log/boot.log          # Boot log

# Package manager logs
/var/log/dnf.log           # DNF logs (RHEL 8+)
/var/log/yum.log           # YUM logs (RHEL 7)

# SELinux logs
/var/log/audit/audit.log

# Kernel messages
dmesg | tail
dmesg | grep -i error
```

## 📚 RHEL-Specific Tools

### System Maintenance

```bash
# Check for package updates
dnf check-update
yum check-update

# List installed packages by size
rpm -qa --queryformat '%{SIZE} %{NAME}\n' | sort -rn | head

# Find large files
find / -type f -size +100M 2>/dev/null

# Clean journal logs (RHEL 7+)
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M

# System performance tuning
sudo dnf install tuned
sudo yum install tuned
sudo systemctl enable tuned
sudo tuned-adm recommend
sudo tuned-adm profile profile_name
```

### Performance Monitoring

```bash
# System monitoring tools
sudo dnf install htop iotop nethogs
sudo yum install htop iotop nethogs

# Performance analysis
sudo dnf install perf sysstat
sudo yum install perf sysstat

# System activity reporter
sar -u 1 10                # CPU usage
sar -r 1 10                # Memory usage
sar -d 1 10                # Disk I/O
```

### Red Hat Specific Commands

```bash
# Subscription information (RHEL)
subscription-manager status
subscription-manager list --consumed

# System registration (RHEL)
sudo subscription-manager register
sudo subscription-manager attach --auto

# Insights client (RHEL 8+)
sudo dnf install insights-client
sudo insights-client --register

# Satellite registration (if using Red Hat Satellite)
curl -O http://satellite.example.com/pub/bootstrap.py
python bootstrap.py
```

## 🎯 Distribution-Specific Notes

### Red Hat Enterprise Linux (RHEL)
- Commercial support from Red Hat
- Long-term support (10 years)
- Subscription-based licensing
- Enterprise-grade security and stability
- Certified hardware and software

### CentOS Stream
- Upstream for RHEL development
- Rolling release model
- Community-supported
- Free to use
- Closer to Fedora than traditional CentOS

### Rocky Linux
- Community-driven RHEL rebuild
- 1:1 binary compatibility with RHEL
- Free and open source
- Founded by CentOS original creator
- Enterprise-ready

### AlmaLinux
- RHEL-compatible distribution
- Backed by CloudLinux
- Free and open source
- 1:1 binary compatibility with RHEL
- Long-term support

### Oracle Linux
- Oracle's RHEL-compatible distribution
- Unbreakable Enterprise Kernel (UEK)
- Free to use and distribute
- Commercial support available
- Optimized for Oracle products

## 🔄 Version Upgrade

### RHEL 8+ Upgrade

```bash
# Upgrade to next minor version
sudo dnf update

# Upgrade to next major version (RHEL 8 to 9)
sudo dnf install leapp-upgrade
sudo leapp preupgrade
sudo leapp upgrade
sudo reboot
```

### RHEL 7 Upgrade

```bash
# Upgrade to next minor version
sudo yum update

# Major version upgrades require fresh installation
# or use Red Hat's upgrade tools
```

---

*This guide covers the essential aspects of Red Hat Enterprise Linux and its derivatives. Always consult the official Red Hat documentation for the most current information and best practices.* 