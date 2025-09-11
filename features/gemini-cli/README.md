# Gemini CLI DevContainer Feature

This feature installs [Gemini CLI](https://github.com/google-gemini/gemini-cli), an open-source AI agent that brings the power of Google Gemini directly into your terminal. Designed for developers who live in the command line, it provides lightweight access to Gemini with built-in tools, MCP (Model Context Protocol) support, and powerful integrations.

## Quick Start

```bash
# Check if Gemini CLI is working
gemini --version

# Start Gemini CLI with OAuth authentication
gemini

# Run in non-interactive mode
gemini -p "Explain the architecture of this codebase"

# Include specific directories
gemini --include-directories ../lib,../docs

# Use specific model
gemini -m gemini-2.5-flash
```

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gemini-cli:latest": {}
    }
}
```

## Options

| Option            | Type    | Default  | Description                                                                                       |
| ----------------- | ------- | -------- | ------------------------------------------------------------------------------------------------- |
| `version`         | string  | `latest` | Version to install: `latest` (stable), `preview` (weekly), `nightly` (daily), or specific version |
| `installGlobally` | boolean | `true`   | Install Gemini CLI globally using npm. Set to false to skip global installation                   |

## Examples

### Basic Installation

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gemini-cli:latest": {}
    }
}
```

### With Node.js DevContainer Feature

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/gemini-cli:latest": {}
    }
}
```

### Using Preview Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gemini-cli:latest": {
            "version": "preview"
        }
    }
}
```

### Complete AI Development Environment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/gemini-cli:latest": {},
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    }
}
```

### Skip Global Installation

```json
{
    "features": {
        "ghcr.io/ruanzx/features/gemini-cli:latest": {
            "installGlobally": false
        }
    }
}
```

## What's Installed

This feature installs:
- **Gemini CLI**: The main AI agent command-line tool
- **Node.js dependencies**: Automatically managed through npm

## Prerequisites

- **Node.js 20+**: Required for running Gemini CLI (automatically checked)
- **npm**: Package manager for Node.js (automatically checked)
- **Internet connection**: Required for API access and model interactions

## Verification

After installation, you can verify Gemini CLI is working:

```bash
# Check version
gemini --version

# Test basic functionality
gemini --help

# Start interactive session (requires authentication)
gemini
```

## 🚀 Why Gemini CLI?

- **🎯 Free tier**: 60 requests/min and 1,000 requests/day with personal Google account
- **🧠 Powerful Gemini 2.5 Pro**: Access to 1M token context window
- **🔧 Built-in tools**: Google Search grounding, file operations, shell commands, web fetching
- **🔌 Extensible**: MCP (Model Context Protocol) support for custom integrations
- **💻 Terminal-first**: Designed for developers who live in the command line
- **🛡️ Open source**: Apache 2.0 licensed

## 📋 Key Features

### Code Understanding & Generation
- Query and edit large codebases
- Generate new apps from PDFs, images, or sketches using multimodal capabilities
- Debug issues and troubleshoot with natural language

### Automation & Integration
- Automate operational tasks like querying pull requests or handling complex rebases
- Use MCP servers to connect new capabilities
- Run non-interactively in scripts for workflow automation

### Advanced Capabilities
- Ground your queries with built-in [Google Search](https://ai.google.dev/gemini-api/docs/grounding) for real-time information
- Conversation checkpointing to save and resume complex sessions
- Custom context files (GEMINI.md) to tailor behavior for your projects

### GitHub Integration
- Pull Request Reviews: Automated code review with contextual feedback
- Issue Triage: Automated labeling and prioritization
- On-demand Assistance: Mention `@gemini-cli` in issues and pull requests
- Custom Workflows: Build automated, scheduled and on-demand workflows

## 🔐 Authentication Options

Choose the authentication method that best fits your needs:

### Option 1: OAuth login (Using your Google Account)
✨ **Best for**: Individual developers and anyone with a Gemini Code Assist License

**Benefits**:
- Free tier: 60 requests/min and 1,000 requests/day
- Gemini 2.5 Pro with 1M token context window
- No API key management - just sign in with your Google account
- Automatic updates to latest models

```bash
# Start Gemini CLI and choose OAuth
gemini

# For paid Code Assist License, set your Google Cloud Project
export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_NAME"
gemini
```

### Option 2: Gemini API Key
✨ **Best for**: Developers who need specific model control or paid tier access

**Benefits**:
- Free tier: 100 requests/day with Gemini 2.5 Pro
- Model selection: Choose specific Gemini models
- Usage-based billing: Upgrade for higher limits when needed

```bash
# Get your key from https://aistudio.google.com/apikey
export GEMINI_API_KEY="YOUR_API_KEY"
gemini
```

### Option 3: Vertex AI
✨ **Best for**: Enterprise teams and production workloads

**Benefits**:
- Enterprise features: Advanced security and compliance
- Scalable: Higher rate limits with billing account
- Integration: Works with existing Google Cloud infrastructure

```bash
# Get your key from Google Cloud Console
export GOOGLE_API_KEY="YOUR_API_KEY"
export GOOGLE_GENAI_USE_VERTEXAI=true
gemini
```

## 🚀 Getting Started

### Basic Usage

```bash
# Start in current directory
gemini

# Include multiple directories
gemini --include-directories ../lib,../docs

# Use specific model
gemini -m gemini-2.5-flash

# Non-interactive mode for scripts
gemini -p "Explain the architecture of this codebase"
```

### Quick Examples

#### Start a new project
```bash
cd new-project/
gemini
> Write me a Discord bot that answers questions using a FAQ.md file I will provide
```

#### Analyze existing code
```bash
git clone https://github.com/google-gemini/gemini-cli
cd gemini-cli
gemini
> Give me a summary of all of the changes that went in yesterday
```

## Integration Examples

### VS Code Workflow

1. **Install DevContainer**: Use this feature in your `.devcontainer/devcontainer.json`
2. **Set up authentication**: Run `gemini` and choose your auth method
3. **Start coding**: Use Gemini CLI for code analysis, generation, and debugging
4. **Automate workflows**: Use non-interactive mode in scripts

### GitHub Codespaces

```json
{
    "name": "AI Development with Gemini",
    "image": "mcr.microsoft.com/devcontainers/javascript-node:20",
    "features": {
        "ghcr.io/ruanzx/features/gemini-cli:latest": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "postCreateCommand": "gemini --version"
}
```

### CI/CD Integration

```yaml
# .github/workflows/ai-code-review.yml
name: AI Code Review
on:
  pull_request:

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Gemini CLI
        run: npm install -g @google/gemini-cli
      
      - name: Run AI Review
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          gemini -p "Review the changes in this pull request and provide feedback"
```

### Docker Development

```dockerfile
# Dockerfile
FROM node:20-alpine

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Verify installation
RUN gemini --version

WORKDIR /workspace
```

## Commands Reference

### Main Commands

```bash
# Get help
gemini --help

# Check version
gemini --version

# Start interactive session
gemini

# Non-interactive mode
gemini -p "Your prompt here"

# Include specific directories
gemini --include-directories path1,path2

# Use specific model
gemini -m gemini-2.5-flash
```

### Slash Commands (In Interactive Mode)

Once in interactive mode, you can use these slash commands:

- `/help` - Show available commands
- `/chat` - Switch to chat mode
- `/mcp` - MCP server management
- `/bug` - Report bugs directly from CLI
- `/clear` - Clear conversation
- `/exit` - Exit Gemini CLI

### Authentication Commands

```bash
# Start with OAuth (recommended)
gemini

# Use API key
export GEMINI_API_KEY="your-key"
gemini

# Use Vertex AI
export GOOGLE_API_KEY="your-key"
export GOOGLE_GENAI_USE_VERTEXAI=true
gemini
```

## MCP (Model Context Protocol) Integration

Gemini CLI supports MCP servers to extend capabilities. Configure MCP servers in `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "your-token"
      }
    }
  }
}
```

Example usage with MCP:
```bash
> @github List my open pull requests
> @slack Send a summary of today's commits to #dev channel
> @database Run a query to find inactive users
```

## Version Information

### Release Cadence
- **Stable (`latest`)**: Published weekly on Tuesdays at UTC 2000
- **Preview (`preview`)**: Published weekly on Tuesdays at UTC 2359 (may contain regressions)
- **Nightly (`nightly`)**: Published daily at UTC 0000 (bleeding edge, assume pending validations)

### Choosing the Right Version

```bash
# Most stable (recommended for production)
npm install -g @google/gemini-cli@latest

# Weekly previews (for testing new features)
npm install -g @google/gemini-cli@preview

# Daily builds (for bleeding edge features)
npm install -g @google/gemini-cli@nightly
```

## Configuration

### Environment Variables

```bash
# Authentication
export GEMINI_API_KEY="your-api-key"
export GOOGLE_CLOUD_PROJECT="your-project"
export GOOGLE_API_KEY="your-vertex-ai-key"
export GOOGLE_GENAI_USE_VERTEXAI=true

# Configuration
export GEMINI_MODEL="gemini-2.5-pro"
export GEMINI_INCLUDE_DIRECTORIES="../lib,../docs"
```

### Project-Specific Settings

Create a `GEMINI.md` file in your project root to provide context:

```markdown
# Project: My Application

This is a Node.js web application using Express and React.

## Architecture
- Backend: Express.js with MongoDB
- Frontend: React with TypeScript
- Deployment: Docker containers on AWS

## Development Guidelines
- Use TypeScript for all new code
- Follow ESLint configuration
- Write tests for all features
```

## Troubleshooting

### Installation Issues

**Node.js version incompatible:**
```bash
# Check Node.js version
node --version

# Install Node.js 20+ if needed
# Use the Node.js DevContainer feature for easy setup
```

**npm installation failed:**
```bash
# Check npm
npm --version

# Clear npm cache
npm cache clean --force

# Try installing again
npm install -g @google/gemini-cli@latest
```

**Command not found after installation:**
```bash
# Check if gemini is in PATH
which gemini

# Check npm global directory
npm config get prefix

# Add to PATH if needed
export PATH="$(npm config get prefix)/bin:$PATH"

# Or restart shell
exec $SHELL
```

### Authentication Issues

**OAuth authentication fails:**
```bash
# Ensure you have a web browser available
# For headless environments, use API key authentication instead
export GEMINI_API_KEY="your-api-key"
gemini
```

**API key not working:**
```bash
# Verify your API key
echo $GEMINI_API_KEY

# Get a new key from https://aistudio.google.com/apikey
export GEMINI_API_KEY="new-api-key"
```

**Vertex AI authentication fails:**
```bash
# Check Google Cloud credentials
gcloud auth list

# Set up Application Default Credentials
gcloud auth application-default login

# Or use service account key
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
```

### Usage Issues

**Large codebase performance:**
```bash
# Include only relevant directories
gemini --include-directories src,lib

# Use .geminiignore file to exclude files
echo "node_modules/" >> .geminiignore
echo "*.log" >> .geminiignore
```

**Token limit exceeded:**
- Break down large requests into smaller chunks
- Use conversation checkpointing for long sessions
- Consider using file-specific queries instead of entire codebase

**Model responses are slow:**
- Try using `gemini-2.5-flash` for faster responses
- Use non-interactive mode for automated tasks
- Consider using preview or nightly versions for performance improvements

### Common Error Messages and Solutions

| Error Message                              | Solution                                                          |
| ------------------------------------------ | ----------------------------------------------------------------- |
| `Command 'gemini' not found`               | Add npm global bin to PATH or restart shell                       |
| `Node.js version 20 or higher is required` | Upgrade Node.js or use Node.js DevContainer feature               |
| `Authentication failed`                    | Check API key or run OAuth setup with `gemini`                    |
| `Rate limit exceeded`                      | Wait for rate limit reset or upgrade to paid tier                 |
| `Invalid model name`                       | Use valid model names like `gemini-2.5-pro` or `gemini-2.5-flash` |
| `MCP server connection failed`             | Check MCP server configuration in `~/.gemini/settings.json`       |

## Best Practices

### Development Workflow
- **Use project context**: Create `GEMINI.md` files for project-specific information
- **Include relevant directories**: Use `--include-directories` to focus on relevant code
- **Use .geminiignore**: Exclude unnecessary files (node_modules, logs, build artifacts)
- **Save conversations**: Use checkpointing for complex, multi-step tasks

### Authentication
- **OAuth for development**: Use OAuth for individual development work
- **API keys for CI/CD**: Use API keys for automated workflows
- **Vertex AI for enterprise**: Use Vertex AI for production and enterprise environments

### Performance Optimization
- **Choose appropriate models**: Use `gemini-2.5-flash` for quick queries, `gemini-2.5-pro` for complex tasks
- **Limit scope**: Include only relevant files and directories
- **Use non-interactive mode**: For automated scripts and CI/CD pipelines

### Security
- **Protect API keys**: Never commit API keys to version control
- **Use environment variables**: Store credentials in environment variables
- **Review generated code**: Always review AI-generated code before deployment

## Platform Support

- ✅ Linux (all architectures)
- ✅ macOS (through compatible base images)
- ✅ Windows WSL2 (through compatible base images)

## Requirements

- **Node.js 20+**: Core runtime requirement
- **npm**: Package manager for installation
- **Internet**: For API access and model interactions
- **Authentication**: Google account, API key, or Vertex AI credentials

## Security Considerations

- **API key management**: Store keys securely in environment variables
- **Network access**: Requires internet for Gemini API access
- **Code execution**: Can execute shell commands when granted permission
- **Data privacy**: Review Google's terms of service for data handling

## Related Features

- **Node.js**: Required base runtime for Gemini CLI
- **Git**: Useful for code analysis and repository operations
- **GitHub CLI**: Complements Gemini CLI for GitHub workflows
- **Docker**: For containerized development with Gemini CLI

## Advanced Usage

### Custom MCP Servers

Create your own MCP server to extend Gemini CLI:

```javascript
// my-mcp-server.js
const { MCPServer } = require('@modelcontextprotocol/server');

const server = new MCPServer({
  name: 'my-custom-server',
  version: '1.0.0'
});

// Add custom tools
server.addTool('my-tool', async (params) => {
  // Your custom logic here
  return { result: 'Custom tool executed' };
});

server.start();
```

Register in `~/.gemini/settings.json`:
```json
{
  "mcpServers": {
    "custom": {
      "command": "node",
      "args": ["./my-mcp-server.js"]
    }
  }
}
```

### Enterprise Deployment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        "ghcr.io/ruanzx/features/gemini-cli:latest": {
            "version": "latest"
        },
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    "postCreateCommand": "gemini --version && echo 'Gemini CLI ready for enterprise development'",
    "remoteEnv": {
        "GOOGLE_CLOUD_PROJECT": "${localEnv:GOOGLE_CLOUD_PROJECT}",
        "GOOGLE_API_KEY": "${localEnv:GOOGLE_API_KEY}"
    }
}
```

### Automation Scripts

```bash
#!/bin/bash
# ai-code-review.sh

# Set up environment
export GEMINI_API_KEY="your-api-key"

# Run code review
REVIEW_OUTPUT=$(gemini -p "Review the recent changes and suggest improvements")

# Post to Slack or other notification system
echo "$REVIEW_OUTPUT" | slack-cli post --channel dev

# Save review to file
echo "$REVIEW_OUTPUT" > code-review-$(date +%Y%m%d).md
```

## Additional Resources

- [Official Documentation](https://github.com/google-gemini/gemini-cli/blob/main/docs/)
- [Quickstart Guide](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/index.md)
- [Authentication Setup](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/authentication.md)
- [MCP Server Integration](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)
- [GitHub Issues](https://github.com/google-gemini/gemini-cli/issues)
- [NPM Package](https://www.npmjs.com/package/@google/gemini-cli)
- [Contributing Guide](https://github.com/google-gemini/gemini-cli/blob/main/CONTRIBUTING.md)
- [Official Roadmap](https://github.com/orgs/google-gemini/projects/11/)
