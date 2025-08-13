#!/bin/bash

# Install yq - YAML/JSON/XML processor
# https://github.com/mikefarah/yq

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
VERSION="${VERSION:-"4.44.3"}"

log_info "Installing yq v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "yq feature currently only supports Linux"
    exit 1
fi

# Map architecture for yq release naming
case "$ARCH" in
    "amd64") YQ_ARCH="amd64" ;;
    "arm64") YQ_ARCH="arm64" ;;
    "arm") YQ_ARCH="arm" ;;
    *) 
        log_error "Unsupported architecture for yq: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download yq
YQ_BINARY="yq_linux_${YQ_ARCH}"
YQ_URL="https://github.com/mikefarah/yq/releases/download/v${VERSION}/${YQ_BINARY}.tar.gz"
YQ_ARCHIVE="yq.tar.gz"

log_info "Downloading yq from $YQ_URL"
download_file "$YQ_URL" "$YQ_ARCHIVE"

# Extract archive
log_info "Extracting yq"
extract_archive "$YQ_ARCHIVE"

# Install binary
install_binary "./${YQ_BINARY}" "yq"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists yq; then
    INSTALLED_VERSION=$(yq --version 2>/dev/null | awk '{print $NF}' || echo "unknown")
    log_success "yq installed successfully: $INSTALLED_VERSION"
else
    log_error "yq installation failed"
    exit 1
fi
