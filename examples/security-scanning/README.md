# Security Scanning Example

This example demonstrates comprehensive security scanning capabilities using Trivy for vulnerability detection, Gitleaks for secret scanning, and other security tools. Perfect for DevSecOps workflows and security-first development practices.

## Features Included

- **Trivy** - Comprehensive security scanner for containers, file systems, and repositories
- **Gitleaks** - Secret detection and prevention tool
- **Docker-in-Docker** - For container image security scanning
- **GitHub CLI** - For repository security analysis and reporting

## What's Included

This development container includes:
- Ubuntu base image with security tools
- Trivy with pre-downloaded vulnerability database
- Gitleaks for secret detection
- Docker support for container image scanning
- VS Code extensions for security analysis
- Docker socket mounting for host container scanning

## Security Scanning Workflows

### 1. Container Image Security

```bash
# Scan a Docker image for vulnerabilities
trivy image nginx:latest

# Scan with specific severity levels
trivy image --severity HIGH,CRITICAL alpine:3.19

# Scan and generate JSON report
trivy image --format json --output image-scan.json python:3.11

# Scan local Dockerfile
docker build -t local-app:latest .
trivy image local-app:latest
```

### 2. File System Vulnerability Scanning

```bash
# Scan current project for vulnerabilities
trivy fs .

# Scan specific directories
trivy fs ./src ./lib

# Generate detailed report
trivy fs --format json --output fs-vulnerabilities.json .

# Scan only for specific types
trivy fs --scanners vuln,secret .
```

### 3. Infrastructure as Code Security

```bash
# Scan Terraform files
trivy config terraform/

# Scan Kubernetes manifests
trivy config k8s-manifests/

# Scan Docker Compose files
trivy config docker-compose.yml

# Custom policy scanning
trivy config --policy custom-policies/ .
```

### 4. Secret Detection

```bash
# Scan for hardcoded secrets with Gitleaks
gitleaks detect --source . --verbose

# Scan specific files
gitleaks detect --source ./config --verbose

# Generate report
gitleaks detect --source . --report-format json --report-path secrets-report.json

# Scan git history
gitleaks detect --source . --log-opts "--all"
```

### 5. Repository Security Analysis

```bash
# Scan remote repository
trivy repo https://github.com/owner/repo

# Scan local git repository
trivy repo .

# Combine with Gitleaks for comprehensive analysis
trivy repo . && gitleaks detect --source .
```

## Automated Security Pipeline

### Complete Security Scan Script

```bash
#!/bin/bash
# security-scan.sh - Comprehensive security scanning

set -e

PROJECT_DIR=${1:-.}
REPORT_DIR="security-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔒 Starting comprehensive security scan for: $PROJECT_DIR"
echo "📁 Reports will be saved to: $REPORT_DIR"

# Create reports directory
mkdir -p "$REPORT_DIR"

# 1. File System Vulnerability Scan
echo "📊 Scanning file system for vulnerabilities..."
trivy fs "$PROJECT_DIR" \
  --format json \
  --output "$REPORT_DIR/fs-vulnerabilities-$TIMESTAMP.json"

# 2. Secret Detection
echo "🔐 Scanning for secrets and credentials..."
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect \
    --source "$PROJECT_DIR" \
    --report-format json \
    --report-path "$REPORT_DIR/secrets-$TIMESTAMP.json" || true
fi

# 3. Infrastructure as Code Scan
echo "🏗️ Scanning Infrastructure as Code files..."
trivy config "$PROJECT_DIR" \
  --format json \
  --output "$REPORT_DIR/iac-$TIMESTAMP.json"

# 4. Container Image Scan (if Dockerfile exists)
if [ -f "$PROJECT_DIR/Dockerfile" ]; then
  echo "🐳 Building and scanning container image..."
  IMAGE_NAME="security-scan:$TIMESTAMP"
  docker build -t "$IMAGE_NAME" "$PROJECT_DIR"
  
  trivy image "$IMAGE_NAME" \
    --format json \
    --output "$REPORT_DIR/container-$TIMESTAMP.json"
  
  # Clean up test image
  docker rmi "$IMAGE_NAME" || true
fi

# 5. Generate SBOM (Software Bill of Materials)
echo "📋 Generating Software Bill of Materials..."
trivy fs "$PROJECT_DIR" \
  --format cyclonedx \
  --output "$REPORT_DIR/sbom-$TIMESTAMP.json"

# 6. Summary Report
echo "📈 Generating summary report..."
cat > "$REPORT_DIR/summary-$TIMESTAMP.md" << EOF
# Security Scan Summary

**Date:** $(date)
**Project:** $PROJECT_DIR
**Scan ID:** $TIMESTAMP

## Files Generated

- \`fs-vulnerabilities-$TIMESTAMP.json\` - File system vulnerability scan
- \`secrets-$TIMESTAMP.json\` - Secret detection results
- \`iac-$TIMESTAMP.json\` - Infrastructure as Code security scan
- \`sbom-$TIMESTAMP.json\` - Software Bill of Materials
$([ -f "$REPORT_DIR/container-$TIMESTAMP.json" ] && echo "- \`container-$TIMESTAMP.json\` - Container image vulnerabilities")

## Quick Stats

EOF

# Add vulnerability counts
if [ -f "$REPORT_DIR/fs-vulnerabilities-$TIMESTAMP.json" ]; then
  CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$REPORT_DIR/fs-vulnerabilities-$TIMESTAMP.json" 2>/dev/null || echo "0")
  HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$REPORT_DIR/fs-vulnerabilities-$TIMESTAMP.json" 2>/dev/null || echo "0")
  
  cat >> "$REPORT_DIR/summary-$TIMESTAMP.md" << EOF
### Vulnerabilities
- **Critical:** $CRITICAL
- **High:** $HIGH

EOF
fi

echo "✅ Security scan complete!"
echo "📊 Summary report: $REPORT_DIR/summary-$TIMESTAMP.md"
echo "📁 Full reports available in: $REPORT_DIR/"
```

Make it executable:
```bash
chmod +x security-scan.sh
./security-scan.sh
```

### CI/CD Integration

#### GitHub Actions Workflow

```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly scan

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for secret scanning
          
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
          
      - name: Run Gitleaks secret scanner
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Container scan
        if: hashFiles('Dockerfile') != ''
        run: |
          docker build -t test-image:${{ github.sha }} .
          trivy image --format sarif --output container-results.sarif test-image:${{ github.sha }}
          
      - name: Upload container scan results
        if: hashFiles('Dockerfile') != ''
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'container-results.sarif'
          category: 'container'
```

#### GitLab CI Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - security

variables:
  SECURE_LOG_LEVEL: info

trivy-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy fs --format json --output trivy-report.json .
    - trivy image --format json --output container-report.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA || true
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json
      - container-report.json
    expire_in: 1 week

gitleaks-scan:
  stage: security
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source . --report-format json --report-path secrets-report.json
  artifacts:
    reports:
      secret_detection: secrets-report.json
    expire_in: 1 week
  allow_failure: true
```

## Configuration Files

### Trivy Configuration

```yaml
# trivy.yaml
format: json
output: security-scan-results.json
severity:
  - UNKNOWN
  - LOW
  - MEDIUM
  - HIGH
  - CRITICAL

cache:
  clear: false

db:
  skip-update: false

vulnerability:
  type:
    - os
    - library

secret:
  config: secret-patterns.yaml

misconfig:
  policy: custom-policies/
```

### Gitleaks Configuration

```yaml
# .gitleaks.toml
title = "Custom Gitleaks Configuration"

[[rules]]
id = "AWS Access Key"
description = "AWS Access Key"
regex = '''(?i)(aws_access_key_id|aws_secret_access_key)\s*=\s*["\']?[A-Z0-9]{20}["\']?'''
keywords = ["aws_access_key_id", "aws_secret_access_key"]

[[rules]]
id = "Generic API Key"
description = "Generic API Key"
regex = '''(?i)(api_key|apikey|secret_key)\s*[:=]\s*["\']?[a-zA-Z0-9_\-]{16,}["\']?'''
keywords = ["api_key", "apikey", "secret_key"]

[allowlist]
description = "Allowlist for false positives"
paths = [
  ".gitleaks.toml",
  "tests/",
  "examples/"
]
```

### Ignore Files

```bash
# .trivyignore
# Ignore specific CVEs that are not applicable
CVE-2023-12345
CVE-2022-67890

# Ignore vulnerabilities in test dependencies
**/node_modules/test-*
**/vendor/test/**

# Ignore specific file paths
docs/**
*.md
```

## Security Policy Examples

### Custom Trivy Policies

```rego
# policies/dockerfile-security.rego
package dockerfile

# Deny running as root
deny[msg] {
  input[i].Cmd == "user"
  val := input[i].Value
  val[0] == "root"
  msg := "Container should not run as root user"
}

# Require specific base images
deny[msg] {
  input[i].Cmd == "from"
  val := input[i].Value
  not startswith(val[0], "ubuntu:")
  not startswith(val[0], "alpine:")
  msg := "Base image must be ubuntu or alpine"
}

# Deny latest tags
deny[msg] {
  input[i].Cmd == "from"
  val := input[i].Value
  endswith(val[0], ":latest")
  msg := "Base image should not use 'latest' tag"
}
```

### Kubernetes Security Policies

```rego
# policies/k8s-security.rego
package kubernetes

# Deny privileged containers
deny[msg] {
  input.kind == "Pod"
  input.spec.containers[_].securityContext.privileged == true
  msg := "Privileged containers are not allowed"
}

# Require resource limits
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  not container.resources.limits
  msg := sprintf("Container '%s' must have resource limits", [container.name])
}
```

## Reporting and Metrics

### Security Dashboard

```bash
#!/bin/bash
# generate-dashboard.sh - Create security metrics dashboard

REPORT_DIR="security-reports"
LATEST_SCAN=$(ls -1 "$REPORT_DIR"/fs-vulnerabilities-*.json | tail -1)

if [ -z "$LATEST_SCAN" ]; then
  echo "No scan results found"
  exit 1
fi

# Extract metrics
CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$LATEST_SCAN")
HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$LATEST_SCAN")
MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "MEDIUM")] | length' "$LATEST_SCAN")
LOW=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "LOW")] | length' "$LATEST_SCAN")

# Generate HTML dashboard
cat > security-dashboard.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Security Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .metric { padding: 20px; margin: 10px; border-radius: 5px; }
        .critical { background-color: #ffebee; border-left: 5px solid #f44336; }
        .high { background-color: #fff3e0; border-left: 5px solid #ff9800; }
        .medium { background-color: #f3e5f5; border-left: 5px solid #9c27b0; }
        .low { background-color: #e8f5e8; border-left: 5px solid #4caf50; }
    </style>
</head>
<body>
    <h1>Security Scan Dashboard</h1>
    <p>Last Updated: $(date)</p>
    
    <div class="metric critical">
        <h2>Critical Vulnerabilities</h2>
        <h1>$CRITICAL</h1>
    </div>
    
    <div class="metric high">
        <h2>High Vulnerabilities</h2>
        <h1>$HIGH</h1>
    </div>
    
    <div class="metric medium">
        <h2>Medium Vulnerabilities</h2>
        <h1>$MEDIUM</h1>
    </div>
    
    <div class="metric low">
        <h2>Low Vulnerabilities</h2>
        <h1>$LOW</h1>
    </div>
</body>
</html>
EOF

echo "Security dashboard generated: security-dashboard.html"
```

## Best Practices

### 1. Shift Left Security
- Integrate scanning in development workflow
- Use pre-commit hooks for secret detection
- Scan container images before pushing to registry

### 2. Continuous Monitoring
- Schedule regular security scans
- Monitor for new vulnerabilities in dependencies
- Track security metrics over time

### 3. Remediation Workflow
- Prioritize critical and high severity issues
- Create tickets for vulnerability remediation
- Track remediation progress

### 4. Policy as Code
- Define security policies in version control
- Use custom policies for organization-specific requirements
- Regularly review and update policies

This comprehensive security scanning environment provides everything needed for robust DevSecOps practices!
