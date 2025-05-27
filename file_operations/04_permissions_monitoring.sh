#!/bin/bash
# File Operations - Lesson 4: File Permissions and Monitoring

echo "=== File Permissions and Monitoring ==="

# Create test directory and files
TEST_DIR="permission_test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "=== Understanding File Permissions ==="

# Create test files
touch test_file.txt
echo "This is a test file" > test_file.txt
mkdir test_directory

echo "1. Basic file listing with permissions:"
ls -la

echo ""
echo "2. Understanding permission format:"
echo "Format: drwxrwxrwx"
echo "d = directory (- for files)"
echo "rwx = owner permissions (read, write, execute)"
echo "rwx = group permissions"
echo "rwx = other permissions"

echo ""
echo "=== Changing File Permissions ==="

echo "3. Symbolic mode examples:"
echo "Adding execute permission for owner:"
chmod u+x test_file.txt
ls -l test_file.txt

echo ""
echo "Removing write permission for group:"
chmod g-w test_file.txt
ls -l test_file.txt

echo ""
echo "Setting specific permissions for all:"
chmod u=rw,g=r,o=r test_file.txt
ls -l test_file.txt

echo ""
echo "4. Numeric mode examples:"
echo "Setting 755 (rwxr-xr-x):"
chmod 755 test_file.txt
ls -l test_file.txt

echo ""
echo "Setting 644 (rw-r--r--):"
chmod 644 test_file.txt
ls -l test_file.txt

echo ""
echo "Common permission combinations:"
echo "755 = rwxr-xr-x (executable files)"
echo "644 = rw-r--r-- (regular files)"
echo "600 = rw------- (private files)"
echo "777 = rwxrwxrwx (all permissions - use carefully!)"

echo ""
echo "=== File Ownership ==="

echo "5. Current ownership:"
ls -l test_file.txt

echo ""
echo "6. Changing ownership (requires sudo for other users):"
echo "Current user: $(whoami)"
echo "Current group: $(id -gn)"

# Demonstrate group change if user has multiple groups
if [ $(id -G | wc -w) -gt 1 ]; then
    echo "Available groups: $(id -Gn)"
fi

echo ""
echo "=== Special Permissions ==="

echo "7. Sticky bit (for directories):"
mkdir sticky_dir
chmod +t sticky_dir
ls -ld sticky_dir
echo "Sticky bit prevents users from deleting others' files in the directory"

echo ""
echo "8. SUID and SGID examples:"
echo "SUID (4000): Runs with owner's permissions"
echo "SGID (2000): Runs with group's permissions"
echo "Example: chmod 4755 file (adds SUID)"

echo ""
echo "=== File Monitoring ==="

echo "9. File watching with inotify (if available):"
if command -v inotifywait >/dev/null 2>&1; then
    echo "inotifywait is available"
    echo "Example: inotifywait -m -e modify,create,delete /path/to/watch"
else
    echo "inotifywait not installed. Install with: sudo apt install inotify-tools"
fi

echo ""
echo "10. Monitoring file changes with stat:"
echo "Before modification:"
stat test_file.txt | grep -E "(Modify|Change|Access)"

sleep 1
echo "Additional content" >> test_file.txt

echo ""
echo "After modification:"
stat test_file.txt | grep -E "(Modify|Change|Access)"

echo ""
echo "=== File System Monitoring Functions ==="

# Function to monitor file changes
monitor_file_changes() {
    local file="$1"
    local interval="${2:-5}"
    
    if [ ! -f "$file" ]; then
        echo "File $file does not exist"
        return 1
    fi
    
    echo "Monitoring $file for changes (checking every ${interval}s)..."
    echo "Press Ctrl+C to stop"
    
    local last_mod=$(stat -c %Y "$file" 2>/dev/null)
    
    while true; do
        sleep "$interval"
        local current_mod=$(stat -c %Y "$file" 2>/dev/null)
        
        if [ "$current_mod" != "$last_mod" ]; then
            echo "[$(date)] File $file was modified"
            last_mod="$current_mod"
        fi
    done
}

echo "11. File monitoring function created (monitor_file_changes)"
echo "Usage: monitor_file_changes filename [interval_seconds]"

echo ""
echo "=== Directory Size Monitoring ==="

# Function to check directory sizes
check_directory_sizes() {
    local dir="${1:-.}"
    echo "Directory sizes in $dir:"
    du -sh "$dir"/* 2>/dev/null | sort -hr
}

echo "12. Directory size checking:"
check_directory_sizes ..

echo ""
echo "=== File Age and Cleanup ==="

# Function to find old files
find_old_files() {
    local dir="${1:-.}"
    local days="${2:-30}"
    
    echo "Files older than $days days in $dir:"
    find "$dir" -type f -mtime +$days -ls 2>/dev/null
}

echo "13. Finding old files (example):"
echo "Function: find_old_files [directory] [days]"

# Create some test files with different ages
touch -d "2 days ago" old_file1.txt
touch -d "1 day ago" old_file2.txt
touch recent_file.txt

echo "Test files created with different ages:"
ls -la *.txt

echo ""
echo "Files older than 1 day:"
find . -name "*.txt" -mtime +1 -ls

echo ""
echo "=== File Integrity Monitoring ==="

echo "14. Creating checksums for integrity monitoring:"
echo "Original file checksum:"
md5sum test_file.txt > test_file.md5
cat test_file.md5

echo ""
echo "Verifying checksum:"
md5sum -c test_file.md5

echo ""
echo "After modifying file:"
echo "Modified content" >> test_file.txt
md5sum -c test_file.md5 || echo "File has been modified!"

echo ""
echo "=== Advanced Permission Checking ==="

# Function to check file permissions
check_permissions() {
    local file="$1"
    
    if [ ! -e "$file" ]; then
        echo "File $file does not exist"
        return 1
    fi
    
    echo "Detailed permissions for $file:"
    echo "Octal: $(stat -c %a "$file")"
    echo "Symbolic: $(stat -c %A "$file")"
    echo "Owner: $(stat -c %U "$file")"
    echo "Group: $(stat -c %G "$file")"
    echo "Size: $(stat -c %s "$file") bytes"
    echo "Last modified: $(stat -c %y "$file")"
}

echo "15. Detailed permission checking:"
check_permissions test_file.txt

echo ""
echo "=== Security Checks ==="

echo "16. Finding files with unusual permissions:"
echo "World-writable files (security risk):"
find . -type f -perm -002 -ls 2>/dev/null

echo ""
echo "SUID/SGID files:"
find . -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null

echo ""
echo "Files with no owner/group:"
find . -nouser -o -nogroup 2>/dev/null

echo ""
echo "=== Disk Usage Monitoring ==="

echo "17. Disk usage monitoring:"
echo "Current directory usage:"
du -sh .

echo ""
echo "Disk space on filesystem:"
df -h .

echo ""
echo "Largest files in current directory:"
find . -type f -exec ls -la {} \; 2>/dev/null | sort -k5 -nr | head -5

echo ""
echo "=== Log File Monitoring ==="

# Create a sample log file
cat > sample.log << 'EOF'
2024-01-01 10:00:01 INFO Application started
2024-01-01 10:00:15 DEBUG Loading configuration
2024-01-01 10:00:30 INFO User login: admin
2024-01-01 10:01:45 WARN Low memory warning
2024-01-01 10:02:12 ERROR Database connection failed
2024-01-01 10:02:30 INFO Retrying database connection
2024-01-01 10:02:45 INFO Database connection restored
EOF

echo "18. Log file monitoring examples:"
echo "Sample log file created:"
cat sample.log

echo ""
echo "Monitoring for ERROR messages:"
grep "ERROR" sample.log

echo ""
echo "Counting log levels:"
awk '{print $3}' sample.log | sort | uniq -c

echo ""
echo "Recent log entries (last 3):"
tail -3 sample.log

echo ""
echo "=== Real-time File Monitoring Script ==="

cat > file_monitor.sh << 'EOF'
#!/bin/bash
# Simple file monitoring script

WATCH_DIR="${1:-.}"
LOG_FILE="monitor.log"

echo "Starting file monitor for: $WATCH_DIR"
echo "Log file: $LOG_FILE"

# Function to log events
log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Monitor using find and stat
monitor_with_find() {
    local last_check=$(date +%s)
    
    while true; do
        sleep 5
        current_check=$(date +%s)
        
        # Find files modified in the last 10 seconds
        find "$WATCH_DIR" -type f -newermt "@$((current_check - 10))" 2>/dev/null | while read file; do
            log_event "MODIFIED: $file"
        done
        
        last_check=$current_check
    done
}

log_event "File monitoring started for $WATCH_DIR"
monitor_with_find
EOF

chmod +x file_monitor.sh
echo "19. File monitoring script created: file_monitor.sh"
echo "Usage: ./file_monitor.sh [directory_to_watch]"

echo ""
echo "=== Cleanup and Summary ==="

cd ..
echo "20. Cleaning up test files:"
rm -rf "$TEST_DIR"
echo "Test directory removed."

echo ""
echo "=== File Permissions and Monitoring Summary ==="
echo "✓ File permissions (symbolic and numeric modes)"
echo "✓ File ownership and special permissions"
echo "✓ File monitoring techniques"
echo "✓ Directory size monitoring"
echo "✓ File integrity checking with checksums"
echo "✓ Security permission auditing"
echo "✓ Log file monitoring"
echo "✓ Real-time file change detection"
echo ""
echo "Key takeaways:"
echo "• Always use appropriate permissions (principle of least privilege)"
echo "• Monitor critical files and directories for changes"
echo "• Regular security audits of file permissions"
echo "• Use checksums for file integrity verification"
echo "• Implement log monitoring for system health" 