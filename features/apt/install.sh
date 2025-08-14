#!/bin/bash

# Install packages using APT package manager
# https://wiki.debian.org/Apt

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
fi

# Get options
PACKAGES=${PACKAGES:-""}
CLEAN_CACHE=${CLEANCACHE:-"true"}
UPDATE_PACKAGE_LIST=${UPDATEPACKAGELIST:-"true"}
UPGRADE_PACKAGES=${UPGRADEPACKAGES:-"false"}

# Function to check if running on Debian-like system
check_debian_like() {
    if [ ! -f /etc/debian_version ] && ! command -v apt >/dev/null 2>&1; then
        echo "❌ This feature requires a Debian-like system with APT package manager"
        echo "Current system does not appear to support APT"
        exit 1
    fi
}

# Function to validate package names
validate_packages() {
    local packages="$1"
    local invalid_packages=()
    
    if [ -z "$packages" ]; then
        echo "⚠️ No packages specified for installation"
        return 0
    fi
    
    # Convert comma-separated list to array
    IFS=',' read -ra package_array <<< "$packages"
    
    # Basic validation - check for obviously invalid characters
    for package in "${package_array[@]}"; do
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Check for invalid characters (basic validation)
        # Valid: letters, numbers, dots, hyphens, plus signs, underscores, colons
        if [[ ! "$package" =~ ^[a-zA-Z0-9._+-:]+$ ]]; then
            invalid_packages+=("$package")
        fi
    done
    
    if [ ${#invalid_packages[@]} -gt 0 ]; then
        echo "❌ Invalid package names detected:"
        printf '  - %s\n' "${invalid_packages[@]}"
        echo "Package names should only contain letters, numbers, dots, hyphens, plus signs, and underscores"
        return 1
    fi
}

# Function to install packages
install_packages() {
    local packages="$1"
    
    if [ -z "$packages" ]; then
        echo "ℹ️ No packages to install"
        return 0
    fi
    
    echo "📦 Installing packages: $packages"
    
    # Convert comma-separated list to space-separated for apt
    local package_list
    package_list=$(echo "$packages" | tr ',' ' ')
    
    # Install packages
    DEBIAN_FRONTEND=noninteractive apt-get install -y $package_list
    
    echo "✅ Packages installed successfully"
}

echo "🔧 Setting up APT package installation..."

# Check if system supports APT
check_debian_like

# Validate package list
if ! validate_packages "$PACKAGES"; then
    exit 1
fi

# Update package list if requested
if [ "$UPDATE_PACKAGE_LIST" = "true" ]; then
    echo "🔄 Updating package list..."
    apt-get update
    echo "✅ Package list updated"
fi

# Upgrade existing packages if requested
if [ "$UPGRADE_PACKAGES" = "true" ]; then
    echo "⬆️ Upgrading existing packages..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    echo "✅ Packages upgraded"
fi

# Install requested packages
install_packages "$PACKAGES"

# Clean package cache if requested
if [ "$CLEAN_CACHE" = "true" ]; then
    echo "🧹 Cleaning package cache..."
    apt-get autoremove -y
    apt-get autoclean
    rm -rf /var/lib/apt/lists/*
    echo "✅ Package cache cleaned"
fi

# Summary
if [ -n "$PACKAGES" ]; then
    echo "🎉 APT package installation completed!"
    echo ""
    echo "Installed packages: $PACKAGES"
    echo "Cache cleaned: $CLEAN_CACHE"
    echo ""
    echo "You can verify installed packages with:"
    echo "  dpkg -l | grep -E '$(echo "$PACKAGES" | tr ',' '|')'"
else
    echo "ℹ️ APT feature configured but no packages were installed"
    echo "To install packages, specify them in the 'packages' option"
fi
