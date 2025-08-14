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

log_info "Installing DevContainers CLI v${VERSION}"
log_info "Node.js dependency:"
log_info "  This feature requires Node.js (installed via ghcr.io/devcontainers/features/node:1)"

# Validate version
validate_version "$VERSION"

# Detect system OS
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "DevContainers CLI feature currently only supports Linux"
    exit 1
fi

# Verify Node.js is available
if ! command -v node >/dev/null 2>&1; then
    log_error "Node.js is not available. Make sure the Node.js feature is installed first."
    log_error "Add 'ghcr.io/devcontainers/features/node:1' to your devcontainer.json features"
    exit 1
fi

CURRENT_NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//')
log_info "Using Node.js ${CURRENT_NODE_VERSION}"

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
