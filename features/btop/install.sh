#!/bin/bash

# Install btop++
# https://github.com/aristocratos/btop

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
VERSION="${VERSION:-"1.4.5"}"

log_info "Installing btop++ v${VERSION}"

# Resolve "latest" to actual version if needed
if [[ "$VERSION" == "latest" ]]; then
    VERSION=$(get_latest_github_version "aristocratos/btop" "1.4.5" "x86_64-linux-musl")
    log_info "Resolved latest version to: $VERSION"
fi

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "btop++ feature only supports Linux"
    exit 1
fi

# Map architecture to btop binary naming
BTOP_ARCH=""
case "$ARCH" in
    amd64|x86_64)
        BTOP_ARCH="x86_64"
        ;;
    arm64|aarch64)
        BTOP_ARCH="aarch64"
        ;;
    armv7l)
        BTOP_ARCH="armv7l"
        ;;
    i686)
        BTOP_ARCH="i686"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        log_info "Supported architectures: x86_64, aarch64, armv7l, i686"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download btop++
# Binary naming format: btop-<arch>-linux-musl.tbz
BTOP_URL="https://github.com/aristocratos/btop/releases/download/v${VERSION}/btop-${BTOP_ARCH}-linux-musl.tbz"
BTOP_ARCHIVE="btop.tbz"

log_info "Downloading btop++ from $BTOP_URL"
download_file "$BTOP_URL" "$BTOP_ARCHIVE"

# Ensure tar and bzip2 are available
ensure_command "tar"
ensure_command "bzip2"

# Extract archive
log_info "Extracting btop++"
tar -xjf "$BTOP_ARCHIVE"

# The archive extracts to btop/ directory
if [[ -d "btop" ]]; then
    cd btop
    
    # Install binary
    if [[ -f "bin/btop" ]]; then
        install_binary "bin/btop" "btop"
    else
        log_error "btop binary not found in archive"
        exit 1
    fi
    
    # Install themes (optional)
    if [[ -d "themes" ]]; then
        THEMES_DIR="/usr/local/share/btop/themes"
        log_info "Installing btop++ themes to $THEMES_DIR"
        run_with_privileges mkdir -p "$THEMES_DIR"
        run_with_privileges cp -r themes/* "$THEMES_DIR/"
    fi
else
    log_error "Expected btop directory not found in archive"
    exit 1
fi

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists btop; then
    INSTALLED_VERSION=$(btop --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "btop++ installed successfully: $INSTALLED_VERSION"
else
    log_error "btop++ installation failed"
    exit 1
fi
