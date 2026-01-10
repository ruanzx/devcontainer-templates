# Docling Document Converter Example

This example demonstrates how to use the `docling-in-docker` DevContainer feature to convert various document formats to markdown.

## What's Included

This dev container includes:

- **Docker-outside-of-Docker**: Enables running Docker containers from within the dev container
- **Docling**: Document converter that supports PDF, DOCX, PPTX, images, and many other formats

## Getting Started

1. **Open in Dev Container**: Open this folder in VS Code and reopen in container when prompted

2. **Wait for Installation**: The container will build and install the Docling feature automatically

3. **Verify Installation**: After the container is ready, you should see the help message from the `postCreateCommand`

## Using Docling

### Basic Usage

Convert any supported document to markdown:

```bash
# Convert a PDF document
docling document.pdf

# Convert with custom output name
docling document.pdf output.md
docling -o output.md document.pdf

# Convert Word documents
docling report.docx

# Convert presentations
docling slides.pptx
```

### Supported Formats

Docling can convert:

- **PDF files** - With advanced OCR and table extraction
- **Microsoft Office** - Word (.docx), PowerPoint (.pptx), Excel (.xlsx)
- **Images** - PNG, JPEG, etc. with OCR support
- **HTML files**
- **Markdown** - For reformatting
- **CSV files**
- And many more...

### Example Workflow

1. **Add test files** to this directory (e.g., copy a PDF or DOCX file here)

2. **Convert the file**:
   ```bash
   docling your-document.pdf
   ```

3. **View the result**:
   ```bash
   cat your-document.md
   ```

### Advanced Features

The Docling converter provides:

- **High-quality markdown** output with proper formatting
- **Automatic OCR** for scanned documents and images
- **Table extraction** with accurate structure preservation
- **Embedded images** in the output
- **Formula extraction** with LaTeX support

### Configuration

Default settings are optimized for quality:

- Output format: Markdown
- Image export: Embedded (base64)
- OCR: Enabled with auto engine
- PDF backend: dlparse_v4 (most advanced)
- Table mode: Accurate

You can customize these by modifying the `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {
      "version": "1.9.0",
      "port": "8080"
    }
  }
}
```

## Testing the Feature

### Quick Test

1. Create a simple text file:
   ```bash
   echo "# Test Document\n\nThis is a test." > test.txt
   ```

2. Convert it:
   ```bash
   docling test.txt test.md
   ```

3. View the result:
   ```bash
   cat test.md
   ```

### With Real Documents

If you have PDF or DOCX files, try converting them:

```bash
# Download a sample PDF
curl -o sample.pdf "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"

# Convert it
docling sample.pdf

# Check the output
cat sample.md
```

## How It Works

1. When you run `docling`, it automatically:
   - Starts a temporary Docling service container
   - Sends your file to the service via REST API
   - Receives the converted markdown
   - Saves it to the output file
   - Stops the service container

2. The service runs on localhost (default port 5001) and is only accessible from within the dev container

3. Files are processed with optimal settings for quality and accuracy

## Environment Variables

Customize behavior using environment variables:

```bash
# Use specific image version
export DOCLING_IMAGE_TAG="1.9.0"

# Use different port
export DOCLING_PORT="8080"

# Then run conversion
docling document.pdf
```

## Troubleshooting

### Container won't start

Check Docker is running:
```bash
docker ps
```

### Port conflicts

If port 5001 is busy, change it:
```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/docling-in-docker:1": {
      "port": "5002"
    }
  }
}
```

### Conversion errors

- Verify input file exists and is readable
- Check file format is supported
- Try with a simpler document first

## Resources

- [Docling GitHub](https://github.com/docling-project/docling-serve)
- [Docling Documentation](https://github.com/docling-project/docling)
- [API Reference](https://github.com/docling-project/docling-serve#api)

## Next Steps

- Try converting your own documents
- Experiment with different input formats
- Integrate into your document processing workflow
- Use in CI/CD pipelines for automated conversions
