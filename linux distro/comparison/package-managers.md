# Package Manager Rosetta Stone

This guide provides equivalent commands across different Linux package managers, making it easier to switch between distributions or work with multiple systems.

## 📦 Package Manager Overview

| Distribution Family | Package Manager | Package Format | Configuration |
|-------------------|----------------|----------------|---------------|
| Debian/Ubuntu | APT + dpkg | .deb | /etc/apt/ |
| Arch/Manjaro | Pacman | .pkg.tar.xz | /etc/pacman.conf |
| Fedora | DNF | .rpm | /etc/dnf/ |
| RHEL/CentOS | YUM/DNF | .rpm | /etc/yum.conf, /etc/dnf/ |
| openSUSE | Zypper | .rpm | /etc/zypp/ |
| Gentoo | Portage | Source | /etc/portage/ |
| Alpine | APK | .apk | /etc/apk/ |
| Void | XBPS | .xbps | /etc/xbps.d/ |

## 🔄 Command Translation Table

### Package Installation

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| Install package | `sudo apt install pkg` | `sudo pacman -S pkg` | `sudo dnf install pkg` | `sudo yum install pkg` | `sudo zypper install pkg` |
| Install local package | `sudo dpkg -i pkg.deb` | `sudo pacman -U pkg.pkg.tar.xz` | `sudo dnf install pkg.rpm` | `sudo yum localinstall pkg.rpm` | `sudo zypper install pkg.rpm` |
| Install from URL | `wget url && sudo dpkg -i pkg.deb` | `sudo pacman -U url` | `sudo dnf install url` | `sudo yum install url` | `sudo zypper install url` |
| Reinstall package | `sudo apt install --reinstall pkg` | `sudo pacman -S pkg` | `sudo dnf reinstall pkg` | `sudo yum reinstall pkg` | `sudo zypper install --force pkg` |

### Package Removal

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| Remove package | `sudo apt remove pkg` | `sudo pacman -R pkg` | `sudo dnf remove pkg` | `sudo yum remove pkg` | `sudo zypper remove pkg` |
| Remove with config | `sudo apt purge pkg` | `sudo pacman -Rn pkg` | `sudo dnf remove pkg` | `sudo yum remove pkg` | `sudo zypper remove pkg` |
| Remove with deps | `sudo apt autoremove pkg` | `sudo pacman -Rs pkg` | `sudo dnf autoremove pkg` | `sudo yum autoremove pkg` | `sudo zypper remove --clean-deps pkg` |
| Remove orphans | `sudo apt autoremove` | `sudo pacman -Rns $(pacman -Qtdq)` | `sudo dnf autoremove` | `sudo yum autoremove` | `sudo zypper remove --clean-deps` |

### Package Updates

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| Update package list | `sudo apt update` | `sudo pacman -Sy` | `sudo dnf check-update` | `sudo yum check-update` | `sudo zypper refresh` |
| Upgrade all packages | `sudo apt upgrade` | `sudo pacman -Syu` | `sudo dnf update` | `sudo yum update` | `sudo zypper update` |
| Full system upgrade | `sudo apt full-upgrade` | `sudo pacman -Syu` | `sudo dnf distro-sync` | `sudo yum distro-sync` | `sudo zypper dup` |
| Upgrade specific package | `sudo apt install pkg` | `sudo pacman -S pkg` | `sudo dnf update pkg` | `sudo yum update pkg` | `sudo zypper update pkg` |

### Package Search and Information

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| Search packages | `apt search keyword` | `pacman -Ss keyword` | `dnf search keyword` | `yum search keyword` | `zypper search keyword` |
| Show package info | `apt show pkg` | `pacman -Si pkg` | `dnf info pkg` | `yum info pkg` | `zypper info pkg` |
| List installed | `apt list --installed` | `pacman -Q` | `dnf list installed` | `yum list installed` | `zypper search -i` |
| List available | `apt list` | `pacman -Sl` | `dnf list available` | `yum list available` | `zypper packages` |
| Show dependencies | `apt depends pkg` | `pacman -Si pkg` | `dnf repoquery --requires pkg` | `yum deplist pkg` | `zypper info --requires pkg` |

### Package Files and Ownership

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| List package files | `dpkg -L pkg` | `pacman -Ql pkg` | `rpm -ql pkg` | `rpm -ql pkg` | `rpm -ql pkg` |
| Find package owning file | `dpkg -S /path/file` | `pacman -Qo /path/file` | `dnf provides /path/file` | `yum provides /path/file` | `zypper search --provides /path/file` |
| Show package contents | `apt-file list pkg` | `pacman -Fl pkg` | `dnf repoquery -l pkg` | `repoquery -l pkg` | `zypper search --file-list pkg` |

### Repository Management

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| List repositories | `apt policy` | `pacman -Sl` | `dnf repolist` | `yum repolist` | `zypper repos` |
| Add repository | `sudo add-apt-repository ppa:name` | Edit `/etc/pacman.conf` | `sudo dnf config-manager --add-repo url` | `sudo yum-config-manager --add-repo url` | `sudo zypper addrepo url name` |
| Remove repository | `sudo add-apt-repository --remove ppa:name` | Edit `/etc/pacman.conf` | `sudo dnf config-manager --disable repo` | `sudo yum-config-manager --disable repo` | `sudo zypper removerepo name` |
| Enable repository | N/A | N/A | `sudo dnf config-manager --enable repo` | `sudo yum-config-manager --enable repo` | `sudo zypper modifyrepo --enable name` |

### Cache and Cleanup

| Action | APT (Debian/Ubuntu) | Pacman (Arch) | DNF (Fedora/RHEL 8+) | YUM (RHEL 7) | Zypper (openSUSE) |
|--------|-------------------|---------------|---------------------|--------------|------------------|
| Clean package cache | `sudo apt clean` | `sudo pacman -Sc` | `sudo dnf clean all` | `sudo yum clean all` | `sudo zypper clean` |
| Clean all cache | `sudo apt autoclean` | `sudo pacman -Scc` | `sudo dnf clean all` | `sudo yum clean all` | `sudo zypper clean --all` |
| Remove orphans | `sudo apt autoremove` | `sudo pacman -Rns $(pacman -Qtdq)` | `sudo dnf autoremove` | `sudo yum autoremove` | `sudo zypper remove --clean-deps` |

## 🔧 Advanced Package Manager Features

### APT (Debian/Ubuntu) Specific

```bash
# Hold package from updates
sudo apt-mark hold package_name

# Unhold package
sudo apt-mark unhold package_name

# Show held packages
apt-mark showhold

# Install specific version
sudo apt install package_name=version

# Show package changelog
apt changelog package_name

# Download source package
apt source package_name

# Build dependencies
sudo apt build-dep package_name
```

### Pacman (Arch) Specific

```bash
# Install from AUR (with helper like yay)
yay -S package_name

# List foreign packages (AUR)
pacman -Qm

# List explicitly installed packages
pacman -Qe

# Show package dependencies tree
pactree package_name

# Download package only
sudo pacman -Sw package_name

# Install package ignoring dependencies
sudo pacman -Sd package_name

# Remove package and all dependencies
sudo pacman -Rns package_name
```

### DNF (Fedora/RHEL) Specific

```bash
# Show transaction history
dnf history

# Undo last transaction
sudo dnf history undo last

# Install package group
sudo dnf group install "Group Name"

# List available groups
dnf group list

# Download package only
dnf download package_name

# Check for security updates
dnf updateinfo list security

# Install only security updates
sudo dnf update --security
```

### Zypper (openSUSE) Specific

```bash
# Install pattern
sudo zypper install -t pattern pattern_name

# List patterns
zypper search -t pattern

# Lock package
sudo zypper addlock package_name

# Unlock package
sudo zypper removelock package_name

# List patches
zypper list-patches

# Install patches
sudo zypper patch

# Verify package integrity
zypper verify
```

## 🌐 Universal Package Managers

### Flatpak Commands

```bash
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

# Add repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Snap Commands

```bash
# Install snap
sudo snap install package_name

# List installed snaps
snap list

# Update snaps
sudo snap refresh

# Remove snap
sudo snap remove package_name

# Find snaps
snap find keyword

# Show snap info
snap info package_name
```

### AppImage Commands

```bash
# Make executable
chmod +x application.AppImage

# Run application
./application.AppImage

# Install AppImageLauncher (Ubuntu/Debian)
sudo apt install appimagelauncher

# Extract AppImage
./application.AppImage --appimage-extract
```

## 🔍 Package Manager Comparison

### Speed Comparison (Typical)
1. **Pacman** - Fastest for most operations
2. **Zypper** - Fast with excellent dependency resolution
3. **APK** - Very fast, minimal overhead
4. **DNF** - Good performance, improved over YUM
5. **APT** - Reliable but can be slower
6. **Portage** - Slowest due to compilation

### Dependency Resolution
1. **Zypper** - Excellent conflict resolution
2. **DNF** - Strong dependency handling
3. **APT** - Mature and reliable
4. **Pacman** - Simple and effective
5. **Portage** - Complex but powerful

### Package Availability
1. **APT** - Largest repositories
2. **Pacman + AUR** - Extensive with user contributions
3. **DNF** - Good coverage with EPEL
4. **Zypper** - Solid package selection
5. **Portage** - Everything available as source

## 🚀 Quick Migration Tips

### From APT to Pacman
- `apt update` → `pacman -Sy`
- `apt upgrade` → `pacman -Syu`
- `apt install` → `pacman -S`
- `apt remove` → `pacman -R`
- `apt search` → `pacman -Ss`

### From YUM to DNF
- Most commands are identical
- `yum` → `dnf` in most cases
- DNF has better performance and features

### From APT to Zypper
- `apt update` → `zypper refresh`
- `apt upgrade` → `zypper update`
- `apt install` → `zypper install`
- `apt remove` → `zypper remove`
- `apt search` → `zypper search`

## 📚 Learning Resources

### Package Manager Documentation
- **APT**: `man apt`, `man apt-get`
- **Pacman**: `man pacman`, Arch Wiki
- **DNF**: `man dnf`, Fedora Documentation
- **Zypper**: `man zypper`, openSUSE Documentation
- **Portage**: `man emerge`, Gentoo Handbook

### Online Resources
- [Arch Wiki Package Management](https://wiki.archlinux.org/title/Pacman)
- [Debian Package Management](https://www.debian.org/doc/manuals/debian-reference/ch02.en.html)
- [Fedora Package Management](https://docs.fedoraproject.org/en-US/quick-docs/dnf/)
- [openSUSE Package Management](https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-sw-cl.html)

---

*This rosetta stone should help you quickly translate package management commands between different Linux distributions. Bookmark this page for quick reference when working with unfamiliar systems.* 