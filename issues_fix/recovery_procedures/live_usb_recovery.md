# System Recovery from Live USB

When your Linux system won't boot or is severely damaged, a Live USB is often your best recovery tool. This guide covers comprehensive recovery procedures using a Live USB environment.

## 🚨 When to Use Live USB Recovery

- System won't boot (GRUB issues, kernel panic)
- Root filesystem corruption
- Forgotten root password
- Broken package manager
- Graphics driver issues preventing GUI access
- Filesystem full preventing login
- Malware or system compromise

## 🔧 Preparing for Recovery

### Create Live USB

```bash
# Download ISO file for your distribution
# Ubuntu: https://ubuntu.com/download
# Fedora: https://getfedora.org/
# Arch: https://archlinux.org/download/

# Create bootable USB (Linux)
sudo dd if=distribution.iso of=/dev/sdX bs=4M status=progress
# or use GUI tools like Balena Etcher, Rufus (Windows)

# Verify USB creation
sudo fdisk -l /dev/sdX
```

### Boot from Live USB

```bash
# Boot options to try:
# 1. Change boot order in BIOS/UEFI
# 2. Use boot menu (F12, F8, or ESC during startup)
# 3. Disable Secure Boot if needed
# 4. Use legacy/UEFI mode as appropriate
```

## 🔍 Initial Assessment

### Identify System Partitions

```bash
# List all storage devices
lsblk
fdisk -l

# Check filesystem types
blkid

# Look for your Linux partitions
# Usually: / (root), /home, /boot, swap
# Common filesystems: ext4, btrfs, xfs

# Example output interpretation:
# /dev/sda1 - EFI System Partition (if UEFI)
# /dev/sda2 - Root partition (/)
# /dev/sda3 - Home partition (/home)
# /dev/sda4 - Swap partition
```

### Check Filesystem Health

```bash
# Check filesystem for errors (unmounted)
sudo fsck /dev/sdXY

# For specific filesystem types:
sudo fsck.ext4 /dev/sdXY    # ext4
sudo fsck.xfs /dev/sdXY     # XFS (read-only check)
sudo btrfs check /dev/sdXY  # Btrfs

# Force check even if filesystem appears clean
sudo fsck -f /dev/sdXY

# Check and repair automatically
sudo fsck -y /dev/sdXY
```

## 🔧 Basic Recovery Procedures

### Mount System Partitions

```bash
# Create mount point
sudo mkdir -p /mnt/system

# Mount root partition
sudo mount /dev/sdXY /mnt/system

# Mount additional partitions if separate
sudo mount /dev/sdXZ /mnt/system/boot      # if /boot is separate
sudo mount /dev/sdXW /mnt/system/boot/efi  # if /boot/efi is separate
sudo mount /dev/sdXV /mnt/system/home      # if /home is separate

# Verify mounts
mount | grep /mnt/system
```

### Chroot into System

```bash
# Mount system directories
sudo mount --bind /dev /mnt/system/dev
sudo mount --bind /proc /mnt/system/proc
sudo mount --bind /sys /mnt/system/sys
sudo mount --bind /run /mnt/system/run

# Chroot into your system
sudo chroot /mnt/system

# Now you're operating as if booted into your system
# You can run package managers, edit configs, etc.
```

### Exit Chroot and Unmount

```bash
# Exit chroot environment
exit

# Unmount in reverse order
sudo umount /mnt/system/run
sudo umount /mnt/system/sys
sudo umount /mnt/system/proc
sudo umount /mnt/system/dev
sudo umount /mnt/system/boot/efi  # if mounted
sudo umount /mnt/system/boot      # if mounted
sudo umount /mnt/system/home      # if mounted
sudo umount /mnt/system

# Or unmount recursively
sudo umount -R /mnt/system
```

## 🔧 Specific Recovery Scenarios

### Fix Boot Issues

#### Reinstall GRUB

```bash
# After chrooting into system
# For BIOS systems:
grub-install /dev/sdX  # X is disk, not partition
update-grub

# For UEFI systems:
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
update-grub

# Distribution-specific commands:
# Ubuntu/Debian: update-grub
# Fedora/RHEL: grub2-mkconfig -o /boot/grub2/grub.cfg
# Arch: grub-mkconfig -o /boot/grub/grub.cfg
```

#### Fix Kernel Issues

```bash
# List available kernels
ls /boot/vmlinuz*

# Reinstall current kernel
apt install --reinstall linux-image-$(uname -r)  # Ubuntu/Debian
dnf reinstall kernel                              # Fedora
pacman -S linux                                   # Arch

# Install new kernel
apt install linux-image-generic  # Ubuntu/Debian
dnf install kernel               # Fedora
pacman -S linux-lts             # Arch LTS kernel
```

### Reset Root Password

```bash
# After mounting and chrooting
passwd root

# Or edit shadow file directly (advanced)
vipw -s
# Remove password hash for root user (between first and second colons)
```

### Fix Package Manager Issues

#### Debian/Ubuntu (APT)

```bash
# After chrooting
# Fix broken packages
apt --fix-broken install
dpkg --configure -a

# Clean package cache
apt clean
apt autoclean

# Update package lists
apt update

# Remove lock files if needed
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
rm /var/lib/dpkg/lock*
```

#### Fedora/RHEL (DNF)

```bash
# After chrooting
# Clean metadata
dnf clean all

# Rebuild RPM database
rpm --rebuilddb

# Fix broken dependencies
dnf distro-sync

# Update system
dnf update
```

#### Arch Linux (Pacman)

```bash
# After chrooting
# Update keyring
pacman -S archlinux-keyring

# Force refresh package database
pacman -Syy

# Update system
pacman -Syu
```

### Recover from Filesystem Corruption

#### Ext4 Filesystem

```bash
# Unmount filesystem first
sudo umount /dev/sdXY

# Check and repair
sudo e2fsck -f /dev/sdXY

# Force repair (dangerous - may cause data loss)
sudo e2fsck -f -y /dev/sdXY

# If superblock is corrupted, try backup superblock
sudo e2fsck -b 32768 /dev/sdXY
```

#### Btrfs Filesystem

```bash
# Check filesystem
sudo btrfs check /dev/sdXY

# Repair (read-only check first)
sudo btrfs check --repair /dev/sdXY

# Scrub filesystem (if mountable)
sudo mount /dev/sdXY /mnt/system
sudo btrfs scrub start /mnt/system
sudo btrfs scrub status /mnt/system
```

#### XFS Filesystem

```bash
# Check filesystem (read-only)
sudo xfs_check /dev/sdXY

# Repair filesystem
sudo xfs_repair /dev/sdXY

# Force repair (may cause data loss)
sudo xfs_repair -L /dev/sdXY
```

## 🔧 Advanced Recovery Techniques

### Backup Critical Data

```bash
# Before attempting repairs, backup important data
# Mount damaged filesystem read-only
sudo mount -o ro /dev/sdXY /mnt/damaged

# Copy important files
sudo cp -r /mnt/damaged/home/user/Documents /mnt/backup/
sudo cp -r /mnt/damaged/etc /mnt/backup/
sudo cp /mnt/damaged/home/user/.bashrc /mnt/backup/

# Create filesystem image for forensics
sudo dd if=/dev/sdXY of=/mnt/backup/filesystem.img bs=4M status=progress
```

### Recover Deleted Files

```bash
# Install recovery tools
sudo apt install testdisk photorec extundelete  # Ubuntu/Debian

# For ext3/ext4 filesystems
sudo extundelete /dev/sdXY --restore-all

# For any filesystem (recovers by file type)
sudo photorec /dev/sdXY

# Interactive partition recovery
sudo testdisk /dev/sdX
```

### Network-Based Recovery

```bash
# Configure network in Live USB
sudo dhclient eth0  # or use NetworkManager

# SSH into system for remote recovery
sudo systemctl start ssh
sudo passwd ubuntu  # Set password for SSH access

# Download tools or transfer files
wget http://example.com/recovery-script.sh
scp user@remote:/path/to/backup.tar.gz /mnt/system/
```

### Memory and Hardware Diagnostics

```bash
# Test RAM
sudo memtest86+  # Reboot required

# Check hardware
sudo lshw -html > hardware-report.html
sudo dmidecode > hardware-details.txt

# Check disk health
sudo smartctl -a /dev/sdX
sudo badblocks -v /dev/sdX > badblocks.txt
```

## 🛠️ System Restoration

### Restore from Backup

```bash
# If you have system backup
# Mount backup location
sudo mount /dev/backup_device /mnt/backup

# Restore system files (be very careful)
sudo tar -xzf /mnt/backup/system-backup.tar.gz -C /mnt/system/

# Restore specific directories
sudo rsync -av /mnt/backup/etc/ /mnt/system/etc/
sudo rsync -av /mnt/backup/home/ /mnt/system/home/
```

### Reinstall System (Preserve /home)

```bash
# If /home is on separate partition
# 1. Note down /home partition
lsblk | grep home

# 2. Reinstall OS (don't format /home partition)
# 3. During installation, mount existing /home partition
# 4. Create user with same username as before
```

### Clone System to New Drive

```bash
# Clone entire drive
sudo dd if=/dev/sdX of=/dev/sdY bs=4M status=progress

# Clone specific partition
sudo dd if=/dev/sdX1 of=/dev/sdY1 bs=4M status=progress

# Resize partition after cloning
sudo resize2fs /dev/sdY1  # for ext4
sudo xfs_growfs /mount/point  # for XFS
```

## 🚨 Emergency Procedures

### System Won't Mount

```bash
# Try different mount options
sudo mount -o ro /dev/sdXY /mnt/system  # Read-only
sudo mount -o noatime /dev/sdXY /mnt/system  # No access time updates

# Force mount (dangerous)
sudo mount -o force /dev/sdXY /mnt/system

# Mount with specific filesystem type
sudo mount -t ext4 /dev/sdXY /mnt/system
```

### Partition Table Corruption

```bash
# Backup partition table
sudo sfdisk -d /dev/sdX > partition-table-backup.txt

# Restore partition table
sudo sfdisk /dev/sdX < partition-table-backup.txt

# Interactive partition repair
sudo fdisk /dev/sdX
sudo parted /dev/sdX
```

### UEFI Boot Issues

```bash
# Check EFI variables
sudo efibootmgr -v

# Recreate EFI boot entry
sudo efibootmgr -c -d /dev/sdX -p 1 -L "Ubuntu" -l "\EFI\ubuntu\grubx64.efi"

# Mount EFI partition and check contents
sudo mount /dev/sdX1 /mnt/efi
ls -la /mnt/efi/EFI/
```

## 🛡️ Prevention and Best Practices

### Regular Backups

```bash
# System configuration backup
sudo tar -czf /backup/etc-backup-$(date +%Y%m%d).tar.gz /etc/

# Home directory backup
tar -czf /backup/home-backup-$(date +%Y%m%d).tar.gz /home/user/

# Full system backup (excluding temporary files)
sudo rsync -av --exclude='/proc/*' --exclude='/sys/*' --exclude='/dev/*' / /backup/system/
```

### System Health Monitoring

```bash
# Regular filesystem checks
sudo tune2fs -l /dev/sdXY | grep "Next check"

# SMART monitoring
sudo smartctl -a /dev/sdX

# System logs monitoring
journalctl -p err -x
```

### Recovery Preparation

1. **Keep Live USB updated** with recent distribution
2. **Document system configuration** (partition layout, UUIDs)
3. **Test recovery procedures** in virtual machines
4. **Maintain offline backups** of critical data
5. **Know your hardware** (UEFI vs BIOS, disk layout)

## 📞 Getting Help

### Information to Document

```bash
# Before recovery, gather information:
lsblk > system-layout.txt
blkid > partition-uuids.txt
mount > current-mounts.txt
dmesg > kernel-messages.txt
journalctl -xe > system-logs.txt
```

### Recovery Logs

```bash
# Keep logs of recovery actions
script recovery-session.log
# Perform recovery actions
exit  # Ends logging

# Document what worked
echo "Recovery steps that worked:" > recovery-notes.txt
```

---

*Live USB recovery is a powerful technique that can save your system from most critical failures. Practice these procedures in safe environments before you need them in emergencies.* 