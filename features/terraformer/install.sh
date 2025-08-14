#!/bin/bash

# Install terraformer - CLI tool to generate terraform files from existing infrastructure
# https://github.com/GoogleCloudPlatform/terraformer

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
fi

# Get options
VERSION=${VERSION:-"latest"}
PROVIDER=${PROVIDER:-"all"}

# Function to get latest version from GitHub API
get_latest_version() {
    local repo="GoogleCloudPlatform/terraformer"
    local latest_tag
    
    latest_tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$latest_tag" ]; then
        echo "0.8.30"  # fallback version
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
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
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
            echo "linux"
            ;;
        darwin)
            echo "darwin"
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

echo "Installing Terraformer..."

# Determine version
if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
    echo "Latest version: $VERSION"
fi

# Get system info
ARCH=$(get_architecture)
OS=$(get_os)

echo "Installing Terraformer version $VERSION for $OS-$ARCH with provider(s): $PROVIDER"

# Construct download URL
DOWNLOAD_URL="https://github.com/GoogleCloudPlatform/terraformer/releases/download/${VERSION}/terraformer-${PROVIDER}-${OS}-${ARCH}"

# Download and install
echo "Downloading from: $DOWNLOAD_URL"

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download terraformer binary
if ! curl -fsSL "$DOWNLOAD_URL" -o terraformer; then
    echo "Failed to download Terraformer from $DOWNLOAD_URL" >&2
    echo "Please check if the version $VERSION and provider $PROVIDER combination is available." >&2
    exit 1
fi

# Make executable
chmod +x terraformer

# Install to system path
sudo mv terraformer /usr/local/bin/terraformer

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Verify installation
echo "Verifying Terraformer installation..."
if command -v terraformer >/dev/null 2>&1; then
    terraformer version
    echo "✅ Terraformer installed successfully!"
else
    echo "❌ Terraformer installation failed"
    exit 1
fi

echo "🎉 Terraformer is ready to use!"
echo ""
echo "Usage examples:"
echo "  terraformer import aws --resources=vpc,subnet --regions=us-west-2"
echo "  terraformer import google --resources=networks,firewall --projects=my-project"
echo "  terraformer import kubernetes --resources=deployments,services"
echo ""
echo "Note: You'll need to initialize Terraform providers in your working directory."
echo "See the documentation for more details: https://github.com/GoogleCloudPlatform/terraformer"
