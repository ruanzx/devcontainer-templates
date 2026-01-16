#!/bin/bash

# Install Skills-Ref wrapper
# Provides a command-line wrapper for running Skills-Ref in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/skills-ref"}"

log_info "Installing Skills-Ref wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the skills-ref wrapper script
SKILLS_REF_WRAPPER="/usr/local/bin/skills-ref"

log_info "Creating skills-ref wrapper script at $SKILLS_REF_WRAPPER"

cat > "$SKILLS_REF_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Skills-Ref - Docker Wrapper Script
# This script wraps the Skills-Ref Docker container for easy command-line usage

IMAGE_NAME="${SKILLS_REF_IMAGE_NAME:-ruanzx/skills-ref}"
IMAGE_TAG="${SKILLS_REF_IMAGE_TAG:-latest}"
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

# Main execution
check_docker
ensure_image

# Get current working directory
WORKING_DIR="$(pwd)"
HOST_WORKING_DIR=$(translate_to_host_path "$WORKING_DIR")

# Run skills-ref in Docker container
# Mount current directory to /output in container
docker run --rm \
    -v "$HOST_WORKING_DIR:/output" \
    -w /output \
    "$FULL_IMAGE" \
    "$@"
EOF

# Make the wrapper executable
chmod +x "$SKILLS_REF_WRAPPER"

log_success "✅ Skills-Ref wrapper installed successfully at $SKILLS_REF_WRAPPER"
log_info "You can now use 'skills-ref' command to validate and manage agent skills"
log_info "Example: skills-ref validate path/to/skill"
log_info "Example: skills-ref read-properties path/to/skill"
log_info "Example: skills-ref to-prompt path/to/skill-a path/to/skill-b"

# Verify installation
if command_exists skills-ref; then
    log_success "✅ Installation verified - skills-ref command is available"
else
    log_warning "⚠️  Warning: skills-ref command not immediately available, may require shell restart"
fi
