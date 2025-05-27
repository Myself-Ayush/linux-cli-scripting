# High CPU Usage Issues

High CPU usage can make your Linux system slow, unresponsive, or cause overheating. This guide helps you identify the cause and implement solutions.

## 🚨 Common Symptoms

- System becomes slow or unresponsive
- Fan noise increases (overheating)
- Applications take long time to start
- Desktop environment becomes sluggish
- High load average in system monitoring tools
- Battery drains quickly on laptops

## 🔍 Diagnosing High CPU Usage

### Check Current CPU Usage

```bash
# Real-time process monitoring
top
htop  # Enhanced version with better interface

# Show CPU usage per core
htop  # Press F2 -> Display options -> Detailed CPU time

# One-time snapshot
ps aux --sort=-%cpu | head -20

# Show load average
uptime
w

# Check system load over time
sar -u 1 10  # CPU usage every second for 10 seconds
```

### Identify CPU-Intensive Processes

```bash
# Top CPU consuming processes
ps aux --sort=-%cpu | head -10

# Processes using most CPU time
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -20

# Find processes by name
pgrep -f process_name
pidof process_name

# Show process tree
pstree -p

# Monitor specific process
top -p PID
```

### Analyze System Load

```bash
# Check load average (1, 5, 15 minute averages)
cat /proc/loadavg

# Number of CPU cores
nproc
cat /proc/cpuinfo | grep processor | wc -l

# Load average interpretation:
# Load = Number of cores: System is fully utilized
# Load > Number of cores: System is overloaded
# Load < Number of cores: System has spare capacity
```

### Check for System Issues

```bash
# Check for I/O wait (high iowait = disk bottleneck)
iostat -x 1 5

# Check memory usage (swapping can cause high CPU)
free -h
cat /proc/meminfo

# Check for hardware issues
dmesg | grep -i error
journalctl -p err -x
```

## 🔧 Solutions

### Kill Resource-Heavy Processes

```bash
# Kill process by PID
kill PID
kill -9 PID  # Force kill

# Kill process by name
killall process_name
pkill process_name

# Kill all processes by user
sudo pkill -u username

# Interactive process killer
htop  # Press F9 to kill selected process
```

### Manage Process Priority

```bash
# Lower process priority (higher nice value = lower priority)
renice +10 PID

# Start process with low priority
nice -n 10 command

# Real-time priority (use carefully)
sudo chrt -f 99 command  # Highest priority
sudo chrt -f 1 command   # Lower real-time priority

# Check process priorities
ps -eo pid,ni,cmd --sort=-ni
```

### Control Process CPU Usage

```bash
# Limit CPU usage with cpulimit
sudo apt install cpulimit  # Debian/Ubuntu
sudo dnf install cpulimit  # Fedora

# Limit process to 50% CPU
cpulimit -p PID -l 50

# Limit by process name
cpulimit -e process_name -l 30

# Use systemd to limit resources
sudo systemctl edit service_name
# Add:
[Service]
CPUQuota=50%
MemoryLimit=1G
```

### Fix Common High CPU Causes

#### Browser Issues

```bash
# Check browser processes
ps aux | grep -E "(firefox|chrome|chromium)"

# Firefox specific
# Type in address bar: about:performance
# Disable problematic extensions
# Clear cache and cookies

# Chrome/Chromium specific
# Type in address bar: chrome://settings/system
# Disable "Continue running background apps when Google Chrome is closed"
# Check chrome://tasks/ for resource usage
```

#### Desktop Environment Issues

```bash
# Restart desktop environment
# GNOME
sudo systemctl restart gdm

# KDE
sudo systemctl restart sddm

# XFCE
xfce4-panel --restart

# Check for compositor issues
# Disable compositing temporarily
xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

#### System Service Issues

```bash
# Check systemd services CPU usage
systemd-cgtop

# Find problematic services
systemctl list-units --type=service --state=running
systemctl status service_name

# Restart problematic service
sudo systemctl restart service_name

# Disable unnecessary services
sudo systemctl disable service_name
sudo systemctl stop service_name
```

## 🔧 Advanced Troubleshooting

### Profile CPU Usage

```bash
# Install profiling tools
sudo apt install perf linux-tools-generic  # Debian/Ubuntu
sudo dnf install perf                       # Fedora
sudo pacman -S perf                         # Arch

# Profile system for 10 seconds
sudo perf record -g sleep 10
sudo perf report

# Profile specific process
sudo perf record -p PID sleep 10
sudo perf report

# Real-time profiling
sudo perf top
```

### Check for Malware or Crypto Mining

```bash
# Look for suspicious processes
ps aux | grep -E "(bitcoin|mine|crypto|xmr)"

# Check network connections
netstat -tuln | grep ESTABLISHED
ss -tuln

# Check for unusual CPU patterns
top -d 1  # Update every second

# Check cron jobs
crontab -l
sudo crontab -l
ls -la /etc/cron.*

# Check for rootkits
sudo apt install rkhunter chkrootkit  # Debian/Ubuntu
sudo rkhunter --check
sudo chkrootkit
```

### Hardware-Related Issues

```bash
# Check CPU temperature
sensors  # Install lm-sensors package first
sudo sensors-detect  # First time setup

# Check for thermal throttling
dmesg | grep -i thermal
journalctl | grep -i thermal

# Check CPU frequency scaling
cat /proc/cpuinfo | grep MHz
cpufreq-info  # Install cpufrequtils

# Monitor hardware
sudo apt install hardinfo  # GUI hardware info
hardinfo
```

### Memory-Related CPU Issues

```bash
# Check for memory leaks
ps aux --sort=-%mem | head -10

# Check swap usage
swapon --show
cat /proc/swaps

# Monitor memory over time
sar -r 1 10

# Check for memory pressure
dmesg | grep -i "out of memory"
journalctl | grep -i oom
```

## 🛠️ System Optimization

### CPU Governor Settings

```bash
# Check current CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Available governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Set performance governor (maximum performance)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set powersave governor (battery saving)
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Install cpufrequtils for easier management
sudo apt install cpufrequtils
sudo cpufreq-set -g performance
```

### Disable Unnecessary Services

```bash
# List all services
systemctl list-unit-files --type=service

# Disable unnecessary services (examples)
sudo systemctl disable bluetooth  # If not using Bluetooth
sudo systemctl disable cups       # If not printing
sudo systemctl disable avahi-daemon  # If not using network discovery

# Check what services are using CPU
systemd-cgtop
```

### Optimize Desktop Environment

```bash
# GNOME optimizations
# Disable animations
gsettings set org.gnome.desktop.interface enable-animations false

# Reduce visual effects
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'

# KDE optimizations
# System Settings -> Desktop Effects -> Disable effects

# XFCE optimizations
# Settings -> Window Manager Tweaks -> Compositor -> Disable
```

## 📊 Monitoring and Prevention

### Set Up Monitoring

```bash
# Install monitoring tools
sudo apt install htop iotop nethogs sysstat  # Debian/Ubuntu
sudo dnf install htop iotop nethogs sysstat  # Fedora

# Enable sysstat data collection
sudo systemctl enable sysstat
sudo systemctl start sysstat

# View historical data
sar -u  # CPU usage
sar -r  # Memory usage
sar -d  # Disk usage
```

### Create Monitoring Scripts

```bash
# CPU monitoring script
cat > ~/bin/cpu-monitor.sh << 'EOF'
#!/bin/bash
THRESHOLD=80
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "HIGH CPU USAGE: $CPU_USAGE%"
    ps aux --sort=-%cpu | head -10
fi
EOF

chmod +x ~/bin/cpu-monitor.sh

# Add to crontab for regular monitoring
echo "*/5 * * * * ~/bin/cpu-monitor.sh" | crontab -
```

### Automated Process Management

```bash
# Create script to kill runaway processes
cat > ~/bin/kill-cpu-hogs.sh << 'EOF'
#!/bin/bash
# Kill processes using more than 90% CPU for more than 5 minutes

ps aux --sort=-%cpu | awk 'NR>1 && $3>90 {print $2}' | while read pid; do
    # Check if process has been running for more than 5 minutes
    runtime=$(ps -o etime= -p $pid | tr -d ' ')
    if [[ $runtime =~ ^[0-9][0-9]:[0-9][0-9]$ ]] && [[ ${runtime:0:2} -gt 5 ]]; then
        echo "Killing high CPU process: $pid"
        kill $pid
    fi
done
EOF

chmod +x ~/bin/kill-cpu-hogs.sh
```

## 🚨 Emergency Procedures

### System Completely Unresponsive

```bash
# Magic SysRq keys (if enabled)
# Alt + SysRq + f: Kill memory-hogging process
# Alt + SysRq + i: Kill all processes except init
# Alt + SysRq + k: Kill all processes on current terminal

# Enable SysRq
echo 1 | sudo tee /proc/sys/kernel/sysrq

# SSH from another machine
ssh user@system_ip
top  # Identify problem
kill -9 PID
```

### Boot into Safe Mode

```bash
# Add to GRUB boot parameters:
# systemd.unit=rescue.target  # Minimal system
# single                      # Single user mode
# init=/bin/bash             # Direct shell access

# From GRUB menu:
# Press 'e' to edit boot entry
# Add parameters to linux line
# Press Ctrl+X to boot
```

## 🛡️ Prevention Tips

### Regular Maintenance

```bash
# Keep system updated
sudo apt update && sudo apt upgrade  # Debian/Ubuntu
sudo dnf update                       # Fedora
sudo pacman -Syu                      # Arch

# Clean up regularly
sudo apt autoremove && sudo apt autoclean
sudo dnf autoremove && sudo dnf clean all
sudo pacman -Sc

# Monitor system health
htop
iotop
nethogs
```

### Best Practices

1. **Monitor regularly**: Check system performance weekly
2. **Update software**: Keep system and applications updated
3. **Limit startup programs**: Disable unnecessary autostart applications
4. **Use lightweight alternatives**: Consider lighter desktop environments
5. **Clean system**: Regular cleanup of temporary files and caches
6. **Hardware maintenance**: Keep system clean and well-ventilated

### Resource Limits

```bash
# Set user limits in /etc/security/limits.conf
username soft cpu 10     # 10 minutes CPU time
username hard cpu 15     # Hard limit
username soft nproc 100  # Max 100 processes

# Set systemd service limits
sudo systemctl edit service_name
[Service]
CPUQuota=50%
TasksMax=100
```

## 📞 Getting Help

### Information to Gather

```bash
# System information
uname -a
lscpu
free -h
uptime

# Top processes
ps aux --sort=-%cpu | head -20

# System load
sar -u 1 5

# Hardware info
lshw -short
sensors
```

---

*High CPU usage is often solvable by identifying and addressing the root cause. Regular monitoring helps prevent issues before they become critical.* 