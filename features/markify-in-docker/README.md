# Markify (in Docker) Feature

Installs a command-line wrapper for [Markify](https://github.com/ruanzx/markify), a tool that converts HTML files, URLs, and raw HTML strings to Markdown format. Markify runs inside a Docker container, so no additional runtime dependencies are required on the host.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markify-in-docker:latest": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version tag of the Markify Docker image to use |
| `cleanCache` | boolean | `true` | Clean Docker layer cache after pulling the image |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markify-in-docker:latest": {}
  }
}
```

### Pin to a Specific Image Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markify-in-docker:latest": {
      "version": "1.2.0"
    }
  }
}
```

### Skip Cache Cleanup

```json
{
  "features": {
    "ghcr.io/ruanzx/features/markify-in-docker:latest": {
      "cleanCache": false
    }
  }
}
```

## Requirements

This feature requires Docker to be available in the dev container. Install it using the `docker-outside-of-docker` feature before this feature:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/features/markify-in-docker:latest": {}
  }
}
```

## Using markify

After installation, the `markify` command is available in your terminal. The current working directory is automatically mounted into the container at `/data`, so relative file paths work as expected.

### Convert a URL to Markdown

```bash
# Fetch a webpage and convert its HTML to Markdown
markify html --url "https://example.com/article" --output article.md
```

### Convert a Local HTML File

```bash
# Convert a local HTML file to Markdown
markify html --file input.html --output output.md
```

### Convert Raw HTML String

```bash
# Convert an inline HTML string
markify html --html "<h1>Hello</h1><p>World</p>"
```

### Use SmartReader to Extract Article Content

```bash
# Extract just the main article body before converting
markify html --url "https://example.com/blog-post" --smart-reader --output post.md
```

### Download Images Alongside the Markdown

```bash
markify html --url "https://example.com/article" --download-images --output article.md
```

### Get Help

```bash
markify --help
```

## Verification

Confirm the feature is installed correctly:

```bash
markify --version
```

or:

```bash
which markify && echo "markify is installed"
```

## Environment Variables

The wrapper respects the following environment variables, allowing you to override the image without reinstalling the feature:

| Variable | Default | Description |
|----------|---------|-------------|
| `MARKIFY_IMAGE_NAME` | `ruanzx/markify` | Docker image name |
| `MARKIFY_IMAGE_TAG` | `latest` | Docker image tag |
