#!/bin/bash

# Main entry script for DevContainer Features development
# This script provides a unified interface for common operations

set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env file if it exists
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    source "$SCRIPT_DIR/.env"
fi

# Source common utilities
source "$SCRIPT_DIR/common/utils.sh"

# Show usage information
usage() {
    echo "DevContainer Features Development Tool"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build      Build all features"
    echo "  test       Run tests (syntax, features, or all)"
    echo "  publish    Publish features to GitHub Container Registry"
    echo "  clean      Clean build artifacts"
    echo "  setup      Set up development environment"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                    # Build all features"
    echo "  $0 test syntax              # Run syntax tests only"
    echo "  $0 test features            # Run feature tests only"
    echo "  $0 test                     # Run all tests"
    echo "  $0 publish                  # Publish all features to registry"
    echo "  $0 publish kubectl helm     # Publish only kubectl and helm features"
    echo "  $0 publish --list           # List available features"
    echo "  $0 publish --private apt    # Publish apt feature as private"
    echo "  $0 clean                    # Clean build directory"
    echo "  $0 setup                    # Set up development environment"
    echo ""
}

# Set up development environment
setup() {
    log_info "Setting up development environment"
    
    # Check if .env exists
    if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
        log_info "Creating .env file from template"
        cp "$SCRIPT_DIR/.env.sample" "$SCRIPT_DIR/.env"
        log_warning "Please edit .env file and add your GitHub token"
    fi
    
    # Make scripts executable
    log_info "Making scripts executable"
    chmod +x "$SCRIPT_DIR/scripts"/*.sh
    chmod +x "$SCRIPT_DIR/features/*/install.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/common/utils.sh"
    
    # Check prerequisites
    log_info "Checking prerequisites"
    
    local missing_tools=()
    
    if ! command_exists docker; then
        missing_tools+=("docker")
    fi
    
    if ! command_exists jq; then
        missing_tools+=("jq")
    fi
    
    if ! command_exists curl; then
        missing_tools+=("curl")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and run setup again"
        exit 1
    fi
    
    log_success "Development environment set up successfully"
    log_info "Next steps:"
    log_info "1. Edit .env file and add your GitHub token"
    log_info "2. Run: $0 build"
    log_info "3. Run: $0 test"
    log_info "4. Run: $0 publish"
}

# Clean build artifacts
clean() {
    log_info "Cleaning build artifacts"
    
    if [[ -d "$SCRIPT_DIR/build" ]]; then
        rm -rf "$SCRIPT_DIR/build"
        log_success "Removed build directory"
    else
        log_info "Build directory already clean"
    fi
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "build")
            exec "$SCRIPT_DIR/scripts/build.sh" "${@:2}"
            ;;
        "test")
            exec "$SCRIPT_DIR/scripts/test.sh" "${@:2}"
            ;;
        "publish")
            exec "$SCRIPT_DIR/scripts/publish.sh" "${@:2}"
            ;;
        "clean")
            clean
            ;;
        "setup")
            setup
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
