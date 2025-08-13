#!/bin/bash

# Install Gitleaks - Secret detector for git repos
# https://github.com/gitleaks/gitleaks

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/utils.sh"

# Parse options
VERSION="${VERSION:-"8.21.1"}"

log_info "Installing Gitleaks v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Gitleaks feature currently only supports Linux"
    exit 1
fi

# Map architecture for Gitleaks release naming
case "$ARCH" in
    "amd64") GITLEAKS_ARCH="x64" ;;
    "arm64") GITLEAKS_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for Gitleaks: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Gitleaks
GITLEAKS_URL="https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/gitleaks_${VERSION}_linux_${GITLEAKS_ARCH}.tar.gz"
GITLEAKS_ARCHIVE="gitleaks.tar.gz"

log_info "Downloading Gitleaks from $GITLEAKS_URL"
download_file "$GITLEAKS_URL" "$GITLEAKS_ARCHIVE"

# Extract archive
log_info "Extracting Gitleaks"
extract_archive "$GITLEAKS_ARCHIVE"

# Install binary
install_binary "./gitleaks" "gitleaks"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists gitleaks; then
    INSTALLED_VERSION=$(gitleaks version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Gitleaks installed successfully: $INSTALLED_VERSION"
else
    log_error "Gitleaks installation failed"
    exit 1
fi
