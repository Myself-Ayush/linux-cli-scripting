# Debian Family Distributions

Debian-based distributions are among the most popular Linux distributions, known for their stability, extensive package repositories, and strong community support.

## 🏗️ Distributions Covered

- **Debian** - The universal operating system
- **Ubuntu** - Desktop and server distribution
- **Linux Mint** - User-friendly desktop
- **Kali Linux** - Security and penetration testing
- **Raspberry Pi OS** - ARM-based distribution

## 📦 Package Management

### APT (Advanced Package Tool)

APT is the primary package management system for Debian-based distributions.

#### Basic Package Operations

```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full system upgrade (handles dependencies better)
sudo apt full-upgrade

# Install a package
sudo apt install package_name

# Install multiple packages
sudo apt install package1 package2 package3

# Remove a package (keep configuration files)
sudo apt remove package_name

# Remove package and configuration files
sudo apt purge package_name

# Remove unused packages
sudo apt autoremove

# Clean package cache
sudo apt autoclean
sudo apt clean
```

#### Package Information and Search

```bash
# Search for packages
apt search keyword
apt-cache search keyword

# Show package information
apt show package_name
apt-cache show package_name

# List installed packages
apt list --installed

# List upgradable packages
apt list --upgradable

# Show package dependencies
apt-cache depends package_name

# Show reverse dependencies
apt-cache rdepends package_name

# Check if package is installed
dpkg -l | grep package_name
```

#### Repository Management

```bash
# Add repository (Ubuntu/Debian)
sudo add-apt-repository ppa:repository/name

# Remove repository
sudo add-apt-repository --remove ppa:repository/name

# Edit sources list
sudo nano /etc/apt/sources.list

# List repositories
grep -r "^deb" /etc/apt/sources.list*

# Add GPG key for repository
wget -qO - https://example.com/key.gpg | sudo apt-key add -
```

### DPKG (Debian Package Manager)

Lower-level package management tool.

```bash
# Install .deb package
sudo dpkg -i package.deb

# Remove package
sudo dpkg -r package_name

# List installed packages
dpkg -l

# Show package contents
dpkg -L package_name

# Find which package owns a file
dpkg -S /path/to/file

# Check package status
dpkg -s package_name

# Fix broken dependencies
sudo apt --fix-broken install
```

### Snap Packages (Ubuntu)

```bash
# Install snap package
sudo snap install package_name

# List installed snaps
snap list

# Update all snaps
sudo snap refresh

# Remove snap
sudo snap remove package_name

# Find snaps
snap find keyword
```

### Flatpak (Universal Packages)

```bash
# Install flatpak
sudo apt install flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install application
flatpak install flathub app.name

# Run application
flatpak run app.name

# List installed apps
flatpak list

# Update apps
flatpak update
```

## 🖥️ Command Line Tools

### System Information

```bash
# System information
uname -a                    # Kernel information
lsb_release -a             # Distribution information
hostnamectl                # System hostname and info
uptime                     # System uptime
whoami                     # Current user
id                         # User and group IDs

# Hardware information
lscpu                      # CPU information
lsmem                      # Memory information
lsblk                      # Block devices
lsusb                      # USB devices
lspci                      # PCI devices
hwinfo --short             # Hardware summary
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
```

### User Management

```bash
# User operations
sudo adduser username      # Add new user
sudo deluser username      # Delete user
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

#### Netplan (Ubuntu 18.04+)

```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
# Apply netplan configuration
sudo netplan apply
sudo netplan try
```

#### Traditional Network Configuration

```bash
# /etc/network/interfaces (Debian)
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4

# Restart networking
sudo systemctl restart networking
```

### Firewall Configuration (UFW)

```bash
# Enable/disable firewall
sudo ufw enable
sudo ufw disable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow/deny rules
sudo ufw allow 22/tcp         # SSH
sudo ufw allow 80/tcp         # HTTP
sudo ufw allow 443/tcp        # HTTPS
sudo ufw deny 23/tcp          # Telnet

# Application profiles
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'

# Status and rules
sudo ufw status verbose
sudo ufw status numbered
sudo ufw delete 2             # Delete rule by number
```

### Cron Jobs

```bash
# Edit crontab
crontab -e

# List cron jobs
crontab -l

# System-wide cron
sudo nano /etc/crontab

# Cron directories
/etc/cron.daily/
/etc/cron.weekly/
/etc/cron.monthly/

# Cron format: minute hour day month weekday command
# Example: Run backup every day at 2 AM
0 2 * * * /path/to/backup.sh
```

## 🔧 Development Environment

### Build Tools

```bash
# Essential build tools
sudo apt install build-essential

# Development packages
sudo apt install git curl wget vim nano

# Compiler and tools
sudo apt install gcc g++ make cmake
sudo apt install python3 python3-pip
sudo apt install nodejs npm
sudo apt install default-jdk
```

### Version Control

```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Common Git operations
git clone repository_url
git add .
git commit -m "message"
git push origin main
git pull origin main
```

### Container Tools

```bash
# Docker installation
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce

# Docker commands
sudo docker run hello-world
sudo docker ps
sudo docker images
sudo usermod -aG docker $USER
```

## 🚨 Troubleshooting

### Common Issues

```bash
# Fix broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Clear package cache
sudo apt clean
sudo apt autoclean

# Reset package manager
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*

# Check disk space
df -h
sudo apt autoremove
sudo apt autoclean

# Network issues
sudo systemctl restart networking
sudo systemctl restart NetworkManager
```

### Log Files

```bash
# System logs
/var/log/syslog            # General system log
/var/log/auth.log          # Authentication log
/var/log/kern.log          # Kernel log
/var/log/apt/              # Package manager logs

# View logs
tail -f /var/log/syslog
journalctl -xe
dmesg | tail
```

## 📚 Distribution-Specific Notes

### Ubuntu
- Uses snap packages by default
- LTS versions supported for 5 years
- PPAs for additional software
- Unity/GNOME desktop environment

### Debian
- Stable, testing, unstable branches
- Very conservative release cycle
- Excellent server distribution
- Strong commitment to free software

### Linux Mint
- Based on Ubuntu LTS
- Cinnamon desktop environment
- Multimedia codecs included
- User-friendly for beginners

### Kali Linux
- Security and penetration testing tools
- Based on Debian testing
- Specialized package repository
- Not recommended for general use

---

*This guide covers the essential commands and concepts for Debian-based distributions. Practice these commands in a safe environment before using them on production systems.* 