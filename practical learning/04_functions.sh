#!/bin/bash
# Lesson 5: Functions - Reusable Code Blocks

echo "=== Basic Function ==="
# Define a simple function
greet() {
    echo "Hello from the greet function!"
}

# Call the function
greet

echo ""
echo "=== Function with Parameters ==="
greet_user() {
    local name=$1
    local age=$2
    echo "Hello $name! You are $age years old."
}

# Call function with arguments
greet_user "Alice" 25
greet_user "Bob" 30

echo ""
echo "=== Function with Return Value ==="
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result  # This is the "return" value
}

# Capture function output
sum=$(add_numbers 15 25)
echo "Sum of 15 and 25 is: $sum"

echo ""
echo "=== Function with Multiple Operations ==="
file_info() {
    local filename=$1
    
    if [ -f "$filename" ]; then
        echo "File: $filename"
        echo "Size: $(ls -lh $filename | awk '{print $5}')"
        echo "Lines: $(wc -l < $filename)"
        echo "Words: $(wc -w < $filename)"
        echo "Last modified: $(stat -c %y $filename)"
    else
        echo "File $filename does not exist!"
        return 1  # Return error code
    fi
}

# Test with current script
echo "Information about this script:"
file_info "$0"

echo ""
echo "=== Interactive Function ==="
calculator() {
    echo "Simple Calculator"
    read -p "Enter first number: " num1
    read -p "Enter operation (+, -, *, /): " op
    read -p "Enter second number: " num2
    
    case $op in
        "+")
            result=$((num1 + num2))
            ;;
        "-")
            result=$((num1 - num2))
            ;;
        "*")
            result=$((num1 * num2))
            ;;
        "/")
            if [ $num2 -eq 0 ]; then
                echo "Error: Division by zero!"
                return 1
            fi
            result=$((num1 / num2))
            ;;
        *)
            echo "Invalid operation!"
            return 1
            ;;
    esac
    
    echo "Result: $num1 $op $num2 = $result"
}

# Call the calculator
read -p "Do you want to use the calculator? (y/n): " USE_CALC
if [ "$USE_CALC" = "y" ]; then
    calculator
fi

echo ""
echo "=== Function with Global and Local Variables ==="
global_var="I am global"

demo_scope() {
    local local_var="I am local"
    global_var="Modified global"
    
    echo "Inside function:"
    echo "  Local: $local_var"
    echo "  Global: $global_var"
}

echo "Before function call:"
echo "  Global: $global_var"

demo_scope

echo "After function call:"
echo "  Global: $global_var"
# echo "  Local: $local_var"  # This would cause an error
