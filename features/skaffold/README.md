# Skaffold Feature

Installs [Skaffold](https://skaffold.dev/), easy and repeatable Kubernetes development.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:skaffold": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `2.16.1` | Version of Skaffold to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:skaffold": {
      "version": "2.16.1"
    }
  }
}
```

## Supported Platforms

- Linux (amd64, arm64)

## License

This feature installs Skaffold which is licensed under the [Apache License 2.0](https://github.com/GoogleContainerTools/skaffold/blob/main/LICENSE).
