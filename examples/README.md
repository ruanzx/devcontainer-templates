# DevContainer Features Usage Examples

This directory contains example devcontainer configurations demonstrating how to use the available features.

## Examples

### [APT Package Management](apt-packages/)
Demonstrates how to install custom system packages using the APT package manager.

### [Azure Functions Development](azure-functions-core-tools/)
Complete Azure Functions development environment with Azure Functions Core Tools supporting multiple programming languages.

### [Basic All Features](basic-all-features/)
Demonstrates how to use all available features in a single devcontainer.

### [Web Development with Tunneling](web-development-tunneling/)
Modern web development environment with ngrok tunneling for external access, webhooks, and mobile testing.

### [.NET Development](dotnet-dev/)
Complete .NET development environment with Entity Framework, code formatting, and analysis tools.

### [Performance Testing](performance-testing/)
Performance testing environment with k6 for load testing and performance analysis.

### [Terraform Development](terraform-dev/)
Terraform development environment with terraform-docs for generating module documentation and additional utility packages.

### [Infrastructure Import](infrastructure-import/)
Infrastructure import environment with Terraformer for bringing existing cloud resources under Terraform management.

### [Serverless Development](serverless-development/)
Serverless development environment with AWS SAM CLI for building and deploying serverless applications.

### [Security Scanning](security-scanning/)
Comprehensive security scanning environment with Trivy and Gitleaks for vulnerability detection and secret scanning.

### [Kubernetes Development](kubernetes-dev/)
Complete Kubernetes development environment with K9s, Skaffold, and related tools.

### [Lazygit Development](lazygit-dev/)
Enhanced git workflow environment with Lazygit terminal UI for intuitive git operations.

### [npm Global Packages](npm/)
Node.js development environment with globally installed npm packages including TypeScript, Angular CLI, and development tools.

### [Security Tools](security-tools/)
Security-focused environment with Gitleaks and other security tools.

### [BMAD-METHOD AI Framework](bmad-method/)
AI-powered development environment with BMAD-METHOD Universal AI Agent Framework for Agentic Agile Driven Development.

### [BMAD-METHOD Docker](bmad-method-docker/)
Docker-based AI development environment with BMAD-METHOD running in containers - no Node.js installation required on host.

### [Spec-Driven Development](spec-kit/)
Spec-driven development environment with GitHub's spec-kit toolkit for building high-quality software with executable specifications.

### [OpenSpec Development](openspec/)
Spec-driven development for AI coding assistants with OpenSpec for structured change proposals and implementation tracking.

### [MarkItDown Utility](markitdown/)
Utility for converting various file formats to Markdown format using Python-based MarkItDown tool.

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

- `ghcr.io/ruanzx/features/apt` - Install system packages using APT package manager on Debian-like systems
- `ghcr.io/ruanzx/features/aws-sam-cli` - AWS Serverless Application Model CLI for building and deploying serverless applications
- `ghcr.io/ruanzx/features/azure-functions-core-tools` - Azure Functions Core Tools for building and deploying serverless functions on Azure
- `ghcr.io/ruanzx/features/bmad-method` - Universal AI Agent Framework for Agentic Agile Driven Development
- `ghcr.io/ruanzx/features/bmad-method-in-docker` - BMAD-METHOD wrapper for Docker-based execution without Node.js dependencies
- `ghcr.io/ruanzx/features/devcontainers-cli` - DevContainers CLI tools
- `ghcr.io/ruanzx/features/dotnet-tools` - .NET Global Tools (Entity Framework, formatters, etc.)
- `ghcr.io/ruanzx/features/gitleaks` - Secret detection and prevention
- `ghcr.io/ruanzx/features/helm` - Kubernetes package manager
- `ghcr.io/ruanzx/features/k6` - Modern load testing tool
- `ghcr.io/ruanzx/features/k9s` - Kubernetes terminal UI
- `ghcr.io/ruanzx/features/kubectl` - Kubernetes command-line tool
- `ghcr.io/ruanzx/features/lazygit` - Simple terminal UI for git commands
- `ghcr.io/ruanzx/features/edit` - Microsoft's modern text editor
- `ghcr.io/ruanzx/features/ngrok` - Tunneling and reverse proxy for developing networked HTTP services
- `ghcr.io/ruanzx/features/npm` - Install global npm packages for Node.js development environments
- `ghcr.io/ruanzx/features/openspec` - Spec-driven development for AI coding assistants with structured change proposals
- `ghcr.io/ruanzx/features/skaffold` - Kubernetes development workflow tool
- `ghcr.io/ruanzx/features/spec-kit` - Spec-Driven Development toolkit for building high-quality software with executable specifications
- `ghcr.io/ruanzx/features/terraform-docs` - Generate documentation from Terraform modules
- `ghcr.io/ruanzx/features/terraformer` - Generate Terraform files from existing infrastructure (reverse Terraform)
- `ghcr.io/ruanzx/features/trivy` - Comprehensive security scanner for vulnerabilities in containers, file systems, and repositories
- `ghcr.io/ruanzx/features/yq` - YAML/JSON/XML processor

For more information, see the main [README.md](../README.md).
