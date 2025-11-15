# tldr Development Environment Example

This example demonstrates how to use the [tldr-in-docker DevContainer Feature](../../features/tldr-in-docker/) to set up a development environment with simplified and community-driven man pages.

## What's Included

This DevContainer configuration provides:

- **Docker Support**: Required for running tldr in containers
- **tldr CLI**: Simplified man pages with practical examples
- **Persistent Caching**: Docker volume caching for fast access
- **VS Code Extensions**: JSON and YAML support for configuration files

## Quick Start

### 1. Open in DevContainer

Open this folder in VS Code and reopen in the DevContainer when prompted, or use the command palette:
- `Dev Containers: Reopen in Container`

### 2. Verify Installation

After the container builds, verify tldr is installed:

```bash
# Check version
tldr --version

# View help
tldr --help

# Test basic functionality
tldr tar
tldr git
tldr docker
```

### 3. Explore tldr Features

Try some common commands to see tldr in action:

```bash
# Get help for various commands
tldr ls          # List directory contents
tldr cp          # Copy files and directories
tldr mv          # Move files and directories
tldr grep        # Print lines matching a pattern
tldr find        # Search for files in a directory hierarchy

# Development tools
tldr git         # Git version control
tldr docker      # Docker container platform
tldr curl        # Transfer data from or to a server
tldr wget        # Download files from the web

# System administration
tldr systemctl   # Control the systemd system and service manager
tldr journalctl  # Query the systemd journal
tldr iptables    # Administration tool for IPv4 packet filtering
```

### 4. Cache Management

The tldr feature includes persistent caching for improved performance:

```bash
# Check cache status (cache updates automatically daily)
tldr --list

# Force cache update if needed
docker volume rm tldr-cache
# Then run any tldr command to recreate cache
```

## Development Workflow

### Using tldr for Learning

tldr is perfect for quickly learning command-line tools:

```bash
# When learning a new tool, start with tldr
tldr rsync       # File synchronization tool
tldr ssh         # OpenSSH remote login client
tldr scp         # Secure copy (remote file copy program)

# Get practical examples instead of reading full man pages
tldr tar         # Archive management
tldr gzip        # Compress files
tldr unzip       # Extract compressed files
```

### Scripting and Automation

Use tldr in scripts to provide helpful examples:

```bash
#!/bin/bash
# Example script showing tldr usage

echo "🔍 Quick reference for common commands:"
echo ""

echo "File Operations:"
tldr cp
echo "---"
tldr mv
echo "---"
tldr rm
echo ""

echo "Process Management:"
tldr ps
echo "---"
tldr kill
echo "---"
tldr top
```

## Configuration

### Customizing the DevContainer

You can customize this DevContainer by modifying `.devcontainer/devcontainer.json`:

```json
{
  "name": "tldr Development Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/features/tldr-in-docker:latest": {
      "version": "latest",
      "imageName": "ruanzx/tldr"
    }
  }
}
```

### Environment Variables

The tldr wrapper supports environment variables for customization:

```bash
# Use a different Docker image
export TLDR_IMAGE_NAME="my-custom/tldr"
export TLDR_IMAGE_TAG="v1.0.0"

# Then use tldr normally
tldr docker
```

## Troubleshooting

### Common Issues

**tldr command not found:**
```bash
# Ensure you're in the DevContainer
# If not, reopen in container or run:
source ~/.bashrc
```

**Docker not running:**
```bash
# Check Docker status
docker info

# Start Docker if needed
sudo service docker start
```

**Cache issues:**
```bash
# Clear and recreate cache
docker volume rm tldr-cache
tldr --update
```

### Performance Tips

- **Caching**: The first run creates a cache that speeds up subsequent commands
- **Volume Persistence**: Cache persists across container restarts
- **Daily Updates**: Cache automatically updates once per day

## Advanced Usage

### Integrating with Development Workflow

Create aliases or scripts that use tldr for documentation:

```bash
# Add to your ~/.bashrc or ~/.zshrc
alias help='tldr'
alias learn='tldr'
alias examples='tldr'

# Now you can use:
help git
learn docker
examples tar
```

### Contributing to tldr

The tldr project welcomes contributions:

```bash
# View existing pages
tldr --list

# Find pages that need improvement
# Visit: https://github.com/tldr-pages/tldr

# Contributing guidelines:
# https://github.com/tldr-pages/tldr/blob/main/CONTRIBUTING.md
```

## Related Resources

- [tldr GitHub Repository](https://github.com/tldr-pages/tldr)
- [tldr Website](https://tldr.sh/)
- [Contributing to tldr](https://github.com/tldr-pages/tldr/blob/main/CONTRIBUTING.md)
- [tldr-in-docker Feature Documentation](../../features/tldr-in-docker/)

## Next Steps

- Explore more commands with `tldr --list`
- Check out the [tldr-in-docker feature](../../features/tldr-in-docker/) for advanced configuration
- Consider contributing to the tldr project by improving existing pages or adding new ones