# K9s Feature

Installs [K9s](https://k9scli.io/), a Kubernetes CLI to manage your clusters in style!

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:k9s": {}
  }
}
```

## Options

| Option    | Type   | Default  | Description               |
| --------- | ------ | -------- | ------------------------- |
| `version` | string | `0.32.7` | Version of K9s to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:k9s": {
      "version": "0.32.7"
    }
  }
}
```

## Supported Platforms

- Linux (amd64, arm64)

## License

This feature installs K9s which is licensed under the [Apache License 2.0](https://github.com/derailed/k9s/blob/master/LICENSE).
