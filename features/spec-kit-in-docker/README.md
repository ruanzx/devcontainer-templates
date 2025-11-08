# Spec-Kit in Docker - DevContainer Feature

A DevContainer feature that provides a Docker-based wrapper for [spec-kit](https://github.com/github/spec-kit), enabling spec-driven development with AI coding agents in an isolated container environment.

## Features

- **Docker-based**: Runs spec-kit in an isolated Docker container
- **Easy to use**: Simple `specify` command wrapper
- **No Python required**: No need to install Python, uv, or other dependencies on host
- **Auto-updates**: Built-in upgrade mechanism with `--wrapper-upgrade`
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
      "version": "latest",
      "imageName": "ruanzx/spec-kit"
    }
  }
}
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Docker image tag for spec-kit |
| `imageName` | string | `"ruanzx/spec-kit"` | Docker image name |

## Commands

### Wrapper-specific Commands

```bash
# Show wrapper help
specify --wrapper-help

# Upgrade spec-kit Docker image
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

You can customize the Docker image used by setting these environment variables:

```bash
export SPECKIT_IMAGE_NAME="ruanzx/spec-kit"
export SPECKIT_IMAGE_TAG="latest"
```

## How It Works

The feature installs a wrapper script at `/usr/local/bin/specify` that:

1. Detects if running inside a DevContainer
2. Translates paths between container and host
3. Mounts your current directory as `/workspace`
4. Mounts your git config (read-only)
5. Passes through GitHub tokens
6. Runs spec-kit commands in the Docker container

## Examples

### Initialize a Project

```bash
# Create new project directory
mkdir my-awesome-app
cd my-awesome-app

# Initialize with GitHub Copilot
specify init --here --ai copilot
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

### Upgrade Spec-Kit

```bash
# Pull latest Docker image
specify --wrapper-upgrade
```

## Building the Docker Image

If you want to build the Docker image yourself:

```bash
cd features/spec-kit-in-docker/docker
docker build -t ruanzx/spec-kit:latest .

# Or with a specific tag
docker build -t ruanzx/spec-kit:v1.0.0 .

# Push to registry (optional)
docker push ruanzx/spec-kit:latest
```

## Testing

Run the test suite:

```bash
cd features/spec-kit-in-docker/test
./test.sh
```

## Supported AI Agents

Spec-kit works with various AI coding agents:

- ✅ GitHub Copilot
- ✅ Claude Code
- ✅ Gemini CLI
- ✅ Cursor
- ✅ Codex CLI
- ✅ Amazon Q Developer
- ✅ And many more...

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
  ruanzx/spec-kit bash
```

### Path Translation Issues

The wrapper automatically translates paths when running in a DevContainer. If you experience issues:

```bash
# Check the wrapper is working
specify --wrapper-help

# Run with verbose output
docker run -it --rm -v $(pwd):/workspace ruanzx/spec-kit specify check
```

## Differences from Direct Installation

| Feature | Direct Install | Docker Install |
|---------|---------------|----------------|
| Python Required | ✅ Yes (3.11+) | ❌ No |
| UV Required | ✅ Yes | ❌ No |
| Isolation | ❌ No | ✅ Yes |
| Updates | Manual | `--wrapper-upgrade` |
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
