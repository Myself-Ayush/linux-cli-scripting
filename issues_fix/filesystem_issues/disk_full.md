# Disk Full Problems

Running out of disk space is a common Linux issue that can cause system instability, prevent applications from working, and stop system updates. This guide covers diagnosis and solutions.

## 🚨 Common Symptoms

- "No space left on device" error messages
- System becomes slow or unresponsive
- Cannot save files or install packages
- Log files stop updating
- Applications crash or fail to start
- Boot failures due to full root partition

## 🔍 Diagnosing Disk Space Issues

### Check Disk Usage

```bash
# Check overall disk usage
df -h

# Check disk usage with inodes
df -hi

# Check specific directory sizes
du -sh /*
du -sh /var/*
du -sh /home/*

# Find largest directories
du -h / 2>/dev/null | sort -hr | head -20

# Interactive disk usage analyzer
ncdu /
# or
baobab  # GUI tool
```

### Identify Large Files

```bash
# Find files larger than 100MB
find / -type f -size +100M 2>/dev/null | head -20

# Find files larger than 1GB
find / -type f -size +1G 2>/dev/null

# Find largest files in current directory
ls -lah | sort -k5 -hr | head -10

# Find files by size range
find /var -type f -size +50M -size -500M 2>/dev/null
```

### Check for Hidden Space Usage

```bash
# Check for deleted files still held open
lsof +L1

# Check for files in deleted directories
find /proc/*/fd -ls 2>/dev/null | grep deleted

# Check mount points for hidden files
mount | grep -E "^/dev"
```

## 🔧 Quick Solutions

### Free Up Space Immediately

```bash
# Clean package manager cache
sudo apt clean && sudo apt autoclean  # Debian/Ubuntu
sudo dnf clean all                    # Fedora/RHEL
sudo pacman -Sc                       # Arch Linux
sudo zypper clean --all               # openSUSE

# Remove old kernels (Ubuntu/Debian)
sudo apt autoremove --purge

# Clean journal logs
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M

# Clear temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear user cache
rm -rf ~/.cache/*
```

### Emergency Space Recovery

```bash
# If root partition is full and you can't log in:
# Boot from Live USB or single-user mode

# Mount root partition
sudo mount /dev/sdXY /mnt

# Clean critical directories
sudo rm -rf /mnt/tmp/*
sudo rm -rf /mnt/var/tmp/*
sudo rm -rf /mnt/var/cache/apt/archives/*

# Truncate large log files (don't delete, truncate)
sudo truncate -s 0 /mnt/var/log/syslog
sudo truncate -s 0 /mnt/var/log/kern.log
```

## 🧹 Systematic Cleanup

### Log Files Cleanup

```bash
# Check log file sizes
sudo du -sh /var/log/*

# Rotate logs manually
sudo logrotate -f /etc/logrotate.conf

# Clean old log files
sudo find /var/log -name "*.log" -type f -mtime +30 -delete
sudo find /var/log -name "*.gz" -type f -mtime +30 -delete

# Configure log rotation
sudo nano /etc/logrotate.conf
# Add or modify:
# weekly
# rotate 4
# compress
# delaycompress
```

### Package Manager Cleanup

#### Debian/Ubuntu (APT)

```bash
# Remove orphaned packages
sudo apt autoremove --purge

# Clean package cache
sudo apt clean
sudo apt autoclean

# Remove old package versions
sudo apt-get autoremove --purge $(dpkg -l | grep "^rc" | awk '{print $2}')

# Remove old kernels (keep current + 1)
sudo apt autoremove --purge
```

#### Fedora/RHEL (DNF)

```bash
# Remove orphaned packages
sudo dnf autoremove

# Clean all cache
sudo dnf clean all

# Remove old kernels (keep 3)
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-3 -q)

# Remove duplicate packages
package-cleanup --cleandupes
```

#### Arch Linux (Pacman)

```bash
# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Clean package cache (keep 3 versions)
sudo paccache -r

# Remove all cached packages
sudo pacman -Scc

# Clean AUR cache
yay -Sc
paru -Sc
```

### User Directory Cleanup

```bash
# Find large files in home directory
find ~ -type f -size +100M 2>/dev/null

# Clean browser cache
rm -rf ~/.cache/mozilla/firefox/*/cache2/*
rm -rf ~/.cache/google-chrome/Default/Cache/*
rm -rf ~/.cache/chromium/Default/Cache/*

# Clean thumbnail cache
rm -rf ~/.cache/thumbnails/*

# Clean trash
rm -rf ~/.local/share/Trash/*

# Find duplicate files
fdupes -r ~ | grep -v "^$"
```

### System Cleanup

```bash
# Clean core dumps
sudo rm -rf /var/crash/*
sudo rm -rf /var/lib/systemd/coredump/*

# Clean old man page cache
sudo rm -rf /var/cache/man/*

# Clean font cache
fc-cache -f -v

# Clean thumbnail cache system-wide
sudo rm -rf /var/cache/thumbnails/*
```

## 📊 Advanced Disk Analysis

### Analyze Disk Usage Patterns

```bash
# Show disk usage by file type
find / -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -20

# Show largest directories by depth
du -h --max-depth=2 / 2>/dev/null | sort -hr | head -20

# Analyze specific partitions
df -h | grep -E "^/dev"
for partition in $(df -h | grep -E "^/dev" | awk '{print $6}'); do
    echo "=== $partition ==="
    du -sh $partition/* 2>/dev/null | sort -hr | head -10
done
```

### Monitor Disk Usage

```bash
# Real-time disk usage monitoring
watch -n 5 'df -h'

# Monitor specific directory
watch -n 10 'du -sh /var/log'

# Set up disk usage alerts
# Add to crontab:
# 0 */6 * * * df -h | awk '$5 > 80 {print $0}' | mail -s "Disk Usage Alert" admin@example.com
```

## 🔧 Permanent Solutions

### Extend Disk Space

#### Add New Disk

```bash
# Check available disks
lsblk
fdisk -l

# Partition new disk
sudo fdisk /dev/sdX

# Create filesystem
sudo mkfs.ext4 /dev/sdX1

# Mount temporarily
sudo mkdir /mnt/newdisk
sudo mount /dev/sdX1 /mnt/newdisk

# Add to fstab for permanent mount
echo "/dev/sdX1 /home/user/data ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

#### Extend Existing Partition

```bash
# For LVM (if using LVM)
sudo lvextend -l +100%FREE /dev/mapper/vg-root
sudo resize2fs /dev/mapper/vg-root

# For regular partitions (requires unmounting)
sudo umount /dev/sdX1
sudo e2fsck -f /dev/sdX1
sudo resize2fs /dev/sdX1
```

### Move Large Directories

```bash
# Move /var/log to separate partition
sudo systemctl stop rsyslog
sudo mv /var/log /var/log.old
sudo mkdir /var/log
sudo mount /dev/sdX1 /var/log
sudo cp -a /var/log.old/* /var/log/
sudo systemctl start rsyslog

# Add to fstab
echo "/dev/sdX1 /var/log ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

### Configure Automatic Cleanup

#### Set up log rotation

```bash
# Configure logrotate
sudo nano /etc/logrotate.d/custom

# Add configuration:
/var/log/custom/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 user group
}
```

#### Set up automatic package cleanup

```bash
# Create cleanup script
sudo nano /usr/local/bin/cleanup.sh

#!/bin/bash
# Automatic system cleanup script

# Clean package cache
apt clean 2>/dev/null || dnf clean all 2>/dev/null || pacman -Sc --noconfirm 2>/dev/null

# Remove old logs
journalctl --vacuum-time=30d

# Clean temp files
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

# Make executable
sudo chmod +x /usr/local/bin/cleanup.sh

# Add to crontab
echo "0 2 * * 0 /usr/local/bin/cleanup.sh" | sudo crontab -
```

## 🚨 Emergency Procedures

### When Root Partition is 100% Full

```bash
# Boot into single-user mode or Live USB

# Mount root partition
sudo mount /dev/sdX1 /mnt

# Emergency cleanup
sudo rm -rf /mnt/tmp/*
sudo rm -rf /mnt/var/tmp/*

# Truncate largest log files
sudo find /mnt/var/log -name "*.log" -size +100M -exec truncate -s 50M {} \;

# Remove old kernels
sudo chroot /mnt
apt autoremove --purge
exit

# Reboot
sudo umount /mnt
sudo reboot
```

### Recover from Inode Exhaustion

```bash
# Check inode usage
df -i

# Find directories with many small files
find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n

# Remove unnecessary small files
find /tmp -type f -delete
find /var/tmp -type f -delete
find /var/cache -name "*.cache" -delete
```

## 🛡️ Prevention Strategies

### Monitoring Setup

```bash
# Install monitoring tools
sudo apt install ncdu baobab  # Debian/Ubuntu
sudo dnf install ncdu baobab  # Fedora
sudo pacman -S ncdu           # Arch

# Set up disk usage monitoring script
cat > ~/bin/disk-monitor.sh << 'EOF'
#!/bin/bash
THRESHOLD=80
df -h | awk -v threshold=$THRESHOLD '
NR>1 && $5+0 > threshold {
    print "WARNING: " $6 " is " $5 " full"
}'
EOF

chmod +x ~/bin/disk-monitor.sh

# Add to crontab for regular checks
echo "0 */6 * * * ~/bin/disk-monitor.sh" | crontab -
```

### Best Practices

1. **Regular Monitoring**: Check disk usage weekly
2. **Automated Cleanup**: Set up automatic log rotation and cache cleaning
3. **Separate Partitions**: Use separate partitions for `/var`, `/tmp`, `/home`
4. **Quota Management**: Implement user quotas on multi-user systems
5. **Backup Strategy**: Regular backups allow safe deletion of old files

### Quota Management

```bash
# Enable quotas on filesystem
sudo mount -o remount,usrquota,grpquota /home

# Initialize quota database
sudo quotacheck -cum /home
sudo quotaon /home

# Set user quota (1GB soft, 1.2GB hard)
sudo setquota -u username 1000000 1200000 0 0 /home

# Check quotas
quota -u username
```

## 📞 Getting Help

### Information to Gather

When seeking help with disk space issues:

```bash
# System information
df -h
df -i
lsblk
mount | grep -E "^/dev"

# Largest directories
du -sh /* 2>/dev/null | sort -hr | head -10

# System logs
journalctl -xe | tail -50
dmesg | grep -i "space\|full" | tail -10
```

---

*Disk space management is crucial for system stability. Regular monitoring and automated cleanup prevent most disk full situations.* 