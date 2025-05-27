#!/bin/bash
# File Operations - Lesson 1: Reading and Writing Files

echo "=== Creating and Writing Files ==="

# Create a simple text file
echo "Hello, World!" > sample.txt
echo "This is line 2" >> sample.txt
echo "This is line 3" >> sample.txt

echo "Created sample.txt with content:"
cat sample.txt

echo ""
echo "=== Reading Files Line by Line ==="

# Read file line by line
line_number=1
while IFS= read -r line; do
    echo "Line $line_number: $line"
    ((line_number++))
done < sample.txt

echo ""
echo "=== Checking File Properties ==="

if [ -f "sample.txt" ]; then
    echo "File exists!"
    echo "File size: $(stat -c%s sample.txt) bytes"
    echo "File permissions: $(stat -c%A sample.txt)"
    echo "Last modified: $(stat -c%y sample.txt)"
else
    echo "File does not exist!"
fi

echo ""
echo "=== File Content Manipulation ==="

# Count lines, words, characters
echo "File statistics:"
echo "Lines: $(wc -l < sample.txt)"
echo "Words: $(wc -w < sample.txt)"
echo "Characters: $(wc -c < sample.txt)"

echo ""
echo "=== Interactive File Operations ==="

read -p "Enter a filename to create: " filename
read -p "Enter content for the file: " content

echo "$content" > "$filename"
echo "Created $filename with your content:"
cat "$filename"

# Clean up
echo ""
read -p "Do you want to delete the test files? (y/n): " cleanup
if [ "$cleanup" = "y" ]; then
    rm -f sample.txt "$filename"
    echo "Files cleaned up!"
fi
