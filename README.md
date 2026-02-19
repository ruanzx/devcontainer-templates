# DevContainer Features Collection

A collection of 47+ high-quality DevContainer Features for enhancing development environments with popular tools and utilities. All features follow consistent patterns with robust error handling, architecture detection, and comprehensive documentation.

## 📦 Available Features

This repository provides the following DevContainer Features:

### 🛠️ Development Tools

- **[APT Package Manager](features/apt/)** - Install packages using APT package manager on Debian-like systems
- **[bottom](features/bottom/)** - A customizable cross-platform graphical process/system monitor for the terminal
- **[btop++](features/btop/)** - A resource monitor that shows usage and stats for processor, memory, disks, network and processes
- **[DevContainers CLI](features/devcontainers-cli/)** - Official CLI for working with Development Containers
- **[Diagrams (in Docker)](features/diagrams-in-docker/)** - Python library for creating cloud system architecture diagrams programmatically
- **[Edit](features/edit/)** - A fast, simple text editor that uses standard command line conventions
- **[Lazygit](features/lazygit/)** - A simple terminal UI for git commands that makes git easy
- **[ngrok](features/ngrok/)** - Tunneling and reverse proxy for developing and understanding networked, HTTP services
- **[npm](features/npm/)** - Install global npm packages for Node.js development environments
- **[yq](features/yq/)** - A lightweight and portable command-line YAML, JSON and XML processor
- **[MarkItDown](features/markitdown/)** - Utility for converting various files to Markdown format
- **[Markify (in Docker)](features/markify-in-docker/)** - Converts HTML files, URLs, and raw HTML to Markdown using the `ruanzx/markify` Docker image (`ghcr.io/ruanzx/features/markify-in-docker`)
- **[Docling (in Docker)](features/docling-in-docker/)** - AI-powered document converter for PDFs, Office files, and more to Markdown
- **[Bun](features/bun/)** - Fast all-in-one JavaScript runtime and toolkit
- **[spec-kit](features/spec-kit/)** - Spec-Driven Development toolkit for building high-quality software with executable specifications
- **[OpenSpec](features/openspec/)** - Spec-driven development for AI coding assistants with structured change proposals
- **[Pandoc](features/pandoc/)** - Universal document converter for converting between various markup and word processing formats
- **[pip](features/pip/)** - Python package installer and dependency management tool

### 🤖 AI & Development Assistance

- **[BMAD-METHOD](features/bmad-method/)** - Universal AI Agent Framework for Agentic Agile Driven Development
- **[Claude Code CLI](features/claude-code-cli/)** - Command-line interface for interacting with Claude AI
- **[Gemini CLI](features/gemini-cli/)** - Google Gemini AI command-line interface
- **[Skills-Ref (in Docker)](features/skills-ref-in-docker/)** - Validates and manages agent skills using Docker-based skills-ref tool

### ☸️ Kubernetes & DevOps

- **[kubectl](features/kubectl/)** - The Kubernetes command-line tool
- **[Helm](features/helm/)** - The package manager for Kubernetes
- **[K9s](features/k9s/)** - Kubernetes CLI to manage your clusters in style
- **[Kubernetes Outside of Docker](features/kubernetes-outside-of-docker/)** - Access host Kubernetes clusters from dev containers
- **[Skaffold](features/skaffold/)** - Easy and repeatable Kubernetes development
- **[kubeseal](features/kubeseal/)** - Client-side utility for Kubernetes Sealed Secrets
- **[mirrord](features/mirrord/)** - Mirror traffic from Kubernetes cluster to development environment
- **[Argo](features/argo/)** - Argo Workflows and Argo CD command-line tools for GitOps
- **[Headlamp](features/headlamp/)** - Kubernetes web UI for cluster management

### 🧪 Testing & Performance

- **[k6](features/k6/)** - Modern load testing tool with Node.js integration for performance testing
- **[Trivy](features/trivy/)** - Vulnerability scanner for containers, file systems, and Git repositories
- **[act](features/act/)** - Run GitHub Actions locally without pushing to GitHub

### 🔒 Security

- **[Gitleaks](features/gitleaks/)** - Detect and prevent secrets in your git repos
- **[Cosign](features/cosign/)** - Container signing and verification tool
- **[GitSign](features/gitsign/)** - Keyless Git signing with Sigstore
- **[Strix](features/strix/)** - Open-source AI agents for penetration testing and security assessments

### ☁️ Cloud & Infrastructure

- **[AWS SAM CLI](features/aws-sam-cli/)** - AWS Serverless Application Model CLI for building and deploying serverless applications
- **[Azure Functions Core Tools](features/azure-functions-core-tools/)** - Local development experience for creating, developing, testing, running, and debugging Azure Functions
- **[Terraform Docs](features/terraform-docs/)** - Generate documentation from Terraform modules in various output formats
- **[Terraformer](features/terraformer/)** - CLI tool to generate terraform files from existing infrastructure
- **[tfsec](features/tfsec/)** - Security scanner for Terraform code to detect potential security issues
- **[aztfy](features/aztfy/)** - Tool to import Azure resources into Terraform configuration
- **[Azure Bicep](features/azure-bicep/)** - Azure Resource Manager template language and tooling
- **[Google Cloud CLI](features/google-cloud-cli/)** - Official Google Cloud SDK and CLI tools

### 💻 Development Platforms

- **[.NET Tools](features/dotnet-tools/)** - Essential .NET development tools including dotnet CLI and development certificates
- **[.NET Aspire](features/aspire/)** - Cloud-ready app stack for building observable, production-ready, distributed applications

## Quick Start

### Using Features in Your DevContainer

Add any of these features to your `.devcontainer/devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,jq,tree"
    },
    "ghcr.io/ruanzx/features/bottom:latest": {},
    "ghcr.io/ruanzx/features/btop:latest": {},
    "ghcr.io/ruanzx/features/devcontainers-cli:0.80.0": {},
    "ghcr.io/ruanzx/features/kubectl:1.31.1": {},
    "ghcr.io/ruanzx/features/helm:3.16.1": {},
    "ghcr.io/ruanzx/features/k9s:0.32.7": {},
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:2.0.8": {},
    "ghcr.io/ruanzx/features/kubeseal:latest": {},
    "ghcr.io/ruanzx/features/mirrord:latest": {},
    "ghcr.io/ruanzx/features/yq:4.44.3": {},
    "ghcr.io/ruanzx/features/lazygit:0.54.2": {},
    "ghcr.io/ruanzx/features/diagrams-in-docker:1.0.0": {},
    "ghcr.io/ruanzx/features/edit:1.2.0": {},
    "ghcr.io/ruanzx/features/ngrok:latest": {},
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,nodemon,eslint"
    },
    "ghcr.io/ruanzx/features/k6:latest": {},
    "ghcr.io/ruanzx/features/act:latest": {},
    "ghcr.io/ruanzx/features/skaffold:2.16.1": {},
    "ghcr.io/ruanzx/features/gitleaks:8.21.1": {},
    "ghcr.io/ruanzx/features/cosign:latest": {},
    "ghcr.io/ruanzx/features/gitsign:latest": {},
    "ghcr.io/ruanzx/features/trivy:latest": {},
    "ghcr.io/ruanzx/features/tfsec:latest": {},
    "ghcr.io/ruanzx/features/strix:latest": {},
    "ghcr.io/ruanzx/features/aws-sam-cli:latest": {},
    "ghcr.io/ruanzx/features/google-cloud-cli:latest": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {},
    "ghcr.io/ruanzx/features/azure-functions-core-tools:latest": {},
    "ghcr.io/ruanzx/features/dotnet-tools:latest": {},
    "ghcr.io/ruanzx/features/terraform-docs:latest": {},
    "ghcr.io/ruanzx/features/terraformer:latest": {},
    "ghcr.io/ruanzx/features/aztfy:latest": {},
    "ghcr.io/ruanzx/features/bun:latest": {},
    "ghcr.io/ruanzx/features/markitdown:latest": {},
    "ghcr.io/ruanzx/features/docling-in-docker:latest": {},
    "ghcr.io/ruanzx/features/argo:latest": {},
    "ghcr.io/ruanzx/features/bmad-method:latest": {},
    "ghcr.io/ruanzx/features/spec-kit:latest": {},
    "ghcr.io/ruanzx/features/claude-code-cli:latest": {},
    "ghcr.io/ruanzx/features/gemini-cli:latest": {},
    "ghcr.io/ruanzx/features/headlamp:latest": {},
    "ghcr.io/ruanzx/features/pandoc:latest": {},
    "ghcr.io/ruanzx/features/pip:latest": {},
    "ghcr.io/ruanzx/features/aspire:latest": {}
  }
}
```

### Feature Versioning

Each feature is independently versioned and tagged by the tool version it installs. Features are available as:

- `ghcr.io/ruanzx/features/<feature-name>:<tool-version>`
- `ghcr.io/ruanzx/features/<feature-name>:latest` (latest version)

Example:
```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubectl:1.31.0": {}
  }
}
```

## Highlighted Features

### 🚀 DevContainers CLI

The **DevContainers CLI** feature provides the official CLI tool for working with Development Containers:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    },
    "ghcr.io/ruanzx/features/devcontainers-cli:0.80.0": {
      "version": "0.80.0"
    }
  }
}
```

**Key Benefits:**
- **Complete DevContainer Management**: Build, run, and manage dev containers from the command line
- **Node.js Dependency**: Uses the official Node.js feature for reliable Node.js/npm environment
- **Global CLI Access**: Available as `devcontainer` command throughout your environment
- **CI/CD Integration**: Perfect for automated builds and testing pipelines

**Common Commands:**
```bash
# Build a dev container
devcontainer build .

# Start a dev container
devcontainer up .

# Execute commands in a running container
devcontainer exec bash

# Get feature info
devcontainer features info
```

### ☸️ Kubernetes Outside of Docker

The **Kubernetes Outside of Docker** feature provides seamless access to host Kubernetes clusters from within development containers:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:2.0.8": {
      "enableClusterAccess": true,
      "autoConfigureKubeconfig": true
    }
  }
}
```

**Key Benefits:**
- **Universal Compatibility**: Works with Docker Desktop, Rancher Desktop, kind, minikube, and other local clusters
- **Automatic Configuration**: Dynamically configures kubectl to access host clusters
- **TLS Certificate Handling**: Automatically resolves certificate authority issues across different Kubernetes distributions
- **Context Detection**: Intelligently detects and selects the appropriate Kubernetes context
- **Zero Configuration**: Works out-of-the-box with sensible defaults

**Supported Platforms:**
- Docker Desktop (Windows, macOS, Linux)
- Rancher Desktop (Windows, macOS, Linux) 
- kind (Kubernetes in Docker)
- minikube
- k3s/k3d
- Generic Kubernetes clusters accessible from the host

**Common Use Cases:**
```bash
# Access your local cluster from dev container
kubectl get nodes

# Deploy applications to local cluster
kubectl apply -f deployment.yaml

# Access cluster services
kubectl port-forward service/my-app 8080:80
```

### 🔄 mirrord - Traffic Mirroring

The **mirrord** feature enables testing local code changes against real production traffic without deploying to the cluster:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/mirrord:latest": {
      "version": "3.161.0"
    },
    "ghcr.io/ruanzx/features/kubectl:latest": {}
  }
}
```

**Key Benefits:**
- **Real Traffic Testing**: Test your local code with actual production traffic patterns
- **Zero Deployment Risk**: No need to deploy untested code to production environments
- **Easy Integration**: Works with any programming language and framework
- **Kubernetes Native**: Seamlessly integrates with existing Kubernetes workflows

**Common Use Cases:**
```bash
# Mirror traffic from a pod to your local application
mirrord exec --target pod/my-app-pod -- python app.py

# Mirror traffic from a deployment
mirrord exec --target deployment/my-app -- npm start

# Mirror with specific configuration
mirrord exec --config-file mirrord.toml --target pod/my-app-pod -- go run main.go
```

### 🔐 Sealed Secrets with kubeseal

The **kubeseal** feature provides client-side utility for Kubernetes Sealed Secrets, enabling secure secret management in GitOps workflows:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubeseal:latest": {
      "version": "v0.30.0"
    },
    "ghcr.io/ruanzx/features/kubectl:latest": {}
  }
}
```

**Key Benefits:**
- **GitOps Safe**: Store encrypted secrets in version control safely
- **Client-Side Encryption**: Secrets are encrypted before leaving your local environment
- **Multi-Scope Support**: Supports strict, namespace-wide, and cluster-wide scopes
- **Production Ready**: Battle-tested in production Kubernetes environments

**Common Use Cases:**
```bash
# Encrypt a secret for GitOps
kubectl create secret generic mysecret --dry-run=client --from-literal=password=supersecret -o yaml | kubeseal -o yaml > sealed-secret.yaml

# Fetch public certificate for offline use
kubeseal --fetch-cert > public.pem

# Use offline mode with saved certificate
kubeseal --cert public.pem --format yaml < secret.yaml > sealed-secret.yaml
```

### 🎬 GitHub Actions with act

The **act** feature allows you to run GitHub Actions workflows locally, providing fast feedback without pushing to GitHub:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/act:latest": {},
    "ghcr.io/devcontainers/features/docker-in-docker:latest": {}
  }
}
```

**Key Benefits:**
- **Local Testing**: Test GitHub Actions workflows without pushing commits
- **Fast Feedback**: Immediate results without waiting for CI/CD queues
- **Cost Effective**: Reduce GitHub Actions minutes usage
- **Development Friendly**: Perfect for iterating on workflow configurations

**Common Use Cases:**
```bash
# Run all jobs in your workflow
act

# Run a specific job
act -j test

# Run with secrets
act -s GITHUB_TOKEN=your_token

# Use specific event
act push
```

### 🤖 BMAD-METHOD Universal AI Framework

The **BMAD-METHOD** feature provides a revolutionary AI agent framework for Agentic Agile Driven Development:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/ruanzx/features/bmad-method:1": {
      "installWorkspace": true
    }
  }
}
```

**Key Benefits:**
- **Agentic Planning**: Dedicated agents (Analyst, PM, Architect) create detailed PRDs and Architecture documents
- **Context-Engineered Development**: Scrum Master transforms plans into hyper-detailed development stories
- **Universal Framework**: Works beyond software development - writing, business, wellness, education
- **Web UI + IDE Integration**: Start planning in web UI, develop in your IDE
- **Node.js Based**: Requires Node.js v20+ with npm and git

**Common Use Cases:**
```bash
# Set up framework in your project
npx bmad-method install

# Check version
npx bmad-method --version

# Update existing installation
npx bmad-method install  # Auto-detects and updates
```

### 📋 Spec-Driven Development with spec-kit

The **spec-kit** feature provides GitHub's spec-kit toolkit for building high-quality software with executable specifications:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/ruanzx/features/spec-kit:1": {
      "version": "latest"
    }
  }
}
```

**Key Benefits:**
- **Executable Specifications**: Write specifications that directly generate working implementations
- **AI-Powered Development**: Leverage AI to transform specifications into code
- **Template-Based**: Use official GitHub spec-kit templates for consistent project structure
- **Modern Python Stack**: Built on Python 3.12+ with uv package manager

**Common Use Cases:**
```bash
# Create a new project from specification
specify new --template python-cli my-project

# Generate implementation from spec
specify generate

# Validate specifications
specify validate
```

## Feature Characteristics

All features in this collection are designed with the following principles:

### 🛡️ Robust & Reliable
- **Error Handling**: Comprehensive error handling with clear, actionable error messages
- **Validation**: Input validation for versions, architectures, and options
- **Cleanup**: Automatic cleanup of temporary files and resources
- **Verification**: Post-installation verification to ensure tools work correctly

### 🏗️ Architecture Support
- **Multi-Platform**: Support for AMD64, ARM64, and other architectures where available
- **OS Detection**: Automatic detection and handling of different operating systems
- **Compatibility**: Tested across different container base images

### 🔧 Developer Experience
- **Consistent Options**: Standardized option names and behavior across features
- **Comprehensive Logging**: Detailed logs with emoji indicators for easy reading
- **Version Flexibility**: Support for latest versions and specific version pinning
- **Documentation**: Each feature includes detailed README with examples

### 🚀 Production Ready
- **Checksum Verification**: Automatic checksum verification for downloaded binaries
- **Retry Logic**: Built-in retry mechanisms for network operations
- **Shared Utilities**: Common functionality through shared utility functions
- **Security Focused**: Security-first approach with verification and validation

### 📋 Feature Quality Standards
Each feature includes:
- **devcontainer-feature.json**: Complete metadata with options and documentation
- **install.sh**: Robust installation script following best practices
- **README.md**: Comprehensive documentation with usage examples
- **utils.sh**: Shared utility functions for consistency (where applicable)

## Development

### Prerequisites

- Docker
- jq
- bash
- GitHub CLI (optional, for authentication)

### Unified Development Interface

This repository provides a unified interface for all development operations through the main script:

```bash
# Set up development environment
./devcontainer-features.sh setup

# Build all features
./devcontainer-features.sh build

# Run tests
./devcontainer-features.sh test
./devcontainer-features.sh test syntax
./devcontainer-features.sh test features

# Test specific features
./devcontainer-features.sh test markitdown-in-docker
./devcontainer-features.sh test features kubectl helm

# Publish all features
./devcontainer-features.sh publish

# Publish specific features
./devcontainer-features.sh publish kubectl helm k9s

# List available features
./devcontainer-features.sh publish --list

# Clean build artifacts
./devcontainer-features.sh clean
```

Alternatively, you can run individual scripts directly from the `scripts/` directory.

### Environment Setup

1. **Clone this repository:**
   ```bash
   git clone https://github.com/ruanzx/devcontainer-templates.git
   cd devcontainer-templates
   ```

2. **Copy and configure environment:**
   ```bash
   cp .env.sample .env
   # Edit .env and add your GitHub token
   ```

### Build Features

Build all features locally:

```bash
./scripts/build.sh
```

This will:
- Validate feature definitions
- Create build artifacts in `build/`
- Update version numbers
- Ensure proper structure

### Test Features

Run comprehensive tests:

```bash
./scripts/test.sh
```

Available test types:
- `./scripts/test.sh` - Run all tests (default)
- `./scripts/test.sh syntax` - Check shell script and JSON syntax
- `./scripts/test.sh features` - Test all feature installations
- `./scripts/test.sh <feature-name>` - Test a specific feature
- `./scripts/test.sh features <feature-names>` - Test multiple specific features

Examples:
```bash
# Test all features
./scripts/test.sh
./scripts/test.sh all

# Test syntax only
./scripts/test.sh syntax

# Test specific feature
./scripts/test.sh markitdown-in-docker
./scripts/test.sh spec-kit-in-docker

# Test multiple features
./scripts/test.sh features kubectl helm k9s
```

### Publish Features

Publish features to GitHub Container Registry:

```bash
# Publish all features
./scripts/publish.sh

# Publish specific features
./scripts/publish.sh kubectl helm k9s

# List available features
./scripts/publish.sh --list

# Publish with specific visibility settings
./scripts/publish.sh --private apt ngrok
./scripts/publish.sh --public kubectl helm
```

Options:
- `./scripts/publish.sh` - Publish all built features (public by default)
- `./scripts/publish.sh <feature-names>` - Publish only specified features
- `./scripts/publish.sh --list` - List all available features
- `./scripts/publish.sh --public` - Make packages public after publishing (default)
- `./scripts/publish.sh --private` - Keep packages private

This will:
- Authenticate with GitHub Container Registry
- Build and push individual features with tool version tags
- Tag each feature as `<feature>:<tool-version>` and `<feature>:latest`
- Support selective publishing of specific features
- Provide guidance for making packages public (when using `--public`)

### Manage Packages

Clean up GitHub Container Registry packages:

```bash
# Delete all packages (use with caution!)
./scripts/delete-packages.sh

# Delete specific feature packages
./scripts/delete-packages.sh kubectl helm
```

**⚠️ Warning**: Package deletion is irreversible. Use with caution, especially in production environments.

## Project Structure

```
├── .env.sample              # Environment variables template
├── .gitignore               # Git ignore patterns
├── README.md                # This file
├── devcontainer-features.sh # Unified development interface
├── common/                  # Shared utilities
│   └── utils.sh            # Common bash functions
├── features/               # Feature definitions (30+ features)
│   ├── act/                # GitHub Actions local runner
│   ├── apt/                # APT package manager
│   ├── argo/               # Argo Workflows and CD tools
│   ├── aspire/             # .NET Aspire development
│   ├── aws-sam-cli/        # AWS Serverless Application Model CLI
│   ├── aztfy/              # Azure to Terraform import tool
│   ├── azure-bicep/        # Azure Bicep templates
│   ├── bmad-method/        # Universal AI Agent Framework
│   ├── bottom/             # Customizable system monitor
│   ├── btop/               # System resource monitor
│   ├── bun/                # JavaScript runtime and toolkit
│   ├── claude-code-cli/    # Claude AI CLI
│   ├── cosign/             # Container signing tool
│   ├── devcontainers-cli/  # DevContainers CLI
│   ├── dotnet-tools/       # .NET development tools
│   ├── edit/               # Fast text editor
│   ├── gemini-cli/         # Google Gemini AI CLI
│   ├── gitleaks/           # Git secrets scanner
│   ├── gitsign/            # Keyless Git signing
│   ├── google-cloud-cli/   # Google Cloud SDK
│   ├── headlamp/           # Kubernetes web UI
│   ├── helm/               # Kubernetes package manager
│   ├── k6/                 # Load testing tool
│   ├── k9s/                # Kubernetes cluster manager
│   ├── kubectl/            # Kubernetes CLI
│   ├── kubernetes-outside-of-docker/ # Host cluster access
│   ├── kubeseal/           # Sealed Secrets client
│   ├── lazygit/            # Terminal Git UI
│   ├── markitdown/         # File to Markdown converter
│   ├── mirrord/            # Traffic mirroring tool
│   ├── ngrok/              # Tunneling service
│   ├── npm/                # npm package manager
│   ├── openspec/           # Spec-driven development
│   ├── pip/                # Python package installer
│   ├── skaffold/           # Kubernetes development
│   ├── spec-kit/           # Spec-Driven Development toolkit
│   ├── strix/              # AI penetration testing agents
│   ├── terraform-docs/     # Terraform documentation
│   ├── terraformer/        # Infrastructure to Terraform
│   ├── tfsec/              # Terraform security scanner
│   ├── trivy/              # Vulnerability scanner
│   └── yq/                 # YAML/JSON/XML processor
├── examples/               # Example configurations
│   ├── apt-packages/
│   ├── basic-all-features/
│   ├── bmad-method/
│   ├── bottom/
│   ├── btop/
│   ├── dotnet-dev/
│   ├── infrastructure-import/
│   ├── kubernetes-dev/
│   ├── kubernetes-outside-docker/
│   ├── lazygit-dev/
│   ├── markitdown/
│   ├── performance-testing/
│   ├── security-scanning/
│   ├── security-tools/
│   ├── serverless-development/
│   ├── spec-kit/
│   ├── strix/
│   ├── terraform-dev/
│   └── web-development-tunneling/
└── scripts/                # Build and deployment scripts
    ├── build.sh            # Build all features
    ├── create-examples.sh  # Generate usage examples
    ├── delete-packages.sh  # Delete GitHub packages
    ├── dotnet-install.sh   # .NET installation helper
    ├── fix-kubernetes-feature.sh # Kubernetes feature fixes
    ├── publish.sh          # Publish to registry
    └── test.sh             # Test all features
```

## Environment Configuration

Create a `.env` file from `.env.sample` with the following variables:

```bash
# GitHub Container Registry Configuration
GITHUB_TOKEN=your_github_personal_access_token
GITHUB_USERNAME=ruanzx
GITHUB_REGISTRY=ghcr.io

# Features Configuration
FEATURES_NAMESPACE=ruanzx/features

# Package Visibility (set to true to get guidance for making packages public)
MAKE_PUBLIC=false

# Build Configuration
BUILD_LOG_LEVEL=info
```

### GitHub Token Requirements

Your GitHub token needs the following permissions:
- `write:packages` - Push to GitHub Container Registry
- `read:packages` - Pull from GitHub Container Registry
- `repo` - Access to repository (if private)

## Contributing

### Adding a New Feature

1. **Create feature directory:**
   ```bash
   mkdir -p features/new-tool
   ```

2. **Create feature definition:**
   ```bash
   # features/new-tool/devcontainer-feature.json
   ```

3. **Create install script:**
   ```bash
   # features/new-tool/install.sh
   ```

4. **Follow the pattern of existing features**

### Feature Requirements

Each feature must include:

- `devcontainer-feature.json` - Feature metadata and options
- `install.sh` - Installation script
- Proper error handling and logging
- Version validation
- Architecture detection
- Cleanup procedures

### Best Practices

- **Use semantic versioning** for feature versions
- **Include comprehensive logging** using common utilities
- **Handle multiple architectures** (amd64, arm64)
- **Validate inputs** before processing
- **Clean up temporary files** after installation
- **Verify installation** after completion
- **Use consistent naming** for options and variables

## Troubleshooting

### Common Issues

1. **Build fails with permission error:**
   ```bash
   chmod +x scripts/*.sh features/*/install.sh
   ```

2. **GitHub authentication fails:**
   - Verify GITHUB_TOKEN in .env
   - Check token permissions
   - Ensure token hasn't expired

3. **Feature test fails:**
   - Check Docker is running
   - Verify feature syntax with `./scripts/test.sh syntax`
   - Test individual features manually
   - For devcontainers-cli: Ensure network access for Node.js download

4. **Node.js installation issues (devcontainers-cli):**
   - Check internet connectivity for downloading Node.js binaries
   - Verify sufficient disk space for Node.js installation
   - Try running with `nodeVersion: "20"` explicitly set

### Debugging

Enable verbose logging:
```bash
export BUILD_LOG_LEVEL=debug
./scripts/build.sh
```

Check individual feature:
```bash
docker run --rm -v ./features/k9s:/tmp/feature mcr.microsoft.com/devcontainers/base:ubuntu bash /tmp/feature/install.sh
```

### Dev Container Connection Issues

If you encounter Dev Container connection problems (502 errors, TCP upgrade failures), see the comprehensive [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide for solutions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [DevContainer Features Specification](https://containers.dev/implementors/features/)
- [DevContainer Templates](https://containers.dev/implementors/templates/)
- All the amazing tool maintainers whose software we package
