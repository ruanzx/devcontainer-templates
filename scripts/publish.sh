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
FEATURES_VERSION="${FEATURES_VERSION:-1.0.0}"

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
    
    # Create a temporary directory for the feature package
    local temp_dir=$(mktemp -d)
    local feature_package_dir="$temp_dir/features/$feature_name"
    
    # Create the feature package structure
    mkdir -p "$feature_package_dir"
    
    # Copy feature files to package directory
    cp -r "$feature_path"/* "$feature_package_dir/"
    
    # Create the collection manifest
    local collection_file="$temp_dir/devcontainer-collection.json"
    cat > "$collection_file" << EOF
{
    "features": [
        {
            "id": "$feature_name",
            "version": "$FEATURES_VERSION",
            "name": "$(jq -r '.name' "$feature_path/devcontainer-feature.json")",
            "description": "$(jq -r '.description' "$feature_path/devcontainer-feature.json")"
        }
    ]
}
EOF
    
    # Create Dockerfile for packaging
    local dockerfile="$temp_dir/Dockerfile"
    cat > "$dockerfile" << 'EOF'
FROM scratch
COPY . /
EOF
    
    # Build and tag the image
    local image_tag="$GITHUB_REGISTRY/$FEATURES_NAMESPACE:$feature_name"
    local image_tag_versioned="$GITHUB_REGISTRY/$FEATURES_NAMESPACE:$feature_name-$FEATURES_VERSION"
    
    log_info "Building feature image: $image_tag"
    docker build -t "$image_tag" -t "$image_tag_versioned" "$temp_dir"
    
    # Push the image
    log_info "Pushing feature image: $image_tag"
    docker push "$image_tag"
    docker push "$image_tag_versioned"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Successfully published feature: $feature_name"
}

# Function to publish all features as a collection
publish_collection() {
    log_info "Publishing feature collection"
    
    # Create a temporary directory for the collection
    local temp_dir=$(mktemp -d)
    local features_dir="$temp_dir/features"
    
    mkdir -p "$features_dir"
    
    # Copy all built features
    for feature_path in "$BUILD_DIR"/*; do
        if [[ -d "$feature_path" ]]; then
            local feature_name=$(basename "$feature_path")
            cp -r "$feature_path" "$features_dir/$feature_name"
        fi
    done
    
    # Create collection manifest
    local collection_file="$temp_dir/devcontainer-collection.json"
    echo '{"features": [' > "$collection_file"
    
    local first=true
    for feature_path in "$BUILD_DIR"/*; do
        if [[ -d "$feature_path" ]]; then
            local feature_name=$(basename "$feature_path")
            local feature_json="$feature_path/devcontainer-feature.json"
            
            if [[ "$first" != true ]]; then
                echo ',' >> "$collection_file"
            fi
            first=false
            
            echo -n '{' >> "$collection_file"
            echo -n "\"id\": \"$feature_name\"," >> "$collection_file"
            echo -n "\"version\": \"$FEATURES_VERSION\"," >> "$collection_file"
            echo -n "\"name\": $(jq -r '.name' "$feature_json" | jq -R .)," >> "$collection_file"
            echo -n "\"description\": $(jq -r '.description' "$feature_json" | jq -R .)" >> "$collection_file"
            echo -n '}' >> "$collection_file"
        fi
    done
    
    echo ']}' >> "$collection_file"
    
    # Create Dockerfile for collection packaging
    local dockerfile="$temp_dir/Dockerfile"
    cat > "$dockerfile" << 'EOF'
FROM scratch
COPY . /
EOF
    
    # Build and tag the collection image
    local collection_tag="$GITHUB_REGISTRY/$FEATURES_NAMESPACE:latest"
    local collection_tag_versioned="$GITHUB_REGISTRY/$FEATURES_NAMESPACE:$FEATURES_VERSION"
    
    log_info "Building collection image: $collection_tag"
    docker build -t "$collection_tag" -t "$collection_tag_versioned" "$temp_dir"
    
    # Push the collection
    log_info "Pushing collection image: $collection_tag"
    docker push "$collection_tag"
    docker push "$collection_tag_versioned"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Successfully published feature collection"
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
    
    # Publish collection if all individual features succeeded
    if [[ ${#failed_features[@]} -eq 0 ]]; then
        publish_collection
        
        log_success "All features published successfully!"
        log_info "Features are now available at: $GITHUB_REGISTRY/$FEATURES_NAMESPACE"
        log_info ""
        log_info "To use these features in a devcontainer.json:"
        log_info "{"
        log_info "  \"features\": {"
        for feature_path in "${features[@]}"; do
            local feature_name=$(basename "$feature_path")
            log_info "    \"$GITHUB_REGISTRY/$FEATURES_NAMESPACE:$feature_name\": {}"
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
