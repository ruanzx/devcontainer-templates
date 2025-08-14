#!/bin/bash

# Install k6 - Modern load testing tool
# https://k6.io/

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

log_info "Installing k6 v${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "k6 feature currently only supports Linux"
    exit 1
fi

# Map architecture for k6 release naming
case "$ARCH" in
    "amd64") K6_ARCH="amd64" ;;
    "arm64") K6_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for k6: $ARCH"
        exit 1
        ;;
esac

# Function to get latest version
get_latest_version() {
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/grafana/k6/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$latest_version" ]]; then
        log_error "Failed to fetch latest version, using fallback"
        echo "v0.54.0"
    else
        echo "$latest_version"
    fi
}

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Fetching latest k6 version from GitHub API"
    INSTALL_VERSION=$(get_latest_version)
    log_info "Latest version: $INSTALL_VERSION"
else
    INSTALL_VERSION="$VERSION"
    # Add 'v' prefix if not present
    if [[ ! "$INSTALL_VERSION" =~ ^v ]]; then
        INSTALL_VERSION="v$INSTALL_VERSION"
    fi
fi

# Validate version format
if [[ ! "$INSTALL_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    log_error "Invalid version format: $INSTALL_VERSION"
    log_info "Expected format: v0.54.0 or 0.54.0"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download k6
K6_URL="https://github.com/grafana/k6/releases/download/${INSTALL_VERSION}/k6-${INSTALL_VERSION}-linux-${K6_ARCH}.tar.gz"
K6_ARCHIVE="k6.tar.gz"

log_info "Downloading k6 from $K6_URL"
download_file "$K6_URL" "$K6_ARCHIVE"

# Extract archive
log_info "Extracting k6"
tar -xzf "$K6_ARCHIVE"

# Find the extracted directory (should be k6-{version}-linux-{arch})
K6_DIR=$(find . -name "k6-${INSTALL_VERSION}-linux-${K6_ARCH}" -type d | head -n1)
if [[ -z "$K6_DIR" ]]; then
    log_error "Could not find extracted k6 directory"
    exit 1
fi

# Install binary
log_info "Installing k6 binary"
install_binary "$K6_DIR/k6" "k6"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists k6; then
    INSTALLED_VERSION=$(k6 version --quiet 2>/dev/null || k6 version 2>/dev/null | head -n1 || echo "unknown")
    log_success "k6 installed successfully: $INSTALLED_VERSION"
else
    log_error "k6 installation failed"
    exit 1
fi

log_info "k6 installation completed"
log_info "You can now use k6 for load testing!"
log_info "Example: k6 run script.js"
    exit 1
fi

# Install K9s - Kubernetes CLI
# https://k9scli.io/

set -e

# Source common utilities

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
