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
    
    # Create a temporary test directory
    local temp_dir=$(mktemp -d)
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
    
    # Test the feature installation by running the install script
    log_info "Running install script for $feature_name"
    
    # Create a test environment
    local test_script="$temp_dir/test.sh"
    cat > "$test_script" << EOF
#!/bin/bash
set -e

# Simulate feature installation environment
export _CONTAINER_USER="vscode"
export _REMOTE_USER="vscode"

# Source and run the install script
cd "$test_container_dir/$feature_name"
chmod +x install.sh

# Run the install script in a way that simulates the devcontainer environment
bash install.sh

echo "Feature $feature_name installation test completed"
EOF
    
    chmod +x "$test_script"
    
    # Run the test in a container to simulate the devcontainer environment
    if docker run --rm \
        -v "$test_container_dir/$feature_name:/tmp/feature" \
        -v "$ROOT_DIR/common:/tmp/common" \
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
            
            # Create the expected directory structure and copy utils
            mkdir -p ../../common
            cp /tmp/common/utils.sh ../../common/
            
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
            
            log_info "Found ${#features[@]} features to test"
            
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
            log_error "Unknown test type: $test_type"
            echo "Usage: $0 [syntax|features|all]"
            exit 1
            ;;
    esac
}

# Show usage information
usage() {
    echo "Usage: $0 [TEST_TYPE]"
    echo ""
    echo "Test DevContainer Features"
    echo ""
    echo "Test types:"
    echo "  syntax     Run syntax checks only"
    echo "  features   Run feature installation tests"
    echo "  all        Run all tests (default)"
    echo ""
    echo "Options:"
    echo "  -h, --help Show this help message"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        syntax|features|all)
            main "$1"
            exit $?
            ;;
        *)
            if [[ $1 =~ ^- ]]; then
                log_error "Unknown option: $1"
                usage
                exit 1
            else
                main "$1"
                exit $?
            fi
            ;;
    esac
done

# Default to running all tests
main "all"
