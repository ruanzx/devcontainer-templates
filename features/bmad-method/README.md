# BMAD-METHOD (bmad-method)

Universal AI Agent Framework for Agentic Agile Driven Development. Transform any domain with specialized AI expertise: software development, entertainment, creative writing, business strategy, and personal wellness.

## Example Usage

```json
"features": {
    "ghcr.io/ruanzx/features/bmad-method:1": {}
}
```

```json
"features": {
    "ghcr.io/ruanzx/features/bmad-method:1": {
        "installWorkspace": true
    }
}
```

## Options

| Options ID       | Description                                       | Type    | Default Value |
| ---------------- | ------------------------------------------------- | ------- | ------------- |
| installWorkspace | Install BMAD-METHOD globally vs. in the workspace | boolean | false         |

## Description

BMAD-METHOD™ is a revolutionary AI agent framework that implements Agentic Agile Driven Development. It provides two key innovations:

1. **Agentic Planning**: Dedicated agents (Analyst, PM, Architect) collaborate with you to create detailed, consistent PRDs and Architecture documents
2. **Context-Engineered Development**: The Scrum Master agent transforms plans into hyper-detailed development stories with full context for the Dev agent

## Key Features

- **Universal Framework**: Works in any domain beyond software development
- **Specialized AI Agents**: Analyst, PM, Architect, Scrum Master, Dev, and QA agents
- **Web UI and IDE Integration**: Start planning in web UI, develop in your IDE
- **Expansion Packs**: Extend functionality for specific domains
- **Node.js Based**: Built on modern Node.js technology

## Dependencies

This feature requires:
- **Node.js v20+**: Required for running BMAD-METHOD
- **npm**: Package manager for installation
- **git**: Version control system (dependency for BMAD-METHOD)

These dependencies are automatically handled by declaring:
```json
"installsAfter": [
    "ghcr.io/devcontainers/features/common-utils",
    "ghcr.io/devcontainers/features/node"
]
```

## Installation Options

### Global Installation (Default)
When `installWorkspace` is `false` (default), BMAD-METHOD is installed globally:
- Available system-wide via `npx bmad-method`
- Can be used in any project directory
- Ideal for multi-project development

### Workspace Installation
When `installWorkspace` is `true`, BMAD-METHOD is installed in the current workspace:
- Installs as a local npm dependency
- Runs the setup wizard to configure the framework files
- Creates project-specific configuration

## Getting Started

After installation, you can:

1. **Create a new project** (global installation):
   ```bash
   mkdir my-project && cd my-project
   npx bmad-method install
   ```

2. **Start with Web UI** (fastest):
   - Get a [full stack team file](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/dist/teams/team-fullstack.txt)
   - Create a new Gemini Gem or CustomGPT
   - Upload the file and set instructions
   - Start with `*help` or `*analyst` commands

3. **Update existing installation**:
   ```bash
   npx bmad-method install  # Auto-detects and updates
   ```

## Verification

After installation, verify BMAD-METHOD is working:

```bash
npx bmad-method --version
```

## Workflow Overview

1. **Planning Phase (Web UI)**:
   - Create Product Requirements Document (PRD)
   - Design Architecture documentation
   - Generate UX briefs (optional)

2. **Development Phase (IDE)**:
   - Shard documentation into manageable pieces
   - Use Scrum Master to create detailed stories
   - Implement with Dev agent using story context
   - Validate with QA agent

## Resources

- **Documentation**: [User Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md)
- **Architecture**: [Core Architecture](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/core-architecture.md)
- **Community**: [Discord Server](https://discord.gg/gk8jAdXWmj)
- **Repository**: [GitHub](https://github.com/bmad-code-org/BMAD-METHOD)
- **Expansion Packs**: [Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/expansion-packs.md)

## Support

- 💬 [Discord Community](https://discord.gg/gk8jAdXWmj)
- 🐛 [Issue Tracker](https://github.com/bmad-code-org/BMAD-METHOD/issues)
- 💬 [Discussions](https://github.com/bmad-code-org/BMAD-METHOD/discussions)

## Example DevContainer Configuration

```json
{
    "name": "BMAD-METHOD Development Environment",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/ruanzx/features/bmad-method:1": {
            "installWorkspace": true
        }
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-json"
            ]
        }
    }
}
```

## License

BMAD-METHOD™ is released under the MIT License. BMAD™ and BMAD-METHOD™ are trademarks of BMad Code, LLC.

---

🌟 **Star the project** on [GitHub](https://github.com/bmad-code-org/BMAD-METHOD) to stay updated with the latest features!