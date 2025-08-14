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
FEATURES_NAMESPACE="${FEATURES_NAMESPACE:-ruanzx/features}"
GITHUB_REGISTRY="${GITHUB_REGISTRY:-ghcr.io}"
GITHUB_USERNAME="${GITHUB_USERNAME:-ruanzx}"
MAKE_PUBLIC="${MAKE_PUBLIC:-true}"

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
    
    # Check if devcontainer CLI is available
    ensure_command "devcontainer"
    
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

# Function to setup authentication
setup_authentication() {
    log_info "Setting up authentication for $GITHUB_REGISTRY"
    
    # The devcontainer CLI will use the GITHUB_TOKEN environment variable automatically
    # for authentication with ghcr.io
    if [[ -z "$GITHUB_TOKEN" ]]; then
        log_error "GITHUB_TOKEN environment variable is required"
        log_info "Please set your GitHub token in the .env file"
        exit 1
    fi
    
    log_success "Authentication configured"
}

# Function to make a package public
make_package_public() {
    local package_name="$1"
    log_info "Making package public: $package_name"
    
    # Use GitHub CLI to make the package public
    # The package name for container packages in the API is typically prefixed with "features/"
    local package_path="features%2F$package_name"
    
    # Try to update package visibility to public
    if gh api --method PATCH "/user/packages/container/$package_path" \
        -f visibility=public 2>/dev/null; then
        log_success "Successfully made package public: $package_name"
        return 0
    else
        log_warning "Failed to make package public via API: $package_name"
        log_info "You may need to manually set visibility at: https://github.com/users/$GITHUB_USERNAME/packages/container/package/features%2F$package_name"
        return 1
    fi
}

# Function to create and push a feature
publish_feature() {
    local feature_path="$1"
    local make_public="$2"
    local feature_name
    feature_name=$(basename "$feature_path")
    log_info "Publishing feature: $feature_name"
    
    # Get the tool version from the feature configuration
    local tool_version
    tool_version=$(jq -r '.options.version.default // .version' "$feature_path/devcontainer-feature.json")
    
    # Use devcontainer CLI to publish all features under the "features" namespace
    # This publishes the feature to ghcr.io/ruanzx/features/<feature_name>
    devcontainer features publish -r "$GITHUB_REGISTRY" -n "$GITHUB_USERNAME/features" "$feature_path"
    
    if [[ $? -eq 0 ]]; then
        log_success "Successfully published feature: $feature_name at $GITHUB_REGISTRY/$GITHUB_USERNAME/features/$feature_name:$tool_version"
        
        # Make package public if requested
        if [[ "$make_public" == "true" ]]; then
            make_package_public "$feature_name"
        fi
        
        return 0
    else
        log_error "Failed to publish feature: $feature_name"
        return 1
    fi
}

# Main publish process
main() {
    log_info "Starting publish process"
    
    check_prerequisites
    setup_authentication
    
    # Find all built features (must contain devcontainer-feature.json)
    local features=()
    for feature_path in "$BUILD_DIR"/*; do
        if [[ -d "$feature_path" && -f "$feature_path/devcontainer-feature.json" ]]; then
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
        local feature_name
        feature_name=$(basename "$feature_path")
        
        if publish_feature "$feature_path" "$MAKE_PUBLIC"; then
            log_success "Successfully published $feature_name"
        else
            log_error "Failed to publish $feature_name"
            failed_features+=("$feature_name")
        fi
    done
    
    # Report results
    if [[ ${#failed_features[@]} -eq 0 ]]; then
        log_success "All features published successfully!"
        log_info "Features are now available at: $GITHUB_REGISTRY/$GITHUB_USERNAME/features/"
        log_info ""
        if [[ "$MAKE_PUBLIC" == "true" ]]; then
            log_info "Packages have been made public automatically."
        else
            log_info "Note: Packages are published as private."
            log_info "To make packages public, visit the package settings in GitHub:"
            log_info "https://github.com/$GITHUB_USERNAME?tab=packages"
        fi
        log_info "To use these features in a devcontainer.json:"
        log_info "{"
        log_info "  \"features\": {"
        for feature_path in "${features[@]}"; do
            local feature_name
            feature_name=$(basename "$feature_path")
            local tool_version
            tool_version=$(jq -r '.options.version.default // .version' "$feature_path/devcontainer-feature.json")
            log_info "    \"$GITHUB_REGISTRY/$GITHUB_USERNAME/features/$feature_name:$tool_version\": {}"
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
    echo "  FEATURES_NAMESPACE    Feature namespace (default: ruanzx/features)"
    echo "  MAKE_PUBLIC           Make packages public after publishing (default: true)"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  --public             Make packages public after publishing (default)"
    echo "  --private            Keep packages private"
    echo ""
    echo "Examples:"
    echo "  $0                   Publish all features (public by default)"
    echo "  $0 --private         Publish all features and keep them private"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --public)
            MAKE_PUBLIC=true
            shift
            ;;
        --private)
            MAKE_PUBLIC=false
            shift
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
