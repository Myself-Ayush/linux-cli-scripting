#!/bin/bash
# Advanced Concepts - Lesson 3: Process Management and Job Control

echo "=== Process Management and Job Control ==="

echo "=== Understanding Processes ==="

echo "1. Current process information:"
echo "Current PID: $$"
echo "Parent PID: $PPID"
echo "Current user: $(whoami)"
echo "Current shell: $0"

echo ""
echo "2. Process listing commands:"
echo "Basic process list (ps):"
ps aux | head -10

echo ""
echo "Process tree (pstree if available):"
if command -v pstree >/dev/null 2>&1; then
    pstree -p $$ | head -5
else
    echo "pstree not available. Install with: sudo apt install psmisc"
fi

echo ""
echo "=== Job Control ==="

echo "3. Background jobs demonstration:"

# Function to simulate long-running task
long_task() {
    local name="$1"
    local duration="$2"
    echo "Starting task: $name"
    for i in $(seq 1 $duration); do
        echo "[$name] Working... $i/$duration"
        sleep 1
    done
    echo "[$name] Completed!"
}

echo "Starting background job..."
long_task "Background Task" 5 &
BG_PID=$!
echo "Background job started with PID: $BG_PID"

echo ""
echo "4. Job control commands:"
echo "jobs - list active jobs:"
jobs

echo ""
echo "Current background processes:"
ps -f --ppid $$

echo ""
echo "Waiting for background job to complete..."
wait $BG_PID
echo "Background job completed."

echo ""
echo "=== Process Control Functions ==="

# Function to start a process and monitor it
start_monitored_process() {
    local command="$1"
    local name="${2:-Process}"
    
    echo "Starting monitored process: $name"
    echo "Command: $command"
    
    # Start process in background
    eval "$command" &
    local pid=$!
    
    echo "Process started with PID: $pid"
    
    # Monitor process
    while kill -0 $pid 2>/dev/null; do
        echo "[$name] Running (PID: $pid)"
        sleep 2
    done
    
    echo "[$name] Process completed"
}

echo "5. Process monitoring function:"
echo "Starting a monitored sleep process..."
start_monitored_process "sleep 3" "Test Sleep" &
MONITOR_PID=$!

# Wait for monitor to complete
wait $MONITOR_PID

echo ""
echo "=== Signal Handling ==="

echo "6. Signal demonstration:"

# Function to handle signals
signal_handler() {
    local signal="$1"
    echo ""
    echo "Received signal: $signal"
    case $signal in
        "TERM")
            echo "Termination signal received. Cleaning up..."
            cleanup_and_exit
            ;;
        "INT")
            echo "Interrupt signal received. Exiting gracefully..."
            exit 0
            ;;
        "USR1")
            echo "User signal 1 received. Printing status..."
            print_status
            ;;
    esac
}

# Function to cleanup and exit
cleanup_and_exit() {
    echo "Performing cleanup operations..."
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null
    echo "Cleanup completed. Exiting."
    exit 0
}

# Function to print status
print_status() {
    echo "=== Process Status ==="
    echo "PID: $$"
    echo "Running time: $(ps -o etime= -p $$)"
    echo "Memory usage: $(ps -o rss= -p $$) KB"
    echo "Active jobs: $(jobs | wc -l)"
}

# Set up signal traps
trap 'signal_handler TERM' TERM
trap 'signal_handler INT' INT
trap 'signal_handler USR1' USR1

echo "Signal handlers set up. Try sending signals to PID $$"
echo "Example: kill -USR1 $$"

echo ""
echo "=== Process Communication ==="

echo "7. Inter-process communication with named pipes (FIFOs):"

PIPE_NAME="test_pipe"
mkfifo "$PIPE_NAME" 2>/dev/null || echo "Pipe already exists"

# Background process to read from pipe
pipe_reader() {
    echo "Pipe reader started"
    while read line < "$PIPE_NAME"; do
        echo "Received: $line"
        if [ "$line" = "quit" ]; then
            break
        fi
    done
    echo "Pipe reader finished"
}

# Start pipe reader in background
pipe_reader &
READER_PID=$!

# Send some messages
echo "hello" > "$PIPE_NAME"
echo "world" > "$PIPE_NAME"
echo "quit" > "$PIPE_NAME"

# Wait for reader to finish
wait $READER_PID

# Cleanup
rm -f "$PIPE_NAME"

echo ""
echo "=== Process Synchronization ==="

echo "8. Process synchronization with locks:"

LOCK_FILE="process.lock"

# Function to acquire lock
acquire_lock() {
    local timeout="${1:-10}"
    local count=0
    
    while [ $count -lt $timeout ]; do
        if (set -C; echo $$ > "$LOCK_FILE") 2>/dev/null; then
            echo "Lock acquired by PID $$"
            return 0
        fi
        echo "Waiting for lock... ($count/$timeout)"
        sleep 1
        ((count++))
    done
    
    echo "Failed to acquire lock within $timeout seconds"
    return 1
}

# Function to release lock
release_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ "$lock_pid" = "$$" ]; then
            rm -f "$LOCK_FILE"
            echo "Lock released by PID $$"
        else
            echo "Cannot release lock - owned by PID $lock_pid"
        fi
    fi
}

# Demonstrate locking
if acquire_lock 5; then
    echo "Performing critical section work..."
    sleep 2
    echo "Critical section completed"
    release_lock
fi

echo ""
echo "=== Process Resource Monitoring ==="

echo "9. Resource monitoring functions:"

# Function to monitor process resources
monitor_process_resources() {
    local pid="${1:-$$}"
    local interval="${2:-2}"
    local count="${3:-5}"
    
    echo "Monitoring PID $pid for $count intervals of ${interval}s each"
    echo "Time     CPU%    Memory(KB)  Status"
    echo "-------- ------- ----------- --------"
    
    for i in $(seq 1 $count); do
        if kill -0 $pid 2>/dev/null; then
            local cpu=$(ps -o %cpu= -p $pid 2>/dev/null | tr -d ' ')
            local mem=$(ps -o rss= -p $pid 2>/dev/null | tr -d ' ')
            local status=$(ps -o stat= -p $pid 2>/dev/null | tr -d ' ')
            printf "%-8s %-7s %-11s %s\n" "$(date +%H:%M:%S)" "$cpu" "$mem" "$status"
        else
            echo "Process $pid no longer exists"
            break
        fi
        sleep $interval
    done
}

echo "Monitoring current process:"
monitor_process_resources $$ 1 3

echo ""
echo "=== Advanced Job Control ==="

echo "10. Job control with process groups:"

# Function to create a process group
create_process_group() {
    local group_name="$1"
    echo "Creating process group: $group_name"
    
    # Start multiple related processes
    (
        echo "Process group $group_name started"
        sleep 3 &
        sleep 4 &
        sleep 5 &
        wait
        echo "Process group $group_name completed"
    ) &
    
    local group_pid=$!
    echo "Process group PID: $group_pid"
    return $group_pid
}

create_process_group "TestGroup"
GROUP_PID=$?

echo "Waiting for process group to complete..."
wait $GROUP_PID

echo ""
echo "=== Process Debugging ==="

echo "11. Process debugging techniques:"

# Function to debug a process
debug_process() {
    local pid="${1:-$$}"
    
    echo "Debugging information for PID $pid:"
    
    if [ -d "/proc/$pid" ]; then
        echo "Command line: $(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')"
        echo "Working directory: $(readlink /proc/$pid/cwd 2>/dev/null)"
        echo "Environment variables: $(wc -l < /proc/$pid/environ 2>/dev/null) entries"
        echo "Open file descriptors: $(ls /proc/$pid/fd 2>/dev/null | wc -l)"
        echo "Memory maps: $(wc -l < /proc/$pid/maps 2>/dev/null) entries"
    else
        echo "Process $pid not found or no access to /proc"
    fi
}

debug_process $$

echo ""
echo "=== Process Performance Analysis ==="

echo "12. Performance analysis tools:"

# Function to analyze process performance
analyze_performance() {
    local duration="${1:-5}"
    
    echo "Analyzing system performance for ${duration}s..."
    
    # CPU usage
    echo "CPU usage:"
    top -bn1 | grep "Cpu(s)" | head -1
    
    # Memory usage
    echo "Memory usage:"
    free -h | grep -E "(Mem|Swap)"
    
    # Load average
    echo "Load average:"
    uptime | awk -F'load average:' '{print $2}'
    
    # Process count
    echo "Process count: $(ps aux | wc -l)"
    
    # Top CPU consumers
    echo "Top 3 CPU consumers:"
    ps aux --sort=-%cpu | head -4 | tail -3
}

analyze_performance

echo ""
echo "=== Cleanup and Summary ==="

# Cleanup any remaining background processes
jobs -p | xargs -r kill 2>/dev/null
rm -f "$LOCK_FILE" "$PIPE_NAME" 2>/dev/null

echo "=== Process Management Summary ==="
echo "✓ Process information and listing"
echo "✓ Background job control"
echo "✓ Signal handling and traps"
echo "✓ Inter-process communication"
echo "✓ Process synchronization with locks"
echo "✓ Resource monitoring"
echo "✓ Process groups and job control"
echo "✓ Process debugging techniques"
echo "✓ Performance analysis"
echo ""
echo "Key concepts:"
echo "• Use & to run processes in background"
echo "• Use jobs, fg, bg to control jobs"
echo "• Set up signal traps for graceful shutdown"
echo "• Use locks for critical sections"
echo "• Monitor process resources regularly"
echo "• Use /proc filesystem for process debugging"
echo "• Kill processes gracefully with appropriate signals" 