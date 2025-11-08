#!/bin/bash

# Install MDC (Markdown to DOCX Converter) wrapper
# Provides a command-line wrapper for running MDC in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ruanzx/mdc"}"

log_info "Installing MDC wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the mdc wrapper script
MDC_WRAPPER="/usr/local/bin/mdc"

log_info "Creating mdc wrapper script at $MDC_WRAPPER"

cat > "$MDC_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# MDC (Markdown to DOCX Converter) - Docker Wrapper Script
# This script wraps the MDC Docker container for easy command-line usage

IMAGE_NAME="${MDC_IMAGE_NAME:-ruanzx/mdc}"
IMAGE_TAG="${MDC_IMAGE_TAG:-latest}"
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
INPUT_FILE=""
OUTPUT_FILE=""
TEMPLATE_FILE=""
VERBOSE=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input-file)
            INPUT_FILE="$2"
            shift 2
            ;;
        -o|--output-file)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -t|--template)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --help)
            echo "MDC (Markdown to DOCX Converter) - Docker Wrapper"
            echo ""
            echo "Usage: mdc -i INPUT.md -o OUTPUT.docx [-t TEMPLATE.docx] [-v]"
            echo ""
            echo "Options:"
            echo "  -i, --input-file FILE    Input Markdown file (required)"
            echo "  -o, --output-file FILE   Output Word document (required)"
            echo "  -t, --template FILE      Word template file (optional)"
            echo "  -v, --verbose            Enable verbose logging"
            echo "  --help                   Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  MDC_IMAGE_NAME           Docker image name (default: ruanzx/mdc)"
            echo "  MDC_IMAGE_TAG            Docker image tag (default: latest)"
            echo ""
            echo "Examples:"
            echo "  mdc -i document.md -o document.docx"
            echo "  mdc -i input.md -o output.docx -t template.docx"
            echo "  mdc -i report.md -o report.docx --verbose"
            exit 0
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$INPUT_FILE" ]; then
    print_error "Input file is required. Use -i or --input-file"
    echo "Run 'mdc --help' for usage information."
    exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
    print_error "Output file is required. Use -o or --output-file"
    echo "Run 'mdc --help' for usage information."
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    print_error "Input file not found: $INPUT_FILE"
    exit 1
fi

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Prepare volume mounts and container paths
INPUT_DIR="$(get_directory "$INPUT_FILE")"
INPUT_FILENAME="$(get_filename "$INPUT_FILE")"
OUTPUT_DIR="$(get_directory "$OUTPUT_FILE")"
OUTPUT_FILENAME="$(get_filename "$OUTPUT_FILE")"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Build Docker command
DOCKER_CMD="docker run --rm"

# Mount input directory (read-only)
DOCKER_CMD="$DOCKER_CMD $(get_volume_mount "$INPUT_DIR" "/data/input" "ro")"

# Mount output directory (read-write)
DOCKER_CMD="$DOCKER_CMD $(get_volume_mount "$OUTPUT_DIR" "/data/output" "rw")"

# Container file paths
CONTAINER_INPUT="/data/input/$INPUT_FILENAME"
CONTAINER_OUTPUT="/data/output/$OUTPUT_FILENAME"

# Add template if provided
if [ -n "$TEMPLATE_FILE" ]; then
    if [ ! -f "$TEMPLATE_FILE" ]; then
        print_error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    TEMPLATE_DIR="$(get_directory "$TEMPLATE_FILE")"
    TEMPLATE_FILENAME="$(get_filename "$TEMPLATE_FILE")"
    
    DOCKER_CMD="$DOCKER_CMD $(get_volume_mount "$TEMPLATE_DIR" "/data/template" "ro")"
    CONTAINER_TEMPLATE="/data/template/$TEMPLATE_FILENAME"
fi

# Add image name
DOCKER_CMD="$DOCKER_CMD $FULL_IMAGE"

# Add MDC arguments
DOCKER_CMD="$DOCKER_CMD -i $CONTAINER_INPUT -o $CONTAINER_OUTPUT"

if [ -n "$TEMPLATE_FILE" ]; then
    DOCKER_CMD="$DOCKER_CMD -t $CONTAINER_TEMPLATE"
fi

if [ -n "$VERBOSE" ]; then
    DOCKER_CMD="$DOCKER_CMD $VERBOSE"
fi

# Add any extra arguments
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    DOCKER_CMD="$DOCKER_CMD ${EXTRA_ARGS[*]}"
fi

# Execute Docker command
echo "Converting: $INPUT_FILE → $OUTPUT_FILE"
if [ -n "$TEMPLATE_FILE" ]; then
    echo "Using template: $TEMPLATE_FILE"
fi
echo ""

eval "$DOCKER_CMD"

# Check if output file was created
if [ -f "$OUTPUT_FILE" ]; then
    print_success "✓ Conversion complete: $OUTPUT_FILE"
    exit 0
else
    print_error "Output file was not created"
    exit 1
fi
EOF

# Set the image name and version as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${MDC_IMAGE_NAME:-ruanzx/mdc}\"|IMAGE_NAME=\"\${MDC_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$MDC_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${MDC_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${MDC_IMAGE_TAG:-${VERSION}}\"|" "$MDC_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$MDC_WRAPPER"

log_success "MDC wrapper installed successfully at $MDC_WRAPPER"

# Verify installation
if command_exists mdc; then
    log_success "MDC command is now available: mdc --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
else
    log_error "MDC installation failed"
    exit 1
fi

log_info "Note: The MDC Docker image will be pulled on first use if not already present"
