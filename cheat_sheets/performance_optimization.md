# Bash Performance Optimization Guide 🚀

## Table of Contents
1. [General Performance Principles](#general-performance-principles)
2. [Command Optimization](#command-optimization)
3. [Loop Optimization](#loop-optimization)
4. [String Operations](#string-operations)
5. [File Operations](#file-operations)
6. [Process Management](#process-management)
7. [Memory Management](#memory-management)
8. [Profiling and Benchmarking](#profiling-and-benchmarking)
9. [Best Practices](#best-practices)

## General Performance Principles

### 1. Avoid Unnecessary Subshells
```bash
# Slow - creates subshell
result=$(cat file | grep pattern)

# Faster - direct command
result=$(grep pattern file)

# Even faster - use built-ins when possible
while read line; do
    [[ $line =~ pattern ]] && echo "$line"
done < file
```

### 2. Use Built-in Commands
```bash
# Slow - external commands
length=$(echo "$string" | wc -c)

# Fast - parameter expansion
length=${#string}

# Slow - external command
basename=$(basename "$path")

# Fast - parameter expansion
basename=${path##*/}
```

### 3. Minimize External Command Calls
```bash
# Slow - multiple external calls
for file in *.txt; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file")
        echo "$file: $size"
    fi
done

# Faster - batch processing
stat -c'%n: %s' *.txt 2>/dev/null
```

## Command Optimization

### 1. Choose the Right Tool
```bash
# For simple pattern matching
grep "pattern" file          # Fast for simple patterns
awk '/pattern/' file         # Better for complex processing
sed -n '/pattern/p' file     # Good for stream editing

# For counting
wc -l file                   # Fastest for line counting
grep -c "pattern" file       # Fast for pattern counting
awk 'END {print NR}' file    # Slower but more flexible
```

### 2. Use Appropriate Options
```bash
# Use -q for existence checks
if grep -q "pattern" file; then
    echo "Found"
fi

# Use -m for early termination
first_match=$(grep -m1 "pattern" file)

# Use -F for literal strings
grep -F "literal.string" file  # Faster than regex
```

### 3. Pipeline Optimization
```bash
# Slow - multiple pipes
cat file | grep pattern | sort | uniq

# Better - fewer commands
grep pattern file | sort -u

# Even better - single command when possible
sort -u file | grep pattern  # If order allows
```

## Loop Optimization

### 1. Avoid Loops When Possible
```bash
# Slow - loop with external commands
for file in *.txt; do
    wc -l "$file"
done

# Fast - single command
wc -l *.txt
```

### 2. Optimize Loop Structure
```bash
# Slow - command substitution in loop condition
while [ $(wc -l < file) -gt 0 ]; do
    # process
done

# Fast - calculate once
line_count=$(wc -l < file)
while [ $line_count -gt 0 ]; do
    # process
    ((line_count--))
done
```

### 3. Use Efficient Loop Types
```bash
# For arrays - use for loop
for item in "${array[@]}"; do
    process "$item"
done

# For ranges - use C-style loop
for ((i=0; i<1000; i++)); do
    process $i
done

# For file processing - use while read
while IFS= read -r line; do
    process "$line"
done < file
```

## String Operations

### 1. Parameter Expansion vs External Commands
```bash
# Slow
filename=$(basename "$path")
extension=$(echo "$filename" | cut -d. -f2)

# Fast
filename=${path##*/}
extension=${filename##*.}

# Slow
uppercase=$(echo "$string" | tr '[:lower:]' '[:upper:]')

# Fast (Bash 4+)
uppercase=${string^^}
```

### 2. String Concatenation
```bash
# Slow - repeated concatenation
result=""
for item in "${array[@]}"; do
    result="$result$item"
done

# Faster - use array and join
result_array=()
for item in "${array[@]}"; do
    result_array+=("$item")
done
result=$(IFS=''; echo "${result_array[*]}")

# Fastest - printf
printf -v result '%s' "${array[@]}"
```

### 3. Pattern Matching
```bash
# Use [[ ]] for pattern matching
if [[ $filename == *.txt ]]; then
    echo "Text file"
fi

# Use case for multiple patterns
case $filename in
    *.txt|*.doc) echo "Document" ;;
    *.jpg|*.png) echo "Image" ;;
esac
```

## File Operations

### 1. Reading Files Efficiently
```bash
# Slow - line by line with cat
cat file | while read line; do
    process "$line"
done

# Fast - direct file reading
while IFS= read -r line; do
    process "$line"
done < file

# For small files - read entire file
content=$(<file)
```

### 2. File Testing
```bash
# Use appropriate test operators
[[ -f file ]]      # File exists and is regular file
[[ -d dir ]]       # Directory exists
[[ -r file ]]      # File is readable
[[ -s file ]]      # File exists and is not empty

# Combine tests when possible
if [[ -f file && -r file ]]; then
    process_file
fi
```

### 3. Directory Operations
```bash
# Use find efficiently
find . -name "*.txt" -type f -exec process {} +  # Batch processing
find . -name "*.txt" -type f | xargs process     # Pipeline

# Use shell globbing when possible
shopt -s globstar
for file in **/*.txt; do
    [[ -f $file ]] && process "$file"
done
```

## Process Management

### 1. Background Processing
```bash
# Process files in parallel
for file in *.txt; do
    process_file "$file" &
done
wait  # Wait for all background jobs

# Limit concurrent processes
max_jobs=4
job_count=0
for file in *.txt; do
    if ((job_count >= max_jobs)); then
        wait -n  # Wait for any job to complete
        ((job_count--))
    fi
    process_file "$file" &
    ((job_count++))
done
wait
```

### 2. Process Substitution
```bash
# Compare outputs without temporary files
diff <(command1) <(command2)

# Process multiple streams
while read -r line1 <&3 && read -r line2 <&4; do
    process "$line1" "$line2"
done 3< file1 4< file2
```

## Memory Management

### 1. Large File Processing
```bash
# Don't load entire file into memory
# Bad
content=$(cat large_file)
process "$content"

# Good
while IFS= read -r line; do
    process "$line"
done < large_file
```

### 2. Array Management
```bash
# Clear arrays when done
unset large_array

# Use associative arrays for lookups
declare -A lookup
for item in "${items[@]}"; do
    lookup[$item]=1
done

# Check membership
if [[ ${lookup[$key]} ]]; then
    echo "Found"
fi
```

## Profiling and Benchmarking

### 1. Time Measurement
```bash
# Basic timing
time command

# More detailed timing
{ time command; } 2>&1

# Custom timing
start_time=$(date +%s.%N)
command
end_time=$(date +%s.%N)
duration=$(echo "$end_time - $start_time" | bc)
echo "Duration: $duration seconds"
```

### 2. Profiling Functions
```bash
# Profile function calls
profile_function() {
    local func_name="$1"
    shift
    local start_time=$(date +%s.%N)
    "$func_name" "$@"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    echo "Function $func_name took $duration seconds" >&2
}

# Usage
profile_function my_function arg1 arg2
```

### 3. Memory Usage
```bash
# Monitor memory usage
monitor_memory() {
    local pid=$1
    while kill -0 $pid 2>/dev/null; do
        ps -o pid,rss,vsz -p $pid
        sleep 1
    done
}

# Usage
long_running_command &
monitor_memory $!
```

## Best Practices

### 1. Algorithm Optimization
```bash
# Use appropriate data structures
# For frequent lookups - associative arrays
# For ordered data - indexed arrays
# For unique items - associative arrays as sets

# Avoid nested loops when possible
# Bad - O(n²)
for item1 in "${array1[@]}"; do
    for item2 in "${array2[@]}"; do
        if [[ $item1 == $item2 ]]; then
            echo "Match: $item1"
        fi
    done
done

# Good - O(n)
declare -A set1
for item in "${array1[@]}"; do
    set1[$item]=1
done
for item in "${array2[@]}"; do
    if [[ ${set1[$item]} ]]; then
        echo "Match: $item"
    fi
done
```

### 2. I/O Optimization
```bash
# Batch I/O operations
# Bad - multiple writes
for item in "${items[@]}"; do
    echo "$item" >> output_file
done

# Good - single write
printf '%s\n' "${items[@]}" > output_file

# Use appropriate buffer sizes
# For large files
while IFS= read -r -n 8192 chunk; do
    process "$chunk"
done < large_file
```

### 3. Resource Management
```bash
# Clean up resources
cleanup() {
    rm -f "$temp_file"
    kill $background_pid 2>/dev/null
}
trap cleanup EXIT

# Use local variables in functions
my_function() {
    local temp_var="value"
    # Process with temp_var
}

# Avoid global variables when possible
```

### 4. Caching and Memoization
```bash
# Cache expensive operations
declare -A cache

expensive_operation() {
    local key="$1"
    
    if [[ ${cache[$key]} ]]; then
        echo "${cache[$key]}"
        return
    fi
    
    # Perform expensive calculation
    local result=$(complex_calculation "$key")
    cache[$key]="$result"
    echo "$result"
}
```

### 5. Lazy Evaluation
```bash
# Only compute when needed
get_expensive_value() {
    if [[ -z $expensive_value ]]; then
        expensive_value=$(expensive_computation)
    fi
    echo "$expensive_value"
}
```

## Performance Testing Script

```bash
#!/bin/bash
# Performance testing framework

benchmark() {
    local name="$1"
    local iterations="${2:-1000}"
    shift 2
    
    echo "Benchmarking: $name ($iterations iterations)"
    
    local start_time=$(date +%s.%N)
    for ((i=0; i<iterations; i++)); do
        "$@" >/dev/null 2>&1
    done
    local end_time=$(date +%s.%N)
    
    local total_time=$(echo "$end_time - $start_time" | bc)
    local avg_time=$(echo "scale=6; $total_time / $iterations" | bc)
    
    printf "Total: %.6f seconds, Average: %.6f seconds\n" "$total_time" "$avg_time"
}

# Example usage
benchmark "Parameter expansion" 10000 test_param_expansion
benchmark "External command" 10000 test_external_command
```

## Quick Reference

### Fast Operations
- Parameter expansion: `${var#pattern}`
- Built-in tests: `[[ condition ]]`
- Array operations: `"${array[@]}"`
- Here strings: `command <<< "$string"`
- Process substitution: `<(command)`

### Slow Operations
- Unnecessary subshells: `$(cat file | grep pattern)`
- External commands for simple tasks: `$(basename "$path")`
- Repeated string concatenation: `result="$result$new"`
- Nested loops: `for i in ...; do for j in ...; done; done`
- Multiple file reads: `cat file | while read line`

### Memory Efficient
- Stream processing: `while read line; do ... done < file`
- Process substitution: `diff <(cmd1) <(cmd2)`
- Lazy evaluation: Compute only when needed
- Resource cleanup: Use `trap` for cleanup

Remember: **Profile first, optimize second!** Always measure performance before and after optimization to ensure improvements. 