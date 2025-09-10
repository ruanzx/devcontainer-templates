# specify-cli DevContainer Feature

This feature installs [specify-cli](https://github.com/github/spec-kit), a toolkit to help you get started with Spec-Driven Development. Build high-quality software faster with executable specifications that directly generate working implementations.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/specify-cli:latest": {}
    }
}
```

## Options

| Option    | Type   | Default    | Description                                                             |
| --------- | ------ | ---------- | ----------------------------------------------------------------------- |
| `version` | string | `"latest"` | Version of specify-cli to install. Currently only 'latest' is supported |

## Examples

### Basic Installation

```json
{
    "features": {
        "ghcr.io/ruanzx/features/specify-cli:latest": {}
    }
}
```

### With Python DevContainer Feature

```json
{
    "features": {
        "ghcr.io/devcontainers/features/python:1": {
            "version": "3.11"
        },
        "ghcr.io/ruanzx/features/specify-cli:latest": {}
    }
}
```

### Complete Spec-Driven Development Environment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/python:1": {
            "version": "3.11"
        },
        "ghcr.io/ruanzx/features/specify-cli:latest": {},
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    }
}
```

## What's Installed

This feature installs:
- **uv package manager**: Modern Python package manager (if not already installed)
- **specify-cli**: Spec-Driven Development toolkit from GitHub's spec-kit project

## Prerequisites

- **Python 3.11+**: Required for specify-cli (automatically checked)
- **Git**: Required for cloning project templates
- **Internet connection**: Required for downloading templates and AI interactions

## Verification

After installation, you can verify specify-cli is working:

```bash
# Check if specify is available
specify --help

# Check system requirements
specify check

# Initialize a new project
specify init my-project
```

## What is Spec-Driven Development?

Spec-Driven Development flips the script on traditional software development. Instead of treating specifications as temporary scaffolding, they become executable documents that directly generate working implementations.

### Key Principles

- **Intent-driven development**: Specifications define the "what" before the "how"
- **Rich specification creation**: Using guardrails and organizational principles
- **Multi-step refinement**: Rather than one-shot code generation from prompts
- **AI-native workflow**: Heavy reliance on advanced AI model capabilities

## Core Workflow

### 1. Initialize Project

```bash
# Create a new project
specify init my-photo-app

# Or initialize in current directory
specify init --here
```

### 2. Create Specification

Use the `/specify` command in your AI coding agent to describe what you want to build:

```
/specify Build an application that can help me organize my photos in separate photo albums. 
Albums are grouped by date and can be re-organized by dragging and dropping on the main page. 
Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

### 3. Create Technical Implementation Plan

Use the `/plan` command to provide your tech stack and architecture choices:

```
/plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, 
and JavaScript as much as possible. Images are not uploaded anywhere and metadata is 
stored in a local SQLite database.
```

### 4. Break Down and Implement

Use `/tasks` to create an actionable task list, then ask your agent to implement the feature.

## AI Coding Agents

Specify works with various AI coding agents:

### Supported Agents
- **[Claude Code](https://www.anthropic.com/claude-code)**: Anthropic's coding assistant
- **[GitHub Copilot](https://code.visualstudio.com/)**: GitHub's AI pair programmer  
- **[Gemini CLI](https://github.com/google-gemini/gemini-cli)**: Google's command-line AI

### Agent Commands

Once you have specify-cli installed and a project initialized, use these commands in your AI agent:

- `/specify` - Create high-level specifications
- `/plan` - Define technical implementation approach
- `/tasks` - Break down into actionable tasks
- `/implement` - Generate working code

## Development Phases

| Phase                     | Type                     | Description                                                                                                           |
| ------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **0-to-1 Development**    | Greenfield               | Start with high-level requirements, generate specifications, plan implementation, build production-ready applications |
| **Creative Exploration**  | Parallel implementations | Explore diverse solutions, support multiple tech stacks & architectures, experiment with UX patterns                  |
| **Iterative Enhancement** | Brownfield modernization | Add features iteratively, modernize legacy systems, adapt existing processes                                          |

## Use Cases

### Greenfield Development
- Start new projects with clear specifications
- Generate multiple implementation approaches
- Validate concepts before heavy development

### Feature Development
- Add new features to existing applications
- Maintain consistency with existing architecture
- Document feature requirements clearly

### Legacy Modernization
- Document existing system behavior
- Plan modernization approaches
- Incrementally update systems

### Prototyping
- Quickly validate ideas
- Generate multiple design approaches
- Test concepts with real implementations

## Integration Examples

### VS Code Workflow

1. **Install DevContainer**: Use this feature in your `.devcontainer/devcontainer.json`
2. **Initialize Project**: Run `specify init my-project`
3. **Use Agent Commands**: Use `/specify`, `/plan`, `/tasks` in your AI coding agent
4. **Implement**: Let the AI generate code based on specifications

### GitHub Codespaces

```json
{
    "name": "Spec-Driven Development",
    "image": "mcr.microsoft.com/devcontainers/python:3.11",
    "features": {
        "ghcr.io/ruanzx/features/specify-cli:latest": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "postCreateCommand": "specify check"
}
```

### CI/CD Integration

```yaml
# .github/workflows/spec-validation.yml
name: Validate Specifications
on:
  pull_request:
    paths: ['specs/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install specify-cli
        run: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          export PATH="$HOME/.local/bin:$PATH"
          uv tool install git+https://github.com/github/spec-kit.git
      
      - name: Check specifications
        run: |
          export PATH="$HOME/.local/bin:$PATH"
          specify check
```

### Docker Development

```dockerfile
# Dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.11

# Install specify-cli
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    export PATH="$HOME/.local/bin:$PATH" && \
    uv tool install git+https://github.com/github/spec-kit.git

# Set PATH for uv tools
ENV PATH="$PATH:/root/.local/bin"

WORKDIR /workspace
```

## Commands Reference

### Project Management

```bash
# Initialize new project
specify init <project-name>

# Initialize in current directory
specify init --here

# Check system requirements
specify check
```

### Development Workflow

The main development happens through AI agent commands, but you can also:

```bash
# Check project status
ls -la

# View project structure
tree . -I '__pycache__'

# Check Git status
git status
```

## Project Structure

After running `specify init my-project`, you'll get:

```
my-project/
├── .gitignore
├── README.md
├── specs/
│   └── README.md
└── src/
    └── README.md
```

## Best Practices

### Specification Writing
- **Be specific about user experience**: Focus on what users will see and do
- **Avoid technical implementation details**: Let the AI choose appropriate tech
- **Include constraints**: Mention any organizational or technical limitations
- **Think in scenarios**: Describe how users will interact with the application

### Technical Planning
- **Choose familiar tech stacks**: Unless experimenting, stick to known technologies
- **Consider deployment targets**: Specify where the application will run
- **Define data storage**: Be clear about persistence requirements
- **Set performance expectations**: Include any performance or scale requirements

### Implementation Process
- **Break down into tasks**: Use `/tasks` to create manageable work items
- **Iterate incrementally**: Build and test small pieces first
- **Document as you go**: Update specifications based on learnings
- **Test early and often**: Validate against original specifications

## Troubleshooting

### Installation Issues

**Python version incompatible:**
```bash
# Check Python version
python3 --version

# Install Python 3.11+ if needed
# Use the Python DevContainer feature for easy setup
```

**uv installation failed:**
```bash
# Manual uv installation
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

**specify command not found:**
```bash
# Check PATH
echo $PATH

# Add uv tools to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or restart shell
exec $SHELL
```

### Project Issues

**Template download fails:**
```bash
# Check internet connectivity
curl -I https://github.com

# Check Git credentials
git config --list

# Try manual clone
git clone https://github.com/github/spec-kit.git
```

**AI agent commands not working:**
- Ensure you're using a supported AI coding agent
- Check that the agent has access to the project files
- Verify the agent understands the `/specify`, `/plan`, `/tasks` commands

### Development Issues

**Specifications too vague:**
- Add more specific user scenarios
- Include concrete examples
- Define success criteria

**Generated code doesn't match expectations:**
- Refine specifications with more details
- Use `/plan` to guide technical choices
- Break down complex features with `/tasks`

## Platform Support

- ✅ Linux (all architectures)
- ✅ macOS (through compatible base images)
- ✅ Windows WSL2 (through compatible base images)

## Requirements

- **Python 3.11+**: Core runtime requirement
- **Git**: For project templates and version control
- **Internet**: For downloading templates and AI interactions
- **AI Coding Agent**: For the full Spec-Driven Development workflow

## Security Considerations

- **Template Sources**: Only uses official GitHub spec-kit templates
- **AI Interactions**: No sensitive data is sent to AI services by specify-cli itself
- **Dependencies**: All Python dependencies are installed in isolated uv environments
- **Network Access**: Requires internet for initial setup and template downloads

## Related Features

- **Python**: Required base runtime for specify-cli
- **Git**: Required for project templates and version control
- **GitHub CLI**: Useful for GitHub integration and authentication
- **Docker-in-Docker**: For containerized development workflows

## Advanced Usage

### Custom Templates

While specify-cli uses the official template, you can customize the generated projects:

```bash
# After initialization, customize the structure
specify init my-project
cd my-project

# Add your own template files
mkdir templates
# Add custom specification templates or examples
```

### Enterprise Integration

```json
{
    "features": {
        "ghcr.io/devcontainers/features/python:1": {
            "version": "3.11"
        },
        "ghcr.io/ruanzx/features/specify-cli:latest": {},
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        "ghcr.io/ruanzx/features/kubectl:latest": {}
    },
    "postCreateCommand": "specify check && az login && kubectl config current-context"
}
```

### Multi-Language Projects

Specify-cli can generate projects in any language:

```
/plan Use Python FastAPI for the backend API, React TypeScript for the frontend, 
and PostgreSQL for the database. Deploy using Docker containers on Azure Container Apps.
```

## Additional Resources

- [Spec Kit Documentation](https://github.com/github/spec-kit)
- [Spec-Driven Development Methodology](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Claude Code Setup](https://docs.anthropic.com/en/docs/claude-code/setup)
- [GitHub Copilot](https://code.visualstudio.com/)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- [uv Package Manager](https://docs.astral.sh/uv/)
- [Python DevContainer Features](https://github.com/devcontainers/features/tree/main/src/python)