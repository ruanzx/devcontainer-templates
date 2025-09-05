#!/bin/bash

# Install aztfexport (formerly aztfy) - A tool to bring existing Azure resources under Terraform's management
# https://github.com/Azure/aztfexport

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

log_info "Installing aztfexport v${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "aztfexport feature only supports Linux"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Determine the latest version if needed
if [[ "$VERSION" == "latest" ]]; then
    log_info "Fetching latest aztfexport version from GitHub API"
    
    # Get latest version from GitHub API
    VERSION=$(curl -s "https://api.github.com/repos/Azure/aztfexport/releases/latest" | \
              grep '"tag_name":' | \
              sed -E 's/.*"tag_name": "([^"]+)".*/\1/' || echo "")
    
    if [[ -z "$VERSION" ]]; then
        log_error "Failed to fetch latest version from GitHub API"
        exit 1
    fi
    
    log_info "Latest version: $VERSION"
fi

# Validate version only if it's not "latest" and after resolution
if [[ "$VERSION" != "latest" ]]; then
    # Remove 'v' prefix for validation
    VERSION_FOR_VALIDATION="${VERSION#v}"
    validate_version "$VERSION_FOR_VALIDATION"
fi

# Download aztfexport (the repository and binary name is aztfexport)
AZTFEXPORT_URL="https://github.com/Azure/aztfexport/releases/download/${VERSION}/aztfexport_${VERSION}_linux_${ARCH}.zip"
AZTFEXPORT_ARCHIVE="aztfexport.zip"

log_info "Downloading aztfexport from $AZTFEXPORT_URL"
download_file "$AZTFEXPORT_URL" "$AZTFEXPORT_ARCHIVE"

# Ensure required tools are available
ensure_command "unzip"

# Extract archive
log_info "Extracting aztfexport"
unzip -q "$AZTFEXPORT_ARCHIVE"

# Install binary as both aztfexport and aztfy for compatibility
install_binary "./aztfexport" "aztfexport"

# Create a symlink for backward compatibility with the old name
ln -sf /usr/local/bin/aztfexport /usr/local/bin/aztfy

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists aztfexport; then
    # Try different methods to get version
    INSTALLED_VERSION=$(aztfexport --version 2>/dev/null | head -n1 || \
                       aztfexport version 2>/dev/null | head -n1 || \
                       echo "version unknown")
    log_success "aztfexport installed successfully: $INSTALLED_VERSION"
    log_info "Also available as 'aztfy' for backward compatibility"
else
    log_error "aztfexport installation failed"
    exit 1
fi