# Claude Code CLI DevContainer Feature

This feature installs [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code/setup), an AI-powered coding assistant by Anthropic that brings Claude's capabilities directly into your terminal and development workflow. Experience intelligent code completion, debugging assistance, and natural language programming in your development environment.

## Quick Start

```bash
# Check if Claude Code CLI is working
claude --version

# Run installation diagnostics
claude doctor

# Start Claude Code in your project
cd your-awesome-project
claude

# Update Claude Code manually
claude update
```

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {}
    }
}
```

## Options

| Option            | Type    | Default  | Description                                                                                      |
| ----------------- | ------- | -------- | ------------------------------------------------------------------------------------------------ |
| `version`         | string  | `latest` | Version to install: `latest` (most recent) or `stable` (stable release)                          |
| `installMethod`   | string  | `npm`    | Installation method: `npm` (Node.js package) or `native` (native binary, beta)                   |
| `installGlobally` | boolean | `true`   | Install Claude Code CLI globally when using npm method. Set to false to skip global installation |

## Examples

### Basic Installation

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {}
    }
}
```

### With Node.js DevContainer Feature

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "18"
        },
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {}
    }
}
```

### Using Native Installation Method

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {
            "installMethod": "native",
            "version": "stable"
        }
    }
}
```

### Complete AI Development Environment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "18"
        },
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {},
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/ruanzx/features/gemini-cli:latest": {}
    }
}
```

### Skip Global Installation (npm method)

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {
            "installGlobally": false
        }
    }
}
```

## What's Installed

This feature installs:
- **Claude Code CLI**: The main AI-powered coding assistant
- **Dependencies**: Automatically managed through npm or native installer
- **ripgrep**: Search functionality (usually included with Claude Code)

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu 20.04+/Debian 10+ (Linux support in DevContainers)
- **Hardware**: 4GB+ RAM
- **Network**: Internet connection required for authentication and AI processing
- **Shell**: Works best in Bash, Zsh, or Fish

### npm Installation Method
- **Node.js 18+**: Required for npm installation (automatically checked)
- **npm**: Package manager for Node.js (automatically checked)

### Native Installation Method
- **curl**: For downloading the installer (automatically checked)
- **Architecture**: x86_64/amd64 or aarch64/arm64 supported

## Verification

After installation, you can verify Claude Code CLI is working:

```bash
# Check version
claude --version

# Run installation diagnostics
claude doctor

# Test basic functionality
claude --help

# Start interactive session (requires authentication)
cd your-project
claude
```

## 🚀 Why Claude Code CLI?

- **🧠 Advanced AI**: Powered by Claude, Anthropic's advanced AI assistant
- **💻 Terminal Integration**: Seamless integration with your existing development workflow
- **🔍 Code Understanding**: Deep understanding of your codebase and context
- **⚡ Intelligent Assistance**: Code completion, debugging, refactoring, and explanation
- **🔄 Continuous Updates**: Automatic updates with the latest improvements
- **🛡️ Security Focused**: Secure credential management and data handling

## 📋 Key Features

### Intelligent Code Assistance
- **Code Completion**: Context-aware suggestions and completions
- **Code Explanation**: Natural language explanations of complex code
- **Debugging Help**: Identify and fix bugs with AI assistance
- **Refactoring**: Intelligent code improvements and optimization

### Development Workflow Integration
- **Project Awareness**: Understands your entire codebase context
- **Multi-language Support**: Works with virtually any programming language
- **Terminal Native**: Designed for developers who live in the command line
- **Real-time Assistance**: Get help without leaving your development environment

### Advanced Capabilities
- **Natural Language Programming**: Describe what you want to build in plain English
- **Code Generation**: Generate boilerplate, functions, and entire features
- **Documentation**: Automatic documentation generation and improvement
- **Code Review**: AI-powered code review and suggestions

## 🔐 Authentication Options

Claude Code CLI offers multiple authentication methods to suit different environments:

### Option 1: Anthropic Console (Default)
✨ **Best for**: Individual developers and teams with billing setup

**Requirements**:
- Active billing at [console.anthropic.com](https://console.anthropic.com/)
- Internet connection for OAuth process
- Web browser for initial authentication

**Benefits**:
- Full feature access with usage-based billing
- Automatic workspace creation for usage tracking
- Enterprise-grade security and compliance

```bash
# Start Claude Code and follow OAuth prompts
cd your-project
claude
```

### Option 2: Claude Pro/Max Plan
✨ **Best for**: Individual developers with existing Claude.ai subscription

**Requirements**:
- Active [Claude Pro or Max subscription](https://www.anthropic.com/pricing)
- Claude.ai account credentials

**Benefits**:
- Unified subscription for both Claude.ai and Claude Code
- Better value proposition with combined features
- Single account management

```bash
# Choose Claude App option during authentication
claude
```

### Option 3: Enterprise Platforms
✨ **Best for**: Enterprise teams with existing cloud infrastructure

**Supported Platforms**:
- Amazon Bedrock
- Google Vertex AI

**Benefits**:
- Integration with existing cloud infrastructure
- Enterprise security and compliance
- Centralized billing and management

For enterprise setup, see the [third-party integrations guide](https://docs.anthropic.com/en/docs/claude-code/third-party-integrations).

## 🚀 Getting Started

### Basic Usage

```bash
# Navigate to your project
cd your-awesome-project

# Start Claude Code
claude

# Update Claude Code
claude update

# Run diagnostics
claude doctor
```

### First-Time Setup

1. **Install and verify**:
   ```bash
   claude --version
   claude doctor
   ```

2. **Navigate to your project**:
   ```bash
   cd your-project-directory
   ```

3. **Start Claude Code**:
   ```bash
   claude
   ```

4. **Follow authentication prompts**:
   - Choose your preferred authentication method
   - Complete the setup process
   - Start coding with AI assistance!

### Common Commands

```bash
# Get help
claude --help

# Check version
claude --version

# Run diagnostics
claude doctor

# Update manually
claude update

# Start in specific directory
cd /path/to/project && claude
```

## Integration Examples

### VS Code Workflow

1. **Install DevContainer**: Use this feature in your `.devcontainer/devcontainer.json`
2. **Set up authentication**: Run `claude` and complete authentication
3. **Start coding**: Use Claude Code for intelligent assistance in your terminal
4. **Combine with other tools**: Works great alongside GitHub Copilot and other AI tools

### GitHub Codespaces

```json
{
    "name": "AI Development with Claude Code",
    "image": "mcr.microsoft.com/devcontainers/javascript-node:18",
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "postCreateCommand": "claude doctor"
}
```

### CI/CD Integration

```yaml
# .github/workflows/ai-code-review.yml
name: AI Code Review with Claude
on:
  pull_request:

jobs:
  claude-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install Claude Code CLI
        run: npm install -g @anthropic-ai/claude-code
      
      - name: Run Claude Code Analysis
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude doctor
          # Add your Claude Code automation here
```

### Docker Development

```dockerfile
# Dockerfile
FROM node:18-alpine

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Verify installation
RUN claude --version && claude doctor

WORKDIR /workspace
```

## Installation Methods

### npm Installation (Default)
- **Pros**: Easy to manage, integrates with Node.js ecosystem, familiar for JS developers
- **Cons**: Requires Node.js 18+, larger dependency footprint
- **Best for**: Node.js projects, existing npm workflows

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {
            "installMethod": "npm"
        }
    }
}
```

### Native Binary Installation (Beta)
- **Pros**: Smaller footprint, faster startup, no Node.js dependency
- **Cons**: Beta status, limited platform support
- **Best for**: Non-Node.js projects, performance-critical environments

```json
{
    "features": {
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {
            "installMethod": "native"
        }
    }
}
```

## Configuration

### Auto Updates

Claude Code automatically updates to ensure you have the latest features and security fixes:

- **Update checks**: Performed on startup and periodically while running
- **Update process**: Downloads and installs automatically in the background
- **Notifications**: You'll see notifications when updates are installed
- **Applying updates**: Updates take effect the next time you start Claude Code

### Disable Auto Updates

Set the `DISABLE_AUTOUPDATER` environment variable:

```bash
export DISABLE_AUTOUPDATER=1
```

Or configure in your settings.json file (see [Claude Code settings documentation](https://docs.anthropic.com/en/docs/claude-code/settings)).

### Environment Variables

```bash
# Disable auto-updates
export DISABLE_AUTOUPDATER=1

# For Windows native installation with Git Bash
export CLAUDE_CODE_GIT_BASH_PATH="C:\Program Files\Git\bin\bash.exe"

# For Alpine Linux and musl-based distributions
export USE_BUILTIN_RIPGREP=0
```

## Troubleshooting

### Installation Issues

**Node.js version incompatible (npm method):**
```bash
# Check Node.js version
node --version

# Install Node.js 18+ if needed
# Use the Node.js DevContainer feature for easy setup
```

**npm installation failed:**
```bash
# Check npm
npm --version

# Avoid using sudo with npm
# If you get permission errors, see Claude Code troubleshooting guide

# Clear npm cache
npm cache clean --force

# Try installing again
npm install -g @anthropic-ai/claude-code
```

**Native installation failed:**
```bash
# Check architecture support
uname -m

# For Alpine Linux, install required packages
apk add libgcc libstdc++ ripgrep
export USE_BUILTIN_RIPGREP=0

# Fallback to npm method
```

**Command not found after installation:**
```bash
# Check if claude is in PATH
which claude

# For npm installation, check npm global directory
npm config get prefix

# Add to PATH if needed
export PATH="$(npm config get prefix)/bin:$PATH"

# Or restart shell
exec $SHELL
```

### Authentication Issues

**OAuth authentication fails:**
```bash
# Ensure you have active billing at console.anthropic.com
# Check internet connectivity
# Try different authentication method

# Verify credentials are stored correctly
claude doctor
```

**Permission errors:**
```bash
# Don't use sudo with npm install
# Configure npm properly for global installations
# See: https://docs.anthropic.com/en/docs/claude-code/troubleshooting#linux-permission-issues

# Alternative: use native installation method
```

**Billing/subscription issues:**
```bash
# Check your billing status at console.anthropic.com
# Ensure you have an active Claude Pro/Max plan for Claude App authentication
# Verify enterprise setup for Bedrock/Vertex AI
```

### Usage Issues

**Search functionality fails:**
```bash
# Check if ripgrep is installed
which rg

# For Alpine Linux
apk add ripgrep
export USE_BUILTIN_RIPGREP=0

# Run diagnostics
claude doctor
```

**Performance issues:**
```bash
# Ensure you have at least 4GB RAM
# Check internet connectivity
# Try native installation method for better performance

# Run diagnostics
claude doctor
```

**Large project performance:**
```bash
# Consider excluding certain directories
# Use .claudeignore file to exclude unnecessary files
# Ensure good internet connectivity for API calls
```

### Common Error Messages and Solutions

| Error Message                              | Solution                                                             |
| ------------------------------------------ | -------------------------------------------------------------------- |
| `Command 'claude' not found`               | Add npm global bin to PATH or restart shell                          |
| `Node.js version 18 or higher is required` | Upgrade Node.js or use Node.js DevContainer feature                  |
| `Authentication failed`                    | Check billing status at console.anthropic.com or verify subscription |
| `Permission denied`                        | Don't use sudo with npm; configure npm properly                      |
| `Search functionality not working`         | Install ripgrep or set USE_BUILTIN_RIPGREP=0                         |
| `Auto-updater permission issues`           | Use `claude migrate-installer` or disable auto-updates               |
| `libgcc/libstdc++ not found`               | Install missing libraries (Alpine: `apk add libgcc libstdc++`)       |

## Best Practices

### Development Workflow
- **Start Claude in project root**: Navigate to your project directory before running `claude`
- **Use .claudeignore**: Exclude unnecessary files (node_modules, logs, build artifacts)
- **Regular updates**: Keep Claude Code updated for the latest features
- **Run diagnostics**: Use `claude doctor` to check installation health

### Authentication
- **Choose appropriate method**: Use Console for teams, Pro/Max for individuals, Enterprise for organizations
- **Secure credentials**: Claude Code securely stores credentials; avoid manual credential management
- **Billing awareness**: Monitor usage through console.anthropic.com for Console authentication

### Performance Optimization
- **Adequate resources**: Ensure at least 4GB RAM for optimal performance
- **Good connectivity**: Stable internet connection for AI processing
- **Project size**: Consider excluding large directories for better performance
- **Native installation**: Try native method for better performance in non-Node.js projects

### Security
- **Credential management**: Let Claude Code handle credential storage securely
- **Network security**: Ensure secure network connections for API communication
- **Code privacy**: Review Anthropic's data handling policies for your organization
- **Access control**: Use appropriate authentication method for your security requirements

## Platform Support

- ✅ Linux (Ubuntu 20.04+, Debian 10+)
- ✅ macOS 10.15+ (through compatible base images)
- ✅ Windows WSL 1/2 (through compatible base images)
- ✅ Windows with Git Bash (through compatible base images)

## Requirements

### Minimum Requirements
- **Operating System**: Ubuntu 20.04+/Debian 10+
- **RAM**: 4GB+ recommended
- **Network**: Internet connection for authentication and AI processing
- **Shell**: Bash, Zsh, or Fish

### npm Installation Method
- **Node.js 18+**: Core runtime requirement
- **npm**: Package manager for installation

### Native Installation Method
- **curl**: For downloading installer
- **Architecture**: x86_64/amd64 or aarch64/arm64
- **Additional packages**: For Alpine Linux: libgcc, libstdc++, ripgrep

## Security Considerations

- **Credential storage**: Claude Code securely manages authentication credentials
- **API communication**: All communication with Anthropic's API is encrypted
- **Data handling**: Review [Anthropic's privacy policy](https://www.anthropic.com/privacy) for data usage
- **Network access**: Requires internet for AI processing and authentication
- **Code analysis**: Your code is sent to Anthropic's servers for AI processing

## Related Features

- **Node.js**: Required base runtime for npm installation method
- **Git**: Useful for version control and code analysis
- **GitHub CLI**: Complements Claude Code for GitHub workflows
- **Gemini CLI**: Alternative AI coding assistant that works alongside Claude Code

## Advanced Usage

### Enterprise Deployment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "18"
        },
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {
            "installMethod": "native",
            "version": "stable"
        },
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    "postCreateCommand": "claude doctor && echo 'Claude Code CLI ready for enterprise development'",
    "remoteEnv": {
        "DISABLE_AUTOUPDATER": "0"
    }
}
```

### Multi-AI Environment

```json
{
    "features": {
        "ghcr.io/devcontainers/features/node:1": {
            "version": "18"
        },
        "ghcr.io/ruanzx/features/claude-code-cli:latest": {},
        "ghcr.io/ruanzx/features/gemini-cli:latest": {},
        "ghcr.io/ruanzx/features/spec-kit:latest": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "postCreateCommand": "claude doctor && gemini --version && specify check && echo 'Multi-AI development environment ready'"
}
```

### Automated Setup Script

```bash
#!/bin/bash
# claude-setup.sh - Automated Claude Code setup

# Install and verify
claude --version
claude doctor

# Set up authentication (requires manual intervention)
echo "Please complete authentication setup:"
claude

# Verify authentication worked
if claude doctor > /dev/null 2>&1; then
    echo "✅ Claude Code CLI setup completed successfully"
else
    echo "❌ Setup incomplete - please check authentication"
fi
```

## Additional Resources

- [Official Documentation](https://docs.anthropic.com/en/docs/claude-code/setup)
- [Troubleshooting Guide](https://docs.anthropic.com/en/docs/claude-code/troubleshooting)
- [Third-party Integrations](https://docs.anthropic.com/en/docs/claude-code/third-party-integrations)
- [Development Containers](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- [Settings Configuration](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Anthropic Console](https://console.anthropic.com/)
- [Claude.ai Pricing](https://www.anthropic.com/pricing)
- [Supported Countries](https://www.anthropic.com/supported-countries)
