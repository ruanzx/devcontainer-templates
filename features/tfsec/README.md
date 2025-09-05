# tfsec DevContainer Feature

This feature installs [tfsec](https://aquasecurity.github.io/tfsec/), a security scanner for Terraform code to detect potential security issues in your Infrastructure as Code.

> **Note**: tfsec is joining the Trivy family. While tfsec will continue to remain available, engineering attention is being directed at Trivy going forward. Consider using [Trivy](https://github.com/aquasecurity/trivy) for new projects.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/tfsec:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of tfsec to install. Use 'latest' for the most recent release or specify a version like '1.28.1' |

## Examples

### Latest Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/tfsec:latest": {}
    }
}
```

### Specific Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/tfsec:latest": {
            "version": "1.28.1"
        }
    }
}
```

### Combined with Terraform Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/tfsec:latest": {},
        "ghcr.io/ruanzx/features/terraform-docs:latest": {},
        "ghcr.io/ruanzx/features/trivy:latest": {},
        "ghcr.io/devcontainers/features/terraform:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **tfsec CLI**: Security scanner for Terraform code

## Verification

After installation, you can verify tfsec is working:

```bash
# Check version
tfsec --version

# Get help
tfsec --help

# Scan current directory
tfsec .

# Scan specific directory
tfsec /path/to/terraform

# Output as JSON
tfsec --format json .
```

## Use Cases

### Infrastructure Security
- Scan Terraform configurations for security vulnerabilities
- Detect misconfigurations in cloud resources
- Enforce security best practices in Infrastructure as Code

### CI/CD Integration
- Integrate security scanning into development workflows
- Prevent insecure configurations from reaching production
- Generate security reports for compliance

### DevSecOps
- Shift security left in the development process
- Automate security checks for infrastructure code
- Provide immediate feedback to developers

## Common Commands

### Basic Scanning

```bash
# Scan current directory
tfsec .

# Scan specific directory
tfsec /path/to/terraform/

# Scan and show only high severity issues
tfsec --minimum-severity HIGH .

# Scan with custom config file
tfsec --config-file tfsec.yml .
```

### Output Formats

```bash
# JSON output
tfsec --format json .

# JUnit output (for CI/CD)
tfsec --format junit .

# SARIF output
tfsec --format sarif .

# CSV output
tfsec --format csv .

# Save output to file
tfsec --format json --out results.json .
```

### Filtering and Exclusions

```bash
# Exclude specific checks
tfsec --exclude AWS001,AWS002 .

# Include only specific checks
tfsec --include AWS001 .

# Exclude by severity
tfsec --exclude-severity LOW,MEDIUM .

# Scan specific files only
tfsec --include-glob="**/*.tf" .
```

### Advanced Options

```bash
# Show passed checks
tfsec --include-passed .

# Disable colors
tfsec --no-colour .

# Verbose output
tfsec --verbose .

# Force exit code 0 (for CI/CD)
tfsec --soft-fail .
```

## Configuration

### Configuration File

Create a `tfsec.yml` configuration file:

```yaml
# tfsec.yml
severity_overrides:
  AWS001: ERROR
  AWS002: WARNING

exclude:
  - AWS003
  - AWS004

include_glob:
  - "**/*.tf"
  - "**/*.tfvars"

exclude_glob:
  - "**/vendor/**"
  - "**/test/**"

minimum_severity: MEDIUM
```

### Inline Exclusions

Exclude specific checks in Terraform files:

```hcl
resource "aws_s3_bucket" "example" {
  #tfsec:ignore:AWS002
  bucket = "my-bucket"
  acl    = "public-read"
}

resource "aws_instance" "example" {
  #tfsec:ignore:AWS001:Ignore for development environment
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

## Integration Examples

### GitHub Actions

```yaml
name: tfsec
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  tfsec:
    runs-on: ubuntu-latest
    steps:
      - name: Clone repo
        uses: actions/checkout@v4
      
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.3
        with:
          soft_fail: false
          format: sarif
          output: tfsec.sarif
      
      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: tfsec.sarif
```

### GitLab CI/CD

```yaml
stages:
  - security

tfsec:
  stage: security
  image: aquasec/tfsec:latest
  script:
    - tfsec --format junit --out tfsec-report.xml .
  artifacts:
    reports:
      junit: tfsec-report.xml
    paths:
      - tfsec-report.xml
    expire_in: 1 week
  only:
    - merge_requests
    - main
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/aquasecurity/tfsec
    rev: v1.28.14
    hooks:
      - id: tfsec
        args: ['--minimum-severity=HIGH']
```

### Makefile Integration

```makefile
# Makefile
.PHONY: security-scan
security-scan:
	@echo "Running tfsec security scan..."
	@tfsec --format json --out tfsec-results.json .
	@echo "Security scan complete. Results saved to tfsec-results.json"

.PHONY: security-scan-ci
security-scan-ci:
	@echo "Running tfsec for CI/CD..."
	@tfsec --format junit --out tfsec-junit.xml --minimum-severity MEDIUM .
```

## Troubleshooting

### No Issues Found

If tfsec reports no issues but you expect some:

```bash
# Check if files are being scanned
tfsec --verbose .

# Verify file patterns
tfsec --include-glob="**/*.tf" --verbose .

# Check specific directory
tfsec /path/to/terraform --verbose
```

### False Positives

To handle false positives:

```bash
# Exclude specific checks
tfsec --exclude AWS001 .

# Use inline exclusions in Terraform files
#tfsec:ignore:AWS001

# Create configuration file with exclusions
tfsec --config-file tfsec.yml .
```

### Performance Issues

For large codebases:

```bash
# Scan specific directories only
tfsec modules/

# Use include/exclude patterns
tfsec --exclude-glob="**/vendor/**" .

# Set minimum severity to reduce output
tfsec --minimum-severity HIGH .
```

### CI/CD Integration Issues

If tfsec fails in CI/CD:

```bash
# Use soft fail to prevent pipeline failure
tfsec --soft-fail .

# Check exit codes
tfsec . || echo "tfsec found issues but continuing..."

# Generate reports for review
tfsec --format json --out results.json .
```

### Version Compatibility

If you need a specific version:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/tfsec:latest": {
            "version": "1.28.1"
        }
    }
}
```

## Platform Support

- ✅ Linux x86_64 (amd64)
- ✅ Linux ARM64 (aarch64)
- ❌ Windows (not supported)
- ❌ macOS (not supported)

## Migration to Trivy

As tfsec is joining the Trivy family, consider migrating to Trivy for enhanced security scanning:

```bash
# Install Trivy
# (Use the trivy devcontainer feature)

# Scan with Trivy (similar functionality)
trivy config .

# Scan with specific policies
trivy config --policy-bundle-repository https://github.com/aquasecurity/trivy-policies .
```

## Related Features

- **Trivy**: Enhanced security scanner (recommended for new projects)
- **Terraform**: Terraform CLI for infrastructure provisioning
- **Terraform Docs**: Documentation generator for Terraform modules
- **Common Utils**: Required base utilities

## Security Best Practices

- **Regular Scanning**: Run tfsec on every code change
- **CI/CD Integration**: Include security scanning in your pipeline
- **Configuration Management**: Use configuration files for consistent scanning
- **Severity Filtering**: Focus on high and critical issues first
- **Documentation**: Document exclusions and their reasoning

## Additional Resources

- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)
- [tfsec GitHub Repository](https://github.com/aquasecurity/tfsec)
- [Trivy Migration Guide](https://github.com/aquasecurity/tfsec/discussions/1994)
- [Security Checks Reference](https://aquasecurity.github.io/tfsec/latest/checks/)
- [Configuration Reference](https://aquasecurity.github.io/tfsec/latest/config/)
- [Aqua Security Blog](https://blog.aquasec.com/)
- [Terraform Security Best Practices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/security-best-practices)
