# Spec-Kit Docker Image

A runtime base image for [spec-kit](https://github.com/github/spec-kit). The image provides Python 3.12, uv, and system dependencies. Spec-kit itself is installed at container start via the entrypoint, allowing you to pin or update the CLI version without rebuilding the image.

## What's Included

- **Python 3.12** - Python runtime
- **uv** - Fast Python package manager
- **Git** - For repository management
- **entrypoint.sh** - Installs spec-kit on container start

Spec-kit is **not** baked into the image. It is installed at runtime based on the `SPECKIT_VERSION` environment variable (default: `latest`).

## Usage

### Build the Image

```bash
docker build -t spec-kit:latest -f Dockerfile .
```

### Run Interactively

```bash
# Run with current directory mounted (installs latest spec-kit on start)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest bash

# Inside container, use specify commands:
specify check
specify init my-project
```

### Run Specific Commands

```bash
# Check installed tools
docker run --rm \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest specify check

# Initialize a new project (mount volume to persist)
docker run --rm \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest specify init my-project

# Pin to a specific spec-kit version
docker run --rm \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  -e SPECKIT_VERSION=v0.5.0 \
  spec-kit:latest specify check
```

### Docker Compose Example

```yaml
version: '3.8'
services:
  spec-kit:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - .:/workspace
      - speckit-uv-tools:/root/.local/share/uv/tools
    working_dir: /workspace
    environment:
      - SPECKIT_VERSION=${SPECKIT_VERSION:-latest}
    stdin_open: true
    tty: true

volumes:
  speckit-uv-tools:
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SPECKIT_VERSION` | `latest` | Spec-kit version to install. Use `latest` or a git tag/ref (e.g. `v0.5.0`). |
| `PYTHONUNBUFFERED` | `1` | Ensures Python output is not buffered |
| `PYTHONDONTWRITEBYTECODE` | `1` | Prevents .pyc file creation |

## Persistent Tool Cache

Mount a named volume at `/root/.local/share/uv/tools` to avoid reinstalling spec-kit on every container run:

```bash
docker volume create speckit-uv-tools

docker run --rm \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest specify check
```

The entrypoint records which version is installed in the volume. It only reinstalls when the requested `SPECKIT_VERSION` differs from the cached version.

## Persistent Configuration

To persist configuration across container runs:

```bash
docker run --rm -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  -v ~/.gitconfig:/root/.gitconfig:ro \
  spec-kit:latest bash
```

## AI Agent Integration

Spec-kit works with various AI coding agents:
- GitHub Copilot
- Claude Code
- Gemini CLI
- Cursor
- And many more

See the [full list of supported agents](https://github.com/github/spec-kit#-supported-ai-agents).

## Common Workflows

### Initialize a New Project

```bash
# Create and navigate to project directory
mkdir my-project && cd my-project

# Run spec-kit container
docker run -it --rm \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest bash

# Inside container:
specify init --here --ai copilot
```

### Work with Existing Project

```bash
# Navigate to project with .specify/ directory
cd my-existing-project

# Run container with project mounted
docker run -it --rm \
  -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  spec-kit:latest bash

# Use spec-kit commands through AI agent
# /speckit.constitution
# /speckit.specify
# /speckit.plan
# /speckit.tasks
# /speckit.implement
```

## Troubleshooting

### Permission Issues

If you encounter permission issues with mounted volumes:

```bash
# Run with current user
docker run -it --rm -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  --user $(id -u):$(id -g) \
  spec-kit:latest bash
```

### Git Configuration

```bash
# Mount git config for commit operations
docker run -it --rm -v $(pwd):/workspace \
  -v speckit-uv-tools:/root/.local/share/uv/tools \
  -v ~/.gitconfig:/root/.gitconfig:ro \
  -v ~/.ssh:/root/.ssh:ro \
  spec-kit:latest bash
```

## References

- [Spec-Kit Documentation](https://github.com/github/spec-kit)
- [Spec-Kit Installation Guide](https://github.com/github/spec-kit/blob/main/docs/installation.md)
- [Spec-Driven Development Methodology](https://github.com/github/spec-kit/blob/main/spec-driven.md)
