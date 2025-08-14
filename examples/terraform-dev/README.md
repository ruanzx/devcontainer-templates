# Terraform Development Example

This example demonstrates how to use the `terraform-docs` feature in a Terraform development environment.

## Features Included

- **terraform-docs**: Generates documentation from Terraform modules in various output formats (markdown, JSON, YAML, etc.)

## What's Included

This development container includes:
- Ubuntu base image
- terraform-docs tool for generating module documentation
- VS Code extensions for Terraform development

## Usage

1. **Generate Documentation**: Create documentation for your Terraform modules:
   ```bash
   # Generate markdown documentation
   terraform-docs markdown table ./
   
   # Generate JSON output
   terraform-docs json ./
   
   # Generate documentation for a specific module
   terraform-docs markdown table ./modules/vpc
   ```

2. **Configuration**: terraform-docs can be configured with a `.terraform-docs.yml` file:
   ```yaml
   formatter: "markdown table"
   header-from: main.tf
   footer-from: ""
   recursive:
     enabled: false
   sections:
     hide: []
     show: []
   content: |-
     {{ .Header }}
     {{ .Requirements }}
     {{ .Providers }}
     {{ .Modules }}
     {{ .Resources }}
     {{ .Inputs }}
     {{ .Outputs }}
   output:
     file: "README.md"
     mode: inject
     template: |-
       <!-- BEGIN_TF_DOCS -->
       {{ .Content }}
       <!-- END_TF_DOCS -->
   ```

## Example Terraform Module

Create a simple Terraform module to test documentation generation:

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name        = "example-${var.environment}"
    Environment = var.environment
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}
```

Then generate documentation:
```bash
terraform-docs markdown table . > README.md
```

## Development Workflow

1. Write your Terraform configurations
2. Use `terraform-docs` to generate documentation
3. Commit both code and documentation to version control
4. Set up CI/CD to automatically update documentation when modules change

## Learn More

- [terraform-docs Documentation](https://terraform-docs.io/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [VS Code Terraform Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
