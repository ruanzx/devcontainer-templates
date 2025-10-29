#!/bin/bash

# Install OpenSpec - Spec-driven development for AI coding assistants
# https://github.com/Fission-AI/OpenSpec

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
VERSION="${VERSION:-"latest"}"

log_info "Installing OpenSpec ${VERSION}"

# Detect system OS
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "OpenSpec feature currently only supports Linux"
    exit 1
fi

# Check if Node.js is available
if ! command_exists node; then
    log_error "Node.js is required for OpenSpec but not found"
    log_info "Please add the Node.js DevContainer feature to your devcontainer.json:"
    log_info '  "ghcr.io/devcontainers/features/node:1": { "version": "20" }'
    log_info "Or ensure Node.js 20.19.0+ is available in your base image"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
NODE_MINOR=$(echo "$NODE_VERSION" | cut -d. -f2)

# Require Node.js >= 20.19.0
if [[ "$NODE_MAJOR" -lt 20 ]] || [[ "$NODE_MAJOR" -eq 20 && "$NODE_MINOR" -lt 19 ]]; then
    log_error "Node.js 20.19.0+ is required for OpenSpec (detected: $NODE_VERSION)"
    log_info "Please upgrade Node.js or update your DevContainer feature configuration"
    exit 1
fi

log_success "Node.js ${NODE_VERSION} detected"

# Check if npm is available
if ! command_exists npm; then
    log_error "npm is required for OpenSpec but not found"
    log_info "npm should be included with Node.js"
    exit 1
fi

# Install OpenSpec using npm
log_info "Installing OpenSpec using npm"

if [[ "$VERSION" == "latest" ]]; then
    # Install latest version
    if npm install -g @fission-ai/openspec@latest; then
        log_success "OpenSpec installed successfully"
    else
        log_error "Failed to install OpenSpec"
        exit 1
    fi
else
    # Install specific version
    if npm install -g @fission-ai/openspec@${VERSION}; then
        log_success "OpenSpec ${VERSION} installed successfully"
    else
        log_error "Failed to install OpenSpec ${VERSION}"
        exit 1
    fi
fi

# Verify installation
if command_exists openspec; then
    INSTALLED_VERSION=$(openspec --version 2>/dev/null || echo "unknown")
    log_success "OpenSpec installed and available on PATH"
    log_info "Installed version: ${INSTALLED_VERSION}"
    
    # Test basic command
    if openspec --help > /dev/null 2>&1; then
        log_success "OpenSpec is working correctly"
    else
        log_warning "OpenSpec command exists but may not be functioning properly"
    fi
else
    log_error "OpenSpec installation failed - command not found"
    log_info "You may need to restart your shell or source your profile"
    exit 1
fi

log_success "OpenSpec installation complete!"
log_info "Try these commands to get started:"
log_info "  openspec --version    # Check version"
log_info "  openspec init         # Initialize OpenSpec in your project"
log_info "  openspec list         # View active change folders"
log_info "  openspec view         # Open interactive dashboard"
