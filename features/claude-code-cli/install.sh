#!/bin/bash

# Install Claude Code CLI - AI-powered coding assistant by Anthropic
# https://docs.anthropic.com/en/docs/claude-code/setup

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
VERSION="${VERSION:-"latest"}"
INSTALL_METHOD="${INSTALLMETHOD:-"npm"}"
INSTALL_GLOBALLY="${INSTALLGLOBALLY:-"true"}"

log_info "Installing Claude Code CLI ${VERSION} using ${INSTALL_METHOD} method"

# Detect system OS and architecture
OS=$(get_os)
ARCH=$(get_architecture)

if [[ "$OS" != "linux" ]]; then
    log_error "Claude Code CLI feature currently only supports Linux"
    log_info "For other platforms, see: https://docs.anthropic.com/en/docs/claude-code/setup"
    exit 1
fi

# Check system requirements
log_info "Checking system requirements"

# Ensure required tools for both installation methods
ensure_command "curl"

# Install method-specific requirements and installation
case "$INSTALL_METHOD" in
    "npm")
        log_info "Using npm installation method"
        
        # Check if Node.js is available (required for npm)
        if ! command_exists node; then
            log_error "Node.js is required for npm installation method"
            log_info "Please install Node.js 18+ or use the Node.js DevContainer feature"
            exit 1
        fi

        # Check if npm is available
        if ! command_exists npm; then
            log_error "npm is required for npm installation method"
            log_info "Please install npm or use the Node.js DevContainer feature"
            exit 1
        fi

        # Check Node.js version (requires 18+)
        NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$NODE_VERSION" -lt 18 ]]; then
            log_warning "Node.js 18+ is required for Claude Code CLI (detected: $(node --version))"
            log_info "Consider upgrading Node.js for optimal compatibility"
        fi

        # Install Claude Code CLI via npm
        if [[ "$INSTALL_GLOBALLY" == "true" ]]; then
            log_info "Installing Claude Code CLI globally using npm"
            
            # Use npm install with proper package name
            if npm install -g @anthropic-ai/claude-code; then
                log_success "Claude Code CLI installed successfully using npm"
            else
                log_error "Failed to install Claude Code CLI using npm"
                exit 1
            fi
        else
            log_info "Skipping global installation (installGlobally=false)"
            log_info "You can install Claude Code CLI locally with: npm install @anthropic-ai/claude-code"
        fi
        ;;
        
    "native")
        log_info "Using native binary installation method (beta)"
        
        # Check architecture support for native installation
        case "$ARCH" in
            "x86_64"|"amd64")
                ARCH_SUPPORTED=true
                ;;
            "aarch64"|"arm64")
                ARCH_SUPPORTED=true
                ;;
            *)
                log_warning "Architecture $ARCH may not be supported for native installation"
                ARCH_SUPPORTED=false
                ;;
        esac

        if [[ "$ARCH_SUPPORTED" != "true" ]]; then
            log_warning "Falling back to npm installation method"
            INSTALL_METHOD="npm"
            # Retry with npm method
            exec bash "$0"
        fi

        # Install native binary
        log_info "Downloading Claude Code CLI native installer"
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Download and run native installer
        case "$VERSION" in
            "latest")
                INSTALL_SCRIPT_URL="https://claude.ai/install.sh"
                INSTALL_ARGS="latest"
                ;;
            "stable")
                INSTALL_SCRIPT_URL="https://claude.ai/install.sh"
                INSTALL_ARGS=""  # Default is stable
                ;;
            *)
                INSTALL_SCRIPT_URL="https://claude.ai/install.sh"
                INSTALL_ARGS="$VERSION"
                ;;
        esac
        
        log_info "Downloading installer from $INSTALL_SCRIPT_URL"
        if download_file "$INSTALL_SCRIPT_URL" "install.sh"; then
            chmod +x install.sh
            if [[ -n "$INSTALL_ARGS" ]]; then
                bash install.sh "$INSTALL_ARGS"
            else
                bash install.sh
            fi
            log_success "Claude Code CLI native installation completed"
        else
            log_error "Failed to download Claude Code CLI native installer"
            log_info "Falling back to npm installation method"
            cd /
            cleanup_temp "$TEMP_DIR"
            
            # Fallback to npm
            INSTALL_METHOD="npm"
            exec bash "$0"
        fi
        
        # Cleanup
        cd /
        cleanup_temp "$TEMP_DIR"
        ;;
        
    *)
        log_error "Invalid installation method: $INSTALL_METHOD"
        log_info "Supported methods: npm, native"
        exit 1
        ;;
esac

# Verify installation
log_info "Verifying Claude Code CLI installation"

if command_exists claude; then
    # Test that claude command works with timeout
    log_info "Testing claude command functionality"
    if timeout 5s claude --version > /dev/null 2>&1; then
        INSTALLED_VERSION=$(timeout 5s claude --version 2>/dev/null | head -n1 || echo "version unknown")
        log_success "Claude Code CLI installed successfully: $INSTALLED_VERSION"
        
        # Run basic diagnostics check (skip interactive doctor command)
        log_info "Running basic installation verification"
        if timeout 5s claude --help > /dev/null 2>&1; then
            log_success "Installation verification passed"
            log_info "Run 'claude doctor' manually for detailed diagnostics"
        else
            log_warning "Installation verification had warnings - try running 'claude doctor' manually"
        fi
    else
        log_error "Claude Code CLI installation failed - command exists but not working properly or timed out"
        log_info "Try running 'claude --version' manually to debug"
        exit 1
    fi
else
    log_error "Claude Code CLI installation failed - command not found"
    log_info "You may need to restart your shell or check your PATH"
    exit 1
fi

log_info "Claude Code CLI installation completed"
log_info ""
log_info "🚀 Getting started:"
log_info "  1. Navigate to your project: cd your-awesome-project"
log_info "  2. Start Claude Code: claude"
log_info "  3. Follow authentication prompts (requires billing at console.anthropic.com)"
log_info "  4. Run diagnostics: claude doctor"
log_info ""
log_info "📚 Authentication options:"
log_info "  - Anthropic Console: Default option (requires active billing)"
log_info "  - Claude Pro/Max plan: Unified subscription for Claude.ai + Claude Code"
log_info "  - Enterprise: Amazon Bedrock or Google Vertex AI integration"
log_info ""
log_info "📖 For detailed setup and usage, see:"
log_info "  - Setup guide: https://docs.anthropic.com/en/docs/claude-code/setup"
log_info "  - Troubleshooting: https://docs.anthropic.com/en/docs/claude-code/troubleshooting"
