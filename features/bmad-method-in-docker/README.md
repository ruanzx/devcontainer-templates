# BMAD-METHOD (Docker) Feature

Installs a command-line wrapper for [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD), a Universal AI Agent Framework for Agentic Agile Driven Development that runs in a Docker container. This feature makes it easy to run BMAD-METHOD directly from your dev container without needing Node.js dependencies.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the BMAD-METHOD Docker image to use |
| `imageName` | string | `ruanzx/bmad` | Docker image name for BMAD-METHOD |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {
      "version": "1.2.3"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {
      "imageName": "myorg/custom-bmad",
      "version": "latest"
    }
  }
}
```

## Requirements

This feature requires Docker to be available. It should be installed after the `docker-outside-of-docker` feature:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {}
  }
}
```

## Commands Available

After installation, the `bmad` command is available to run BMAD-METHOD:

### Install BMAD-METHOD in Current Directory

```bash
# Initialize BMAD-METHOD in the current workspace
bmad install
```

### Check Version

```bash
# Show BMAD-METHOD version
bmad --version
```

### Run BMAD-METHOD Commands

```bash
# All commands are passed through to BMAD-METHOD in the container
bmad *analyst     # Run analyst agent
bmad *pm          # Run project manager agent
bmad *architect   # Run architect agent
```

### Help

```bash
# Show help message
bmad --help
```

## How It Works

1. The feature installs a wrapper script at `/usr/local/bin/bmad`
2. When you run `bmad`, it executes the BMAD-METHOD Docker container with:
   - Current working directory mounted to `/workspace` in the container
   - All commands passed through to the containerized BMAD-METHOD
3. The script automatically handles:
   - Path translation between dev container and host (when running in a dev container)
   - Volume mounting for workspace access
   - Docker image pulling (if not already present)
4. All BMAD-METHOD files and outputs remain in your workspace

## Dev Container Integration

When running inside a dev container, the wrapper automatically:
- Detects the dev container environment
- Translates container paths to host paths for Docker volume mounting
- Ensures proper file access between the dev container and the BMAD-METHOD Docker container
- Mounts your workspace so BMAD-METHOD can read and write files

## Environment Variables

You can customize the Docker image used by setting environment variables:

```bash
# Use a different Docker image
export BMAD_IMAGE_NAME="myorg/custom-bmad"
export BMAD_IMAGE_TAG="1.2.3"

bmad install
```

## Getting Started

1. **Install BMAD-METHOD in your project**:
   ```bash
   cd /workspace/my-project
   bmad install
   ```

2. **Start with Web UI** (fastest):
   - Get a [full stack team file](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/dist/teams/team-fullstack.txt)
   - Create a new Gemini Gem or CustomGPT
   - Upload the file and set instructions
   - Start with `*help` or `*analyst` commands

3. **Use in IDE**:
   - Run `bmad install` to set up the framework
   - Use agent commands like `*analyst`, `*pm`, `*architect`
   - Generate documentation and development stories

## Workflow Overview

### Planning Phase (Web UI)
- Create Product Requirements Document (PRD)
- Design Architecture documentation
- Generate UX briefs (optional)

### Development Phase (IDE)
- Shard documentation into manageable pieces
- Use Scrum Master to create detailed stories
- Implement with Dev agent using story context
- Validate with QA agent

## Verification

After installation, verify that BMAD-METHOD is working:

```bash
# Check if bmad command is available
which bmad

# View help message
bmad --help

# Test installation
cd /tmp/test-bmad
bmad install
```

## Troubleshooting

### Docker Not Running

If you see "Docker is not running", ensure Docker is started:

```bash
docker info
```

### Image Not Found

If the BMAD-METHOD image is not found, it will be automatically pulled on first use. You can also pull it manually:

```bash
docker pull ruanzx/bmad:latest
```

### Permission Issues

If you encounter permission issues, ensure your user has access to Docker:

```bash
docker ps
```

### Workspace Files Not Accessible

The wrapper mounts your current working directory to `/workspace` in the container. Ensure you're running `bmad` commands from within your project directory.

## Comparison with Native Installation

| Feature | Docker (this feature) | Native (bmad-method) |
|---------|----------------------|---------------------|
| Node.js Required | ❌ No | ✅ Yes (v20+) |
| npm Required | ❌ No | ✅ Yes |
| Installation Size | Smaller (wrapper only) | Larger (full dependencies) |
| Isolation | ✅ Fully isolated | ❌ Uses host Node.js |
| Setup Speed | Faster | Slower (npm install) |
| Best For | Docker-based workflows | Node.js developers |

## Resources

- **Documentation**: [User Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md)
- **Architecture**: [Core Architecture](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/core-architecture.md)
- **Community**: [Discord Server](https://discord.gg/gk8jAdXWmj)
- **Repository**: [GitHub](https://github.com/bmad-code-org/BMAD-METHOD)
- **Expansion Packs**: [Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/expansion-packs.md)

## Support

- 💬 [Discord Community](https://discord.gg/gk8jAdXWmj)
- 🐛 [Issue Tracker](https://github.com/bmad-code-org/BMAD-METHOD/issues)
- 💬 [Discussions](https://github.com/bmad-code-org/BMAD-METHOD/discussions)

## Example DevContainer Configuration

```json
{
    "name": "BMAD-METHOD Development Environment (Docker)",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
        "ghcr.io/ruanzx/devcontainer-features/bmad-method-in-docker:1.0.0": {
            "version": "latest"
        }
    }
}
```

## License

This feature installs a wrapper for BMAD-METHOD. Check the [BMAD-METHOD project](https://github.com/bmad-code-org/BMAD-METHOD) for its licensing information.
