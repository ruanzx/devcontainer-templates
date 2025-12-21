#!/bin/bash

# Install Pandoc wrapper
# Provides a command-line wrapper for running Pandoc in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"pandoc/extra"}"

log_info "Installing Pandoc wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the pandoc wrapper script
PANDOC_WRAPPER="/usr/local/bin/pandoc"

log_info "Creating pandoc wrapper script at $PANDOC_WRAPPER"

cat > "$PANDOC_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Pandoc - Docker Wrapper Script
# This script wraps the Pandoc Docker container for easy command-line usage

IMAGE_NAME="${PANDOC_IMAGE_NAME:-pandoc/extra}"
IMAGE_TAG="${PANDOC_IMAGE_TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Detect if running in dev container
DEV_CONTAINER_HOST_PATH=""
if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
    CONTAINER_ID=$(hostname)
    if [ -n "$CONTAINER_ID" ]; then
        # Try to get the bind mount for the workspace
        WORKSPACE_MOUNT=$(docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}:{{.Destination}}{{printf "\n"}}{{end}}{{end}}' "$CONTAINER_ID" 2>/dev/null | grep "/workspaces/" | head -n1 || echo "")
        if [ -n "$WORKSPACE_MOUNT" ]; then
            HOST_PATH=$(echo "$WORKSPACE_MOUNT" | cut -d: -f1)
            CONTAINER_PATH=$(echo "$WORKSPACE_MOUNT" | cut -d: -f2)
            DEV_CONTAINER_HOST_PATH="$HOST_PATH"
            DEV_CONTAINER_WORKSPACE="$CONTAINER_PATH"
        fi
    fi
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

ensure_image() {
    if ! docker image inspect "$FULL_IMAGE" >/dev/null 2>&1; then
        print_warning "Docker image '$FULL_IMAGE' not found locally. Pulling..."
        docker pull "$FULL_IMAGE" || {
            print_error "Failed to pull image '$FULL_IMAGE'"
            exit 1
        }
        print_success "Image pulled successfully!"
    fi
}

get_absolute_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")"
    fi
}

translate_to_host_path() {
    local container_path="$1"
    
    if [ -n "$DEV_CONTAINER_HOST_PATH" ] && [ -n "$DEV_CONTAINER_WORKSPACE" ]; then
        # Replace container workspace path with host path
        echo "${container_path/#$DEV_CONTAINER_WORKSPACE/$DEV_CONTAINER_HOST_PATH}"
    else
        echo "$container_path"
    fi
}

get_volume_mount() {
    local host_path="$1"
    local container_path="$2"
    local mode="${3:-rw}"
    
    host_path=$(get_absolute_path "$host_path")
    host_path=$(translate_to_host_path "$host_path")
    
    echo "-v $host_path:$container_path:$mode"
}

# Collect all volume mounts needed
VOLUME_MOUNTS=""
CONTAINER_ARGS=()

# Mount current working directory
WORKING_DIR="$(pwd)"
VOLUME_MOUNTS="$(get_volume_mount "$WORKING_DIR" "/data" "rw")"

# Process arguments and adjust file paths
for arg in "$@"; do
    # Check if argument looks like a file path (not an option)
    if [[ "$arg" != -* && "$arg" != --* ]]; then
        # This might be a file path, check if it exists relative to working directory
        if [[ -e "$WORKING_DIR/$arg" ]]; then
            # It's a relative path, convert to container path
            CONTAINER_ARGS+=("/data/$arg")
        elif [[ -e "$arg" ]]; then
            # It's an absolute path within the working directory
            rel_path="${arg#$WORKING_DIR/}"
            if [[ "$rel_path" != "$arg" ]]; then
                CONTAINER_ARGS+=("/data/$rel_path")
            else
                CONTAINER_ARGS+=("$arg")
            fi
        else
            # Not a file path, pass through
            CONTAINER_ARGS+=("$arg")
        fi
    else
        CONTAINER_ARGS+=("$arg")
    fi
done

# Add pandoc command
# Note: pandoc/extra image has pandoc as entrypoint, so we don't add it again
CONTAINER_ARGS=("$@")

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Build Docker command
DOCKER_CMD="docker run --rm"

# Add volume mounts
DOCKER_CMD="$DOCKER_CMD $VOLUME_MOUNTS"

# Set working directory if we mounted current dir
if [[ "$VOLUME_MOUNTS" == *"$(pwd):/data"* ]]; then
    DOCKER_CMD="$DOCKER_CMD -w /data"
fi

# Add image name
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add pandoc arguments
DOCKER_CMD="$DOCKER_CMD ${CONTAINER_ARGS[*]}"

# Execute Docker command
eval "$DOCKER_CMD"
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${PANDOC_IMAGE_NAME:-pandoc/extra}\"|IMAGE_NAME=\"\${PANDOC_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$PANDOC_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${PANDOC_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${PANDOC_IMAGE_TAG:-${VERSION}}\"|" "$PANDOC_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$PANDOC_WRAPPER"

log_success "Pandoc wrapper installed successfully at $PANDOC_WRAPPER"

# Verify installation
if command_exists pandoc; then
    log_success "Pandoc command is now available: pandoc --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
else
    log_error "Pandoc installation failed"
    exit 1
fi

log_info "Note: The Pandoc Docker image will be pulled on first use if not already present"