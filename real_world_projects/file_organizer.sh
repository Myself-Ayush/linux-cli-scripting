#!/bin/bash
# Real World Project - File Organizer Script

echo "=== SMART FILE ORGANIZER ==="

# Configuration
ORGANIZE_DIR="${1:-$(pwd)}"
LOG_FILE="file_organizer.log"
DRY_RUN=false

# File type associations
declare -A FILE_TYPES=(
    ["images"]="jpg jpeg png gif bmp tiff svg webp ico"
    ["documents"]="pdf doc docx txt rtf odt pages"
    ["spreadsheets"]="xls xlsx csv ods numbers"
    ["presentations"]="ppt pptx odp key"
    ["archives"]="zip rar tar gz 7z bz2 xz"
    ["videos"]="mp4 avi mkv mov wmv flv webm m4v"
    ["audio"]="mp3 wav flac aac ogg wma m4a"
    ["code"]="py js html css php java cpp c sh rb go rs"
    ["configs"]="conf cfg ini json yaml yml xml"
    ["executables"]="exe msi deb rpm appimage dmg"
)

# Logging function
log_action() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Create directory if it doesn't exist
create_category_dir() {
    local category="$1"
    local target_dir="$ORGANIZE_DIR/organized/$category"
    
    if [ ! -d "$target_dir" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "Would create directory: $target_dir"
        else
            mkdir -p "$target_dir"
            log_action "Created directory: $target_dir"
        fi
    fi
}

# Get file category based on extension
get_file_category() {
    local file="$1"
    local extension="${file##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    for category in "${!FILE_TYPES[@]}"; do
        if [[ " ${FILE_TYPES[$category]} " =~ " $extension " ]]; then
            echo "$category"
            return 0
        fi
    done
    
    echo "misc"
}

# Organize a single file
organize_file() {
    local file="$1"
    local filename=$(basename "$file")
    local category=$(get_file_category "$filename")
    local target_dir="$ORGANIZE_DIR/organized/$category"
    local target_path="$target_dir/$filename"
    
    # Handle name conflicts
    local counter=1
    local base_name="${filename%.*}"
    local extension="${filename##*.}"
    
    while [ -f "$target_path" ]; do
        if [ "$base_name" = "$extension" ]; then
            # File has no extension
            target_path="$target_dir/${base_name}_$counter"
        else
            target_path="$target_dir/${base_name}_$counter.$extension"
        fi
        ((counter++))
    done
    
    create_category_dir "$category"
    
    if [ "$DRY_RUN" = true ]; then
        echo "Would move: $file -> $target_path"
    else
        mv "$file" "$target_path"
        log_action "Moved: $file -> $target_path"
    fi
}

# Analyze directory contents
analyze_directory() {
    local dir="$1"
    
    echo "📊 DIRECTORY ANALYSIS"
    echo "===================="
    echo "Directory: $dir"
    echo "Analysis date: $(date)"
    echo ""
    
    # Count files by type
    declare -A file_counts
    local total_files=0
    local total_size=0
    
    # Initialize counts
    for category in "${!FILE_TYPES[@]}"; do
        file_counts["$category"]=0
    done
    file_counts["misc"]=0
    
    # Count files
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local category=$(get_file_category "$filename")
            ((file_counts["$category"]++))
            ((total_files++))
            
            local size=$(stat -c%s "$file" 2>/dev/null || echo 0)
            ((total_size+=size))
        fi
    done < <(find "$dir" -maxdepth 1 -type f -print0)
    
    echo "Total files: $total_files"
    echo "Total size: $(numfmt --to=iec $total_size)"
    echo ""
    
    echo "Files by category:"
    for category in "${!file_counts[@]}"; do
        if [ "${file_counts[$category]}" -gt 0 ]; then
            echo "  $category: ${file_counts[$category]} files"
        fi
    done
    echo ""
}

# Clean up empty directories
cleanup_empty_dirs() {
    local base_dir="$1"
    
    echo "🧹 CLEANING UP EMPTY DIRECTORIES"
    echo "================================"
    
    find "$base_dir" -type d -empty | while read -r empty_dir; do
        if [ "$empty_dir" != "$base_dir" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "Would remove empty directory: $empty_dir"
            else
                rmdir "$empty_dir"
                log_action "Removed empty directory: $empty_dir"
            fi
        fi
    done
}

# Duplicate file finder
find_duplicates() {
    local dir="$1"
    
    echo "🔍 FINDING DUPLICATE FILES"
    echo "========================="
    
    # Find files with same size first (quick check)
    declare -A size_files
    
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            local size=$(stat -c%s "$file")
            if [ -n "${size_files[$size]}" ]; then
                size_files["$size"]="${size_files[$size]} $file"
            else
                size_files["$size"]="$file"
            fi
        fi
    done < <(find "$dir" -type f -print0)
    
    # Check potential duplicates with md5sum
    for size in "${!size_files[@]}"; do
        local files=(${size_files[$size]})
        if [ ${#files[@]} -gt 1 ]; then
            echo "Files with same size ($size bytes):"
            for file in "${files[@]}"; do
                local hash=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1)
                echo "  $hash  $file"
            done
            echo ""
        fi
    done
}

# Undo organization
undo_organization() {
    local organized_dir="$ORGANIZE_DIR/organized"
    
    if [ ! -d "$organized_dir" ]; then
        echo "No organized directory found to undo."
        return 1
    fi
    
    echo "🔄 UNDOING FILE ORGANIZATION"
    echo "============================"
    
    find "$organized_dir" -type f | while read -r file; do
        local filename=$(basename "$file")
        local target="$ORGANIZE_DIR/$filename"
        
        # Handle conflicts
        local counter=1
        while [ -f "$target" ]; do
            local base_name="${filename%.*}"
            local extension="${filename##*.}"
            
            if [ "$base_name" = "$extension" ]; then
                target="$ORGANIZE_DIR/${base_name}_restored_$counter"
            else
                target="$ORGANIZE_DIR/${base_name}_restored_$counter.$extension"
            fi
            ((counter++))
        done
        
        if [ "$DRY_RUN" = true ]; then
            echo "Would restore: $file -> $target"
        else
            mv "$file" "$target"
            log_action "Restored: $file -> $target"
        fi
    done
    
    # Remove organized directory structure
    if [ "$DRY_RUN" = false ]; then
        rm -rf "$organized_dir"
        log_action "Removed organized directory structure"
    fi
}

# Generate organization report
generate_report() {
    local report_file="organization_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "FILE ORGANIZATION REPORT"
        echo "Generated on: $(date)"
        echo "Directory: $ORGANIZE_DIR"
        echo "=========================="
        echo ""
        
        analyze_directory "$ORGANIZE_DIR"
        
        if [ -f "$LOG_FILE" ]; then
            echo "Recent actions:"
            tail -20 "$LOG_FILE"
        fi
        
    } > "$report_file"
    
    echo "Report saved to: $report_file"
}

# Interactive menu
show_menu() {
    echo ""
    echo "=== FILE ORGANIZER MENU ==="
    echo "1. Analyze directory"
    echo "2. Organize files"
    echo "3. Find duplicates"
    echo "4. Clean empty directories" 
    echo "5. Undo organization"
    echo "6. Generate report"
    echo "7. Toggle dry run mode (currently: $DRY_RUN)"
    echo "8. Change target directory"
    echo "0. Exit"
    echo ""
    echo "Current directory: $ORGANIZE_DIR"
}

# Main execution
main() {
    log_action "File organizer started"
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "File Organizer - Smart file organization tool"
        echo ""
        echo "Usage: $0 [directory] [options]"
        echo ""
        echo "Options:"
        echo "  --dry-run    Show what would be done without making changes"
        echo "  --analyze    Just analyze the directory"
        echo "  --organize   Organize files immediately"
        echo "  --help       Show this help"
        echo ""
        echo "Interactive mode: Run without options for menu"
        exit 0
    fi
    
    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                echo "Dry run mode enabled"
                ;;
            --analyze)
                analyze_directory "$ORGANIZE_DIR"
                exit 0
                ;;
            --organize)
                echo "Organizing files in $ORGANIZE_DIR..."
                find "$ORGANIZE_DIR" -maxdepth 1 -type f | while read -r file; do
                    organize_file "$file"
                done
                echo "Organization complete!"
                exit 0
                ;;
        esac
        shift
    done
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Select option (0-8): " choice
        
        case $choice in
            1)
                analyze_directory "$ORGANIZE_DIR"
                ;;
            2)
                echo "Organizing files..."
                find "$ORGANIZE_DIR" -maxdepth 1 -type f | while read -r file; do
                    organize_file "$file"
                done
                echo "Organization complete!"
                ;;
            3)
                find_duplicates "$ORGANIZE_DIR"
                ;;
            4)
                cleanup_empty_dirs "$ORGANIZE_DIR"
                ;;
            5)
                undo_organization
                ;;
            6)
                generate_report
                ;;
            7)
                if [ "$DRY_RUN" = true ]; then
                    DRY_RUN=false
                else
                    DRY_RUN=true
                fi
                echo "Dry run mode: $DRY_RUN"
                ;;
            8)
                read -p "Enter new directory path: " new_dir
                if [ -d "$new_dir" ]; then
                    ORGANIZE_DIR="$new_dir"
                    echo "Directory changed to: $ORGANIZE_DIR"
                else
                    echo "Directory does not exist!"
                fi
                ;;
            0)
                log_action "File organizer finished"
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
