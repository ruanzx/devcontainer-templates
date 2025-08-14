# DevContainers CLI

A reference implementation for the DevContainers specification.

## Description

This feature installs the DevContainers CLI, which allows you to work with development containers from the command line. It's the same tooling that powers VS Code's DevContainer functionality and GitHub Codespaces.

This feature requires Node.js and automatically depends on the official Node.js feature for installation.

## Features

- Depends on the official Node.js DevContainer feature for Node.js runtime
- Installs @devcontainers/cli globally via npm
- Adds npm global bin directory to PATH
- Provides `devcontainer` command for container operations

## Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    },
    "ghcr.io/ruanzx/devcontainer-features/devcontainers-cli:0.80.0": {}
  }
}
```

Note: The Node.js feature dependency is automatically handled via `installsAfter`, so you don't need to explicitly include it if you only want the DevContainers CLI.

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `0.80.0` | Version of DevContainers CLI to install |

### Example with options

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/ruanzx/devcontainer-features/devcontainers-cli:0.80.0": {
      "version": "0.80.0"
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
- Node.js runtime (automatically provided via dependency on `ghcr.io/devcontainers/features/node:1`)

## Dependencies

This feature automatically installs after the Node.js feature to ensure npm is available for installing the DevContainers CLI. The dependency is handled automatically through the `installsAfter` configuration.
- Internet connection for downloading Node.js and npm packages

## Links

- [DevContainers CLI GitHub](https://github.com/devcontainers/cli)
- [DevContainers Specification](https://containers.dev/)
- [VS Code DevContainers](https://code.visualstudio.com/docs/remote/containers)
