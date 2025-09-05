# Azure Bicep CLI Feature

Installs [Azure Bicep CLI](https://github.com/Azure/bicep), a declarative language (DSL) for deploying Azure resources. Bicep provides a transparent abstraction over ARM and ARM templates, making it easier to author and maintain Azure infrastructure as code.

## Description

Azure Bicep is a domain-specific language (DSL) that provides a cleaner syntax for deploying Azure resources compared to JSON ARM templates. Bicep files are transpiled to ARM templates, ensuring full compatibility with the Azure Resource Manager while providing a more readable and maintainable authoring experience.

## Use Cases

- **Infrastructure as Code**: Define Azure resources declaratively
- **ARM Template Alternative**: Cleaner syntax than JSON ARM templates
- **Azure DevOps Integration**: Deploy infrastructure in CI/CD pipelines
- **Resource Management**: Create, update, and manage Azure resources
- **Multi-environment Deployments**: Parameterize templates for different environments

## Options

### `version` (string)
Specify the version of Azure Bicep CLI to install.

- **Default**: `"latest"`
- **Example**: `"v0.30.3"`
- **Description**: Install a specific version or use "latest" for the most recent release

## Basic Usage

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/azure-bicep:latest": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/azure-bicep:latest": {
      "version": "v0.30.3"
    }
  }
}
```

## Advanced Usage

### Complete Azure Development Environment

```json
{
  "name": "Azure Infrastructure Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {
      "version": "latest"
    },
    "ghcr.io/ruanzx/features/terraform-docs:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "jq,curl,git"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-bicep",
        "ms-vscode.azure-account",
        "ms-azuretools.vscode-azureresourcegroups"
      ]
    }
  }
}
```

### Infrastructure as Code Workflow

```json
{
  "name": "IaC Development Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {}
  }
}
```

## Command Line Usage

After installation, Azure Bicep CLI provides comprehensive infrastructure management:

### Basic Commands

```bash
# Check Bicep version
bicep --version

# Build a Bicep file to ARM template
bicep build main.bicep

# Decompile ARM template to Bicep
bicep decompile template.json

# Generate parameters file
bicep generate-params main.bicep

# Format Bicep files
bicep format main.bicep

# Lint Bicep files
bicep lint main.bicep
```

### Deployment Workflow

```bash
# Build Bicep to ARM template
bicep build main.bicep --outfile main.json

# Deploy using Azure CLI
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.json \
  --parameters @parameters.json

# Or deploy Bicep directly (Azure CLI 2.20+)
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
```

### Example Bicep File

```bicep
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the storage account')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountSku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
```

## Configuration Examples

### Azure DevOps Environment

```json
{
  "name": "Azure DevOps Infrastructure",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "zip,unzip,jq"
    }
  },
  "postCreateCommand": "az extension add --name azure-devops"
}
```

### Multi-Cloud Infrastructure

```json
{
  "name": "Multi-Cloud Infrastructure",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/ruanzx/features/azure-bicep:latest": {},
    "ghcr.io/ruanzx/features/kubectl:latest": {}
  }
}
```

## Supported Platforms

- **Linux x86_64**: Full support
- **Linux ARM64**: Full support

## VS Code Integration

This feature automatically installs the Azure Bicep VS Code extension, providing:

- **Syntax Highlighting**: Bicep language support
- **IntelliSense**: Auto-completion for Azure resources
- **Validation**: Real-time error checking
- **Snippets**: Common Bicep patterns
- **Formatting**: Automatic code formatting

## Verification

After installation, verify Azure Bicep CLI is working:

```bash
# Check installation
bicep --version

# Validate Bicep syntax
echo 'param location string = resourceGroup().location' > test.bicep
bicep build test.bicep

# Check available commands
bicep --help
```

## Troubleshooting

### Installation Issues

**Problem**: Installation fails with download errors
**Solution**: Check internet connectivity and GitHub access:
```bash
curl -I https://github.com/Azure/bicep/releases/latest
```

**Problem**: Binary not found after installation
**Solution**: Check PATH and verify installation:
```bash
which bicep
echo $PATH
```

### Version Issues

**Problem**: Specific version not found
**Solution**: Check available releases at: https://github.com/Azure/bicep/releases

**Problem**: Architecture mismatch
**Solution**: This feature automatically detects your architecture (x64/ARM64)

### Permission Issues

**Problem**: Permission denied when running bicep
**Solution**: The installation makes the binary executable automatically, but you can fix manually:
```bash
sudo chmod +x /usr/local/bin/bicep
```

## Related Features

- **[Azure CLI](https://github.com/devcontainers/features/tree/main/src/azure-cli)**: Deploy Bicep templates
- **[Terraform](https://github.com/devcontainers/features/tree/main/src/terraform)**: Alternative IaC tool
- **[kubectl](../kubectl)**: Kubernetes resource management
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Required dependency

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature installs Azure Bicep CLI which is licensed under the [MIT License](https://github.com/Azure/bicep/blob/main/LICENSE).

---

**Note**: Azure Bicep is developed by Microsoft. This feature provides a convenient way to install it in development containers. For the latest information about Azure Bicep, visit the [official repository](https://github.com/Azure/bicep).
