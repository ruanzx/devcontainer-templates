#!/bin/bash

# Install BMAD-METHOD wrapper
# Provides a command-line wrapper for running BMAD-METHOD in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/bmad"}"

log_info "Installing BMAD-METHOD wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the bmad wrapper script
BMAD_WRAPPER="/usr/local/bin/bmad"

log_info "Creating bmad wrapper script at $BMAD_WRAPPER"

cat > "$BMAD_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# BMAD-METHOD - Docker Wrapper Script
# This script wraps the BMAD-METHOD Docker container for easy command-line usage

IMAGE_NAME="${BMAD_IMAGE_NAME:-ruanzx/bmad}"
IMAGE_TAG="${BMAD_IMAGE_TAG:-latest}"
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
    # Check if image exists locally, pull if not found
    if ! docker image inspect "$FULL_IMAGE" >/dev/null 2>&1; then
        print_warning "Docker image '$FULL_IMAGE' not found locally. Pulling..."
        docker pull "$FULL_IMAGE" >/dev/null 2>&1 || {
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

get_directory() {
    local file_path="$1"
    if [[ "$file_path" == */* ]]; then
        dirname "$file_path"
    else
        echo "$(pwd)"
    fi
}

get_filename() {
    basename "$1"
}

# Parse arguments
COMMAND=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            echo "BMAD-METHOD - Docker Wrapper"
            echo ""
            echo "Usage: bmad [command] [options]"
            echo ""
            echo "This wrapper runs BMAD-METHOD in a Docker container with automatic"
            echo "workspace mounting for seamless file access."
            echo ""
            echo "Commands:"
            echo "  install              Install BMAD-METHOD in the current directory"
            echo "  --version           Show version information"
            echo "  --help              Show this help message"
            echo ""
            echo "All other commands and options are passed through to BMAD-METHOD."
            echo ""
            echo "Environment Variables:"
            echo "  BMAD_IMAGE_NAME     Docker image name (default: ruanzx/bmad)"
            echo "  BMAD_IMAGE_TAG      Docker image tag (default: latest)"
            echo ""
            echo "Examples:"
            echo "  bmad install                    # Install BMAD-METHOD in current directory"
            echo "  bmad --version                  # Show version"
            echo "  bmad *analyst                   # Run analyst agent"
            echo ""
            echo "For more information, visit:"
            echo "  https://github.com/bmad-code-org/BMAD-METHOD"
            exit 0
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# No argument validation needed - pass everything through to BMAD

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Get current working directory
CURRENT_DIR="$(pwd)"
WORKSPACE_DIR="$CURRENT_DIR"

# Translate to host path if in dev container
HOST_WORKSPACE=$(translate_to_host_path "$WORKSPACE_DIR")

# Build Docker command
DOCKER_CMD="docker run --rm"

# Mount current working directory
DOCKER_CMD="$DOCKER_CMD -v $HOST_WORKSPACE:/workspace"

# Set working directory in container
DOCKER_CMD="$DOCKER_CMD -w /workspace"

# Add image name
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add all arguments passed to bmad
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    DOCKER_CMD="$DOCKER_CMD ${EXTRA_ARGS[*]}"
fi

# Execute Docker command
eval "$DOCKER_CMD"
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${BMAD_IMAGE_NAME:-ruanzx/bmad}\"|IMAGE_NAME=\"\${BMAD_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$BMAD_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${BMAD_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${BMAD_IMAGE_TAG:-${VERSION}}\"|" "$BMAD_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$BMAD_WRAPPER"

log_success "BMAD-METHOD wrapper installed successfully at $BMAD_WRAPPER"

# Verify installation
if command_exists bmad; then
    log_success "BMAD-METHOD command is now available: bmad --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
else
    log_error "BMAD-METHOD installation failed"
    exit 1
fi

log_info "Note: The BMAD-METHOD Docker image will be pulled on first use if not already present"
