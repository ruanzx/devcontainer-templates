# aztfexport (aztfy) Feature

Installs [aztfexport](https://github.com/Azure/aztfexport) (formerly known as aztfy), a tool to bring existing Azure resources under Terraform's management. This tool allows you to import existing Azure infrastructure into Terraform configuration and state files, making it easier to manage your infrastructure as code.

## Description

aztfexport is a command-line tool that helps you migrate existing Azure resources to Terraform. It automatically generates Terraform configuration files and imports existing Azure resources into your Terraform state. This is particularly useful when you have existing Azure infrastructure that you want to start managing with Terraform.

**Key Features:**
- **Resource Discovery**: Automatically discovers Azure resources in your subscription/resource group
- **Configuration Generation**: Generates Terraform configuration files for discovered resources
- **State Import**: Imports existing resources into Terraform state
- **Incremental Migration**: Supports incremental migration of resources
- **Multiple Modes**: Supports resource group, resource, and query-based migration

## Use Cases

- **Infrastructure Migration**: Move existing Azure resources to Terraform management
- **IaC Adoption**: Start using Infrastructure as Code for existing resources
- **Configuration Drift Detection**: Import current state to detect configuration drift
- **Resource Documentation**: Generate Terraform configuration as infrastructure documentation
- **Compliance**: Ensure all resources are managed through code

## Options

### `version` (string)
Specify the version of aztfexport to install.

- **Default**: `"latest"`
- **Example**: `"v0.18.0"`
- **Description**: Install a specific version or use "latest" for the most recent release

## Basic Usage

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/aztfy:latest": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/aztfy:latest": {
      "version": "v0.18.0"
    }
  }
}
```

## Advanced Usage

### Complete Terraform Migration Environment

```json
{
  "name": "Azure Terraform Migration",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {
      "version": "1.9"
    },
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/aztfy:latest": {
      "version": "latest"
    },
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "jq,curl,git"
    }
  }
}
```

### Infrastructure as Code Development

```json
{
  "name": "IaC Development Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {},
    "ghcr.io/ruanzx/features/aztfy:latest": {}
  }
}
```

## Command Line Usage

aztfexport provides several migration modes and commands:

### Basic Commands

```bash
# Check version (available as both aztfexport and aztfy)
aztfexport --version
aztfy --version

# Show help
aztfexport --help

# List available subcommands
aztfexport
```

### Migration Modes

#### 1. Resource Group Migration

```bash
# Migrate an entire resource group
aztfexport resource-group myResourceGroup

# With specific output directory
aztfexport resource-group myResourceGroup --output-dir ./terraform

# Non-interactive mode
aztfexport resource-group myResourceGroup --non-interactive
```

#### 2. Single Resource Migration

```bash
# Migrate a specific resource by resource ID
aztfexport resource /subscriptions/12345678-1234-1234-1234-123456789abc/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorageaccount

# With custom resource name in Terraform
aztfexport resource /path/to/resource --name my_storage_account
```

#### 3. Query-Based Migration

```bash
# Migrate resources based on a query
aztfexport query "resourceGroup eq 'myResourceGroup' and resourceType eq 'Microsoft.Storage/storageAccounts'"

# Complex query example
aztfexport query "location eq 'East US' and tags['Environment'] eq 'Production'"
```

#### 4. Mapping File Migration

```bash
# Use a pre-defined mapping file
aztfexport mapping-file ./resources.json

# Generate a mapping file template
aztfexport mapping-file --generate-mapping-file ./template.json
```

### Authentication and Configuration

```bash
# Login to Azure (required before using aztfexport)
az login

# Set subscription context
az account set --subscription "your-subscription-id"

# Verify current context
az account show
```

### Example Workflow

```bash
# 1. Login to Azure
az login

# 2. Set the subscription
az account set --subscription "your-subscription-id"

# 3. Create a directory for Terraform files
mkdir terraform-migration
cd terraform-migration

# 4. Initialize Terraform
terraform init

# 5. Run aztfexport to migrate a resource group
aztfexport resource-group myResourceGroup

# 6. Review generated files
ls -la

# 7. Plan the Terraform configuration
terraform plan

# 8. Apply to sync state (no changes should be needed)
terraform apply
```

## Configuration Examples

### Azure DevOps Migration Pipeline

```json
{
  "name": "Azure DevOps Migration",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/aztfy:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "zip,unzip,jq"
    }
  },
  "postCreateCommand": [
    "az extension add --name azure-devops"
  ]
}
```

### Multi-Subscription Migration

```json
{
  "name": "Multi-Subscription Migration",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {
      "version": "1.9"
    },
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/aztfy:latest": {},
    "ghcr.io/ruanzx/features/terraform-docs:latest": {}
  }
}
```

## Supported Platforms

- **Linux x86_64**: Full support
- **Linux ARM64**: Full support

## Migration Best Practices

### 1. Pre-Migration Checklist

```bash
# Verify Azure login
az account show

# Check Terraform version compatibility
terraform version

# Ensure you have appropriate permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --all
```

### 2. Resource Organization

```bash
# Create separate directories for different resource groups
mkdir -p terraform/{networking,compute,storage}

# Use consistent naming conventions
aztfexport resource-group myRG-networking --output-dir ./terraform/networking
aztfexport resource-group myRG-compute --output-dir ./terraform/compute
```

### 3. Incremental Migration

```bash
# Start with simple resources like storage accounts
aztfexport query "resourceType eq 'Microsoft.Storage/storageAccounts'"

# Then move to more complex resources
aztfexport query "resourceType eq 'Microsoft.Compute/virtualMachines'"
```

## Common Use Cases

### Migrating a Web Application

```bash
# 1. Migrate the resource group containing the web app
aztfexport resource-group myWebAppRG

# 2. Review and organize the generated files
ls *.tf

# 3. Plan to verify no changes are needed
terraform plan

# 4. Apply to establish baseline
terraform apply
```

### Migrating Storage Resources

```bash
# Target only storage accounts
aztfexport query "resourceType eq 'Microsoft.Storage/storageAccounts' and resourceGroup eq 'myResourceGroup'"
```

### Migrating by Tags

```bash
# Migrate resources with specific tags
aztfexport query "tags['Environment'] eq 'Production' and tags['Team'] eq 'Platform'"
```

## Verification

After installation, verify aztfexport is working:

```bash
# Check installation (both commands should work)
aztfexport --version
aztfy --version

# Verify Azure CLI integration
az account show

# Test basic functionality
aztfexport --help
```

## Troubleshooting

### Installation Issues

**Problem**: Installation fails with download errors
**Solution**: Check internet connectivity and GitHub access:
```bash
curl -I https://github.com/Azure/aztfexport/releases/latest
```

**Problem**: Binary not found after installation
**Solution**: Check PATH and verify installation:
```bash
which aztfexport
which aztfy
echo $PATH
```

### Authentication Issues

**Problem**: "No subscription found" error
**Solution**: Login to Azure and set subscription:
```bash
az login
az account list
az account set --subscription "your-subscription-id"
```

**Problem**: Permission denied errors
**Solution**: Verify you have Reader permissions on resources:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### Migration Issues

**Problem**: Resources not discovered
**Solution**: Check resource group exists and you have access:
```bash
az group show --name myResourceGroup
az resource list --resource-group myResourceGroup
```

**Problem**: Terraform plan shows changes after import
**Solution**: This is normal - review and adjust the generated configuration to match actual resource state.

### Version Compatibility

**Problem**: Terraform version compatibility issues
**Solution**: Check aztfexport documentation for supported Terraform versions and update accordingly.

## Backward Compatibility

This feature installs aztfexport but also creates a symlink as `aztfy` for backward compatibility with the original tool name. Both commands work identically:

```bash
# These are equivalent
aztfexport resource-group myRG
aztfy resource-group myRG
```

## Related Features

- **[Terraform](https://github.com/devcontainers/features/tree/main/src/terraform)**: Required for managing imported resources
- **[Azure CLI](https://github.com/devcontainers/features/tree/main/src/azure-cli)**: Required for Azure authentication
- **[Azure Bicep](../azure-bicep)**: Alternative Azure IaC tool
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Required dependency

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature installs aztfexport which is licensed under the [MIT License](https://github.com/Azure/aztfexport/blob/main/LICENSE).

---

**Note**: aztfexport (formerly aztfy) is developed by Microsoft. This feature provides a convenient way to install it in development containers. For the latest information about aztfexport, visit the [official repository](https://github.com/Azure/aztfexport).
