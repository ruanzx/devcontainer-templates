# Spec-Kit in Docker - DevContainer Feature

A DevContainer feature that provides a Docker-based wrapper for [spec-kit](https://github.com/github/spec-kit), enabling spec-driven development with AI coding agents in an isolated container environment.

## Features

- **Docker-based**: Runs spec-kit in an isolated Docker container
- **Easy to use**: Simple `specify` command wrapper
- **No Python required**: No need to install Python, uv, or other dependencies on host
- **Version pinning**: Pin to a specific spec-kit release or use latest
- **Auto-caching**: Persistent volume avoids reinstalling on every run
- **DevContainer friendly**: Works seamlessly in DevContainer environments
- **Volume mounting**: Automatically mounts current directory
- **Git integration**: Mounts git config for repository operations

## Usage

### In devcontainer.json

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/features/spec-kit-in-docker:1": {
      "speckitVersion": "latest",
      "imageName": "ruanzx/spec-kit"
    }
  }
}
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `imageTag` | string | `"latest"` | Docker image tag for the runtime base image |
| `imageName` | string | `"ruanzx/spec-kit"` | Docker image name |
| `speckitVersion` | string | `"latest"` | Spec-kit CLI version. `latest` or a git tag/ref (e.g. `v0.5.0`) |

## Commands

### Wrapper-specific Commands

```bash
# Show wrapper help
specify --wrapper-help

# Force pull the latest base Docker image
specify --wrapper-upgrade
```

### Spec-Kit Commands

```bash
# Initialize a new project in current directory
specify init --here --ai copilot

# Initialize a new project in subdirectory
specify init my-project --ai claude

# Check installed tools
specify check

# Get spec-kit help
specify --help
```

## Environment Variables

You can customize the Docker image and spec-kit version at runtime:

```bash
export SPECKIT_IMAGE_NAME="ruanzx/spec-kit"
export SPECKIT_IMAGE_TAG="latest"
export SPECKIT_VERSION="latest"           # or a git tag like "v0.5.0"
```

## How It Works

The feature installs a wrapper script at `/usr/local/bin/specify` that:

1. Detects if running inside a DevContainer
2. Translates paths between container and host
3. Mounts your current directory as `/workspace`
4. Mounts a persistent volume for cached spec-kit installs
5. Passes `SPECKIT_VERSION` to the container entrypoint
6. Mounts your git config (read-only)
7. Passes through GitHub tokens
8. Runs spec-kit commands in the Docker container

The Docker image itself contains only Python 3.12, uv, and system dependencies. Spec-kit is installed at container start by the entrypoint script, which:

- Checks the persistent volume for a matching cached version
- Installs from the spec-kit git repository if the version changed or is missing
- Records the installed version so subsequent runs skip installation

## Examples

### Initialize a Project

```bash
# Create new project directory
mkdir my-awesome-app
cd my-awesome-app

# Initialize with GitHub Copilot
specify init --here --ai copilot
```

### Pin to a Specific Version

```bash
# Use a specific release
SPECKIT_VERSION=v0.5.0 specify check

# Or set it in devcontainer.json
```

### Work with Spec-Driven Development

After initialization, use the spec-kit workflow:

```bash
# In your AI coding agent, use these commands:
/speckit.constitution   # Establish project principles
/speckit.specify        # Create feature specifications
/speckit.plan           # Generate implementation plan
/speckit.tasks          # Break down into tasks
/speckit.implement      # Execute implementation
```

### Upgrade Base Image

```bash
# Pull latest Docker image
specify --wrapper-upgrade
```

## Building the Docker Image

If you want to build the Docker image yourself:

```bash
cd features/spec-kit-in-docker/docker
docker build -t ruanzx/spec-kit:latest .

# Push to registry (optional)
docker push ruanzx/spec-kit:latest
```

## Testing

Run the test suite:

```bash
cd features/spec-kit-in-docker/docker
./test.sh
```

## Supported AI Agents

Spec-kit works with various AI coding agents:

- GitHub Copilot
- Claude Code
- Gemini CLI
- Cursor
- Codex CLI
- Amazon Q Developer
- And many more...

See the [full list](https://github.com/github/spec-kit#-supported-ai-agents).

## Troubleshooting

### Docker Image Not Found

If you get "manifest not found" error:

```bash
# Build the image locally
cd features/spec-kit-in-docker/docker
docker build -t ruanzx/spec-kit:latest .
```

### Permission Issues

If you encounter permission issues:

```bash
# The wrapper automatically handles permissions
# But you can run Docker manually if needed
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  ruanzx/spec-kit bash
```

### Path Translation Issues

The wrapper automatically translates paths when running in a DevContainer. If you experience issues:

```bash
# Check the wrapper is working
specify --wrapper-help

# Run with verbose output
docker run -it --rm \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  ruanzx/spec-kit specify check
```

### Force Reinstall Spec-Kit

To force a fresh install, remove the persistent volume:

```bash
docker volume rm speckit-uv-tools
specify check   # will reinstall
```

## Differences from Direct Installation

| Feature | Direct Install | Docker Install |
|---------|---------------|----------------|
| Python Required | Yes (3.11+) | No |
| UV Required | Yes | No |
| Isolation | No | Yes |
| Version Pinning | Manual | `SPECKIT_VERSION` env var |
| Updates | Manual | Change `SPECKIT_VERSION` or remove volume |
| Performance | Faster | Slightly slower |
| Portability | OS-dependent | Cross-platform |

## Related Features

- [spec-kit](../spec-kit) - Direct installation (requires Python)
- [docker-outside-of-docker](https://github.com/devcontainers/features/tree/main/src/docker-outside-of-docker) - Required for Docker access

## Contributing

See the main [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.

## License

See the main [LICENSE](../../LICENSE) file.

## References

- [Spec-Kit Repository](https://github.com/github/spec-kit)
- [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [DevContainer Features](https://containers.dev/implementors/features/)
