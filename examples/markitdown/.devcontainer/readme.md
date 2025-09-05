## Markitdown Usage
```
usage: SYNTAX:

    markitdown <OPTIONAL: FILENAME>
    If FILENAME is empty, markitdown reads from stdin.

EXAMPLE:

    markitdown example.pdf

    OR

    cat example.pdf | markitdown

    OR

    markitdown < example.pdf

    OR to save to a file use

    markitdown example.pdf -o example.md

    OR

    markitdown example.pdf > example.md

Convert various file formats to markdown.

positional arguments:
  filename

options:
  -h, --help            show this help message and exit
  -v, --version         show the version number and exit
  -o OUTPUT, --output OUTPUT
                        Output file name. If not provided, output is written to stdout.
  -x EXTENSION, --extension EXTENSION
                        Provide a hint about the file extension (e.g., when reading from stdin).
  -m MIME_TYPE, --mime-type MIME_TYPE
                        Provide a hint about the file's MIME type.
  -c CHARSET, --charset CHARSET
                        Provide a hint about the file's charset (e.g, UTF-8).
  -d, --use-docintel    Use Document Intelligence to extract text instead of offline conversion. Requires a valid Document Intelligence Endpoint.
  -e ENDPOINT, --endpoint ENDPOINT
                        Document Intelligence Endpoint. Required if using Document Intelligence.
  -p, --use-plugins     Use 3rd-party plugins to convert files. Use --list-plugins to see installed plugins.
  --list-plugins        List installed 3rd-party plugins. Plugins are loaded when using the -p or --use-plugin option.
  --keep-data-uris      Keep data URIs (like base64-encoded images) in the output. By default, data URIs are truncated.
 ```