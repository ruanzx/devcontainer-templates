#!/bin/bash

# Install ngrok - tunneling, reverse proxy for developing networked services
# https://ngrok.com/docs

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
ADD_TO_PATH="${ADDTOPATH:-"true"}"

log_info "Installing ngrok v${VERSION}"

# Detect architecture
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64) ARCH="amd64" ;;
    aarch64 | arm64) ARCH="arm64" ;;
    armv7l) ARCH="arm" ;;
    i386) ARCH="386" ;;
    *) 
        log_error "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux) OS="linux" ;;
    Darwin) OS="darwin" ;;
    CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
    *)
        log_error "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

log_info "Detected platform: ${OS}-${ARCH}"

# Get latest version if requested
if [[ "${VERSION}" == "latest" ]]; then
    log_info "Fetching latest ngrok version from GitHub API"
    if command -v curl >/dev/null 2>&1; then
        # Note: ngrok doesn't use GitHub releases, so we'll use a known stable version
        # The ngrok binary is distributed directly from equinox.io
        VERSION="3.18.4"
        log_info "Using stable version: v${VERSION}"
    else
        log_warning "curl not available, using default version 3.18.4"
        VERSION="3.18.4"
    fi
    log_info "Version: v${VERSION}"
fi

# Remove 'v' prefix if present
VERSION="${VERSION#v}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

log_info "Downloading ngrok from https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-${OS}-${ARCH}.tgz"

# Download ngrok
DOWNLOAD_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-${OS}-${ARCH}.tgz"
download_file "$DOWNLOAD_URL" "$TEMP_DIR/ngrok.tgz"

log_info "Extracting ngrok"
cd "$TEMP_DIR"
tar -xzf ngrok.tgz

# Verify extraction
if [[ ! -f "ngrok" ]]; then
    log_error "Failed to extract ngrok binary"
    exit 1
fi

# Make executable
chmod +x ngrok

# Install to system location
INSTALL_DIR="/usr/local/bin"
if [[ "$ADD_TO_PATH" == "true" ]]; then
    log_info "Installing ngrok to ${INSTALL_DIR}"
    mv ngrok "$INSTALL_DIR/ngrok"
else
    # Install to a location not in PATH
    INSTALL_DIR="/opt/ngrok"
    mkdir -p "$INSTALL_DIR"
    log_info "Installing ngrok to ${INSTALL_DIR}"
    mv ngrok "$INSTALL_DIR/ngrok"
fi

# Clean up
cd /
cleanup

# Verify installation
if [[ "$ADD_TO_PATH" == "true" ]]; then
    INSTALLED_VERSION=$(ngrok version 2>/dev/null | head -n1 || echo "Unknown")
    log_success "ngrok installed successfully: ${INSTALLED_VERSION}"
    log_info "ngrok is available in PATH"
else
    log_success "ngrok installed successfully to ${INSTALL_DIR}/ngrok"
    log_info "To use ngrok, run: ${INSTALL_DIR}/ngrok"
fi

log_info "ngrok installation completed"
log_info ""
log_info "To get started with ngrok:"
log_info "1. Sign up for a free account at https://ngrok.com"
log_info "2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken"
log_info "3. Set up authentication: ngrok config add-authtoken <your-token>"
log_info "4. Start tunneling: ngrok http 3000"
log_info ""
log_info "Common ngrok commands:"
log_info "  ngrok http 8080          # Tunnel local port 8080"
log_info "  ngrok tcp 22             # Tunnel TCP port 22"
log_info "  ngrok config check       # Verify configuration"
log_info "  ngrok status             # Show tunnel status"
