# terraform-docs

Generate documentation from Terraform modules in various output formats.

## Example Usage

```json
"features": {
    "ghcr.io/ruanzx/features/terraform-docs:latest": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of terraform-docs to install. Use 'latest' for the most recent version or specify a version like 'v0.19.0' | string | latest |

## Description

terraform-docs is a utility to generate documentation from Terraform modules in various output formats. It reads Terraform module files and generates formatted documentation that can be included in README files, wikis, or other documentation systems.

## Usage Examples

### Default Installation (Latest Version)
```json
"ghcr.io/ruanzx/features/terraform-docs:latest": {}
```

### Specific Version
```json
"ghcr.io/ruanzx/features/terraform-docs:latest": {
    "version": "v0.19.0"
}
```

### Version Without 'v' Prefix
```json
"ghcr.io/ruanzx/features/terraform-docs:latest": {
    "version": "0.19.0"
}
```

## What is terraform-docs?

terraform-docs is a utility to generate documentation from Terraform modules in various output formats including:

- **Markdown**: Generate markdown tables and text
- **JSON**: Machine-readable JSON format
- **YAML**: YAML format output
- **XML**: XML format output
- **ASCIIDOC**: AsciiDoc format
- **TOML**: TOML format

### Key Features

- **Multiple Output Formats**: Supports markdown, JSON, YAML, XML, AsciiDoc, and TOML
- **Flexible Templates**: Customizable output templates
- **Automated Documentation**: Generate docs automatically from Terraform code
- **CI/CD Integration**: Perfect for automated documentation workflows
- **Module Analysis**: Analyzes inputs, outputs, providers, and resources

## Getting Started

After installation, you can generate documentation for your Terraform modules:

### 1. Basic Usage

Navigate to your Terraform module directory and run:

```bash
# Generate markdown table format (most common)
terraform-docs markdown table .

# Generate markdown document format
terraform-docs markdown document .

# Generate JSON format
terraform-docs json .
```

### 2. Output to File

```bash
# Write to README.md
terraform-docs markdown table . > README.md

# Write to docs directory
terraform-docs markdown document . > docs/terraform-module.md
```

### 3. Using Configuration File

Create a `.terraform-docs.yml` configuration file:

```yaml
formatter: "markdown table"
version: ""
header-from: main.tf
footer-from: ""
recursive:
  enabled: false
  path: modules
sections:
  hide: []
  show: []
content: |-
  # Terraform Module Documentation
  
  {{ .Header }}
  
  ## Requirements
  
  {{ .Requirements }}
  
  ## Providers
  
  {{ .Providers }}
  
  ## Modules
  
  {{ .Modules }}
  
  ## Resources
  
  {{ .Resources }}
  
  ## Inputs
  
  {{ .Inputs }}
  
  ## Outputs
  
  {{ .Outputs }}
output:
  file: "README.md"
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
sort:
  enabled: true
  by: name
settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

Then run:
```bash
terraform-docs .
```

## Output Formats

### Markdown Table
```bash
terraform-docs markdown table .
```

Generates a table format suitable for README files:

```markdown
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
```

### Markdown Document
```bash
terraform-docs markdown document .
```

Generates a more detailed document format with descriptions.

### JSON Format
```bash
terraform-docs json .
```

Generates machine-readable JSON:

```json
{
  "header": "",
  "footer": "",
  "inputs": [
    {
      "name": "instance_type",
      "type": "string",
      "description": "EC2 instance type",
      "default": "t3.micro",
      "required": false
    }
  ],
  "outputs": [
    {
      "name": "instance_id",
      "description": "ID of the EC2 instance"
    }
  ]
}
```

## Advanced Usage

### Custom Templates

Create custom templates for specific documentation needs:

```bash
# Using custom template
terraform-docs --template-file custom-template.tmpl markdown .
```

### Recursive Documentation

Generate docs for multiple modules:

```bash
# Generate docs for all modules in subdirectories
terraform-docs --recursive .
```

### CI/CD Integration

#### GitHub Actions Example

```yaml
name: Generate terraform docs
on:
  - pull_request

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.ref }}

    - name: Render terraform docs and push changes back to PR
      uses: terraform-docs/gh-actions@main
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```

#### Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.19.0"
    hooks:
      - id: terraform-docs-go
        args: ['markdown', 'table', '--output-file', 'README.md', '.']
```

### Integration with Terraform Workflows

#### Makefile Integration

```makefile
.PHONY: docs
docs:
	terraform-docs markdown table . > README.md

.PHONY: docs-check
docs-check:
	terraform-docs markdown table . | diff README.md -
```

#### VS Code Tasks

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Terraform Docs",
      "type": "shell",
      "command": "terraform-docs",
      "args": ["markdown", "table", ".", ">", "README.md"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

## Common Use Cases

### 1. Module README Generation
```bash
# Generate comprehensive module documentation
terraform-docs markdown document . > README.md
```

### 2. API Documentation
```bash
# Generate JSON for API consumption
terraform-docs json . > module-api.json
```

### 3. Wiki Documentation
```bash
# Generate for confluence or other wikis
terraform-docs asciidoc table . > module-docs.adoc
```

### 4. Automated Documentation Updates
```bash
# Use in CI/CD to keep docs in sync
terraform-docs --output-file README.md markdown table .
```

## Configuration Options

terraform-docs supports various configuration options:

### Command Line Options
- `--output-file`: Write output to file
- `--output-mode`: How to write to file (replace, inject)
- `--sort-by`: Sort inputs/outputs by name or type
- `--anchor`: Add anchors to headings
- `--hide`: Hide specific sections
- `--show`: Show only specific sections

### Configuration File
Create `.terraform-docs.yml` for persistent configuration:

```yaml
formatter: "markdown table"
sections:
  hide:
    - requirements
  show:
    - inputs
    - outputs
sort:
  enabled: true
  by: name
settings:
  anchor: true
  default: true
  required: true
```

## Best Practices

### 1. Consistent Documentation
- Use configuration files for consistent formatting
- Include terraform-docs in your CI/CD pipeline
- Use pre-commit hooks to ensure docs are always up-to-date

### 2. Module Structure
```
terraform-module/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
└── .terraform-docs.yml
```

### 3. Variable Documentation
```hcl
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium"
    ], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}
```

### 4. Output Documentation
```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.example.arn
  sensitive   = false
}
```

## Verification

After installation, verify terraform-docs is working:

```bash
# Check version
terraform-docs version

# Test with a simple module
mkdir test-module
cd test-module
cat > main.tf << EOF
variable "example" {
  description = "An example variable"
  type        = string
  default     = "hello"
}

output "example_output" {
  description = "An example output"
  value       = var.example
}
EOF

# Generate documentation
terraform-docs markdown table .
```

## Documentation

- [terraform-docs Website](https://terraform-docs.io/)
- [GitHub Repository](https://github.com/terraform-docs/terraform-docs)
- [Configuration Reference](https://terraform-docs.io/user-guide/configuration/)
- [Output Formats](https://terraform-docs.io/user-guide/output-formats/)

## Troubleshooting

If terraform-docs fails to install:

1. Check that the specified version exists on [GitHub releases](https://github.com/terraform-docs/terraform-docs/releases)
2. Verify your system architecture is supported (amd64, arm64)
3. Ensure internet connectivity for downloading the binary
4. Check that you have sufficient permissions to install binaries

For the latest version information, visit the [terraform-docs releases page](https://github.com/terraform-docs/terraform-docs/releases).
