# Azure Functions Core Tools Feature

Installs [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools), which provide a local development experience for creating, developing, testing, running, and debugging Azure Functions.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/azure-functions-core-tools": {}
  }
}
```

## Options

| Option          | Type   | Default | Description                                                                 |
| --------------- | ------ | ------- | --------------------------------------------------------------------------- |
| `version`       | string | `latest`| Version of Azure Functions Core Tools to install (e.g., '4.2.2' or 'latest') |
| `installMethod` | string | `apt`   | Installation method: 'apt' for package repository or 'binary' for direct download |

## Examples

### Install Latest Version (APT Repository)

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/azure-functions-core-tools": {}
  }
}
```

### Install Specific Version via Binary Download

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/azure-functions-core-tools": {
      "version": "4.2.2",
      "installMethod": "binary"
    }
  }
}
```

### Install Latest via Binary Download

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/azure-functions-core-tools": {
      "installMethod": "binary"
    }
  }
}
```

## Installation Methods

### APT Repository (Default)
- Installs from the official Microsoft APT repository
- Automatically handles dependencies
- Supports Ubuntu and Debian distributions
- Always installs the latest available version
- Recommended for most use cases

### Binary Download
- Downloads the binary directly from GitHub releases
- Supports specific version selection
- Works when APT repository is not available
- Requires manual dependency management

## Supported Platforms

- Linux (x86_64)
- Limited ARM64 support available in recent versions

## VS Code Extensions

This feature automatically installs the [Azure Functions VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions) for enhanced development experience.

## Getting Started

After installation, you can create a new Azure Functions project:

```bash
# Create a new function app project
func init MyFunctionApp --worker-runtime node

# Navigate to the project directory
cd MyFunctionApp

# Create a new function
func new --template "HTTP trigger" --name MyHttpTrigger

# Run the function app locally
func start
```

## Available Commands

- `func init` - Initialize a new function app project
- `func new` - Create a new function from a template
- `func start` - Start the local Functions runtime
- `func azure functionapp publish` - Deploy to Azure
- `func --help` - Show help information

## Version Information

The Azure Functions Core Tools version corresponds to the Azure Functions runtime version:
- Version 4.x supports Azure Functions runtime 4.x (recommended)
- Version 3.x supports Azure Functions runtime 3.x (end of support)
- Version 2.x supports Azure Functions runtime 2.x (end of support)

## Troubleshooting

### APT Repository Issues
If you encounter issues with the APT installation, try the binary method:

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/azure-functions-core-tools": {
      "installMethod": "binary"
    }
  }
}
```

### Permission Issues
Make sure the container has appropriate permissions to install packages and write to `/usr/local/bin`.

### ARM64 Support
ARM64 support is available in recent versions but may have limitations. Check the [official releases](https://github.com/Azure/azure-functions-core-tools/releases) for ARM64 availability.

## License

This feature installs Azure Functions Core Tools which is licensed under the [MIT License](https://github.com/Azure/azure-functions-core-tools/blob/main/LICENSE).

## Related Features

- `azure-bicep` - Azure Bicep CLI for infrastructure deployment
- `dotnet-tools` - .NET development tools
- `nodejs` - Node.js runtime for JavaScript/TypeScript functions