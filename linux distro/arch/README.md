# Arch Linux Family

Arch Linux is a lightweight and flexible Linux distribution that follows the KISS (Keep It Simple, Stupid) principle. It features a rolling release model and the powerful Pacman package manager.

## 🏗️ Distributions Covered

- **Arch Linux** - The original rolling release distribution
- **Manjaro** - User-friendly Arch derivative
- **EndeavourOS** - Arch-based with easier installation
- **ArcoLinux** - Educational Arch-based distribution
- **Garuda Linux** - Gaming-focused Arch derivative

## 📦 Package Management

### Pacman (Package Manager)

Pacman is Arch Linux's powerful package manager that handles binary packages from the official repositories.

#### Basic Package Operations

```bash
# Update package database
sudo pacman -Sy

# Upgrade all packages
sudo pacman -Syu

# Install a package
sudo pacman -S package_name

# Install multiple packages
sudo pacman -S package1 package2 package3

# Remove a package
sudo pacman -R package_name

# Remove package and dependencies
sudo pacman -Rs package_name

# Remove package, dependencies, and configuration files
sudo pacman -Rns package_name

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Clean package cache
sudo pacman -Sc

# Clean all package cache
sudo pacman -Scc
```

#### Package Information and Search

```bash
# Search for packages
pacman -Ss keyword

# Search installed packages
pacman -Qs keyword

# Show package information
pacman -Si package_name

# Show installed package information
pacman -Qi package_name

# List all installed packages
pacman -Q

# List explicitly installed packages
pacman -Qe

# List foreign packages (AUR)
pacman -Qm

# Show package files
pacman -Ql package_name

# Find which package owns a file
pacman -Qo /path/to/file

# Check for orphaned packages
pacman -Qtd
```

#### Advanced Pacman Operations

```bash
# Download package without installing
sudo pacman -Sw package_name

# Install local package
sudo pacman -U package.pkg.tar.xz

# Force reinstall package
sudo pacman -S --force package_name

# Ignore package updates
# Edit /etc/pacman.conf and add:
# IgnorePkg = package_name

# List package dependencies
pactree package_name

# Show reverse dependencies
pactree -r package_name
```

### AUR (Arch User Repository)

The AUR contains user-contributed packages not available in official repositories.

#### AUR Helpers

##### Yay (Yet Another Yaourt)

```bash
# Install yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Update system and AUR packages
yay -Syu

# Install AUR package
yay -S package_name

# Search AUR
yay -Ss keyword

# Remove AUR package
yay -R package_name

# Show AUR package info
yay -Si package_name

# Clean build cache
yay -Sc
```

##### Paru (Alternative AUR helper)

```bash
# Install paru
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Similar commands to yay
paru -Syu                  # Update system
paru -S package_name       # Install package
paru -Ss keyword           # Search packages
```

#### Manual AUR Installation

```bash
# Clone AUR package
git clone https://aur.archlinux.org/package_name.git
cd package_name

# Review PKGBUILD (IMPORTANT!)
nano PKGBUILD

# Build and install
makepkg -si

# Build without installing
makepkg

# Install built package
sudo pacman -U package_name.pkg.tar.xz
```

### Flatpak Support

```bash
# Install flatpak
sudo pacman -S flatpak

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
neofetch                   # Stylized system info
screenfetch                # Alternative system info

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
baobab                     # GUI disk usage analyzer

# File operations
ls -la                     # List files with details
find /path -name "pattern" # Find files
fd pattern                 # Modern find alternative
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
btop                       # Modern process viewer
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
speedtest-cli              # Internet speed test

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

#### systemd-networkd

```bash
# /etc/systemd/network/20-wired.network
[Match]
Name=enp1s0

[Network]
DHCP=yes

# Static configuration
[Match]
Name=enp1s0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
DNS=8.8.4.4

# Enable systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
```

### Firewall Configuration

#### iptables

```bash
# List rules
sudo iptables -L

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/iptables.rules

# Enable iptables service
sudo systemctl enable iptables
```

#### UFW (if installed)

```bash
# Install UFW
sudo pacman -S ufw

# Enable UFW
sudo ufw enable

# Basic rules
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Status
sudo ufw status verbose
```

### Boot Configuration

#### GRUB

```bash
# Update GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Edit GRUB defaults
sudo nano /etc/default/grub

# Install GRUB to disk
sudo grub-install /dev/sdX
```

#### systemd-boot

```bash
# Install systemd-boot
sudo bootctl install

# Update systemd-boot
sudo bootctl update

# Configuration file location
/boot/loader/loader.conf
/boot/loader/entries/
```

### Pacman Configuration

```bash
# Pacman configuration
sudo nano /etc/pacman.conf

# Enable multilib repository (32-bit packages)
[multilib]
Include = /etc/pacman.d/mirrorlist

# Enable color output
Color

# Enable parallel downloads
ParallelDownloads = 5

# Update mirrorlist
sudo reflector --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

## 🔧 Development Environment

### Base Development Tools

```bash
# Base development group
sudo pacman -S base-devel

# Essential tools
sudo pacman -S git curl wget vim nano

# Compilers and build tools
sudo pacman -S gcc clang make cmake ninja
sudo pacman -S python python-pip
sudo pacman -S nodejs npm
sudo pacman -S jdk-openjdk
sudo pacman -S rust cargo
sudo pacman -S go
```

### Version Control

```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install Git GUI tools
sudo pacman -S gitg git-cola

# Advanced Git tools
sudo pacman -S tig lazygit
```

### Container and Virtualization

```bash
# Docker
sudo pacman -S docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Podman (Docker alternative)
sudo pacman -S podman podman-compose

# VirtualBox
sudo pacman -S virtualbox virtualbox-host-modules-arch

# QEMU/KVM
sudo pacman -S qemu virt-manager libvirt
sudo systemctl enable libvirtd
```

### Text Editors and IDEs

```bash
# Terminal editors
sudo pacman -S vim neovim emacs

# GUI editors
sudo pacman -S code          # Visual Studio Code
sudo pacman -S atom          # Atom editor
sudo pacman -S sublime-text-4 # Sublime Text (AUR)

# IDEs
sudo pacman -S intellij-idea-community-edition
sudo pacman -S qtcreator
```

## 🚨 Troubleshooting

### Common Issues

#### Pacman Issues

```bash
# Fix corrupted package database
sudo rm /var/lib/pacman/db.lck
sudo pacman -Syu

# Reinstall all packages
sudo pacman -Qqn | sudo pacman -S -

# Fix keyring issues
sudo pacman -S archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Downgrade package
sudo pacman -U /var/cache/pacman/pkg/package-version.pkg.tar.xz
```

#### System Recovery

```bash
# Boot from Arch ISO and chroot
mount /dev/sdXY /mnt
arch-chroot /mnt

# Fix broken bootloader
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sdX

# Check filesystem
fsck /dev/sdXY

# Fix permissions
chmod 755 /
chmod 755 /usr
chmod 755 /usr/bin
```

#### Network Issues

```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Reset network configuration
sudo systemctl stop NetworkManager
sudo rm /etc/NetworkManager/system-connections/*
sudo systemctl start NetworkManager

# Manual network configuration
sudo ip link set dev interface up
sudo dhcpcd interface
```

### Log Files and Debugging

```bash
# System logs
journalctl -xe             # Recent logs with explanations
journalctl -f              # Follow logs
journalctl -b              # Boot logs
journalctl -u service_name # Service-specific logs

# Kernel messages
dmesg | tail
dmesg | grep -i error

# Package manager logs
/var/log/pacman.log

# Boot issues
journalctl -b -1           # Previous boot logs
```

## 📚 Arch-Specific Tools

### System Maintenance

```bash
# Check for orphaned packages
pacman -Qtd

# Check for broken symlinks
find /usr -xtype l

# Verify package integrity
sudo pacman -Qk

# Update file database
sudo updatedb

# Check system file integrity
sudo pacman -Qkk
```

### Performance Monitoring

```bash
# System monitoring
htop                       # Process monitor
iotop                      # I/O monitor
nethogs                    # Network monitor per process
powertop                   # Power consumption monitor

# Disk monitoring
iotop                      # I/O usage
iostat                     # I/O statistics
```

### Arch Wiki and Documentation

```bash
# Install arch-wiki-docs
sudo pacman -S arch-wiki-docs

# Access offline wiki
/usr/share/doc/arch-wiki/html/

# Man pages
man pacman
man makepkg
man PKGBUILD
```

## 🎯 Distribution-Specific Notes

### Arch Linux
- Rolling release model
- Minimal base installation
- Extensive documentation (Arch Wiki)
- DIY philosophy
- Bleeding-edge packages

### Manjaro
- User-friendly Arch derivative
- Stable branch with delayed updates
- Pre-configured desktop environments
- Hardware detection and drivers
- Pamac GUI package manager

### EndeavourOS
- Near-vanilla Arch experience
- Easier installation process
- Minimal pre-installed software
- Strong community support
- Arch repositories + EndeavourOS repo

---

*This guide covers the essential aspects of Arch Linux and its derivatives. Always consult the Arch Wiki for the most up-to-date and detailed information.* 