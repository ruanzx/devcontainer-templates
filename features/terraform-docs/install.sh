#!/bin/bash

# Install terraform-docs - Generate documentation from Terraform modules
# https://terraform-docs.io/

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

log_info "Installing terraform-docs v${VERSION}"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "terraform-docs feature currently only supports Linux"
    exit 1
fi

# Map architecture for terraform-docs release naming
case "$ARCH" in
    "amd64") TERRAFORM_DOCS_ARCH="amd64" ;;
    "arm64") TERRAFORM_DOCS_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for terraform-docs: $ARCH"
        exit 1
        ;;
esac

# Function to get latest version
get_latest_version() {
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$latest_version" ]]; then
        log_error "Failed to fetch latest version, using fallback"
        echo "v0.19.0"
    else
        echo "$latest_version"
    fi
}

# Determine version to install
if [[ "$VERSION" == "latest" ]]; then
    log_info "Fetching latest terraform-docs version from GitHub API"
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
    log_info "Expected format: v0.19.0 or 0.19.0"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download terraform-docs
TERRAFORM_DOCS_URL="https://github.com/terraform-docs/terraform-docs/releases/download/${INSTALL_VERSION}/terraform-docs-${INSTALL_VERSION}-linux-${TERRAFORM_DOCS_ARCH}.tar.gz"
TERRAFORM_DOCS_ARCHIVE="terraform-docs.tar.gz"

log_info "Downloading terraform-docs from $TERRAFORM_DOCS_URL"
download_file "$TERRAFORM_DOCS_URL" "$TERRAFORM_DOCS_ARCHIVE"

# Extract archive
log_info "Extracting terraform-docs"
tar -xzf "$TERRAFORM_DOCS_ARCHIVE"

# Install binary
log_info "Installing terraform-docs binary"
install_binary "./terraform-docs" "terraform-docs"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists terraform-docs; then
    INSTALLED_VERSION=$(terraform-docs version 2>/dev/null | head -n1 || echo "unknown")
    log_success "terraform-docs installed successfully: $INSTALLED_VERSION"
else
    log_error "terraform-docs installation failed"
    exit 1
fi

log_info "terraform-docs installation completed"
log_info "You can now use terraform-docs to generate documentation!"
log_info "Example: terraform-docs markdown table ."
