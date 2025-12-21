# Pandoc Document Converter Feature

Installs a command-line wrapper for [Pandoc](https://github.com/jgm/pandoc), a universal document converter that runs in a Docker container. This feature makes it easy to convert documents between various formats directly from your dev container.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pandoc:1.0.0": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the Pandoc Docker image to use |
| `imageName` | string | `pandoc/extra` | Docker image name for Pandoc |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pandoc:1.0.0": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pandoc:1.0.0": {
      "version": "3.1.9"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pandoc:1.0.0": {
      "imageName": "pandoc/latex",
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
    "ghcr.io/ruanzx/devcontainer-features/pandoc:1.0.0": {}
  }
}
```

## Commands Available

After installation, the `pandoc` command is available to convert documents:

### Basic Conversion

```bash
# Convert Markdown to HTML
pandoc input.md -o output.html

# Convert Markdown to PDF (requires LaTeX in the image)
pandoc input.md -o output.pdf

# Convert DOCX to Markdown
pandoc input.docx -o output.md
```

### With Options

```bash
# Convert with table of contents
pandoc input.md --toc -o output.html

# Convert with custom CSS
pandoc input.md -c styles.css -o output.html

# Convert to different formats
pandoc input.md -o output.docx  # Markdown to Word
pandoc input.md -o output.tex   # Markdown to LaTeX
pandoc input.md -o output.epub  # Markdown to EPUB
```

### Help

```bash
# Show help message
pandoc --help

# List supported formats
pandoc --list-input-formats
pandoc --list-output-formats
```

## Environment Variables

You can customize the Docker image used by setting environment variables:

```bash
# Use a different Docker image
export PANDOC_IMAGE_NAME="pandoc/latex"
export PANDOC_IMAGE_TAG="3.1.9"

pandoc input.md -o output.pdf
```

## How It Works

1. The feature installs a wrapper script at `/usr/local/bin/pandoc`
2. When you run `pandoc`, it executes the Pandoc Docker container with appropriate volume mounts
3. The script automatically handles:
   - Path translation between dev container and host (when running in a dev container)
   - Volume mounting for input and output files
   - Docker image pulling (if not already present)
4. The converted document is saved to your specified output path

## Dev Container Integration

When running inside a dev container, the wrapper automatically:
- Detects the dev container environment
- Translates container paths to host paths for Docker volume mounting
- Ensures proper file access between the dev container and the Pandoc Docker container

## Verification

After installation, verify that Pandoc is working:

```bash
# Check if pandoc command is available
which pandoc

# View help message
pandoc --help

# Test conversion
echo "# Test Document" > test.md
pandoc test.md -o test.html
```

## Troubleshooting

### Docker Not Running

If you see "Docker is not running", ensure Docker is started:

```bash
docker info
```

### Image Not Found

If the Pandoc image is not found, it will be automatically pulled on first use. You can also pull it manually:

```bash
docker pull pandoc/extra:latest
```

### Permission Issues

If you encounter permission issues, ensure your user has access to Docker:

```bash
docker ps
```

## License

This feature installs a wrapper for Pandoc. Check the [Pandoc project](https://github.com/jgm/pandoc) for its licensing information.