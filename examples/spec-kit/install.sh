#!/bin/bash

# Install specify-cli - Toolkit to help you get started with Spec-Driven Development
# https://github.com/github/spec-kit

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

log_info "Installing specify-cli ${VERSION}"

# Detect system OS
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "specify-cli feature currently only supports Linux"
    exit 1
fi

# Check if Python 3.11+ is available
if ! command_exists python3; then
    log_warning "Python 3 is not available, attempting to install it"
    
    # Try to install Python using apt (common in Debian/Ubuntu base images)
    if command_exists apt-get; then
        log_info "Installing Python 3 using apt-get"
        apt-get update && apt-get install -y python3 python3-pip python3-venv
        
        # Check if installation was successful
        if ! command_exists python3; then
            log_error "Failed to install Python 3 using apt-get"
            log_info "Please add the Python DevContainer feature to your devcontainer.json:"
            log_info '  "ghcr.io/devcontainers/features/python:1": { "version": "3.11" }'
            log_info "Or ensure Python 3.11+ is available in your base image"
            exit 1
        fi
        log_success "Python 3 installed successfully using apt-get"
    else
        log_error "Python 3 is required for specify-cli and cannot be automatically installed"
        log_info "Please add the Python DevContainer feature to your devcontainer.json:"
        log_info '  "ghcr.io/devcontainers/features/python:1": { "version": "3.11" }'
        log_info "Or ensure Python 3.11+ is available in your base image"
        exit 1
    fi
fi

# Check Python version
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [[ "$PYTHON_MAJOR" -lt 3 ]] || [[ "$PYTHON_MAJOR" -eq 3 && "$PYTHON_MINOR" -lt 11 ]]; then
    log_warning "Python 3.11+ is recommended for specify-cli (detected: $PYTHON_VERSION)"
fi

# Install uv if not available
if ! command_exists uv; then
    log_info "Installing uv package manager (required for specify-cli)"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Verify uv installation
    if ! command_exists uv; then
        log_error "Failed to install uv package manager"
        exit 1
    fi
    log_success "uv package manager installed successfully"
fi

# Ensure uv tool bin is in PATH (always, not just when installing)
UV_BIN_PATH="$HOME/.local/bin"
if [[ ":$PATH:" != *":$UV_BIN_PATH:"* ]]; then
    export PATH="$UV_BIN_PATH:$PATH"
fi

# Install specify-cli using uv
log_info "Installing specify-cli using uv"

if [[ "$VERSION" == "latest" ]]; then
    # Install from git repository (latest)
    uv tool install --python python3 git+https://github.com/github/spec-kit.git
else
    # For specific versions, we would need to check if they have releases
    log_warning "Specific version installation not yet supported, installing latest"
    uv tool install --python python3 git+https://github.com/github/spec-kit.git
fi

# Add uv tool bin to shell profile for persistence
UV_BIN_PATH="$HOME/.local/bin"
if [[ ":$PATH:" != *":$UV_BIN_PATH:"* ]]; then
    echo "export PATH=\"$UV_BIN_PATH:\$PATH\"" >> ~/.bashrc
    echo "export PATH=\"$UV_BIN_PATH:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
fi

# Verify installation
if command_exists specify; then
    # specify doesn't have a --version flag, but we can check if it runs
    if specify --help > /dev/null 2>&1; then
        log_success "specify-cli installed successfully"
    else
        log_error "specify-cli installation failed - command exists but not working properly"
        exit 1
    fi
else
    log_error "specify-cli installation failed - command not found"
    log_info "You may need to restart your shell or source your profile"
    exit 1
fi

log_info "specify-cli installation completed"
log_info "You can now use specify to initialize Spec-Driven Development projects!"
log_info "Example: specify init my-project"
