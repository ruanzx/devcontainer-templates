# APT Package Manager Feature

This feature installs packages using the APT package manager on Debian-like systems (Ubuntu, Debian, etc.). It provides a convenient way to install system packages during container build time with configurable options for package list management and cache cleaning.

## Description

APT (Advanced Package Tool) is the primary package management system for Debian and Ubuntu-based Linux distributions. This feature allows you to specify a list of packages to install and configure various APT behaviors like cache cleaning and package list updates.

## Use Cases

- **Development Tools**: Install essential development packages (build-essential, git, curl, etc.)
- **System Utilities**: Add useful command-line tools (htop, tree, jq, etc.)
- **Language Runtimes**: Install specific language interpreters or compilers
- **Libraries**: Install system libraries required by your application
- **Debugging Tools**: Add debugging and profiling utilities

## Options

### `packages` (string)
Comma-separated list of package names to install.

- **Default**: `""` (empty - no packages)
- **Example**: `"curl,git,vim,htop,jq,tree"`
- **Description**: Specify the packages you want to install. Package names should be valid APT package names.

### `cleanCache` (boolean)
Remove APT cache after package installation to reduce image size.

- **Default**: `true`
- **Description**: When true, runs `apt-get autoremove`, `apt-get autoclean`, and removes `/var/lib/apt/lists/*` to minimize image size

### `updatePackageList` (boolean)
Update package list before installing packages.

- **Default**: `true`
- **Description**: Runs `apt-get update` to refresh the package list from repositories

### `upgradePackages` (boolean)
Upgrade existing packages before installing new ones.

- **Default**: `false`
- **Description**: Runs `apt-get upgrade` to update all installed packages to their latest versions

## Basic Usage

### Simple Package Installation

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,git,vim"
    }
  }
}
```

### Development Environment

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "build-essential,git,curl,wget,vim,htop,tree,jq,unzip"
    }
  }
}
```

### System Administration Tools

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "htop,iotop,nethogs,tcpdump,strace,lsof,net-tools"
    }
  }
}
```

## Advanced Configuration

### Custom Package Management

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "nodejs,npm,python3-pip,docker.io",
      "cleanCache": false,
      "updatePackageList": true,
      "upgradePackages": true
    }
  }
}
```

### Minimal Installation (No Cache Cleaning)

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "essential-package",
      "cleanCache": false,
      "updatePackageList": false
    }
  }
}
```

## Common Package Categories

### Development Tools

```json
{
  "packages": "build-essential,git,curl,wget,vim,nano,htop,tree,jq,unzip,zip"
}
```

**Includes:**
- `build-essential` - GCC compiler and build tools
- `git` - Version control system
- `curl`, `wget` - HTTP clients
- `vim`, `nano` - Text editors
- `htop` - Process monitor
- `tree` - Directory tree viewer
- `jq` - JSON processor
- `unzip`, `zip` - Archive utilities

### System Monitoring

```json
{
  "packages": "htop,iotop,nethogs,tcpdump,strace,lsof,net-tools,dstat"
}
```

**Includes:**
- `htop` - Interactive process viewer
- `iotop` - I/O monitoring
- `nethogs` - Network bandwidth monitor
- `tcpdump` - Network packet analyzer
- `strace` - System call tracer
- `lsof` - List open files
- `net-tools` - Network configuration utilities
- `dstat` - System resource statistics

### Database Tools

```json
{
  "packages": "mysql-client,postgresql-client,redis-tools,sqlite3"
}
```

### Network Tools

```json
{
  "packages": "nmap,telnet,netcat,dig,whois,traceroute,mtr-tiny"
}
```

### Security Tools

```json
{
  "packages": "gnupg,ca-certificates,openssl,ssh-client"
}
```

## Package Validation

The feature includes validation for package names to prevent common errors:

- **Character Validation**: Only allows valid package name characters (letters, numbers, dots, hyphens, plus signs, underscores)
- **Format Validation**: Checks for proper comma separation
- **Empty Package Handling**: Gracefully handles empty package lists

## Examples by Use Case

### Web Development Environment

```json
{
  "name": "Web Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,git,vim,htop,tree,jq,nodejs,npm"
    }
  }
}
```

### Python Data Science

```json
{
  "name": "Python Data Science",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "git,vim,htop,tree,jq,graphviz,libpq-dev,gcc"
    }
  }
}
```

### System Administration

```json
{
  "name": "SysAdmin Tools",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "htop,iotop,nethogs,tcpdump,strace,lsof,net-tools,nmap,telnet"
    }
  }
}
```

### Security Testing

```json
{
  "name": "Security Testing",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "nmap,netcat,tcpdump,wireshark-common,john,hashcat,sqlmap"
    }
  }
}
```

## Performance Considerations

### Image Size Optimization

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "essential-packages-only",
      "cleanCache": true,
      "updatePackageList": true,
      "upgradePackages": false
    }
  }
}
```

**Benefits of `cleanCache: true`:**
- Removes downloaded package files
- Cleans unused dependencies
- Removes package list cache
- Can save 100MB+ in container images

### Build Time Optimization

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "my-packages",
      "updatePackageList": false,
      "upgradePackages": false
    }
  }
}
```

**When to disable updates:**
- Base image already has recent package lists
- Building frequently and want faster builds
- Using a specific base image version

## Troubleshooting

### Common Issues

1. **Package Not Found**
   ```
   E: Unable to locate package package-name
   ```
   - **Solution**: Check package name spelling and availability
   - **Check**: `apt search package-name` or visit https://packages.ubuntu.com/

2. **Permission Denied**
   ```
   E: Could not open lock file
   ```
   - **Solution**: Feature runs with appropriate permissions automatically
   - **Note**: This shouldn't occur in devcontainer builds

3. **Invalid Package Names**
   ```
   ❌ Invalid package names detected
   ```
   - **Solution**: Check for typos and invalid characters in package names
   - **Valid**: Letters, numbers, dots, hyphens, plus signs, underscores

4. **Network Issues**
   ```
   Failed to fetch package lists
   ```
   - **Solution**: Check internet connectivity and repository availability
   - **Retry**: Build process with better network connection

### Verification Commands

```bash
# Check if packages are installed
dpkg -l | grep package-name

# List all installed packages
dpkg -l

# Check package information
apt show package-name

# Search for packages
apt search keyword
```

## Integration with Other Features

### With Programming Languages

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "python3-dev,libpq-dev,gcc,build-essential"
    }
  }
}
```

### With Development Tools

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "git,curl,jq,tree,htop"
    }
  }
}
```

### Multiple Package Installations

```json
{
  "features": {
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "essential-tools,monitoring-tools"
    },
    "ghcr.io/devcontainers/features/node:latest": {}
  }
}
```

## Security Considerations

- **Package Sources**: Only installs from configured APT repositories
- **Signature Verification**: APT automatically verifies package signatures
- **Minimal Installation**: Only install packages you actually need
- **Regular Updates**: Consider enabling `upgradePackages` for security updates

## Best Practices

1. **Group Related Packages**: Install related packages together for efficiency
2. **Use Specific Versions**: For production, consider pinning package versions
3. **Clean Cache**: Keep `cleanCache: true` for production images
4. **Validate Packages**: Test package installations in development
5. **Document Dependencies**: Comment why specific packages are needed

## More Information

- [APT Documentation](https://wiki.debian.org/Apt)
- [Ubuntu Package Search](https://packages.ubuntu.com/)
- [Debian Package Search](https://packages.debian.org/)
- [APT Command Reference](https://manpages.ubuntu.com/manpages/jammy/man8/apt.8.html)
