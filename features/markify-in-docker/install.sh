#!/usr/bin/env bash

# Install Markify wrapper for Docker
# Provides a command-line wrapper for running Markify in a Docker container
# Markify converts HTML files, URLs, and raw HTML to Markdown format

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    source "${SCRIPT_DIR}/utils.sh"
elif [[ -f "${SCRIPT_DIR}/../../common/utils.sh" ]]; then
    source "${SCRIPT_DIR}/../../common/utils.sh"
else
    echo "Error: Could not find utils.sh"
    exit 1
fi

# Parse options (DevContainer maps camelCase option names to UPPERCASE env vars)
VERSION="${VERSION:-"latest"}"
CLEAN_CACHE="${CLEANCACHE:-"true"}"
IMAGE_NAME="ruanzx/markify"

log_info "Installing Markify wrapper for Docker image ${IMAGE_NAME}:${VERSION}"

# Check if Docker is available
if ! command_exists docker; then
    log_error "Docker is required but not found. Please install Docker first."
    log_info "Consider using the docker-outside-of-docker feature"
    exit 1
fi

# Create the markify wrapper script
MARKIFY_WRAPPER="/usr/local/bin/markify"

log_info "Creating markify wrapper script at $MARKIFY_WRAPPER"

cat > "$MARKIFY_WRAPPER" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Markify - Docker Wrapper Script
# Converts HTML files, URLs, and raw HTML to Markdown

IMAGE_NAME="${MARKIFY_IMAGE_NAME:-ruanzx/markify}"
IMAGE_TAG="${MARKIFY_IMAGE_TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error()   { echo -e "${RED}Error: $1${NC}" >&2; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}Warning: $1${NC}"; }
print_info()    { echo -e "${BLUE}$1${NC}"; }

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

# Detect dev container workspace mounts (returns "host_path:container_path" or "")
detect_dev_container_mounts() {
    if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
        local container_id
        container_id=$(hostname)
        if [ -n "$container_id" ]; then
            docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}:{{.Destination}}{{printf "\n"}}{{end}}{{end}}' \
                "$container_id" 2>/dev/null | grep "/workspaces/" | head -n1 || true
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
Markify Docker Wrapper

WRAPPER FLAGS:
  --wrapper-help     Show this help

ENVIRONMENT VARIABLES:
  MARKIFY_IMAGE_NAME   Docker image (default: ruanzx/markify)
  MARKIFY_IMAGE_TAG    Image tag (default: latest)

EXAMPLES:
  markify html --url "https://example.com/article" --output article.md
  markify html --file input.html --output output.md
  markify html --html "<h1>Hello</h1>"
  markify html --url "https://example.com" --smart-reader --output clean.md
  markify html --url "https://example.com" --download-images --output article.md

NOTE:
  Output files are written relative to the current working directory.
  To use a specific image version:
    export MARKIFY_IMAGE_TAG=1.2.0

For more: https://github.com/ruanzx/markify
HELP
    exit 0
fi

check_docker
ensure_image

# Get current directory and translate to host path (handles dev containers)
CURRENT_DIR="$(pwd)"
HOST_CURRENT_DIR="$(translate_path_for_host "$CURRENT_DIR")"

# Build Docker command - mount CWD to /app/output (the Markify container working dir)
DOCKER_ARGS=(
    "run" "--rm"
    "-v" "${HOST_CURRENT_DIR}:/app/output"
    "-w" "/app/output"
)

# Pass stdin through if it is a pipe or redirect
if [ ! -t 0 ]; then
    DOCKER_ARGS+=("-i")
fi

DOCKER_ARGS+=("$FULL_IMAGE")

# Append user arguments
if [ ${#ARGS[@]} -gt 0 ]; then
    DOCKER_ARGS+=("${ARGS[@]}")
fi

# Execute
exec docker "${DOCKER_ARGS[@]}"
EOF

# Bake the image name and version into the wrapper defaults
sed -i "s|IMAGE_NAME=\"\${MARKIFY_IMAGE_NAME:-ruanzx/markify}\"|IMAGE_NAME=\"\${MARKIFY_IMAGE_NAME:-${IMAGE_NAME}}\"|" "$MARKIFY_WRAPPER"
sed -i "s|IMAGE_TAG=\"\${MARKIFY_IMAGE_TAG:-latest}\"|IMAGE_TAG=\"\${MARKIFY_IMAGE_TAG:-${VERSION}}\"|" "$MARKIFY_WRAPPER"

# Make the wrapper executable
run_with_privileges chmod +x "$MARKIFY_WRAPPER"

log_success "Markify wrapper installed at $MARKIFY_WRAPPER"

# Pull the Docker image (warn on failure - will auto-pull on first use)
log_info "Pulling Docker image: ${IMAGE_NAME}:${VERSION}"
if docker pull "${IMAGE_NAME}:${VERSION}" >/dev/null 2>&1; then
    log_success "Docker image pulled successfully"
else
    log_warning "Failed to pull Docker image. It will be pulled on first use."
fi

# Optionally clean Docker layer cache
if [[ "${CLEAN_CACHE}" == "true" ]]; then
    log_info "Cleaning Docker build cache..."
    docker builder prune -f --filter type=exec.cachemount >/dev/null 2>&1 || true
    log_success "Docker cache cleaned"
fi

# Verify installation
if command_exists markify; then
    log_success "Markify command is now available"
    log_info "Docker image: ${IMAGE_NAME}:${VERSION}"
    log_info ""
    log_info "Quick start:"
    log_info "  markify html --url \"https://example.com\" --output page.md"
    log_info "  markify html --file input.html --output output.md"
    log_info "  markify html --html \"<h1>Hello</h1>\""
    log_info "  markify --wrapper-help"
else
    log_error "Markify wrapper installation failed"
    exit 1
fi

log_info "Note: Markify runs in Docker with your current directory mounted at /app/output"
