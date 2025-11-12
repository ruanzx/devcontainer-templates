#!/bin/bash

# Install dotnet tools
dotnet tool install --global dotnet-ef
dotnet tool install --global dotnet-format
dotnet tool install --global dotnet-outdated-tool
dotnet tool install --global dotnet-sonarscanner
dotnet tool install --global dotnet-script
dotnet tool install --global Microsoft.OpenApi.Kiota

# Add .NET tools to PATH if not already in .bashrc
DOTNET_TOOLS_PATH="$HOME/.dotnet/tools"
if ! grep -q "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" ~/.bashrc 2>/dev/null; then
    echo "Adding .NET tools to PATH: $DOTNET_TOOLS_PATH"
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.bashrc
    echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
fi
export PATH="$DOTNET_TOOLS_PATH:$PATH"
