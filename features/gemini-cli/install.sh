#!/bin/bash

# Install Gemini CLI - Open-source AI agent with Google Gemini integration
# https://github.com/google-gemini/gemini-cli

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
INSTALL_GLOBALLY="${INSTALLGLOBALLY:-"true"}"

log_info "Installing Gemini CLI ${VERSION}"

# Detect system OS
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Gemini CLI feature currently only supports Linux"
    exit 1
fi

# Check if Node.js is available (required for npm)
if ! command_exists node; then
    log_error "Node.js is required for Gemini CLI"
    log_info "Please install Node.js 20+ or use the Node.js DevContainer feature"
    exit 1
fi

# Check if npm is available
if ! command_exists npm; then
    log_error "npm is required for Gemini CLI installation"
    log_info "Please install npm or use the Node.js DevContainer feature"
    exit 1
fi

# Check Node.js version (requires 20+)
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [[ "$NODE_VERSION" -lt 20 ]]; then
    log_warning "Node.js 20+ is required for Gemini CLI (detected: $(node --version))"
    log_info "Consider upgrading Node.js for optimal compatibility"
fi

# Install Gemini CLI
if [[ "$INSTALL_GLOBALLY" == "true" ]]; then
    log_info "Installing Gemini CLI globally using npm"
    
    # Determine the package name based on version
    case "$VERSION" in
        "latest")
            PACKAGE_NAME="@google/gemini-cli@latest"
            ;;
        "preview")
            PACKAGE_NAME="@google/gemini-cli@preview"
            ;;
        "nightly")
            PACKAGE_NAME="@google/gemini-cli@nightly"
            ;;
        *)
            # Assume it's a specific version
            PACKAGE_NAME="@google/gemini-cli@${VERSION}"
            ;;
    esac
    
    # Install with npm global flag
    if npm install -g "$PACKAGE_NAME"; then
        log_success "Gemini CLI installed successfully using npm"
    else
        log_error "Failed to install Gemini CLI using npm"
        exit 1
    fi
else
    log_info "Skipping global installation (installGlobally=false)"
    log_info "You can install Gemini CLI locally with: npm install @google/gemini-cli"
fi

# Verify installation if globally installed
if [[ "$INSTALL_GLOBALLY" == "true" ]]; then
    if command_exists gemini; then
        # Test that gemini command works
        if gemini --version > /dev/null 2>&1; then
            INSTALLED_VERSION=$(gemini --version 2>/dev/null | head -n1 || echo "version unknown")
            log_success "Gemini CLI installed successfully: $INSTALLED_VERSION"
        else
            log_error "Gemini CLI installation failed - command exists but not working properly"
            exit 1
        fi
    else
        log_error "Gemini CLI installation failed - command not found"
        log_info "You may need to restart your shell or check your PATH"
        log_info "Try running: source ~/.bashrc"
        exit 1
    fi
fi

log_info "Gemini CLI installation completed"
log_info "🚀 Getting started:"
log_info "  1. Set up authentication: gemini (choose OAuth, API key, or Vertex AI)"
log_info "  2. Start using Gemini: gemini"
log_info "  3. Run in non-interactive mode: gemini -p \"Your prompt here\""
log_info ""
log_info "📚 For detailed setup and usage, see:"
log_info "  - Authentication: https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/authentication.md"
log_info "  - Quick start: https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/index.md"
