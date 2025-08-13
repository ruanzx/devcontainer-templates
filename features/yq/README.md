# yq Feature

Installs [yq](https://mikefarah.gitbook.io/yq/), a lightweight and portable command-line YAML, JSON and XML processor.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:yq": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `4.44.3` | Version of yq to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:yq": {
      "version": "4.44.3"
    }
  }
}
```

## Supported Platforms

- Linux (amd64, arm64, arm)

## License

This feature installs yq which is licensed under the [MIT License](https://github.com/mikefarah/yq/blob/master/LICENSE).
