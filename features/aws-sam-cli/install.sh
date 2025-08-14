#!/bin/bash

# Install AWS SAM CLI - AWS Serverless Application Model CLI
# https://docs.aws.amazon.com/serverless-application-model/

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
fi

# Get options
VERSION=${VERSION:-"latest"}
INSTALL_DOCKER=${INSTALLDOCKER:-"true"}

# Function to get latest version from GitHub API
get_latest_version() {
    local repo="aws/aws-sam-cli"
    local latest_tag
    
    latest_tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [ -z "$latest_tag" ]; then
        echo "1.126.0"  # fallback version
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
            echo "x86_64"
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
            echo "macos"
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

echo "Installing AWS SAM CLI..."

# Determine version
if [ "$VERSION" = "latest" ]; then
    VERSION=$(get_latest_version)
    echo "Latest version: $VERSION"
fi

# Get system info
ARCH=$(get_architecture)
OS=$(get_os)

echo "Installing AWS SAM CLI version $VERSION for $OS-$ARCH"

# Install prerequisites
echo "Installing prerequisites..."
apt-get update
apt-get install -y curl unzip

# Install Docker if requested
if [ "$INSTALL_DOCKER" = "true" ]; then
    echo "Installing Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        # Install Docker using the official script
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        # Add current user to docker group if not root
        if [ "$(id -u)" != "0" ]; then
            usermod -aG docker $USER || true
        fi
    else
        echo "Docker is already installed"
    fi
fi

# Construct download URL
DOWNLOAD_URL="https://github.com/aws/aws-sam-cli/releases/download/v${VERSION}/aws-sam-cli-${OS}-${ARCH}.zip"

# Download and install
echo "Downloading from: $DOWNLOAD_URL"

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download SAM CLI
if ! curl -fsSL "$DOWNLOAD_URL" -o sam-cli.zip; then
    echo "Failed to download AWS SAM CLI from $DOWNLOAD_URL" >&2
    echo "Please check if the version $VERSION is available." >&2
    exit 1
fi

# Extract and install
echo "Extracting and installing..."
unzip -q sam-cli.zip

# Check if SAM CLI is already installed and use update flag if needed
if [ -d "/usr/local/aws-sam-cli" ]; then
    echo "Updating existing AWS SAM CLI installation..."
    sudo ./install --update
else
    echo "Installing AWS SAM CLI..."
    sudo ./install
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Verify installation
echo "Verifying AWS SAM CLI installation..."
if command -v sam >/dev/null 2>&1; then
    sam --version
    echo "✅ AWS SAM CLI installed successfully!"
else
    echo "❌ AWS SAM CLI installation failed"
    exit 1
fi

# Check Docker installation if requested
if [ "$INSTALL_DOCKER" = "true" ]; then
    if command -v docker >/dev/null 2>&1; then
        echo "✅ Docker is available for SAM local testing"
    else
        echo "⚠️ Docker installation may require a restart to be fully functional"
    fi
fi

echo "🎉 AWS SAM CLI is ready to use!"
echo ""
echo "Quick start:"
echo "  sam init                    # Initialize a new SAM project"
echo "  sam build                   # Build your serverless application"
echo "  sam local start-api         # Start API locally for testing"
echo "  sam deploy --guided         # Deploy to AWS with guided prompts"
echo ""
echo "Note: Configure AWS credentials with 'aws configure' or environment variables."
echo "Documentation: https://docs.aws.amazon.com/serverless-application-model/"
