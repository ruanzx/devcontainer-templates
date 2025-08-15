# Kubernetes Outside of Docker

This feature enables access to the host machine's Kubernetes cluster from within a dev container. It configures kubectl to work seamlessly with clusters running on the host, including Docker Desktop Kubernetes, kind, minikube, and other local clusters.

## Features

- 🔧 Automatic detection of host Kubernetes cluster configuration
- 🌐 Smart network configuration for container-to-host connectivity  
- 🏷️ Special handling for kind clusters and Docker Desktop Kubernetes
- 🔐 Proper TLS configuration for container environments
- 📝 Automatic shell environment setup
- 💾 Safe handling of original kubeconfig (creates backups)

## Requirements

- kubectl must be available (automatically installed via dependency)
- Host Kubernetes cluster must be running and accessible
- .kube directory must be mounted from host to container

## Usage

### Basic Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {}
  }
}
```

### With Required Mount

To access your host Kubernetes cluster, you must mount your .kube directory:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {}
  },
  "mounts": [
    {
      "source": "${localEnv:HOME}/.kube",
      "target": "/home/vscode/.kube", 
      "type": "bind"
    }
  ]
}
```

### Complete Example

```json
{
  "name": "Kubernetes Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:latest": {},
    "ghcr.io/ruanzx/features/kubectl:latest": {},
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {}
  },
  "mounts": [
    {
      "source": "${localEnv:HOME}/.kube",
      "target": "/home/vscode/.kube",
      "type": "bind"
    }
  ],
  "runArgs": [
    "--add-host=host.docker.internal:172.17.0.1",
    "--add-host=kubernetes.docker.internal:172.17.0.1"
  ]
}
```

## How It Works

1. **Detection**: Automatically detects the type of Kubernetes cluster (kind, Docker Desktop, etc.)
2. **Network Configuration**: Determines the correct gateway IP and port for container-to-host communication
3. **Kubeconfig Modification**: Creates a container-specific kubeconfig with updated server URLs
4. **TLS Configuration**: Configures kubectl to skip TLS verification when necessary
5. **Environment Setup**: Sets up KUBECONFIG environment variable for all shell sessions

## Supported Cluster Types

- **Docker Desktop Kubernetes**: Full support with automatic detection
- **kind clusters**: Automatic detection with special networking handling
- **minikube**: Works with proper network configuration
- **Remote clusters**: Works if accessible from container network
- **k3s/k3d**: Compatible with standard configuration

## Troubleshooting

### No kubeconfig found

```
ℹ️  No kubeconfig found at /home/vscode/.kube/config
   Mount your .kube directory to access the host Kubernetes cluster
```

**Solution**: Add the .kube directory mount to your devcontainer.json as shown above.

### kind cluster connection issues

If using a kind cluster bound to localhost, you may see:

```
⚠️  This appears to be a kind cluster bound to localhost.
   For dev container access, consider recreating the cluster with:
```

**Solution**: Create a kind cluster that binds to all interfaces:

```bash
kind create cluster --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
EOF
```

### Connection timeouts

If kubectl commands timeout:

1. Verify the Kubernetes cluster is running on the host
2. Check that the .kube directory is properly mounted
3. Ensure network connectivity between container and host
4. Try restarting the dev container

## Files Created

- `/home/vscode/.kube/config-container`: Container-specific kubeconfig
- `/home/vscode/.kube/config.backup`: Backup of original kubeconfig
- `/usr/local/share/kubernetes-init.sh`: Initialization script
- `/usr/local/share/docker-init.sh`: Entrypoint script (symlink)

## Environment Variables

- `KUBECONFIG`: Automatically set to `/home/vscode/.kube/config-container`

## Dependencies

- `ghcr.io/devcontainers/features/common-utils`: Base utilities
- `ghcr.io/ruanzx/features/kubectl`: kubectl CLI tool

## Verification

After installation, verify the setup works:

```bash
# Check kubectl is available
kubectl version --client

# Test cluster connection
kubectl get nodes

# Verify kubeconfig location
echo $KUBECONFIG
```

## Manual Configuration

If automatic configuration doesn't work, you can manually run the initialization:

```bash
sudo /usr/local/share/kubernetes-init.sh
```

## Security Notes

- TLS verification is disabled for container-to-host communication
- Original kubeconfig remains unchanged
- Container-specific configuration is isolated from host
- Backup of original configuration is automatically created
