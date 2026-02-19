# Markify (in Docker) Example

This example demonstrates how to use the `markify-in-docker` DevContainer feature to convert HTML content from URLs, local files, and raw HTML strings into Markdown format.

## What is Markify?

[Markify](https://github.com/ruanzx/markify) is a command-line tool that converts:

- **Web pages** — fetches a URL and converts the HTML to clean Markdown
- **Local HTML files** — converts an existing `.html` file on disk
- **Raw HTML strings** — converts an inline HTML snippet directly

Markify optionally uses SmartReader to extract only the main article body from a page, and can download images to a local subfolder with relative Markdown paths.

The `markify-in-docker` feature installs a thin shell wrapper so you can run `markify` without managing any runtime dependencies — Docker does the heavy lifting.

## Getting Started

1. Open this folder in VS Code with the Dev Containers extension installed.
2. When prompted, click **Reopen in Container**.
3. Wait for the container to build (the first build pulls the `ruanzx/markify` Docker image).
4. Open a terminal inside the container and try the commands below.

## Example Commands

### 1. Convert a Web Page to Markdown

```bash
markify html --url "https://example.com" --output example.md
cat example.md
```

**Expected output:** A `example.md` file in the current directory containing the Markdown representation of the page.

---

### 2. Convert a Local HTML File

```bash
echo "<h1>Hello, Markify!</h1><p>This is a <strong>test</strong> paragraph.</p>" > test.html
markify html --file test.html --output test.md
cat test.md
```

**Expected output:**

```markdown
# Hello, Markify!

This is a **test** paragraph.
```

---

### 3. Convert Raw HTML from the Command Line

```bash
markify html --html "<h2>Quick Convert</h2><ul><li>Item A</li><li>Item B</li></ul>"
```

**Expected output** (written to stdout):

```markdown
## Quick Convert

- Item A
- Item B
```

---

### 4. Use SmartReader to Extract Article Content

```bash
markify html --url "https://en.wikipedia.org/wiki/Markdown" --smart-reader --output markdown-wiki.md
```

**Expected output:** A `markdown-wiki.md` file containing only the main article body, with navigation and sidebars removed.

---

### 5. Download Images Alongside Markdown

```bash
markify html --url "https://example.com/article-with-images" --download-images --output article.md
```

**Expected output:** An `article.md` file with image references pointing to a local `images/` subfolder in the current directory.

---

## Verify Installation

```bash
markify --help
```

## Override the Docker Image

Set environment variables to use a different image or tag without reinstalling the feature:

```bash
export MARKIFY_IMAGE_NAME="ruanzx/markify"
export MARKIFY_IMAGE_TAG="1.2.0"
markify html --url "https://example.com"
```
