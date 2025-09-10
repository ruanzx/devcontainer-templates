#!/bin/bash

# Install Headlamp Kubernetes UI
# https://headlamp.dev/

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
VERSION="${VERSION:-"0.35.0"}"

log_info "Installing Headlamp v${VERSION}"

# Validate version
validate_version "$VERSION"

# Detect system architecture
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$OS" != "linux" ]]; then
    log_error "Headlamp feature only supports Linux"
    exit 1
fi

# Map architecture names for Headlamp downloads
case "$ARCH" in
    "amd64") HEADLAMP_ARCH="x64" ;;
    "arm64") HEADLAMP_ARCH="arm64" ;;
    "armv7") HEADLAMP_ARCH="armv7l" ;;
    *) 
        log_error "Unsupported architecture: $ARCH"
        log_info "Supported architectures: amd64, arm64, armv7"
        exit 1
        ;;
esac

# Install required dependencies
log_info "Installing system dependencies..."
apt-get update && apt-get install -y \
    curl \
    libgtk-3-0t64 \
    libnss3 \
    libasound2t64 \
    xdg-utils

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Headlamp
HEADLAMP_URL="https://github.com/headlamp-k8s/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-${HEADLAMP_ARCH}.tar.gz"
HEADLAMP_ARCHIVE="headlamp.tar.gz"

log_info "Downloading Headlamp from $HEADLAMP_URL"
download_file "$HEADLAMP_URL" "$HEADLAMP_ARCHIVE"

# Extract archive
log_info "Extracting Headlamp"
tar -xzf "$HEADLAMP_ARCHIVE"

# Install Headlamp
INSTALL_DIR="/usr/local/headlamp"
log_info "Installing Headlamp to $INSTALL_DIR"

# Remove existing installation if present
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
fi

# Move extracted files to installation directory
mv "Headlamp-${VERSION}-linux-${HEADLAMP_ARCH}" "$INSTALL_DIR"

# Make binary executable
chmod +x "$INSTALL_DIR/headlamp"

# Create symlink in /usr/local/bin for global access
ln -sf "$INSTALL_DIR/headlamp" "/usr/local/bin/headlamp"

# Cleanup
cd /
cleanup_temp "$TEMP_DIR"

# Verify installation
if command_exists headlamp; then
    INSTALLED_VERSION=$(headlamp --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "v${VERSION}")
    log_success "Headlamp installed successfully: $INSTALLED_VERSION"
else
    log_error "Headlamp installation failed"
    exit 1
fi

# Create verification script
VERIFY_SCRIPT="/usr/local/bin/verify-headlamp"
cat > "$VERIFY_SCRIPT" << 'EOF'
#!/bin/bash
echo "🔍 Verifying Headlamp installation..."

# Check if headlamp command exists
if ! command -v headlamp >/dev/null 2>&1; then
    echo "❌ Headlamp command not found"
    exit 1
fi

echo "✅ Headlamp command found: $(which headlamp)"

# Get version
VERSION_OUTPUT=$(headlamp --version 2>/dev/null || echo "version check failed")
echo "✅ Headlamp version: $VERSION_OUTPUT"

# Check installation directory
if [ -d "/usr/local/headlamp" ]; then
    echo "✅ Headlamp installation directory exists"
    echo "📁 Installation path: /usr/local/headlamp"
else
    echo "❌ Headlamp installation directory not found"
    exit 1
fi

echo ""
echo "🎉 Headlamp is ready!"
echo "📖 Documentation: https://headlamp.dev/docs/"
echo "💡 To start Headlamp: headlamp"
EOF

chmod +x "$VERIFY_SCRIPT"
log_info "Created verification script: $VERIFY_SCRIPT"

log_success "🎉 Headlamp installation complete!"
log_info ""
log_info "📋 Summary:"
log_info "  • Headlamp version: ${VERSION}"
log_info "  • Installation path: /usr/local/headlamp"
log_info "  • Binary symlink: /usr/local/bin/headlamp"
log_info "  • Verification script: $VERIFY_SCRIPT"
log_info ""
log_info "💡 Next steps:"
log_info "  1. Run 'verify-headlamp' to check the installation"
log_info "  2. Start Headlamp with 'headlamp'"
log_info "  3. Access the web UI (default: http://localhost:4466)"
log_info "  4. Read the docs: https://headlamp.dev/docs/"
