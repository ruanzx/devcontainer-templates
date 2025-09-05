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

# Remove existing Aspire workload if present (for .NET Aspire 9+)
log_info "Checking for existing .NET Aspire workload..."
if dotnet workload list | grep -q "aspire"; then
    log_warning "Found existing .NET Aspire workload. Removing to prevent conflicts..."
    dotnet workload uninstall aspire || log_warning "Failed to uninstall aspire workload (this may be expected)"
fi

# Install .NET Aspire project templates
log_info "Installing .NET Aspire project templates..."
if [[ "$VERSION" == "latest" ]]; then
    dotnet new install Aspire.ProjectTemplates
else
    dotnet new install "Aspire.ProjectTemplates::${VERSION}"
fi

# Verify installation
log_info "Verifying .NET Aspire template installation..."
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

log_success "🎉 .NET Aspire project templates installation complete!"
log_info ""
log_info "📋 Summary:"
log_info "  • .NET Aspire templates version: ${VERSION}"
log_info "  • Templates installed via: dotnet new install"
log_info "  • Verification script: $VERIFY_SCRIPT"
log_info ""
log_info "💡 Next steps:"
log_info "  1. Run 'verify-aspire' to check the installation"
log_info "  2. Create a new Aspire app: 'dotnet new aspire-starter -n MyApp'"
log_info "  3. Read the docs: https://learn.microsoft.com/en-us/dotnet/aspire/"