# Common Bash Debugging Techniques 🐛

## Enable Debug Mode
```bash
# Method 1: Command line
bash -x script.sh

# Method 2: In script
set -x    # Enable debug mode
set +x    # Disable debug mode

# Method 3: Shebang
#!/bin/bash -x
```

## Strict Mode (Recommended)
```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on any error
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

## Error Trapping
```bash
# Trap errors and show line number
trap 'echo "Error on line $LINENO"' ERR

# More detailed error handler
error_handler() {
    echo "Error occurred:"
    echo "  Script: $0"
    echo "  Line: $1"
    echo "  Exit code: $2"
    echo "  Command: $3"
}
trap 'error_handler $LINENO $? "$BASH_COMMAND"' ERR
```

## Logging and Output
```bash
# Create log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a script.log
}

# Usage
log "INFO: Script started"
log "ERROR: Something went wrong"

# Redirect output to file
exec > >(tee script.log)
exec 2>&1  # Redirect stderr to stdout
```

## Variable Validation
```bash
# Check if variable is set
if [ -z "${VAR:-}" ]; then
    echo "Variable VAR is not set"
    exit 1
fi

# Provide default value
NAME="${1:-default_name}"

# Check if variable is numeric
if ! [[ "$NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Not a valid number: $NUMBER"
    exit 1
fi
```

## Function Debugging
```bash
# Debug function entry/exit
debug_function() {
    echo "DEBUG: Entering function: ${FUNCNAME[1]}"
    echo "DEBUG: Arguments: $@"
    
    # Your function code here
    
    echo "DEBUG: Exiting function: ${FUNCNAME[1]}"
}

# Print call stack
print_stack() {
    local i=0
    echo "Call stack:"
    while caller $i; do
        ((i++))
    done
}
```

## Common Issues and Solutions

### Issue: Command not found
```bash
# Check if command exists before using
if command -v git &> /dev/null; then
    git status
else
    echo "Git is not installed"
    exit 1
fi
```

### Issue: File not found
```bash
# Always check file existence
if [ ! -f "$filename" ]; then
    echo "File $filename does not exist"
    exit 1
fi
```

### Issue: Permission denied
```bash
# Check file permissions
if [ ! -r "$filename" ]; then
    echo "Cannot read file $filename"
    exit 1
fi

if [ ! -w "$filename" ]; then
    echo "Cannot write to file $filename"
    exit 1
fi
```

### Issue: Infinite loops
```bash
# Add safety counter
counter=0
max_iterations=100

while [ condition ]; do
    # Your loop code
    
    ((counter++))
    if [ $counter -gt $max_iterations ]; then
        echo "ERROR: Loop exceeded maximum iterations"
        break
    fi
done
```

## Testing Strategies

### Dry Run Mode
```bash
DRY_RUN=false

if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

execute_command() {
    if [ "$DRY_RUN" = true ]; then
        echo "Would execute: $@"
    else
        "$@"
    fi
}
```

### Unit Testing for Functions
```bash
# Simple test function
test_add_function() {
    local result=$(add 2 3)
    if [ "$result" -eq 5 ]; then
        echo "✓ add function test passed"
    else
        echo "✗ add function test failed: expected 5, got $result"
        return 1
    fi
}

# Run tests
test_add_function
```

## Performance Debugging
```bash
# Time script execution
time ./script.sh

# Time specific commands
start_time=$(date +%s.%N)
# Your command here
end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Execution time: $execution_time seconds"
```

## Memory Usage
```bash
# Monitor memory usage
ps -o pid,vsz,rss,comm -p $$

# Check script memory usage
/usr/bin/time -v ./script.sh
```

## Useful Debug Commands
```bash
# Show all variables
set

# Show all functions
declare -F

# Show specific variable
declare -p VARIABLE_NAME

# Check syntax without execution
bash -n script.sh

# Verbose mode
bash -v script.sh
```

## Interactive Debugging
```bash
# Add breakpoints
read -p "Press Enter to continue..." debug_pause

# Interactive shell in script
bash

# Print current state
echo "DEBUG: Variable values:"
echo "  VAR1=$VAR1"
echo "  VAR2=$VAR2"
echo "  PWD=$PWD"
```

## External Tools
```bash
# ShellCheck (static analysis)
shellcheck script.sh

# Bash debugger (bashdb)
bashdb script.sh

# strace (system calls)
strace -e trace=file bash script.sh
```

## Quick Debug Tips
1. **Add echo statements** liberally
2. **Use meaningful variable names**
3. **Test with simple inputs first**
4. **Check return codes**: `echo $?`
5. **Validate all inputs**
6. **Use quotes around variables**
7. **Test edge cases** (empty strings, special characters)
8. **Run with different shells** if portable
9. **Check file permissions**
10. **Use version control** to track changes
