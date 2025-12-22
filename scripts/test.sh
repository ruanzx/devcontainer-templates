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
    if [[ "$QUIET_MODE" == "false" ]]; then
        echo "Loaded environment variables from .env"
    fi
fi

# Source common utilities
source "$ROOT_DIR/common/utils.sh"

# Configuration
FEATURES_DIR="$ROOT_DIR/features"
TEST_DIR="$ROOT_DIR/test"
BUILD_DIR="$ROOT_DIR/build"
QUIET_MODE="${QUIET_MODE:-false}"

# Logging functions that respect quiet mode
log_info_quiet() {
    if [[ "$QUIET_MODE" == "false" ]]; then
        log_info "$1"
    fi
}

log_success_quiet() {
    if [[ "$QUIET_MODE" == "false" ]]; then
        log_success "$1"
    fi
}

log_warning_quiet() {
    if [[ "$QUIET_MODE" == "false" ]]; then
        log_warning "$1"
    fi
}

log_error_quiet() {
    if [[ "$QUIET_MODE" == "false" ]]; then
        log_error "$1"
    fi
}

log_info_quiet "Testing DevContainer Features"

# Function to check if a feature requires .NET SDK
feature_requires_dotnet() {
    local feature_name="$1"
    local feature_path="$BUILD_DIR/$feature_name"
    
    # Check if this feature directly depends on dotnet
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" && "$dep" == *"dotnet"* ]]; then
                    return 0
                fi
            done <<< "$installs_after"
        fi
    fi
    
    # Check if any dependency features require dotnet (recursive)
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    # Extract feature name from the full reference
                    local dep_name=$(echo "$dep" | sed 's|.*/||')
                    # Check if dependency feature exists in our build directory
                    if [[ -d "$BUILD_DIR/$dep_name" ]]; then
                        if feature_requires_dotnet "$dep_name"; then
                            return 0
                        fi
                    elif [[ "$dep" == *"dotnet"* ]]; then
                        # External dotnet dependency
                        return 0
                    fi
                fi
            done <<< "$installs_after"
        fi
    fi
    
    return 1
}

# Function to check if a feature requires Node.js
feature_requires_nodejs() {
    local feature_name="$1"
    local feature_path="$BUILD_DIR/$feature_name"
    
    # Check if this feature directly depends on nodejs
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" && ("$dep" == *"node"* || "$dep" == *"nodejs"*) ]]; then
                    return 0
                fi
            done <<< "$installs_after"
        fi
    fi
    
    # Check if any dependency features require nodejs (recursive)
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    # Extract feature name from the full reference
                    local dep_name=$(echo "$dep" | sed 's|.*/||')
                    # Check if dependency feature exists in our build directory
                    if [[ -d "$BUILD_DIR/$dep_name" ]]; then
                        if feature_requires_nodejs "$dep_name"; then
                            return 0
                        fi
                    elif [[ "$dep" == *"node"* || "$dep" == *"nodejs"* ]]; then
                        # External nodejs dependency
                        return 0
                    fi
                fi
            done <<< "$installs_after"
        fi
    fi
    
    return 1
}

# Function to check if a feature requires Python
feature_requires_python() {
    local feature_name="$1"
    local feature_path="$BUILD_DIR/$feature_name"
    
    # Check if this feature directly depends on python
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" && "$dep" == *"python"* ]]; then
                    return 0
                fi
            done <<< "$installs_after"
        fi
    fi
    
    # Check if any dependency features require python (recursive)
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    # Extract feature name from the full reference
                    local dep_name=$(echo "$dep" | sed 's|.*/||')
                    # Check if dependency feature exists in our build directory
                    if [[ -d "$BUILD_DIR/$dep_name" ]]; then
                        if feature_requires_python "$dep_name"; then
                            return 0
                        fi
                    elif [[ "$dep" == *"python"* ]]; then
                        # External python dependency
                        return 0
                    fi
                fi
            done <<< "$installs_after"
        fi
    fi
    
    return 1
}

# Function to check if a feature requires Docker
feature_requires_docker() {
    local feature_name="$1"
    local feature_path="$BUILD_DIR/$feature_name"
    
    # Check if this feature directly depends on docker
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" && "$dep" == *"docker"* ]]; then
                    return 0
                fi
            done <<< "$installs_after"
        fi
    fi
    
    # Check if any dependency features require docker (recursive)
    if [[ -f "$feature_path/devcontainer-feature.json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_path/devcontainer-feature.json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    # Extract feature name from the full reference
                    local dep_name=$(echo "$dep" | sed 's|.*/||')
                    # Check if dependency feature exists in our build directory
                    if [[ -d "$BUILD_DIR/$dep_name" ]]; then
                        if feature_requires_docker "$dep_name"; then
                            return 0
                        fi
                    elif [[ "$dep" == *"docker"* ]]; then
                        # External docker dependency
                        return 0
                    fi
                fi
            done <<< "$installs_after"
        fi
    fi
    
    # Also check if the feature name contains "docker" or "in-docker"
    if [[ "$feature_name" == *"docker"* || "$feature_name" == *"in-docker"* ]]; then
        return 0
    fi
    
    return 1
}

# Function to install .NET SDK in test container
install_dotnet_sdk() {
    cat << 'EOF'
# Install .NET SDK
echo 'Installing .NET SDK...'
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update
apt-get install -y dotnet-sdk-8.0
echo 'Installed .NET SDK'
EOF
}

# Function to install Node.js in test container
install_nodejs() {
    cat << 'EOF'
# Install Node.js
echo 'Installing Node.js...'
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
echo 'Installed Node.js'
EOF
}

# Function to install Python in test container
install_python() {
    cat << 'EOF'
# Install Python
echo 'Installing Python...'
apt-get install -y python3 python3-pip python3-venv
echo 'Installed Python'
EOF
}

# Function to install Docker CLI in test container
install_docker_cli() {
    cat << 'EOF'
# Install Docker CLI
echo 'Installing Docker CLI...'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce-cli
echo 'Installed Docker CLI'
EOF
}

# Function to test a single feature
test_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    
    log_info_quiet "Testing feature: $feature_name"
    
    # Create a temporary test directory under the workspace so Docker can access it
    local temp_dir=$(mktemp -d "$ROOT_DIR/test-temp.XXXXXX")
    local test_container_dir="$temp_dir/test-container"
    
    mkdir -p "$test_container_dir/.devcontainer"
    
    # Create a minimal devcontainer.json that uses the feature
    # First, read the feature's devcontainer-feature.json to get dependencies
    local feature_json="$feature_path/devcontainer-feature.json"
    local features_block="\"./$feature_name\": {}"
    
    if [[ -f "$feature_json" ]]; then
        # Extract installsAfter dependencies
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    features_block="$features_block,\n        \"$dep\": {}"
                fi
            done <<< "$installs_after"
        fi
    fi
    
    cat > "$test_container_dir/.devcontainer/devcontainer.json" << EOF
{
    "name": "Test $feature_name",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        $features_block
    },
    "postCreateCommand": "echo 'Testing $feature_name feature'"
}
EOF
    
    # Copy the built feature to the test directory
    cp -r "$BUILD_DIR/$feature_name" "$test_container_dir/$feature_name"
    
    # Also copy dependency features if they exist
    if [[ -f "$feature_json" ]]; then
        local installs_after=$(jq -r '.installsAfter[]?' "$feature_json" 2>/dev/null || echo "")
        if [[ -n "$installs_after" ]]; then
            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    # Extract feature name from the full reference
                    # e.g., "ghcr.io/devcontainers/features/dotnet" -> "dotnet"
                    local dep_name=$(echo "$dep" | sed 's|.*/||')
                    if [[ -d "$BUILD_DIR/$dep_name" ]]; then
                        log_info_quiet "Including dependency feature: $dep_name"
                        cp -r "$BUILD_DIR/$dep_name" "$test_container_dir/$dep_name"
                    else
                        log_warning_quiet "Dependency feature not found in build directory: $dep_name"
                    fi
                fi
            done <<< "$installs_after"
        fi
    fi
    
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
    log_info_quiet "Running install script for $feature_name"
    
    # Check if this feature requires dependencies
    local dotnet_install_script=""
    local nodejs_install_script=""
    local python_install_script=""
    local docker_cli_install_script=""
    local docker_volume_mount=""
    
    if feature_requires_dotnet "$feature_name"; then
        dotnet_install_script=$(install_dotnet_sdk)
    fi
    
    if feature_requires_nodejs "$feature_name"; then
        nodejs_install_script=$(install_nodejs)
    fi
    
    if feature_requires_python "$feature_name"; then
        python_install_script=$(install_python)
    fi
    
    if feature_requires_docker "$feature_name"; then
        docker_cli_install_script=$(install_docker_cli)
        docker_volume_mount="-v /var/run/docker.sock:/var/run/docker.sock"
    fi
    
    # Capture output for error reporting in quiet mode
    local test_output=""
    local test_exit_code=0
    
    # Run the test in a container to simulate the devcontainer environment
    if test_output=$(docker run --rm \
        -v "$host_feature_path:/tmp/feature" \
        $docker_volume_mount \
        -w /tmp/feature \
        mcr.microsoft.com/devcontainers/base:ubuntu \
        bash -c "
            set -e
            # Install common dependencies
            apt-get update >/dev/null 2>&1
            apt-get install -y curl wget jq unzip tar gzip zstd lsb-release gnupg >/dev/null 2>&1
            
            # Install dependencies if required
            $dotnet_install_script
            $nodejs_install_script
            $python_install_script
            $docker_cli_install_script
            
            # Set up environment
            export _CONTAINER_USER=vscode
            export _REMOTE_USER=vscode
            
            # Run the install script
            chmod +x install.sh
            bash install.sh
            
            echo 'Feature $feature_name test completed successfully'
        " 2>&1); then
        if [[ "$QUIET_MODE" == "true" ]]; then
            echo "✓ $feature_name PASSED"
        else
            log_success_quiet "Feature $feature_name test passed"
        fi
        cleanup_temp "$temp_dir"
        return 0
    else
        test_exit_code=$?
        if [[ "$QUIET_MODE" == "true" ]]; then
            echo "✗ $feature_name FAILED"
            # Show last few lines of error output
            echo "$test_output" | tail -10 | sed 's/^/  /'
        else
            log_error "Feature $feature_name test failed"
            echo "$test_output" | tail -20
        fi
        cleanup_temp "$temp_dir"
        return 1
    fi
}

# Function to run syntax checks
check_syntax() {
    log_info_quiet "Running syntax checks"
    
    local failed_checks=()
    
    # Check all shell scripts
    for script in $(find "$ROOT_DIR" -name "*.sh" -type f); do
        if ! bash -n "$script" 2>/dev/null; then
            log_error "Syntax error in: $script"
            failed_checks+=("$script")
        fi
    done
    
    # Check all JSON files
    for json_file in $(find "$ROOT_DIR" -name "*.json" -type f -not -path "*/test-temp*/*"); do
        if ! jq . "$json_file" >/dev/null 2>&1; then
            log_error "Invalid JSON in: $json_file"
            failed_checks+=("$json_file")
        fi
    done
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_success_quiet "All syntax checks passed"
        return 0
    else
        log_error_quiet "Syntax checks failed for: ${failed_checks[*]}"
        return 1
    fi
}

# Main test process
main() {
    local test_type="${1:-all}"
    shift || true
    local specific_features=("$@")
    
    log_info_quiet "Starting test process: $test_type"
    
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
                log_info_quiet "Testing specific features: ${specific_features[*]}"
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
            
            log_info_quiet "Found ${#features[@]} feature(s) to test"
            
            # Test each feature
            local failed_features=()
            for feature_path in "${features[@]}"; do
                local feature_name=$(basename "$feature_path")
                
                if ! test_feature "$feature_path"; then
                    failed_features+=("$feature_name")
                fi
            done
            
            # Report results
            if [[ ${#failed_features[@]} -eq 0 ]]; then
                if [[ "$QUIET_MODE" == "false" ]]; then
                    log_success "All feature tests passed!"
                fi
            else
                if [[ "$QUIET_MODE" == "false" ]]; then
                    log_error "Failed tests for ${#failed_features[@]} features: ${failed_features[*]}"
                fi
                exit 1
            fi
            ;;
        *)
            # Assume it's a feature name
            log_info_quiet "Testing specific feature: $test_type"
            
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
                log_success_quiet "Feature $test_type test passed"
            else
                log_error "Feature $test_type test failed"
                exit 1
            fi
            ;;
    esac
}

# Show usage information
usage() {
    echo "Usage: $0 [OPTIONS] [TEST_TYPE] [FEATURE_NAMES...]"
    echo ""
    echo "Test DevContainer Features"
    echo ""
    echo "Test types:"
    echo "  syntax              Run syntax checks only"
    echo "  features            Run feature installation tests"
    echo "  all                 Run all tests (default)"
    echo "  <feature-name>      Test a specific feature"
    echo ""
    echo "Options:"
    echo "  -q, --quiet         Quiet mode: only show PASSED/FAILED status"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                              # Run all tests (verbose)"
    echo "  $0 -q                           # Run all tests (quiet mode)"
    echo "  $0 --quiet features             # Run feature tests in quiet mode"
    echo "  $0 syntax                       # Run syntax checks only"
    echo "  $0 features kubectl helm        # Test only kubectl and helm"
    echo "  $0 markitdown-in-docker         # Test only markitdown-in-docker"
    echo ""
}

# Parse command line arguments
if [[ $# -eq 0 ]]; then
    # Default to running all tests
    main "all"
else
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -q|--quiet)
                QUIET_MODE="true"
                shift
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
    done
fi
