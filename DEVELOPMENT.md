# DevContainer Features Development Workflow

## Quick Start Commands

```bash
# Set up development environment
./devcontainer-features.sh setup

# Build all features
./devcontainer-features.sh build

# Run tests
./devcontainer-features.sh test

# Publish to GitHub Container Registry
./devcontainer-features.sh publish

# Create usage examples
./scripts/create-examples.sh

# Clean build artifacts
./devcontainer-features.sh clean
```

## Publishing Workflow

1. **Set up GitHub Token**: Edit `.env` file and add your GitHub personal access token with `write:packages` permission.

2. **Build Features**: `./devcontainer-features.sh build`

3. **Test Features**: `./devcontainer-features.sh test`

4. **Publish to Registry**: `./devcontainer-features.sh publish`

## Using Published Features

Once published, use features in any devcontainer.json:

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

## Development Best Practices

- **Version Management**: Use semantic versioning for features
- **Testing**: Always test features before publishing
- **Documentation**: Keep README files updated
- **Security**: Use Gitleaks to scan for secrets
- **Consistency**: Follow the established patterns for new features

## Maintenance

- Regularly update tool versions in feature definitions
- Test features with new devcontainer base images
- Monitor GitHub Container Registry for package status
- Update documentation when adding new features
