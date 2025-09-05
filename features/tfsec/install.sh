#!/bin/bash

# Install tfsec - Security scanner for Terraform code
# https://github.com/aquasecurity/tfsec

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

log_info "Installing tfsec ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "tfsec feature only supports Linux"
    exit 1
fi

# Map architecture to tfsec naming convention
case "$ARCH" in
    amd64|x86_64)
        TFSEC_ARCH="amd64"
        ;;
    arm64|aarch64)
        TFSEC_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: linux-$TFSEC_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to get latest version from GitHub API"
        exit 1
    fi
    VERSION="$LATEST_VERSION"
    log_info "Latest version resolved to: $VERSION"
fi

# Normalize version (add 'v' prefix if not present)
if [[ "${VERSION:0:1}" != "v" ]]; then
    VERSION="v${VERSION}"
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download tfsec
TFSEC_URL="https://github.com/aquasecurity/tfsec/releases/download/${VERSION}/tfsec-linux-${TFSEC_ARCH}"
TFSEC_BINARY="tfsec-linux-${TFSEC_ARCH}"

log_info "Downloading tfsec from $TFSEC_URL"
download_file "$TFSEC_URL" "$TFSEC_BINARY"

if [[ ! -f "$TFSEC_BINARY" ]]; then
    log_error "tfsec binary not found after download"
    exit 1
fi

# Install binary
install_binary "$TFSEC_BINARY" "tfsec"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists tfsec; then
    INSTALLED_VERSION=$(tfsec --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "tfsec installed successfully: $INSTALLED_VERSION"
else
    log_error "tfsec installation failed"
    exit 1
fi