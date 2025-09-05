#!/bin/bash

# Install act - Run GitHub Actions locally
# https://github.com/nektos/act

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

log_info "Installing act ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "act feature only supports Linux"
    exit 1
fi

# Map architecture to act naming convention
case "$ARCH" in
    amd64|x86_64)
        ACT_ARCH="x86_64"
        ;;
    arm64|aarch64)
        ACT_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: Linux $ACT_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates tar

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/nektos/act/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
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

# Download act
ACT_URL="https://github.com/nektos/act/releases/download/v${VERSION}/act_Linux_${ACT_ARCH}.tar.gz"
ACT_ARCHIVE="act_Linux_${ACT_ARCH}.tar.gz"

log_info "Downloading act from $ACT_URL"
download_file "$ACT_URL" "$ACT_ARCHIVE"

# Extract archive
log_info "Extracting act"
tar -xzf "$ACT_ARCHIVE"

if [[ ! -f "act" ]]; then
    log_error "act binary not found in extracted archive"
    exit 1
fi

# Install binary
install_binary "act" "act"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists act; then
    INSTALLED_VERSION=$(act --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "act installed successfully: $INSTALLED_VERSION"
else
    log_error "act installation failed"
    exit 1
fi