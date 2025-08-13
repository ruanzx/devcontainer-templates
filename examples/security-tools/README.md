# Security Development Environment

This example focuses on security tools for development and auditing.

## Features Included

- **Gitleaks** - Detect secrets in git repositories
- **yq** - Secure YAML/JSON processing
- **Microsoft Edit** - Secure text editing
- **Git** - Version control with security focus

## Usage

1. Open this folder in VS Code
2. Choose "Reopen in Container"
3. Gitleaks will automatically scan the repository

## Security Commands

```bash
# Scan for secrets in current repository
gitleaks detect --verbose

# Scan specific files
gitleaks detect --source myfile.py

# Create gitleaks config
gitleaks generate config

# Process sensitive YAML safely
yq '.password = "REDACTED"' config.yaml
```
