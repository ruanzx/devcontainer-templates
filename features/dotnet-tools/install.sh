#!/bin/bash

# Install .NET Global Tools
# Allows installation of custom .NET global tools

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
TOOLS="${TOOLS:-"dotnet-format@latest"}"
PRERELEASE="${PRERELEASE:-"false"}"

log_info "Installing .NET Global Tools"

# Check if .NET is installed
if ! command_exists dotnet; then
    log_error ".NET SDK is required but not found"
    log_info "Please install the .NET SDK feature first: ghcr.io/devcontainers/features/dotnet"
    exit 1
fi

# Display .NET version
DOTNET_VERSION=$(dotnet --version)
log_info "Using .NET SDK version: $DOTNET_VERSION"

# Function to install a single tool
install_dotnet_tool() {
    local tool_spec="$1"
    local tool_name
    local tool_version
    
    # Parse tool@version format
    if [[ "$tool_spec" == *"@"* ]]; then
        tool_name="${tool_spec%@*}"
        tool_version="${tool_spec#*@}"
    else
        tool_name="$tool_spec"
        tool_version="latest"
    fi
    
    log_info "Installing .NET tool: $tool_name (version: $tool_version)"
    
    # Build install command
    local install_cmd="dotnet tool install --global"
    
    # Add prerelease flag if requested
    if [[ "$PRERELEASE" == "true" ]]; then
        install_cmd="$install_cmd --prerelease"
    fi
    
    # Add version specification if not latest
    if [[ "$tool_version" != "latest" ]]; then
        install_cmd="$install_cmd --version $tool_version"
    fi
    
    # Add tool name
    install_cmd="$install_cmd $tool_name"
    
    # Execute installation
    if eval "$install_cmd"; then
        log_success "Successfully installed: $tool_name"
        
        # Verify installation with generic approach
        if command_exists "$tool_name"; then
            local installed_version="installed"
            
            # Try common version commands for .NET tools
            if command -v "$tool_name" --version >/dev/null 2>&1; then
                installed_version=$("$tool_name" --version 2>/dev/null | head -n1 || echo "unknown")
            elif command -v "$tool_name" -v >/dev/null 2>&1; then
                installed_version=$("$tool_name" -v 2>/dev/null | head -n1 || echo "unknown")
            elif command -v "$tool_name" version >/dev/null 2>&1; then
                installed_version=$("$tool_name" version 2>/dev/null | head -n1 || echo "unknown")
            fi
            
            log_info "Verified installation: $tool_name ($installed_version)"
        fi
    else
        log_error "Failed to install: $tool_name"
        return 1
    fi
}

# Parse and install tools
IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
FAILED_TOOLS=()

for tool_spec in "${TOOL_LIST[@]}"; do
    # Trim whitespace
    tool_spec=$(echo "$tool_spec" | xargs)
    
    if [[ -n "$tool_spec" ]]; then
        if ! install_dotnet_tool "$tool_spec"; then
            FAILED_TOOLS+=("$tool_spec")
        fi
    fi
done

# Report results
if [[ ${#FAILED_TOOLS[@]} -eq 0 ]]; then
    log_success "All .NET tools installed successfully!"
    
    # List installed global tools
    log_info "Currently installed global tools:"
    dotnet tool list --global | grep -v "Package Id" | grep -v "^-" || log_info "No tools listed"
    
else
    log_error "Failed to install ${#FAILED_TOOLS[@]} tools: ${FAILED_TOOLS[*]}"
    log_info "Successfully installed tools are still available"
    exit 1
fi

# Add .NET tools to PATH if not already in .bashrc
DOTNET_TOOLS_PATH="$HOME/.dotnet/tools"
if ! grep -q "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" ~/.bashrc 2>/dev/null; then
    log_info "Adding .NET tools to PATH: $DOTNET_TOOLS_PATH"
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.bashrc
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
fi
export PATH="$DOTNET_TOOLS_PATH:$PATH"

log_info ".NET Global Tools installation completed"
