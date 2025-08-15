#!/bin/bash

# Install Lazygit - A simple terminal UI for git commands
# https://github.com/jesseduffield/lazygit

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
VERSION="${VERSION:-"0.54.2"}"

log_info "Installing Lazygit v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Lazygit feature currently only supports Linux"
    exit 1
fi

# Map architecture for Lazygit release naming
case "$ARCH" in
    "amd64") LAZYGIT_ARCH="x86_64" ;;
    "arm64") LAZYGIT_ARCH="arm64" ;;
    "armv7l") LAZYGIT_ARCH="armv6" ;;
    *) 
        log_error "Unsupported architecture for Lazygit: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Lazygit
# URL pattern: https://github.com/jesseduffield/lazygit/releases/download/v0.54.2/lazygit_0.54.2_Linux_x86_64.tar.gz
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
LAZYGIT_ARCHIVE="lazygit.tar.gz"

log_info "Downloading Lazygit from $LAZYGIT_URL"
download_file "$LAZYGIT_URL" "$LAZYGIT_ARCHIVE"

# Extract archive
log_info "Extracting Lazygit"
extract_archive "$LAZYGIT_ARCHIVE"

# Find the lazygit binary in the extracted directory
LAZYGIT_BINARY="lazygit"
if [[ ! -f "$LAZYGIT_BINARY" ]]; then
    log_error "Lazygit binary not found in expected location: $LAZYGIT_BINARY"
    exit 1
fi

# Install binary
install_binary "./$LAZYGIT_BINARY" "lazygit"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists lazygit; then
    INSTALLED_VERSION=$(lazygit --version 2>/dev/null | grep -o 'version=[0-9.]*' | cut -d= -f2 || echo "unknown")
    log_success "Lazygit installed successfully: v$INSTALLED_VERSION"
else
    log_error "Lazygit installation failed"
    exit 1
fi
