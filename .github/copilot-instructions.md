# DevContainer Features Collection - AI Coding Instructions

## Architecture Overview

This repository implements a **collection of DevContainer Features** - reusable, versioned packages that install tools in development containers. The project follows a modular architecture with:

- **`features/`**: Individual feature definitions (JSON + install scripts)
- **`build/`**: Build artifacts for testing/validation
- **`examples/`**: Sample configurations demonstrating feature usage
- **`scripts/`**: Build automation and publishing workflows

## Key Development Patterns

### Feature Structure (Required Files)
Every feature in `features/<name>/` must have:
```
devcontainer-feature.json  # Metadata, options, versioning
install.sh                 # Installation logic (bash)
README.md                  # Documentation and examples
```

### Common Utilities Integration
- **Always source `utils.sh`** from install scripts: `source "${SCRIPT_DIR}/utils.sh"`
- Use consistent logging: `log_info()`, `log_success()`, `log_warning()`, `log_error()`
- Features requiring utilities declare: `"installsAfter": ["ghcr.io/devcontainers/features/common-utils"]`

### Environment Variable Pattern
Feature options map to uppercase environment variables:
```json
"options": { "cleanCache": { "type": "boolean", "default": true } }
```
Becomes: `CLEAN_CACHE=${CLEANCACHE:-"true"}` in install.sh

## Critical Developer Workflows

### Primary Build/Test/Publish Cycle
```bash
./devcontainer-features.sh setup    # First-time environment setup
./devcontainer-features.sh build    # Build all features
./devcontainer-features.sh test     # Run syntax + feature tests
./devcontainer-features.sh publish  # Publish to ghcr.io
```

### Feature-Specific Testing
```bash
# Test individual feature install script
cd build/<feature-name> && bash install.sh

# Test with specific environment variables
PACKAGES="curl,git" bash build/apt/install.sh
```

### Example Generation
```bash
./scripts/create-examples.sh  # Generate usage examples
```

## Project-Specific Conventions

### Version Management
- Features are **versioned by the tool version they install** (e.g., kubectl:1.31.0)
- Use `:latest` for most recent tool version
- GitHub Container Registry path: `ghcr.io/ruanzx/features/<name>:<version>`

### Error Handling Standards
- **Always use `set -e`** in install scripts
- Validate system requirements early (e.g., `check_debian_like()` for APT)
- Provide clear error messages with emojis for visibility

### Package Validation (APT Feature Pattern)
When accepting user input (like package names), implement validation:
```bash
validate_packages() {
    # Regex validation: ^[a-zA-Z0-9._+-:]+$
    # Early exit with clear error messages
    # Handle empty inputs gracefully
}
```

## Integration Points

### GitHub Container Registry
- Features publish to `ghcr.io/ruanzx/features/*`
- Requires `GITHUB_TOKEN` with `write:packages` permission in `.env`
- Publishing handled by `scripts/publish.sh`

### DevContainer Ecosystem
- Features install **after** base image setup but **before** user code
- Support standard DevContainer customizations (VS Code extensions, etc.)
- Examples demonstrate real-world integration patterns

### Cross-Feature Dependencies
- Use `"installsAfter"` for dependency ordering
- Common pattern: APT feature + tool-specific features
- Example: `terraform-dev` combines terraform-docs + terraformer + apt packages

## Key Files for Understanding

- **`common/utils.sh`**: Shared utilities, logging, download functions
- **`examples/basic-all-features/`**: Comprehensive integration example
- **`features/apt/`**: Most complex feature showing validation patterns
- **`scripts/build.sh`**: Build orchestration and validation logic
- **`devcontainer-features.sh`**: Main developer interface

## Testing Philosophy

- **Syntax validation**: All bash scripts must pass `bash -n`
- **Feature testing**: Install scripts run in isolated containers
- **Integration examples**: Real devcontainer configurations in `examples/`
- **Manual verification**: Features provide verification commands in README
