# Microsoft Edit Feature

Installs [Microsoft Edit](https://github.com/microsoft/edit), a fast, simple text editor that uses the standard command line conventions on Windows, Linux, and Mac.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:microsoft-edit": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `1.2.0` | Version of Microsoft Edit to install |

## Example

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features:microsoft-edit": {
      "version": "1.2.0"
    }
  }
}
```

## Supported Platforms

- Linux (x86_64)

## License

This feature installs Microsoft Edit which is licensed under the [MIT License](https://github.com/microsoft/edit/blob/main/LICENSE).
