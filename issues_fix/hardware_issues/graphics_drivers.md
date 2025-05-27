# Graphics Driver Problems

Graphics driver issues are among the most common hardware problems in Linux. This guide covers diagnosis and solutions for NVIDIA, AMD, and Intel graphics cards.

## 🚨 Common Symptoms

- Black screen after boot
- Low resolution or incorrect display settings
- Poor graphics performance
- Screen tearing or flickering
- System freezes during graphics-intensive tasks
- No hardware acceleration
- Multiple monitor issues

## 🔍 Identifying Graphics Hardware

### Check Graphics Card Information

```bash
# List all graphics hardware
lspci | grep -E "VGA|3D|Display"

# Detailed graphics information
lshw -c display

# Check current driver
lsmod | grep -E "(nvidia|nouveau|amdgpu|radeon|i915)"

# Check OpenGL information
glxinfo | grep -E "(OpenGL vendor|OpenGL renderer|OpenGL version)"

# Check Vulkan support
vulkaninfo | head -20
```

### Check Current Graphics Status

```bash
# Check X11 configuration
cat /etc/X11/xorg.conf
ls /etc/X11/xorg.conf.d/

# Check Wayland session
echo $XDG_SESSION_TYPE

# Check display server logs
journalctl -u gdm  # GNOME
journalctl -u sddm # KDE
journalctl -u lightdm # XFCE/others

# Check Xorg logs
cat /var/log/Xorg.0.log | grep -E "(EE)|(\*\*)"
```

## 🔧 NVIDIA Graphics Solutions

### Install NVIDIA Proprietary Drivers

#### Ubuntu/Debian

```bash
# Check available drivers
ubuntu-drivers devices

# Install recommended driver
sudo ubuntu-drivers autoinstall

# Or install specific driver
sudo apt install nvidia-driver-470

# For older cards
sudo apt install nvidia-driver-390

# Install CUDA support (optional)
sudo apt install nvidia-cuda-toolkit
```

#### Fedora

```bash
# Enable RPM Fusion repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install NVIDIA drivers
sudo dnf install akmod-nvidia
sudo dnf install xorg-x11-drv-nvidia-cuda

# Wait for kernel module to build
sudo akmods --force
```

#### Arch Linux

```bash
# Install NVIDIA drivers
sudo pacman -S nvidia nvidia-utils

# For older cards
sudo pacman -S nvidia-390xx nvidia-390xx-utils

# Install CUDA
sudo pacman -S cuda
```

### Fix NVIDIA Issues

#### Black Screen After Driver Installation

```bash
# Boot into recovery mode or TTY (Ctrl+Alt+F2)

# Remove NVIDIA drivers
sudo apt purge nvidia-* # Ubuntu/Debian
sudo dnf remove nvidia-* # Fedora
sudo pacman -R nvidia nvidia-utils # Arch

# Reinstall with different version
sudo apt install nvidia-driver-460 # Ubuntu/Debian

# Check for conflicting drivers
lsmod | grep nouveau
# If nouveau is loaded, blacklist it:
echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u
```

#### NVIDIA Settings Not Working

```bash
# Install NVIDIA control panel
sudo apt install nvidia-settings # Ubuntu/Debian
sudo dnf install nvidia-settings # Fedora
sudo pacman -S nvidia-settings # Arch

# Run as root for system-wide changes
sudo nvidia-settings

# Generate xorg.conf
sudo nvidia-xconfig
```

#### Performance Issues

```bash
# Check NVIDIA GPU status
nvidia-smi

# Set performance mode
sudo nvidia-settings -a [gpu:0]/GpuPowerMizerMode=1

# Enable coolbits for overclocking
sudo nvidia-xconfig --cool-bits=28
```

## 🔧 AMD Graphics Solutions

### Install AMD Drivers

#### Modern AMD Cards (AMDGPU)

```bash
# Ubuntu/Debian - usually works out of box
sudo apt install mesa-vulkan-drivers libvulkan1

# Fedora
sudo dnf install mesa-vulkan-drivers vulkan-tools

# Arch Linux
sudo pacman -S mesa vulkan-radeon libva-mesa-driver
```

#### Older AMD Cards (Radeon)

```bash
# Ubuntu/Debian
sudo apt install xserver-xorg-video-radeon

# Fedora
sudo dnf install xorg-x11-drv-ati

# Arch Linux
sudo pacman -S xf86-video-ati
```

### Fix AMD Issues

#### Enable AMDGPU for Older Cards

```bash
# Add kernel parameter
sudo nano /etc/default/grub
# Add to GRUB_CMDLINE_LINUX_DEFAULT:
# amdgpu.si_support=1 amdgpu.cik_support=1 radeon.si_support=0 radeon.cik_support=0

# Update GRUB
sudo update-grub # Ubuntu/Debian
sudo grub2-mkconfig -o /boot/grub2/grub.cfg # Fedora
sudo grub-mkconfig -o /boot/grub/grub.cfg # Arch
```

#### AMD Performance Tuning

```bash
# Install AMD GPU tools
sudo apt install radeontop # Ubuntu/Debian
sudo dnf install radeontop # Fedora
sudo pacman -S radeontop # Arch

# Monitor GPU usage
radeontop

# Set GPU performance profile
echo "high" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level
```

## 🔧 Intel Graphics Solutions

### Install Intel Drivers

```bash
# Ubuntu/Debian - usually pre-installed
sudo apt install intel-media-va-driver i965-va-driver

# Fedora
sudo dnf install intel-media-driver libva-intel-driver

# Arch Linux
sudo pacman -S intel-media-driver libva-intel-driver
```

### Fix Intel Graphics Issues

#### Enable Hardware Acceleration

```bash
# Check VA-API support
vainfo

# Install additional codecs
sudo apt install intel-media-va-driver-non-free # Ubuntu/Debian

# For older Intel graphics
sudo apt install i965-va-driver
```

#### Fix Screen Tearing

```bash
# Create Intel configuration file
sudo nano /etc/X11/xorg.conf.d/20-intel.conf

# Add content:
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
EndSection
```

## 🔧 General Graphics Fixes

### Fix Resolution Issues

```bash
# Check available resolutions
xrandr

# Set resolution manually
xrandr --output HDMI-1 --mode 1920x1080

# Add custom resolution
cvt 1920 1080 60  # Generate modeline
xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
xrandr --addmode HDMI-1 "1920x1080_60.00"
xrandr --output HDMI-1 --mode "1920x1080_60.00"
```

### Fix Multiple Monitor Issues

```bash
# List connected displays
xrandr --listmonitors

# Configure dual monitors
xrandr --output HDMI-1 --mode 1920x1080 --pos 1920x0 --output eDP-1 --mode 1920x1080 --pos 0x0

# Save configuration
# Create ~/.xprofile or add to display manager configuration
```

### Fix Screen Tearing

```bash
# Enable compositor (if using X11)
# GNOME: Usually enabled by default
# KDE: System Settings -> Display -> Compositor
# XFCE: Settings -> Window Manager Tweaks -> Compositor

# For NVIDIA with X11
sudo nvidia-settings
# Enable "Force Composition Pipeline"

# For AMD/Intel
# Add to xorg.conf:
Option "TearFree" "true"
```

## 🔧 Advanced Troubleshooting

### Rebuild Graphics Drivers

```bash
# NVIDIA (if using DKMS)
sudo dkms remove nvidia/470.86 --all
sudo dkms install nvidia/470.86

# AMD (rebuild initramfs)
sudo update-initramfs -u # Ubuntu/Debian
sudo dracut --force # Fedora
sudo mkinitcpio -P # Arch
```

### Switch Between Drivers

#### NVIDIA/Nouveau Switching

```bash
# Switch to Nouveau (open source)
sudo apt install xserver-xorg-video-nouveau
# Remove nvidia from /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

# Switch back to NVIDIA
sudo apt install nvidia-driver-470
echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u
```

#### Hybrid Graphics (Optimus/Prime)

```bash
# Install Prime utilities
sudo apt install nvidia-prime # Ubuntu

# Switch to NVIDIA
sudo prime-select nvidia

# Switch to Intel
sudo prime-select intel

# Check current GPU
prime-select query

# For newer systems with GPU switching
# Install optimus-manager (Arch) or similar tools
```

### Debug Graphics Issues

```bash
# Check kernel messages
dmesg | grep -E "(drm|gpu|nvidia|amdgpu|i915)"

# Check graphics memory
cat /proc/meminfo | grep -i gpu

# Test OpenGL
glxgears -info

# Test Vulkan
vkcube

# Check graphics processes
ps aux | grep -E "(X|Wayland|gnome|kde)"
```

## 🛠️ Performance Optimization

### Gaming Performance

```bash
# Install gaming-related packages
sudo apt install gamemode mangohud # Ubuntu/Debian
sudo dnf install gamemode mangohud # Fedora
sudo pacman -S gamemode mangohud # Arch

# Enable performance governor
sudo cpupower frequency-set -g performance

# For NVIDIA, enable performance mode
nvidia-settings -a [gpu:0]/GpuPowerMizerMode=1
```

### Video Acceleration

```bash
# Check hardware acceleration
vainfo # VA-API
vdpauinfo # VDPAU (NVIDIA)

# Install video acceleration
sudo apt install va-driver-all vdpau-driver-all # Ubuntu/Debian

# Test video playback
mpv --hwdec=auto video_file.mp4
```

## 🚨 Emergency Recovery

### Boot with Safe Graphics

```bash
# Add to GRUB boot parameters:
nomodeset          # Disable kernel mode setting
nouveau.modeset=0  # Disable nouveau
nvidia.modeset=0   # Disable NVIDIA
i915.modeset=0     # Disable Intel

# Boot into text mode
systemctl set-default multi-user.target
```

### Reset Graphics Configuration

```bash
# Remove all graphics configuration
sudo rm /etc/X11/xorg.conf
sudo rm /etc/X11/xorg.conf.d/*graphics*

# Reset to defaults
sudo dpkg-reconfigure xserver-xorg # Ubuntu/Debian

# Reinstall display manager
sudo apt install --reinstall gdm3 # GNOME
sudo apt install --reinstall sddm # KDE
```

## 🛡️ Prevention and Maintenance

### Regular Maintenance

```bash
# Keep drivers updated
sudo apt update && sudo apt upgrade
sudo ubuntu-drivers autoinstall # Ubuntu

# Monitor graphics performance
nvidia-smi -l 1 # NVIDIA
radeontop # AMD
intel_gpu_top # Intel

# Check for driver updates
sudo ubuntu-drivers list # Ubuntu
dnf list nvidia* # Fedora
```

### Best Practices

1. **Use distribution packages** when possible
2. **Avoid mixing driver sources** (don't mix PPA with official repos)
3. **Test in virtual console** before rebooting
4. **Keep kernel and drivers in sync**
5. **Document working configurations**

### Backup Graphics Configuration

```bash
# Backup working configuration
sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
sudo cp -r /etc/X11/xorg.conf.d /etc/X11/xorg.conf.d.backup

# Backup NVIDIA settings
nvidia-settings --save-rc-file=~/.nvidia-settings-rc.backup
```

## 📞 Getting Help

### Information to Gather

```bash
# Hardware information
lspci | grep VGA
lshw -c display

# Driver information
lsmod | grep -E "(nvidia|nouveau|amdgpu|radeon|i915)"
glxinfo | head -20

# System information
uname -a
cat /etc/os-release

# Logs
journalctl -u gdm -n 50
cat /var/log/Xorg.0.log | tail -50
```

### Useful Commands for Support

```bash
# Generate system report
sudo hw-probe -all -upload # Hardware probe
inxi -Fxz # System information
```

---

*Graphics driver issues can be complex, but most problems are solvable with the right driver version and configuration. Always backup working configurations before making changes.* 