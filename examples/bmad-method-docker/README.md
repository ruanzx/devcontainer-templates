# BMAD-METHOD Docker Example

This example demonstrates how to use the BMAD-METHOD framework in a Docker-based development container without requiring Node.js installation on the host system.

## What's Included

This dev container includes:

- **Docker**: Access to Docker daemon on the host via `docker-outside-of-docker`
- **BMAD-METHOD**: CLI wrapper that runs BMAD in a Docker container
- **GitHub Copilot**: AI-powered code completion and chat
- **VS Code Extensions**: JSON and Markdown support

## Key Features

### Docker-Based Execution
- No Node.js required on host
- Fully isolated execution environment
- Easy to update (just pull new Docker image)
- Consistent across different systems

### BMAD-METHOD Framework
- Universal AI Agent Framework for Agentic Agile Driven Development
- Specialized AI agents: Analyst, PM, Architect, Scrum Master, Dev, QA
- Works in any domain beyond software development
- Expansion packs for specific use cases

## Getting Started

### 1. Install BMAD-METHOD in Your Project

```bash
# Initialize BMAD-METHOD in the current directory
bmad install
```

This will:
- Create necessary configuration files
- Set up the agent framework
- Prepare your workspace for AI-assisted development

### 2. Check Installation Status

```bash
# Verify installation
bmad status
```

### 3. Run BMAD Commands

```bash
# Show version
bmad --version

# List available expansion packs
bmad list:expansions

# Update existing installation
bmad update

# Check for updates
bmad update-check

# Flatten codebase to XML (for LLM context)
bmad flatten
```

## Workflow Examples

### Planning Phase (Web UI)

1. Get a [full stack team file](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/dist/teams/team-fullstack.txt)
2. Create a new Gemini Gem or CustomGPT
3. Upload the file and set instructions
4. Start with `*help` or `*analyst` commands
5. Create Product Requirements Document (PRD)
6. Design Architecture documentation

### Development Phase (IDE)

1. **Shard Documentation**:
   ```bash
   bmad flatten
   ```

2. **Use Agents**: Work with specialized agents through the framework:
   - `*analyst` - Requirements analysis
   - `*pm` - Project management
   - `*architect` - System architecture
   - `*scrum` - Story creation
   - `*dev` - Implementation
   - `*qa` - Quality assurance

3. **Implement Features**: Use Dev agent with detailed story context
4. **Validate**: Use QA agent to test implementations

## Directory Structure

```
.
├── .devcontainer/
│   └── devcontainer.json          # Dev container configuration
├── bmad/                           # BMAD configuration (created on install)
│   ├── config.json
│   ├── agents/
│   └── templates/
├── docs/                           # Documentation
│   ├── prd/                        # Product Requirements
│   ├── architecture/               # Architecture docs
│   └── stories/                    # Development stories
├── src/                            # Source code
└── README.md
```

## Available Commands

### Core Commands
- `bmad install` - Install BMAD-METHOD framework
- `bmad update` - Update existing installation
- `bmad status` - Show installation status
- `bmad --version` - Show version information

### Utilities
- `bmad flatten` - Flatten codebase to XML format
- `bmad list:expansions` - List available expansion packs
- `bmad update-check` - Check for BMAD updates

### Wrapper Commands
- `bmad --help` - Show wrapper help (Docker-specific)

## Environment Variables

Customize the Docker image used:

```bash
# Use a different Docker image
export BMAD_IMAGE_NAME="myorg/custom-bmad"
export BMAD_IMAGE_TAG="1.0.0"

bmad --version
```

## Ports

The dev container forwards these ports:

- **3000**: Development Server
- **8000**: API Server  
- **8080**: Web UI

## VS Code Extensions

Included extensions:
- **GitHub Copilot**: AI pair programming
- **GitHub Copilot Chat**: AI assistance
- **JSON**: JSON language support
- **Markdown**: Enhanced Markdown support

## Comparison: Docker vs Native

| Feature | Docker (this example) | Native |
|---------|----------------------|---------|
| Node.js Required | ❌ No | ✅ Yes (v20+) |
| Setup Time | Fast | Slower |
| Isolation | ✅ Full | ❌ Partial |
| Updates | Pull image | npm update |
| Best For | Docker workflows | Node.js devs |

## Resources

- **BMAD-METHOD**: [GitHub Repository](https://github.com/bmad-code-org/BMAD-METHOD)
- **Documentation**: [User Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md)
- **Architecture**: [Core Architecture](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/core-architecture.md)
- **Community**: [Discord Server](https://discord.gg/gk8jAdXWmj)
- **Expansion Packs**: [Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/expansion-packs.md)

## Troubleshooting

### Docker Not Running

```bash
# Check Docker status
docker info
```

### Update BMAD-METHOD

```bash
# Pull latest Docker image
docker pull ruanzx/bmad:latest

# Verify new version
bmad --version
```

### Workspace Not Accessible

Ensure you're running `bmad` commands from within your project directory. The wrapper automatically mounts your current working directory to `/workspace` in the container.

## Support

- 💬 [Discord Community](https://discord.gg/gk8jAdXWmj)
- 🐛 [Issue Tracker](https://github.com/bmad-code-org/BMAD-METHOD/issues)
- 💬 [Discussions](https://github.com/bmad-code-org/BMAD-METHOD/discussions)

## License

This example is part of the DevContainer Features collection. Check the [BMAD-METHOD project](https://github.com/bmad-code-org/BMAD-METHOD) for its licensing information.
