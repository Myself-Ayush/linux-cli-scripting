#!/bin/bash
# Advanced Concepts - Lesson 2: Error Handling and Debugging

echo "=== Basic Error Handling ==="

# Set strict mode for better error handling
set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Function to handle errors
error_handler() {
    echo "Error occurred in script $0 at line $1"
    echo "Exit code: $2"
    exit $2
}

# Trap errors
trap 'error_handler $LINENO $?' ERR

echo "Strict mode enabled - script will exit on any error"

echo ""
echo "=== Exit Codes ==="

# Function that returns different exit codes
check_number() {
    local num=$1
    
    if [ $num -gt 100 ]; then
        echo "Number is too large"
        return 1
    elif [ $num -lt 0 ]; then
        echo "Number is negative"
        return 2
    else
        echo "Number $num is valid"
        return 0
    fi
}

# Test the function with error handling
test_numbers=(50 150 -10 75)

for num in "${test_numbers[@]}"; do
    if check_number $num; then
        echo "✓ Success for $num"
    else
        exit_code=$?
        echo "✗ Error for $num (exit code: $exit_code)"
    fi
done

echo ""
echo "=== Debugging Techniques ==="

# Turn on debugging
set -x  # Print commands before executing

echo "Debug mode ON - you'll see commands as they execute"

# Some commands to demonstrate debugging
current_date=$(date)
user_name=$(whoami)
file_count=$(ls -1 | wc -l)

# Turn off debugging
set +x

echo "Debug mode OFF"

echo ""
echo "=== Conditional Error Handling ==="

# Function with proper error handling
safe_file_operation() {
    local filename=$1
    local operation=$2
    
    # Check if file exists
    if [ ! -f "$filename" ]; then
        echo "Warning: File $filename does not exist, creating it..."
        touch "$filename" || {
            echo "Error: Cannot create file $filename"
            return 1
        }
    fi
    
    case $operation in
        "read")
            if [ -r "$filename" ]; then
                cat "$filename"
            else
                echo "Error: Cannot read file $filename"
                return 1
            fi
            ;;
        "write")
            if [ -w "$filename" ]; then
                echo "Test content $(date)" >> "$filename"
                echo "Successfully wrote to $filename"
            else
                echo "Error: Cannot write to file $filename"
                return 1
            fi
            ;;
        *)
            echo "Error: Unknown operation $operation"
            return 1
            ;;
    esac
    
    return 0
}

# Test safe file operations
echo "Testing safe file operations:"
safe_file_operation "test_file.txt" "write"
safe_file_operation "test_file.txt" "read"

echo ""
echo "=== Logging and Error Reporting ==="

# Create a logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a script.log
}

log_message "INFO" "Script started"
log_message "DEBUG" "Processing user input"
log_message "ERROR" "Sample error message"
log_message "SUCCESS" "Operation completed"

echo ""
echo "=== Try-Catch Simulation ==="

# Bash doesn't have try-catch, but we can simulate it
try_catch() {
    local command="$1"
    local error_message="$2"
    
    if eval "$command"; then
        echo "✓ Command succeeded: $command"
        return 0
    else
        echo "✗ Command failed: $error_message"
        return 1
    fi
}

# Test try-catch simulation
echo "Testing command execution:"
try_catch "ls /home" "Failed to list home directory"
try_catch "ls /nonexistent" "Directory does not exist" || echo "Handled error gracefully"

echo ""
echo "=== Input Validation ==="

validate_input() {
    local input=$1
    local type=$2
    
    case $type in
        "number")
            if [[ $input =~ ^[0-9]+$ ]]; then
                echo "✓ Valid number: $input"
                return 0
            else
                echo "✗ Invalid number: $input"
                return 1
            fi
            ;;
        "email")
            if [[ $input =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "✓ Valid email: $input"
                return 0
            else
                echo "✗ Invalid email: $input"
                return 1
            fi
            ;;
        "filename")
            if [[ $input =~ ^[a-zA-Z0-9._-]+$ ]]; then
                echo "✓ Valid filename: $input"
                return 0
            else
                echo "✗ Invalid filename: $input"
                return 1
            fi
            ;;
    esac
}

# Test input validation
echo "Testing input validation:"
validate_input "123" "number"
validate_input "abc" "number"
validate_input "user@example.com" "email"
validate_input "invalid-email" "email"
validate_input "valid_file.txt" "filename"
validate_input "invalid/file" "filename"

# Cleanup
rm -f test_file.txt script.log

echo ""
echo "=== Summary ==="
echo "Error handling and debugging techniques demonstrated!"
echo "Key points:"
echo "1. Use 'set -euo pipefail' for strict mode"
echo "2. Always validate inputs"
echo "3. Use proper exit codes"
echo "4. Log important events"
echo "5. Handle errors gracefully"
