#!/bin/bash

# Build script for DevContainer Features
# This script builds and validates all features

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
FEATURES_DIR="$ROOT_DIR/features"
BUILD_DIR="$ROOT_DIR/build"

log_info "Building DevContainer Features"

# Create build directory
mkdir -p "$BUILD_DIR"

# Function to validate feature structure
validate_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    
    log_info "Validating feature: $feature_name"
    
    # Check required files
    if [[ ! -f "$feature_path/devcontainer-feature.json" ]]; then
        log_error "Missing devcontainer-feature.json in $feature_name"
        return 1
    fi
    
    if [[ ! -f "$feature_path/install.sh" ]]; then
        log_error "Missing install.sh in $feature_name"
        return 1
    fi
    
    # Validate JSON syntax
    if ! jq . "$feature_path/devcontainer-feature.json" >/dev/null 2>&1; then
        log_error "Invalid JSON in $feature_name/devcontainer-feature.json"
        return 1
    fi
    
    # Check install.sh is executable
    if [[ ! -x "$feature_path/install.sh" ]]; then
        log_warning "Making install.sh executable for $feature_name"
        chmod +x "$feature_path/install.sh"
    fi
    
    log_success "Feature $feature_name validated successfully"
}

# Function to build a single feature
build_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    local feature_build_dir="$BUILD_DIR/$feature_name"
    
    log_info "Building feature: $feature_name"
    
    # Create feature build directory
    mkdir -p "$feature_build_dir"
    
    # Copy feature files
    cp "$feature_path/devcontainer-feature.json" "$feature_build_dir/"
    cp "$feature_path/install.sh" "$feature_build_dir/"
    
    # Copy any additional files (README, etc.)
    for file in "$feature_path"/*; do
        if [[ -f "$file" && "$(basename "$file")" != "devcontainer-feature.json" && "$(basename "$file")" != "install.sh" ]]; then
            cp "$file" "$feature_build_dir/"
        fi
    done
    
    log_success "Built feature: $feature_name"
}

# Main build process
main() {
    log_info "Starting build process"
    
    # Clean build directory
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi
    mkdir -p "$BUILD_DIR"
    
    # Find all features
    if [[ ! -d "$FEATURES_DIR" ]]; then
        log_error "Features directory not found: $FEATURES_DIR"
        exit 1
    fi
    
    local features=()
    for feature_path in "$FEATURES_DIR"/*; do
        if [[ -d "$feature_path" ]]; then
            features+=("$feature_path")
        fi
    done
    
    if [[ ${#features[@]} -eq 0 ]]; then
        log_error "No features found in $FEATURES_DIR"
        exit 1
    fi
    
    log_info "Found ${#features[@]} features to build"
    
    # Validate and build each feature
    local failed_features=()
    for feature_path in "${features[@]}"; do
        local feature_name=$(basename "$feature_path")
        
        if validate_feature "$feature_path"; then
            if build_feature "$feature_path"; then
                log_success "Successfully built $feature_name"
            else
                log_error "Failed to build $feature_name"
                failed_features+=("$feature_name")
            fi
        else
            log_error "Failed to validate $feature_name"
            failed_features+=("$feature_name")
        fi
    done
    
    # Report results
    if [[ ${#failed_features[@]} -eq 0 ]]; then
        log_success "All features built successfully!"
        log_info "Build artifacts located in: $BUILD_DIR"
    else
        log_error "Failed to build ${#failed_features[@]} features: ${failed_features[*]}"
        exit 1
    fi
}

# Run main function
main "$@"
