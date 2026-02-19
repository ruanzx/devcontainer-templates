Create the markify-in-docker feature by following the instructions and the patterns used in features/markitdown-in-docker.
markify-in-docker feature will be used to convert various files format/url into markdown file format.

Tasks:
- Create the features/markify-in-docker folder with the required files:
  - install.sh: Installation script.
  - devcontainer-feature.json: Metadata and configuration options.
  - README.md: Documentation for the feature.

- Match the scripting pattern used in features/markitdown-in-docker:
  - Use utils.sh for shared utilities.
  - Use docker image ruanzx/markify
  - Implement proper logging and error handling.
  - Validate system requirements (e.g., OS, architecture).

- Test the install.sh script:
  - Verify installation works as expected.
  - Test with different versions and configurations.

- Create a sample in folder examples/markify-in-docker to let developer test the created feature, with required files:
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

---

You are a senior DevContainer engineer working in this repository. Your task is to create a new DevContainer feature called `markify-in-docker` by strictly following the patterns established in the existing `features/mdc` feature.

The `markify-in-docker` feature converts various file formats and URLs into Markdown format using the Docker image `ruanzx/markify`.

Complete all tasks in order. Each task is self-contained and small enough to avoid response limits.

---

TASK 1 - Inspect the reference implementation:
Read and understand all files in `features/mdc/`:
- `devcontainer-feature.json`
- `install.sh`
- `README.md`
Also read `common/utils.sh` to understand available shared utilities.

---

TASK 2 - Create `features/markify-in-docker/devcontainer-feature.json`:
Model it after `features/mdc/devcontainer-feature.json`.
- Set `id` to `markify-in-docker`
- Set `version` to match the current Docker image tag pattern
- Define relevant options such as `version` (string, default: `"latest"`) and `cleanCache` (boolean, default: `true`)
- Set `installsAfter` to include `ghcr.io/devcontainers/features/common-utils` and the docker feature
- Include a meaningful `description` referencing conversion of files/URLs to Markdown using `ruanzx/markify`

---

TASK 3 - Create `features/markify-in-docker/install.sh`:
Model it after `features/mdc/install.sh`. Requirements:
- Begin with `#!/usr/bin/env bash` and `set -e`
- Source `utils.sh` using the `SCRIPT_DIR` pattern
- Map all options to uppercase environment variables (e.g., `VERSION=${VERSION:-"latest"}`)
- Validate the system is Debian-like using `check_debian_like()` from utils.sh
- Verify Docker is available (`docker --version`) with a clear error if missing
- Pull the image `ruanzx/markify:${VERSION}` using `docker pull`
- Create a wrapper shell script at `/usr/local/bin/markify` that calls `docker run --rm -it -v "$(pwd):/data" ruanzx/markify:${VERSION}` with all CLI arguments forwarded (`"$@"`)
- Make the wrapper executable with `chmod +x`
- Use `log_info`, `log_success`, `log_warning`, `log_error` for all output
- Handle the `cleanCache` option to optionally clean Docker layer cache

---

TASK 4 - Create `features/markify-in-docker/README.md`:
Model it after `features/mdc/README.md`. Include:
- Feature name and description
- A table listing all options, their types, defaults, and descriptions
- A usage example showing a `devcontainer.json` snippet with the feature
- A section "Using markify" with example CLI commands (convert a local file, convert a URL)
- A verification command to confirm the feature is installed

---

TASK 5 - Create example files in `examples/markify-in-docker/`:
Create `.devcontainer/devcontainer.json`:
- Reference the feature `ghcr.io/ruanzx/features/markify-in-docker:latest`
- Include a base image consistent with other examples in this repo
Create `readme.md`:
- Explain what `markify` does
- List 3-5 example `markify` CLI commands with expected outputs described
- Include a "Getting Started" section

---

TASK 6 - Update the root `README.md`:
- Locate the features table or list
- Add a new row/entry for `markify-in-docker` with its description and the registry path `ghcr.io/ruanzx/features/markify-in-docker`
- Do not alter any other content

---

TASK 7 - Verify all created scripts pass bash syntax validation:
Run the following commands and report the output:
```bash
bash -n features/markify-in-docker/install.sh
cat features/markify-in-docker/devcontainer-feature.json | python3 -m json.tool > /dev/null
```

For each file created, show the full file content in a code block with the filepath comment.
