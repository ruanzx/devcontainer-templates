# tldr (Docker-based)

Installs [tldr](https://github.com/tldr-pages/tldr), a simplified and community-driven man pages, that runs in a Docker container.

tldr (pronounced "tee el dee arr") is a collection of simplified and community-driven man pages. It provides practical examples for commands instead of the full manual pages.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/tldr-in-docker": {}
  }
}
```

## Prerequisites

This feature requires Docker to be available. Add the Docker feature before this one:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker": {},
    "ghcr.io/ruanzx/devcontainer-features/tldr-in-docker": {}
  }
}
```

## Options

| Option     | Type   | Default       | Description                          |
| ---------- | ------ | ------------- | ------------------------------------ |
| `version`  | string | `latest`      | Version tag of the tldr Docker image |
| `imageName`| string | `ruanzx/tldr` | Docker image name for tldr           |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker": {},
    "ghcr.io/ruanzx/devcontainer-features/tldr-in-docker": {}
  }
}
```

### Specific Version

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker": {},
    "ghcr.io/ruanzx/devcontainer-features/tldr-in-docker": {
      "version": "1.0.0"
    }
  }
}
```

## What's Installed

This feature installs a wrapper script that runs tldr commands in a Docker container using the `ruanzx/tldr` image with persistent caching.

**Caching Features:**
- **Persistent Cache**: tldr pages are cached in a Docker named volume (`tldr-cache`)
- **Automatic Updates**: Cache updates automatically once per day
- **Performance**: Subsequent runs are faster due to cached pages

## Getting Started

After installation, you can use tldr commands directly:

```bash
# Get help for a command
tldr tar

# Get help for git commands
tldr git

# List all available pages
tldr --list

# Update local cache (also happens automatically daily)
tldr --update

# Get help for the tldr command itself
tldr --help
```

**Cache Management:**
- Cache is automatically updated once per day
- To force a cache refresh: `docker volume rm tldr-cache`
- Cache persists across container restarts

## Requirements

- **Docker**: Required for running tldr in containers
- **Network**: Internet access for pulling Docker images

## Common Use Cases

- **Command Help**: Get simplified help for Linux/Unix commands
- **Learning CLI**: Learn command-line tools with practical examples
- **Quick Reference**: Fast access to command usage examples
- **Documentation**: Community-driven, up-to-date command documentation

## Supported Platforms

- Linux (x86_64, ARM64)
- macOS (x86_64, ARM64)
- Windows (via WSL2)

## Additional Resources

- [tldr GitHub Repository](https://github.com/tldr-pages/tldr)
- [tldr Website](https://tldr.sh/)
- [Contributing to tldr](https://github.com/tldr-pages/tldr/blob/main/CONTRIBUTING.md)