#!/bin/bash
# Advanced Concepts - Lesson 1: Command Line Arguments

echo "=== Script Information ==="
echo "Script name: $0"
echo "Number of arguments: $#"
echo "All arguments: $@"
echo "All arguments (as string): $*"

echo ""
echo "=== Processing Arguments ==="

if [ $# -eq 0 ]; then
    echo "No arguments provided!"
    echo "Usage: $0 <name> <age> [city]"
    echo "Example: $0 John 25 'New York'"
    exit 1
fi

# Access individual arguments
NAME=$1
AGE=$2
CITY=${3:-"Unknown"}  # Default value if not provided

echo "Name: $NAME"
echo "Age: $AGE"
echo "City: $CITY"

echo ""
echo "=== Argument Validation ==="

# Validate arguments
if [ -z "$NAME" ]; then
    echo "Error: Name is required!"
    exit 1
fi

if ! [[ "$AGE" =~ ^[0-9]+$ ]]; then
    echo "Error: Age must be a number!"
    exit 1
fi

if [ "$AGE" -lt 0 ] || [ "$AGE" -gt 150 ]; then
    echo "Error: Age must be between 0 and 150!"
    exit 1
fi

echo "All arguments are valid!"

echo ""
echo "=== Advanced Argument Processing ==="

# Process all arguments
echo "Processing all arguments:"
for arg in "$@"; do
    echo "  - Argument: $arg"
done

echo ""
echo "=== Using getopts for Options ==="

# Reset for getopts demo
OPTIND=1
verbose=false
output_file=""
input_file=""

# This would work if called with options like: script -v -o output.txt -i input.txt
while getopts "vo:i:h" opt; do
    case $opt in
        v)
            verbose=true
            echo "Verbose mode enabled"
            ;;
        o)
            output_file=$OPTARG
            echo "Output file: $output_file"
            ;;
        i)
            input_file=$OPTARG
            echo "Input file: $input_file"
            ;;
        h)
            echo "Help: $0 [-v] [-o output_file] [-i input_file]"
            echo "  -v: Verbose mode"
            echo "  -o: Output file"
            echo "  -i: Input file"
            echo "  -h: Show this help"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

echo ""
echo "=== Practical Example ==="

# Create a simple file processor based on arguments
process_file() {
    local file=$1
    local operation=$2
    
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found!"
        return 1
    fi
    
    case $operation in
        "count")
            echo "Lines in $file: $(wc -l < "$file")"
            ;;
        "show")
            echo "Content of $file:"
            cat "$file"
            ;;
        "size")
            echo "Size of $file: $(stat -c%s "$file") bytes"
            ;;
        *)
            echo "Unknown operation: $operation"
            echo "Available operations: count, show, size"
            ;;
    esac
}

# Demo with this script itself
echo "Demonstrating file operations on this script:"
process_file "$0" "count"
process_file "$0" "size"

echo ""
echo "=== Summary ==="
echo "Command line arguments processed successfully!"
echo "Remember: Always validate your inputs!"
