#!/bin/bash

# Common utilities for devcontainer features
# Source this file in feature install scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Architecture detection
get_architecture() {
    local arch=$(uname -m)
    case $arch in
        x86_64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        armv7l) echo "arm" ;;
        *) 
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# OS detection
get_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    else
        log_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Download file with retries
download_file() {
    local url="$1"
    local output="$2"
    local retries=3
    
    for i in $(seq 1 $retries); do
        log_info "Downloading $url (attempt $i/$retries)"
        if curl -fsSL "$url" -o "$output"; then
            log_success "Downloaded $output"
            return 0
        else
            log_warning "Download failed, retrying..."
            sleep 2
        fi
    done
    
    log_error "Failed to download $url after $retries attempts"
    return 1
}

# Extract archive based on extension
extract_archive() {
    local archive="$1"
    local destination="${2:-.}"
    
    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$destination"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$destination"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$destination"
            ;;
        *.tar.zst)
            zstd -d "$archive" && tar -xf "${archive%.zst}" -C "$destination"
            rm -f "${archive%.zst}"
            ;;
        *.zip)
            unzip -q "$archive" -d "$destination"
            ;;
        *)
            log_error "Unsupported archive format: $archive"
            return 1
            ;;
    esac
}

# Install binary to /usr/local/bin
install_binary() {
    local binary_path="$1"
    local binary_name="${2:-$(basename $binary_path)}"
    local target_dir="/usr/local/bin"
    
    if [[ ! -f "$binary_path" ]]; then
        log_error "Binary not found: $binary_path"
        return 1
    fi
    
    chmod +x "$binary_path"
    mv "$binary_path" "$target_dir/$binary_name"
    log_success "Installed $binary_name to $target_dir"
}

# Cleanup temporary files
cleanup_temp() {
    local temp_dir="$1"
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
        log_info "Cleaned up temporary directory: $temp_dir"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
ensure_command() {
    local cmd="$1"
    if ! command_exists "$cmd"; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
}

# Update package manager cache
update_packages() {
    if command_exists apt-get; then
        log_info "Updating apt package cache"
        apt-get update
    elif command_exists yum; then
        log_info "Updating yum package cache"
        yum update -y
    elif command_exists apk; then
        log_info "Updating apk package cache"
        apk update
    fi
}

# Install packages using available package manager
install_packages() {
    local packages="$@"
    
    if command_exists apt-get; then
        apt-get install -y $packages
    elif command_exists yum; then
        yum install -y $packages
    elif command_exists apk; then
        apk add $packages
    else
        log_error "No supported package manager found"
        exit 1
    fi
}

# Validate semver version
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format: $version (expected semver)"
        return 1
    fi
}

# Strip v prefix from version
normalize_version() {
    local version="$1"
    echo "${version#v}"
}
