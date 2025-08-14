#!/bin/bash

# APT Feature Demonstration Script
# This script demonstrates the packages installed by the APT feature

echo "🎉 APT Feature Demo - Installed Package Showcase"
echo "================================================"
echo

echo "📦 Checking installed packages..."
echo

# Check each package individually
packages=("htop" "tree" "curl" "wget" "vim" "git" "jq" "unzip" "zip" "nano")

for package in "${packages[@]}"; do
    if command -v "$package" &> /dev/null; then
        version=$(case "$package" in
            "htop") htop --version 2>&1 | head -n1 ;;
            "tree") tree --version 2>&1 | head -n1 ;;
            "curl") curl --version 2>&1 | head -n1 ;;
            "wget") wget --version 2>&1 | head -n1 ;;
            "vim") vim --version 2>&1 | head -n1 ;;
            "git") git --version 2>&1 ;;
            "jq") jq --version 2>&1 ;;
            "unzip") unzip -v 2>&1 | head -n1 ;;
            "zip") zip -v 2>&1 | head -n2 | tail -n1 ;;
            "nano") nano --version 2>&1 | head -n1 ;;
        esac)
        echo "✅ $package: $version"
    else
        echo "❌ $package: Not found"
    fi
done

echo
echo "🔍 Package details from dpkg:"
dpkg -l | grep -E 'htop|tree|curl|wget|vim|git|jq|unzip|zip|nano' | awk '{printf "  %-15s %s\n", $2, $3}' | sort

echo
echo "📁 Demonstrating tree command:"
tree -L 2 /usr/local 2>/dev/null || echo "  /usr/local directory structure not available"

echo
echo "🌐 Demonstrating curl command:"
echo "  Fetching a simple JSON API..."
curl -s "https://api.github.com/zen" 2>/dev/null | head -c 100 || echo "  Network not available"

echo
echo
echo "🎯 All packages are ready for use in your development environment!"
echo "Try these commands:"
echo "  - htop           # Interactive process viewer"
echo "  - tree           # Directory tree visualization"  
echo "  - curl <url>     # HTTP client"
echo "  - jq             # JSON processor"
echo "  - vim <file>     # Text editor"
echo "  - nano <file>    # Simple text editor"
