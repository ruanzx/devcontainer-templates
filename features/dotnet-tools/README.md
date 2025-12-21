# .NET Global Tools (dotnet-tools)

Installs custom .NET global tools from the official .NET tool ecosystem.

## Example Usage

```json
"features": {
    "ghcr.io/ruanzx/features/dotnet-tools:latest": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| tools | Comma-separated list of .NET global tools to install. Format: 'tool@version' or 'tool@latest' | string | dotnet-format@latest |
| prerelease | Include prerelease versions when installing tools | boolean | false |

## Supported Tools Examples

### Code Formatting
```json
"ghcr.io/ruanzx/features/dotnet-tools:latest": {
    "tools": "dotnet-format@latest"
}
```

### Entity Framework
```json
"ghcr.io/ruanzx/features/dotnet-tools:latest": {
    "tools": "dotnet-ef@latest"
}
```

### Multiple Tools
```json
"ghcr.io/ruanzx/features/dotnet-tools:latest": {
    "tools": "dotnet-format@latest,dotnet-ef@latest,dotnet-outdated-tool@latest"
}
```

### Specific Versions
```json
"ghcr.io/ruanzx/features/dotnet-tools:latest": {
    "tools": "dotnet-ef@7.0.0,dotnet-format@5.1.250250"
}
```

### With Prerelease Versions
```json
"ghcr.io/ruanzx/features/dotnet-tools:latest": {
    "tools": "dotnet-ef@latest",
    "prerelease": true
}
```

## Popular .NET Global Tools

### Entity Framework
- `dotnet-ef` - Entity Framework Core CLI tools

### Code Analysis & Quality
- `dotnet-sonarscanner` - SonarQube scanner
- `dotnet-reportgenerator-globaltool` - Coverage report generator
- `dotnet-coverage` - Code coverage tool
- `security-scan` - Security vulnerability scanner

### Development & Debugging
- `dotnet-dump` - Dump collection and analysis
- `dotnet-trace` - Performance tracing
- `dotnet-counters` - Performance counters
- `dotnet-gcdump` - GC dump collection

### Package Management
- `dotnet-outdated-tool` - Check for outdated packages
- `snitch` - Detect transitive package references
- `dotnet-depends` - Dependency analysis

### Code Generation & Scaffolding
- `dotnet-aspnet-codegenerator` - ASP.NET Core scaffolding
- `Microsoft.dotnet-httprepl` - HTTP REPL tool
- `dotnet-openapi` - OpenAPI tools

### Testing
- `dotnet-stryker` - Mutation testing
- `coverlet.console` - Code coverage
- `trx2junit` - Test result conversion

### Formatting & Linting
- `dotnet-format` - Code formatter
- `csharpier` - C# code formatter
- `dotnet-fsharplint` - F# linter

### Performance & Benchmarking
- `BenchmarkDotNet.Tool` - Benchmarking framework
- `dotnet-benchmark` - Benchmark runner

### DevOps & Deployment
- `GitVersion.Tool` - Semantic versioning
- `dotnet-zip` - Archive creation
- `dotnet-docker` - Docker utilities

### Documentation
- `docfx` - Documentation generator
- `dotnet-api-docs` - API documentation

## Prerequisites

This feature requires the .NET SDK to be installed. It's recommended to install the .NET feature first:

```json
"features": {
    "ghcr.io/devcontainers/features/dotnet:latest": {},
    "ghcr.io/ruanzx/features/dotnet-tools:latest": {
        "tools": "dotnet-ef@latest,dotnet-format@latest"
    }
}
```

## Notes

- Tools are installed globally and available system-wide
- Use `@latest` to install the latest stable version
- Use specific version numbers for reproducible builds
- Set `prerelease: true` to include preview/beta versions
- Multiple tools can be installed by separating them with commas
- The feature will verify installation and report any failures

## Verification

After installation, you can verify the tools are available:

```bash
# List all installed global tools
dotnet tool list --global

# Check specific tool versions
dotnet ef --version
dotnet format --version
```

## Troubleshooting

If a tool fails to install:
1. Check the tool name is correct
2. Verify the version exists
3. Check if .NET SDK is properly installed
4. Try with `prerelease: true` for newer tools
5. Check the tool's NuGet page for specific requirements
