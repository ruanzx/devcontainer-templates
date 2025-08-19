#!/bin/bash

# Install MarkItDown - utility for converting various files to Markdown
# https://github.com/microsoft/markitdown

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
elif [ -f "${SCRIPT_DIR}/../../common/utils.sh" ]; then
    source "${SCRIPT_DIR}/../../common/utils.sh"
fi

# Get options
VERSION=${VERSION:-"latest"}
EXTRAS=${EXTRAS:-"all"}
ENABLE_PLUGINS=${ENABLEPLUGINS:-"false"}
INSTALL_SYSTEM_DEPS=${INSTALLSYSTEMDEPS:-"true"}

# Function to check if Python is available
check_python() {
    local python_cmd=""
    
    # Try to find Python command
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        log_error "Python is required but not found. Please install Python first."
        log_info "This feature requires the Python devcontainer feature as a dependency."
        log_info "Add 'ghcr.io/devcontainers/features/python:1' to your devcontainer.json features."
        exit 1
    fi
    
    log_info "Found Python command: $python_cmd"
}

# Function to check Python version
check_python_version() {
    local python_cmd=""
    
    # Find the best Python command
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        log_error "No Python command found"
        exit 1
    fi
    
    # Check if this is actually Python 3
    if ! $python_cmd -c "import sys; assert sys.version_info[0] >= 3" 2>/dev/null; then
        log_error "Python 3 is required but $python_cmd appears to be Python 2"
        exit 1
    fi
    
    local python_version
    python_version=$($python_cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    local required_version="3.10"
    
    if [ -z "$python_version" ]; then
        log_error "Could not determine Python version"
        exit 1
    fi
    
    # Compare versions using sort -V
    if ! printf '%s\n%s\n' "$required_version" "$python_version" | sort -V | head -n1 | grep -q "^$required_version$"; then
        log_error "MarkItDown requires Python $required_version or higher. Found Python $python_version"
        log_info "Please use a newer Python version or update your Python devcontainer feature."
        exit 1
    fi
    
    log_info "Python $python_version detected - compatible with MarkItDown"
}

# Function to get pip command
get_pip_command() {
    local pip_cmd=""
    
    # Try different pip commands in order of preference
    if command -v pip3 >/dev/null 2>&1; then
        pip_cmd="pip3"
    elif command -v pip >/dev/null 2>&1; then
        pip_cmd="pip"
    else
        log_error "pip is required but not found"
        log_info "Make sure pip is installed with your Python installation."
        exit 1
    fi
    
    # Verify pip works
    if ! $pip_cmd --version >/dev/null 2>&1; then
        log_error "pip command '$pip_cmd' is not working properly"
        exit 1
    fi
    
    echo "$pip_cmd"
}

# Function to install system dependencies
install_system_dependencies() {
    # Skip if system dependencies installation is disabled
    if [ "$INSTALL_SYSTEM_DEPS" != "true" ]; then
        log_info "System dependencies installation is disabled"
        return 0
    fi
    
    local needs_ffmpeg=false
    local needs_poppler=false
    local needs_tesseract=false
    
    # Check if we need system dependencies based on extras
    if [ "$EXTRAS" = "all" ]; then
        # When "all" is specified, we need both ffmpeg and poppler
        needs_ffmpeg=true
        needs_poppler=true
    else
        # Check for specific extras
        if [[ "$EXTRAS" == *"audio-transcription"* ]]; then
            needs_ffmpeg=true
        fi
        
        if [[ "$EXTRAS" == *"pdf"* ]]; then
            needs_poppler=true
        fi
    fi
    
    # Only install system dependencies if we have apt and they're needed
    if [ "$needs_ffmpeg" = true ] || [ "$needs_poppler" = true ] || [ "$needs_tesseract" = true ]; then
        if command -v apt-get >/dev/null 2>&1; then
            log_info "Installing system dependencies for MarkItDown extras..."
            
            # Update package list
            apt-get update -q >/dev/null 2>&1 || log_warning "Failed to update package list"
            
            local packages_to_install=""
            
            if [ "$needs_ffmpeg" = true ]; then
                packages_to_install="$packages_to_install ffmpeg"
                log_info "  - ffmpeg (for audio processing)"
            fi
            
            if [ "$needs_poppler" = true ]; then
                packages_to_install="$packages_to_install poppler-utils"
                log_info "  - poppler-utils (for PDF processing)"
            fi
            
            if [ -n "$packages_to_install" ]; then
                # Install packages quietly
                if apt-get install -y -q $packages_to_install >/dev/null 2>&1; then
                    log_success "System dependencies installed successfully"
                else
                    log_warning "Some system dependencies failed to install - MarkItDown will still work but some features may be limited"
                fi
                
                # Clean up to reduce image size
                apt-get autoremove -y -q >/dev/null 2>&1 || true
                apt-get autoclean -q >/dev/null 2>&1 || true
                rm -rf /var/lib/apt/lists/* 2>/dev/null || true
            fi
        else
            log_info "APT not available - skipping system dependency installation"
            log_info "Some MarkItDown features may show warnings about missing system dependencies"
        fi
    else
        log_info "No system dependencies needed for current extras configuration"
    fi
}
install_markitdown() {
    local pip_cmd
    pip_cmd=$(get_pip_command)
    local install_spec="markitdown"
    
    log_info "Using pip command: $pip_cmd"
    
    # Handle version specification
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        install_spec="markitdown==$VERSION"
        log_info "Installing specific version: $VERSION"
    else
        log_info "Installing latest version"
    fi
    
    # Handle extras specification
    if [ "$EXTRAS" != "none" ] && [ -n "$EXTRAS" ]; then
        install_spec="${install_spec}[${EXTRAS}]"
        log_info "Including extras: $EXTRAS"
    fi
    
    log_info "Final install specification: $install_spec"
    log_info "Running: $pip_cmd install '$install_spec'"
    
    # Install MarkItDown with explicit error handling
    if $pip_cmd install "$install_spec"; then
        log_success "MarkItDown installed successfully"
    else
        local exit_code=$?
        log_error "Failed to install MarkItDown (exit code: $exit_code)"
        log_info "This might be due to:"
        log_info "  - Network connectivity issues"
        log_info "  - Missing system dependencies"
        log_info "  - Incompatible Python version"
        log_info "  - Invalid version or extras specification"
        exit 1
    fi
}

# Function to verify installation
verify_installation() {
    log_info "Verifying MarkItDown installation..."
    
    # Check CLI availability
    if command -v markitdown >/dev/null 2>&1; then
        local version
        version=$(markitdown --version 2>/dev/null || echo "unknown")
        log_success "MarkItDown CLI is available (version: $version)"
    else
        log_warning "MarkItDown CLI not found in PATH"
        log_info "The CLI might not be available, but the Python module should still work"
    fi
    
    # Test Python import - this is the critical test
    local python_cmd=""
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        log_error "No Python command found for verification"
        exit 1
    fi
    
    log_info "Testing Python import with: $python_cmd"
    
    if $python_cmd -c "import markitdown; print('MarkItDown Python module is available')" 2>/dev/null; then
        log_success "MarkItDown Python module is importable"
        
        # Test basic functionality
        if $python_cmd -c "from markitdown import MarkItDown; md = MarkItDown(); print('MarkItDown instance created successfully')" 2>/dev/null; then
            log_success "MarkItDown functionality test passed"
        else
            log_warning "MarkItDown module imports but may have issues with instantiation"
        fi
    else
        log_error "MarkItDown Python module cannot be imported"
        log_info "This indicates the installation failed or there are missing dependencies"
        
        # Try to get more details about the error
        log_info "Attempting to get detailed error information..."
        $python_cmd -c "import markitdown" 2>&1 | head -10 | while read -r line; do
            log_error "Python error: $line"
        done
        
        exit 1
    fi
}

# Function to display usage information
display_usage_info() {
    echo ""
    log_info "MarkItDown has been installed!"
    echo ""
    echo "📚 Usage Examples:"
    echo "  • Convert a file to Markdown:"
    echo "    markitdown document.pdf > output.md"
    echo ""
    echo "  • Use with output file:"
    echo "    markitdown document.docx -o output.md"
    echo ""
    echo "  • Python API usage:"
    echo "    from markitdown import MarkItDown"
    echo "    md = MarkItDown()"
    echo "    result = md.convert('document.pdf')"
    echo "    print(result.text_content)"
    echo ""
    
    if [ "$ENABLE_PLUGINS" = "true" ]; then
        echo "  • Plugins are enabled by default"
        echo "    markitdown --list-plugins"
        echo "    markitdown --use-plugins document.pdf"
        echo ""
    fi
    
    echo "🔧 Configuration:"
    echo "  • Version: $([ "$VERSION" = "latest" ] && echo "latest" || echo "$VERSION")"
    echo "  • Extras: $EXTRAS"
    echo "  • Plugins enabled: $ENABLE_PLUGINS"
    echo ""
    echo "📖 For more information: https://github.com/microsoft/markitdown"
}

# Main execution
main() {
    log_info "🚀 Installing MarkItDown..."
    
    # Display configuration
    log_info "Configuration:"
    log_info "  - Version: $VERSION"
    log_info "  - Extras: $EXTRAS"
    log_info "  - Enable Plugins: $ENABLE_PLUGINS"
    log_info "  - Install System Dependencies: $INSTALL_SYSTEM_DEPS"
    
    # Display environment info for debugging
    log_info "Environment info:"
    log_info "  - PATH: $PATH"
    log_info "  - USER: ${USER:-unknown}"
    log_info "  - PWD: $(pwd)"
    
    # Check prerequisites
    check_python
    check_python_version
    
    # Install system dependencies if needed
    install_system_dependencies
    
    # Install MarkItDown
    install_markitdown
    
    # Verify installation
    verify_installation
    
    # Display usage information
    display_usage_info
    
    log_success "✅ MarkItDown installation completed!"
}

# Run main function
main
