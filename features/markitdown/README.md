# MarkItDown Feature

This feature installs [MarkItDown](https://github.com/microsoft/markitdown), a utility for converting various file formats to Markdown. MarkItDown is particularly useful for LLM workflows and text analysis pipelines where you need to convert documents, PDFs, images, and other files into clean Markdown format.

## Description

MarkItDown is a lightweight Python utility that converts various files to Markdown while preserving important document structure. It's designed to be consumed by text analysis tools and LLMs, making it ideal for document processing workflows in development containers.

**Supported file formats:**
- PDF documents
- Microsoft Office files (Word, PowerPoint, Excel)
- Images (with OCR and EXIF metadata extraction)
- Audio files (with speech transcription)
- HTML files
- Text-based formats (CSV, JSON, XML)
- ZIP archives
- YouTube URLs
- EPUB files
- And more!

## Use Cases

- **Document Processing**: Convert various file formats to Markdown for LLM consumption
- **Content Analysis**: Extract structured text from documents for analysis
- **Documentation Workflows**: Convert existing documents to Markdown format
- **Data Pipeline**: Process mixed file types in automated workflows
- **Research Tools**: Extract text content from academic papers and documents

## Prerequisites

- **Python 3.10+**: MarkItDown requires Python 3.10 or higher
- **Python DevContainer Feature**: This feature automatically installs after the Python feature

## Options

### `version` (string)
Specify the version of MarkItDown to install.

- **Default**: `"latest"`
- **Example**: `"0.1.1"`
- **Description**: Install a specific version or use "latest" for the most recent version

### `extras` (string)
Specify which optional dependencies to install.

- **Default**: `"all"`
- **Options**: 
  - `"all"` - Install all optional dependencies (recommended)
  - `"pdf,docx,pptx"` - Install specific format support
  - `"none"` - Install base package only
- **Available extras**: `pdf`, `docx`, `pptx`, `xlsx`, `xls`, `outlook`, `audio-transcription`, `youtube-transcription`, `az-doc-intel`

### `enablePlugins` (boolean)
Enable MarkItDown plugins by default.

- **Default**: `false`
- **Description**: When true, plugins will be enabled by default in CLI usage

## Basic Usage

### Install with All Features

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markitdown:latest": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "version": "0.1.1"
    }
  }
}
```

### Install with Specific Format Support

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "extras": "pdf,docx,pptx"
    }
  }
}
```

### Enable Plugins by Default

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "enablePlugins": true
    }
  }
}
```

## Advanced Usage

### Complete Development Setup

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "version": "latest",
      "extras": "all",
      "enablePlugins": true
    }
  }
}
```

### Minimal Installation

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "extras": "none"
    }
  }
}
```

## Command Line Usage

After installation, MarkItDown provides a command-line interface:

### Basic File Conversion

```bash
# Convert a PDF to Markdown
markitdown document.pdf > output.md

# Convert with output file specification
markitdown presentation.pptx -o output.md

# Convert multiple files
markitdown *.pdf
```

### Using Pipes

```bash
# Pipe content through MarkItDown
cat document.pdf | markitdown > output.md
```

### Plugin Management

```bash
# List available plugins
markitdown --list-plugins

# Use plugins for conversion
markitdown --use-plugins document.pdf
```

### Azure Document Intelligence

```bash
# Use Azure Document Intelligence for better PDF conversion
markitdown document.pdf -o output.md -d -e "<azure_endpoint>"
```

## Python API Usage

MarkItDown can also be used programmatically in Python:

### Basic Usage

```python
from markitdown import MarkItDown

# Initialize MarkItDown
md = MarkItDown()

# Convert a file
result = md.convert("document.pdf")
print(result.text_content)
```

### With Azure Document Intelligence

```python
from markitdown import MarkItDown

# Use Azure Document Intelligence
md = MarkItDown(docintel_endpoint="<azure_endpoint>")
result = md.convert("document.pdf")
print(result.text_content)
```

### With LLM for Image Descriptions

```python
from markitdown import MarkItDown
from openai import OpenAI

# Use OpenAI for image descriptions
client = OpenAI()
md = MarkItDown(llm_client=client, llm_model="gpt-4o")
result = md.convert("image.jpg")
print(result.text_content)
```

### Enable Plugins

```python
from markitdown import MarkItDown

# Enable plugins
md = MarkItDown(enable_plugins=True)
result = md.convert("document.pdf")
print(result.text_content)
```

## Configuration Examples

### Document Processing Pipeline

```json
{
  "name": "Document Processing Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.12",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "version": "latest",
      "extras": "all",
      "enablePlugins": true
    },
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "pandoc,poppler-utils,tesseract-ocr"
    }
  }
}
```

### Research Environment

```json
{
  "name": "Academic Research Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.12",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/ruanzx/features/markitdown:latest": {
      "extras": "pdf,docx,audio-transcription"
    }
  }
}
```

## Verification

After installation, verify MarkItDown is working:

```bash
# Check CLI availability
markitdown --version

# Test conversion
echo "# Test Document" > test.md
markitdown test.md

# Test Python import
python3 -c "import markitdown; print('MarkItDown is ready!')"
```

## Troubleshooting

### Python Version Issues
- Ensure Python 3.10+ is installed
- MarkItDown requires modern Python features

### Missing Dependencies
- Install with `extras: "all"` for full functionality
- Specific format support may require additional system packages

### Permission Issues
- Ensure the container has write permissions for output files
- Some file formats may require additional system libraries

## Related Features

- **[Python Feature](https://github.com/devcontainers/features/tree/main/src/python)**: Required dependency
- **[APT Feature](../apt)**: Install additional system packages for file processing
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Basic system utilities

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature follows the same license as the parent repository. MarkItDown itself is licensed under the MIT License.

---

**Note**: MarkItDown is developed by Microsoft and the AutoGen team. This feature provides a convenient way to install it in development containers. For the latest information about MarkItDown, visit the [official repository](https://github.com/microsoft/markitdown).
