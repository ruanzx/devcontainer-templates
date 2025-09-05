#!/bin/bash

# Install Gitsign - Keyless Git signing with Sigstore
# https://github.com/sigstore/gitsign

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
CONFIGURE_GIT="${CONFIGUREGIT:-"true"}"

log_info "Installing Gitsign ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Gitsign feature only supports Linux"
    exit 1
fi

# Map architecture to Gitsign naming convention
case "$ARCH" in
    amd64|x86_64)
        GITSIGN_ARCH="amd64"
        ;;
    arm64|aarch64)
        GITSIGN_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: linux-$GITSIGN_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates git

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/sigstore/gitsign/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
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

# Download Gitsign
GITSIGN_URL="https://github.com/sigstore/gitsign/releases/download/v${VERSION}/gitsign_${VERSION}_linux_${GITSIGN_ARCH}"
GITSIGN_BINARY="gitsign_${VERSION}_linux_${GITSIGN_ARCH}"

log_info "Downloading Gitsign from $GITSIGN_URL"
download_file "$GITSIGN_URL" "$GITSIGN_BINARY"

if [[ ! -f "$GITSIGN_BINARY" ]]; then
    log_error "Gitsign binary not found after download"
    exit 1
fi

# Install binary
install_binary "$GITSIGN_BINARY" "gitsign"

# Configure git to use gitsign (if requested)
if [[ "$CONFIGURE_GIT" == "true" ]]; then
    log_info "Configuring git to use gitsign for signing"
    
    # Set global git configuration for gitsign
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    git config --global gpg.x509.program gitsign
    git config --global gpg.format x509
    
    log_info "Git configured to use gitsign for commit and tag signing"
fi

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists gitsign; then
    INSTALLED_VERSION=$(gitsign version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Gitsign installed successfully: $INSTALLED_VERSION"
else
    log_error "Gitsign installation failed"
    exit 1
fi