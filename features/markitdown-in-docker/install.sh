#!/bin/bash

# Install MarkItDown wrapper for Docker
# Provides a command-line wrapper for running MarkItDown in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/markitdown"}"

log_info "Installing MarkItDown wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the markitdown wrapper script
MARKITDOWN_WRAPPER="/usr/local/bin/markitdown"

log_info "Creating markitdown wrapper script at $MARKITDOWN_WRAPPER"

cat > "$MARKITDOWN_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# MarkItDown - Docker Wrapper Script

IMAGE_NAME="${MARKITDOWN_IMAGE_NAME:-ruanzx/markitdown}"
IMAGE_TAG="${MARKITDOWN_IMAGE_TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() { echo -e "${RED}Error: $1${NC}" >&2; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}Warning: $1${NC}"; }
print_info() { echo -e "${BLUE}$1${NC}"; }

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

# Detect dev container mounts
detect_dev_container_mounts() {
    if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
        local container_id
        container_id=$(hostname)
        if [ -n "$container_id" ]; then
            docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}:{{.Destination}}{{printf "\n"}}{{end}}{{end}}' "$container_id" 2>/dev/null | grep "/workspaces/" | head -n1 || echo ""
        fi
    fi
    echo ""
}

translate_path_for_host() {
    local container_path="$1"
    local workspace_mount
    workspace_mount="$(detect_dev_container_mounts)"
    
    if [ -n "$workspace_mount" ]; then
        local host_path mount_path
        host_path=$(echo "$workspace_mount" | cut -d: -f1)
        mount_path=$(echo "$workspace_mount" | cut -d: -f2)
        echo "${container_path/#$mount_path/$host_path}"
    else
        echo "$container_path"
    fi
}

# Parse flags
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

if [ "$WRAPPER_HELP" = "true" ]; then
    cat << 'HELP'
MarkItDown Docker Wrapper

WRAPPER FLAGS:
  --wrapper-help     Show this help

ENVIRONMENT VARIABLES:
  MARKITDOWN_IMAGE_NAME   Docker image (default: ruanzx/markitdown)
  MARKITDOWN_IMAGE_TAG    Image tag (default: latest)

EXAMPLES:
  markitdown document.pdf
  markitdown document.docx -o output.md
  cat file.html | markitdown -x html

NOTE:
  To upgrade markitdown, use a newer Docker image tag:
  export MARKITDOWN_IMAGE_TAG=0.1.3

For more: https://github.com/microsoft/markitdown
HELP
    exit 0
fi

check_docker
ensure_image

# Build Docker command
CURRENT_DIR="$(pwd)"
HOST_CURRENT_DIR="$(translate_path_for_host "$CURRENT_DIR")"

DOCKER_ARGS=(
    "run" "--rm"
    "-v" "$HOST_CURRENT_DIR:/data"
    "-w" "/data"
)

# If stdin is a pipe or redirect, pass it through
if [ ! -t 0 ]; then
    DOCKER_ARGS+=("-i")
fi

DOCKER_ARGS+=("$FULL_IMAGE")

# Add user arguments (entrypoint is already markitdown)
if [ ${#ARGS[@]} -gt 0 ]; then
    DOCKER_ARGS+=("${ARGS[@]}")
fi

# Execute
exec docker "${DOCKER_ARGS[@]}"
        -o)
            OUTPUT_FILE="$2"
            ARGS+=("$1" "$2")
            shift 2
            ;;
        --help|-h)
            ARGS+=("$1")
            shift
            ;;
        *)
            # Track input file (first non-option argument)
            if [ -z "$INPUT_FILE" ] && [ -f "$1" ]; then
                INPUT_FILE="$1"
            fi
            ARGS+=("$1")
            shift
            ;;
    esac
done

# Show wrapper help if requested
if [ "$WRAPPER_HELP" = "true" ]; then
    cat << 'HELP'
MarkItDown Docker Wrapper

This wrapper runs markitdown commands inside a Docker container for easy, isolated usage.

WRAPPER FLAGS (must come before markitdown commands):
  --upgrade            Upgrade markitdown to the latest version inside the container
  --wrapper-help       Show this wrapper help message

ENVIRONMENT VARIABLES:
  MARKITDOWN_IMAGE_NAME   Docker image name (default: ruanzx/markitdown)
  MARKITDOWN_IMAGE_TAG    Docker image tag (default: latest)

MARKITDOWN COMMANDS:
  markitdown FILE              Convert file to Markdown (output to stdout)
  markitdown FILE -o OUT.md    Convert file to Markdown (save to file)

EXAMPLES:
  # Upgrade markitdown to the latest version
  markitdown --upgrade document.pdf

  # Convert a file to Markdown
  markitdown document.pdf

  # Convert with output file
  markitdown document.docx -o output.md

  # Convert PDF
  markitdown report.pdf -o report.md

  # Get markitdown help
  markitdown --help

For more information: https://github.com/microsoft/markitdown
HELP
    exit 0
fi

# Check Docker
check_docker

# Ensure image exists
ensure_image

# Get current directory (absolute)
CURRENT_DIR="$(pwd)"
HOST_CURRENT_DIR="$(translate_path_for_host "$CURRENT_DIR")"

# Build Docker command
DOCKER_CMD="docker run --rm"

# Mount current directory as /data
DOCKER_CMD="$DOCKER_CMD -v \"$HOST_CURRENT_DIR:/data\""

# Set working directory
DOCKER_CMD="$DOCKER_CMD -w /data"

# Add image
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Build the command to execute inside the container
CONTAINER_CMD=""

# If upgrade flag is set, prepend the upgrade command
if [ "$UPGRADE_MARKITDOWN" = "true" ]; then
    print_info "Upgrading markitdown to the latest version..."
    CONTAINER_CMD="pip install --upgrade --no-cache-dir markitdown > /dev/null 2>&1 && "
fi

# Add markitdown command and arguments
if [ ${#ARGS[@]} -eq 0 ]; then
    # No arguments, show help
    CONTAINER_CMD="${CONTAINER_CMD}markitdown --help"
else
    CONTAINER_CMD="${CONTAINER_CMD}markitdown ${ARGS[*]}"
fi

# Add the command to Docker
DOCKER_CMD="$DOCKER_CMD bash -c \"$CONTAINER_CMD\""

# Execute Docker command
eval "$DOCKER_CMD"
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${MARKITDOWN_IMAGE_NAME:-ruanzx/markitdown}\"|IMAGE_NAME=\"\${MARKITDOWN_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$MARKITDOWN_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${MARKITDOWN_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${MARKITDOWN_IMAGE_TAG:-${VERSION}}\"|" "$MARKITDOWN_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$MARKITDOWN_WRAPPER"

log_success "MarkItDown wrapper installed successfully at $MARKITDOWN_WRAPPER"

# Pull the Docker image
log_info "Pulling Docker image: ${IMAGE_NAME}:${VERSION}"
if docker pull "${IMAGE_NAME}:${VERSION}" >/dev/null 2>&1; then
    log_success "Docker image pulled successfully"
else
    log_warning "Failed to pull Docker image. It will be pulled on first use."
fi

# Verify installation
if command_exists markitdown; then
    log_success "MarkItDown command is now available: markitdown --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
    log_info ""
    log_info "Quick start:"
    log_info "  markitdown document.pdf                  # Convert to stdout"
    log_info "  markitdown document.docx -o output.md    # Convert to file"
    log_info "  markitdown --upgrade document.pdf        # Upgrade and convert"
    log_info "  markitdown --wrapper-help                # Wrapper help"
else
    log_error "MarkItDown wrapper installation failed"
    exit 1
fi

log_info "Note: MarkItDown runs in a Docker container with your current directory mounted at /data"
