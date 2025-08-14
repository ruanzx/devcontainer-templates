# Terraformer Feature

This feature installs [Terraformer](https://github.com/GoogleCloudPlatform/terraformer), a CLI tool that generates Terraform files from existing infrastructure (reverse Terraform).

## Description

Terraformer is a powerful tool that can import existing cloud resources and generate corresponding Terraform configuration files and state files. This enables you to bring existing infrastructure under Terraform management without having to recreate it.

## Supported Providers

Terraformer supports a wide range of cloud providers and services:

### Major Cloud Providers
- **AWS** - Amazon Web Services
- **Google Cloud** - Google Cloud Platform
- **Azure** - Microsoft Azure
- **AliCloud** - Alibaba Cloud

### Other Providers
- **Kubernetes** - Kubernetes clusters
- **GitHub** - GitHub repositories and settings
- **DigitalOcean** - DigitalOcean droplets and services
- **OpenStack** - OpenStack infrastructure

## Options

### `version` (string)
Select the version of Terraformer to install.

- **Default**: `latest`
- **Options**: `latest`, `0.8.30`, `0.8.29`, `0.8.28`

### `provider` (string)
Select which provider(s) to include in the Terraformer binary.

- **Default**: `all`
- **Options**: `all`, `aws`, `google`, `azure`, `kubernetes`, `github`, `alicloud`, `digitalocean`, `openstack`

## Usage

### Basic Import Examples

```bash
# Import AWS VPC and subnets
terraformer import aws --resources=vpc,subnet --regions=us-west-2

# Import Google Cloud networks and firewall rules
terraformer import google --resources=networks,firewall --projects=my-project --regions=us-central1

# Import all Kubernetes deployments and services
terraformer import kubernetes --resources=deployments,services

# Import GitHub repositories
terraformer import github --resources=repositories --organizations=my-org
```

### Advanced Usage

```bash
# Import with filtering
terraformer import aws --resources=s3 --filter="Name=tags.Environment;Value=production" --regions=us-west-2

# Import to specific output directory
terraformer import aws --resources=ec2_instance --path-output=./imported --regions=us-east-1

# Import with compact output (all resources in one file)
terraformer import google --resources=compute --compact --projects=my-project

# Generate plan before importing
terraformer plan aws --resources=vpc --regions=us-west-2
terraformer import plan generated/aws/terraformer/plan.json
```

## Prerequisites

Before using Terraformer, you need:

1. **Terraform** installed and configured
2. **Provider credentials** configured (AWS CLI, gcloud, etc.)
3. **Terraform providers** initialized in your working directory

### Setting up Terraform Providers

Create a `versions.tf` file in your working directory:

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
  }
  required_version = ">= 1.0"
}
```

Then run:
```bash
terraform init
```

## Example Workflow

1. **Configure credentials** for your cloud provider
2. **Initialize Terraform** in your working directory
3. **Import existing resources**:
   ```bash
   terraformer import aws --resources=vpc,subnet,ec2_instance --regions=us-west-2
   ```
4. **Review generated files** in the `generated/` directory
5. **Customize and manage** with Terraform

## Output Structure

Terraformer generates:
- **`.tf` files** - Terraform configuration files
- **`.tfstate` files** - Terraform state files
- **Organized by provider and service** - Clean directory structure

Default output structure:
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

## Troubleshooting

### Common Issues

1. **Binary not found for provider combination**
   - Some provider combinations may not be available for all versions
   - Try using `provider: "all"` or a different version

2. **Permission denied errors**
   - Ensure your cloud provider credentials are properly configured
   - Check that you have read permissions for the resources you're trying to import

3. **Provider plugin not found**
   - Make sure you've run `terraform init` in your working directory
   - Verify the correct provider versions in your `versions.tf`

## More Information

- [Terraformer Documentation](https://github.com/GoogleCloudPlatform/terraformer)
- [Supported Providers and Resources](https://github.com/GoogleCloudPlatform/terraformer/tree/master/docs)
- [Terraform Documentation](https://www.terraform.io/docs/)
