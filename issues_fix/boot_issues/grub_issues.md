# GRUB Boot Loader Issues

GRUB (GRand Unified Bootloader) is the most common boot loader for Linux systems. When GRUB fails, your system won't boot, making this a critical issue to resolve.

## 🚨 Common GRUB Problems

### 1. GRUB Rescue Mode
**Symptoms**: System boots to `grub rescue>` prompt
**Cause**: GRUB configuration files are missing or corrupted

### 2. GRUB Not Found
**Symptoms**: "GRUB not found" or "No bootable device" error
**Cause**: GRUB not installed on the correct drive or MBR corrupted

### 3. Operating System Not Found
**Symptoms**: GRUB loads but can't find the OS
**Cause**: Incorrect partition configuration or missing kernel

### 4. GRUB Menu Not Showing
**Symptoms**: System boots directly without showing GRUB menu
**Cause**: GRUB timeout set to 0 or hidden menu enabled

## 🔧 Solutions

### Solution 1: Fix GRUB from Rescue Mode

If you see the `grub rescue>` prompt:

```bash
# 1. Find your Linux partition
grub rescue> ls
# Look for partitions like (hd0,msdos1), (hd0,gpt2), etc.

# 2. Check each partition for your Linux installation
grub rescue> ls (hd0,msdos1)/
# Look for directories like /boot, /etc, /home

# 3. Set the correct partition (example: hd0,msdos1)
grub rescue> set root=(hd0,msdos1)

# 4. Load normal module
grub rescue> insmod normal

# 5. Start normal GRUB
grub rescue> normal
```

### Solution 2: Reinstall GRUB from Live USB

Boot from a Linux Live USB and follow these steps:

#### For BIOS/MBR Systems:

```bash
# 1. Identify your Linux partition
sudo fdisk -l
# Look for your root partition (usually largest Linux partition)

# 2. Mount your Linux partition
sudo mount /dev/sdXY /mnt
# Replace sdXY with your root partition (e.g., sda1)

# 3. Mount additional partitions if separate
sudo mount /dev/sdXZ /mnt/boot  # If /boot is separate
sudo mount /dev/sdXW /mnt/boot/efi  # If /boot/efi is separate (UEFI)

# 4. Mount system directories
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys

# 5. Chroot into your system
sudo chroot /mnt

# 6. Reinstall GRUB
grub-install /dev/sdX  # Replace sdX with your disk (not partition)
# Example: grub-install /dev/sda

# 7. Update GRUB configuration
update-grub

# 8. Exit chroot and reboot
exit
sudo umount -R /mnt
sudo reboot
```

#### For UEFI Systems:

```bash
# 1. Mount partitions (same as above)
sudo mount /dev/sdXY /mnt  # Root partition
sudo mount /dev/sdXZ /mnt/boot/efi  # EFI partition

# 2. Mount system directories and chroot (same as above)
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt

# 3. Reinstall GRUB for UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# 4. Update GRUB configuration
update-grub

# 5. Exit and reboot
exit
sudo umount -R /mnt
sudo reboot
```

### Solution 3: Fix GRUB Configuration

If GRUB loads but can't find your OS:

```bash
# 1. Boot from Live USB and chroot (as above)

# 2. Check /etc/fstab for correct UUIDs
cat /etc/fstab

# 3. Check actual partition UUIDs
blkid

# 4. Update /etc/fstab if UUIDs don't match
nano /etc/fstab

# 5. Regenerate GRUB configuration
update-grub

# 6. Check GRUB configuration
cat /boot/grub/grub.cfg | grep -A 5 -B 5 "linux"
```

### Solution 4: Restore GRUB Menu

If GRUB menu doesn't appear:

```bash
# 1. Edit GRUB configuration
sudo nano /etc/default/grub

# 2. Modify these lines:
GRUB_TIMEOUT=10
GRUB_TIMEOUT_STYLE=menu
# Comment out: #GRUB_HIDDEN_TIMEOUT=0

# 3. Update GRUB
sudo update-grub
```

## 🔍 Advanced Troubleshooting

### Check GRUB Installation

```bash
# Check if GRUB is installed
sudo grub-install --version

# Check GRUB files
ls -la /boot/grub/

# Check EFI boot entries (UEFI systems)
sudo efibootmgr -v
```

### Manual GRUB Boot

If GRUB menu appears but entries don't work:

```bash
# 1. Press 'c' in GRUB menu to get command line

# 2. Find your kernel and initrd
grub> ls (hd0,msdos1)/boot/
grub> ls (hd0,msdos1)/

# 3. Set root partition
grub> set root=(hd0,msdos1)

# 4. Load kernel (adjust path and version)
grub> linux /boot/vmlinuz-5.4.0-42-generic root=/dev/sda1 ro

# 5. Load initrd
grub> initrd /boot/initrd.img-5.4.0-42-generic

# 6. Boot
grub> boot
```

### Backup and Restore GRUB

```bash
# Backup GRUB configuration
sudo cp /boot/grub/grub.cfg /boot/grub/grub.cfg.backup

# Backup MBR (BIOS systems)
sudo dd if=/dev/sda of=/home/user/mbr_backup.img bs=512 count=1

# Restore MBR
sudo dd if=/home/user/mbr_backup.img of=/dev/sda bs=512 count=1
```

## 🛡️ Prevention Tips

### Regular Maintenance

```bash
# 1. Keep GRUB updated
sudo apt update && sudo apt upgrade grub-pc  # Debian/Ubuntu
sudo dnf update grub2-tools  # Fedora
sudo zypper update grub2  # openSUSE

# 2. Backup GRUB configuration regularly
sudo cp /boot/grub/grub.cfg /boot/grub/grub.cfg.$(date +%Y%m%d)

# 3. Test GRUB configuration after changes
sudo grub-mkconfig -o /tmp/grub.cfg.test
```

### Safe Practices

1. **Always backup** before modifying GRUB
2. **Test changes** in virtual machines first
3. **Keep a Live USB** handy for recovery
4. **Document your setup** (partition layout, UUIDs)
5. **Avoid force shutdowns** during updates

## 📚 Distribution-Specific Commands

### Ubuntu/Debian
```bash
sudo update-grub
sudo grub-install /dev/sda
```

### Fedora/RHEL
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-install /dev/sda
```

### Arch Linux
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub-install /dev/sda
```

### openSUSE
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-install /dev/sda
```

## 🆘 Emergency Recovery

If all else fails:

1. **Boot from Live USB**
2. **Backup important data**
3. **Reinstall bootloader completely**
4. **Consider using alternative bootloaders** (systemd-boot, rEFInd)

## 📞 Getting Help

- **Ubuntu**: Ask Ubuntu forums, Ubuntu documentation
- **Arch Linux**: Arch Wiki (excellent GRUB documentation)
- **Fedora**: Fedora forums, Red Hat documentation
- **General**: r/linuxquestions, Stack Overflow

---

*Remember: GRUB issues can usually be fixed without reinstalling the entire system. Take your time and follow the steps carefully.* 