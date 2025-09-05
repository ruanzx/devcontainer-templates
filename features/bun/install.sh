#!/bin/bash

# Install Bun - A fast all-in-one JavaScript runtime
# https://github.com/oven-sh/bun

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

log_info "Installing Bun ${VERSION}"

# Detect system architecture and OS
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Bun feature only supports Linux"
    exit 1
fi

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates unzip

# Determine target platform
case "$ARCH" in
    amd64|x86_64)
        if grep -q avx2 /proc/cpuinfo 2>/dev/null; then
            target="linux-x64"
        else
            target="linux-x64-baseline"
        fi
        ;;
    arm64|aarch64)
        target="linux-aarch64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: $target"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Determine download URL
GITHUB_REPO="https://github.com/oven-sh/bun"
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/oven-sh/bun/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to get latest version from GitHub API"
        exit 1
    fi
    VERSION="$LATEST_VERSION"
    log_info "Latest version resolved to: $VERSION"
    BUN_URL="${GITHUB_REPO}/releases/latest/download/bun-${target}.zip"
else
    BUN_URL="${GITHUB_REPO}/releases/download/${VERSION}/bun-${target}.zip"
fi

BUN_ARCHIVE="bun-${target}.zip"

log_info "Downloading Bun from $BUN_URL"
download_file "$BUN_URL" "$BUN_ARCHIVE"

# Extract archive
log_info "Extracting Bun"
unzip -q "$BUN_ARCHIVE"

# Install binary
BUN_EXTRACTED_DIR="bun-${target}"
if [[ -f "${BUN_EXTRACTED_DIR}/bun" ]]; then
    install_binary "${BUN_EXTRACTED_DIR}/bun" "bun"
else
    log_error "Bun binary not found in extracted archive"
    exit 1
fi

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists bun; then
    INSTALLED_VERSION=$(bun --version 2>/dev/null || echo "unknown")
    log_success "Bun installed successfully: $INSTALLED_VERSION"
    
    # Install completions (optional, non-critical)
    log_info "Installing shell completions"
    IS_BUN_AUTO_UPDATE=true bun completions >/dev/null 2>&1 || log_warning "Failed to install completions (non-critical)"
else
    log_error "Bun installation failed"
    exit 1
fi