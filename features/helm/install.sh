#!/bin/bash

# Install Helm - The package manager for Kubernetes
# https://helm.sh/docs/intro/install/

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
VERSION="${VERSION:-"3.16.1"}"
INSTALL_DASHBOARD="${INSTALLDASHBOARD:-"true"}"
DASHBOARD_VERSION="${DASHBOARD_VERSION:-"2.0.4"}"

log_info "Installing Helm v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Helm feature currently only supports Linux"
    exit 1
fi

# Map architecture for Helm release naming
case "$ARCH" in
    "amd64") HELM_ARCH="amd64" ;;
    "arm64") HELM_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for Helm: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Helm
HELM_URL="https://get.helm.sh/helm-v${VERSION}-linux-${HELM_ARCH}.tar.gz"
HELM_ARCHIVE="helm.tar.gz"

log_info "Downloading Helm from $HELM_URL"
download_file "$HELM_URL" "$HELM_ARCHIVE"

# Verify the archive with checksum (if available)
HELM_CHECKSUM_URL="https://get.helm.sh/helm-v${VERSION}-linux-${HELM_ARCH}.tar.gz.sha256sum"
HELM_CHECKSUM_FILE="helm.tar.gz.sha256sum"

log_info "Downloading Helm checksum for verification"
if download_file "$HELM_CHECKSUM_URL" "$HELM_CHECKSUM_FILE"; then
    log_info "Verifying Helm archive"
    if sha256sum --check "$HELM_CHECKSUM_FILE" --status 2>/dev/null; then
        log_success "Helm archive verification passed"
    else
        log_warning "Helm archive verification failed, proceeding anyway"
    fi
else
    log_warning "Could not download checksum file, skipping verification"
fi

# Extract archive
log_info "Extracting Helm"
extract_archive "$HELM_ARCHIVE"

# Find the helm binary in the extracted directory
HELM_BINARY="linux-${HELM_ARCH}/helm"
if [[ ! -f "$HELM_BINARY" ]]; then
    log_error "Helm binary not found in expected location: $HELM_BINARY"
    exit 1
fi

# Install binary
install_binary "./$HELM_BINARY" "helm"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists helm; then
    INSTALLED_VERSION=$(helm version --template='{{.Version}}' 2>/dev/null || echo "unknown")
    log_success "Helm installed successfully: $INSTALLED_VERSION"
else
    log_error "Helm installation failed"
    exit 1
fi

if [[ "$INSTALL_DASHBOARD" == "true" ]]; then
    log_info "Installing Helm Dashboard v${DASHBOARD_VERSION}"

    # Map architecture for Helm Dashboard release naming
    case "$ARCH" in
        "amd64") DASHBOARD_ARCH="x86_64" ;;
        "arm64") DASHBOARD_ARCH="arm64" ;;
        *) 
            log_error "Unsupported architecture for Helm Dashboard: $ARCH"
            exit 1
            ;;
    esac

    # Create temporary directory for dashboard
    TEMP_DIR_DASHBOARD=$(mktemp -d)
    cd "$TEMP_DIR_DASHBOARD"

    # Download Helm Dashboard
    VERSION_NO_V="${DASHBOARD_VERSION#v}"
    DASHBOARD_URL="https://github.com/komodorio/helm-dashboard/releases/download/v${DASHBOARD_VERSION}/helm-dashboard_${VERSION_NO_V}_Linux_${DASHBOARD_ARCH}.tar.gz"
    DASHBOARD_ARCHIVE="helm-dashboard.tar.gz"

    log_info "Downloading Helm Dashboard from $DASHBOARD_URL"
    download_file "$DASHBOARD_URL" "$DASHBOARD_ARCHIVE"

    # Extract archive
    log_info "Extracting Helm Dashboard"
    extract_archive "$DASHBOARD_ARCHIVE"

    # Find the helm-dashboard binary
    DASHBOARD_BINARY="helm-dashboard"
    if [[ ! -f "$DASHBOARD_BINARY" ]]; then
        log_error "Helm Dashboard binary not found in expected location: $DASHBOARD_BINARY"
        exit 1
    fi

    # Install binary
    install_binary "./$DASHBOARD_BINARY" "helm-dashboard"

    # Cleanup
    cd /
    cleanup_temp "$TEMP_DIR_DASHBOARD"

    # Verify installation
    if command_exists helm-dashboard; then
        INSTALLED_DASHBOARD_VERSION=$(helm-dashboard --version 2>/dev/null | head -n 1 || echo "unknown")
        log_success "Helm Dashboard installed successfully: $INSTALLED_DASHBOARD_VERSION"
    else
        log_error "Helm Dashboard installation failed"
        exit 1
    fi
fi
