#!/bin/bash

# Install Docling (Document Converter) wrapper
# Provides a command-line wrapper for running Docling in a Docker container

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
IMAGE_NAME="${IMAGENAME:-"ghcr.io/docling-project/docling-serve"}"
PORT="${PORT:-"5001"}"

log_info "Installing Docling wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Ensure curl and jq are installed
log_info "Checking dependencies (curl, jq)..."
MISSING_PACKAGES=""

if ! command_exists curl; then
    MISSING_PACKAGES="${MISSING_PACKAGES}curl "
fi

if ! command_exists jq; then
    MISSING_PACKAGES="${MISSING_PACKAGES}jq "
fi

if [ -n "$MISSING_PACKAGES" ]; then
    log_info "Installing missing packages: $MISSING_PACKAGES"
    if command_exists apt-get; then
        run_with_privileges apt-get update -y
        run_with_privileges apt-get install -y $MISSING_PACKAGES
    elif command_exists apk; then
        run_with_privileges apk add --no-cache $MISSING_PACKAGES
    elif command_exists yum; then
        run_with_privileges yum install -y $MISSING_PACKAGES
    else
        log_error "Could not install dependencies. Please install curl and jq manually."
        exit 1
    fi
    log_success "Dependencies installed successfully"
fi

# Create the docling wrapper script
DOCLING_WRAPPER="/usr/local/bin/docling"

log_info "Creating docling wrapper script at $DOCLING_WRAPPER"

cat > "$DOCLING_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Docling (Document Converter) - Docker Wrapper Script
# This script wraps the Docling Docker container for easy command-line usage

IMAGE_NAME="${DOCLING_IMAGE_NAME:-ghcr.io/docling-project/docling-serve}"
IMAGE_TAG="${DOCLING_IMAGE_TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="docling-serve-$$"
DOCLING_PORT=""

# Detect Docker host for API calls
DOCKER_HOST_IP="localhost"
if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
    # We're in a dev container, use the gateway IP
    DOCKER_HOST_IP=$(ip route | grep default | awk '{print $3}' | head -n1)
    if [ -z "$DOCKER_HOST_IP" ]; then
        DOCKER_HOST_IP="host.docker.internal"
    fi
fi

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

print_info() {
    echo "$1"
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

# Find an available port
find_available_port() {
    # Use a random port in the ephemeral range
    echo $((30000 + RANDOM % 20000))
}

# Start Docling service container in background
start_service() {
    print_info "Starting Docling service..."
    
    # Check if container is already running
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Find an available port
    DOCLING_PORT=$(find_available_port)
    if [ -z "$DOCLING_PORT" ]; then
        print_error "Failed to find available port"
        return 1
    fi
    
    print_info "Using port: $DOCLING_PORT"
    
    docker run -d --rm \
        --name "$CONTAINER_NAME" \
        -p "${DOCLING_PORT}:5001" \
        "$FULL_IMAGE" >/dev/null 2>&1 || {
        print_error "Failed to start Docling service"
        return 1
    }
    
    # Wait for service to be ready
    print_info "Waiting for service to be ready on port $DOCLING_PORT..."
    local max_attempts=60
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        # Check if container is still running
        if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            print_error "Container stopped unexpectedly"
            docker logs "$CONTAINER_NAME" 2>&1 | tail -20
            return 1
        fi
        
        # Try health endpoint first, then root endpoint as fallback
        if curl -sf "http://${DOCKER_HOST_IP}:${DOCLING_PORT}/health" >/dev/null 2>&1 || \
           curl -sf "http://${DOCKER_HOST_IP}:${DOCLING_PORT}/" >/dev/null 2>&1; then
            # Double-check with a small delay
            sleep 1
            if curl -sf "http://${DOCKER_HOST_IP}:${DOCLING_PORT}/health" >/dev/null 2>&1; then
                print_success "Docling service is ready on port $DOCLING_PORT!"
                return 0
            fi
        fi
        
        sleep 2
        attempt=$((attempt + 1))
        
        # Show progress every 10 attempts
        if [ $((attempt % 10)) -eq 0 ]; then
            print_info "Still waiting... (${attempt}/${max_attempts})"
        fi
    done
    
    print_error "Service failed to start within timeout"
    docker logs "$CONTAINER_NAME" 2>&1 | tail -30
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
    return 1
}

# Stop Docling service container
stop_service() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "Stopping Docling service..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    fi
}

# Convert files using Docling API
convert_file() {
    local input_file="$1"
    local output_file="$2"
    
    # Get absolute paths
    input_file=$(get_absolute_path "$input_file")
    
    if [ ! -f "$input_file" ]; then
        print_error "Input file not found: $input_file"
        return 1
    fi
    
    # Prepare output file path
    if [ -z "$output_file" ]; then
        output_file="${input_file%.*}.md"
    fi
    output_file=$(get_absolute_path "$output_file")
    
    # Create output directory if needed
    mkdir -p "$(dirname "$output_file")"
    
    print_info "Converting: $(basename "$input_file") → $(basename "$output_file")"
    
    # Call Docling API
    local response
    local http_code
    local temp_response=$(mktemp)
    
    http_code=$(curl -sf -w "%{http_code}" -X POST \
        "http://${DOCKER_HOST_IP}:${DOCLING_PORT}/v1/convert/file" \
        -F "files=@${input_file}" \
        -F "to_formats=md" \
        -F "image_export_mode=embedded" \
        -F "do_ocr=true" \
        -F "ocr_engine=auto" \
        -F "pdf_backend=dlparse_v4" \
        -F "table_mode=accurate" \
        -F "target_type=inbody" \
        -o "$temp_response" \
        2>&1) || {
        print_error "API request failed"
        [ -f "$temp_response" ] && cat "$temp_response" >&2
        rm -f "$temp_response"
        return 1
    }
    
    # Check HTTP status code
    if [ "$http_code" != "200" ]; then
        print_error "API returned HTTP $http_code"
        [ -f "$temp_response" ] && cat "$temp_response" >&2
        rm -f "$temp_response"
        return 1
    fi
    
    response=$(cat "$temp_response")
    rm -f "$temp_response"
    
    # Extract markdown content from JSON response using jq
    local md_content
    md_content=$(echo "$response" | jq -r '.document.md_content // empty' 2>/dev/null) || {
        print_error "Failed to parse JSON response"
        echo "$response" | head -20 >&2
        return 1
    }
    
    if [ -z "$md_content" ]; then
        print_error "No markdown content in response"
        echo "Response preview:" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response" | head -20 >&2
        return 1
    fi
    
    # Write to output file
    echo "$md_content" > "$output_file"
    
    if [ -f "$output_file" ]; then
        print_success "✓ Conversion complete: $output_file"
        return 0
    else
        print_error "Failed to write output file"
        return 1
    fi
}

# Parse arguments
INPUT_FILE=""
OUTPUT_FILE=""
CONTINUE_ON_ERROR=true

show_help() {
    cat << HELP
Docling (Document Converter) - Docker Wrapper

Usage: docling [OPTIONS] <input-file> [output-file]

Convert various document formats to markdown using Docling.

Arguments:
  <input-file>     Input file to convert (required)
  [output-file]    Output markdown file (optional, defaults to input with .md extension)

Options:
  -h, --help       Show this help message
  -o, --output     Output file path (alternative to positional argument)

Supported Input Formats:
  - PDF documents
  - Microsoft Word (.docx)
  - PowerPoint (.pptx)
  - HTML files
  - Images (with OCR)
  - CSV, Excel files
  - And more...

Environment Variables:
  DOCLING_IMAGE_NAME    Docker image name (default: ghcr.io/docling-project/docling-serve)
  DOCLING_IMAGE_TAG     Docker image tag (default: latest)

Examples:
  docling document.pdf
  docling document.pdf output.md
  docling -o output.md document.docx
  docling presentation.pptx

HELP
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            echo "Run 'docling --help' for usage information."
            exit 1
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            elif [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
            else
                print_error "Too many arguments"
                echo "Run 'docling --help' for usage information."
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$INPUT_FILE" ]; then
    print_error "Input file is required"
    echo "Run 'docling --help' for usage information."
    exit 1
fi

# Check Docker
check_docker

# Ensure Docker image exists
ensure_image

# Trap to ensure cleanup
trap 'stop_service' EXIT INT TERM

# Start service
start_service || exit 1

# Convert file
convert_file "$INPUT_FILE" "$OUTPUT_FILE"
exit_code=$?

# Cleanup is handled by trap
exit $exit_code
EOF

# Set the image name, version, and port as environment defaults in the script
sed -i "s|IMAGE_NAME=\"\${DOCLING_IMAGE_NAME:-ghcr.io/docling-project/docling-serve}\"|IMAGE_NAME=\"\${DOCLING_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$DOCLING_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${DOCLING_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${DOCLING_IMAGE_TAG:-${VERSION}}\"|" "$DOCLING_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$DOCLING_WRAPPER"

log_success "Docling wrapper installed successfully at $DOCLING_WRAPPER"

# Verify installation
if command_exists docling; then
    log_success "Docling command is now available: docling --help"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
else
    log_error "Docling installation failed"
    exit 1
fi

log_info "Note: The Docling Docker image will be pulled on first use if not already present"
log_info "The service will start automatically when you run the docling command"
