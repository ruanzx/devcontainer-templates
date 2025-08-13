# DevContainer Features Collection

A collection of high-quality DevContainer Features for enhancing development environments with popular tools and utilities.

## Features

This repository provides the following DevContainer Features:

### 🛠️ Development Tools

- **[Microsoft Edit](features/microsoft-edit/)** - A fast, simple text editor that uses standard command line conventions
- **[yq](features/yq/)** - A lightweight and portable command-line YAML, JSON and XML processor

### ☸️ Kubernetes & DevOps

- **[kubectl](features/kubectl/)** - The Kubernetes command-line tool
- **[Helm](features/helm/)** - The package manager for Kubernetes
- **[K9s](features/k9s/)** - Kubernetes CLI to manage your clusters in style
- **[Skaffold](features/skaffold/)** - Easy and repeatable Kubernetes development

### 🔒 Security

- **[Gitleaks](features/gitleaks/)** - Detect and prevent secrets in your git repos

## Quick Start

### Using Features in Your DevContainer

Add any of these features to your `.devcontainer/devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/kubectl:1.31.0": {},
    "ghcr.io/ruanzx/devcontainer-features/helm:3.16.1": {},
    "ghcr.io/ruanzx/devcontainer-features/k9s:0.32.7": {},
    "ghcr.io/ruanzx/devcontainer-features/yq:4.44.3": {},
    "ghcr.io/ruanzx/devcontainer-features/microsoft-edit:1.2.0": {},
    "ghcr.io/ruanzx/devcontainer-features/skaffold:2.16.1": {},
    "ghcr.io/ruanzx/devcontainer-features/gitleaks:8.21.1": {}
  }
}
```

### Feature Versioning

Each feature is independently versioned and tagged by the tool version it installs. Features are available as:

- `ghcr.io/ruanzx/devcontainer-features/<feature-name>:<tool-version>`
- `ghcr.io/ruanzx/devcontainer-features/<feature-name>:latest` (latest version)

Example:
```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/kubectl:1.31.0": {}
  }
}
```

## Development

### Prerequisites

- Docker
- jq
- bash
- GitHub CLI (optional, for authentication)

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
- `./scripts/test.sh syntax` - Check shell script and JSON syntax
- `./scripts/test.sh features` - Test feature installations
- `./scripts/test.sh all` - Run all tests (default)

### Publish Features

Publish features to GitHub Container Registry:

```bash
./scripts/publish.sh
```

Options:
- `./scripts/publish.sh --public` - Publish with guidance to make packages public
- `./scripts/publish.sh --private` - Publish as private (default)

This will:
- Authenticate with GitHub Container Registry
- Build and push individual features with tool version tags
- Tag each feature as `<feature>:<tool-version>` and `<feature>:latest`
- Provide guidance for making packages public (when using `--public`)

## Project Structure

```
├── .env.sample              # Environment variables template
├── .gitignore               # Git ignore patterns
├── README.md                # This file
├── common/                  # Shared utilities
│   └── utils.sh            # Common bash functions
├── features/               # Feature definitions
│   ├── gitleaks/
│   ├── helm/
│   ├── k9s/
│   ├── kubectl/
│   ├── microsoft-edit/
│   ├── skaffold/
│   └── yq/
└── scripts/                # Build and deployment scripts
    ├── build.sh            # Build all features
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
FEATURES_NAMESPACE=ruanzx/devcontainer-features

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [DevContainer Features Specification](https://containers.dev/implementors/features/)
- [DevContainer Templates](https://containers.dev/implementors/templates/)
- All the amazing tool maintainers whose software we package
