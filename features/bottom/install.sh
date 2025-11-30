#!/bin/bash

# Install bottom
# https://github.com/ClementTsang/bottom

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
VERSION="${VERSION:-"0.11.4"}"

log_info "Installing bottom v${VERSION}"

# Resolve "latest" to actual version if needed
if [[ "$VERSION" == "latest" ]]; then
    VERSION=$(get_latest_github_version "ClementTsang/bottom" "0.11.4" "x86_64-unknown-linux-gnu")
    log_info "Resolved latest version to: $VERSION"
fi

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "bottom feature only supports Linux"
    exit 1
fi

# Map architecture to bottom binary naming
# Format: bottom_<arch>-unknown-linux-<musl|gnu>.tar.gz
BOTTOM_ARCH=""
BOTTOM_LIBC="musl"  # Use musl for better compatibility

case "$ARCH" in
    amd64|x86_64)
        BOTTOM_ARCH="x86_64"
        ;;
    arm64|aarch64)
        BOTTOM_ARCH="aarch64"
        ;;
    armv7l|armhf)
        BOTTOM_ARCH="armv7"
        ;;
    i686)
        BOTTOM_ARCH="i686"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        log_info "Supported architectures: x86_64, aarch64, armv7, i686"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download bottom
# Binary naming format: bottom_<arch>-unknown-linux-musl.tar.gz
BOTTOM_URL="https://github.com/ClementTsang/bottom/releases/download/${VERSION}/bottom_${BOTTOM_ARCH}-unknown-linux-${BOTTOM_LIBC}.tar.gz"
BOTTOM_ARCHIVE="bottom.tar.gz"

log_info "Downloading bottom from $BOTTOM_URL"
download_file "$BOTTOM_URL" "$BOTTOM_ARCHIVE"

# Ensure tar and gzip are available
ensure_command "tar"
ensure_command "gzip"

# Extract archive
log_info "Extracting bottom"
tar -xzf "$BOTTOM_ARCHIVE"

# The archive extracts the btm binary directly
if [[ -f "btm" ]]; then
    install_binary "btm" "btm"
else
    log_error "btm binary not found in archive"
    exit 1
fi

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists btm; then
    INSTALLED_VERSION=$(btm --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "bottom installed successfully: $INSTALLED_VERSION"
    log_info "Run 'btm' to start bottom"
else
    log_error "bottom installation failed"
    exit 1
fi
