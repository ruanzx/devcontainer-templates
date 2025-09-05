#!/bin/bash

# Install Cosign - Container signing verification and signing tool
# https://github.com/sigstore/cosign

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

log_info "Installing Cosign ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Cosign feature only supports Linux"
    exit 1
fi

# Map architecture to Cosign naming convention
case "$ARCH" in
    amd64|x86_64)
        COSIGN_ARCH="amd64"
        ;;
    arm64|aarch64)
        COSIGN_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: linux-$COSIGN_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/sigstore/cosign/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to get latest version from GitHub API"
        exit 1
    fi
    VERSION="$LATEST_VERSION"
    log_info "Latest version resolved to: $VERSION"
fi

# Normalize version (remove 'v' prefix if present)
VERSION="${VERSION#v}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Cosign
COSIGN_URL="https://github.com/sigstore/cosign/releases/download/v${VERSION}/cosign-linux-${COSIGN_ARCH}"
COSIGN_BINARY="cosign-linux-${COSIGN_ARCH}"

log_info "Downloading Cosign from $COSIGN_URL"
download_file "$COSIGN_URL" "$COSIGN_BINARY"

if [[ ! -f "$COSIGN_BINARY" ]]; then
    log_error "Cosign binary not found after download"
    exit 1
fi

# Install binary
install_binary "$COSIGN_BINARY" "cosign"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists cosign; then
    INSTALLED_VERSION=$(cosign version --short 2>/dev/null || cosign version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Cosign installed successfully: $INSTALLED_VERSION"
else
    log_error "Cosign installation failed"
    exit 1
fi