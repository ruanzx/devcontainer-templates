# Complete Development Environment with ALL Features

This example demonstrates a **comprehensive development container** with all 44 available features from the ruanzx DevContainer Features collection. It provides a complete, production-ready development environment supporting multiple languages, cloud platforms, Kubernetes workflows, security scanning, and AI-assisted development.

## 🎯 What's Included

### Base Development Tools
- **Common Utils** - Zsh, Oh My Zsh, and essential Unix utilities
- **Git** - Latest version from PPA
- **APT Packages** - htop, tree, curl, wget, vim, nano, jq, net-tools, build-essential, and more

### 💻 Programming Languages & Runtimes
- **.NET** (latest) - Complete SDK with apt-based installation
- **Node.js** (v20) - With Yarn and node-gyp dependencies
- **Python** (3.12) - With optimization and development tools
- **Bun** (latest) - Fast all-in-one JavaScript runtime

### 📦 Package Managers
- **pip** - Python packages (requests, pytest, black, pylint, mypy)
- **npm** - Node packages (typescript, eslint, prettier, nodemon, ts-node)

### 🔧 .NET Tools & Frameworks
- **dotnet-tools** - Entity Framework, dotnet-format, dotnet-outdated, SonarScanner, CSharpier
- **.NET Aspire** - Cloud-ready distributed application framework

### ☁️ Cloud & Serverless
- **AWS SAM CLI** - Serverless Application Model for AWS
- **Azure Functions Core Tools** (v4) - Azure serverless development
- **Azure Bicep** - Infrastructure as Code for Azure
- **Google Cloud CLI** - Complete GCP SDK

### ☸️ Kubernetes & Container Orchestration
- **kubectl** - Kubernetes CLI
- **Helm** - Kubernetes package manager
- **K9s** - Terminal UI for Kubernetes
- **Kubernetes Outside of Docker** - Access host clusters with automatic TLS configuration
- **Skaffold** - Continuous development for Kubernetes
- **Argo** - Workflows and CD (both installed)
- **mirrord** - Traffic mirroring for local development
- **kubeseal** - Sealed Secrets management
- **Headlamp** - Kubernetes web UI

### 🏗️ Infrastructure as Code
- **terraform-docs** - Generate Terraform documentation
- **terraformer** - Import existing infrastructure to Terraform
- **tfsec** - Security scanner for Terraform
- **aztfy** - Azure resource import for Terraform

### 🔒 Security Tools
- **Gitleaks** - Secret detection and prevention
- **Trivy** - Vulnerability scanner
- **Cosign** - Container signing and verification
- **GitSign** - Keyless Git signing with Sigstore

### 🧪 Testing & Performance
- **k6** - Modern load testing tool
- **act** - Run GitHub Actions locally

### 🛠️ Development Utilities
- **DevContainers CLI** - Manage dev containers from command line
- **Edit** - Microsoft's modern text editor
- **Lazygit** - Terminal UI for Git
- **yq** - YAML/JSON/XML processor
- **ngrok** - Tunneling for local development
- **MarkItDown** - Convert files to Markdown

### 🤖 AI & Development Assistance
- **BMAD-METHOD** - Universal AI Agent Framework (global installation)
- **spec-kit** - Spec-Driven Development toolkit
- **Claude Code CLI** - Claude AI integration
- **Gemini CLI** - Google Gemini AI integration

## 📋 VS Code Configuration

### Pre-installed Extensions (24)
- Kubernetes & YAML tools
- Cloud provider extensions (Azure, AWS, Google Cloud)
- Language support (.NET, Python, TypeScript)
- Code quality tools (Prettier, ESLint, EditorConfig)
- Infrastructure as Code (Terraform, Bicep)
- Git tools (GitLens, GitHub Copilot)
- Utilities (JSON, XML, TOML, Makefile)

### Editor Settings
- Zsh as default terminal
- Format on save enabled
- Auto-organize imports
- Trim trailing whitespace
- Code rulers at 80 and 120 characters

## 🚀 Getting Started

### 1. Open in DevContainer
```bash
# Clone and open
git clone <repository>
cd examples/basic-all-features
code .
```

Then click **"Reopen in Container"** when prompted.

### 2. Wait for Build
The initial build may take 10-15 minutes as it installs all 44 features. Subsequent builds will be much faster thanks to Docker layer caching.

### 3. Verify Installation
After the container starts, you'll see a welcome message listing all installed features. Verify tools are available:

```bash
# Languages
node --version          # Node.js v20
python --version        # Python 3.12
dotnet --version        # Latest .NET
bun --version           # Bun

# Cloud CLIs
aws --version           # AWS SAM CLI
az --version            # Azure CLI
gcloud --version        # Google Cloud CLI

# Kubernetes
kubectl version --client
helm version
k9s version

# Security
trivy --version
gitleaks version
cosign version

# AI Tools
npx bmad-method --version
specify --version
```

## 🌐 Port Forwarding

The following ports are automatically forwarded:
- **3000** - Frontend Dev Server
- **5000** - Backend API
- **8000** - Alternative Server
- **8080** - Web UI
- **9000** - Headlamp UI

## 💡 Common Use Cases

### Full-Stack Development
Supports Node.js, Python, and .NET development with all tooling pre-installed.

### Cloud-Native Development
Complete Kubernetes workflows with local cluster access, Helm, Skaffold, and Argo.

### Multi-Cloud Infrastructure
Tools for AWS, Azure, and Google Cloud with Terraform support.

### Security-First Development
Built-in secret scanning, vulnerability detection, and signing tools.

### AI-Assisted Development
Multiple AI tools for code generation, spec-driven development, and agent-based workflows.

## 📚 Key Features Highlights

### Kubernetes Outside of Docker
Automatically configures kubectl to access your host Kubernetes cluster (Docker Desktop, Rancher, kind, minikube). Handles TLS certificates and context detection automatically.

### BMAD-METHOD
Universal AI Agent Framework for Agentic Agile Driven Development. Use `npx bmad-method install` to set up your project.

### Spec-Driven Development
Use `specify` CLI to create projects from executable specifications with AI-powered code generation.

### Security Scanning
Run `trivy fs .` to scan for vulnerabilities or `gitleaks detect` to find exposed secrets.

## 🔄 Customization

To customize this configuration:

1. **Remove unwanted features** - Delete feature entries you don't need
2. **Adjust versions** - Change from `:latest` to specific versions
3. **Add more packages** - Update package lists in apt, pip, or npm features
4. **Modify ports** - Add or remove forwarded ports
5. **Change extensions** - Add/remove VS Code extensions

## ⚙️ Resource Considerations

This comprehensive setup requires:
- **Disk Space**: ~10-15 GB for all tools and dependencies
- **Memory**: 4 GB RAM minimum, 8 GB recommended
- **Build Time**: 10-15 minutes initial, <1 minute subsequent

## 📖 Documentation

For detailed documentation on individual features, see:
- [Main README](../../README.md)
- [Feature Documentation](../../features/)
- [Individual Feature READMEs](../../features/*/README.md)

## 🎓 Learning Path

If this complete setup is overwhelming, start with targeted examples:
- [Web Development](../web-development-tunneling/) - Node.js + ngrok
- [Kubernetes Development](../kubernetes-dev/) - K8s tools only
- [.NET Development](../dotnet-dev/) - .NET focused
- [Security Scanning](../security-scanning/) - Security tools
- [BMAD-METHOD](../bmad-method/) - AI agent framework

## 🤝 Contributing

Found an issue or want to add more features? See [CONTRIBUTING.md](../../CONTRIBUTING.md).

---

**Note**: This is a demonstration of all available features. For production use, consider creating a focused configuration with only the tools your team needs.
