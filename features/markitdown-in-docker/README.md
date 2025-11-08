# MarkItDown (Docker)

Installs a Docker-based wrapper for [MarkItDown](https://github.com/microsoft/markitdown), Microsoft's tool for converting various file formats (PDF, PowerPoint, Word, Excel, images, audio, HTML, and more) to Markdown.

## Description

This feature provides a command-line wrapper that runs MarkItDown in a Docker container, making it easy to convert documents without installing Python dependencies directly in your development environment.

## Example Usage

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/ruanzx/features/markitdown-in-docker:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Docker image tag for markitdown |
| `imageName` | string | `ruanzx/markitdown` | Docker image name |

## Usage Examples

### Basic Conversion

Convert a document to Markdown (output to stdout):

```bash
markitdown document.pdf
markitdown presentation.pptx
markitdown spreadsheet.xlsx
markitdown image.jpg
```

### Save to File

Convert and save to a Markdown file:

```bash
markitdown document.pdf -o document.md
markitdown report.docx -o report.md
```

### Pipe Input

Convert from stdin with file extension hint:

```bash
cat document.html | markitdown -x html
curl -s https://example.com | markitdown -x html
```

### Stdin Redirection

```bash
markitdown < document.html -x html > output.md
```

### Get Help

Show wrapper-specific help:

```bash
markitdown --wrapper-help
```

Show markitdown CLI help:

```bash
markitdown --help
```

Check version:

```bash
markitdown --version
```

## Supported File Formats

MarkItDown can convert:

- **Documents**: PDF, DOCX, PPTX, XLSX
- **Images**: JPG, PNG (with OCR via Tesseract if available)
- **Audio**: MP3, WAV (transcription via speech recognition)
- **Web**: HTML, MHTML
- **Archives**: ZIP (extracts and converts contents)
- **Code**: Various programming languages
- **Text**: CSV, JSON, XML, and more

## Environment Variables

Customize the Docker image:

```bash
# Use a specific version
export MARKITDOWN_IMAGE_TAG=0.1.2
markitdown document.pdf

# Use a custom image
export MARKITDOWN_IMAGE_NAME=my-registry/markitdown
export MARKITDOWN_IMAGE_TAG=custom
markitdown document.pdf
```

## Advanced Options

MarkItDown supports various advanced options that can be passed through the wrapper:

```bash
# Provide MIME type hint
markitdown file.dat -m application/pdf

# Provide charset hint
markitdown file.txt -c UTF-8

# Keep data URIs in output
markitdown image.png --keep-data-uris

# Use Azure Document Intelligence
markitdown document.pdf -d -e https://your-endpoint.cognitiveservices.azure.com/

# Use 3rd-party plugins
markitdown document.pdf -p --list-plugins
```

## How It Works

1. The wrapper mounts your current directory as `/data` in the Docker container
2. Files are accessed relative to your current working directory
3. Output is returned to stdout or saved to the specified file
4. In DevContainer environments, the wrapper automatically translates paths for proper Docker-in-Docker operation

## Upgrading

To use a newer version of markitdown, pull a new Docker image:

```bash
# Update to specific version
export MARKITDOWN_IMAGE_TAG=0.1.3
markitdown document.pdf

# Or pull manually
docker pull ruanzx/markitdown:latest
```

## Comparison with markitdown Feature

This repository also provides a `markitdown` feature that installs markitdown directly using pip. Choose based on your needs:

| Feature | markitdown | markitdown-in-docker |
|---------|-----------|---------------------|
| Installation | Python/pip | Docker wrapper |
| Isolation | Direct install | Containerized |
| Performance | Faster | Slight overhead |
| Dependencies | Requires Python | Only needs Docker |
| Upgrades | `pip install --upgrade` | Pull new image |
| Best for | Python environments | Any environment with Docker |

## Troubleshooting

### File Not Found Errors

Make sure you're in the correct directory or use relative paths:

```bash
cd /path/to/documents
markitdown mydoc.pdf
```

### Docker Not Running

The wrapper requires Docker to be running:

```bash
# Check Docker status
docker info

# In DevContainers, ensure docker-outside-of-docker feature is installed
```

### Permission Issues

If you get permission errors, ensure the files are readable:

```bash
chmod +r document.pdf
markitdown document.pdf
```

## Dependencies

- Docker must be available and running
- In DevContainer environments, use the `ghcr.io/devcontainers/features/docker-outside-of-docker` feature

## Notes

- The wrapper automatically detects DevContainer environments and translates paths
- All file operations happen in the context of your current working directory
- The Docker container has read/write access to your current directory
- Standard markitdown options and flags are passed through transparently

## Additional Resources

- [MarkItDown GitHub Repository](https://github.com/microsoft/markitdown)
- [MarkItDown Documentation](https://github.com/microsoft/markitdown#readme)
- [Docker Image Source](https://github.com/ruanzx/devcontainer-templates/tree/main/features/markitdown-in-docker/docker)

## Example DevContainer Configuration

Complete example with Docker support:

```json
{
    "name": "Document Processing Environment",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
        "ghcr.io/ruanzx/features/markitdown-in-docker:latest": {
            "version": "latest"
        }
    },
    "postCreateCommand": "markitdown --version"
}
```

## License

This feature follows the same license as the parent repository. MarkItDown is licensed under the MIT License by Microsoft.
