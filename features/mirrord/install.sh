#!/bin/bash

# Install mirrord - tool for testing in cloud environments locally
# https://github.com/metalbear-co/mirrord

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

# Verify checksum function
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    
    if [[ -z "$file" || -z "$expected_checksum" ]]; then
        log_error "verify_checksum: file and checksum parameters required"
        return 1
    fi
    
    log_info "Verifying checksum for $file"
    local actual_checksum
    actual_checksum=$(sha256sum "$file" | cut -d' ' -f1)
    
    if [[ "$actual_checksum" == "$expected_checksum" ]]; then
        log_success "Checksum verification passed"
        return 0
    else
        log_error "Checksum verification failed!"
        log_error "Expected: $expected_checksum"
        log_error "Actual:   $actual_checksum"
        return 1
    fi
}

# Parse options
VERSION="${VERSION:-"latest"}"
SHA256="${SHA256:-"automatic"}"

log_info "Installing mirrord ${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "mirrord feature only supports Linux"
    exit 1
fi

# Map architecture to mirrord naming convention
case "$ARCH" in
    "amd64") MIRRORD_ARCH="x86_64" ;;
    "arm64") MIRRORD_ARCH="aarch64" ;;
    *) 
        log_error "Unsupported architecture: $ARCH. mirrord supports x86_64 and aarch64"
        exit 1
        ;;
esac

# Resolve version
if [[ "$VERSION" == "latest" ]]; then
    log_info "Resolving latest mirrord version..."
    VERSION=$(curl -s "https://api.github.com/repos/metalbear-co/mirrord/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z "$VERSION" ]]; then
        log_error "Failed to resolve latest version"
        exit 1
    fi
    log_info "Latest version resolved to: $VERSION"
fi

# Validate version format
validate_version "$VERSION"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Construct download URLs
BASE_URL="https://github.com/metalbear-co/mirrord/releases/download/${VERSION}"
BINARY_URL="${BASE_URL}/mirrord_linux_${MIRRORD_ARCH}.zip"
CHECKSUM_URL="${BASE_URL}/mirrord_linux_${MIRRORD_ARCH}.shasum256"
BINARY_FILE="mirrord.zip"

log_info "Downloading mirrord from $BINARY_URL"

# Download binary
if ! download_file "$BINARY_URL" "$BINARY_FILE"; then
    log_error "Failed to download mirrord binary"
    cleanup_temp "$TEMP_DIR"
    exit 1
fi

# Handle checksum verification
if [[ "$SHA256" == "automatic" ]]; then
    log_info "Downloading checksum from $CHECKSUM_URL"
    if download_file "$CHECKSUM_URL" "mirrord.shasum256"; then
        # Extract just the checksum part (first field before any space)
        EXPECTED_CHECKSUM=$(head -n1 mirrord.shasum256 | cut -d' ' -f1 | tr -d '\n\r')
        if [[ -n "$EXPECTED_CHECKSUM" && ${#EXPECTED_CHECKSUM} -eq 64 ]]; then
            verify_checksum "$BINARY_FILE" "$EXPECTED_CHECKSUM"
        else
            log_warning "Could not extract valid checksum from downloaded file, skipping verification"
        fi
    else
        log_warning "Could not download checksum file, skipping verification"
    fi
elif [[ "$SHA256" != "dev-mode" ]]; then
    verify_checksum "$BINARY_FILE" "$SHA256"
fi

# Extract the ZIP file
log_info "Extracting mirrord"
unzip -q "$BINARY_FILE"

# Extract the ZIP file
log_info "Extracting mirrord"
unzip -q "$BINARY_FILE"

# Make binary executable
chmod +x mirrord

# Install binary
install_binary "./mirrord" "mirrord"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists mirrord; then
    INSTALLED_VERSION=$(mirrord --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "mirrord installed successfully: $INSTALLED_VERSION"
else
    log_error "mirrord installation failed"
    exit 1
fi