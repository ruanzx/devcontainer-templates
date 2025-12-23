#!/bin/bash

# Install Diagrams wrapper
# Provides a command-line wrapper for running Diagrams in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/diagrams"}"

log_info "Installing Diagrams wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the diagrams wrapper script
DIAGRAMS_WRAPPER="/usr/local/bin/diagrams"

log_info "Creating diagrams wrapper script at $DIAGRAMS_WRAPPER"

cat > "$DIAGRAMS_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Diagrams - Docker Wrapper Script
# This script wraps the Diagrams Docker container for easy command-line usage

IMAGE_NAME="${DIAGRAMS_IMAGE_NAME:-ruanzx/diagrams}"
IMAGE_TAG="${DIAGRAMS_IMAGE_TAG:-latest}"
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

# Parse arguments
WORKING_DIR="$(pwd)"
OUTPUT_DIR=""
VERBOSE=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --help)
            echo "Diagrams - Docker Wrapper"
            echo ""
            echo "Usage: diagrams [OPTIONS] [SCRIPT.py]"
            echo ""
            echo "Options:"
            echo "  -o, --output DIR        Output directory for generated diagrams"
            echo "  -v, --verbose           Enable verbose logging"
            echo "  --help                  Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  DIAGRAMS_IMAGE_NAME     Docker image name (default: ruanzx/diagrams)"
            echo "  DIAGRAMS_IMAGE_TAG      Docker image tag (default: latest)"
            echo ""
            echo "Examples:"
            echo "  diagrams my_diagram.py"
            echo "  diagrams -o ./output my_diagram.py"
            echo "  diagrams --verbose diagram.py"
            exit 0
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Set default output directory if not specified
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$(pwd)/output"
fi

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Build Docker command
DOCKER_CMD="docker run --rm"

# Mount working directory (read-only for scripts)
DOCKER_CMD="$DOCKER_CMD $(get_volume_mount "$WORKING_DIR" "/data" "ro")"

# Mount output directory (read-write)
DOCKER_CMD="$DOCKER_CMD $(get_volume_mount "$OUTPUT_DIR" "/output" "rw")"

# Set working directory in container to output directory
DOCKER_CMD="$DOCKER_CMD -w /output"

# Add image name
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add diagrams arguments
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    # Convert relative paths to absolute paths in /data
    PROCESSED_ARGS=()
    for arg in "${EXTRA_ARGS[@]}"; do
        if [[ "$arg" == *.py && ! "$arg" == /* ]]; then
            # Convert relative Python file paths to /data/ paths
            PROCESSED_ARGS+=("/data/$arg")
        else
            PROCESSED_ARGS+=("$arg")
        fi
    done
    DOCKER_CMD="$DOCKER_CMD ${PROCESSED_ARGS[*]}"
else
    DOCKER_CMD="$DOCKER_CMD /data/test_diagram.py"  # Default if no args
fi

# Execute Docker command
echo "Running Diagrams in Docker container..."
echo "Working directory: $WORKING_DIR"
echo "Output directory: $OUTPUT_DIR"
echo ""

eval "$DOCKER_CMD"

print_success "✓ Diagrams execution complete"
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${DIAGRAMS_IMAGE_NAME:-ruanzx/diagrams}\"|IMAGE_NAME=\"\${DIAGRAMS_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$DIAGRAMS_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${DIAGRAMS_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${DIAGRAMS_IMAGE_TAG:-${VERSION}}\"|" "$DIAGRAMS_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$DIAGRAMS_WRAPPER"

log_success "Diagrams wrapper installed successfully at $DIAGRAMS_WRAPPER"

# Verify installation
if command_exists diagrams; then
    log_success "Diagrams command is now available: diagrams --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
else
    log_error "Diagrams installation failed"
    exit 1
fi

log_info "Note: The Diagrams Docker image will be pulled on first use if not already present"