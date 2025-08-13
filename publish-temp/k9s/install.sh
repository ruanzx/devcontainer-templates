#!/bin/bash

# Install K9s - Kubernetes CLI to manage clusters in style
# https://k9scli.io/

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/utils.sh"

# Parse options
VERSION="${VERSION:-"0.32.7"}"

log_info "Installing K9s v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "K9s feature currently only supports Linux"
    exit 1
fi

# Map architecture for K9s release naming
case "$ARCH" in
    "amd64") K9S_ARCH="amd64" ;;
    "arm64") K9S_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for K9s: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download K9s
K9S_URL="https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_${K9S_ARCH}.tar.gz"
K9S_ARCHIVE="k9s.tar.gz"

log_info "Downloading K9s from $K9S_URL"
download_file "$K9S_URL" "$K9S_ARCHIVE"

# Extract archive
log_info "Extracting K9s"
extract_archive "$K9S_ARCHIVE"

# Install binary
install_binary "./k9s" "k9s"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists k9s; then
    INSTALLED_VERSION=$(k9s version --short 2>/dev/null | head -n1 | awk '{print $2}' || echo "unknown")
    log_success "K9s installed successfully: $INSTALLED_VERSION"
else
    log_error "K9s installation failed"
    exit 1
fi

# Install K9s - Kubernetes CLI
# https://k9scli.io/

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/utils.sh"

# Parse options
VERSION="${VERSION:-"0.32.7"}"

log_info "Installing K9s v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "K9s feature currently only supports Linux"
    exit 1
fi

# Map architecture for K9s release naming
case "$ARCH" in
    "amd64") K9S_ARCH="amd64" ;;
    "arm64") K9S_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for K9s: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download K9s
K9S_URL="https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_${K9S_ARCH}.tar.gz"
K9S_ARCHIVE="k9s.tar.gz"

log_info "Downloading K9s from $K9S_URL"
download_file "$K9S_URL" "$K9S_ARCHIVE"

# Extract archive
log_info "Extracting K9s"
extract_archive "$K9S_ARCHIVE"

# Install binary
install_binary "./k9s" "k9s"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists k9s; then
    INSTALLED_VERSION=$(k9s version --short 2>/dev/null | grep "Version" | awk '{print $2}' || echo "unknown")
    log_success "K9s installed successfully: $INSTALLED_VERSION"
else
    log_error "K9s installation failed"
    exit 1
fi
