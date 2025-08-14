#!/bin/bash

# Install Trivy - A comprehensive security scanner
# https://trivy.dev/

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
fi

# Get options
VERSION=${VERSION:-"latest"}
INSTALL_DB=${INSTALLDB:-"true"}

# Function to get latest version from GitHub API
get_latest_version() {
    local repo="aquasecurity/trivy"
    local latest_tag
    
    latest_tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [ -z "$latest_tag" ]; then
        echo "0.58.1"  # fallback version
    else
        echo "$latest_tag"
    fi
}

# Function to get system architecture
get_architecture() {
    local arch
    arch=$(uname -m)
    
    case $arch in
        x86_64)
            echo "64bit"
            ;;
        aarch64|arm64)
            echo "ARM64"
            ;;
        armv7l)
            echo "ARM"
            ;;
        *)
            echo "Unsupported architecture: $arch" >&2
            exit 1
            ;;
    esac
}

# Function to get system OS
get_os() {
    local os
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    case $os in
        linux)
            echo "Linux"
            ;;
        darwin)
            echo "macOS"
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

echo "Installing Trivy..."

# Determine version
if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
    echo "Latest version: $VERSION"
fi

# Get system info
ARCH=$(get_architecture)
OS=$(get_os)

echo "Installing Trivy version $VERSION for $OS-$ARCH"

# Install prerequisites
echo "Installing prerequisites..."
apt-get update
apt-get install -y curl tar

# Construct download URL
DOWNLOAD_URL="https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_${OS}-${ARCH}.tar.gz"

# Download and install
echo "Downloading from: $DOWNLOAD_URL"

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Trivy
if ! curl -fsSL "$DOWNLOAD_URL" -o trivy.tar.gz; then
    echo "Failed to download Trivy from $DOWNLOAD_URL" >&2
    echo "Please check if the version $VERSION is available." >&2
    exit 1
fi

# Extract and install
echo "Extracting and installing..."
tar -xzf trivy.tar.gz

# Find the trivy binary (it might be in the root or in a subdirectory)
TRIVY_BINARY=""
if [ -f "trivy" ]; then
    TRIVY_BINARY="trivy"
elif [ -f "trivy_${VERSION}_${OS}-${ARCH}/trivy" ]; then
    TRIVY_BINARY="trivy_${VERSION}_${OS}-${ARCH}/trivy"
else
    # Find trivy binary recursively
    TRIVY_BINARY=$(find . -name "trivy" -type f | head -1)
fi

if [ -z "$TRIVY_BINARY" ] || [ ! -f "$TRIVY_BINARY" ]; then
    echo "Error: Could not find trivy binary in extracted archive" >&2
    exit 1
fi

# Make executable and install
chmod +x "$TRIVY_BINARY"
sudo mv "$TRIVY_BINARY" /usr/local/bin/trivy

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Verify installation
echo "Verifying Trivy installation..."
if command -v trivy >/dev/null 2>&1; then
    trivy version
    echo "✅ Trivy installed successfully!"
else
    echo "❌ Trivy installation failed"
    exit 1
fi

# Download vulnerability database if requested
if [ "$INSTALL_DB" = "true" ]; then
    echo "Downloading vulnerability database..."
    trivy image --download-db-only
    echo "✅ Vulnerability database downloaded!"
fi

echo "🎉 Trivy is ready to use!"
echo ""
echo "Quick start:"
echo "  trivy image alpine:3.19           # Scan container image"
echo "  trivy fs .                        # Scan file system"
echo "  trivy repo https://github.com/... # Scan git repository"
echo "  trivy config .                    # Scan IaC files"
echo ""
echo "Documentation: https://trivy.dev/latest/"
