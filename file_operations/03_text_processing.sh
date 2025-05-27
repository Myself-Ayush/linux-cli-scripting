#!/bin/bash
# File Operations - Lesson 3: Text Processing (grep, sed, awk)

echo "=== Text Processing Tools ==="

# Create sample data for demonstration
cat > sample_data.txt << 'EOF'
John Doe,25,Engineer,New York,75000
Jane Smith,30,Manager,California,85000
Bob Johnson,28,Developer,Texas,70000
Alice Brown,35,Designer,Florida,65000
Charlie Wilson,22,Intern,New York,35000
Diana Davis,29,Engineer,California,78000
EOF

echo "Sample data created:"
cat sample_data.txt
echo ""

echo "=== GREP - Pattern Searching ==="

echo "1. Basic grep - find lines containing 'Engineer':"
grep "Engineer" sample_data.txt

echo ""
echo "2. Case-insensitive search (-i):"
grep -i "engineer" sample_data.txt

echo ""
echo "3. Count matches (-c):"
grep -c "Engineer" sample_data.txt

echo ""
echo "4. Show line numbers (-n):"
grep -n "New York" sample_data.txt

echo ""
echo "5. Invert match (-v) - lines NOT containing 'Engineer':"
grep -v "Engineer" sample_data.txt

echo ""
echo "6. Regular expressions - find ages in 20s:"
grep -E "2[0-9]," sample_data.txt

echo ""
echo "7. Multiple patterns (-E with |):"
grep -E "(Engineer|Manager)" sample_data.txt

echo ""
echo "8. Word boundaries (-w):"
echo "Testing word boundaries with sample text..."
echo -e "cat\ncatch\nscatter" | grep -w "cat"

echo ""
echo "=== SED - Stream Editor ==="

echo "1. Basic substitution - replace 'Engineer' with 'Software Engineer':"
sed 's/Engineer/Software Engineer/' sample_data.txt

echo ""
echo "2. Global substitution (all occurrences in line):"
echo "New York, New York" | sed 's/New/Old/g'

echo ""
echo "3. Case-insensitive substitution:"
sed 's/engineer/Software Engineer/I' sample_data.txt

echo ""
echo "4. Delete lines containing pattern:"
sed '/Intern/d' sample_data.txt

echo ""
echo "5. Print specific lines (line 2-4):"
sed -n '2,4p' sample_data.txt

echo ""
echo "6. Insert text before pattern:"
sed '/Manager/i\--- Management Team ---' sample_data.txt

echo ""
echo "7. Append text after pattern:"
sed '/Manager/a\--- End Management ---' sample_data.txt

echo ""
echo "8. Multiple commands with -e:"
sed -e 's/Engineer/Dev/' -e 's/Manager/Lead/' sample_data.txt

echo ""
echo "=== AWK - Pattern Scanning and Processing ==="

echo "1. Print specific columns (name and salary):"
awk -F',' '{print $1, $5}' sample_data.txt

echo ""
echo "2. Print with custom formatting:"
awk -F',' '{printf "%-15s %s\n", $1, $3}' sample_data.txt

echo ""
echo "3. Filter by condition (salary > 70000):"
awk -F',' '$5 > 70000 {print $1, $5}' sample_data.txt

echo ""
echo "4. Calculate sum of salaries:"
awk -F',' '{sum += $5} END {print "Total salaries: $" sum}' sample_data.txt

echo ""
echo "5. Count records by location:"
awk -F',' '{count[$4]++} END {for (loc in count) print loc ": " count[loc]}' sample_data.txt

echo ""
echo "6. Add header and format output:"
awk -F',' 'BEGIN {print "Name\t\tAge\tPosition"} {printf "%-15s %s\t%s\n", $1, $2, $3}' sample_data.txt

echo ""
echo "7. Pattern matching with awk:"
awk -F',' '/Engineer/ {print $1 " is an engineer in " $4}' sample_data.txt

echo ""
echo "8. Mathematical operations:"
awk -F',' '{print $1 ": Annual salary = $" $5 ", Monthly = $" $5/12}' sample_data.txt

echo ""
echo "=== CUT - Extract Columns ==="

echo "1. Extract specific fields (names only):"
cut -d',' -f1 sample_data.txt

echo ""
echo "2. Extract multiple fields (name and position):"
cut -d',' -f1,3 sample_data.txt

echo ""
echo "3. Extract character ranges:"
echo "Hello World" | cut -c1-5

echo ""
echo "=== SORT - Sorting Text ==="

echo "1. Sort by name (default alphabetical):"
sort sample_data.txt

echo ""
echo "2. Sort by age (numeric, field 2):"
sort -t',' -k2 -n sample_data.txt

echo ""
echo "3. Sort by salary (reverse numeric, field 5):"
sort -t',' -k5 -nr sample_data.txt

echo ""
echo "=== UNIQ - Remove Duplicates ==="

# Create data with duplicates
cat > duplicate_data.txt << 'EOF'
apple
banana
apple
cherry
banana
date
EOF

echo "Sample data with duplicates:"
cat duplicate_data.txt

echo ""
echo "1. Remove consecutive duplicates:"
sort duplicate_data.txt | uniq

echo ""
echo "2. Count occurrences:"
sort duplicate_data.txt | uniq -c

echo ""
echo "3. Show only duplicates:"
sort duplicate_data.txt | uniq -d

echo ""
echo "=== TR - Character Translation ==="

echo "1. Convert to uppercase:"
echo "hello world" | tr '[:lower:]' '[:upper:]'

echo ""
echo "2. Replace characters:"
echo "hello-world" | tr '-' '_'

echo ""
echo "3. Delete characters:"
echo "hello123world" | tr -d '[:digit:]'

echo ""
echo "4. Squeeze repeated characters:"
echo "hello    world" | tr -s ' '

echo ""
echo "=== WC - Word Count ==="

echo "1. Count lines, words, characters:"
wc sample_data.txt

echo ""
echo "2. Count only lines:"
wc -l sample_data.txt

echo ""
echo "3. Count only words:"
wc -w sample_data.txt

echo ""
echo "=== Advanced Text Processing Examples ==="

echo "1. Extract email domains (if we had email data):"
echo -e "user@gmail.com\nadmin@company.org\ntest@yahoo.com" | sed 's/.*@//' | sort | uniq

echo ""
echo "2. Process log-like data:"
cat > log_sample.txt << 'EOF'
2024-01-01 10:30:15 INFO User login successful
2024-01-01 10:31:22 ERROR Database connection failed
2024-01-01 10:32:45 INFO User logout
2024-01-01 10:33:12 WARN Low disk space
2024-01-01 10:34:55 ERROR Authentication failed
EOF

echo "Log sample:"
cat log_sample.txt

echo ""
echo "Extract only ERROR messages:"
grep "ERROR" log_sample.txt

echo ""
echo "Count message types:"
awk '{print $3}' log_sample.txt | sort | uniq -c

echo ""
echo "Extract timestamps of errors:"
grep "ERROR" log_sample.txt | awk '{print $1, $2}'

echo ""
echo "=== Combining Tools with Pipes ==="

echo "1. Find highest paid employee:"
sort -t',' -k5 -nr sample_data.txt | head -1 | awk -F',' '{print $1 " earns $" $5}'

echo ""
echo "2. Count employees by position:"
cut -d',' -f3 sample_data.txt | sort | uniq -c | sort -nr

echo ""
echo "3. Average salary calculation:"
awk -F',' '{sum += $5; count++} END {print "Average salary: $" sum/count}' sample_data.txt

echo ""
echo "=== Cleanup ==="
rm -f sample_data.txt duplicate_data.txt log_sample.txt
echo "Temporary files cleaned up."

echo ""
echo "=== Text Processing Summary ==="
echo "✓ grep: Search patterns in text"
echo "✓ sed: Stream editor for filtering and transforming text"
echo "✓ awk: Pattern scanning and data extraction language"
echo "✓ cut: Extract specific columns or characters"
echo "✓ sort: Sort lines of text"
echo "✓ uniq: Report or omit repeated lines"
echo "✓ tr: Translate or delete characters"
echo "✓ wc: Count lines, words, and characters"
echo ""
echo "These tools are the foundation of text processing in Unix/Linux!" 