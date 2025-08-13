# DevContainer Features Usage Examples

This directory contains example devcontainer configurations demonstrating how to use the available features.

## Examples

### [Basic All Features](basic-all-features/)
Demonstrates how to use all available features in a single devcontainer.

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

- `ghcr.io/ruanzx/devcontainer-features:microsoft-edit`
- `ghcr.io/ruanzx/devcontainer-features:kubectl`
- `ghcr.io/ruanzx/devcontainer-features:helm`
- `ghcr.io/ruanzx/devcontainer-features:k9s`
- `ghcr.io/ruanzx/devcontainer-features:skaffold`
- `ghcr.io/ruanzx/devcontainer-features:yq`
- `ghcr.io/ruanzx/devcontainer-features:gitleaks`

For more information, see the main [README.md](../README.md).
