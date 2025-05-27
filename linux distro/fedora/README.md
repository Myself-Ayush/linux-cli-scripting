# Fedora Linux

Fedora is a cutting-edge Linux distribution sponsored by Red Hat that showcases the latest in free and open-source software. It serves as the upstream for Red Hat Enterprise Linux and features the DNF package manager.

## 🏗️ Fedora Editions

- **Fedora Workstation** - Desktop edition with GNOME
- **Fedora Server** - Server edition for data centers
- **Fedora IoT** - Internet of Things edition
- **Fedora CoreOS** - Container-focused operating system
- **Fedora Silverblue** - Immutable desktop with Flatpak focus

## 📦 Package Management

### DNF (Dandified YUM)

DNF is the modern package manager for Fedora, replacing YUM.

#### Basic Package Operations

```bash
# Update package metadata
sudo dnf check-update

# Update all packages
sudo dnf update

# Upgrade to new Fedora version
sudo dnf system-upgrade download --releasever=XX
sudo dnf system-upgrade reboot

# Install a package
sudo dnf install package_name

# Install multiple packages
sudo dnf install package1 package2 package3

# Remove a package
sudo dnf remove package_name

# Remove package and dependencies
sudo dnf autoremove package_name

# Clean package cache
sudo dnf clean all

# Remove orphaned packages
sudo dnf autoremove
```

#### Package Information and Search

```bash
# Search for packages
dnf search keyword

# Show package information
dnf info package_name

# List installed packages
dnf list installed

# List available packages
dnf list available

# List upgradable packages
dnf list upgrades

# Show package dependencies
dnf repoquery --requires package_name

# Show what provides a file
dnf provides /path/to/file

# Show package history
dnf history

# Undo last transaction
sudo dnf history undo last
```

#### Repository Management

```bash
# List enabled repositories
dnf repolist

# List all repositories
dnf repolist --all

# Enable repository
sudo dnf config-manager --enable repository_name

# Disable repository
sudo dnf config-manager --disable repository_name

# Add repository
sudo dnf config-manager --add-repo https://example.com/repo.repo

# Install RPM Fusion repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### RPM (Red Hat Package Manager)

Lower-level package management tool.

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

### Flatpak (Default in Fedora)

```bash
# Flatpak is pre-installed in Fedora Workstation

# Install application
flatpak install flathub app.name

# Run application
flatpak run app.name

# List installed apps
flatpak list

# Update apps
flatpak update

# Remove app
flatpak uninstall app.name

# Add Flathub repository (if not present)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Snap Support

```bash
# Install snapd
sudo dnf install snapd

# Enable snapd
sudo systemctl enable --now snapd.socket

# Create symlink for classic snaps
sudo ln -s /var/lib/snapd/snap /snap

# Install snap package
sudo snap install package_name

# List installed snaps
snap list

# Update snaps
sudo snap refresh
```

## 🖥️ Command Line Tools

### System Information

```bash
# System information
uname -a                   # Kernel information
hostnamectl                # System hostname and info
uptime                     # System uptime
neofetch                   # Stylized system info
screenfetch                # Alternative system info

# Fedora-specific information
cat /etc/fedora-release    # Fedora version
rpm -q fedora-release      # Fedora release package

# Hardware information
lscpu                      # CPU information
lsmem                      # Memory information
lsblk                      # Block devices
lsusb                      # USB devices
lspci                      # PCI devices
hwinfo --short             # Hardware summary
inxi -Fxz                  # Comprehensive system info
```

### File System Operations

```bash
# Disk usage
df -h                      # Disk space usage
du -sh directory/          # Directory size
ncdu                       # Interactive disk usage

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

#### NetworkManager

```bash
# NetworkManager commands (default in Fedora)
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

# GUI network configuration
nm-connection-editor
```

### Firewall Configuration (firewalld)

```bash
# Firewalld is the default firewall in Fedora

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

# GUI firewall configuration
firewall-config
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
```

### Boot Configuration (GRUB2)

```bash
# Update GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# For UEFI systems
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Edit GRUB defaults
sudo nano /etc/default/grub

# Install GRUB to disk
sudo grub2-install /dev/sdX

# Set default boot entry
sudo grub2-set-default 0
```

### DNF Configuration

```bash
# DNF configuration
sudo nano /etc/dnf/dnf.conf

# Useful DNF settings
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
max_parallel_downloads=10
deltarpm=true
```

## 🔧 Development Environment

### Development Tools

```bash
# Development Tools group
sudo dnf groupinstall "Development Tools"

# Essential development packages
sudo dnf install git curl wget vim nano

# Compilers and build tools
sudo dnf install gcc gcc-c++ make cmake ninja-build
sudo dnf install python3 python3-pip python3-devel
sudo dnf install nodejs npm
sudo dnf install java-latest-openjdk java-latest-openjdk-devel
sudo dnf install rust cargo
sudo dnf install golang

# Additional development tools
sudo dnf install gdb valgrind strace
sudo dnf install autoconf automake libtool
```

### Version Control

```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Git GUI tools
sudo dnf install gitg git-cola

# Advanced Git tools
sudo dnf install tig
```

### Container and Virtualization

```bash
# Podman (default container engine in Fedora)
sudo dnf install podman podman-compose

# Docker (alternative)
sudo dnf install docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Buildah and Skopeo
sudo dnf install buildah skopeo

# VirtualBox
sudo dnf install VirtualBox

# QEMU/KVM
sudo dnf install qemu-kvm libvirt virt-manager
sudo systemctl enable libvirtd
sudo usermod -aG libvirt $USER
```

### Text Editors and IDEs

```bash
# Terminal editors
sudo dnf install vim neovim emacs

# GUI editors
sudo dnf install code          # Visual Studio Code
sudo dnf install gedit         # GNOME Text Editor

# IDEs
sudo dnf install eclipse-jdt   # Eclipse for Java
sudo dnf install qtcreator     # Qt Creator
```

### Programming Languages

```bash
# Python development
sudo dnf install python3-virtualenv python3-pip
sudo dnf install python3-numpy python3-scipy python3-matplotlib

# Node.js development
sudo dnf install nodejs npm yarn

# Java development
sudo dnf install maven gradle

# C/C++ development
sudo dnf install clang clang-tools-extra

# Rust development
sudo dnf install rust cargo

# Go development
sudo dnf install golang
```

## 🚨 Troubleshooting

### Common Issues

#### DNF Issues

```bash
# Clear DNF cache
sudo dnf clean all

# Rebuild DNF cache
sudo dnf makecache

# Fix broken dependencies
sudo dnf distro-sync

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
# Add "systemd.unit=rescue.target" to kernel parameters

# Reset root password
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
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Reset network configuration
sudo nmcli connection reload

# Check DNS resolution
nslookup google.com
dig google.com

# Flush DNS cache
sudo systemctl restart systemd-resolved
```

### Log Files and Debugging

```bash
# System logs
journalctl -xe             # Recent logs with explanations
journalctl -f              # Follow logs
journalctl -b              # Boot logs
journalctl -u service_name # Service-specific logs

# DNF logs
/var/log/dnf.log
/var/log/dnf.rpm.log

# SELinux logs
/var/log/audit/audit.log

# Kernel messages
dmesg | tail
dmesg | grep -i error

# Boot issues
journalctl -b -1           # Previous boot logs
```

## 📚 Fedora-Specific Tools

### System Maintenance

```bash
# Check for package updates
dnf check-update

# List installed packages by size
rpm -qa --queryformat '%{SIZE} %{NAME}\n' | sort -rn | head

# Find large files
find / -type f -size +100M 2>/dev/null

# Clean journal logs
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M

# Update firmware
sudo fwupdmgr refresh
sudo fwupdmgr update
```

### Performance Monitoring

```bash
# System monitoring
htop                       # Process monitor
iotop                      # I/O monitor
nethogs                    # Network monitor per process
powertop                   # Power consumption monitor

# Performance analysis
perf top                   # CPU profiling
perf record command        # Record performance data
perf report                # Analyze performance data
```

### Fedora-Specific Commands

```bash
# Fedora version information
cat /etc/fedora-release
rpm -q fedora-release

# List installed groups
dnf group list installed

# Install group
sudo dnf group install "Group Name"

# Remove group
sudo dnf group remove "Group Name"

# Show group information
dnf group info "Group Name"
```

## 🎯 Fedora Editions Notes

### Fedora Workstation
- GNOME desktop environment
- Wayland display server (default)
- Flatpak integration
- Developer-focused tools

### Fedora Server
- Minimal installation
- Cockpit web console
- Container-ready
- Enterprise features

### Fedora Silverblue
- Immutable operating system
- rpm-ostree for system updates
- Flatpak for applications
- Toolbox for development

### Fedora CoreOS
- Container-optimized
- Automatic updates
- Ignition for configuration
- Designed for clusters

## 🔄 Version Upgrade

```bash
# Upgrade to next Fedora version
sudo dnf upgrade --refresh
sudo dnf install dnf-plugin-system-upgrade
sudo dnf system-upgrade download --releasever=XX
sudo dnf system-upgrade reboot

# Check upgrade status
sudo dnf system-upgrade log

# Clean up after upgrade
sudo dnf system-upgrade clean
sudo dnf autoremove
```

---

*This guide covers the essential aspects of Fedora Linux. Fedora releases new versions every 6 months, so stay updated with the latest features and changes.* 