#!/bin/bash

# Install Google Cloud CLI - Command-line tools for Google Cloud Platform
# https://cloud.google.com/sdk/gcloud

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
INSTALL_GKE_PLUGIN="${INSTALLGKEGCLOUDAUTHPLUGIN:-"false"}"

log_info "Installing Google Cloud CLI ${VERSION}"

# Detect system architecture and OS
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Google Cloud CLI feature only supports Linux"
    exit 1
fi

# Check if running as root
if [[ $(id -u) -ne 0 ]]; then
    log_error "Script must be run as root. Use sudo, su, or add 'USER root' to your Dockerfile"
    exit 1
fi

log_info "Detected platform: linux-$ARCH"

# Update package cache and install dependencies
export DEBIAN_FRONTEND=noninteractive
update_packages
install_packages apt-transport-https curl ca-certificates gnupg2 python3 lsb-release

# Add Google Cloud repository
log_info "Adding Google Cloud repository"

# Import Google Cloud public key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add Google Cloud CLI repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list

# Update package cache with new repository
log_info "Updating package cache with Google Cloud repository"
update_packages

# Install Google Cloud CLI
log_info "Installing Google Cloud CLI"

if [[ "$VERSION" == "latest" ]]; then
    log_info "Installing latest version from repository"
    install_packages google-cloud-cli
else
    log_info "Installing specific version: $VERSION"
    # Try to find version in apt cache
    if apt-cache madison google-cloud-cli | grep -q "$VERSION"; then
        install_packages "google-cloud-cli=$VERSION"
    else
        log_warning "Specific version $VERSION not found in repository, installing latest"
        install_packages google-cloud-cli
    fi
fi

# Install GKE authentication plugin if requested
if [[ "$INSTALL_GKE_PLUGIN" == "true" ]]; then
    log_info "Installing GKE gcloud auth plugin"
    install_packages google-cloud-sdk-gke-gcloud-auth-plugin
fi

# Clean up package cache
apt-get clean
rm -rf /var/lib/apt/lists/*

# Verify installation
if command_exists gcloud; then
    INSTALLED_VERSION=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null || echo "unknown")
    log_success "Google Cloud CLI installed successfully: $INSTALLED_VERSION"
    
    # Show installed components
    log_info "Installed components:"
    gcloud components list --only-local-state --format="table(id,name,version)" 2>/dev/null || true
else
    log_error "Google Cloud CLI installation failed"
    exit 1
fi