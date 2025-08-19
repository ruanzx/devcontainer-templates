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

# Function to check if Python is available
check_python() {
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
        log_error "Python is required but not found. Please install Python first."
        log_info "This feature requires the Python devcontainer feature as a dependency."
        exit 1
    fi
}

# Function to check Python version
check_python_version() {
    local python_cmd="python3"
    if ! command -v python3 >/dev/null 2>&1; then
        python_cmd="python"
    fi
    
    local python_version
    python_version=$($python_cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    local required_version="3.10"
    
    if ! printf '%s\n%s\n' "$required_version" "$python_version" | sort -V | head -n1 | grep -q "^$required_version$"; then
        log_error "MarkItDown requires Python $required_version or higher. Found Python $python_version"
        exit 1
    fi
    
    log_info "Python $python_version detected - compatible with MarkItDown"
}

# Function to get pip command
get_pip_command() {
    if command -v pip3 >/dev/null 2>&1; then
        echo "pip3"
    elif command -v pip >/dev/null 2>&1; then
        echo "pip"
    else
        log_error "pip is required but not found"
        exit 1
    fi
}

# Function to install MarkItDown
install_markitdown() {
    local pip_cmd
    pip_cmd=$(get_pip_command)
    local install_spec="markitdown"
    
    # Handle version specification
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        install_spec="markitdown==$VERSION"
    fi
    
    # Handle extras specification
    if [ "$EXTRAS" != "none" ] && [ -n "$EXTRAS" ]; then
        install_spec="${install_spec}[${EXTRAS}]"
    fi
    
    log_info "Installing MarkItDown with: $pip_cmd install '$install_spec'"
    
    # Install MarkItDown
    if ! $pip_cmd install "$install_spec"; then
        log_error "Failed to install MarkItDown"
        exit 1
    fi
    
    log_success "MarkItDown installed successfully"
}

# Function to verify installation
verify_installation() {
    if command -v markitdown >/dev/null 2>&1; then
        local version
        version=$(markitdown --version 2>/dev/null || echo "unknown")
        log_success "MarkItDown CLI is available (version: $version)"
    else
        log_warning "MarkItDown CLI not found in PATH"
    fi
    
    # Test Python import
    local python_cmd="python3"
    if ! command -v python3 >/dev/null 2>&1; then
        python_cmd="python"
    fi
    
    if $python_cmd -c "import markitdown; print('MarkItDown Python module is available')" 2>/dev/null; then
        log_success "MarkItDown Python module is importable"
    else
        log_error "MarkItDown Python module cannot be imported"
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
    
    # Check prerequisites
    check_python
    check_python_version
    
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
