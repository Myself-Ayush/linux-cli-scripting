# Popular Linux Distributions Guide 🐧

## Overview of Major Linux Distributions

### 1. **Ubuntu** (Debian-based)
- **Based on**: Debian
- **Package Manager**: APT (Advanced Package Tool)
- **Package Format**: .deb
- **Release Cycle**: Every 6 months (LTS every 2 years)
- **Target Users**: Beginners, Desktop users, Servers

#### Package Management Commands:
```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade

# Install package
sudo apt install package_name

# Remove package
sudo apt remove package_name

# Remove package and config files
sudo apt purge package_name

# Search for packages
apt search keyword

# Show package info
apt show package_name

# List installed packages
apt list --installed

# Clean package cache
sudo apt autoremove
sudo apt autoclean

# Fix broken packages
sudo apt --fix-broken install

# Add PPA repository
sudo add-apt-repository ppa:repository_name

# Install .deb file
sudo dpkg -i package.deb
```

---

### 2. **Fedora** (Red Hat-based)
- **Based on**: Red Hat
- **Package Manager**: DNF (Dandified YUM)
- **Package Format**: .rpm
- **Release Cycle**: Every 6 months
- **Target Users**: Developers, Latest technology enthusiasts

#### Package Management Commands:
```bash
# Update package list and upgrade
sudo dnf update

# Install package
sudo dnf install package_name

# Remove package
sudo dnf remove package_name

# Search for packages
dnf search keyword

# Show package info
dnf info package_name

# List installed packages
dnf list installed

# List available packages
dnf list available

# Clean package cache
sudo dnf clean all

# Install group of packages
sudo dnf groupinstall "Development Tools"

# List package groups
dnf grouplist

# Install local RPM
sudo dnf install package.rpm

# Enable repository
sudo dnf config-manager --enable repository_name

# Add repository
sudo dnf config-manager --add-repo repository_url
```

---

### 3. **CentOS/RHEL** (Red Hat Enterprise Linux)
- **Based on**: Red Hat
- **Package Manager**: YUM/DNF
- **Package Format**: .rpm
- **Release Cycle**: Long-term support
- **Target Users**: Enterprise, Servers

#### Package Management Commands:
```bash
# CentOS 7 (YUM)
sudo yum update
sudo yum install package_name
sudo yum remove package_name
sudo yum search keyword
yum info package_name

# CentOS 8+ (DNF) - same as Fedora
sudo dnf update
sudo dnf install package_name

# Enable EPEL repository
sudo yum install epel-release

# Install from RPM
sudo rpm -ivh package.rpm

# Query installed packages
rpm -qa | grep package_name
```

---

### 4. **Debian**
- **Based on**: Independent
- **Package Manager**: APT
- **Package Format**: .deb
- **Release Cycle**: Every 2-3 years
- **Target Users**: Servers, Stability-focused users

#### Package Management Commands:
```bash
# Same as Ubuntu (APT-based)
sudo apt update
sudo apt upgrade
sudo apt install package_name

# Debian-specific commands
sudo aptitude install package_name
sudo apt-cache search keyword

# Install from source
sudo apt-get build-dep package_name

# Hold package version
sudo apt-mark hold package_name

# Unhold package
sudo apt-mark unhold package_name
```

---

### 5. **Arch Linux**
- **Based on**: Independent
- **Package Manager**: Pacman
- **Package Format**: .pkg.tar.xz
- **Release Cycle**: Rolling release
- **Target Users**: Advanced users, Customization enthusiasts

#### Package Management Commands:
```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S package_name

# Remove package
sudo pacman -R package_name

# Remove package and dependencies
sudo pacman -Rs package_name

# Search for packages
pacman -Ss keyword

# Show package info
pacman -Si package_name

# List installed packages
pacman -Q

# List explicitly installed packages
pacman -Qe

# Clean package cache
sudo pacman -Sc

# Install from AUR (requires AUR helper like yay)
yay -S package_name

# Update AUR packages
yay -Syu

# Search in AUR
yay -Ss keyword
```

---

### 6. **openSUSE**
- **Based on**: Independent (SUSE)
- **Package Manager**: Zypper
- **Package Format**: .rpm
- **Release Cycle**: Rolling (Tumbleweed) / Regular (Leap)
- **Target Users**: Desktop users, Developers

#### Package Management Commands:
```bash
# Update system
sudo zypper update

# Install package
sudo zypper install package_name

# Remove package
sudo zypper remove package_name

# Search for packages
zypper search keyword

# Show package info
zypper info package_name

# List installed packages
zypper search --installed-only

# Add repository
sudo zypper addrepo repository_url

# List repositories
zypper repos

# Install pattern (group of packages)
sudo zypper install -t pattern pattern_name

# Clean cache
sudo zypper clean
```

---

### 7. **Manjaro** (Arch-based)
- **Based on**: Arch Linux
- **Package Manager**: Pacman + Pamac
- **Package Format**: .pkg.tar.xz
- **Release Cycle**: Rolling release
- **Target Users**: Arch benefits with easier setup

#### Package Management Commands:
```bash
# GUI package manager
pamac install package_name
pamac remove package_name
pamac search keyword

# Command line (same as Arch)
sudo pacman -Syu
sudo pacman -S package_name

# Manjaro-specific
sudo pacman-mirrors -g

# AUR support
pamac build package_name
```

---

### 8. **Linux Mint** (Ubuntu-based)
- **Based on**: Ubuntu/Debian
- **Package Manager**: APT
- **Package Format**: .deb
- **Release Cycle**: Based on Ubuntu LTS
- **Target Users**: Windows migrants, Desktop users

#### Package Management Commands:
```bash
# Same as Ubuntu
sudo apt update
sudo apt install package_name

# Mint-specific tools
mintinstall
mintupdate
mintsources
```

---

### 9. **Alpine Linux**
- **Based on**: Independent
- **Package Manager**: APK
- **Package Format**: .apk
- **Release Cycle**: Every 6 months
- **Target Users**: Containers, Security-focused

#### Package Management Commands:
```bash
# Update package index
apk update

# Install package
apk add package_name

# Remove package
apk del package_name

# Search packages
apk search keyword

# Show package info
apk info package_name

# List installed packages
apk info

# Upgrade system
apk upgrade
```

---

### 10. **Gentoo**
- **Based on**: Independent
- **Package Manager**: Portage (emerge)
- **Package Format**: Source-based
- **Release Cycle**: Rolling release
- **Target Users**: Advanced users, Performance enthusiasts

#### Package Management Commands:
```bash
# Update portage tree
emerge --sync

# Install package
emerge package_name

# Remove package
emerge --unmerge package_name

# Update system
emerge --update --deep --newuse @world

# Search packages
emerge --search keyword

# Show package info
emerge --info package_name

# Clean system
emerge --depclean
```

## Distribution Comparison Table

| Distribution | Base | Package Manager | Difficulty | Use Case |
|-------------|------|----------------|------------|----------|
| Ubuntu | Debian | APT | Beginner | Desktop, Server |
| Fedora | Red Hat | DNF | Intermediate | Development, Latest tech |
| CentOS/RHEL | Red Hat | YUM/DNF | Intermediate | Enterprise, Server |
| Debian | Independent | APT | Intermediate | Server, Stability |
| Arch | Independent | Pacman | Advanced | Customization |
| openSUSE | SUSE | Zypper | Intermediate | Desktop, Enterprise |
| Manjaro | Arch | Pacman/Pamac | Beginner-Int | Arch benefits, easier |
| Linux Mint | Ubuntu | APT | Beginner | Windows migration |
| Alpine | Independent | APK | Advanced | Containers, Security |
| Gentoo | Independent | Portage | Expert | Performance, Learning |

## Common Commands Across Distributions

### System Information
```bash
# Distribution info
cat /etc/os-release
lsb_release -a

# Kernel version
uname -r

# Architecture
uname -m

# System uptime
uptime

# Memory info
free -h

# Disk usage
df -h

# CPU info
lscpu
cat /proc/cpuinfo
```

### Service Management (systemd)
```bash
# Start service
sudo systemctl start service_name

# Stop service
sudo systemctl stop service_name

# Enable service (start at boot)
sudo systemctl enable service_name

# Disable service
sudo systemctl disable service_name

# Check service status
systemctl status service_name

# List all services
systemctl list-units --type=service

# Reload systemd configuration
sudo systemctl daemon-reload
```

### File Operations
```bash
# List files
ls -la

# Copy files
cp source destination

# Move/rename files
mv source destination

# Remove files
rm file_name
rm -rf directory_name

# Create directory
mkdir directory_name

# Change permissions
chmod 755 file_name

# Change ownership
chown user:group file_name

# Find files
find /path -name "filename"

# Search in files
grep "pattern" file_name
```

### Network Commands
```bash
# Show network interfaces
ip addr show
ifconfig

# Show routing table
ip route
route -n

# Test connectivity
ping hostname

# Show network connections
netstat -tuln
ss -tuln

# Download files
wget url
curl url

# SSH to remote host
ssh user@hostname
```

### Process Management
```bash
# Show running processes
ps aux
htop
top

# Kill process
kill PID
killall process_name

# Show process tree
pstree

# Background process
command &

# Bring to foreground
fg

# List jobs
jobs
```

This comprehensive guide should help you navigate different Linux distributions effectively!
