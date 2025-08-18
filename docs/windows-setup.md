# Windows DevContainer Setup Guide

This guide helps Windows users set up and troubleshoot DevContainers, particularly when using the kubernetes-outside-of-docker feature.

## Common Issues and Solutions

### Issue: Wayland Socket Mount Error

**Error Message:**
```
bind source path does not exist: \\wsl.localhost\Ubuntu\mnt\wslg\runtime-dir\wayland-0
```

**Cause:** VS Code automatically tries to mount GUI-related sockets for Wayland support, but these paths may not exist on Windows systems.

**Solutions:**

#### Solution 1: Disable GUI Forwarding (Recommended)
Add this to your `devcontainer.json`:
```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "dev.containers.forwardGUI": false
      }
    }
  }
}
```

#### Solution 2: Use VS Code Settings
1. Open VS Code Settings (File > Preferences > Settings)
2. Search for "devcontainer gui"
3. Uncheck "Dev > Containers: Forward GUI"

#### Solution 3: Update Docker Desktop
Ensure you're using the latest version of Docker Desktop for Windows with WSL2 backend enabled.

### Issue: Kubernetes Mount Not Found

**Error Message:**
```
Host .kube directory not mounted at /tmp/.kube
```

**Solution:** 
Ensure your `devcontainer.json` has the correct mount configuration for Windows:

```json
{
  "mounts": [
    {
      "source": "${localEnv:USERPROFILE}/.kube",
      "target": "/tmp/.kube",
      "type": "bind"
    }
  ]
}
```

**Note:** Use `${localEnv:USERPROFILE}` on Windows instead of `${localEnv:HOME}`.

## Recommended Windows DevContainer Configuration

Here's a complete, Windows-optimized `devcontainer.json`:

```json
{
  "name": "DevContainer Features Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/ruanzx/features/kubectl:latest": {},
    "ghcr.io/ruanzx/features/devcontainers-cli:latest": {},
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {}
  },
  "mounts": [
    {
      "source": "${localEnv:USERPROFILE}/.kube",
      "target": "/tmp/.kube",
      "type": "bind"
    }
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-json",
        "timonwong.shellcheck",
        "foxundermoon.shell-format"
      ],
      "settings": {
        "dev.containers.forwardGUI": false
      }
    }
  },
  "runArgs": [
    "--security-opt", "label=disable"
  ],
  "containerEnv": {
    "DISPLAY": ":0"
  },
  "init": true,
  "privileged": false,
  "overrideCommand": false,
  "remoteUser": "root"
}
```

## Prerequisites for Windows

1. **Docker Desktop for Windows** with WSL2 backend
2. **WSL2** installed and configured
3. **Kubernetes enabled** in Docker Desktop (optional, for local testing)

## Verification Steps

After setting up your devcontainer:

1. **Check Docker access:**
   ```bash
   docker ps
   ```

2. **Check Kubernetes mount:**
   ```bash
   ls -la /tmp/.kube/
   ```

3. **Test kubectl (if available):**
   ```bash
   kubectl cluster-info
   ```

## Troubleshooting

### Mount Validation Script

Run the included mount validator:
```bash
bash .devcontainer/mount-validator.sh
```

### Debug Mode

Enable debug mode for the kubernetes feature:
```bash
export KUBE_DEBUG=true
source /etc/profile.d/kubernetes-outside-docker.sh
```

### Check Container Logs

If the container fails to start:
```powershell
# In PowerShell on Windows
docker logs <container-name>
```

## Getting Help

If you continue to experience issues:

1. Check the [VS Code DevContainers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
2. Review the [Docker Desktop for Windows troubleshooting guide](https://docs.docker.com/desktop/troubleshoot/)
3. Open an issue in this repository with:
   - Your complete error message
   - Your `devcontainer.json` configuration
   - Your Windows and Docker Desktop versions
