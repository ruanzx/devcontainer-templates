# .NET Aspire Feature

Installs [.NET Aspire](https://learn.microsoft.com/en-us/dotnet/aspire/) project templates for building observable, production-ready distributed applications.

.NET Aspire is an opinionated, cloud-ready stack for building observable, production-ready, distributed applications. It provides tools, templates, and packages for building distributed apps with a code-first app model, unified tooling for local development, and deployment anywhere—cloud, Kubernetes, or your servers.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/aspire": {}
  }
}
```

## Prerequisites

This feature requires the .NET SDK to be installed. Add the .NET feature before this one:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet": {},
    "ghcr.io/ruanzx/devcontainer-features/aspire": {}
  }
}
```

## Options

| Option    | Type   | Default | Description                                    |
| --------- | ------ | ------- | ---------------------------------------------- |
| `version` | string | `9.4.0` | Version of .NET Aspire templates to install   |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet": {},
    "ghcr.io/ruanzx/devcontainer-features/aspire": {}
  }
}
```

### Specific Version

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet": {},
    "ghcr.io/ruanzx/devcontainer-features/aspire": {
      "version": "9.0.0"
    }
  }
}
```

### Latest Version

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet": {},
    "ghcr.io/ruanzx/devcontainer-features/aspire": {
      "version": "latest"
    }
  }
}
```

## What's Installed

This feature installs the .NET Aspire project templates using `dotnet new install Aspire.ProjectTemplates`. After installation, you'll have access to:

- **aspire-starter**: .NET Aspire Starter Application
- **aspire-apphost**: .NET Aspire AppHost project
- **aspire-servicedefaults**: .NET Aspire Service defaults
- **aspire-mstest**: .NET Aspire MSTest project
- **aspire-nunit**: .NET Aspire NUnit project  
- **aspire-xunit**: .NET Aspire xUnit project

## Getting Started

After installation, you can create a new .NET Aspire application:

```bash
# Create a new Aspire starter application
dotnet new aspire-starter -n MyAspireApp

# Navigate to the project
cd MyAspireApp

# Run the application
dotnet run --project MyAspireApp.AppHost
```

## Verification

Run the verification script to check the installation:

```bash
verify-aspire
```

## Requirements

- **.NET 8.0 or later**: .NET Aspire requires .NET 8.0 SDK or later
- **Container Runtime**: Docker Desktop or Podman (for container orchestration)
- **.NET CLI**: Available through the devcontainers/features/dotnet feature

## Common Use Cases

- **Microservices Development**: Build distributed applications with service discovery
- **Cloud-Native Apps**: Develop applications ready for cloud deployment
- **Observability**: Built-in telemetry, logging, and monitoring
- **Local Development**: Unified tooling for developing distributed systems locally
- **Azure Deployment**: Deploy to Azure Container Apps with Azure Developer CLI

## Supported Platforms

- Linux (x86_64, ARM64)
- Requires .NET 8.0+ SDK

## Additional Resources

- [.NET Aspire Documentation](https://learn.microsoft.com/en-us/dotnet/aspire/)
- [.NET Aspire Samples](https://github.com/dotnet/aspire-samples)
- [Get Started with .NET Aspire](https://learn.microsoft.com/en-us/dotnet/aspire/get-started/build-your-first-aspire-app)
- [.NET Aspire Templates](https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/aspire-sdk-templates)

## License

This feature installs .NET Aspire templates which are licensed under the [MIT License](https://github.com/dotnet/aspire/blob/main/LICENSE.TXT).
