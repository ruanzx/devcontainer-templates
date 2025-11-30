#!/bin/bash

# Install Strix
# https://github.com/usestrix/strix

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
VERSION="${VERSION:-"0.4.0"}"

log_info "Installing Strix v${VERSION}"

# Check system requirements
if [[ "$(get_os)" != "linux" ]]; then
    log_error "Strix feature currently only supports Linux"
    exit 1
fi

# Ensure pipx is available
if ! command_exists pipx; then
    log_info "pipx not found, installing pipx"
    
    # Install pipx using pip
    if command_exists pip3; then
        run_with_privileges pip3 install --user pipx
        run_with_privileges pip3 install --user --upgrade pipx
    elif command_exists pip; then
        run_with_privileges pip install --user pipx
        run_with_privileges pip install --user --upgrade pipx
    else
        log_error "pip/pip3 not found. Please install Python and pip first."
        log_info "Consider using the Python feature: ghcr.io/devcontainers/features/python:1"
        exit 1
    fi
    
    # Ensure pipx is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Verify pipx installation
    if ! command_exists pipx; then
        log_error "Failed to install pipx"
        exit 1
    fi
    
    log_success "pipx installed successfully"
fi

# Install Strix using pipx
log_info "Installing Strix using pipx"

# For specific version, use version specifier
if [[ "$VERSION" == "latest" ]]; then
    PACKAGE_SPEC="strix-agent"
else
    PACKAGE_SPEC="strix-agent==${VERSION}"
fi

# Install with pipx
if pipx install "$PACKAGE_SPEC"; then
    log_success "Strix installed successfully via pipx"
else
    log_error "Failed to install Strix via pipx"
    exit 1
fi

# Ensure pipx bin directory is in PATH for all users
PIPX_BIN_DIR="$HOME/.local/bin"
if [[ -d "$PIPX_BIN_DIR" ]]; then
    # Add to profile if not already there
    if ! grep -q "export PATH=.*\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        log_info "Added pipx bin directory to .bashrc"
    fi
fi

# Verify installation
export PATH="$HOME/.local/bin:$PATH"

if command_exists strix; then
    INSTALLED_VERSION=$(strix --version 2>/dev/null || echo "installed")
    log_success "Strix installed successfully: $INSTALLED_VERSION"
    log_info "Run 'strix --help' to get started"
    log_warning "Note: Strix requires Docker to be running and an LLM API key to function"
    log_info "Set STRIX_LLM and LLM_API_KEY environment variables before using Strix"
else
    log_error "Strix installation verification failed"
    log_info "Try running: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi
