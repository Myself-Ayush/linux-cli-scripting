# Bash Scripting Cheat Sheet 📋

## Variables
```bash
# Basic variables
NAME="John"
AGE=25
echo "Hello $NAME, you are $AGE years old"

# Command substitution
CURRENT_DATE=$(date)
FILE_COUNT=$(ls | wc -l)

# Environment variables
echo $HOME
echo $PATH
echo $USER

# Special variables
echo $0    # Script name
echo $1    # First argument
echo $#    # Number of arguments
echo $@    # All arguments
echo $$    # Process ID
echo $?    # Exit status of last command
```

## Conditional Statements
```bash
# Basic if-else
if [ $AGE -gt 18 ]; then
    echo "Adult"
else
    echo "Minor"
fi

# String comparison
if [ "$NAME" = "John" ]; then
    echo "Hello John"
fi

# File tests
if [ -f "file.txt" ]; then
    echo "File exists"
fi

# Multiple conditions
if [ $AGE -gt 18 ] && [ "$LICENSE" = "yes" ]; then
    echo "Can drive"
fi

# Case statement
case $DAY in
    "Monday")
        echo "Start of week"
        ;;
    "Friday")
        echo "TGIF!"
        ;;
    *)
        echo "Regular day"
        ;;
esac
```

## Loops
```bash
# For loop with range
for i in {1..5}; do
    echo $i
done

# For loop with array
FRUITS=("apple" "banana" "cherry")
for fruit in "${FRUITS[@]}"; do
    echo $fruit
done

# While loop
counter=1
while [ $counter -le 5 ]; do
    echo $counter
    ((counter++))
done

# Until loop
until [ $counter -gt 5 ]; do
    echo $counter
    ((counter++))
done
```

## Functions
```bash
# Basic function
greet() {
    echo "Hello $1"
}

# Function with return value
add() {
    local result=$(($1 + $2))
    echo $result
}

# Call functions
greet "World"
sum=$(add 5 3)
```

## Arrays
```bash
# Create array
FRUITS=("apple" "banana" "cherry")

# Access elements
echo ${FRUITS[0]}      # First element
echo ${FRUITS[@]}      # All elements
echo ${#FRUITS[@]}     # Array length

# Add to array
FRUITS+=("date")

# Associative array (Bash 4+)
declare -A PERSON
PERSON["name"]="John"
PERSON["age"]="30"
```

## File Operations
```bash
# Read file
while IFS= read -r line; do
    echo "$line"
done < file.txt

# Write to file
echo "content" > file.txt     # Overwrite
echo "content" >> file.txt    # Append

# File tests
[ -f file ]     # File exists
[ -d dir ]      # Directory exists
[ -r file ]     # Readable
[ -w file ]     # Writable
[ -x file ]     # Executable
[ -s file ]     # File not empty
```

## String Operations
```bash
STRING="Hello World"

# Length
echo ${#STRING}

# Substring
echo ${STRING:0:5}     # "Hello"
echo ${STRING:6}       # "World"

# Replace
echo ${STRING/World/Universe}  # "Hello Universe"
echo ${STRING//l/L}           # "HeLLo WorLd"

# Case conversion
echo ${STRING^^}       # "HELLO WORLD"
echo ${STRING,,}       # "hello world"
```

## Input/Output
```bash
# Read user input
read -p "Enter name: " NAME
read -s -p "Enter password: " PASS  # Silent input

# Here document
cat << EOF
This is a
multi-line
text
EOF
```

## Error Handling
```bash
# Exit codes
command || echo "Command failed"
command && echo "Command succeeded"

# Strict mode
set -euo pipefail

# Trap errors
trap 'echo "Error on line $LINENO"' ERR
```

## Common Patterns
```bash
# Check if command exists
if command -v git &> /dev/null; then
    echo "Git is installed"
fi

# Process all files in directory
for file in *.txt; do
    [ -f "$file" ] || continue
    echo "Processing $file"
done

# Backup with timestamp
cp file.txt "file.txt.backup.$(date +%Y%m%d_%H%M%S)"

# Menu system
while true; do
    echo "1. Option 1"
    echo "2. Option 2"
    echo "0. Exit"
    read -p "Choose: " choice
    case $choice in
        1) echo "Option 1 selected" ;;
        2) echo "Option 2 selected" ;;
        0) break ;;
        *) echo "Invalid option" ;;
    esac
done
```

## Useful Commands
```bash
# Text processing
grep "pattern" file      # Search text
sed 's/old/new/g' file  # Replace text
awk '{print $1}' file   # Print first column
sort file               # Sort lines
uniq file              # Remove duplicates
wc -l file             # Count lines

# File operations
find . -name "*.txt"    # Find files
xargs                   # Execute command for each input
tar -czf archive.tar.gz dir/  # Create archive
```

## Best Practices
1. **Always quote variables**: `"$VAR"` not `$VAR`
2. **Use `set -euo pipefail`** for strict error handling
3. **Check exit codes**: `command || handle_error`
4. **Use local variables** in functions: `local var="value"`
5. **Validate inputs** before processing
6. **Use meaningful variable names**
7. **Add comments** for complex logic
8. **Test scripts thoroughly**
9. **Use ShellCheck** for static analysis
10. **Handle edge cases** (empty files, missing directories, etc.)
