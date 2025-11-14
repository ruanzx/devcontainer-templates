# OpenSpec (Docker) Feature

Installs [OpenSpec](https://github.com/Fission-AI/OpenSpec), a spec-driven development tool for AI coding assistants, that runs in a Docker container. This feature makes it easy to run OpenSpec directly from your dev container without needing Node.js dependencies.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the OpenSpec Docker image to use |
| `imageName` | string | `ruanzx/openspec` | Docker image name for OpenSpec |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {
      "version": "0.15.0"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {
      "imageName": "myorg/custom-openspec",
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
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {}
  }
}
```

## Commands Available

After installation, the `openspec` command is available to run OpenSpec:

### Initialize OpenSpec in Current Directory

```bash
# Initialize OpenSpec in the current workspace
openspec init
```

### List Active Changes

```bash
# View active change folders
openspec list
```

### Show Change Details

```bash
# Display change details (proposal, tasks, spec updates)
openspec show <change-name>
```

### Validate Change

```bash
# Check spec formatting and structure
openspec validate <change-name>
```

### Archive Completed Change

```bash
# Move a completed change into archive/
openspec archive <change-name> --yes
```

### Help

```bash
# Show help message
openspec --help
```

## How It Works

1. The feature installs a wrapper script at `/usr/local/bin/openspec`
2. When you run `openspec`, it:
   - Executes the OpenSpec Docker container with your workspace mounted
   - Passes all commands through to the containerized OpenSpec
3. The script automatically handles:
   - Path translation between dev container and host (when running in a dev container)
   - Volume mounting for workspace access
   - Docker image pulling (if not already present)
4. All OpenSpec files and outputs remain in your workspace

**Note**: To get the latest OpenSpec version, rebuild and push the Docker image with `npm install -g @fission-ai/openspec@latest`

## Dev Container Integration

When running inside a dev container, the wrapper automatically:
- Detects the dev container environment
- Translates container paths to host paths for Docker volume mounting
- Ensures proper file access between the dev container and the OpenSpec Docker container
- Mounts your workspace so OpenSpec can read and write files

## Environment Variables

You can customize the Docker image used by setting environment variables:

```bash
# Use a different Docker image
export OPEN_SPEC_IMAGE_NAME="myorg/custom-openspec"
export OPEN_SPEC_IMAGE_TAG="0.15.0"

openspec init
```

## Getting Started

1. **Initialize OpenSpec in your project**:
   ```bash
   cd /workspace/my-project
   openspec init
   ```

2. **Create your first change proposal**:
   - Ask your AI assistant to create an OpenSpec change proposal
   - Use slash commands if supported (e.g., `/openspec:proposal`)

3. **Work through the OpenSpec workflow**:
   - Review and refine specifications
   - Implement tasks with AI assistance
   - Archive completed changes

## Workflow Overview

### Planning Phase
- Create a change proposal that captures spec updates
- Review the proposal with your AI assistant until everyone agrees

### Implementation Phase
- Implement tasks that reference the agreed specs
- Use AI tools with OpenSpec integration for consistent development

### Completion Phase
- Archive the change to merge approved updates back into source specs

## Verification

After installation, verify that OpenSpec is working:

```bash
# Check if openspec command is available
which openspec

# View help message
openspec --help

# Test initialization
cd /tmp/test-openspec
openspec init
```

## Troubleshooting

### Docker Not Running

If you see "Docker is not running", ensure Docker is started:

```bash
docker info
```

### Update to Latest OpenSpec

To use the latest OpenSpec version:

1. Pull the latest Docker image:
```bash
docker pull ruanzx/openspec:latest
```

2. Or set the version explicitly:
```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {
      "version": "0.15.0"
    }
  }
}
```

### Check Current OpenSpec Version

```bash
openspec --version
```

### Image Not Found

If the OpenSpec Docker image is not found locally, it will be automatically pulled on first use:

```bash
docker pull ruanzx/openspec:latest
```

### Permission Issues

If you encounter permission issues, ensure your user has access to Docker:

```bash
docker ps
```

### Workspace Files Not Accessible

The wrapper mounts your current working directory to `/workspace` in the container. Ensure you're running `openspec` commands from within your project directory.

## Comparison with Native Installation

| Feature | Docker (this feature) | Native (openspec) |
|---------|----------------------|------------------|
| Node.js Required | ❌ No (in container) | ✅ Yes (v20.19.0+) |
| npm Required | ❌ No (in container) | ✅ Yes |
| Installation Size | Smaller (wrapper only) | Larger (full dependencies) |
| Isolation | ✅ Fully isolated | ❌ Uses host Node.js |
| Updates | Manual (rebuild/pull image) | ❌ Manual (npm update) |
| Startup Time | Fast | Fast |
| Best For | Docker-based workflows | Node.js developers |

## Resources

- **Documentation**: [OpenSpec.dev](https://openspec.dev/)
- **Repository**: [GitHub](https://github.com/Fission-AI/OpenSpec)
- **Discord**: [Community Chat](https://discord.gg/YctCnvvshC)

## Support

- 💬 [Discord Community](https://discord.gg/YctCnvvshC)
- 🐛 [Issue Tracker](https://github.com/Fission-AI/OpenSpec/issues)
- 💬 [Discussions](https://github.com/Fission-AI/OpenSpec/discussions)

## Example DevContainer Configuration

```json
{
    "name": "OpenSpec Development Environment (Docker)",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
        "ghcr.io/ruanzx/devcontainer-features/openspec-in-docker:1.0.0": {
            "version": "latest"
        }
    }
}
```

## License

This feature installs a wrapper for OpenSpec. Check the [OpenSpec project](https://github.com/Fission-AI/OpenSpec) for its licensing information.