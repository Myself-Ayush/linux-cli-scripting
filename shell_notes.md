# Shell Scripting Notes 📝

## Basic Input/Output

### Reading User Input
```bash
read -p "Enter your name: " NAME
# -p means prompt text
# NAME is variable where user input is stored
# Use echo $NAME to print the value
```

### Different Read Options
```bash
read -s -p "Enter password: " PASSWORD    # Silent input (no echo)
read -t 10 -p "Enter within 10 seconds: " TIMED_INPUT  # Timeout
read -n 1 -p "Press any key: " KEY       # Read single character
```

## Variable Best Practices

### Naming Conventions
- Use UPPERCASE for environment variables: `export PATH="/usr/bin"`
- Use lowercase for local variables: `local_var="value"`
- Use descriptive names: `user_count` instead of `uc`

### Variable Expansion
```bash
# Basic expansion
echo $var
echo ${var}

# Default values
echo ${var:-"default"}        # Use default if var is unset
echo ${var:="default"}        # Set var to default if unset

# String manipulation
echo ${var#prefix}            # Remove shortest prefix
echo ${var##prefix}           # Remove longest prefix
echo ${var%suffix}            # Remove shortest suffix
echo ${var%%suffix}           # Remove longest suffix
```

## Error Handling Patterns

### Exit Codes
- 0: Success
- 1: General error
- 2: Misuse of shell command
- 126: Command not executable
- 127: Command not found
- 128+n: Fatal error signal "n"

### Common Error Handling
```bash
# Check if command succeeded
if command; then
    echo "Success"
else
    echo "Failed with exit code $?"
fi

# One-liner error handling
command || { echo "Command failed"; exit 1; }
```

## Performance Tips

### Avoid Subshells When Possible
```bash
# Slow - creates subshell
var=$(cat file | grep pattern)

# Faster - use built-ins
var=$(grep pattern file)
```

### Use Built-in Commands
- Use `[[ ]]` instead of `[ ]` for conditions
- Use `$(())` for arithmetic instead of `expr`
- Use parameter expansion instead of `sed`/`awk` for simple operations

## Security Considerations

### Input Validation
```bash
# Always validate user input
if [[ $input =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Valid input"
else
    echo "Invalid characters detected"
    exit 1
fi
```

### Quoting Variables
```bash
# Always quote variables to prevent word splitting
rm "$file"           # Correct
rm $file             # Dangerous - can break with spaces
```

## Common Patterns

### Configuration Files
```bash
# Source configuration
if [[ -f "$HOME/.myapp.conf" ]]; then
    source "$HOME/.myapp.conf"
fi
```

### Logging
```bash
# Simple logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}
```

### Progress Indicators
```bash
# Simple progress bar
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    printf "\rProgress: [%-50s] %d%%" $(printf "#%.0s" $(seq 1 $((percent/2)))) $percent
}
```

## Debugging Tips

### Enable Debug Mode
```bash
set -x          # Print commands before execution
set -e          # Exit on any error
set -u          # Exit on undefined variables
set -o pipefail # Exit on pipe failures

# Combine all
set -euxo pipefail
```

### Debugging Functions
```bash
debug() {
    [[ $DEBUG ]] && echo "DEBUG: $*" >&2
}

# Usage: DEBUG=1 ./script.sh
```

## Advanced Techniques

### Process Substitution
```bash
# Compare output of two commands
diff <(command1) <(command2)

# Read from process
while read line; do
    echo "Processing: $line"
done < <(find /path -name "*.txt")
```

### Here Documents
```bash
# Multi-line strings
cat << EOF > file.txt
This is a multi-line
document with variables: $USER
EOF

# Here strings
grep pattern <<< "$variable"
```

## Testing Scripts

### Basic Test Framework
```bash
# Simple assertion function
assert() {
    if [[ $1 == $2 ]]; then
        echo "✓ Test passed: $3"
    else
        echo "✗ Test failed: $3 (expected: $2, got: $1)"
        return 1
    fi
}

# Usage
assert "$(echo hello)" "hello" "Echo test"
```

