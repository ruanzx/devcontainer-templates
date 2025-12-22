## Pandoc Syntax

```bash
pandoc --help
```

```
pandoc [OPTIONS] [FILES]
  -f FORMAT, -r FORMAT  --from=FORMAT, --read=FORMAT                  # Specify input format (e.g., markdown, html, docx)
  -t FORMAT, -w FORMAT  --to=FORMAT, --write=FORMAT                   # Specify output format (e.g., html, pdf, docx, pptx)
  -o FILE               --output=FILE                                 # Write output to specified FILE
                        --data-dir=DIRECTORY                          # Specify directory for pandoc data files
  -M KEY[:VALUE]        --metadata=KEY[:VALUE]                        # Set document metadata (title, author, date, etc.)
                        --metadata-file=FILE                          # Read metadata from YAML/JSON file
  -d FILE               --defaults=FILE                               # Read default options from file
                        --file-scope[=true|false]                     # Parse each input file individually (default: false)
                        --sandbox[=true|false]                        # Run in restricted sandbox mode
  -s[true|false]        --standalone[=true|false]                     # Produce standalone document with header/footer
                        --template=FILE                               # Use custom template file
  -V KEY[:VALUE]        --variable=KEY[:VALUE]                        # Set template variable
                        --variable-json=KEY[:JSON]                    # Set template variable to JSON value
                        --wrap=auto|none|preserve                     # Control text wrapping in output
                        --ascii[=true|false]                          # Use only ASCII characters in output
                        --toc[=true|false], --table-of-contents[=true|false]  # Include table of contents
                        --toc-depth=NUMBER                            # Set maximum depth for table of contents
                        --lof[=true|false], --list-of-figures[=true|false]    # Include list of figures
                        --lot[=true|false], --list-of-tables[=true|false]     # Include list of tables
  -N[true|false]        --number-sections[=true|false]                # Number section headings
                        --number-offset=NUMBERS                       # Set starting number for sections
                        --top-level-division=section|chapter|part     # Set type of top-level divisions
                        --extract-media=PATH                          # Extract media files to specified path
                        --resource-path=SEARCHPATH                    # Set search path for resources
  -H FILE               --include-in-header=FILE                      # Include file in document header
  -B FILE               --include-before-body=FILE                    # Include file before document body
  -A FILE               --include-after-body=FILE                     # Include file after document body
                        --no-highlight                                # Disable syntax highlighting
                        --highlight-style=STYLE|FILE                  # Set syntax highlighting style/theme
                        --syntax-definition=FILE                      # Use custom syntax definition file
                        --syntax-highlighting=none|default|idiomatic|<stylename>|<themepath>  # Set highlighting mode
                        --dpi=NUMBER                                  # Set DPI for raster images
                        --eol=crlf|lf|native                          # Set end-of-line character style
                        --columns=NUMBER                              # Set column width for text output
  -p[true|false]        --preserve-tabs[=true|false]                  # Preserve tabs in code blocks
                        --tab-stop=NUMBER                             # Set tab stop width
                        --pdf-engine=PROGRAM                          # Set PDF generation engine (pdflatex, xelatex, etc.)
                        --pdf-engine-opt=STRING                       # Pass option to PDF engine
                        --reference-doc=FILE                          # Use reference document for styling (Word)
                        --self-contained[=true|false]                 # Make HTML output self-contained (embed resources)
                        --embed-resources[=true|false]                # Embed resources in output
                        --link-images[=true|false]                    # Link to images instead of embedding
                        --request-header=NAME:VALUE                   # Set HTTP header for URL requests
                        --no-check-certificate[=true|false]           # Don't verify SSL certificates
                        --abbreviations=FILE                          # Read abbreviations from file
                        --indented-code-classes=STRING                # Set CSS classes for indented code blocks
                        --default-image-extension=extension           # Set default extension for images
  -F PROGRAM            --filter=PROGRAM                              # Apply external filter program
  -L SCRIPTPATH         --lua-filter=SCRIPTPATH                       # Apply Lua filter script
                        --shift-heading-level-by=NUMBER               # Shift heading levels up/down
                        --base-header-level=NUMBER                    # Set base level for headers
                        --track-changes=accept|reject|all             # Handle Word document track changes
                        --strip-comments[=true|false]                 # Strip HTML comments from input
                        --reference-links[=true|false]                # Use reference-style links
                        --reference-location=block|section|document   # Set location for footnotes/endnotes
                        --figure-caption-position=above|below         # Set figure caption position
                        --table-caption-position=above|below          # Set table caption position
                        --markdown-headings=setext|atx                # Set preferred markdown heading style
                        --list-tables[=true|false]                    # List all tables in document
                        --listings[=true|false]                       # Use listings package for LaTeX code blocks
  -i[true|false]        --incremental[=true|false]                    # Make list items appear incrementally in slides
                        --slide-level=NUMBER                          # Set heading level for slide breaks
                        --section-divs[=true|false]                   # Wrap sections in <div> tags
                        --html-q-tags[=true|false]                    # Use <q> tags for quotes
                        --email-obfuscation=none|javascript|references  # Set email address obfuscation method
                        --id-prefix=STRING                            # Set prefix for element IDs
  -T STRING             --title-prefix=STRING                         # Set HTML title prefix
  -c URL                --css=URL                                     # Link to CSS stylesheet
                        --epub-subdirectory=DIRNAME                   # Set subdirectory for EPUB content
                        --epub-cover-image=FILE                       # Set EPUB cover image
                        --epub-title-page[=true|false]                # Include title page in EPUB
                        --epub-metadata=FILE                          # Set EPUB metadata from file
                        --epub-embed-font=FILE                        # Embed font in EPUB
                        --split-level=NUMBER                          # Set split level for EPUB chapters
                        --chunk-template=PATHTEMPLATE                 # Set template for EPUB chunks
                        --epub-chapter-level=NUMBER                   # Set heading level for EPUB chapters
                        --ipynb-output=all|none|best                  # Set how to handle Jupyter notebook outputs
  -C                    --citeproc                                    # Process citations and bibliographies
                        --bibliography=FILE                           # Set bibliography file(s)
                        --csl=FILE                                    # Set CSL citation style file
                        --citation-abbreviations=FILE                 # Set citation abbreviations file
                        --natbib                                      # Use natbib for citations in LaTeX
                        --biblatex                                    # Use biblatex for citations in LaTeX
                        --mathml                                      # Use MathML for math rendering
                        --webtex[=URL]                                # Use WebTeX for math rendering
                        --mathjax[=URL]                               # Use MathJax for math rendering
                        --katex[=URL]                                 # Use KaTeX for math rendering
                        --gladtex                                     # Use GladTeX for math rendering
                        --trace[=true|false]                          # Trace pandoc execution
                        --dump-args[=true|false]                      # Dump command-line arguments
                        --ignore-args[=true|false]                    # Ignore command-line arguments
                        --verbose                                     # Enable verbose output
                        --quiet                                       # Suppress non-error output
                        --fail-if-warnings[=true|false]               # Exit with error on warnings
                        --log=FILE                                    # Write log to file
                        --bash-completion                             # Generate bash completion script
                        --list-input-formats                          # List supported input formats
                        --list-output-formats                         # List supported output formats
                        --list-extensions[=FORMAT]                    # List extensions for format
                        --list-highlight-languages                    # List supported highlighting languages
                        --list-highlight-styles                       # List available highlighting styles
  -D FORMAT             --print-default-template=FORMAT               # Print default template for format
                        --print-default-data-file=FILE                # Print default data file
                        --print-highlight-style=STYLE|FILE            # Print highlighting style
  -v                    --version                                     # Show pandoc version
  -h                    --help                                        # Show this help message
```

## Usage

### Basic Usage

#### Convert Markdown to HTML

```bash
pandoc input.md -o output.html
```

#### Convert Markdown to PDF (requires LaTeX)

```bash
pandoc input.md -o output.pdf
```

#### Convert Markdown to Word Document

```bash
pandoc input.md -o output.docx
```

#### Convert Markdown to PowerPoint

```bash
pandoc input.md -o output.pptx
```

#### Convert from URL

```bash
pandoc https://example.com/document.md -o output.html
```

### Converting Between Formats

#### HTML to Markdown

```bash
pandoc -f html -t markdown input.html -o output.md
```

#### Word Document to Markdown

```bash
pandoc -f docx -t markdown input.docx -o output.md
```

#### PDF to Plain Text (basic extraction)

```bash
pandoc -f pdf -t plain input.pdf -o output.txt
```

#### LaTeX to HTML

```bash
pandoc -f latex -t html input.tex -o output.html
```

### Advanced Options

#### Add Table of Contents

```bash
pandoc input.md -o output.html --toc --toc-depth=3
```

#### Number Sections

```bash
pandoc input.md -o output.html --number-sections
```

#### Set Document Title and Metadata

```bash
pandoc input.md -o output.html \
  --metadata title="My Document" \
  --metadata author="John Doe" \
  --metadata date="2024-01-01"
```

#### Use Custom CSS for HTML Output

```bash
pandoc input.md -o output.html \
  --css custom.css \
  --self-contained
```

#### Use Reference Document for Word Output

```bash
pandoc input.md -o output.docx \
  --reference-doc template.docx
```

#### Generate PDF with Custom LaTeX Options

```bash
pandoc input.md -o output.pdf \
  --pdf-engine=pdflatex \
  --variable geometry:margin=1in \
  --variable fontsize=12pt
```

### Templates and Styling

#### Use Custom HTML Template

```bash
pandoc input.md -o output.html \
  --template custom-template.html \
  --self-contained
```

#### Print Default Template

```bash
pandoc -D html > default-template.html
pandoc -D latex > default-latex.tex
```

#### Custom LaTeX Template

```bash
pandoc input.md -o output.pdf \
  --template custom-template.tex \
  --pdf-engine=xelatex
```

### Filters and Extensions

#### Enable Syntax Highlighting

```bash
pandoc input.md -o output.html \
  --highlight-style=tango
```

#### Use Lua Filters

```bash
pandoc input.md -o output.html \
  --lua-filter custom-filter.lua
```

#### Convert with Citations (requires pandoc-citeproc)

```bash
pandoc input.md \
  --filter pandoc-citeproc \
  --bibliography references.bib \
  --csl apa.csl \
  -o output.pdf
```

### Batch Processing

#### Convert Multiple Files

```bash
for file in *.md; do
  pandoc "$file" -o "${file%.md}.html"
done
```

#### Convert Directory Recursively

```bash
find . -name "*.md" -exec pandoc {} -o {}.html \;
```

#### Batch Convert with Common Options

```bash
pandoc *.md \
  --metadata title="Documentation" \
  --toc \
  --css style.css \
  --self-contained \
  -o combined.html
```

### Real-World Examples

#### Create a Professional PDF Report

```bash
pandoc report.md \
  --pdf-engine=pdflatex \
  --variable geometry:margin=1in \
  --variable fontsize=11pt \
  --variable colorlinks=true \
  --variable linkcolor=blue \
  --variable urlcolor=blue \
  --variable citecolor=green \
  --toc \
  --toc-depth=2 \
  --number-sections \
  --metadata title="Annual Report" \
  --metadata author="Company Name" \
  --metadata date="\\today" \
  -o report.pdf
```

#### Generate HTML Documentation Site

```bash
pandoc README.md \
  --template documentation-template.html \
  --css docs.css \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --self-contained \
  --metadata title="API Documentation" \
  --metadata author="Development Team" \
  -o docs/index.html
```

#### Convert Jupyter Notebook to PDF

```bash
pandoc notebook.ipynb \
  --pdf-engine=pdflatex \
  --highlight-style=pygments \
  --variable geometry:margin=1in \
  -o notebook.pdf
```

#### Create Slideshow from Markdown

```bash
pandoc slides.md \
  -t revealjs \
  -s \
  --slide-level=2 \
  --css custom-slides.css \
  -o slides.html
```

#### Extract Images and Convert to Different Format

```bash
pandoc input.docx \
  --extract-media=./images \
  -t markdown \
  -o output.md
```

### Advanced Features

#### Custom Syntax Highlighting

```bash
pandoc input.md -o output.html \
  --highlight-style=my-theme.theme
```

#### Include Raw Content

```bash
pandoc input.md -o output.html \
  --include-in-header header.html \
  --include-before-body before.html \
  --include-after-body after.html
```

#### Process Multiple Input Files

```bash
pandoc chapter1.md chapter2.md chapter3.md \
  --toc \
  --metadata title="Complete Book" \
  -o book.pdf
```

#### Convert with Custom Lua Filters for Advanced Processing

```bash
pandoc input.md \
  --lua-filter add-figure-numbers.lua \
  --lua-filter custom-code-blocks.lua \
  -o output.html
```

#### Generate Multiple Outputs Simultaneously

```bash
pandoc input.md \
  -o output.html \
  --metadata title="Document"

pandoc input.md \
  -o output.pdf \
  --metadata title="Document" \
  --pdf-engine=pdflatex
```

### Troubleshooting and Tips

#### Check Available Formats

```bash
pandoc --list-input-formats
pandoc --list-output-formats
pandoc --list-highlight-languages
pandoc --list-highlight-styles
```

#### Debug Conversion Issues

```bash
pandoc input.md -o output.html --verbose
```

#### Handle Encoding Issues

```bash
pandoc input.md -o output.html --from markdown+smart
```

#### Preserve Tabs in Code Blocks

```bash
pandoc input.md -o output.html --preserve-tabs
```

#### Set Custom DPI for Images

```bash
pandoc input.md -o output.pdf --dpi=300
```

