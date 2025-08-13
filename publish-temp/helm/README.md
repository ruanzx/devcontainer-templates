# Helm Feature

Installs [Helm](https://helm.sh/), the package manager for Kubernetes that helps you manage Kubernetes applications.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/helm:3.16.1": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `3.16.1` | Version of Helm to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/helm:3.16.1": {}
  }
}
```

Or use the latest version:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/helm:latest": {}
  }
}
```

## Supported Platforms

- Linux (amd64, arm64)

## Commands Available

After installation, you can use Helm commands:

```bash
# Check Helm version
helm version

# Add a chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update chart repositories
helm repo update

# Search for charts
helm search repo wordpress

# Install a chart
helm install my-release bitnami/wordpress

# List releases
helm list

# Upgrade a release
helm upgrade my-release bitnami/wordpress

# Uninstall a release
helm uninstall my-release
```

## Common Workflows

```bash
# Create a new chart
helm create mychart

# Validate chart syntax
helm lint mychart/

# Dry run installation
helm install --dry-run --debug mychart ./mychart

# Package a chart
helm package mychart/
```

## License

This feature installs Helm which is licensed under the [Apache License 2.0](https://github.com/helm/helm/blob/main/LICENSE).
