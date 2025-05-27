#!/bin/bash
# Linux Distribution Detection and Package Management Script

echo "=== LINUX DISTRIBUTION DETECTOR AND PACKAGE MANAGER ==="

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        PRETTY_NAME=$PRETTY_NAME
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
        VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
        PRETTY_NAME=$(cat /etc/redhat-release)
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
        VERSION=$(cat /etc/debian_version)
        PRETTY_NAME="Debian $VERSION"
    else
        DISTRO="unknown"
        VERSION="unknown"
        PRETTY_NAME="Unknown Linux Distribution"
    fi
    
    echo "🐧 DISTRIBUTION INFORMATION"
    echo "=========================="
    echo "Distribution: $DISTRO"
    echo "Version: $VERSION"
    echo "Full Name: $PRETTY_NAME"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo ""
}

# Function to get package manager info
get_package_manager() {
    echo "📦 PACKAGE MANAGER INFORMATION"
    echo "============================="
    
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        echo "Package Manager: APT (Advanced Package Tool)"
        echo "Package Format: .deb"
        echo "Configuration: /etc/apt/"
        echo "Cache Location: /var/cache/apt/"
        echo ""
        
        echo "Common APT Commands:"
        echo "  Update:    sudo apt update"
        echo "  Upgrade:   sudo apt upgrade"
        echo "  Install:   sudo apt install <package>"
        echo "  Remove:    sudo apt remove <package>"
        echo "  Search:    apt search <keyword>"
        echo ""
        
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        echo "Package Manager: DNF (Dandified YUM)"
        echo "Package Format: .rpm"
        echo "Configuration: /etc/dnf/"
        echo "Cache Location: /var/cache/dnf/"
        echo ""
        
        echo "Common DNF Commands:"
        echo "  Update:    sudo dnf update"
        echo "  Install:   sudo dnf install <package>"
        echo "  Remove:    sudo dnf remove <package>"
        echo "  Search:    dnf search <keyword>"
        echo ""
        
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        echo "Package Manager: YUM (Yellowdog Updater Modified)"
        echo "Package Format: .rpm"
        echo "Configuration: /etc/yum.conf, /etc/yum.repos.d/"
        echo "Cache Location: /var/cache/yum/"
        echo ""
        
        echo "Common YUM Commands:"
        echo "  Update:    sudo yum update"
        echo "  Install:   sudo yum install <package>"
        echo "  Remove:    sudo yum remove <package>"
        echo "  Search:    yum search <keyword>"
        echo ""
        
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        echo "Package Manager: Pacman"
        echo "Package Format: .pkg.tar.xz"
        echo "Configuration: /etc/pacman.conf"
        echo "Database: /var/lib/pacman/"
        echo ""
        
        echo "Common Pacman Commands:"
        echo "  Update:    sudo pacman -Syu"
        echo "  Install:   sudo pacman -S <package>"
        echo "  Remove:    sudo pacman -R <package>"
        echo "  Search:    pacman -Ss <keyword>"
        echo ""
        
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        echo "Package Manager: Zypper"
        echo "Package Format: .rpm"
        echo "Configuration: /etc/zypp/"
        echo "Repositories: /etc/zypp/repos.d/"
        echo ""
        
        echo "Common Zypper Commands:"
        echo "  Update:    sudo zypper update"
        echo "  Install:   sudo zypper install <package>"
        echo "  Remove:    sudo zypper remove <package>"
        echo "  Search:    zypper search <keyword>"
        echo ""
        
    elif command -v apk &> /dev/null; then
        PKG_MANAGER="apk"
        echo "Package Manager: APK"
        echo "Package Format: .apk"
        echo "Configuration: /etc/apk/"
        echo "Database: /lib/apk/db/"
        echo ""
        
        echo "Common APK Commands:"
        echo "  Update:    apk update"
        echo "  Install:   apk add <package>"
        echo "  Remove:    apk del <package>"
        echo "  Search:    apk search <keyword>"
        echo ""
        
    elif command -v emerge &> /dev/null; then
        PKG_MANAGER="portage"
        echo "Package Manager: Portage (emerge)"
        echo "Package Format: Source-based"
        echo "Configuration: /etc/portage/"
        echo "Tree: /var/db/repos/gentoo/"
        echo ""
        
        echo "Common Portage Commands:"
        echo "  Sync:      emerge --sync"
        echo "  Install:   emerge <package>"
        echo "  Remove:    emerge --unmerge <package>"
        echo "  Search:    emerge --search <keyword>"
        echo ""
    else
        PKG_MANAGER="unknown"
        echo "Package Manager: Unknown or not detected"
        echo ""
    fi
}

# Function to show installed packages count
show_package_stats() {
    echo "📊 PACKAGE STATISTICS"
    echo "===================="
    
    case $PKG_MANAGER in
        "apt")
            installed_count=$(dpkg -l | grep '^ii' | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: /var/lib/dpkg/status"
            ;;
        "dnf"|"yum")
            installed_count=$(rpm -qa | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: RPM database"
            ;;
        "pacman")
            installed_count=$(pacman -Q | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: /var/lib/pacman/local/"
            ;;
        "zypper")
            installed_count=$(rpm -qa | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: RPM database"
            ;;
        "apk")
            installed_count=$(apk info | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: /lib/apk/db/"
            ;;
        "portage")
            installed_count=$(find /var/db/pkg -mindepth 2 -maxdepth 2 -type d | wc -l)
            echo "Installed packages: $installed_count"
            echo "Package database: /var/db/pkg/"
            ;;
        *)
            echo "Cannot determine package count for unknown package manager"
            ;;
    esac
    echo ""
}

# Function to show repositories
show_repositories() {
    echo "🗂️  REPOSITORIES"
    echo "==============="
    
    case $PKG_MANAGER in
        "apt")
            echo "Active repositories:"
            grep -h "^deb " /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | head -5
            echo "..."
            echo ""
            echo "Repository files: /etc/apt/sources.list, /etc/apt/sources.list.d/"
            ;;
        "dnf")
            echo "Enabled repositories:"
            dnf repolist enabled 2>/dev/null | head -10
            echo ""
            ;;
        "yum")
            echo "Enabled repositories:"
            yum repolist enabled 2>/dev/null | head -10
            echo ""
            ;;
        "pacman")
            echo "Repository configuration:"
            grep "^\[" /etc/pacman.conf 2>/dev/null | head -5
            echo ""
            echo "Mirrorlist: /etc/pacman.d/mirrorlist"
            ;;
        "zypper")
            echo "Configured repositories:"
            zypper repos 2>/dev/null | head -10
            echo ""
            ;;
        "apk")
            echo "Repository list:"
            cat /etc/apk/repositories 2>/dev/null | head -5
            echo ""
            ;;
        "portage")
            echo "Portage repositories:"
            find /var/db/repos -maxdepth 1 -type d -name "*" | head -5
            echo ""
            ;;
        *)
            echo "Repository information not available for unknown package manager"
            ;;
    esac
}

# Function to demonstrate package operations
demo_package_operations() {
    echo "🔧 PACKAGE OPERATION EXAMPLES"
    echo "============================="
    
    read -p "Enter a package name to demonstrate operations (or press Enter for 'curl'): " demo_package
    demo_package=${demo_package:-curl}
    
    echo ""
    echo "Examples for package: $demo_package"
    echo ""
    
    case $PKG_MANAGER in
        "apt")
            echo "Search:    apt search $demo_package"
            echo "Info:      apt show $demo_package"
            echo "Install:   sudo apt install $demo_package"
            echo "Remove:    sudo apt remove $demo_package"
            echo "Check:     dpkg -l | grep $demo_package"
            ;;
        "dnf")
            echo "Search:    dnf search $demo_package"
            echo "Info:      dnf info $demo_package"
            echo "Install:   sudo dnf install $demo_package"
            echo "Remove:    sudo dnf remove $demo_package"
            echo "Check:     rpm -qa | grep $demo_package"
            ;;
        "yum")
            echo "Search:    yum search $demo_package"
            echo "Info:      yum info $demo_package"
            echo "Install:   sudo yum install $demo_package"
            echo "Remove:    sudo yum remove $demo_package"
            echo "Check:     rpm -qa | grep $demo_package"
            ;;
        "pacman")
            echo "Search:    pacman -Ss $demo_package"
            echo "Info:      pacman -Si $demo_package"
            echo "Install:   sudo pacman -S $demo_package"
            echo "Remove:    sudo pacman -R $demo_package"
            echo "Check:     pacman -Q | grep $demo_package"
            ;;
        "zypper")
            echo "Search:    zypper search $demo_package"
            echo "Info:      zypper info $demo_package"
            echo "Install:   sudo zypper install $demo_package"
            echo "Remove:    sudo zypper remove $demo_package"
            echo "Check:     rpm -qa | grep $demo_package"
            ;;
        "apk")
            echo "Search:    apk search $demo_package"
            echo "Info:      apk info $demo_package"
            echo "Install:   apk add $demo_package"
            echo "Remove:    apk del $demo_package"
            echo "Check:     apk info | grep $demo_package"
            ;;
        "portage")
            echo "Search:    emerge --search $demo_package"
            echo "Info:      emerge --info $demo_package"
            echo "Install:   emerge $demo_package"
            echo "Remove:    emerge --unmerge $demo_package"
            echo "Check:     qlist -I | grep $demo_package"
            ;;
        *)
            echo "Package operations not available for unknown package manager"
            ;;
    esac
    echo ""
}

# Function to run actual package search
run_package_search() {
    echo "🔍 LIVE PACKAGE SEARCH"
    echo "====================="
    
    read -p "Enter package name to search for: " search_term
    
    if [ -z "$search_term" ]; then
        echo "No search term provided."
        return 1
    fi
    
    echo ""
    echo "Searching for: $search_term"
    echo "=============================="
    
    case $PKG_MANAGER in
        "apt")
            apt search "$search_term" 2>/dev/null | head -10
            ;;
        "dnf")
            dnf search "$search_term" 2>/dev/null | head -10
            ;;
        "yum")
            yum search "$search_term" 2>/dev/null | head -10
            ;;
        "pacman")
            pacman -Ss "$search_term" | head -10
            ;;
        "zypper")
            zypper search "$search_term" 2>/dev/null | head -10
            ;;
        "apk")
            apk search "$search_term" | head -10
            ;;
        "portage")
            emerge --search "$search_term" | head -10
            ;;
        *)
            echo "Search not available for unknown package manager"
            ;;
    esac
    echo ""
}

# Interactive menu
show_menu() {
    echo "=== LINUX DISTRIBUTION PACKAGE MANAGER TOOL ==="
    echo "1. Show distribution information"
    echo "2. Show package manager details"
    echo "3. Show package statistics"
    echo "4. Show repositories"
    echo "5. Demo package operations"
    echo "6. Live package search"
    echo "7. Show all information"
    echo "0. Exit"
    echo ""
}

# Main execution
main() {
    detect_distro
    get_package_manager
    
    if [ "$1" = "--auto" ]; then
        show_package_stats
        show_repositories
        demo_package_operations
        exit 0
    fi
    
    while true; do
        show_menu
        read -p "Select option (0-7): " choice
        
        case $choice in
            1)
                detect_distro
                ;;
            2)
                get_package_manager
                ;;
            3)
                show_package_stats
                ;;
            4)
                show_repositories
                ;;
            5)
                demo_package_operations
                ;;
            6)
                run_package_search
                ;;
            7)
                detect_distro
                get_package_manager
                show_package_stats
                show_repositories
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Run main function
main "$@"
