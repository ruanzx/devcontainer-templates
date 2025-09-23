# Azure Functions Development Environment

This example demonstrates a complete Azure Functions development environment with Azure Functions Core Tools, supporting multiple programming languages and providing everything needed for serverless development on Azure.

## Features Included

- **Azure Functions Core Tools** - Build, test, and deploy Azure Functions locally
- **Azure CLI** - Azure command-line interface for deployment and management
- **Node.js 18** - For JavaScript/TypeScript Azure Functions
- **Python 3.11** - For Python Azure Functions
- **C#/.NET** - For C# Azure Functions
- **VS Code Extensions** - Complete Azure development toolchain

## What's Included

This development container includes:
- Ubuntu 22.04 base image
- Azure Functions Core Tools (latest version)
- Azure CLI for cloud deployments
- Multiple runtime support (Node.js, Python, .NET)
- VS Code extensions for Azure Functions development
- Pre-configured port forwarding for local testing

## Quick Start

### 1. Configure Azure Authentication

```bash
# Login to Azure
az login

# Set your subscription (optional)
az account set --subscription "your-subscription-id"
```

### 2. Create a New Azure Functions Project

#### JavaScript/TypeScript Functions
```bash
# Create a new Functions project
func init MyFunctionApp --javascript
cd MyFunctionApp

# Create a new HTTP trigger function
func new --name HttpExample --template "HTTP trigger"

# Start the Functions runtime locally
func start
```

#### Python Functions
```bash
# Create a new Functions project
func init MyPythonFunctionApp --python
cd MyPythonFunctionApp

# Create a new HTTP trigger function
func new --name HttpExample --template "HTTP trigger"

# Install dependencies
pip install -r requirements.txt

# Start the Functions runtime locally
func start
```

#### C# Functions
```bash
# Create a new Functions project
func init MyCSharpFunctionApp --dotnet
cd MyCSharpFunctionApp

# Create a new HTTP trigger function
func new --name HttpExample --template "HTTP trigger"

# Start the Functions runtime locally
func start
```

### 3. Test Your Function

Once the runtime is started, you can test your HTTP trigger function:

```bash
# Test the function using curl
curl http://localhost:7071/api/HttpExample?name=World

# Or open in browser
# http://localhost:7071/api/HttpExample?name=World
```

## Available Commands

After the container is ready, you can use these Azure Functions Core Tools commands:

```bash
# Check version
func --version

# Initialize new project
func init [PROJECT_NAME] --[LANGUAGE]

# Create new function
func new --name [FUNCTION_NAME] --template [TEMPLATE_NAME]

# Start local development server
func start

# Deploy to Azure
func azure functionapp publish [APP_NAME]

# Get function URL after deployment
func azure functionapp list-functions [APP_NAME] --show-keys
```

## Supported Languages and Templates

### Languages:
- **JavaScript/TypeScript** (`--javascript`, `--typescript`)
- **Python** (`--python`)
- **C#** (`--dotnet`, `--dotnet-isolated`)
- **Java** (`--java`)
- **PowerShell** (`--powershell`)

### Common Templates:
- **HTTP trigger** - Responds to HTTP requests
- **Timer trigger** - Runs on a schedule
- **Blob trigger** - Responds to blob storage events
- **Queue trigger** - Processes queue messages
- **Service Bus trigger** - Processes Service Bus messages
- **Event Grid trigger** - Responds to Event Grid events
- **Cosmos DB trigger** - Responds to Cosmos DB changes

## Development Workflow

### Local Development
1. Create or open an Azure Functions project
2. Use `func start` to run functions locally
3. Test functions using HTTP requests or trigger events
4. Debug using VS Code's integrated debugger

### Deployment
1. Ensure you're logged into Azure (`az login`)
2. Deploy using `func azure functionapp publish [APP_NAME]`
3. Monitor logs using `func azure functionapp logstream [APP_NAME]`

## Environment Variables

You can configure your functions using local.settings.json:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "CUSTOM_SETTING": "value"
  }
}
```

## Debugging

### VS Code Debugging
- Set breakpoints in your function code
- Press F5 or use "Run and Debug" panel
- The debugger will attach to the local Functions runtime

### Console Logging
```javascript
// JavaScript
context.log('This is a log message');

# Python
import logging
logging.info('This is a log message')

// C#
log.LogInformation("This is a log message");
```

## Port Configuration

The example configures these ports:
- **7071**: Azure Functions runtime (default)
- **8080**: Additional development server
- **3000**: Frontend application (if needed)

## Troubleshooting

### Common Issues

1. **Container fails to start or connect (502 error)**
   - Try the minimal configuration: `cp .devcontainer/devcontainer.minimal.json .devcontainer/devcontainer.json`
   - Clean Docker resources: `docker system prune -f`
   - Restart Docker and VS Code

2. **Port already in use**: Change the port in host.json or stop conflicting processes
3. **Authentication issues**: Run `az login` and ensure proper permissions
4. **Missing dependencies**: Install language-specific packages (npm install, pip install, etc.)
5. **Runtime errors**: Check local.settings.json configuration

### Performance Optimization

If the container is slow to start:
- Use the minimal configuration first
- Add features gradually
- Reduce VS Code extensions
- Ensure adequate system resources

### Useful Commands

```bash
# Check Azure CLI login status
az account show

# List available function app templates
func templates list

# Get help for specific commands
func --help
func new --help
func start --help
```

## Additional Resources

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Functions Core Tools Reference](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
- [Azure Functions Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
- [Azure Functions Triggers and Bindings](https://docs.microsoft.com/azure/azure-functions/functions-triggers-bindings)

## Customization

You can modify the `.devcontainer/devcontainer.json` file to:

- Change the Azure Functions Core Tools version
- Add additional VS Code extensions
- Include other Azure services (Cosmos DB, Service Bus, etc.)
- Configure different runtime versions
- Add custom environment variables or tools