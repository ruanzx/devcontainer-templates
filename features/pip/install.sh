#!/bin/bash

# Install Python packages using pip
# https://pip.pypa.io/en/stable/

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
PACKAGES="${PACKAGES:-""}"
UPGRADE="${UPGRADE:-"false"}"
REQUIREMENTS="${REQUIREMENTS:-""}"
EXTRA_ARGS="${EXTRAARGS:-""}"

log_info "Installing Python packages using pip"

# Global variable to store pip command
PIP_CMD=""
USE_BREAK_SYSTEM_PACKAGES="false"

# Function to check if pip supports --break-system-packages flag
pip_supports_break_system_packages() {
    local pip_cmd="${1:-pip3}"
    $pip_cmd install --help 2>/dev/null | grep -q -- "--break-system-packages"
}

# Function to check if Python and pip are available
check_python_environment() {
    if ! command_exists python3; then
        log_error "Python 3 is required but not found"
        log_info "Install the python feature before this feature:"
        log_info "  \"ghcr.io/devcontainers/features/python\": {}"
        exit 1
    fi
    
    if ! command_exists pip3 && ! command_exists pip; then
        log_error "pip is required but not found"
        log_info "pip should be installed with Python. Please check your Python installation."
        exit 1
    fi
    
    # Determine which pip command to use
    if command_exists pip3; then
        PIP_CMD="pip3"
    else
        PIP_CMD="pip"
    fi
    
    log_info "Found Python: $(python3 --version 2>/dev/null || python --version)"
    log_info "Found pip: $($PIP_CMD --version | head -n1)"
    
    # Check if we should use --break-system-packages
    if pip_supports_break_system_packages "$PIP_CMD"; then
        USE_BREAK_SYSTEM_PACKAGES="true"
        log_info "pip supports --break-system-packages flag"
    else
        USE_BREAK_SYSTEM_PACKAGES="false"
        log_info "pip does not support --break-system-packages flag (older version)"
    fi
}

# Function to validate package names
validate_packages() {
    local packages="$1"
    local invalid_packages=()
    
    if [[ -z "$packages" ]]; then
        return 0
    fi
    
    # Convert comma-separated list to array
    IFS=',' read -ra package_array <<< "$packages"
    
    # Basic validation - check for obviously invalid characters
    for package in "${package_array[@]}"; do
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Skip empty packages
        if [[ -z "$package" ]]; then
            continue
        fi
        
        # Check for invalid characters in package names
        # Valid: letters, numbers, dots, hyphens, underscores, square brackets (for extras)
        # Allow common Python package name patterns
        if [[ ! "$package" =~ ^[a-zA-Z0-9._-]+(\[[a-zA-Z0-9,_-]*\])?([\<\>\=\!\~][0-9a-zA-Z._-]*)*$ ]]; then
            invalid_packages+=("$package")
        fi
    done
    
    if [[ ${#invalid_packages[@]} -gt 0 ]]; then
        log_error "Invalid package names detected:"
        printf '  - %s\n' "${invalid_packages[@]}"
        log_error "Package names should only contain letters, numbers, dots, hyphens, underscores, and version specifiers"
        return 1
    fi
}

# Function to install packages from comma-separated list
install_packages() {
    local packages="$1"
    
    if [[ -z "$packages" ]]; then
        return 0
    fi
    
    log_info "Installing packages: $packages"
    
    # Convert comma-separated list to array for individual installation
    IFS=',' read -ra package_array <<< "$packages"
    
    local failed_packages=()
    local successful_packages=()
    
    for package in "${package_array[@]}"; do
        # Trim whitespace
        package=$(echo "$package" | xargs)
        
        # Skip empty packages
        if [[ -z "$package" ]]; then
            continue
        fi
        
        log_info "Installing: $package"
        
        # Build pip install command
        local pip_args=("install")
        
        # Add --break-system-packages for newer pip versions in managed environments
        # This is safe in containers as they are isolated environments
        if [[ "$USE_BREAK_SYSTEM_PACKAGES" == "true" ]]; then
            pip_args+=("--break-system-packages")
        fi
        
        if [[ "$UPGRADE" == "true" ]]; then
            pip_args+=("--upgrade")
        fi
        
        # Add extra arguments if provided
        if [[ -n "$EXTRA_ARGS" ]]; then
            # Split extra args by space and add them
            read -ra extra_array <<< "$EXTRA_ARGS"
            pip_args+=("${extra_array[@]}")
        fi
        
        pip_args+=("$package")
        
        # Execute pip install
        if $PIP_CMD "${pip_args[@]}"; then
            successful_packages+=("$package")
            log_info "✅ Successfully installed: $package"
        else
            failed_packages+=("$package")
            log_warning "❌ Failed to install: $package"
        fi
    done
    
    # Report results
    if [[ ${#successful_packages[@]} -gt 0 ]]; then
        log_success "Successfully installed ${#successful_packages[@]} packages:"
        printf '  ✅ %s\n' "${successful_packages[@]}"
    fi
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Failed to install ${#failed_packages[@]} packages:"
        printf '  ❌ %s\n' "${failed_packages[@]}"
        return 1
    fi
}

# Function to install packages from requirements file
install_from_requirements() {
    local requirements_file="$1"
    
    if [[ -z "$requirements_file" ]]; then
        return 0
    fi
    
    if [[ ! -f "$requirements_file" ]]; then
        log_error "Requirements file not found: $requirements_file"
        return 1
    fi
    
    log_info "Installing packages from requirements file: $requirements_file"
    
    # Build pip install command
    local pip_args=("install" "-r" "$requirements_file")
    
    # Add --break-system-packages for newer pip versions in managed environments
    if [[ "$USE_BREAK_SYSTEM_PACKAGES" == "true" ]]; then
        pip_args+=("--break-system-packages")
    fi
    
    if [[ "$UPGRADE" == "true" ]]; then
        pip_args+=("--upgrade")
    fi
    
    # Add extra arguments if provided
    if [[ -n "$EXTRA_ARGS" ]]; then
        read -ra extra_array <<< "$EXTRA_ARGS"
        pip_args+=("${extra_array[@]}")
    fi
    
    # Execute pip install
    if $PIP_CMD "${pip_args[@]}"; then
        log_success "Successfully installed packages from requirements file"
    else
        log_error "Failed to install packages from requirements file"
        return 1
    fi
}

# Main installation process
check_python_environment

# Validate inputs
if [[ -n "$PACKAGES" ]]; then
    if ! validate_packages "$PACKAGES"; then
        exit 1
    fi
fi

# Check if we have anything to install
if [[ -z "$PACKAGES" && -z "$REQUIREMENTS" ]]; then
    log_warning "No packages or requirements file specified"
    log_info "To install packages, specify them in the 'packages' option or provide a 'requirements' file path"
    exit 0
fi

# Install packages from requirements file if specified
if [[ -n "$REQUIREMENTS" ]]; then
    if ! install_from_requirements "$REQUIREMENTS"; then
        exit 1
    fi
fi

# Install individual packages if specified
if [[ -n "$PACKAGES" ]]; then
    if ! install_packages "$PACKAGES"; then
        exit 1
    fi
fi

# Create verification script
VERIFY_SCRIPT="/usr/local/bin/verify-pip-packages"
run_with_privileges bash -c "cat > '$VERIFY_SCRIPT' << 'EOF'
#!/bin/bash
echo '🔍 Verifying pip installation and packages...'

# Check Python
if ! command -v python3 >/dev/null 2>&1; then
    echo '❌ Python 3 not found'
    exit 1
fi

echo \"✅ Python found: \$(python3 --version)\"

# Check pip
if command -v pip3 >/dev/null 2>&1; then
    PIP_CMD='pip3'
elif command -v pip >/dev/null 2>&1; then
    PIP_CMD='pip'
else
    echo '❌ pip not found'
    exit 1
fi

echo \"✅ pip found: \$(\$PIP_CMD --version | head -n1)\"

# List installed packages
echo ''
echo '📦 Installed Python packages:'
\$PIP_CMD list --format=columns | head -20

echo ''
echo '🎉 pip and Python packages are ready!'
EOF
chmod +x '$VERIFY_SCRIPT'"
log_info "Created verification script: $VERIFY_SCRIPT"

log_success "🎉 Python package installation completed!"
log_info ""
log_info "📋 Summary:"
if [[ -n "$PACKAGES" ]]; then
    log_info "  • Packages installed: $PACKAGES"
fi
if [[ -n "$REQUIREMENTS" ]]; then
    log_info "  • Requirements file: $REQUIREMENTS"
fi
log_info "  • Upgrade mode: $UPGRADE"
if [[ -n "$EXTRA_ARGS" ]]; then
    log_info "  • Extra arguments: $EXTRA_ARGS"
fi
log_info "  • Verification script: $VERIFY_SCRIPT"
log_info ""
log_info "💡 Next steps:"
log_info "  1. Run 'verify-pip-packages' to check installed packages"
log_info "  2. Use 'pip list' to see all installed packages"
log_info "  3. Install additional packages with 'pip install <package>'"
