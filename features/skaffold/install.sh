#!/bin/bash

# Install Skaffold
# https://skaffold.dev/

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
VERSION="${VERSION:-"2.16.1"}"

log_info "Installing Skaffold v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Skaffold feature currently only supports Linux"
    exit 1
fi

# Map architecture for Skaffold release naming
case "$ARCH" in
    "amd64") SKAFFOLD_ARCH="amd64" ;;
    "arm64") SKAFFOLD_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for Skaffold: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Skaffold
SKAFFOLD_URL="https://storage.googleapis.com/skaffold/releases/v${VERSION}/skaffold-linux-${SKAFFOLD_ARCH}"
SKAFFOLD_BINARY="skaffold"

log_info "Downloading Skaffold from $SKAFFOLD_URL"
download_file "$SKAFFOLD_URL" "$SKAFFOLD_BINARY"

# Install binary
install_binary "./$SKAFFOLD_BINARY" "skaffold"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists skaffold; then
    INSTALLED_VERSION=$(skaffold version --output=json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    log_success "Skaffold installed successfully: $INSTALLED_VERSION"
else
    log_error "Skaffold installation failed"
    exit 1
fi
