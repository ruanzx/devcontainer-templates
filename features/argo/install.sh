#!/bin/bash

# Install Argo Workflows and Argo CD CLIs
# https://github.com/argoproj/argo-workflows
# https://github.com/argoproj/argo-cd

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
INSTALL_ARGOCD="${ARGOCD:-"true"}"
INSTALL_ARGO="${ARGO:-"true"}"

log_info "Installing Argo tools (ArgoCD: $INSTALL_ARGOCD, Argo Workflows: $INSTALL_ARGO)"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Argo features only support Linux"
    exit 1
fi

# Map architecture to Argo naming convention
case "$ARCH" in
    amd64|x86_64)
        ARGO_ARCH="amd64"
        ;;
    arm64|aarch64)
        ARGO_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected platform: linux-$ARGO_ARCH"

# Ensure required packages are installed
update_packages
install_packages curl ca-certificates

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

install_argocd_cli() {
    log_info "Installing Argo CD CLI"
    
    local artifact="argocd-linux-${ARGO_ARCH}"
    local download_url="https://github.com/argoproj/argo-cd/releases/latest/download/$artifact"
    
    log_info "Downloading Argo CD CLI from $download_url"
    download_file "$download_url" "$artifact"
    
    # Install binary
    install_binary "$artifact" "argocd"
    
    log_success "Argo CD CLI installed successfully"
}

install_argo_cli() {
    log_info "Installing Argo Workflows CLI"
    
    local artifact="argo-linux-${ARGO_ARCH}"
    local artifact_gz="${artifact}.gz"
    local download_url="https://github.com/argoproj/argo-workflows/releases/latest/download/$artifact_gz"
    
    log_info "Downloading Argo Workflows CLI from $download_url"
    download_file "$download_url" "$artifact_gz"
    
    # Extract gzipped file
    log_info "Extracting Argo Workflows CLI"
    gunzip "$artifact_gz"
    
    if [[ ! -f "$artifact" ]]; then
        log_error "Failed to extract Argo Workflows CLI"
        exit 1
    fi
    
    # Install binary
    install_binary "$artifact" "argo"
    
    log_success "Argo Workflows CLI installed successfully"
}

# Install requested tools
if [[ "$INSTALL_ARGOCD" == "true" ]]; then
    install_argocd_cli
fi

if [[ "$INSTALL_ARGO" == "true" ]]; then
    install_argo_cli
fi

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installations
if [[ "$INSTALL_ARGOCD" == "true" ]]; then
    if command_exists argocd; then
        ARGOCD_VERSION=$(argocd version --client --short 2>/dev/null || echo "unknown")
        log_success "Argo CD CLI verified: $ARGOCD_VERSION"
    else
        log_error "Argo CD CLI installation failed"
        exit 1
    fi
fi

if [[ "$INSTALL_ARGO" == "true" ]]; then
    if command_exists argo; then
        ARGO_VERSION=$(argo version --short 2>/dev/null || echo "unknown")
        log_success "Argo Workflows CLI verified: $ARGO_VERSION"
    else
        log_error "Argo Workflows CLI installation failed"
        exit 1
    fi
fi

log_success "Argo installation completed successfully"