#!/bin/bash

# Install spec-kit wrapper for Docker
# Provides a command-line wrapper for running spec-kit in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/spec-kit"}"

log_info "Installing spec-kit wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the specify wrapper script
SPECIFY_WRAPPER="/usr/local/bin/specify"

log_info "Creating specify wrapper script at $SPECIFY_WRAPPER"

cat > "$SPECIFY_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Spec-Kit - Docker Wrapper Script
# This script wraps the spec-kit Docker container for easy command-line usage

IMAGE_NAME="${SPECKIT_IMAGE_NAME:-ruanzx/spec-kit}"
IMAGE_TAG="${SPECKIT_IMAGE_TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

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
    local force_pull="${1:-false}"
    
    if [ "$force_pull" = "true" ]; then
        print_info "Force pulling latest image: $FULL_IMAGE"
        docker pull "$FULL_IMAGE" || {
            print_error "Failed to pull image '$FULL_IMAGE'"
            exit 1
        }
        print_success "Image updated successfully!"
    elif ! docker image inspect "$FULL_IMAGE" >/dev/null 2>&1; then
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

# Detect if running in dev container
detect_dev_container_mounts() {
    if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
        local container_id=$(hostname)
        if [ -n "$container_id" ]; then
            # Get workspace mount from dev container
            docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}:{{.Destination}}{{printf "\n"}}{{end}}{{end}}' "$container_id" 2>/dev/null | grep "/workspaces/" | head -n1 || echo ""
        fi
    fi
    echo ""
}

translate_path_for_host() {
    local container_path="$1"
    local workspace_mount="$(detect_dev_container_mounts)"
    
    if [ -n "$workspace_mount" ]; then
        local host_path=$(echo "$workspace_mount" | cut -d: -f1)
        local mount_path=$(echo "$workspace_mount" | cut -d: -f2)
        # Replace container workspace path with host path
        echo "${container_path/#$mount_path/$host_path}"
    else
        echo "$container_path"
    fi
}

# Parse wrapper-specific flags
WRAPPER_HELP=false
ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --wrapper-help)
            WRAPPER_HELP=true
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# Show wrapper help if requested
if [ "$WRAPPER_HELP" = "true" ]; then
    cat << 'HELP'
Spec-Kit Docker Wrapper

This wrapper runs spec-kit commands inside a Docker container for easy, isolated usage.
Spec-kit is automatically updated to the latest version once per day.

WRAPPER FLAGS (must come before spec-kit commands):
  --wrapper-help       Show this wrapper help message

ENVIRONMENT VARIABLES:
  SPECKIT_IMAGE_NAME   Docker image name (default: ruanzx/spec-kit)
  SPECKIT_IMAGE_TAG    Docker image tag (default: latest)

SPEC-KIT COMMANDS:
  init                 Initialize a new spec-kit project
  check                Check that all required tools are installed

EXAMPLES:
  # Initialize a new project in current directory
  specify init --here --ai copilot

  # Initialize a new project in a subdirectory
  specify init my-project --ai claude

  # Check installed tools
  specify check

  # Get spec-kit help
  specify --help

  # Force update to latest version (remove volume)
  docker volume rm speckit-uv-tools

For more information: https://github.com/github/spec-kit
HELP
    exit 0
fi

# Check Docker
check_docker

# Ensure image exists
ensure_image false

# Get current directory (absolute)
CURRENT_DIR="$(pwd)"
HOST_CURRENT_DIR="$(translate_path_for_host "$CURRENT_DIR")"

# Create or use a named volume for spec-kit tool cache to persist updates
SPECKIT_VOLUME="speckit-uv-tools"

# Check if this is the first run or if we should update (once per day)
LAST_UPDATE_FILE="/tmp/speckit-last-update-check"
CURRENT_TIME=$(date +%s)
SHOULD_UPDATE=false

if ! docker volume inspect "$SPECKIT_VOLUME" >/dev/null 2>&1; then
    print_info "First run detected. Creating persistent volume and updating spec-kit..."
    docker volume create "$SPECKIT_VOLUME" >/dev/null 2>&1
    SHOULD_UPDATE=true
else
    if [ -f "$LAST_UPDATE_FILE" ]; then
        LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
        TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
        # Update if more than 24 hours (86400 seconds) have passed
        if [ $TIME_DIFF -gt 86400 ]; then
            SHOULD_UPDATE=true
        fi
    else
        SHOULD_UPDATE=true
    fi
fi

# Update spec-kit if needed
if [ "$SHOULD_UPDATE" = "true" ]; then
    print_info "Updating spec-kit to the latest version..."
    docker run --rm -v "$SPECKIT_VOLUME:/root/.local/share/uv/tools" "$FULL_IMAGE" bash -c "uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git >/dev/null 2>&1 && echo 'Spec-kit updated successfully'" || print_warning "Failed to update spec-kit, using existing version"
    echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE"
fi

# Build Docker command
DOCKER_CMD="docker run --rm -it"

# Mount the persistent spec-kit tools volume
DOCKER_CMD="$DOCKER_CMD -v $SPECKIT_VOLUME:/root/.local/share/uv/tools"

# Mount current directory as workspace
DOCKER_CMD="$DOCKER_CMD -v \"$HOST_CURRENT_DIR:/workspace\""

# Set working directory
DOCKER_CMD="$DOCKER_CMD -w /workspace"

# Mount git config if available (read-only)
if [ -f "$HOME/.gitconfig" ]; then
    HOST_GITCONFIG="$(translate_path_for_host "$HOME/.gitconfig")"
    DOCKER_CMD="$DOCKER_CMD -v \"$HOST_GITCONFIG:/root/.gitconfig:ro\""
fi

# Pass through environment variables
if [ -n "${GITHUB_TOKEN:-}" ]; then
    DOCKER_CMD="$DOCKER_CMD -e GITHUB_TOKEN=\"$GITHUB_TOKEN\""
fi

if [ -n "${GH_TOKEN:-}" ]; then
    DOCKER_CMD="$DOCKER_CMD -e GH_TOKEN=\"$GH_TOKEN\""
fi

# Add image
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add specify command and arguments
if [ ${#ARGS[@]} -gt 0 ]; then
    DOCKER_CMD="$DOCKER_CMD specify ${ARGS[*]}"
else
    DOCKER_CMD="$DOCKER_CMD specify --help"
fi

# Execute Docker command
eval "$DOCKER_CMD"
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${SPECKIT_IMAGE_NAME:-ruanzx/spec-kit}\"|IMAGE_NAME=\"\${SPECKIT_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$SPECIFY_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${SPECKIT_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${SPECKIT_IMAGE_TAG:-${VERSION}}\"|" "$SPECIFY_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$SPECIFY_WRAPPER"

log_success "Spec-kit wrapper installed successfully at $SPECIFY_WRAPPER"

# Pull the Docker image
log_info "Pulling Docker image: ${IMAGE_NAME}:${VERSION}"
if docker pull "${IMAGE_NAME}:${VERSION}" >/dev/null 2>&1; then
    log_success "Docker image pulled successfully"
else
    log_warning "Failed to pull Docker image. It will be pulled on first use."
fi

# Verify installation
if command_exists specify; then
    log_success "Spec-kit command is now available: specify --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
    log_info ""
    log_info "Quick start:"
    log_info "  specify init my-project --ai copilot    # Initialize new project"
    log_info "  specify check                            # Check requirements"
    log_info "  specify --wrapper-help                   # Wrapper help"
    log_info ""
    log_info "Note: Spec-kit is automatically updated once per day"
    log_info "To force update: docker volume rm speckit-uv-tools"
else
    log_error "Spec-kit wrapper installation failed"
    exit 1
fi

log_info "Note: Spec-kit runs in a Docker container with your current directory mounted at /workspace"
