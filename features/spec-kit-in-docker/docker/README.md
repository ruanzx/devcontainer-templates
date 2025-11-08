# Spec-Kit Docker Image

A containerized version of [spec-kit](https://github.com/github/spec-kit) for spec-driven development with AI coding agents.

## What's Included

- **Python 3.12** - Latest Python runtime
- **uv** - Fast Python package manager
- **spec-kit CLI** - The specify command-line tool
- **Git** - For repository management

## Usage

### Build the Image

```bash
docker build -t spec-kit:latest -f Dockerfile .
```

### Run Interactively

```bash
# Run with current directory mounted
docker run -it --rm -v $(pwd):/workspace spec-kit:latest bash

# Inside container, use specify commands:
specify check
specify init my-project
```

### Run Specific Commands

```bash
# Check installed tools
docker run --rm spec-kit:latest specify check

# Initialize a new project (mount volume to persist)
docker run --rm -v $(pwd):/workspace spec-kit:latest specify init my-project

# Show version
docker run --rm spec-kit:latest specify --version
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
    working_dir: /workspace
    stdin_open: true
    tty: true
```

## Environment Variables

The following environment variables are pre-configured:

- `PYTHONUNBUFFERED=1` - Ensures Python output is not buffered
- `PYTHONDONTWRITEBYTECODE=1` - Prevents .pyc file creation
- `PATH` - Includes uv and specify CLI tools

## Persistent Configuration

To persist configuration across container runs:

```bash
docker run --rm -v $(pwd):/workspace \
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
docker run -it --rm -v $(pwd):/workspace spec-kit:latest bash

# Inside container:
specify init --here --ai copilot
```

### Work with Existing Project

```bash
# Navigate to project with .specify/ directory
cd my-existing-project

# Run container with project mounted
docker run -it --rm -v $(pwd):/workspace spec-kit:latest bash

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
  --user $(id -u):$(id -g) \
  spec-kit:latest bash
```

### Git Configuration

```bash
# Mount git config for commit operations
docker run -it --rm -v $(pwd):/workspace \
  -v ~/.gitconfig:/root/.gitconfig:ro \
  -v ~/.ssh:/root/.ssh:ro \
  spec-kit:latest bash
```

## References

- [Spec-Kit Documentation](https://github.com/github/spec-kit)
- [Spec-Kit Installation Guide](https://github.com/github/spec-kit/blob/main/docs/installation.md)
- [Spec-Driven Development Methodology](https://github.com/github/spec-kit/blob/main/spec-driven.md)
