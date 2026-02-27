# Docling (Document Converter) Feature

Installs a command-line wrapper for [Docling](https://github.com/docling-project/docling-serve), a powerful document converter that runs in a Docker container. This feature makes it easy to convert various document formats (PDF, DOCX, PPTX, images, etc.) to markdown directly from your dev container.

## Prerequisites

- **Docker**: Required for running the Docling service container
- **curl** and **jq**: Automatically installed if not present

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the Docling Docker image to use |
| `imageName` | string | `ghcr.io/docling-project/docling-serve` | Docker image name for Docling |
| `port` | string | `5001` | Port for the Docling service |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {
      "version": "1.9.0"
    }
  }
}
```

### Custom Port

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {
      "port": "8080"
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
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {}
  }
}
```

## Commands Available

After installation, the `docling` command is available to convert documents:

### Basic Conversion

```bash
# Convert a PDF to markdown (output will be document.md)
docling document.pdf

# Specify custom output file
docling document.pdf output.md
docling -o output.md document.pdf
```

### Supported Input Formats

Docling supports a wide variety of input formats:

- **PDF documents** - With advanced OCR and table extraction
- **Microsoft Office** - Word (.docx), PowerPoint (.pptx), Excel (.xlsx)
- **Images** - PNG, JPEG, etc. (with OCR support)
- **HTML files**
- **Markdown** - For reformatting
- **CSV files**
- **And many more...**

### Examples

```bash
# Convert a Word document
docling report.docx

# Convert a presentation
docling slides.pptx presentation.md

# Convert a scanned PDF with OCR
docling scanned_document.pdf

# Convert an image with text
docling screenshot.png
```

## Features

The Docling converter provides:

- **High-quality markdown output** with proper formatting
- **OCR support** for scanned documents and images (auto-detection)
- **Table extraction** with accurate structure preservation
- **Image embedding** in the markdown output
- **Formula extraction** with LaTeX support
- **Multi-format support** - PDF, DOCX, PPTX, images, and more

## Default Settings

The wrapper is configured with these optimal defaults:

- **Output format**: Markdown
- **Image export mode**: Embedded (images included as base64)
- **OCR**: Enabled with auto engine selection
- **PDF backend**: dlparse_v4 (most advanced)
- **Table mode**: Accurate (best quality)
- **Continue on error**: Yes

## How It Works

1. The `docling` command starts a temporary Docling service container
2. A persistent Docker volume (`docling-models-cache`) is mounted to cache OCR and AI models
3. Files are submitted via the async REST API to avoid server-side timeouts
4. The wrapper polls for completion, then retrieves the converted result
5. The converted markdown is saved to the specified output file
6. The service container is automatically stopped when done

## Environment Variables

You can customize behavior using environment variables:

```bash
# Use a different image
export DOCLING_IMAGE_NAME="ghcr.io/docling-project/docling-serve"
export DOCLING_IMAGE_TAG="1.9.0"

# Use a different port
export DOCLING_PORT="8080"

# Then run conversion
docling document.pdf
```

## Troubleshooting

### Service won't start

If you see "Service failed to start within timeout":

1. Check Docker is running: `docker ps`
2. Check port availability: `netstat -an | grep 5001`
3. Try pulling the image manually: `docker pull ghcr.io/docling-project/docling-serve:latest`

### Conversion fails

If conversion fails:

1. Verify the input file exists and is readable
2. Check the file format is supported
3. Look for error messages in the output
4. Try with a different input file to isolate the issue

### Out of memory

For large documents, the Docling service may need more memory. You can run it manually with more resources:

```bash
docker run -d --rm --name docling-serve \
  --memory="4g" \
  -p 5001:5001 \
  ghcr.io/docling-project/docling-serve:latest
```

## Notes

- The Docker image will be pulled automatically on first use if not already present
- The service starts fresh for each conversion to ensure clean state
- **Model cache is persisted** in Docker volume `docling-models-cache` across runs, so OCR/AI models are only downloaded once
- Uses the **async API** (`/v1/convert/file/async`) with polling to avoid 504 Gateway Timeout on large documents
- Conversion quality is excellent for most document types
- Processing time varies based on document complexity and length
- To clear the model cache: `docker volume rm docling-models-cache`

## Resources

- [Docling GitHub Repository](https://github.com/docling-project/docling-serve)
- [Docling Documentation](https://github.com/docling-project/docling)
- [API Reference](https://github.com/docling-project/docling-serve#api)
