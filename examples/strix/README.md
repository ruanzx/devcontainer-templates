# Strix Security Testing Example

This example demonstrates how to use the Strix feature in a dev container for AI-powered penetration testing and security assessments.

## What is Strix?

[Strix](https://github.com/usestrix/strix) is an open-source AI-powered security testing tool that uses autonomous agents to act like real hackers. It runs code dynamically, finds vulnerabilities, and validates them through actual proof-of-concepts (PoCs).

## Features Included

- ✅ Strix v0.4.0 - AI penetration testing agent
- ✅ Python 3.12 - Required runtime
- ✅ Docker support - For Strix sandbox execution
- ✅ pipx - Python application installer

## Prerequisites

Before using Strix, you need:

1. **LLM API Key** - Get one from:
   - [OpenAI](https://platform.openai.com/api-keys) (recommended: GPT-4)
   - [Anthropic](https://claude.ai/platform/api) (recommended: Claude Sonnet 4.5)
   - Or use a local LLM (Ollama, LM Studio)

2. **Docker Running** - Strix uses Docker for sandbox execution

## Configuration

### Set Environment Variables

Add your API key to your local environment before starting the container:

```bash
# On your host machine
export LLM_API_KEY="your-api-key-here"
```

The devcontainer is configured to pass this through via `remoteEnv`.

### Supported LLM Providers

```bash
# OpenAI (recommended)
export STRIX_LLM="openai/gpt-4"

# Anthropic (recommended)
export STRIX_LLM="anthropic/claude-sonnet-4-5"

# Local Ollama
export STRIX_LLM="ollama/llama2"
export LLM_API_BASE="http://localhost:11434"

# Azure OpenAI
export STRIX_LLM="azure/gpt-4"
export AZURE_API_KEY="your-azure-key"
```

## Usage

### Basic Security Scans

```bash
# Scan a local codebase
strix --target ./your-app

# Scan a GitHub repository
strix --target https://github.com/org/repo

# Black-box web application test
strix --target https://your-app.com

# Scan an IP address
strix --target 192.168.1.100
```

### Advanced Testing Scenarios

```bash
# Authenticated testing
strix --target https://your-app.com \
  --instruction "Test with credentials: admin:password123"

# Multi-target assessment (source + deployed)
strix -t https://github.com/org/app \
     -t https://your-app.com

# Focus on specific vulnerabilities
strix --target https://api.example.com \
  --instruction "Focus on IDOR, XSS, and authentication bypass"

# File-based instructions (v0.4.0+)
echo "Test the /api/users endpoint for IDOR vulnerabilities" > scope.txt
strix --target https://your-app.com --instruction @scope.txt

# Custom run name
strix --target https://your-app.com \
  --run-name "sprint-23-security-review"
```

### Headless Mode (CI/CD)

```bash
# Run without interactive TUI
strix -n --target https://your-app.com

# Returns non-zero exit code if vulnerabilities found
# Perfect for CI/CD pipelines
```

### View Results

```bash
# Results are saved to:
cd strix_runs/<run-name>/

# View findings
cat findings.json

# Open HTML report
open report.html  # or xdg-open report.html on Linux
```

## What Strix Tests For

### Access Control
- IDOR (Insecure Direct Object Reference)
- Privilege escalation
- Broken access control
- Authorization bypass

### Injection Attacks
- SQL injection
- NoSQL injection
- Command injection
- LDAP injection
- Template injection

### Server-Side Vulnerabilities
- SSRF (Server-Side Request Forgery)
- XXE (XML External Entity)
- Deserialization flaws
- File upload vulnerabilities
- Path traversal

### Client-Side Vulnerabilities
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- DOM-based vulnerabilities
- Prototype pollution
- Clickjacking

### Business Logic
- Race conditions
- Workflow manipulation
- Payment logic flaws
- Rate limit bypass
- Mass assignment

### Authentication & Session
- JWT vulnerabilities
- Session fixation
- Cookie security
- OAuth misconfigurations
- Password reset flaws

### Infrastructure
- Misconfigurations
- Exposed services
- Information disclosure
- Security headers
- CORS issues

## Live Stats Panel (v0.4.0)

While Strix runs, you'll see real-time statistics:
- 🔍 Vulnerabilities found (by severity: Critical, High, Medium, Low)
- 💰 Token usage and estimated costs
- 🤖 Active agents and tools in use
- ⏱️ Scan progress and time elapsed

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/strix-security.yml`:

```yaml
name: Strix Security Scan

on:
  pull_request:
    branches: [ main ]

jobs:
  security-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      
      - name: Install Strix
        run: pipx install strix-agent
      
      - name: Run Security Scan
        env:
          STRIX_LLM: ${{ secrets.STRIX_LLM }}
          LLM_API_KEY: ${{ secrets.LLM_API_KEY }}
        run: |
          strix -n --target ./
      
      - name: Upload Security Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: strix-report
          path: strix_runs/*/report.html
```

### Add Secrets to GitHub

1. Go to Settings → Secrets and variables → Actions
2. Add:
   - `STRIX_LLM`: `openai/gpt-4`
   - `LLM_API_KEY`: Your API key

## Advanced Configuration

### Custom Instructions File

Create detailed test scope in a file:

```bash
# scope.txt
Focus on the following areas:

1. Authentication System
   - Test login at /api/auth/login
   - Check JWT implementation
   - Verify password reset flow

2. User Management
   - Test /api/users endpoints for IDOR
   - Check authorization on profile updates
   - Verify role-based access control

3. Payment Processing
   - Focus on /api/payments endpoint
   - Test for race conditions
   - Verify amount validation

Use credentials: test@example.com:TestPass123
```

```bash
strix --target https://your-app.com --instruction @scope.txt
```

### Cost Management

Monitor costs with the live stats panel:
```bash
# Use cheaper models for initial scans
export STRIX_LLM="openai/gpt-3.5-turbo"

# Upgrade to GPT-4 for detailed analysis
export STRIX_LLM="openai/gpt-4"
```

### Local LLM Setup (Cost-Free)

```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh

# Pull a model
ollama pull llama2

# Configure Strix
export STRIX_LLM="ollama/llama2"
export LLM_API_BASE="http://localhost:11434"

# Run scan
strix --target ./your-app
```

## Multi-Agent Architecture

Strix uses specialized agents that work together:

1. **Reconnaissance Agents** - Map attack surface, gather information
2. **Scanner Agents** - Identify potential vulnerabilities
3. **Exploit Agents** - Develop proof-of-concepts
4. **Validation Agents** - Confirm findings are real
5. **Reporting Agents** - Generate actionable reports

Each agent has access to:
- HTTP Proxy for request manipulation
- Browser automation (Playwright)
- Terminal environments
- Python runtime
- Security tools

## Report Format

Strix generates comprehensive reports including:

- **Executive Summary** - High-level overview
- **Vulnerability Details** - Each finding with:
  - Severity rating
  - Description
  - Impact assessment
  - Proof-of-concept code
  - Remediation steps
- **Attack Surface Map** - Discovered endpoints and services
- **Recommendations** - Prioritized fix suggestions

## Best Practices

1. **Start Small** - Test on a limited scope first
2. **Monitor Costs** - Watch the live stats panel for token usage
3. **Use Specific Instructions** - More context = better results
4. **Review PoCs** - Verify proof-of-concepts in a safe environment
5. **Iterate** - Use findings to refine instructions for deeper testing
6. **Document Scope** - Use file-based instructions for complex tests
7. **Set Limits** - Use `--max-iterations` to control agent depth

## Troubleshooting

### LLM API Errors

```bash
# Verify environment variables
echo $STRIX_LLM
echo $LLM_API_KEY

# Test API connection
curl -H "Authorization: Bearer $LLM_API_KEY" \
  https://api.openai.com/v1/models
```

### Docker Not Running

```bash
# Check Docker
docker ps

# Ensure Docker is started
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Rate Limit Issues

v0.4.0 has improved rate-limit handling, but you can:
```bash
# Use a different provider
export STRIX_LLM="anthropic/claude-sonnet-4-5"

# Or use a local model
export STRIX_LLM="ollama/llama2"
```

### Sandbox Pull Failed

First run downloads the Strix sandbox Docker image:
```bash
# This happens automatically, but you can pre-pull:
docker pull usestrix/strix-sandbox:latest
```

## Example Output

```
🦉 Strix Security Assessment

Target: https://your-app.com
Run: security-scan-2024-11

╭─ Live Stats ─────────────────────────╮
│ Vulnerabilities: 5                   │
│   Critical: 2                        │
│   High: 1                            │
│   Medium: 2                          │
│   Low: 0                             │
│                                      │
│ Tokens Used: 45.2K                   │
│ Estimated Cost: $0.92                │
│                                      │
│ Active Agents: 3                     │
│ Tools in Use: http_proxy, browser    │
╰──────────────────────────────────────╯

[+] Found: SQL Injection in /api/users
    Severity: CRITICAL
    Impact: Database access
    PoC: Available in findings.json

[+] Found: IDOR in /api/profile
    Severity: HIGH
    Impact: User data exposure
    PoC: Available in findings.json

... (more findings) ...

✅ Scan complete!
   Report: strix_runs/security-scan-2024-11/report.html
```

## Verification

After container creation, verify setup:

```bash
# Check Strix installation
strix --help

# Verify Docker
docker ps

# Check environment
echo $STRIX_LLM
echo $LLM_API_KEY

# Run a test scan (optional)
mkdir test-app && cd test-app
echo "print('hello')" > app.py
strix -n --target ./
```

## Security Warning

⚠️ **IMPORTANT**: Only test applications you own or have explicit written permission to test. Unauthorized security testing is illegal. You are responsible for using Strix ethically and legally.

## Cloud Alternative

Don't want to manage local setup? Use [app.usestrix.com](https://app.usestrix.com/) for:
- No local installation
- No API key management
- Team dashboards
- CI/CD integrations
- Continuous monitoring

## Resources

- 🌐 [Strix Website](https://usestrix.com/)
- 📚 [GitHub Repository](https://github.com/usestrix/strix)
- 💬 [Discord Community](https://discord.gg/YjKFvEZSdZ)
- 📖 [Documentation](https://usestrix.com/docs)
- 🔖 [Release Notes](https://github.com/usestrix/strix/releases)

## Contributing

Found issues or want to contribute? Visit the [GitHub repository](https://github.com/usestrix/strix) and join our community!
