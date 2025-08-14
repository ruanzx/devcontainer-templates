# Infrastructure Import Example

This example demonstrates how to use [Terraformer](https://github.com/GoogleCloudPlatform/terraformer) to import existing cloud infrastructure into Terraform configuration files. This is perfect for bringing existing infrastructure under Infrastructure as Code (IaC) management.

## Features Included

- **Terraformer** - Generate Terraform files from existing infrastructure (reverse Terraform)
- **Terraform** - Infrastructure as Code tool
- **AWS CLI** - For AWS credential management and resource access
- **Azure CLI** - For Azure credential management and resource access  
- **GitHub CLI** - For GitHub repository and organization management

## What's Included

This development container includes:
- Ubuntu base image
- Terraformer with support for all providers
- Terraform latest version
- Cloud provider CLIs for authentication
- VS Code extensions for Terraform development

## Use Cases

### 1. Migrating Existing Infrastructure to Terraform

If you have existing cloud resources that weren't created with Terraform, Terraformer can help you:
- Import existing resources into Terraform state
- Generate corresponding `.tf` configuration files
- Enable ongoing management through Terraform

### 2. Documentation and Auditing

Use Terraformer to:
- Document existing infrastructure in HCL format
- Create inventory of cloud resources
- Understand resource relationships and dependencies

### 3. Multi-Cloud Management

Terraformer supports multiple cloud providers, making it useful for:
- Standardizing infrastructure definitions across clouds
- Creating consistent Terraform workflows
- Managing hybrid cloud environments

## Quick Start Guide

### 1. Set Up Provider Credentials

**For AWS:**
```bash
aws configure
# OR
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"
```

**For Google Cloud:**
```bash
gcloud auth login
gcloud config set project your-project-id
```

**For Azure:**
```bash
az login
az account set --subscription "your-subscription-id"
```

**For GitHub:**
```bash
gh auth login
```

### 2. Initialize Terraform Providers

Create a `versions.tf` file with the providers you need:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Provider configurations
provider "aws" {
  region = "us-west-2"
}

provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = "your-github-org"
}
```

Then initialize:
```bash
terraform init
```

### 3. Import Infrastructure

**AWS Examples:**
```bash
# Import all VPCs and subnets in us-west-2
terraformer import aws --resources=vpc,subnet --regions=us-west-2

# Import specific EC2 instances
terraformer import aws --resources=ec2_instance --regions=us-west-2 --filter=instance_id=i-1234567890abcdef0

# Import S3 buckets with specific tags
terraformer import aws --resources=s3 --filter="Name=tags.Environment;Value=production"

# Import all resources (use with caution!)
terraformer import aws --resources="*" --regions=us-west-2
```

**Google Cloud Examples:**
```bash
# Import networks and firewall rules
terraformer import google --resources=networks,firewall --projects=my-project --regions=us-central1

# Import compute instances and disks
terraformer import google --resources=instances,disks --projects=my-project --zones=us-central1-a

# Import all supported resources
terraformer import google --resources="*" --projects=my-project
```

**Azure Examples:**
```bash
# Import resource groups and virtual networks
terraformer import azure --resources=resource_group,virtual_network

# Import virtual machines
terraformer import azure --resources=virtual_machine --resource-group=my-rg
```

**GitHub Examples:**
```bash
# Import repositories for an organization
terraformer import github --resources=repositories --organizations=my-org

# Import repository settings and branch protection
terraformer import github --resources=repositories,branch_protection --organizations=my-org
```

**Kubernetes Examples:**
```bash
# Import deployments and services
terraformer import kubernetes --resources=deployments,services --namespace=default

# Import all resources in a namespace
terraformer import kubernetes --resources="*" --namespace=production
```

### 4. Review and Customize Generated Files

After import, Terraformer creates:
```
generated/
├── aws/
│   ├── vpc/
│   │   ├── vpc.tf
│   │   └── terraform.tfstate
│   └── ec2/
│       ├── instance.tf
│       └── terraform.tfstate
```

Review and customize:
1. **Configuration files** (`.tf`) - Adjust resource names, add variables, etc.
2. **State files** (`.tfstate`) - Import into your Terraform workspace
3. **Resource relationships** - Terraformer attempts to connect resources automatically

### 5. Plan and Apply

```bash
# Copy generated files to your working directory
cp -r generated/aws/* .

# Initialize with new state
terraform init

# Plan to see what changes (should be minimal for imported resources)
terraform plan

# Apply any necessary changes
terraform apply
```

## Advanced Usage

### Filtering Resources

```bash
# Filter by resource ID
terraformer import aws --resources=vpc --filter=vpc=vpc-12345678 --regions=us-west-2

# Filter by tag
terraformer import aws --resources=ec2_instance --filter="Name=tags.Environment;Value=production" --regions=us-west-2

# Multiple filters
terraformer import aws --resources=sg,vpc --filter Type=sg;Name=vpc_id;Value=vpc-12345678 --filter Type=vpc;Name=id;Value=vpc-12345678
```

### Custom Output Structure

```bash
# Compact output (all resources in one file per service)
terraformer import aws --resources=vpc,subnet --compact --regions=us-west-2

# Custom output path
terraformer import aws --resources=vpc --path-output=./imported-infrastructure --regions=us-west-2

# Custom path pattern
terraformer import aws --resources=vpc,subnet --path-pattern="{output}/{provider}/" --regions=us-west-2
```

### Planning Before Import

```bash
# Generate a plan first
terraformer plan aws --resources=vpc,subnet --regions=us-west-2

# Review the plan file
cat generated/aws/terraformer/plan.json

# Execute the plan
terraformer import plan generated/aws/terraformer/plan.json
```

## Best Practices

### 1. Start Small
- Begin with a few resources to understand the process
- Test the import workflow before doing large-scale imports

### 2. Use Filtering
- Don't import everything at once
- Use filters to target specific resources or environments

### 3. Review Generated Code
- Generated Terraform may need refinement
- Add variables, locals, and modules as appropriate
- Standardize naming conventions

### 4. Backup Existing State
- Always backup existing Terraform state before importing
- Test imports in a separate workspace first

### 5. Handle Dependencies
- Import resources in dependency order (VPC before subnets, etc.)
- Review resource references in generated code

## Troubleshooting

### Common Issues

1. **Missing Permissions**
   ```
   Error: AccessDenied: User is not authorized to perform action
   ```
   - Ensure your credentials have read access to all resources you're importing

2. **Provider Plugin Not Found**
   ```
   Error: Could not load plugin
   ```
   - Run `terraform init` to download required providers

3. **Resource Already Exists in State**
   ```
   Error: Resource already managed by Terraform
   ```
   - Use `terraform import` instead for individual resources
   - Or remove from state and re-import

4. **Invalid Resource Configuration**
   ```
   Error: Invalid configuration
   ```
   - Review and fix generated `.tf` files
   - Some resources may need manual adjustment

### Getting Help

- [Terraformer Documentation](https://github.com/GoogleCloudPlatform/terraformer)
- [Terraform Import Documentation](https://www.terraform.io/docs/import/)
- [Provider-specific Import Guides](https://registry.terraform.io/browse/providers)

## Example Workflows

### Migrating AWS Infrastructure

1. **Inventory existing resources**
   ```bash
   aws ec2 describe-vpcs --region us-west-2
   aws ec2 describe-instances --region us-west-2
   ```

2. **Import with Terraformer**
   ```bash
   terraformer import aws --resources=vpc,subnet,ec2_instance --regions=us-west-2
   ```

3. **Organize and refactor**
   ```bash
   # Move files to organized structure
   mkdir -p modules/vpc modules/compute
   mv generated/aws/vpc/* modules/vpc/
   mv generated/aws/ec2/* modules/compute/
   ```

4. **Add variables and outputs**
   ```hcl
   # variables.tf
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "production"
   }
   ```

5. **Test and apply**
   ```bash
   terraform plan
   terraform apply
   ```

This example provides a comprehensive environment for importing and managing existing infrastructure with Terraformer and Terraform!
