# Quick Start Guide

This guide helps you quickly test the BMAD-METHOD Docker example.

## Prerequisites

- Docker installed and running
- VS Code with Remote - Containers extension

## Steps

### 1. Open in Dev Container

```bash
# Navigate to this example
cd examples/bmad-method-docker

# Open in VS Code
code .
```

Then:
1. Press `F1` or `Ctrl+Shift+P`
2. Select "Dev Containers: Reopen in Container"
3. Wait for the container to build and start

### 2. Verify Installation

After the container starts, the `postCreateCommand` will run:

```bash
bmad --version && bmad help
```

You should see:
- BMAD version number (e.g., 4.44.3)
- BMAD command help output

### 3. Test BMAD Commands

```bash
# Check status
bmad status

# List expansion packs
bmad list:expansions

# Show help
bmad help
```

### 4. Initialize BMAD in a Project

```bash
# Install BMAD-METHOD framework
bmad install

# Verify installation
bmad status
```

### 5. Explore Features

Try these npm scripts defined in `package.json`:

```bash
npm run bmad:status      # Check BMAD status
npm run bmad:expansions  # List expansion packs
npm run bmad:flatten     # Flatten codebase
```

## What's Happening Behind the Scenes

1. **Feature Installation**: The `bmad-method-in-docker` feature installs a wrapper script at `/usr/local/bin/bmad`
2. **Docker Execution**: When you run `bmad`, it executes `docker run --rm -v $PWD:/workspace ruanzx/bmad [args]`
3. **Workspace Mounting**: Your current directory is mounted to `/workspace` in the container
4. **Path Translation**: If running in a dev container, paths are automatically translated to host paths

## Troubleshooting

### Docker Not Available

```bash
# Check Docker is running
docker info
```

### BMAD Command Not Found

```bash
# Verify installation
which bmad

# Reinstall if needed
cd /workspaces/devcontainer-templates
./devcontainer-features.sh build bmad-method-in-docker
```

### Permission Issues

```bash
# Check Docker access
docker ps
```

## Next Steps

1. Read the main [README.md](README.md) for detailed usage
2. Check the [BMAD-METHOD documentation](https://github.com/bmad-code-org/BMAD-METHOD)
3. Explore [expansion packs](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/expansion-packs.md)
4. Join the [Discord community](https://discord.gg/gk8jAdXWmj)

## Feedback

Found an issue or have suggestions? Please open an issue in the repository!
