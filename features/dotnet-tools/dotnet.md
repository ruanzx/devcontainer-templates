Based on the .NET ecosystem, here are the main categories of tools that .NET supports:

## Global Tools (installed via `dotnet tool install -g`)

### Entity Framework
```bash
dotnet tool install -g dotnet-ef
```

### Code Analysis & Quality
```bash
dotnet tool install -g dotnet-sonarscanner
dotnet tool install -g dotnet-reportgenerator-globaltool
dotnet tool install -g dotnet-coverage
dotnet tool install -g security-scan
```

### Development & Debugging
```bash
dotnet tool install -g dotnet-dump
dotnet tool install -g dotnet-trace
dotnet tool install -g dotnet-counters
dotnet tool install -g dotnet-gcdump
dotnet tool install -g dotnet-symbol
dotnet tool install -g dotnet-sos
```

### Package Management
```bash
dotnet tool install -g dotnet-outdated-tool
dotnet tool install -g snitch
dotnet tool install -g dotnet-depends
```

### Code Generation & Scaffolding
```bash
dotnet tool install -g dotnet-aspnet-codegenerator
dotnet tool install -g Microsoft.dotnet-httprepl
dotnet tool install -g dotnet-openapi
```

### Testing
```bash
dotnet tool install -g dotnet-stryker
dotnet tool install -g coverlet.console
dotnet tool install -g trx2junit
```

### Formatting & Linting
```bash
dotnet tool install -g dotnet-format
dotnet tool install -g csharpier
dotnet tool install -g dotnet-fsharplint
```

### Performance & Benchmarking
```bash
dotnet tool install -g BenchmarkDotNet.Tool
dotnet tool install -g dotnet-benchmark
```

### DevOps & Deployment
```bash
dotnet tool install -g GitVersion.Tool
dotnet tool install -g dotnet-zip
dotnet tool install -g dotnet-docker
```

### Documentation
```bash
dotnet tool install -g docfx
dotnet tool install -g dotnet-api-docs
```

## Built-in CLI Commands

### Project Management
- `dotnet new` - Create new projects/files
- `dotnet add` - Add references/packages
- `dotnet remove` - Remove references/packages
- `dotnet list` - List references/packages

### Build & Run
- `dotnet build` - Build projects
- `dotnet run` - Run applications
- `dotnet publish` - Publish applications
- `dotnet clean` - Clean build outputs

### Package Management
- `dotnet restore` - Restore NuGet packages
- `dotnet pack` - Create NuGet packages
- `dotnet nuget` - NuGet management commands

### Testing
- `dotnet test` - Run unit tests
- `dotnet vstest` - Run tests with VSTest

### Development
- `dotnet watch` - Watch for file changes
- `dotnet dev-certs` - Manage development certificates
- `dotnet user-secrets` - Manage user secrets

## Workload Commands
```bash
dotnet workload install maui
dotnet workload install android
dotnet workload install ios
dotnet workload install maccatalyst
dotnet workload install tvos
dotnet workload install blazor-webassembly-aot
```

## SDK Management
```bash
dotnet --list-sdks
dotnet --list-runtimes
dotnet --info
```

To see all available global tools, you can search the NuGet gallery:
```bash
dotnet tool search <search-term>
```

To list currently installed global tools:
```bash
dotnet tool list -g
```

Would you like me to provide more details about any specific category or tool?