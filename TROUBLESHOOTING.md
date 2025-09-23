# Dev Container Troubleshooting Guide

## Issue: TCP Upgrade Failure (502 Error)

### Symptoms
- Container builds successfully but VS Code can't connect
- Error: "unable to upgrade to tcp, received 502"
- Shell server terminated with code 1

### Solutions (Try in Order)

## 1. Use Simplified Configuration

If you're testing the Azure Functions example, try the minimal configuration first:

```bash
# Rename current config
mv .devcontainer/devcontainer.json .devcontainer/devcontainer.full.json

# Use minimal config
cp .devcontainer/devcontainer.minimal.json .devcontainer/devcontainer.json
```

## 2. Clean Docker Resources

```bash
# Clean up Docker space
docker system prune -f

# Remove unused images
docker image prune -a -f

# Check available space
docker system df
```

## 3. Restart Docker and VS Code

```bash
# Restart Docker (Linux)
sudo systemctl restart docker

# Or restart Docker Desktop (Windows/Mac)
```

Then restart VS Code completely.

## 4. Check System Resources

```bash
# Check memory usage
free -h

# Check disk space
df -h

# Check running containers
docker ps -a
```

## 5. Rebuild Container from Scratch

1. Close VS Code
2. Delete existing container:
   ```bash
   docker container prune -f
   docker volume prune -f
   ```
3. Reopen project in VS Code
4. Select "Rebuild Container"

## 6. Try Different Base Image

Edit your `devcontainer.json` to use a smaller base image:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-20.04"
}
```

## 7. Disable Port Forwarding Temporarily

Comment out port forwarding in `devcontainer.json`:

```json
{
  // "forwardPorts": [7071],
  // "portsAttributes": {
  //   "7071": {
  //     "label": "Azure Functions Runtime"
  //   }
  // }
}
```

## 8. Check VS Code Dev Container Extension

1. Update VS Code Dev Container extension
2. Reload VS Code window (Ctrl+Shift+P → "Developer: Reload Window")
3. Try opening the container again

## 9. Network Troubleshooting

If you're behind a corporate firewall or proxy:

```bash
# Check network connectivity
curl -I https://github.com
curl -I https://mcr.microsoft.com

# Configure Docker proxy if needed
# Add to ~/.docker/config.json:
{
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.company.com:8080",
      "httpsProxy": "http://proxy.company.com:8080"
    }
  }
}
```

## 10. Alternative: Use Codespaces

If local development continues to fail, consider using GitHub Codespaces:

1. Push your code to GitHub
2. Create a Codespace
3. The same devcontainer.json will work in Codespaces

## Prevention Tips

1. **Keep Docker clean**: Run `docker system prune` regularly
2. **Monitor resources**: Ensure adequate disk space and memory
3. **Use staged builds**: Start with minimal configurations and add features gradually
4. **Test configurations**: Validate devcontainer.json syntax before building

## Common Configuration Issues

### Too Many Features
Reduce the number of features loaded simultaneously:

```json
{
  "features": {
    // Start with just one feature
    "ghcr.io/ruanzx/features/azure-functions-core-tools:latest": {}
  }
}
```

### Too Many Extensions
Limit VS Code extensions:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        // Keep only essential extensions
        "ms-azuretools.vscode-azurefunctions"
      ]
    }
  }
}
```

### Large postCreateCommand
Simplify or remove complex post-creation commands:

```json
{
  "postCreateCommand": "echo 'Container ready'"
}
```

---

If none of these solutions work, please share:
1. Your `devcontainer.json` configuration
2. Complete error logs from VS Code Dev Container extension
3. System information (OS, Docker version, available resources)