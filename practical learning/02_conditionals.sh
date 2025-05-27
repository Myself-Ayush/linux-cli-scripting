#!/bin/bash
# Lesson 3: Conditional Statements and Comparisons

echo "=== Numeric Comparisons ==="
read -p "Enter a number: " NUMBER

if [ $NUMBER -gt 10 ]; then
    echo "$NUMBER is greater than 10"
elif [ $NUMBER -eq 10 ]; then
    echo "$NUMBER equals 10"
else
    echo "$NUMBER is less than 10"
fi

echo ""
echo "=== String Comparisons ==="
read -p "Enter your favorite color: " COLOR

if [ "$COLOR" = "blue" ]; then
    echo "Blue is a nice color!"
elif [ "$COLOR" = "red" ]; then
    echo "Red is energetic!"
else
    echo "$COLOR is an interesting choice!"
fi

echo ""
echo "=== File and Directory Tests ==="
read -p "Enter a filename to check: " FILENAME

if [ -f "$FILENAME" ]; then
    echo "$FILENAME is a regular file"
    echo "File size: $(ls -lh $FILENAME | awk '{print $5}')"
elif [ -d "$FILENAME" ]; then
    echo "$FILENAME is a directory"
    echo "Contents: $(ls -1 $FILENAME | wc -l) items"
else
    echo "$FILENAME does not exist"
    read -p "Do you want to create it as a file? (y/n): " CREATE
    if [ "$CREATE" = "y" ] || [ "$CREATE" = "Y" ]; then
        touch "$FILENAME"
        echo "Created $FILENAME"
    fi
fi

echo ""
echo "=== Multiple Conditions ==="
read -p "Enter your age: " AGE
read -p "Do you have a license? (y/n): " LICENSE

if [ $AGE -ge 18 ] && [ "$LICENSE" = "y" ]; then
    echo "You can drive!"
elif [ $AGE -ge 18 ] && [ "$LICENSE" = "n" ]; then
    echo "You're old enough but need a license"
else
    echo "You're too young to drive"
fi

echo ""
echo "=== Case Statement ==="
read -p "Enter a day of the week: " DAY

case $DAY in
    "Monday"|"monday"|"Mon"|"mon")
        echo "Start of the work week!"
        ;;
    "Friday"|"friday"|"Fri"|"fri")
        echo "TGIF!"
        ;;
    "Saturday"|"sunday"|"Sat"|"Sun")
        echo "Weekend!"
        ;;
    *)
        echo "Regular day"
        ;;
esac
