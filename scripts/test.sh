#!/bin/bash

# Test script for DevContainer Features
# This script tests all features by building test containers

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
TEST_DIR="$ROOT_DIR/test"
BUILD_DIR="$ROOT_DIR/build"

log_info "Testing DevContainer Features"

# Function to test a single feature
test_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    
    log_info "Testing feature: $feature_name"
    
    # Create a temporary test directory under the workspace so Docker can access it
    local temp_dir=$(mktemp -d "$ROOT_DIR/test-temp.XXXXXX")
    local test_container_dir="$temp_dir/test-container"
    
    mkdir -p "$test_container_dir/.devcontainer"
    
    # Create a minimal devcontainer.json that uses the feature
    cat > "$test_container_dir/.devcontainer/devcontainer.json" << EOF
{
    "name": "Test $feature_name",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "./$feature_name": {}
    },
    "postCreateCommand": "echo 'Testing $feature_name feature'"
}
EOF
    
    # Copy the built feature to the test directory
    cp -r "$BUILD_DIR/$feature_name" "$test_container_dir/$feature_name"
    
    # Function to translate container path to host path for dev containers
    translate_to_host_path() {
        local container_path="$1"
        
        # Check if running in dev container
        if [ -n "${REMOTE_CONTAINERS:-}" ] && [ "${REMOTE_CONTAINERS}" = "true" ]; then
            local container_id=$(hostname)
            if [ -n "$container_id" ]; then
                # Try to get the bind mount for the workspace
                local workspace_mount=$(docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}:{{.Destination}}{{printf "\n"}}{{end}}{{end}}' "$container_id" 2>/dev/null | grep "/workspaces/" | head -n1 || echo "")
                if [ -n "$workspace_mount" ]; then
                    local host_path=$(echo "$workspace_mount" | cut -d: -f1)
                    local container_workspace=$(echo "$workspace_mount" | cut -d: -f2)
                    # Replace container workspace path with host path
                    echo "${container_path/#$container_workspace/$host_path}"
                    return
                fi
            fi
        fi
        
        # Not in dev container or couldn't determine mapping, return as-is
        echo "$container_path"
    }
    
    # Get the host path for the feature directory
    local host_feature_path=$(translate_to_host_path "$test_container_dir/$feature_name")
    
    # Test the feature installation by running the install script
    log_info "Running install script for $feature_name"
    
    # Run the test in a container to simulate the devcontainer environment
    if docker run --rm \
        -v "$host_feature_path:/tmp/feature" \
        -w /tmp/feature \
        mcr.microsoft.com/devcontainers/base:ubuntu \
        bash -c "
            set -e
            # Install common dependencies
            apt-get update
            apt-get install -y curl wget jq unzip tar gzip zstd
            
            # Set up environment
            export _CONTAINER_USER=vscode
            export _REMOTE_USER=vscode
            
            # Run the install script
            chmod +x install.sh
            bash install.sh
            
            echo 'Feature $feature_name test completed successfully'
        "; then
        log_success "Feature $feature_name test passed"
        cleanup_temp "$temp_dir"
        return 0
    else
        log_error "Feature $feature_name test failed"
        cleanup_temp "$temp_dir"
        return 1
    fi
}

# Function to run syntax checks
check_syntax() {
    log_info "Running syntax checks"
    
    local failed_checks=()
    
    # Check all shell scripts
    for script in $(find "$ROOT_DIR" -name "*.sh" -type f); do
        if ! bash -n "$script" 2>/dev/null; then
            log_error "Syntax error in: $script"
            failed_checks+=("$script")
        fi
    done
    
    # Check all JSON files
    for json_file in $(find "$ROOT_DIR" -name "*.json" -type f); do
        if ! jq . "$json_file" >/dev/null 2>&1; then
            log_error "Invalid JSON in: $json_file"
            failed_checks+=("$json_file")
        fi
    done
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_success "All syntax checks passed"
        return 0
    else
        log_error "Syntax checks failed for: ${failed_checks[*]}"
        return 1
    fi
}

# Main test process
main() {
    local test_type="${1:-all}"
    shift || true
    local specific_features=("$@")
    
    log_info "Starting test process: $test_type"
    
    case "$test_type" in
        "syntax")
            check_syntax
            ;;
        "features"|"all")
            # Run syntax checks first
            if ! check_syntax; then
                log_error "Syntax checks failed, aborting feature tests"
                exit 1
            fi
            
            # Check if build directory exists
            if [[ ! -d "$BUILD_DIR" ]]; then
                log_error "Build directory not found: $BUILD_DIR"
                log_info "Please run the build script first: ./scripts/build.sh"
                exit 1
            fi
            
            # Check if docker is available
            ensure_command "docker"
            
            # Find features to test
            local features=()
            if [[ ${#specific_features[@]} -gt 0 ]]; then
                # Test only specified features
                log_info "Testing specific features: ${specific_features[*]}"
                for feature_name in "${specific_features[@]}"; do
                    local feature_path="$BUILD_DIR/$feature_name"
                    if [[ -d "$feature_path" ]]; then
                        features+=("$feature_path")
                    else
                        log_error "Feature not found: $feature_name"
                        log_info "Available features: $(ls -1 "$BUILD_DIR" | tr '\n' ' ')"
                        exit 1
                    fi
                done
            else
                # Test all features
                for feature_path in "$BUILD_DIR"/*; do
                    if [[ -d "$feature_path" ]]; then
                        features+=("$feature_path")
                    fi
                done
            fi
            
            if [[ ${#features[@]} -eq 0 ]]; then
                log_error "No features to test"
                exit 1
            fi
            
            log_info "Found ${#features[@]} feature(s) to test"
            
            # Test each feature
            local failed_features=()
            for feature_path in "${features[@]}"; do
                local feature_name=$(basename "$feature_path")
                
                if test_feature "$feature_path"; then
                    log_success "Feature $feature_name test passed"
                else
                    log_error "Feature $feature_name test failed"
                    failed_features+=("$feature_name")
                fi
            done
            
            # Report results
            if [[ ${#failed_features[@]} -eq 0 ]]; then
                log_success "All feature tests passed!"
            else
                log_error "Failed tests for ${#failed_features[@]} features: ${failed_features[*]}"
                exit 1
            fi
            ;;
        *)
            # Assume it's a feature name
            log_info "Testing specific feature: $test_type"
            
            # Run syntax checks first
            if ! check_syntax; then
                log_error "Syntax checks failed, aborting feature test"
                exit 1
            fi
            
            # Check if build directory exists
            if [[ ! -d "$BUILD_DIR" ]]; then
                log_error "Build directory not found: $BUILD_DIR"
                log_info "Please run the build script first: ./scripts/build.sh"
                exit 1
            fi
            
            # Check if docker is available
            ensure_command "docker"
            
            local feature_path="$BUILD_DIR/$test_type"
            if [[ ! -d "$feature_path" ]]; then
                log_error "Feature not found: $test_type"
                log_info "Available features: $(ls -1 "$BUILD_DIR" | tr '\n' ' ')"
                exit 1
            fi
            
            if test_feature "$feature_path"; then
                log_success "Feature $test_type test passed"
            else
                log_error "Feature $test_type test failed"
                exit 1
            fi
            ;;
    esac
}

# Show usage information
usage() {
    echo "Usage: $0 [TEST_TYPE] [FEATURE_NAMES...]"
    echo ""
    echo "Test DevContainer Features"
    echo ""
    echo "Test types:"
    echo "  syntax              Run syntax checks only"
    echo "  features            Run feature installation tests"
    echo "  all                 Run all tests (default)"
    echo "  <feature-name>      Test a specific feature"
    echo ""
    echo "Examples:"
    echo "  $0                              # Run all tests"
    echo "  $0 syntax                       # Run syntax checks only"
    echo "  $0 features                     # Run all feature tests"
    echo "  $0 features kubectl helm        # Test only kubectl and helm"
    echo "  $0 markitdown-in-docker         # Test only markitdown-in-docker"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo ""
}

# Parse command line arguments
if [[ $# -eq 0 ]]; then
    # Default to running all tests
    main "all"
else
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        syntax|features|all)
            main "$@"
            exit $?
            ;;
        *)
            if [[ $1 =~ ^- ]]; then
                log_error "Unknown option: $1"
                usage
                exit 1
            else
                # Treat as feature name
                main "$@"
                exit $?
            fi
            ;;
    esac
fi
