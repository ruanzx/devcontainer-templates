#!/bin/bash

# Install .NET Aspire project templates
# https://learn.microsoft.com/en-us/dotnet/aspire/

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
VERSION="${VERSION:-"9.4.0"}"

log_info "Installing .NET Aspire project templates v${VERSION}"

# Validate version
validate_version "$VERSION"

# Check if .NET CLI is available
if ! command_exists dotnet; then
    log_error ".NET CLI is required but not found. Please install .NET SDK first."
    log_info "Install the dotnet feature before this feature:"
    log_info "  \"ghcr.io/devcontainers/features/dotnet\": {}"
    exit 1
fi

# Get .NET version
DOTNET_VERSION=$(dotnet --version 2>/dev/null || echo "unknown")
log_info "Found .NET CLI version: ${DOTNET_VERSION}"

# Check if .NET 8.0 or later is available
DOTNET_MAJOR_VERSION=$(echo "$DOTNET_VERSION" | cut -d'.' -f1)
if [[ "$DOTNET_MAJOR_VERSION" -lt 8 ]]; then
    log_warning ".NET Aspire requires .NET 8.0 or later. Current version: ${DOTNET_VERSION}"
    log_info "Please ensure .NET 8.0+ is installed"
fi

# Install .NET Aspire workload (includes the aspire CLI command)
log_info "Installing .NET Aspire workload..."
if dotnet workload install aspire; then
    log_success ".NET Aspire workload installed successfully"
else
    log_error "Failed to install .NET Aspire workload"
    exit 1
fi

# Install .NET Aspire project templates
log_info "Installing .NET Aspire project templates..."
if [[ "$VERSION" == "latest" ]]; then
    dotnet new install Aspire.ProjectTemplates --force
else
    dotnet new install "Aspire.ProjectTemplates::${VERSION}" --force
fi

# Verify installation
log_info "Verifying .NET Aspire installation..."

# Check workload installation
if dotnet workload list | grep -q "aspire"; then
    log_success ".NET Aspire workload installed successfully"
else
    log_warning ".NET Aspire workload may not be properly installed"
fi

# Check templates
if dotnet new list aspire >/dev/null 2>&1; then
    TEMPLATE_COUNT=$(dotnet new list aspire | grep -c "aspire" || echo "0")
    log_success ".NET Aspire templates installed successfully"
    log_info "Found ${TEMPLATE_COUNT} Aspire templates"
    
    # List available templates
    log_info "Available .NET Aspire templates:"
    dotnet new list aspire | tail -n +3 | while read -r line; do
        if [[ -n "$line" ]]; then
            log_info "  • $line"
        fi
    done
else
    log_error ".NET Aspire template installation failed"
    exit 1
fi

# Add dotnet tools to PATH if not already there (aspire CLI is installed as a dotnet tool)
DOTNET_TOOLS_PATH="$HOME/.dotnet/tools"
if [[ ":$PATH:" != *":$DOTNET_TOOLS_PATH:"* ]]; then
    log_info "Adding .NET tools to PATH: $DOTNET_TOOLS_PATH"
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.bashrc
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
    export PATH="$DOTNET_TOOLS_PATH:$PATH"
fi

# Create verification script
VERIFY_SCRIPT="/usr/local/bin/verify-aspire"
cat > "$VERIFY_SCRIPT" << 'EOF'
#!/bin/bash
echo "🔍 Verifying .NET Aspire installation..."

# Check .NET CLI
if ! command -v dotnet >/dev/null 2>&1; then
    echo "❌ .NET CLI not found"
    exit 1
fi

echo "✅ .NET CLI found: $(dotnet --version)"

# Check Aspire workload
if dotnet workload list | grep -q "aspire"; then
    echo "✅ .NET Aspire workload installed"
else
    echo "⚠️  .NET Aspire workload not found"
fi

# Check aspire command
if command -v aspire >/dev/null 2>&1; then
    echo "✅ aspire command available: $(aspire --version 2>/dev/null || echo 'version check not supported')"
else
    echo "⚠️  aspire command not found in PATH"
    echo "   Try: source ~/.bashrc or restart your shell"
fi

# Check Aspire templates
if dotnet new list aspire >/dev/null 2>&1; then
    TEMPLATE_COUNT=$(dotnet new list aspire | grep -c "aspire" || echo "0")
    echo "✅ .NET Aspire templates installed (${TEMPLATE_COUNT} templates)"
    echo ""
    echo "📋 Available templates:"
    dotnet new list aspire | tail -n +3
else
    echo "❌ .NET Aspire templates not found"
    exit 1
fi

echo ""
echo "🎉 .NET Aspire is ready!"
echo "📖 Get started: https://learn.microsoft.com/en-us/dotnet/aspire/get-started/build-your-first-aspire-app"
EOF

chmod +x "$VERIFY_SCRIPT"
log_info "Created verification script: $VERIFY_SCRIPT"

log_success "🎉 .NET Aspire installation complete!"
log_info ""
log_info "📋 Summary:"
log_info "  • .NET Aspire workload installed (includes 'aspire' command)"
log_info "  • .NET Aspire templates version: ${VERSION}"
log_info "  • Templates installed via: dotnet new install"
log_info "  • Verification script: $VERIFY_SCRIPT"
log_info ""
log_info "💡 Next steps:"
log_info "  1. Run 'source ~/.bashrc' to update PATH in current session"
log_info "  2. Run 'verify-aspire' to check the installation"
log_info "  3. Run 'aspire --help' to see available commands"
log_info "  4. Create a new Aspire app: 'dotnet new aspire-starter -n MyApp'"
log_info "  5. Read the docs: https://learn.microsoft.com/en-us/dotnet/aspire/"