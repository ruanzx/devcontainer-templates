# APT Package Management Example

This example demonstrates how to use the APT feature to install custom packages in your devcontainer.

## Features Used

- **APT Feature**: Installs system packages using the APT package manager

## Configuration

The devcontainer is configured to install a comprehensive set of development tools:

```jsonc
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "htop,tree,curl,wget,vim,git,jq,unzip,zip,nano",
      "cleanCache": true,
      "updatePackageList": true,
      "upgradePackages": false
    }
  }
}
```

## Installed Packages

This configuration installs the following packages:

- **htop** - Interactive process viewer
- **tree** - Directory tree visualization
- **curl** - Command line HTTP client
- **wget** - File downloader
- **vim** - Text editor
- **git** - Version control system
- **jq** - JSON processor
- **unzip** - Archive extractor
- **zip** - Archive creator
- **nano** - Simple text editor

## APT Feature Options

### Available Options

- `packages` (string): Comma-separated list of package names to install
- `cleanCache` (boolean, default: true): Remove APT cache after installation to reduce image size
- `updatePackageList` (boolean, default: true): Update package list before installing packages
- `upgradePackages` (boolean, default: false): Upgrade existing packages before installing new ones

### Example Configurations

#### Basic package installation:
```json
{
  "ghcr.io/ruanzx/features/apt:latest": {
    "packages": "curl,git,vim"
  }
}
```

#### Advanced configuration with cache management:
```json
{
  "ghcr.io/ruanzx/features/apt:latest": {
    "packages": "build-essential,cmake,gdb,valgrind",
    "cleanCache": false,
    "updatePackageList": true,
    "upgradePackages": true
  }
}
```

#### Development tools for specific languages:
```json
{
  "ghcr.io/ruanzx/features/apt:latest": {
    "packages": "python3-pip,nodejs,npm,default-jdk,maven"
  }
}
```

## Getting Started

1. Open this folder in VS Code
2. When prompted, reopen in container
3. Wait for the container to build and packages to install
4. Start coding with your custom development environment!

## Verification

After the container starts, you can verify the installed packages:

```bash
# Check specific packages
dpkg -l | grep -E 'htop|tree|curl'

# Test tools
htop --version
tree --version
curl --version
jq --version
```

## Use Cases

This example is perfect for:

- **General Development**: Basic development tools for any project
- **Shell Scripting**: Tools for working with files, APIs, and data
- **System Administration**: Monitoring and file management tools
- **Learning**: Pre-configured environment with common Unix tools

## Troubleshooting

### Package Not Found
If a package isn't available, check the package name:
```bash
apt search <package-name>
```

### Permission Issues
The feature runs with appropriate permissions during container build. No sudo required.

### Cache Issues
If you want to preserve the cache for debugging:
```json
{
  "cleanCache": false
}
```

## Related Examples

- [Basic All Features](../basic-all-features/) - See all available features
- [Security Tools](../security-tools/) - Security-focused package selection
- [Kubernetes Dev](../kubernetes-dev/) - Kubernetes development tools
