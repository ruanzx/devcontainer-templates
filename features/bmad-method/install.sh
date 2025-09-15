#!/bin/bash

# Install BMAD-METHOD Universal AI Agent Framework
# https://github.com/bmad-code-org/BMAD-METHOD

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
INSTALL_WORKSPACE="${INSTALLWORKSPACE:-"false"}"

log_info "Installing BMAD-METHOD Universal AI Agent Framework"

# Ensure Node.js is available
if ! command_exists node; then
    log_error "Node.js is required but not found. Please ensure the Node.js devcontainer feature is installed."
    exit 1
fi

# Check Node.js version (requires v20+)
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [[ "$NODE_VERSION" -lt 20 ]]; then
    log_error "BMAD-METHOD requires Node.js v20 or higher. Current version: $(node --version)"
    exit 1
fi

# Ensure npm is available
if ! command_exists npm; then
    log_error "npm is required but not found. Please ensure the Node.js devcontainer feature is installed with npm."
    exit 1
fi

# Ensure git is available (dependency for BMAD-METHOD)
if ! command_exists git; then
    log_error "git is required but not found. Please ensure git is installed."
    exit 1
fi

log_info "Node.js version: $(node --version)"
log_info "npm version: $(npm --version)"
log_info "git version: $(git --version)"

# Install BMAD-METHOD
if [[ "$INSTALL_WORKSPACE" == "true" ]]; then
    log_info "Installing BMAD-METHOD in current workspace"
    npm install bmad-method
    log_info "Installing BMAD-METHOD framework files"
    npx bmad-method install
else
    log_info "Installing BMAD-METHOD globally"
    npm install -g bmad-method
fi

# Verify installation
if command_exists npx && npx bmad-method --version >/dev/null 2>&1; then
    INSTALLED_VERSION=$(npx bmad-method --version 2>/dev/null || echo "unknown")
    log_success "BMAD-METHOD installed successfully: $INSTALLED_VERSION"
else
    log_error "BMAD-METHOD installation verification failed"
    exit 1
fi

log_success "🎉 BMAD-METHOD Universal AI Agent Framework is ready!"
log_info "💡 To get started:"
if [[ "$INSTALL_WORKSPACE" == "true" ]]; then
    log_info "   • Run 'npx bmad-method install' to set up framework files in your project"
else
    log_info "   • Create a new project directory and run 'npx bmad-method install'"
fi
log_info "   • Visit https://github.com/bmad-code-org/BMAD-METHOD for documentation"
log_info "   • Join the Discord community: https://discord.gg/gk8jAdXWmj"