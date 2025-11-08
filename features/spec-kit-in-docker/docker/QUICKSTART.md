# Quick Start Guide - Spec-Kit Docker

This guide will help you get started with the spec-kit Docker container in under 5 minutes.

## Prerequisites

- Docker installed on your machine
- Basic understanding of Docker commands

## Step 1: Build the Image

```bash
cd /path/to/docker/directory
docker build -t spec-kit:latest -f Dockerfile .
```

Or use the Makefile:

```bash
make build
```

## Step 2: Verify Installation

```bash
docker run --rm spec-kit:latest specify check
```

You should see a list of available tools and their status.

## Step 3: Initialize Your First Project

### Option A: Using the interactive script

```bash
./examples.sh
# Select option 3
```

### Option B: Using Docker directly

```bash
mkdir my-project
cd my-project

docker run -it --rm \
  -v $(pwd):/workspace \
  spec-kit:latest \
  specify init --here --ai copilot
```

### Option C: Using Makefile

```bash
make init
# Follow the prompts
```

## Step 4: Start Using Spec-Kit

After initialization, you'll have a `.specify/` directory with templates and scripts.

### Available Commands

Once inside your AI coding agent, you can use:

- `/speckit.constitution` - Establish project principles
- `/speckit.specify` - Create feature specifications
- `/speckit.plan` - Generate implementation plans
- `/speckit.tasks` - Break down into actionable tasks
- `/speckit.implement` - Execute the implementation

### Example Workflow

1. **Define your feature:**
   ```
   /speckit.specify Build a photo album organizer that lets users create albums 
   grouped by date and rearrange them via drag-and-drop.
   ```

2. **Create technical plan:**
   ```
   /speckit.plan Use React with TypeScript, Vite for bundling, and SQLite 
   for local storage. Keep dependencies minimal.
   ```

3. **Generate tasks:**
   ```
   /speckit.tasks
   ```

4. **Implement:**
   ```
   /speckit.implement
   ```

## Working with the Container

### Interactive Shell

```bash
# Start a shell in the container
docker run -it --rm \
  -v $(pwd):/workspace \
  spec-kit:latest bash

# Inside the container:
specify check
specify init my-project --ai claude
cd my-project
ls -la .specify/
```

### With Git Configuration

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gitconfig:/root/.gitconfig:ro \
  spec-kit:latest bash
```

### With Docker Compose

```bash
# Start the container
docker-compose up -d

# Execute commands
docker-compose exec spec-kit bash

# Stop the container
docker-compose down
```

## Common Use Cases

### Creating Multiple Projects

```bash
# Project 1
mkdir web-app && cd web-app
docker run -it --rm -v $(pwd):/workspace spec-kit:latest \
  specify init --here --ai copilot

# Project 2
cd ..
mkdir mobile-app && cd mobile-app
docker run -it --rm -v $(pwd):/workspace spec-kit:latest \
  specify init --here --ai claude
```

### Checking System Requirements

```bash
docker run --rm spec-kit:latest specify check
```

### Getting Help

```bash
# General help
docker run --rm spec-kit:latest specify --help

# Command-specific help
docker run --rm spec-kit:latest specify init --help
```

## Troubleshooting

### Container Exits Immediately

If the container exits right after starting:
```bash
# Make sure to use -it flags for interactive mode
docker run -it --rm spec-kit:latest bash
```

### Permission Issues

If you encounter permission issues with mounted volumes:
```bash
# Run as current user
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  spec-kit:latest bash
```

### Cannot Access Files

Make sure the volume is mounted correctly:
```bash
# Verify mount
docker run --rm -v $(pwd):/workspace spec-kit:latest ls -la /workspace
```

## Next Steps

1. Read the [full README](README.md) for detailed documentation
2. Visit [spec-kit documentation](https://github.com/github/spec-kit) for methodology details
3. Check out [spec-driven development guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)

## Quick Reference

| Command | Description |
|---------|-------------|
| `make build` | Build the Docker image |
| `make run` | Start interactive shell |
| `make check` | Check installed tools |
| `make init` | Initialize new project |
| `make clean` | Remove Docker images |
| `./examples.sh` | Run interactive examples |

## Tips

- Always mount your project directory with `-v $(pwd):/workspace`
- Use `-it` flags for interactive commands
- Mount your git config for commit operations
- Use docker-compose for persistent development sessions

Happy spec-driven development! 🚀
