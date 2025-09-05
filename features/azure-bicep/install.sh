#!/bin/bash

# Install Azure Bicep CLI
# https://github.com/Azure/bicep

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

log_info "Installing Azure Bicep CLI v${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Azure Bicep CLI feature only supports Linux"
    exit 1
fi

# Map architecture to Bicep naming convention
BICEP_ARCH="x64"
if [[ "$ARCH" == "arm64" ]]; then
    BICEP_ARCH="arm64"
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Construct download URL
if [ "${VERSION}" = "latest" ]; then        
    BICEP_URL="https://github.com/Azure/bicep/releases/latest/download/bicep-linux-${BICEP_ARCH}"
else
    BICEP_URL="https://github.com/Azure/bicep/releases/download/${VERSION}/bicep-linux-${BICEP_ARCH}"
fi

BICEP_BINARY="bicep-linux-${BICEP_ARCH}"

log_info "Downloading Azure Bicep CLI from $BICEP_URL"
download_file "$BICEP_URL" "$BICEP_BINARY"

# Make binary executable
chmod +x "$BICEP_BINARY"

# Install binary
install_binary "./$BICEP_BINARY" "bicep"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists bicep; then
    INSTALLED_VERSION=$(bicep --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Azure Bicep CLI installed successfully: $INSTALLED_VERSION"
else
    log_error "Azure Bicep CLI installation failed"
    exit 1
fi
