#!/bin/bash

# Install Microsoft Edit
# https://github.com/microsoft/edit

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/utils.sh"

# Parse options
VERSION="${VERSION:-"1.2.0"}"

log_info "Installing Microsoft Edit v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Microsoft Edit feature only supports Linux"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Microsoft Edit
EDIT_URL="https://github.com/microsoft/edit/releases/download/v${VERSION}/edit-${VERSION}-x86_64-linux-gnu.tar.zst"
EDIT_ARCHIVE="edit.tar.zst"

log_info "Downloading Microsoft Edit from $EDIT_URL"
download_file "$EDIT_URL" "$EDIT_ARCHIVE"

# Ensure required tools are available
ensure_command "unzstd"

# Extract archive
log_info "Extracting Microsoft Edit"
unzstd "$EDIT_ARCHIVE"
tar -xf "edit.tar"

# Install binary
install_binary "./edit" "edit"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists edit; then
    INSTALLED_VERSION=$(edit --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Microsoft Edit installed successfully: $INSTALLED_VERSION"
else
    log_error "Microsoft Edit installation failed"
    exit 1
fi
