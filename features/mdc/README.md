# MDC (Markdown to DOCX Converter) Feature

Installs a command-line wrapper for [MDC](https://github.com/ruanzx/mdc), a Markdown to DOCX converter that runs in a Docker container. This feature makes it easy to convert Markdown files to Word documents directly from your dev container.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/mdc:1.0.0": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the MDC Docker image to use |
| `imageName` | string | `ruanzx/mdc` | Docker image name for MDC |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/mdc:1.0.0": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/mdc:1.0.0": {
      "version": "1.2.3"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/mdc:1.0.0": {
      "imageName": "myorg/custom-mdc",
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
    "ghcr.io/ruanzx/devcontainer-features/mdc:1.0.0": {}
  }
}
```

## Commands Available

After installation, the `mdc` command is available to convert Markdown to DOCX:

### Basic Conversion

```bash
# Convert a Markdown file to DOCX
mdc -i document.md -o document.docx
```

### With Template

```bash
# Convert using a Word template
mdc -i input.md -o output.docx -t template.docx
```

### Verbose Output

```bash
# Enable verbose logging
mdc -i report.md -o report.docx --verbose
```

### Help

```bash
# Show help message
mdc --help
```

## Command Options

| Option | Alias | Description | Required |
|--------|-------|-------------|----------|
| `--input-file FILE` | `-i` | Input Markdown file | Yes |
| `--output-file FILE` | `-o` | Output Word document | Yes |
| `--template FILE` | `-t` | Word template file | No |
| `--verbose` | `-v` | Enable verbose logging | No |
| `--help` | | Show help message | No |

## Environment Variables

You can customize the Docker image used by setting environment variables:

```bash
# Use a different Docker image
export MDC_IMAGE_NAME="myorg/custom-mdc"
export MDC_IMAGE_TAG="1.2.3"

mdc -i input.md -o output.docx
```

## How It Works

1. The feature installs a wrapper script at `/usr/local/bin/mdc`
2. When you run `mdc`, it executes the MDC Docker container with appropriate volume mounts
3. The script automatically handles:
   - Path translation between dev container and host (when running in a dev container)
   - Volume mounting for input, output, and template files
   - Docker image pulling (if not already present)
4. The converted DOCX file is saved to your specified output path

## Dev Container Integration

When running inside a dev container, the wrapper automatically:
- Detects the dev container environment
- Translates container paths to host paths for Docker volume mounting
- Ensures proper file access between the dev container and the MDC Docker container

## Verification

After installation, verify that MDC is working:

```bash
# Check if mdc command is available
which mdc

# View help message
mdc --help

# Test conversion (create a test Markdown file first)
echo "# Test Document" > test.md
mdc -i test.md -o test.docx
```

## Troubleshooting

### Docker Not Running

If you see "Docker is not running", ensure Docker is started:

```bash
docker info
```

### Image Not Found

If the MDC image is not found, it will be automatically pulled on first use. You can also pull it manually:

```bash
docker pull ruanzx/mdc:latest
```

### Permission Issues

If you encounter permission issues, ensure your user has access to Docker:

```bash
docker ps
```

## License

This feature installs a wrapper for MDC. Check the [MDC project](https://github.com/ruanzx/mdc) for its licensing information.
