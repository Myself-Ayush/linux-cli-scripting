#!/bin/bash
# Lesson 6: Arrays and Advanced Data Handling

echo "=== Basic Arrays ==="
# Create array
fruits=("apple" "banana" "cherry" "date")

# Access elements
echo "First fruit: ${fruits[0]}"
echo "Second fruit: ${fruits[1]}"
echo "All fruits: ${fruits[@]}"
echo "Number of fruits: ${#fruits[@]}"

echo ""
echo "=== Adding to Arrays ==="
fruits+=("elderberry")
fruits[5]="fig"
echo "Updated fruits: ${fruits[@]}"
echo "Now we have ${#fruits[@]} fruits"

echo ""
echo "=== Looping Through Arrays ==="
echo "Fruits with index:"
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[$i]}"
done

echo ""
echo "=== Associative Arrays (Bash 4+) ==="
declare -A person
person["name"]="John Doe"
person["age"]="30"
person["city"]="New York"
person["job"]="Developer"

echo "Person Information:"
for key in "${!person[@]}"; do
    echo "$key: ${person[$key]}"
done

echo ""
echo "=== Array Operations ==="
numbers=(1 2 3 4 5 6 7 8 9 10)
echo "Original numbers: ${numbers[@]}"

# Get slice of array
echo "First 5 numbers: ${numbers[@]:0:5}"
echo "Last 3 numbers: ${numbers[@]: -3}"
echo "Middle section: ${numbers[@]:3:4}"

echo ""
echo "=== Array Search and Manipulation ==="
search_in_array() {
    local search_term=$1
    shift  # Remove first argument
    local array=("$@")  # Remaining arguments become array
    
    for item in "${array[@]}"; do
        if [ "$item" = "$search_term" ]; then
            echo "Found: $search_term"
            return 0
        fi
    done
    echo "Not found: $search_term"
    return 1
}

colors=("red" "green" "blue" "yellow" "purple")
echo "Colors: ${colors[@]}"

read -p "Search for a color: " search_color
search_in_array "$search_color" "${colors[@]}"

echo ""
echo "=== Array Sorting ==="
unsorted=(5 2 8 1 9 3)
echo "Unsorted: ${unsorted[@]}"

# Sort array (this creates a new sorted array)
IFS=$'\n' sorted=($(sort -n <<<"${unsorted[*]}"))
unset IFS

echo "Sorted: ${sorted[@]}"

echo ""
echo "=== Reading into Array ==="
echo "Enter 3 favorite movies (press Enter after each):"
movies=()
for i in {1..3}; do
    read -p "Movie $i: " movie
    movies+=("$movie")
done

echo "Your favorite movies:"
for i in "${!movies[@]}"; do
    echo "$((i+1)). ${movies[$i]}"
done

echo ""
echo "=== Array from Command Output ==="
# Get list of .sh files into array
script_files=($(ls *.sh 2>/dev/null))

if [ ${#script_files[@]} -gt 0 ]; then
    echo "Bash scripts found:"
    for script in "${script_files[@]}"; do
        echo "- $script"
    done
else
    echo "No bash scripts found in current directory"
fi
