#!/bin/bash

# Install Azure Functions Core Tools
# https://github.com/Azure/azure-functions-core-tools

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
INSTALL_METHOD="${INSTALLMETHOD:-"apt"}"

log_info "Installing Azure Functions Core Tools v${VERSION} using ${INSTALL_METHOD} method"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Azure Functions Core Tools feature only supports Linux"
    exit 1
fi

# Function to install via APT
install_via_apt() {
    log_info "Installing Azure Functions Core Tools via APT repository"
    
    # Update packages first
    update_packages
    
    # Install required packages for repository setup
    install_packages curl gnupg lsb-release
    
    # Install Microsoft package repository GPG key
    log_info "Setting up Microsoft package repository"
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
    mv /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    
    # Detect distribution and setup APT source
    if command_exists lsb_release; then
        DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
        CODENAME=$(lsb_release -cs)
        
        if [[ "$DISTRO" == "ubuntu" ]]; then
            echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-${CODENAME}-prod ${CODENAME} main" > /etc/apt/sources.list.d/dotnetdev.list
        elif [[ "$DISTRO" == "debian" ]]; then
            VERSION_ID=$(lsb_release -rs | cut -d'.' -f 1)
            echo "deb [arch=amd64] https://packages.microsoft.com/debian/${VERSION_ID}/prod ${CODENAME} main" > /etc/apt/sources.list.d/dotnetdev.list
        else
            log_warning "Unsupported distribution for APT method: $DISTRO. Falling back to binary installation."
            install_via_binary
            return
        fi
    else
        log_warning "Cannot detect distribution. Falling back to binary installation."
        install_via_binary
        return
    fi
    
    # Update package cache
    update_packages
    
    # Install Azure Functions Core Tools
    if [ "${VERSION}" = "latest" ]; then
        install_packages azure-functions-core-tools-4
    else
        # For specific versions, still install latest as APT doesn't support specific versions
        log_warning "APT installation doesn't support specific versions. Installing latest."
        install_packages azure-functions-core-tools-4
    fi
}

# Function to install via binary download
install_via_binary() {
    log_info "Installing Azure Functions Core Tools via binary download"
    
    # Map architecture for binary download
    FUNC_ARCH="x64"
    if [[ "$ARCH" == "arm64" ]]; then
        FUNC_ARCH="arm64"
        log_warning "ARM64 support is limited to certain versions"
    fi
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Determine download URL
    if [ "${VERSION}" = "latest" ]; then
        # Get latest release version from GitHub API
        log_info "Fetching latest release information"
        LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/Azure/azure-functions-core-tools/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        if [[ -z "$LATEST_VERSION" ]]; then
            log_error "Failed to fetch latest version information"
            exit 1
        fi
        VERSION="$LATEST_VERSION"
        log_info "Latest version detected: $VERSION"
    fi
    
    # Construct download URL
    FUNC_URL="https://github.com/Azure/azure-functions-core-tools/releases/download/${VERSION}/Azure.Functions.Cli.linux-${FUNC_ARCH}.${VERSION}.zip"
    FUNC_ARCHIVE="azure-functions-cli.zip"
    
    log_info "Downloading Azure Functions Core Tools from $FUNC_URL"
    download_file "$FUNC_URL" "$FUNC_ARCHIVE"
    
    # Ensure required tools are available
    install_packages unzip
    
    # Extract archive
    log_info "Extracting Azure Functions Core Tools"
    unzip -q "$FUNC_ARCHIVE" -d azure-functions-cli
    
    # Create installation directory
    INSTALL_DIR="/usr/local/share/azure-functions-core-tools"
    mkdir -p "$INSTALL_DIR"
    
    # Copy all files to installation directory
    log_info "Installing Azure Functions Core Tools to $INSTALL_DIR"
    cp -r azure-functions-cli/* "$INSTALL_DIR/"
    
    # Make binaries executable
    chmod +x "$INSTALL_DIR/func"
    chmod +x "$INSTALL_DIR/gozip"
    
    # Create symlink in PATH
    ln -sf "$INSTALL_DIR/func" "/usr/local/bin/func"
    
    # Cleanup
    cd /
    cleanup_temp "$TEMP_DIR"
}

# Choose installation method
case "$INSTALL_METHOD" in
    "apt")
        install_via_apt
        ;;
    "binary")
        install_via_binary
        ;;
    *)
        log_error "Invalid installation method: $INSTALL_METHOD. Use 'apt' or 'binary'."
        exit 1
        ;;
esac

# Verify installation
if command_exists func; then
    INSTALLED_VERSION=$(func --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Azure Functions Core Tools installed successfully: $INSTALLED_VERSION"
else
    log_error "Azure Functions Core Tools installation failed"
    exit 1
fi

log_info "Azure Functions Core Tools installation complete!"
log_info "Use 'func --help' to get started"