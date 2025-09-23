#!/bin/bash

# Install global npm packages
# https://docs.npmjs.com/

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to source utils.sh from multiple locations
if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    source "${SCRIPT_DIR}/utils.sh"
elif [[ -f "${SCRIPT_DIR}/../../common/utils.sh" ]]; then
    source "${SCRIPT_DIR}/../../common/utils.sh"
else
    echo "Error: Could not find utils.sh"
    exit 1
fi

# Get options
PACKAGES=${PACKAGES:-""}
REGISTRY=${REGISTRY:-""}
INSTALL_LATEST=${INSTALLLATEST:-"true"}
UPDATE_NPM=${UPDATENPM:-"false"}

log_info "Setting up npm global package installation..."

# Function to check if Node.js and npm are available
check_nodejs() {
    if ! command_exists node; then
        log_error "Node.js is not installed. Please install Node.js first."
        log_info "You can add the Node.js feature to your devcontainer.json:"
        log_info "\"ghcr.io/devcontainers/features/node:latest\": {}"
        exit 1
    fi
    
    if ! command_exists npm; then
        log_error "npm is not available. npm should be included with Node.js installation."
        exit 1
    fi
    
    log_info "Node.js version: $(node --version)"
    log_info "npm version: $(npm --version)"
}

# Function to validate package names
validate_packages() {
    local packages="$1"
    local invalid_packages=()
    
    if [ -z "$packages" ]; then
        log_warning "No packages specified for installation"
        return 0
    fi
    
    # Convert comma-separated list to array
    IFS=',' read -ra package_array <<< "$packages"
    
    # Basic validation - check for obviously invalid characters
    for package in "${package_array[@]}"; do
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Check for invalid characters (basic validation)
        # Valid: letters, numbers, dots, hyphens, slashes, @ symbols, underscores
        if [[ ! "$package" =~ ^[a-zA-Z0-9._@/-]+$ ]]; then
            invalid_packages+=("$package")
        fi
    done
    
    if [ ${#invalid_packages[@]} -gt 0 ]; then
        log_error "Invalid package names detected:"
        printf '  - %s\n' "${invalid_packages[@]}"
        log_error "Package names should only contain letters, numbers, dots, hyphens, slashes, @ symbols, and underscores"
        return 1
    fi
}

# Function to configure npm registry
configure_registry() {
    local registry="$1"
    
    if [ -n "$registry" ]; then
        log_info "Setting npm registry to: $registry"
        npm config set registry "$registry"
        log_success "npm registry configured"
    fi
}

# Function to update npm
update_npm() {
    if [ "$UPDATE_NPM" = "true" ]; then
        log_info "Updating npm to latest version..."
        npm install -g npm@latest
        log_success "npm updated to version: $(npm --version)"
    fi
}

# Function to install packages
install_packages() {
    local packages="$1"
    
    if [ -z "$packages" ]; then
        log_info "No packages to install"
        return 0
    fi
    
    log_info "Installing global npm packages: $packages"
    
    # Convert comma-separated list to array
    IFS=',' read -ra package_array <<< "$packages"
    
    # Install each package
    for package in "${package_array[@]}"; do
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Skip empty packages
        if [ -z "$package" ]; then
            continue
        fi
        
        # Add @latest if requested and not already specified
        if [ "$INSTALL_LATEST" = "true" ] && [[ ! "$package" =~ @ ]]; then
            package="${package}@latest"
        fi
        
        log_info "Installing package: $package"
        
        # Install package globally
        if npm install -g "$package"; then
            log_success "Successfully installed: $package"
        else
            log_error "Failed to install: $package"
            exit 1
        fi
    done
    
    log_success "All packages installed successfully"
}

# Function to list installed global packages
list_installed_packages() {
    log_info "Listing installed global packages:"
    npm list -g --depth=0 2>/dev/null | grep -v "npm@" || true
}

# Check if Node.js and npm are available
check_nodejs

# Validate package list
if ! validate_packages "$PACKAGES"; then
    exit 1
fi

# Configure npm registry if specified
configure_registry "$REGISTRY"

# Update npm if requested
update_npm

# Install requested packages
install_packages "$PACKAGES"

# List installed packages for verification
if [ -n "$PACKAGES" ]; then
    echo ""
    list_installed_packages
    echo ""
fi

# Summary
if [ -n "$PACKAGES" ]; then
    log_success "npm global package installation completed!"
    echo ""
    echo "Installed packages: $PACKAGES"
    echo "Registry: ${REGISTRY:-"default (npmjs.org)"}"
    echo "Install latest: $INSTALL_LATEST"
    echo ""
    echo "You can verify installed packages with:"
    echo "  npm list -g --depth=0"
    echo ""
    echo "To run installed CLI tools, use them directly from the command line"
    echo "Example: If you installed 'typescript', you can use 'tsc --version'"
else
    log_info "npm feature configured but no packages were installed"
    echo "To install packages, specify them in the 'packages' option"
    echo "Example: \"packages\": \"typescript,nodemon,@angular/cli\""
fi