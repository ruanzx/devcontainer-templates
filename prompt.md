Reference:
- https://github.com/docling-project/docling-serve

Create the docling-in-docker feature by following the instructions and the patterns used in features/mdc.
docling-in-docker feature will be used to convert various files format into markdown file format.
Use API provided from ghcr.io/docling-project/docling-serve docker image (port 5001) and api endpoints from openapi.json to upload files need to convert, recieve response and write to files.

Docling serve default setting:
- To format: markdown
- Image export mode: embedded
- Pipeline type: standard
- Enable ocr mode by default, OCR engine use AUTO
- PDF backend: dlparse_v4
- Table mode: ACCURATE
- RETURN as FILE
- Continue on error

Tasks:
- Create the features/docling-in-docker folder with the required files:
  - install.sh: Installation script.
  - devcontainer-feature.json: Metadata and configuration options.
  - README.md: Documentation for the feature.

- Match the scripting pattern used in features/mdc:
  - Use utils.sh for shared utilities.
  - Use docker image ghcr.io/docling-project/docling-serve
  - Implement proper logging and error handling.
  - Validate system requirements (e.g., OS, architecture).

- Test the install.sh script:
  - Verify installation works as expected.
  - Test with different versions and configurations.

- Create a sample in folder examples/docling-in-docker to let developer test the created feature, with required files:
  - .devcontainer/devcontainer.json: metadata and configuration options
  - readme.md: Documentation for how to use the feature

- Update the project root README.md:
  - Add the new feature to the list of available features.
  - Ensure the README reflects the current state of the repository.



---


Create a new DevContainer feature called `docling-in-docker` that provides a command-line tool for converting various file formats to Markdown using the Docling service API via Docker.

**Reference Documentation:**
- https://github.com/docling-project/docling-serve

**Implementation Requirements:**

1. **Feature Structure** (features/docling-in-docker/):
   - `install.sh`: Bash script that creates a CLI wrapper command
   - `devcontainer-feature.json`: Feature metadata with version, description, and configurable options
   - README.md: User-facing documentation with usage examples and configuration options

2. **Technical Specifications:**
   - Base Docker image: `ghcr.io/docling-project/docling-serve` (port 5001)
   - CLI wrapper behavior:
     - Starts Docker container with random available port
     - Detects dev container environment and uses Docker gateway IP when needed
     - Uploads input file via API endpoint from openapi.json
     - Receives converted markdown response
     - Writes output to specified file path
     - Stops Docker container after conversion
     - Implements health checks with 2-minute timeout
   - Default conversion settings:
     - Output format: markdown
     - Image export mode: embedded
     - Pipeline type: standard
     - OCR mode: enabled (engine: AUTO)
     - PDF backend: dlparse_v4
     - Table mode: ACCURATE
     - Response type: FILE
     - Continue on error: enabled

3. **Code Patterns** (reference: features/mdc/):
   - Source utils.sh at script start: `source "${SCRIPT_DIR}/utils.sh"`
   - Use logging functions: `log_info()`, `log_success()`, `log_warning()`, `log_error()`
   - Implement architecture detection and validation
   - Use `set -e` for error handling
   - Map JSON options to uppercase environment variables
   - Use `download_file()` from utils.sh if downloading external binaries

4. **Testing and Examples:**
   - Create docling-in-docker with:
     - devcontainer.json: Feature configuration demonstrating usage
     - README.md: Step-by-step usage instructions and test commands
     - Sample input file (PDF) for testing conversions
   - Verify installation in isolated container
   - Test with different file formats and configurations

5. **Documentation Updates:**
   - Add feature entry to root README.md features list
   - Include description: "Converts documents to Markdown using Docling API via Docker"
   - Maintain alphabetical ordering in feature list

**Expected Deliverables:**
- Three feature files in docling-in-docker
- Example configuration in docling-in-docker
- Updated root README.md
- All scripts pass `bash -n` syntax validation
- Feature successfully converts sample document

**Output Format for CLI Tool:**
```bash
docling <input-file> <output-file.md>
```
