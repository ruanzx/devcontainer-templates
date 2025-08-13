# DevContainers CLI

A reference implementation for the DevContainers specification.

## Description

This feature installs the DevContainers CLI, which allows you to work with development containers from the command line. It's the same tooling that powers VS Code's DevContainer functionality and GitHub Codespaces.

## Features

- Installs Node.js LTS version (if not already present)
- Installs @devcontainers/cli globally via npm
- Adds npm global bin directory to PATH
- Provides `devcontainer` command for container operations

## Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/devcontainers-cli:0.80.0": {}
  }
}
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `0.80.0` | Version of DevContainers CLI to install |
| `nodeVersion` | string | `lts` | Node.js version to install (if needed) |

### Example with options

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/devcontainers-cli:0.80.0": {
      "version": "0.80.0",
      "nodeVersion": "20"
    }
  }
}
```

## Commands

After installation, you can use the `devcontainer` command:

- `devcontainer build .` - Build a dev container
- `devcontainer up .` - Start a dev container
- `devcontainer exec <cmd>` - Execute command in running container
- `devcontainer --help` - Show all available commands

## Requirements

- Linux-based container
- Internet connection for downloading Node.js and npm packages

## Links

- [DevContainers CLI GitHub](https://github.com/devcontainers/cli)
- [DevContainers Specification](https://containers.dev/)
- [VS Code DevContainers](https://code.visualstudio.com/docs/remote/containers)
