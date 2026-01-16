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


Create a new DevContainer feature called `skills-ref-in-docker` that provides a Docker-based command-line tool for validating and managing agent skills following the established patterns in this repository.

## Context

You are working in a DevContainer Features collection repository with a standardized structure. Reference the existing `mdc` feature (features/mdc/) and `diagrams-in-docker` feature as architectural templates. The Docker image `ruanzx/skills-ref` already exists and contains the skills-ref tool installed from https://github.com/agentskills/agentskills/tree/main/skills-ref.

## Required Deliverables

### 1. Feature Implementation (features/skills-ref-in-docker/)

Create three required files following the repository's established patterns:

**install.sh:**
- Must start with `#!/bin/sh` and `set -e`
- Source common utilities: `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" && source "${SCRIPT_DIR}/../../common/utils.sh"`
- Use logging functions: `log_info()`, `log_success()`, `log_warning()`, `log_error()`
- Create a wrapper script in `/usr/local/bin/skills-ref` that:
  - Executes: `docker run --rm -v "$(pwd)":/output ruanzx/skills-ref "$@"`
  - Handles dev container environment detection for Docker gateway IP if needed
  - Preserves all command-line arguments passed to skills-ref
- Make the wrapper executable: `chmod +x /usr/local/bin/skills-ref`
- Log successful installation with version information

**devcontainer-feature.json:**
- Follow the JSON schema from existing features
- Required fields:
  - `id`: "skills-ref-in-docker"
  - `version`: "1.0.0"
  - `name`: "Skills-Ref (in Docker)"
  - `description`: "Validates and manages agent skills using Docker-based skills-ref tool"
  - `documentationURL`: Link to the feature's README
  - `options`: Include at least one option (e.g., `cleanCache` or `version` with appropriate defaults)
  - `installsAfter`: Empty array or dependencies if needed
- Include optional customizations for common use cases

**README.md:**
- Structure following existing feature READMEs
- Sections:
  - Brief description of what skills-ref does
  - Installation example in devcontainer.json
  - Usage examples showing all three skills-ref commands:
    - `skills-ref validate path/to/skill`
    - `skills-ref read-properties path/to/skill`
    - `skills-ref to-prompt path/to/skill-a path/to/skill-b`
  - Configuration options from devcontainer-feature.json
  - Reference links to upstream documentation

### 2. Example Configuration (examples/skills-ref-in-docker/)

Create a working example demonstrating feature usage:

**devcontainer.json:**
- Use a base image like `mcr.microsoft.com/devcontainers/base:debian`
- Reference the feature: `"ghcr.io/ruanzx/features/skills-ref-in-docker:1"`
- Include any feature options being demonstrated

**README.md:**
- Explain the example setup
- Provide step-by-step testing instructions
- Include expected output for verification

**Sample skill structure for testing:**
- Create a minimal valid skill directory with SKILL.md that skills-ref can validate
- Include test commands users can run to verify installation

### 3. Documentation Updates

**Root README.md:**
- Add entry to the features list: `| [skills-ref-in-docker](./features/skills-ref-in-docker) | Validates agent skills via Docker | ghcr.io/ruanzx/features/skills-ref-in-docker |`
- Maintain alphabetical ordering in the features table
- Ensure consistent formatting with existing entries

### 4. Build Integration

**build/ directory:**
- Run the build script to generate build artifacts: `./devcontainer-features.sh build`
- Ensure build/skills-ref-in-docker/ contains copied files from features/

## Technical Constraints

- All bash scripts must pass `bash -n` syntax validation
- Follow the wrapper pattern from features/diagrams-in-docker/ or features/mdc/
- Docker image reference: `ruanzx/skills-ref` (already built and available)
- Volume mount pattern: Map current directory to `/output` in container
- Error handling: Use `set -e` and validate command existence
- Architecture: Support amd64/arm64 (Docker handles this via image)

## Validation Checklist

Before considering the task complete, verify:
- [ ] `bash -n features/skills-ref-in-docker/install.sh` passes without errors
- [ ] Feature builds successfully: `./devcontainer-features.sh build`
- [ ] Example can be tested: Navigate to examples/skills-ref-in-docker/ and rebuild devcontainer
- [ ] All three skills-ref commands work: validate, read-properties, to-prompt
- [ ] Root README.md updated with alphabetically ordered entry
- [ ] Feature follows the exact pattern of existing "-in-docker" features

## Output Format

Provide a summary of completed tasks in this structure:
1. Files created/modified (with full paths)
2. Key implementation details
3. Test commands for user verification
4. Any deviations from patterns (if unavoidable)

Do not simulate file contents unless showing brief examples for clarification. Focus on implementation completion.