#!/bin/bash
# File Operations - Lesson 2: Directory Management

echo "=== Creating Directory Structure ==="

# Create nested directories
mkdir -p test_project/{src,docs,tests,config}
mkdir -p test_project/src/{main,utils}
mkdir -p test_project/docs/{user,dev}

echo "Created directory structure:"
tree test_project 2>/dev/null || find test_project -type d | sed 's/[^/]*\//  /g'

echo ""
echo "=== Working with Directories ==="

# Navigate and create files
cd test_project

# Create some sample files
echo "# Main Application" > src/main/app.sh
echo "# Utility Functions" > src/utils/helpers.sh
echo "# User Manual" > docs/user/manual.md
echo "# API Documentation" > docs/dev/api.md
echo "# Configuration" > config/settings.conf
echo "# Test Suite" > tests/test_suite.sh

echo "Created files in project structure:"
find . -type f | sort

echo ""
echo "=== Directory Information ==="

echo "Current directory: $(pwd)"
echo "Directory size: $(du -sh . | cut -f1)"
echo "Number of files: $(find . -type f | wc -l)"
echo "Number of directories: $(find . -type d | wc -l)"

echo ""
echo "=== Finding Files ==="

echo "All .sh files:"
find . -name "*.sh" -type f

echo ""
echo "All .md files:"
find . -name "*.md" -type f

echo ""
echo "=== Directory Permissions ==="

echo "Directory permissions:"
ls -la

echo ""
echo "=== Copying and Moving Directories ==="

# Copy directory
cp -r ../test_project ../test_project_backup
echo "Created backup of test_project"

# Move back to parent directory
cd ..

echo ""
echo "=== Interactive Directory Operations ==="

read -p "Enter name for a new directory: " dirname
mkdir -p "$dirname"
echo "Created directory: $dirname"

read -p "Enter a subdirectory name: " subdirname
mkdir -p "$dirname/$subdirname"
echo "Created subdirectory: $dirname/$subdirname"

echo ""
echo "Current directory structure:"
ls -la

# Cleanup
echo ""
read -p "Do you want to clean up test directories? (y/n): " cleanup
if [ "$cleanup" = "y" ]; then
    rm -rf test_project test_project_backup "$dirname"
    echo "Cleanup completed!"
fi
