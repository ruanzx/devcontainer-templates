#!/bin/bash

# Demo script to show how to use the DevContainer Features
# This script creates example devcontainer configurations

set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env file if it exists
if [[ -f "$ROOT_DIR/.env" ]]; then
    source "$ROOT_DIR/.env"
fi

# Source common utilities
source "$ROOT_DIR/common/utils.sh"

# Configuration
EXAMPLES_DIR="$ROOT_DIR/examples"
FEATURES_NAMESPACE="${FEATURES_NAMESPACE:-ruanzx/devcontainer-features}"
GITHUB_REGISTRY="${GITHUB_REGISTRY:-ghcr.io}"

log_info "Creating DevContainer usage examples"

# Create examples directory
mkdir -p "$EXAMPLES_DIR"

# Example 1: Basic usage with all features
create_basic_example() {
    local example_dir="$EXAMPLES_DIR/basic-all-features"
    mkdir -p "$example_dir/.devcontainer"
    
    cat > "$example_dir/.devcontainer/devcontainer.json" << EOF
{
  "name": "Development Environment with All Features",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:microsoft-edit": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:kubectl": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:helm": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:k9s": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:skaffold": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:yq": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:gitleaks": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "redhat.vscode-yaml"
      ]
    }
  },
  "postCreateCommand": "echo 'DevContainer with all features ready!'",
  "remoteUser": "vscode"
}
EOF

    cat > "$example_dir/README.md" << EOF
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

\`\`\`bash
# Test the tools
edit --version
kubectl version --client
helm version
k9s version
skaffold version
yq --version
gitleaks version
\`\`\`
EOF

    log_success "Created basic example at: $example_dir"
}

# Example 2: Kubernetes development environment
create_k8s_example() {
    local example_dir="$EXAMPLES_DIR/kubernetes-dev"
    mkdir -p "$example_dir/.devcontainer"
    
    cat > "$example_dir/.devcontainer/devcontainer.json" << EOF
{
  "name": "Kubernetes Development Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:kubectl": {
      "version": "1.31.0"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:helm": {
      "version": "3.16.1"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:k9s": {
      "version": "0.32.7"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:skaffold": {
      "version": "2.16.1"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:yq": {
      "version": "4.44.3"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "redhat.vscode-yaml",
        "ms-vscode.vscode-docker"
      ]
    }
  },
  "forwardPorts": [8080, 3000],
  "postCreateCommand": "echo 'Kubernetes development environment ready!'",
  "remoteUser": "vscode"
}
EOF

    cat > "$example_dir/README.md" << EOF
# Kubernetes Development Environment

This example creates a complete Kubernetes development environment with essential tools.

## Features Included

- **Docker-in-Docker** - Run Docker commands inside the container
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **K9s** - Kubernetes cluster management UI
- **Skaffold** - Continuous development for Kubernetes
- **yq** - YAML processing

## Usage

1. Open this folder in VS Code
2. Choose "Reopen in Container"
3. Start a local Kubernetes cluster: \`minikube start\`
4. Use K9s for cluster management: \`k9s\`
5. Use Skaffold for development: \`skaffold dev\`

## Sample Commands

\`\`\`bash
# Check cluster status
kubectl cluster-info

# Install applications with Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-app bitnami/nginx

# Launch K9s dashboard
k9s

# Initialize Skaffold in your project
skaffold init

# Process YAML files
cat deployment.yaml | yq '.spec.replicas = 3'
\`\`\`
EOF

    log_success "Created Kubernetes example at: $example_dir"
}

# Example 3: Security-focused environment
create_security_example() {
    local example_dir="$EXAMPLES_DIR/security-tools"
    mkdir -p "$example_dir/.devcontainer"
    
    cat > "$example_dir/.devcontainer/devcontainer.json" << EOF
{
  "name": "Security Development Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:gitleaks": {
      "version": "8.21.1"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:yq": {
      "version": "4.44.3"
    },
    "$GITHUB_REGISTRY/$FEATURES_NAMESPACE:microsoft-edit": {
      "version": "1.2.0"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "redhat.vscode-yaml",
        "ms-vscode.vscode-json"
      ]
    }
  },
  "postCreateCommand": "gitleaks detect --verbose || echo 'Gitleaks scan complete'",
  "remoteUser": "vscode"
}
EOF

    cat > "$example_dir/README.md" << EOF
# Security Development Environment

This example focuses on security tools for development and auditing.

## Features Included

- **Gitleaks** - Detect secrets in git repositories
- **yq** - Secure YAML/JSON processing
- **Microsoft Edit** - Secure text editing
- **Git** - Version control with security focus

## Usage

1. Open this folder in VS Code
2. Choose "Reopen in Container"
3. Gitleaks will automatically scan the repository

## Security Commands

\`\`\`bash
# Scan for secrets in current repository
gitleaks detect --verbose

# Scan specific files
gitleaks detect --source myfile.py

# Create gitleaks config
gitleaks generate config

# Process sensitive YAML safely
yq '.password = "REDACTED"' config.yaml
\`\`\`
EOF

    log_success "Created security example at: $example_dir"
}

# Main function
main() {
    log_info "Creating usage examples"
    
    create_basic_example
    create_k8s_example
    create_security_example
    
    # Create main examples README
    cat > "$EXAMPLES_DIR/README.md" << EOF
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
2. Rename to \`.devcontainer\` or place the contents in your existing \`.devcontainer\` directory
3. Open your project in VS Code
4. Choose "Reopen in Container" when prompted

## Customization

You can customize any example by:
- Changing feature versions in the \`devcontainer.json\`
- Adding additional VS Code extensions
- Including additional features from the registry
- Modifying post-creation commands

## Available Features

- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:microsoft-edit\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:kubectl\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:helm\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:k9s\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:skaffold\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:yq\`
- \`$GITHUB_REGISTRY/$FEATURES_NAMESPACE:gitleaks\`

For more information, see the main [README.md](../README.md).
EOF

    log_success "All examples created successfully!"
    log_info "Examples available in: $EXAMPLES_DIR"
}

# Run main function
main "$@"
