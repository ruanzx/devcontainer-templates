#!/bin/bash

# Install DevContainers CLI - A reference implementation for the DevContainers specification
# https://github.com/devcontainers/cli

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

# Parse options
VERSION="${VERSION:-"0.80.0"}"
NODE_VERSION="${NODEVERSION:-"lts"}"

log_info "Installing DevContainers CLI v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system OS
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "DevContainers CLI feature currently only supports Linux"
    exit 1
fi

# Check if Node.js is already installed
if command -v node >/dev/null 2>&1; then
    CURRENT_NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//')
    log_info "Node.js ${CURRENT_NODE_VERSION} is already installed"
else
    log_info "Installing Node.js ${NODE_VERSION}"
    
    # Update package lists
    update_packages
    
    # Install prerequisites
    install_packages curl ca-certificates
    
    # Determine Node.js version to install
    if [[ "$NODE_VERSION" == "lts" ]]; then
        # Use Node.js 20 (current LTS)
        NODE_VERSION_TO_INSTALL="20"
        log_info "Installing Node.js 20 (LTS)"
    else
        NODE_VERSION_TO_INSTALL=$(echo "$NODE_VERSION" | cut -d'.' -f1)
        log_info "Installing Node.js ${NODE_VERSION_TO_INSTALL}"
    fi
    
    # Download and install Node.js from official binaries
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get the latest version for the major version
    if [[ "$NODE_VERSION_TO_INSTALL" == "20" ]]; then
        FULL_VERSION="v20.17.0"  # Latest LTS as of 2024
    else
        # For other versions, use a reasonable default
        FULL_VERSION="v${NODE_VERSION_TO_INSTALL}.0.0"
    fi
    
    log_info "Downloading Node.js ${FULL_VERSION}"
    NODE_URL="https://nodejs.org/dist/${FULL_VERSION}/node-${FULL_VERSION}-linux-x64.tar.xz"
    
    curl -fsSL "$NODE_URL" -o "node.tar.xz"
    
    # Extract and install
    tar -xf node.tar.xz
    NODE_DIR="node-${FULL_VERSION}-linux-x64"
    
    # Move to system directories
    cp -r "${NODE_DIR}/bin/"* /usr/local/bin/
    cp -r "${NODE_DIR}/lib/"* /usr/local/lib/
    cp -r "${NODE_DIR}/include/"* /usr/local/include/ 2>/dev/null || true
    cp -r "${NODE_DIR}/share/"* /usr/local/share/ 2>/dev/null || true
    
    # Clean up
    cd /
    rm -rf "$TEMP_DIR"
    
    # Verify Node.js installation
    if command -v node >/dev/null 2>&1; then
        INSTALLED_NODE_VERSION=$(node --version)
        log_success "Node.js ${INSTALLED_NODE_VERSION} installed successfully"
    else
        log_error "Failed to install Node.js"
        exit 1
    fi
fi

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    log_error "npm is not available. Node.js installation may be incomplete."
    exit 1
fi

log_info "Installing @devcontainers/cli@${VERSION} globally"

# Install DevContainers CLI globally
npm install -g "@devcontainers/cli@${VERSION}"

# Verify installation
if command -v devcontainer >/dev/null 2>&1; then
    INSTALLED_CLI_VERSION=$(devcontainer --version 2>/dev/null || echo "unknown")
    log_success "DevContainers CLI installed successfully"
    log_info "Version: ${INSTALLED_CLI_VERSION}"
    log_info "Command available: devcontainer"
else
    log_error "Failed to install DevContainers CLI"
    exit 1
fi

# Add npm global bin to PATH if not already there
NPM_BIN_PATH=$(npm config get prefix)/bin
if [[ ":$PATH:" != *":$NPM_BIN_PATH:"* ]]; then
    log_info "Adding npm global bin to PATH: $NPM_BIN_PATH"
    echo "export PATH=\"$NPM_BIN_PATH:\$PATH\"" >> /etc/bash.bashrc
    echo "export PATH=\"$NPM_BIN_PATH:\$PATH\"" >> /etc/zsh/zshrc 2>/dev/null || true
fi

log_success "DevContainers CLI v${VERSION} installation completed"
log_info "You can now use 'devcontainer' command to work with dev containers"
log_info "Example commands:"
log_info "  devcontainer build ."
log_info "  devcontainer up ."
log_info "  devcontainer exec bash"
