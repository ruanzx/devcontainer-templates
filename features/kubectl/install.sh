#!/bin/bash

# Install kubectl - Kubernetes command-line tool
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

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
VERSION="${VERSION:-"1.31.0"}"

log_info "Installing kubectl v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "kubectl feature currently only supports Linux"
    exit 1
fi

# Map architecture for kubectl release naming
case "$ARCH" in
    "amd64") KUBECTL_ARCH="amd64" ;;
    "arm64") KUBECTL_ARCH="arm64" ;;
    *) 
        log_error "Unsupported architecture for kubectl: $ARCH"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download kubectl
KUBECTL_URL="https://dl.k8s.io/release/v${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"
KUBECTL_BINARY="kubectl"

log_info "Downloading kubectl from $KUBECTL_URL"
download_file "$KUBECTL_URL" "$KUBECTL_BINARY"

# Verify the binary (optional but recommended for security)
KUBECTL_CHECKSUM_URL="https://dl.k8s.io/release/v${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl.sha256"
KUBECTL_CHECKSUM_FILE="kubectl.sha256"

log_info "Downloading kubectl checksum for verification"
if download_file "$KUBECTL_CHECKSUM_URL" "$KUBECTL_CHECKSUM_FILE"; then
    log_info "Verifying kubectl binary"
    if echo "$(cat $KUBECTL_CHECKSUM_FILE)  $KUBECTL_BINARY" | sha256sum --check --status; then
        log_success "kubectl binary verification passed"
    else
        log_error "kubectl binary verification failed"
        exit 1
    fi
else
    log_warning "Could not download checksum file, skipping verification"
fi

# Install binary
install_binary "./$KUBECTL_BINARY" "kubectl"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists kubectl; then
    INSTALLED_VERSION=$(kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | cut -d'"' -f4 || echo "unknown")
    log_success "kubectl installed successfully: $INSTALLED_VERSION"
else
    log_error "kubectl installation failed"
    exit 1
fi
