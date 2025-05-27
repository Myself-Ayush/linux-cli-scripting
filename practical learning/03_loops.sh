#!/bin/bash
# Lesson 4: Loops - For, While, and Until

echo "=== For Loop with Range ==="
echo "Counting from 1 to 5:"
for i in {1..5}; do
    echo "Number: $i"
    sleep 0.5  # Pause for half second to see the progression
done

echo ""
echo "=== For Loop with Custom Step ==="
echo "Even numbers from 2 to 10:"
for i in {2..10..2}; do
    echo "Even: $i"
done

echo ""
echo "=== For Loop with Array ==="
FRUITS=("apple" "banana" "cherry" "date" "elderberry")
echo "My favorite fruits:"
for fruit in "${FRUITS[@]}"; do
    echo "- I like $fruit"
done

echo ""
echo "=== For Loop with Files ==="
echo "Bash scripts in current directory:"
for file in *.sh; do
    if [ -f "$file" ]; then
        echo "Script: $file ($(wc -l < $file) lines)"
    fi
done

echo ""
echo "=== While Loop with Counter ==="
counter=1
echo "Countdown from 5:"
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    counter=$((counter + 1))
    sleep 0.3
done

echo ""
echo "=== Interactive While Loop ==="
echo "Type messages (type 'quit' to exit):"
while true; do
    read -p "> " input
    if [ "$input" = "quit" ]; then
        echo "Goodbye!"
        break
    elif [ "$input" = "date" ]; then
        echo "Current date: $(date)"
    elif [ "$input" = "user" ]; then
        echo "Current user: $(whoami)"
    else
        echo "You said: $input"
    fi
done

echo ""
echo "=== Until Loop ==="
number=1
echo "Until loop (stops when number > 3):"
until [ $number -gt 3 ]; do
    echo "Number is: $number"
    number=$((number + 1))
done

echo ""
echo "=== Nested Loops ==="
echo "Multiplication table (3x3):"
for i in {1..3}; do
    for j in {1..3}; do
        result=$((i * j))
        echo -n "$i x $j = $result  "
    done
    echo ""  # New line after each row
done
