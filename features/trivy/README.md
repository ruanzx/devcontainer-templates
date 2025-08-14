# Trivy Feature

This feature installs [Trivy](https://trivy.dev/), a comprehensive security scanner for vulnerabilities in containers, file systems, git repositories, and Infrastructure as Code (IaC) files.

## Description

Trivy is a simple and comprehensive vulnerability scanner for containers and other artifacts. It detects vulnerabilities of OS packages and language-specific packages. Trivy is easy to use and can be integrated into CI/CD pipelines for automated security scanning.

## Key Features

- **Container Image Scanning**: Scan Docker images for vulnerabilities
- **File System Scanning**: Scan local file systems and directories
- **Git Repository Scanning**: Scan remote git repositories
- **Infrastructure as Code (IaC) Scanning**: Scan Terraform, CloudFormation, Kubernetes manifests
- **SBOM Generation**: Generate Software Bill of Materials
- **Compliance Scanning**: Check against security standards and policies
- **Secret Detection**: Find hardcoded secrets in code
- **License Detection**: Identify software licenses
- **Misconfiguration Detection**: Find security misconfigurations

## Supported Targets

### Container Images
- Docker images (local and remote registries)
- OCI images
- Container archives (tar files)

### File Systems
- Local directories
- Application dependencies
- OS packages

### Repositories
- Git repositories (GitHub, GitLab, etc.)
- Local git repositories

### Infrastructure as Code
- Terraform files
- CloudFormation templates
- Kubernetes YAML files
- Docker Compose files
- Helm charts

## Options

### `version` (string)
Select the version of Trivy to install.

- **Default**: `latest`
- **Options**: `latest`, `0.58.1`, `0.58.0`, `0.57.1`, `0.57.0`

### `installDb` (boolean)
Download vulnerability database during installation.

- **Default**: `true`
- **Description**: Pre-downloads the vulnerability database for faster scanning

## Basic Usage

### Container Image Scanning

```bash
# Scan a container image
trivy image alpine:3.19

# Scan with specific severity levels
trivy image --severity HIGH,CRITICAL nginx:latest

# Output in JSON format
trivy image --format json alpine:3.19

# Save results to file
trivy image --output result.json --format json alpine:3.19
```

### File System Scanning

```bash
# Scan current directory
trivy fs .

# Scan specific directory
trivy fs /path/to/project

# Scan only specific file types
trivy fs --scanners vuln,secret .

# Ignore specific vulnerabilities
trivy fs --ignore-unfixed .
```

### Repository Scanning

```bash
# Scan remote repository
trivy repo https://github.com/owner/repo

# Scan local git repository
trivy repo .

# Scan specific branch or commit
trivy repo --branch develop https://github.com/owner/repo
```

### Infrastructure as Code Scanning

```bash
# Scan IaC files in current directory
trivy config .

# Scan specific Terraform files
trivy config terraform/

# Scan Kubernetes manifests
trivy config k8s-manifests/

# Custom policy scanning
trivy config --policy custom-policies/ .
```

## Advanced Usage

### Vulnerability Filtering

```bash
# Show only specific severities
trivy image --severity HIGH,CRITICAL alpine:3.19

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed alpine:3.19

# Use ignore file
trivy image --ignorefile .trivyignore alpine:3.19

# Filter by vulnerability ID
trivy image --ignore-policy ignore.rego alpine:3.19
```

### Output Formats

```bash
# JSON output
trivy image --format json alpine:3.19

# Table output (default)
trivy image --format table alpine:3.19

# SARIF output (for GitHub Code Scanning)
trivy image --format sarif alpine:3.19

# CycloneDX SBOM
trivy image --format cyclonedx alpine:3.19

# SPDX SBOM
trivy image --format spdx-json alpine:3.19
```

### Cache Management

```bash
# Clear cache
trivy clean --all

# Update vulnerability database
trivy image --download-db-only

# Use custom cache directory
trivy image --cache-dir /custom/cache alpine:3.19
```

## Configuration

### .trivyignore File

Create a `.trivyignore` file to ignore specific vulnerabilities:

```
# Ignore specific CVEs
CVE-2022-12345
CVE-2023-67890

# Ignore by package name
golang.org/x/crypto

# Ignore by file path
**/test/**
**/node_modules/**
```

### Configuration File

Create a `trivy.yaml` configuration file:

```yaml
# trivy.yaml
format: json
output: trivy-results.json
severity:
  - HIGH
  - CRITICAL
ignore-unfixed: true
cache:
  clear: false
db:
  skip-update: false
vulnerability:
  type:
    - os
    - library
```

Use with: `trivy --config trivy.yaml image alpine:3.19`

## CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan

on: [push, pull_request]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```

### GitLab CI

```yaml
# .gitlab-ci.yml
trivy:
  stage: test
  image: aquasec/trivy:latest
  script:
    - trivy fs --format json --output trivy-report.json .
  artifacts:
    reports:
      container_scanning: trivy-report.json
```

### Docker Integration

```dockerfile
# Multi-stage build with Trivy scanning
FROM alpine:3.19 AS base
# ... your application setup ...

FROM aquasec/trivy:latest AS trivy
COPY --from=base / /target
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL /target

FROM base AS final
# ... final image ...
```

## Scanning Examples

### Complete Project Scan

```bash
#!/bin/bash
# comprehensive-scan.sh

echo "🔍 Starting comprehensive security scan..."

# Scan file system for vulnerabilities
echo "📁 Scanning file system..."
trivy fs --format json --output fs-scan.json .

# Scan for secrets
echo "🔐 Scanning for secrets..."
trivy fs --scanners secret --format json --output secrets-scan.json .

# Scan IaC configurations
echo "🏗️ Scanning Infrastructure as Code..."
trivy config --format json --output iac-scan.json .

# Scan container images (if Dockerfile exists)
if [ -f "Dockerfile" ]; then
    echo "🐳 Building and scanning Docker image..."
    docker build -t local-app:latest .
    trivy image --format json --output image-scan.json local-app:latest
fi

# Generate SBOM
echo "📋 Generating Software Bill of Materials..."
trivy fs --format cyclonedx --output sbom.json .

echo "✅ Security scan complete!"
echo "📊 Results:"
echo "  - File system: fs-scan.json"
echo "  - Secrets: secrets-scan.json" 
echo "  - IaC: iac-scan.json"
echo "  - SBOM: sbom.json"
[ -f "image-scan.json" ] && echo "  - Container: image-scan.json"
```

### Kubernetes Security Scanning

```bash
# Scan Kubernetes manifests
trivy config k8s/

# Scan running cluster (requires kubectl)
kubectl get pods --all-namespaces -o json | \
  trivy k8s --report summary -

# Scan specific namespace
trivy k8s namespace/production

# Scan with custom policies
trivy config --policy security-policies/ k8s/
```

### Policy as Code

Create custom security policies with Rego:

```rego
# policies/dockerfile.rego
package dockerfile

deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    contains(val[_], "curl")
    not contains(val[_], "--fail")
    msg := "curl should use --fail option"
}

deny[msg] {
    input[i].Cmd == "from"
    val := input[i].Value
    endswith(val[0], ":latest")
    msg := "base image should not use 'latest' tag"
}
```

## Report Generation

### HTML Reports

```bash
# Generate HTML report
trivy image --format template --template "@contrib/html.tpl" \
  --output report.html alpine:3.19

# Custom HTML template
trivy image --format template --template "@custom-template.tpl" \
  --output custom-report.html alpine:3.19
```

### Summary Reports

```bash
# Summary table
trivy image --format table --severity HIGH,CRITICAL alpine:3.19

# Count summary
trivy image --format json alpine:3.19 | \
  jq '.Results[].Vulnerabilities | length'

# Severity breakdown
trivy image --format json alpine:3.19 | \
  jq '.Results[].Vulnerabilities | group_by(.Severity) | 
      map({severity: .[0].Severity, count: length})'
```

## Database Management

```bash
# Update vulnerability database
trivy image --download-db-only

# Check database version
trivy version

# Use offline database
trivy image --offline-scan alpine:3.19

# Custom database URL
trivy image --db-repository custom-db-url alpine:3.19
```

## Performance Tuning

```bash
# Skip file scanning for faster results
trivy image --scanners vuln alpine:3.19

# Parallel scanning
trivy fs --parallel 4 .

# Skip certain directories
trivy fs --skip-dirs node_modules,vendor .

# Use cache efficiently
trivy image --cache-ttl 24h alpine:3.19
```

## Compliance and Standards

### CIS Benchmarks

```bash
# Docker CIS benchmark
trivy config --compliance docker-cis .

# Kubernetes CIS benchmark  
trivy k8s --compliance k8s-cis cluster
```

### NIST Framework

```bash
# NIST compliance checking
trivy config --compliance nist .
```

## Integration with Security Tools

### SIEM Integration

```bash
# Generate SIEM-friendly output
trivy fs --format json . | \
  jq '.Results[] | select(.Vulnerabilities) | 
      .Vulnerabilities[] | 
      {timestamp: now, severity: .Severity, cve: .VulnerabilityID}'
```

### Vulnerability Management

```bash
# Export for vulnerability tracking
trivy image --format cyclonedx --output sbom.xml alpine:3.19

# Create vulnerability tickets
trivy fs --format json . | \
  jq '.Results[].Vulnerabilities[] | 
      select(.Severity == "CRITICAL") | 
      {title: .Title, cve: .VulnerabilityID, severity: .Severity}'
```

## Troubleshooting

### Common Issues

1. **Database download failures**
   ```bash
   # Manual database update
   trivy image --download-db-only --db-repository ghcr.io/aquasecurity/trivy-db
   ```

2. **Large scan times**
   ```bash
   # Skip unnecessary scanners
   trivy fs --scanners vuln .
   
   # Use specific file patterns
   trivy fs --file-patterns "*.py,*.js" .
   ```

3. **False positives**
   ```bash
   # Use ignore file
   echo "CVE-2023-12345" >> .trivyignore
   trivy fs --ignorefile .trivyignore .
   ```

4. **Network issues**
   ```bash
   # Use offline mode
   trivy image --offline-scan alpine:3.19
   
   # Custom timeout
   trivy image --timeout 5m alpine:3.19
   ```

## More Information

- [Trivy Documentation](https://trivy.dev/latest/)
- [Trivy GitHub Repository](https://github.com/aquasecurity/trivy)
- [Vulnerability Database](https://github.com/aquasecurity/trivy-db)
- [Custom Policies](https://trivy.dev/latest/docs/scanner/misconfiguration/custom/)
- [Integration Examples](https://github.com/aquasecurity/trivy-action)
