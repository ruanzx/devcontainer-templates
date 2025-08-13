#!/bin/bash

# Publish script for DevContainer Features to GitHub Container Registry
# This script publishes features to GHCR for distribution

set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env file if it exists
if [[ -f "$ROOT_DIR/.env" ]]; then
    source "$ROOT_DIR/.env"
    echo "Loaded environment variables from .env"
fi

# Source common utilities
source "$ROOT_DIR/common/utils.sh"

# Configuration
BUILD_DIR="$ROOT_DIR/build"
FEATURES_NAMESPACE="${FEATURES_NAMESPACE:-ruanzx/devcontainer-features}"
GITHUB_REGISTRY="${GITHUB_REGISTRY:-ghcr.io}"
GITHUB_USERNAME="${GITHUB_USERNAME:-ruanzx}"

# Validate required environment variables
if [[ -z "$GITHUB_TOKEN" ]]; then
    log_error "GITHUB_TOKEN environment variable is required"
    log_info "Please set your GitHub token in the .env file"
    exit 1
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
    log_error "GITHUB_USERNAME environment variable is required"
    exit 1
fi

log_info "Publishing DevContainer Features to $GITHUB_REGISTRY/$FEATURES_NAMESPACE"

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites"
    
    # Check if docker is available
    ensure_command "docker"
    
    # Check if jq is available
    ensure_command "jq"
    
    # Check if build directory exists
    if [[ ! -d "$BUILD_DIR" ]]; then
        log_error "Build directory not found: $BUILD_DIR"
        log_info "Please run the build script first: ./scripts/build.sh"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Function to login to GitHub Container Registry
ghcr_login() {
    log_info "Logging into GitHub Container Registry"
    
    echo "$GITHUB_TOKEN" | docker login "$GITHUB_REGISTRY" -u "$GITHUB_USERNAME" --password-stdin
    
    if [[ $? -eq 0 ]]; then
        log_success "Successfully logged into $GITHUB_REGISTRY"
    else
        log_error "Failed to login to $GITHUB_REGISTRY"
        exit 1
    fi
}

# Function to create and push a feature
publish_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    
    log_info "Publishing feature: $feature_name"
    
    # Get the tool version from the feature configuration
    local tool_version=$(jq -r '.options.version.default // .version' "$feature_path/devcontainer-feature.json")
    
    # Create a temporary directory for the feature package
    local temp_dir=$(mktemp -d)
    
    # Copy feature files to temp directory (root level for single feature repo)
    cp -r "$feature_path"/* "$temp_dir/"
    
    # Create Dockerfile for packaging
    local dockerfile="$temp_dir/Dockerfile"
    cat > "$dockerfile" << 'EOF'
FROM scratch
COPY . /
EOF
    
    # Build and tag the image with tool version
    local image_base="$GITHUB_REGISTRY/$FEATURES_NAMESPACE/$feature_name"
    local image_tag_latest="$image_base:latest"
    local image_tag_versioned="$image_base:$tool_version"
    
    log_info "Building feature image: $image_tag_latest (version: $tool_version)"
    docker build -t "$image_tag_latest" -t "$image_tag_versioned" "$temp_dir"
    
    # Push the image
    log_info "Pushing feature image: $image_tag_latest"
    docker push "$image_tag_latest"
    docker push "$image_tag_versioned"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Successfully published feature: $feature_name at $image_base:$tool_version"
}

# Main publish process
main() {
    log_info "Starting publish process"
    
    check_prerequisites
    ghcr_login
    
    # Find all built features
    local features=()
    for feature_path in "$BUILD_DIR"/*; do
        if [[ -d "$feature_path" ]]; then
            features+=("$feature_path")
        fi
    done
    
    if [[ ${#features[@]} -eq 0 ]]; then
        log_error "No built features found in $BUILD_DIR"
        log_info "Please run the build script first: ./scripts/build.sh"
        exit 1
    fi
    
    log_info "Found ${#features[@]} features to publish"
    
    # Publish individual features
    local failed_features=()
    for feature_path in "${features[@]}"; do
        local feature_name=$(basename "$feature_path")
        
        if publish_feature "$feature_path"; then
            log_success "Successfully published $feature_name"
        else
            log_error "Failed to publish $feature_name"
            failed_features+=("$feature_name")
        fi
    done
    
    # Report results
    if [[ ${#failed_features[@]} -eq 0 ]]; then
        log_success "All features published successfully!"
        log_info "Features are now available at: $GITHUB_REGISTRY/$FEATURES_NAMESPACE/"
        log_info ""
        log_info "To use these features in a devcontainer.json:"
        log_info "{"
        log_info "  \"features\": {"
        for feature_path in "${features[@]}"; do
            local feature_name=$(basename "$feature_path")
            local tool_version=$(jq -r '.options.version.default // .version' "$feature_path/devcontainer-feature.json")
            log_info "    \"$GITHUB_REGISTRY/$FEATURES_NAMESPACE/$feature_name:$tool_version\": {}"
        done
        log_info "  }"
        log_info "}"
    else
        log_error "Failed to publish ${#failed_features[@]} features: ${failed_features[*]}"
        exit 1
    fi
}

# Show usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Publish DevContainer Features to GitHub Container Registry"
    echo ""
    echo "Environment variables (can be set in .env file):"
    echo "  GITHUB_TOKEN          GitHub personal access token (required)"
    echo "  GITHUB_USERNAME       GitHub username (default: ruanzx)"
    echo "  GITHUB_REGISTRY       Registry URL (default: ghcr.io)"
    echo "  FEATURES_NAMESPACE    Feature namespace (default: ruanzx/devcontainer-features)"
    echo "  FEATURES_VERSION      Features version (default: 1.0.0)"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                   Publish all features"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Run main function
main "$@"
