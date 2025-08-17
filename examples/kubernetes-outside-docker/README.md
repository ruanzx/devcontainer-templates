# Kubernetes Outside Docker Example

This example demonstrates how to use the `kubernetes-outside-of-docker` feature to access a host Kubernetes cluster (like Docker Desktop) from within a dev container.

## Prerequisites

- Docker Desktop with Kubernetes enabled, OR
- Any Kubernetes cluster accessible from the host
- Host `~/.kube/config` file configured

## Usage

### Basic Configuration

```json
{
  "name": "Kubernetes Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/kubectl:latest": {},
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {}
  },
  "mounts": [
    {
      "source": "${localEnv:HOME}/.kube",
      "target": "/tmp/.kube", 
      "type": "bind"
    }
  ]
}
```

### Windows Configuration

For Windows hosts, use `USERPROFILE` instead of `HOME`:

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

### What the Feature Does

1. **Mounts host kubeconfig**: Uses the mount to access your host's `~/.kube/config`
2. **Fixes connectivity**: Replaces localhost/kubernetes.docker.internal with container-accessible IPs
3. **Sets environment**: Configures `KUBECONFIG` for all users
4. **Docker Desktop compatible**: Automatically detects and uses the correct IP for certificate validation

### Supported Kubernetes Configurations

- ✅ Docker Desktop Kubernetes
- ✅ Minikube 
- ✅ Local clusters (kind, k3s, etc.)
- ✅ Remote clusters with local kubeconfig

### IP Resolution

The feature automatically:
- Detects Docker Desktop and uses `192.168.65.3` (certificate-valid IP)
- Falls back to gateway IP `172.17.0.1` for other setups
- Replaces all localhost, 127.0.0.1, and kubernetes.docker.internal references

### Testing Connectivity

After the container starts:

```bash
# Check kubectl configuration
kubectl config view

# Test cluster connectivity  
kubectl cluster-info

# List nodes
kubectl get nodes

# Verify current context
kubectl config current-context
```

### Troubleshooting

If you see connection errors:

1. **Verify mount**: Check if `/tmp/.kube/config` exists in the container
2. **Check IP**: The feature logs which IP it's using for connectivity
3. **Test manually**: Try `kubectl get nodes` to verify the connection
4. **Certificate issues**: For Docker Desktop, ensure the cluster is using the certificate-valid IP

### Example Output

When working correctly, you should see:
```
[INFO] 🔧 Setting up Kubernetes access from dev container...
[INFO] 📋 Container user: vscode
[INFO] 📁 User home: /home/vscode
[INFO] 📋 Copying and fixing host kubeconfig
[INFO] 🐳 Detected Docker Desktop, using 192.168.65.3
[INFO] 🔧 Kubeconfig server URLs updated to use 192.168.65.3
[SUCCESS] ✅ KUBECONFIG set to: /home/vscode/.kube/config
[SUCCESS] ✅ kubectl connection successful!
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   1d    v1.28.2
[SUCCESS] 🎉 Kubernetes outside-of-docker setup complete!
```

## Integration with Other Features

This feature works well with other Kubernetes tools:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/kubectl:latest": {},
    "ghcr.io/ruanzx/features/kubernetes-outside-of-docker:latest": {},
    "ghcr.io/ruanzx/features/helm:latest": {},
    "ghcr.io/ruanzx/features/k9s:latest": {},
    "ghcr.io/ruanzx/features/skaffold:latest": {}
  }
}
```
