# Strix Feature

Installs [Strix](https://github.com/usestrix/strix), open-source AI agents that act like real hackers to secure your applications. Strix runs code dynamically, finds vulnerabilities, and validates them through actual proof-of-concepts. Built for developers and security teams who need fast, accurate security testing.

## Features

- 🤖 **Autonomous AI Agents** - Agents that think and act like real security researchers
- 🔧 **Full Hacker Toolkit** - HTTP proxy, browser automation, terminal, Python runtime
- ✅ **Real Validation** - Generates actual PoCs, not just theoretical vulnerabilities
- 🕸️ **Multi-Agent Orchestration** - Teams of specialized agents that collaborate
- 💻 **Developer-First CLI** - Clean interface with actionable reports
- 🔄 **CI/CD Integration** - Block vulnerabilities before they reach production
- 📊 **Live Stats Panel** - Real-time vulnerability counts, token usage, and costs

## Requirements

- **Python 3.12+** - Required for Strix (installed via Python feature)
- **Docker** - Required for Strix sandbox execution (installed via docker-outside-of-docker feature)
- **LLM API Key** - OpenAI, Anthropic, or other LLM provider

## Usage

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/devcontainer-features/strix:1": {
      "version": "0.4.0"
    }
  }
}
```

## Options

| Option    | Type   | Default  | Description                    |
| --------- | ------ | -------- | ------------------------------ |
| `version` | string | `0.4.0`  | Version of Strix to install    |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/devcontainer-features/strix:1": {}
  }
}
```

### With Latest Version

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    },
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/devcontainer-features/strix:1": {
      "version": "latest"
    }
  }
}
```

## Configuration

Strix requires environment variables to be set before use:

```bash
# Required: LLM Configuration
export STRIX_LLM="openai/gpt-4"          # or "anthropic/claude-sonnet-4-5"
export LLM_API_KEY="your-api-key"

# Optional: For local models
export LLM_API_BASE="http://localhost:11434"  # e.g., Ollama

# Optional: For search capabilities
export PERPLEXITY_API_KEY="your-perplexity-key"
```

### Recommended Models

- **OpenAI GPT-4** (`openai/gpt-4`)
- **Anthropic Claude Sonnet 4.5** (`anthropic/claude-sonnet-4-5`)

Other models are supported but may have varying performance.

## Usage Examples

### Basic Security Scan

```bash
# Scan a local codebase
strix --target ./app-directory

# Scan a GitHub repository
strix --target https://github.com/org/repo

# Black-box web application assessment
strix --target https://your-app.com
```

### Advanced Testing

```bash
# Authenticated testing
strix --target https://your-app.com \
  --instruction "Test with credentials: user:pass"

# Multi-target testing (source + deployed)
strix -t https://github.com/org/app -t https://your-app.com

# Focused testing with custom instructions
strix --target https://api.example.com \
  --instruction "Focus on business logic flaws and IDOR vulnerabilities"

# File-based instructions (new in v0.4.0)
strix --target https://your-app.com --instruction @pentest-scope.txt
```

### Headless Mode (CI/CD)

Perfect for automation and CI/CD pipelines:

```bash
# Run without interactive UI
strix -n --target https://your-app.com

# Exits with non-zero code if vulnerabilities found
# Prints findings in real-time
```

### GitHub Actions Integration

Add to `.github/workflows/security-scan.yml`:

```yaml
name: strix-penetration-test

on:
  pull_request:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Strix
        run: pipx install strix-agent

      - name: Run Strix
        env:
          STRIX_LLM: ${{ secrets.STRIX_LLM }}
          LLM_API_KEY: ${{ secrets.LLM_API_KEY }}
        run: strix -n -t ./
```

## Command-Line Options

```bash
# Target specification
strix --target <URL|PATH|REPO>
strix -t <target1> -t <target2>  # Multiple targets

# Testing mode
strix -n                         # Non-interactive (headless)
strix --instruction "..."        # Custom test instructions
strix --instruction @file.txt    # File-based instructions (v0.4.0+)

# Configuration
strix --max-iterations 300       # Agent iteration limit
strix --output-dir ./results     # Custom output directory

# Help and version
strix --help
strix --version
```

## Vulnerability Detection

Strix can identify and validate:

### Access Control
- IDOR (Insecure Direct Object Reference)
- Privilege escalation
- Authentication bypass
- Broken access control

### Injection Attacks
- SQL injection
- NoSQL injection
- Command injection
- LDAP injection

### Server-Side Vulnerabilities
- SSRF (Server-Side Request Forgery)
- XXE (XML External Entity)
- Deserialization flaws
- File upload vulnerabilities

### Client-Side Vulnerabilities
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- DOM-based vulnerabilities
- Prototype pollution

### Business Logic
- Race conditions
- Workflow manipulation
- Payment logic flaws
- Rate limit bypass

### Authentication & Session
- JWT vulnerabilities
- Session fixation
- Cookie security issues
- OAuth misconfigurations

### Infrastructure
- Misconfigurations
- Exposed services
- Information disclosure
- Security header issues

## Live Stats Panel (v0.4.0)

The new interactive stats panel shows:
- 🔍 Vulnerabilities found (by severity)
- 💰 Token usage and cost estimates
- 🤖 Active agents and tools
- ⏱️ Scan progress

## Results and Reports

Strix saves results to `strix_runs/<run-name>/`:
- **findings.json** - Structured vulnerability data
- **report.html** - Human-readable HTML report
- **logs/** - Detailed execution logs

### Report Features (v0.4.0)
- Real-time persistence (survives crashes)
- Per-severity vulnerability counts
- Validated findings with PoCs
- Clear remediation steps

## Advanced Features

### Multi-Agent Orchestration

Strix uses specialized agents:
- **Reconnaissance agents** - Map attack surface
- **Vulnerability scanner agents** - Find security issues
- **Exploit development agents** - Create PoCs
- **Validation agents** - Confirm findings

### Security Toolkit

Each agent has access to:
- **HTTP Proxy** - Request/response manipulation
- **Browser Automation** - Multi-tab testing (Playwright)
- **Terminal Environments** - Interactive shells
- **Python Runtime** - Custom exploit development
- **Reconnaissance Tools** - OSINT and discovery
- **Code Analysis** - Static and dynamic analysis

## Tips & Best Practices

1. **Start Small** - Test on a small scope first to understand behavior
2. **Use Headless Mode** - For CI/CD and automated testing
3. **Monitor Costs** - Check live stats panel for token usage
4. **Custom Instructions** - Provide specific context for better results
5. **Multi-Target** - Combine source code and deployed app scans
6. **Docker Required** - Ensure Docker is running before starting
7. **Rate Limits** - v0.4.0 has improved rate-limit handling

## Verification

After installation, verify Strix is working:

```bash
# Check installation
which strix

# Check version
strix --version

# View help
strix --help

# Ensure Docker is running
docker ps

# Set required environment variables
export STRIX_LLM="openai/gpt-4"
export LLM_API_KEY="your-api-key"

# Run a test scan (optional)
strix --target https://example.com -n
```

## Troubleshooting

### pipx Not Found

Ensure Python is installed:
```bash
python3 --version
pip3 install --user pipx
export PATH="$HOME/.local/bin:$PATH"
```

### Docker Not Running

Strix requires Docker:
```bash
# Check Docker status
docker ps

# If not running, start Docker
sudo systemctl start docker
```

### LLM API Errors

Verify your API configuration:
```bash
# Check environment variables
echo $STRIX_LLM
echo $LLM_API_KEY

# Test API access
curl -H "Authorization: Bearer $LLM_API_KEY" \
  https://api.openai.com/v1/models
```

### Rate Limit Issues

v0.4.0 improved rate-limit handling, but you can:
- Use a different LLM provider
- Reduce max-iterations
- Add delays between scans

### Permission Errors

Ensure proper permissions:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Re-login or run
newgrp docker
```

## Security Warning

⚠️ **Important**: Only test applications you own or have explicit permission to test. You are responsible for using Strix ethically and legally.

## Cloud Option

Want to skip local setup? Use [app.usestrix.com](https://app.usestrix.com/) for:
- No local setup required
- No API key management
- Shareable dashboards
- CI/CD integrations
- Continuous monitoring

## Community & Support

- 💬 [Join Discord](https://discord.gg/YjKFvEZSdZ)
- 🐛 [Report Issues](https://github.com/usestrix/strix/issues)
- ⭐ [Star on GitHub](https://github.com/usestrix/strix)
- 📚 [Documentation](https://usestrix.com/)

## License

This feature installs Strix which is licensed under the [Apache-2.0 License](https://github.com/usestrix/strix/blob/main/LICENSE).

## References

- [Strix GitHub Repository](https://github.com/usestrix/strix)
- [Strix Website](https://usestrix.com/)
- [Release Notes](https://github.com/usestrix/strix/releases)
