# Gitleaks Feature

Installs [Gitleaks](https://github.com/gitleaks/gitleaks), a tool to detect and prevent secrets in your git repos.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:gitleaks": {}
  }
}
```

## Options

| Option    | Type   | Default  | Description                    |
| --------- | ------ | -------- | ------------------------------ |
| `version` | string | `8.21.1` | Version of Gitleaks to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:gitleaks": {
      "version": "8.21.1"
    }
  }
}
```

## Supported Platforms

- Linux (amd64, arm64)

## License

This feature installs Gitleaks which is licensed under the [MIT License](https://github.com/gitleaks/gitleaks/blob/master/LICENSE).
