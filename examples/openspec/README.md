# OpenSpec Development Environment Example

This example demonstrates how to use the [OpenSpec DevContainer Feature](../../features/openspec/) to set up a spec-driven development environment with AI coding assistants.

## What's Included

This DevContainer configuration provides:

- **Node.js 20+**: Required runtime for OpenSpec
- **Git**: Version control for specs and changes
- **OpenSpec CLI**: Spec-driven development tool
- **VS Code Extensions**: ESLint and Prettier for code quality

## Quick Start

### 1. Open in DevContainer

Open this folder in VS Code and reopen in the DevContainer when prompted, or use the command palette:
- `Dev Containers: Reopen in Container`

### 2. Verify Installation

After the container builds, verify OpenSpec is installed:

```bash
# Check versions
node --version      # Should be 20.x or higher
npm --version       # Should be included with Node.js
openspec --version  # Should show OpenSpec version

# View help
openspec --help
```

### 3. Initialize OpenSpec

Create a sample project and initialize OpenSpec:

```bash
# Initialize OpenSpec in the workspace
openspec init

# When prompted, select any AI tools you're using
# OpenSpec will configure slash commands and AGENTS.md
```

### 4. Explore the Structure

After initialization, you'll have:

```
workspace/
├── openspec/
│   ├── project.md              # Project context and conventions
│   ├── specs/                  # Source of truth specifications
│   ├── changes/                # Proposed changes
│   └── archive/                # Completed changes
├── AGENTS.md                   # AI assistant instructions
└── [tool-specific configs]     # Slash commands for supported tools
```

### 5. Try the Workflow

#### Create a Change Proposal

With your AI assistant (e.g., GitHub Copilot, Claude, Cursor):

```
You: "Create an OpenSpec change proposal for adding user authentication"

AI: Creates openspec/changes/add-auth/ with:
    - proposal.md: Why and what changes
    - tasks.md: Implementation checklist
    - specs/auth/spec.md: Specification delta
```

Or use slash commands if your tool supports them:
```
/openspec-proposal Add user authentication
```

#### Review the Change

```bash
# List all changes
openspec list

# View change details
openspec show add-auth

# Validate specifications
openspec validate add-auth

# Open interactive dashboard
openspec view
```

#### Refine Specs

Work with your AI to refine the specifications:

```
You: "Add acceptance criteria for password requirements"
AI: Updates specs/auth/spec.md with password scenarios
```

#### Implement

```
You: "The specs look good. Let's implement this change."
Or: /openspec-apply add-auth

AI: Works through tasks from tasks.md
    Marks tasks complete as they're done
```

#### Archive

Once implementation is complete:

```bash
# Archive the change (merges specs back to source)
openspec archive add-auth --yes

# Or ask your AI:
# "Please archive the add-auth change"
# Or: /openspec-archive add-auth
```

## Configuration Details

### devcontainer.json

```json
{
  "name": "OpenSpec Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/openspec:latest": {
      "version": "latest"
    }
  }
}
```

### Key Features

- **Node.js 20**: Required for OpenSpec (v20.19.0+)
- **Git**: Essential for version control and OpenSpec initialization
- **OpenSpec**: Latest version from npm (@fission-ai/openspec)

## OpenSpec Commands

```bash
# Project setup
openspec init                   # Initialize in project
openspec update                 # Refresh agent instructions

# Working with changes
openspec list                   # View active changes
openspec show <change>          # Display change details
openspec validate <change>      # Check spec formatting
openspec view                   # Interactive dashboard

# Completing work
openspec archive <change>       # Merge completed change
openspec archive <change> --yes # Non-interactive archive

# Help
openspec --version              # Show version
openspec --help                 # Show help
```

## Supported AI Tools

### Native Slash Commands
- **Claude Code**: `/openspec:proposal`, `/openspec:apply`, `/openspec:archive`
- **Cursor**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **GitHub Copilot**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Windsurf**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Codex**: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
- **Amazon Q Developer**: `@openspec-proposal`, `@openspec-apply`, `@openspec-archive`
- And many more...

### AGENTS.md Compatible
All tools supporting the [AGENTS.md convention](https://agents.md/):
- Amp
- Jules  
- Gemini CLI
- Others

Simply ask them to "follow the OpenSpec workflow" or "create an OpenSpec proposal".

## Spec Format Example

### Source Spec (openspec/specs/auth/spec.md)

```markdown
# Authentication Specification

## Purpose
User authentication and session management

## Requirements

### Requirement: User Login
The system SHALL authenticate users with email and password

#### Scenario: Valid credentials
- GIVEN a registered user
- WHEN they submit valid credentials
- THEN a JWT token is returned
```

### Change Delta (openspec/changes/add-2fa/specs/auth/spec.md)

```markdown
# Authentication Delta

## ADDED Requirements

### Requirement: Two-Factor Authentication
The system MUST require a second factor during login

#### Scenario: OTP required
- GIVEN a user with 2FA enabled
- WHEN they submit valid credentials
- THEN an OTP challenge is required

## MODIFIED Requirements

### Requirement: User Login
The system SHALL authenticate users with email, password, and optional 2FA

#### Scenario: Valid credentials with 2FA
- GIVEN a registered user with 2FA enabled
- WHEN they submit valid credentials and OTP
- THEN a JWT token is returned
```

## Project Context

Use `openspec/project.md` to define:

- **Tech Stack**: Languages, frameworks, libraries
- **Conventions**: Coding standards, naming conventions
- **Architecture**: System design patterns
- **Guidelines**: Best practices, security requirements

This context is available to your AI assistant for all changes.

## Tips for Success

1. **Initialize First**: Run `openspec init` before creating proposals
2. **Use Natural Language**: OpenSpec works with conversational requests
3. **Iterate on Specs**: Refine specifications before implementing
4. **Validate Often**: Use `openspec validate` to catch issues early
5. **Archive When Done**: Keep specs up-to-date by archiving completed changes
6. **Leverage AI Tools**: Use slash commands for faster workflow
7. **Document Context**: Fill out `project.md` for better AI assistance

## Benefits Over Ad-Hoc Development

- ✅ **Alignment**: Agree on specs before coding
- ✅ **Traceability**: Track what changed and why
- ✅ **Reviewability**: Explicit diffs for all changes
- ✅ **Predictability**: Deterministic AI outputs
- ✅ **Documentation**: Living specs that evolve with code
- ✅ **Brownfield-Friendly**: Works for existing codebases
- ✅ **Tool-Agnostic**: Use any AI coding assistant

## Troubleshooting

### OpenSpec not found after build

Ensure Node.js 20.19.0+ is installed:
```bash
node --version
```

If Node.js is too old, update the feature version in devcontainer.json.

### Initialization fails

Make sure you're in a git repository:
```bash
git init
openspec init
```

### AI doesn't show slash commands

Restart your AI assistant to reload command configurations.

## Next Steps

- Read the [OpenSpec documentation](https://github.com/Fission-AI/OpenSpec)
- Visit [openspec.dev](https://openspec.dev/) for more information
- Join the [OpenSpec Discord](https://discord.gg/YctCnvvshC) for help
- Check out the [AGENTS.md convention](https://agents.md/)

## Related Examples

- **[spec-kit](../spec-kit/)** - GitHub's spec-kit example
- **[bmad-method](../bmad-method/)** - AI agent framework example
- **[npm](../npm/)** - npm packages example

## Resources

- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec npm Package](https://www.npmjs.com/package/@fission-ai/openspec)
- [AGENTS.md Convention](https://agents.md/)
- [DevContainer Features](https://containers.dev/features)

---

**Note**: This is a development environment example. Customize the configuration based on your project needs and AI tool preferences.
