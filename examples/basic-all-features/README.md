# Basic DevContainer with All Features

This example shows how to use all available features in a single devcontainer.

## Features Included

- **Microsoft Edit** - Fast text editor
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **K9s** - Kubernetes cluster management
- **Skaffold** - Kubernetes development workflow
- **yq** - YAML/JSON processor
- **Gitleaks** - Secret detection

## Usage

1. Open this folder in VS Code
2. Choose "Reopen in Container" when prompted
3. Wait for the container to build
4. All tools will be available in the terminal

## Testing

```bash
# Test the tools
edit --version
kubectl version --client
helm version
k9s version
skaffold version
yq --version
gitleaks version
```
