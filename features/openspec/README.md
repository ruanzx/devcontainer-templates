# OpenSpec DevContainer Feature

This feature installs [OpenSpec](https://github.com/Fission-AI/OpenSpec), a spec-driven development tool for AI coding assistants. OpenSpec helps align humans and AI on what to build before any code is written, providing a lightweight specification workflow that locks intent before implementation.

## Quick Start

```bash
# Check if OpenSpec is working
openspec --version

# Initialize OpenSpec in your project
openspec init

# View active changes
openspec list

# Open interactive dashboard
openspec view

# Create a change proposal (with AI assistant)
# "Create an OpenSpec change proposal for adding user authentication"

# Review and validate changes
openspec show <change-name>
openspec validate <change-name>

# Archive completed changes
openspec archive <change-name>
```

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/openspec:latest": {}
    }
}
```

## Options

| Option    | Type   | Default    | Description                                    |
| --------- | ------ | ---------- | ---------------------------------------------- |
| `version` | string | `"latest"` | Version of OpenSpec to install. Use 'latest' for the most recent version, or specify a version like '0.13.0' |

## Examples

### Basic Installation

```json
{
    "features": {
        "ghcr.io/ruanzx/features/openspec:latest": {}
    }
}
```

### With Node.js DevContainer Feature (Recommended)

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/openspec:latest": {}
    }
}
```

> **Note**: Node.js 20.19.0+ is **required** for OpenSpec. This feature does not install Node.js automatically. Please include the Node.js DevContainer feature as shown above, or ensure Node.js 20.19.0+ is available in your base image.

### Specific Version

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/openspec:latest": {
            "version": "0.13.0"
        }
    }
}
```

### Complete AI-Assisted Development Environment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/openspec:latest": {},
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    }
}
```

## What's Installed

This feature installs:
- **OpenSpec CLI**: Spec-driven development tool from Fission AI's OpenSpec project
- **Global npm package**: `@fission-ai/openspec` installed globally via npm

## Prerequisites

- **Node.js 20.19.0+**: Required for OpenSpec (must be installed via Node.js feature or base image)
- **npm**: Node package manager (included with Node.js)
- **Git**: Required for project initialization and version control

> **Important**: This feature does not install Node.js. Please include the Node.js DevContainer feature in your configuration or use a base image with Node.js 20.19.0+.

## Verification

After installing the feature, verify the installation:

```bash
# Check OpenSpec version
openspec --version

# View help
openspec --help

# Test initialization (in a test directory)
mkdir test-project && cd test-project
openspec init
```

## OpenSpec Workflow

OpenSpec implements a structured workflow for spec-driven development:

### 1. Initialize

```bash
openspec init
```

Creates the `openspec/` directory structure:
- `openspec/specs/` - Current source of truth specifications
- `openspec/changes/` - Proposed changes and updates
- `openspec/project.md` - Project context and conventions
- `AGENTS.md` - Instructions for AI assistants

### 2. Create Change Proposals

Work with your AI assistant to create change proposals:

```
You: "Create an OpenSpec change proposal for adding profile search filters"

AI: Creates openspec/changes/add-profile-filters/ with:
    - proposal.md (intent and scope)
    - tasks.md (implementation checklist)
    - specs/ (specification deltas)
```

### 3. Review and Refine

```bash
# List all changes
openspec list

# View change details
openspec show add-profile-filters

# Validate specs
openspec validate add-profile-filters

# Interactive dashboard
openspec view
```

### 4. Implement

Work through tasks with your AI assistant, referencing the agreed specifications.

### 5. Archive

Once complete, merge the change back into source specs:

```bash
openspec archive add-profile-filters --yes
```

## Supported AI Tools

OpenSpec works with many AI coding assistants through:

### Native Slash Commands
- **Claude Code**: `/openspec:proposal`, `/openspec:apply`, `/openspec:archive`
- **Cursor**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **GitHub Copilot**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Windsurf**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Codex**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Amazon Q Developer**: `@openspec-proposal`, `@openspec-apply`, `@openspec-archive`
- And many more...

### AGENTS.md Compatible
All AI tools that support the [AGENTS.md convention](https://agents.md/):
- Amp
- Jules
- Gemini CLI
- Others

## Key Benefits

- **Alignment before implementation**: Agree on specs before code is written
- **Structured change tracking**: Proposals, tasks, and spec deltas live together
- **Brownfield-friendly**: Works great for modifying existing features, not just new ones
- **Explicit diffs**: Separate source of truth (`specs/`) from proposals (`changes/`)
- **Lightweight**: No API keys required, minimal setup
- **Universal compatibility**: Works with any AI coding assistant

## Command Reference

```bash
openspec init                   # Initialize OpenSpec in project
openspec list                   # View active change folders
openspec view                   # Interactive dashboard
openspec show <change>          # Display change details
openspec validate <change>      # Check spec formatting
openspec archive <change>       # Merge completed change
openspec update                 # Refresh agent instructions
openspec --version              # Show version
openspec --help                 # Show help
```

## Project Structure

After initialization, your project will have:

```
my-project/
├── openspec/
│   ├── project.md              # Project context and conventions
│   ├── specs/                  # Source of truth specifications
│   │   └── [feature]/
│   │       └── spec.md
│   ├── changes/                # Proposed changes
│   │   └── [change-name]/
│   │       ├── proposal.md
│   │       ├── tasks.md
│   │       ├── design.md (optional)
│   │       └── specs/
│   │           └── [feature]/
│   │               └── spec.md  # Delta showing changes
│   └── archive/                # Completed changes
├── AGENTS.md                   # AI assistant instructions
└── [tool-specific-configs]     # Slash commands for supported tools
```

## Spec Format

OpenSpec uses structured specification deltas:

```markdown
# Feature Name Specification

## Purpose
Brief description of the feature purpose

## Requirements

### Requirement: Feature Name
The system SHALL/MUST provide [requirement description]

#### Scenario: Use Case Name
- GIVEN [precondition]
- WHEN [action]
- THEN [expected outcome]
```

### Delta Format

Change proposals use deltas to show modifications:

```markdown
## ADDED Requirements
New capabilities being added

## MODIFIED Requirements
Changed behavior (include complete updated text)

## REMOVED Requirements
Deprecated features being removed
```

## Updating OpenSpec

To upgrade to a newer version:

1. Update your `devcontainer.json` with the desired version
2. Rebuild your container
3. Run `openspec update` in your projects to refresh agent instructions

## Troubleshooting

### OpenSpec command not found

**Solution**: Ensure Node.js 20.19.0+ is installed and npm is available:

```bash
node --version  # Should be >= 20.19.0
npm --version
```

### Initialization fails

**Solution**: Ensure you're in a git repository:

```bash
git init
openspec init
```

### AI assistant doesn't show slash commands

**Solution**: Restart your AI assistant to reload command configurations.

## Integration with Other Features

OpenSpec works well with:

- **[specify-cli](../specify-cli/)**: GitHub's spec-kit for spec-driven development
- **[Git](https://github.com/devcontainers/features/tree/main/src/git)**: Version control for specs and changes
- **[GitHub CLI](https://github.com/devcontainers/features/tree/main/src/github-cli)**: GitHub integration
- **[Node.js](https://github.com/devcontainers/features/tree/main/src/node)**: Required runtime
- **[Python](https://github.com/devcontainers/features/tree/main/src/python)**: For Python projects

## Comparison with Other Tools

### vs. spec-kit
- **OpenSpec**: Two-folder model (specs/ + changes/) with explicit diffs
- **spec-kit**: Strong for 0→1 greenfield projects

### vs. Kiro.dev
- **OpenSpec**: Groups all change artifacts in one folder
- **Kiro.dev**: Spreads updates across multiple spec folders

### vs. No Specs
- **OpenSpec**: Predictable, reviewable AI outputs with agreed specs
- **No Specs**: Vague prompts lead to unpredictable implementations

## Resources

- **Documentation**: https://github.com/Fission-AI/OpenSpec
- **Website**: https://openspec.dev/
- **Discord**: https://discord.gg/YctCnvvshC
- **npm Package**: https://www.npmjs.com/package/@fission-ai/openspec
- **AGENTS.md Convention**: https://agents.md/

## Contributing

Found an issue or want to improve this feature? Contributions are welcome!

## License

This feature follows the same license as the parent repository. OpenSpec itself is licensed under MIT License.

## Related Features

- **[specify-cli](../specify-cli/)** - GitHub's spec-kit for spec-driven development
- **[bmad-method](../bmad-method/)** - Universal AI Agent Framework for Agentic Agile Driven Development
- **[claude-code-cli](../claude-code-cli/)** - Command-line interface for Claude AI
- **[gemini-cli](../gemini-cli/)** - Google Gemini AI CLI

---

**Note**: This is an unofficial DevContainer feature for OpenSpec. For official support and documentation, visit the [OpenSpec GitHub repository](https://github.com/Fission-AI/OpenSpec).
