# .NET Development Environment

This example demonstrates a complete .NET development environment with commonly used .NET global tools.

## Features Included

- **.NET SDK** - Latest .NET SDK for development
- **.NET Global Tools** - Essential development tools:
  - `dotnet-ef` - Entity Framework Core CLI tools
  - `dotnet-format` - Code formatter
  - `dotnet-outdated-tool` - Check for outdated packages
  - `dotnet-sonarscanner` - SonarQube code analysis

## VS Code Extensions

- C# extension for IntelliSense and debugging
- .NET Runtime installer
- Tailwind CSS support
- .NET Test Explorer

## Getting Started

1. Open this folder in VS Code with the Dev Containers extension
2. Choose "Reopen in Container" when prompted
3. Wait for the container to build and the tools to install
4. Verify installation with: `dotnet tool list --global`

## Available Tools

After the container is ready, you can use:

```bash
# Entity Framework commands
dotnet ef --help

# Format your code
dotnet format

# Check for outdated packages
dotnet outdated

# Run SonarQube analysis
dotnet sonarscanner --help
```

## Customization

You can modify the `.devcontainer/devcontainer.json` file to:

- Add more .NET tools by updating the `tools` parameter
- Include specific versions: `"tools": "dotnet-ef@7.0.0,dotnet-format@5.1.250250"`
- Add VS Code extensions
- Configure post-creation commands

Example with more tools:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:latest": {},
    "ghcr.io/ruanzx/features/dotnet-tools:latest": {
      "tools": "dotnet-ef@latest,dotnet-format@latest,dotnet-outdated-tool@latest,dotnet-reportgenerator-globaltool@latest,dotnet-stryker@latest"
    }
  }
}
```
