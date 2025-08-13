# DevContainer Features Collection

A collection of high-quality DevContainer Features for enhancing development environments with popular tools and utilities.

## Features

This repository provides the following DevContainer Features:

### 🛠️ Development Tools

- **[Microsoft Edit](features/microsoft-edit/)** - A fast, simple text editor that uses standard command line conventions
- **[yq](features/yq/)** - A lightweight and portable command-line YAML, JSON and XML processor

### ☸️ Kubernetes & DevOps

- **[K9s](features/k9s/)** - Kubernetes CLI to manage your clusters in style
- **[Skaffold](features/skaffold/)** - Easy and repeatable Kubernetes development

### 🔒 Security

- **[Gitleaks](features/gitleaks/)** - Detect and prevent secrets in your git repos

## Quick Start

### Using Features in Your DevContainer

Add any of these features to your `.devcontainer/devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:k9s": {},
    "ghcr.io/ruanzx/devcontainer-features:yq": {
      "version": "4.44.3"
    },
    "ghcr.io/ruanzx/devcontainer-features:microsoft-edit": {},
    "ghcr.io/ruanzx/devcontainer-features:skaffold": {},
    "ghcr.io/ruanzx/devcontainer-features:gitleaks": {}
  }
}
```

### Feature Options

Each feature supports version configuration:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:k9s": {
      "version": "0.32.7"
    }
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

This will:
- Authenticate with GitHub Container Registry
- Build and push individual feature images
- Create a collection manifest
- Tag with both latest and version-specific tags

## Project Structure

```
├── .env.sample              # Environment variables template
├── .gitignore               # Git ignore patterns
├── README.md                # This file
├── common/                  # Shared utilities
│   └── utils.sh            # Common bash functions
├── features/               # Feature definitions
│   ├── gitleaks/
│   ├── k9s/
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
FEATURES_VERSION=1.0.0

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
                "gold",
                "green"
            ],
            "default": "red"
        }
    }
}
```

An [implementing tool](https://containers.dev/supporting#tools) will use the `options` property from [the documented Dev Container Template properties](https://containers.dev/implementors/templates#devcontainer-templatejson-properties) for customizing the Template. See [option resolution example](https://containers.dev/implementors/templates#option-resolution-example) for details.

## Distributing Templates

**Note**: *Allow GitHub Actions to create and approve pull requests* should be enabled in the repository's `Settings > Actions > General > Workflow permissions` for auto generation of `src/<template>/README.md` per Template (which merges any existing `src/<template>/NOTES.md`).

### Versioning

Templates are individually versioned by the `version` attribute in a Template's `devcontainer-template.json`. Templates are versioned according to the semver specification. More details can be found in [the Dev Container Template specification](https://containers.dev/implementors/templates-distribution/#versioning).

### Publishing

> NOTE: The Distribution spec can be [found here](https://containers.dev/implementors/templates-distribution/).  
>
> While any registry [implementing the OCI Distribution spec](https://github.com/opencontainers/distribution-spec) can be used, this template will leverage GHCR (GitHub Container Registry) as the backing registry.

Templates are source files packaged together that encode configuration for a complete development environment.

This repo contains a GitHub Action [workflow](.github/workflows/release.yaml) that will publish each template to GHCR.  By default, each Template will be prefixed with the `<owner>/<repo>` namespace.  For example, the two Templates in this repository can be referenced by an [implementing tool](https://containers.dev/supporting#tools) with:

```
ghcr.io/devcontainers/template-starter/color:latest
ghcr.io/devcontainers/template-starter/hello:latest
```

The provided GitHub Action will also publish a third "metadata" package with just the namespace, eg: `ghcr.io/devcontainers/template-starter`. This contains information useful for tools aiding in Template discovery.

'`devcontainers/template-starter`' is known as the template collection namespace.

### Marking Template Public

For your Template to be used, it currently needs to be available publicly. By default, OCI Artifacts in GHCR are marked as `private`. 

To make them public, navigate to the Template's "package settings" page in GHCR, and set the visibility to 'public`. 

```
https://github.com/users/<owner>/packages/container/<repo>%2F<templateName>/settings
```

### Adding Templates to the Index

Next you will need to add your Templates collection to our [public index](https://containers.dev/templates) so that other community members can find them. Just follow these steps once per collection you create:

* Go to [github.com/devcontainers/devcontainers.github.io](https://github.com/devcontainers/devcontainers.github.io)
     * This is the GitHub repo backing the [containers.dev](https://containers.dev/) spec site
* Open a PR to modify the [collection-index.yml](https://github.com/devcontainers/devcontainers.github.io/blob/gh-pages/_data/collection-index.yml) file

This index is from where [supporting tools](https://containers.dev/supporting) like [VS Code Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and [GitHub Codespaces](https://github.com/templates/codespaces) surface Templates for their Dev Container Creation Configuration UI.

### Testing Templates

This repo contains a GitHub Action [workflow](.github/workflows/test-pr.yaml) for testing the Templates. Similar to the [`devcontainers/templates`](https://github.com/devcontainers/templates) repo, this repository has a `test` folder.  Each Template has its own sub-folder, containing at least a `test.sh`.

For running the tests locally, you would need to execute the following commands -

```
    ./.github/actions/smoke-test/build.sh ${TEMPLATE-ID} 
    ./.github/actions/smoke-test/test.sh ${TEMPLATE-ID} 
```

### Updating Documentation

This repo contains a GitHub Action [workflow](.github/workflows/release.yaml) that will automatically generate documentation (ie. `README.md`) for each Template. This file will be auto-generated from the `devcontainer-template.json` and `NOTES.md`.
