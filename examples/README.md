# DevContainer Features Usage Examples

This directory contains example devcontainer configurations demonstrating how to use the available features.

## Examples

### [Basic All Features](basic-all-features/)
Demonstrates how to use all available features in a single devcontainer.

### [.NET Development](dotnet-dev/)
Complete .NET development environment with Entity Framework, code formatting, and analysis tools.

### [Kubernetes Development](kubernetes-dev/)
Complete Kubernetes development environment with K9s, Skaffold, and related tools.

### [Security Tools](security-tools/)
Security-focused environment with Gitleaks and other security tools.

## Quick Start

1. Copy any example directory to your project
2. Rename to `.devcontainer` or place the contents in your existing `.devcontainer` directory
3. Open your project in VS Code
4. Choose "Reopen in Container" when prompted

## Customization

You can customize any example by:
- Changing feature versions in the `devcontainer.json`
- Adding additional VS Code extensions
- Including additional features from the registry
- Modifying post-creation commands

## Available Features

- `ghcr.io/ruanzx/features/devcontainers-cli` - DevContainers CLI tools
- `ghcr.io/ruanzx/features/dotnet-tools` - .NET Global Tools (Entity Framework, formatters, etc.)
- `ghcr.io/ruanzx/features/gitleaks` - Secret detection and prevention
- `ghcr.io/ruanzx/features/helm` - Kubernetes package manager
- `ghcr.io/ruanzx/features/k9s` - Kubernetes terminal UI
- `ghcr.io/ruanzx/features/kubectl` - Kubernetes command-line tool
- `ghcr.io/ruanzx/features/microsoft-edit` - Microsoft's modern text editor
- `ghcr.io/ruanzx/features/skaffold` - Kubernetes development workflow tool
- `ghcr.io/ruanzx/features/yq` - YAML/JSON/XML processor

For more information, see the main [README.md](../README.md).
