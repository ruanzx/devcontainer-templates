#!/bin/bash

# Install tldr wrapper
# Provides a command-line wrapper for running tldr in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/tldr"}"

log_info "Installing tldr wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the tldr wrapper script
TLDR_WRAPPER="/usr/local/bin/tldr"

log_info "Creating tldr wrapper script at $TLDR_WRAPPER"

cat > "$TLDR_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -eo pipefail

# tldr - Docker Wrapper Script
# This script wraps the tldr Docker container for easy command-line usage

IMAGE_NAME="${TLDR_IMAGE_NAME:-ruanzx/tldr}"
IMAGE_TAG="${TLDR_IMAGE_TAG:-latest}"
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
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}$1${NC}"
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

# Parse arguments
COMMAND=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            echo "tldr - Docker Wrapper"
            echo ""
            echo "Usage: tldr [command] [options]"
            echo ""
            echo "This wrapper runs tldr in a Docker container with persistent caching."
            echo ""
            echo "Commands:"
            echo "  <command>         Get help for a command (e.g., 'tldr tar')"
            echo "  --help            Show this help message"
            echo "  --version         Show version information"
            echo "  --list            List all available pages"
            echo "  --update          Update local pages cache"
            echo ""
            echo "All other commands and options are passed through to tldr."
            echo ""
            echo "Environment Variables:"
            echo "  TLDR_IMAGE_NAME    Docker image name (default: ruanzx/tldr)"
            echo "  TLDR_IMAGE_TAG     Docker image tag (default: latest)"
            echo ""
            echo "Cache Management:"
            echo "  Cache is persisted in Docker volume 'tldr-cache-<workspace-hash>'"
            echo "  Each workspace gets its own isolated cache"
            echo "  To update cache manually: tldr --update"
            echo "  To clear cache: docker volume rm tldr-cache-<workspace-hash>"
            echo ""
            echo "Examples:"
            echo "  tldr tar                    # Get help for tar command"
            echo "  tldr git commit             # Get help for git commit"
            echo "  tldr --list                 # List all available pages"
            echo "  tldr --update               # Update local cache"
            echo ""
            echo "For more information, visit:"
            echo "  https://github.com/tldr-pages/tldr"
            exit 0
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Create or use a named volume for tldr cache to persist pages
# Include current directory hash in volume name to make it unique per workspace
WORKSPACE_HASH=$(echo "$PWD" | md5sum | cut -d' ' -f1 | cut -c1-8)
# TLDR_VOLUME="tldr-cache-${WORKSPACE_HASH}"
TLDR_VOLUME="tldr-cache"

# Create volume if it doesn't exist and do initial cache update
if ! docker volume inspect "$TLDR_VOLUME" >/dev/null 2>&1; then
    print_info "First run detected. Creating persistent volume: $TLDR_VOLUME"
    docker volume create "$TLDR_VOLUME" >/dev/null 2>&1
    print_info "Updating tldr cache..."
    if docker run --rm --entrypoint sh -v "$TLDR_VOLUME:/root/.tldr" "$FULL_IMAGE" -c "tldr --update" >/dev/null 2>&1; then
        print_success "Cache initialized successfully!"
    else
        print_warning "Failed to initialize cache, will update on first use"
    fi
fi

# Build Docker command
DOCKER_CMD="docker run --rm"

# Mount the persistent tldr cache volume
DOCKER_CMD="$DOCKER_CMD -v $TLDR_VOLUME:/root/.tldr"

# Add image name
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add all arguments passed to tldr
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    DOCKER_CMD="$DOCKER_CMD ${EXTRA_ARGS[*]}"
fi

# Execute Docker command
exec $DOCKER_CMD
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${TLDR_IMAGE_NAME:-ruanzx/tldr}\"|IMAGE_NAME=\"\${TLDR_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$TLDR_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${TLDR_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${TLDR_IMAGE_TAG:-${VERSION}}\"|" "$TLDR_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$TLDR_WRAPPER"

log_success "tldr wrapper installed successfully at $TLDR_WRAPPER"

# Pull the Docker image
log_info "Pulling Docker image: ${IMAGE_NAME}:${VERSION}"
if docker pull "${IMAGE_NAME}:${VERSION}" >/dev/null 2>&1; then
    log_success "Docker image pulled successfully"
else
    log_warning "Failed to pull Docker image. It will be pulled on first use."
fi

# Verify installation
if command_exists tldr; then
    log_success "tldr command is now available: tldr --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
    log_info ""
    log_info "Quick start:"
    log_info "  tldr tar                    # Get help for tar command"
    log_info "  tldr git                    # Get help for git command"
    log_info "  tldr --list                 # List all available pages"
    log_info "  tldr --update               # Update local cache"
else
    log_error "tldr installation failed"
    exit 1
fi

log_info "Note: tldr runs in a Docker container for isolated execution"