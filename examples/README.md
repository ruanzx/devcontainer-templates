# DevContainer Features Usage Examples

This directory contains example devcontainer configurations demonstrating how to use the available features.

## Examples

### [Basic All Features](basic-all-features/)
Demonstrates how to use all available features in a single devcontainer.

### [.NET Development](dotnet-dev/)
Complete .NET development environment with Entity Framework, code formatting, and analysis tools.

### [Performance Testing](performance-testing/)
Performance testing environment with k6 for load testing and performance analysis.

### [Terraform Development](terraform-dev/)
Terraform development environment with terraform-docs for generating module documentation.

### [Infrastructure Import](infrastructure-import/)
Infrastructure import environment with Terraformer for bringing existing cloud resources under Terraform management.

### [Serverless Development](serverless-development/)
Serverless development environment with AWS SAM CLI for building and deploying serverless applications.

### [Security Scanning](security-scanning/)
Comprehensive security scanning environment with Trivy and Gitleaks for vulnerability detection and secret scanning.

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

- `ghcr.io/ruanzx/features/aws-sam-cli` - AWS Serverless Application Model CLI for building and deploying serverless applications
- `ghcr.io/ruanzx/features/devcontainers-cli` - DevContainers CLI tools
- `ghcr.io/ruanzx/features/dotnet-tools` - .NET Global Tools (Entity Framework, formatters, etc.)
- `ghcr.io/ruanzx/features/gitleaks` - Secret detection and prevention
- `ghcr.io/ruanzx/features/helm` - Kubernetes package manager
- `ghcr.io/ruanzx/features/k6` - Modern load testing tool
- `ghcr.io/ruanzx/features/k9s` - Kubernetes terminal UI
- `ghcr.io/ruanzx/features/kubectl` - Kubernetes command-line tool
- `ghcr.io/ruanzx/features/microsoft-edit` - Microsoft's modern text editor
- `ghcr.io/ruanzx/features/skaffold` - Kubernetes development workflow tool
- `ghcr.io/ruanzx/features/terraform-docs` - Generate documentation from Terraform modules
- `ghcr.io/ruanzx/features/terraformer` - Generate Terraform files from existing infrastructure (reverse Terraform)
- `ghcr.io/ruanzx/features/trivy` - Comprehensive security scanner for vulnerabilities in containers, file systems, and repositories
- `ghcr.io/ruanzx/features/yq` - YAML/JSON/XML processor

For more information, see the main [README.md](../README.md).
