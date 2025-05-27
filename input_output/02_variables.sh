#!/bin/bash
# Lesson 2: Variables and Data Types

echo "=== Basic Variables ==="
# Variables (no spaces around =)
NAME="John"
AGE=25
echo "Static variable: $NAME is $AGE years old"

echo ""
echo "=== User Input Variables ==="
# User input
read -p "Enter your name: " USER_NAME
read -p "Enter your age: " USER_AGE
echo "Hello $USER_NAME, you are $USER_AGE years old"

echo ""
echo "=== Different ways to use variables ==="
echo "Direct: $NAME"
echo "With braces: ${NAME}"
echo "Concatenation: ${NAME}_suffix"

echo ""
echo "=== Numeric Operations ==="
NUM1=10
NUM2=5
echo "NUM1 = $NUM1, NUM2 = $NUM2"
echo "Sum: $((NUM1 + NUM2))"
echo "Difference: $((NUM1 - NUM2))"
echo "Product: $((NUM1 * NUM2))"
echo "Division: $((NUM1 / NUM2))"

echo ""
echo "=== Command Substitution ==="
CURRENT_DATE=$(date)
CURRENT_USER=$(whoami)
CURRENT_DIR=$(pwd)
FILE_COUNT=$(ls -1 | wc -l)

echo "Today is: $CURRENT_DATE"
echo "Current user: $CURRENT_USER"
echo "Current directory: $CURRENT_DIR"
echo "Files in directory: $FILE_COUNT"

echo ""
echo "=== Environment Variables ==="
echo "Home directory: $HOME"
echo "Shell: $SHELL"
echo "Path: $PATH"
