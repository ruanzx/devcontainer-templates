# kubectl Feature

Installs [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line tool that allows you to run commands against Kubernetes clusters.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/kubectl:1.31.0": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `1.31.0` | Version of kubectl to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/kubectl:1.31.0": {}
  }
}
```

Or use the latest version:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/kubectl:latest": {}
  }
}
```

## Supported Platforms

- Linux (amd64, arm64)

## Commands Available

After installation, you can use kubectl commands:

```bash
# Check kubectl version
kubectl version --client

# Get cluster information (requires cluster access)
kubectl cluster-info

# List nodes (requires cluster access)
kubectl get nodes

# Apply configuration
kubectl apply -f deployment.yaml

# Get pods
kubectl get pods
```

## License

This feature installs kubectl which is licensed under the [Apache License 2.0](https://github.com/kubernetes/kubernetes/blob/master/LICENSE).
