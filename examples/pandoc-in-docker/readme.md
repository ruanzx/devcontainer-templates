# Pandoc Document Converter Example

This example demonstrates how to use the Pandoc feature in a dev container to convert documents between various formats.

## Getting Started

1. Open this folder in VS Code
2. When prompted, click "Reopen in Container" to build the dev container
3. The dev container will include Pandoc with Docker support

## Usage Examples

Once the dev container is running, you can use Pandoc to convert documents:

### Convert Markdown to HTML

```bash
pandoc document.md -o document.html
```

### Convert Markdown to PDF

```bash
pandoc document.md -o document.pdf
```

### Convert DOCX to Markdown

```bash
pandoc document.docx -o document.md
```

### Convert with Table of Contents

```bash
pandoc document.md --toc -o document.html
```

### Convert Multiple Files

```bash
pandoc chapter1.md chapter2.md -o book.html
```

## Supported Formats

Pandoc supports conversion between many formats including:

- Markdown
- HTML
- LaTeX
- PDF (requires LaTeX)
- Microsoft Word (DOCX)
- OpenDocument (ODT)
- EPUB
- And many more...

## Features

This dev container includes:

- Pandoc document converter
- Docker support for running Pandoc in containers
- VS Code extensions for JSON and Markdown editing

## Testing

Try converting the sample file:

```bash
pandoc sample.md -o sample.html
```

## Requirements

- Docker must be available (automatically included via docker-outside-of-docker feature)
- The Pandoc Docker image will be downloaded on first use