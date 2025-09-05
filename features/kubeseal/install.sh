#!/bin/bash

# Install kubeseal - Client-side utility for Kubernetes Sealed Secrets
# https://github.com/bitnami-labs/sealed-secrets

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
SHA256="${SHA256:-"automatic"}"

log_info "Installing kubeseal ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "kubeseal feature only supports Linux"
    exit 1
fi

# Map architecture to kubeseal naming convention
case "$ARCH" in
    amd64|x86_64)
        KUBESEAL_ARCH="amd64"
        ;;
    arm64|aarch64)
        KUBESEAL_ARCH="arm64"
        ;;
    arm|armv7*)
        KUBESEAL_ARCH="arm"
        ;;
    386|i?86)
        KUBESEAL_ARCH="386"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: linux-$KUBESEAL_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates coreutils

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest version from GitHub API"
    # Get latest version from GitHub API
    LATEST_VERSION=$(curl -sf "https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to get latest version from GitHub API"
        exit 1
    fi
    VERSION="$LATEST_VERSION"
    log_info "Latest version resolved to: $VERSION"
fi

# Normalize version (remove 'v' prefix if present for file names)
VERSION_NUMBER="${VERSION#v}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download kubeseal tarball
KUBESEAL_URL="https://github.com/bitnami-labs/sealed-secrets/releases/download/${VERSION}/kubeseal-${VERSION_NUMBER}-linux-${KUBESEAL_ARCH}.tar.gz"
KUBESEAL_TARBALL="kubeseal-${VERSION_NUMBER}-linux-${KUBESEAL_ARCH}.tar.gz"

log_info "Downloading kubeseal from $KUBESEAL_URL"
download_file "$KUBESEAL_URL" "$KUBESEAL_TARBALL"

if [[ ! -f "$KUBESEAL_TARBALL" ]]; then
    log_error "kubeseal tarball not found after download"
    exit 1
fi

# Verify checksum if requested
if [[ "$SHA256" == "automatic" ]]; then
    log_info "Downloading and verifying checksums"
    CHECKSUMS_URL="https://github.com/bitnami-labs/sealed-secrets/releases/download/${VERSION}/sealed-secrets_${VERSION_NUMBER}_checksums.txt"
    
    if curl -sf "$CHECKSUMS_URL" -o checksums.txt; then
        EXPECTED_SHA256=$(grep "$KUBESEAL_TARBALL" checksums.txt | cut -f1 -d' ')
        if [[ -n "$EXPECTED_SHA256" ]]; then
            log_info "Verifying SHA256 checksum: $EXPECTED_SHA256"
            echo "${EXPECTED_SHA256} ${KUBESEAL_TARBALL}" | sha256sum -c -
            log_info "Checksum verification passed"
        else
            log_warning "Could not find checksum for $KUBESEAL_TARBALL in checksums file"
        fi
    else
        log_warning "Could not download checksums file, skipping verification"
    fi
elif [[ "$SHA256" != "dev-mode" && -n "$SHA256" ]]; then
    log_info "Verifying provided SHA256 checksum: $SHA256"
    echo "${SHA256} ${KUBESEAL_TARBALL}" | sha256sum -c -
    log_info "Checksum verification passed"
fi

# Extract and install
log_info "Extracting kubeseal binary"
tar -xf "$KUBESEAL_TARBALL"

if [[ ! -f "kubeseal" ]]; then
    log_error "kubeseal binary not found in tarball"
    exit 1
fi

# Install binary
install_binary "kubeseal" "kubeseal"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists kubeseal; then
    INSTALLED_VERSION=$(kubeseal --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "kubeseal installed successfully: $INSTALLED_VERSION"
else
    log_error "kubeseal installation failed"
    exit 1
fi