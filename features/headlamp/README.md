# Headlamp Feature

Installs [Headlamp](https://headlamp.dev/), a user-friendly Kubernetes UI for the desktop and web that provides an easy way to manage and interact with Kubernetes clusters.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/headlamp": {}
  }
}
```

## Options

| Option    | Type   | Default  | Description                    |
| --------- | ------ | -------- | ------------------------------ |
| `version` | string | `0.35.0` | Version of Headlamp to install |

## Examples

### Install latest version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/headlamp": {
      "version": "0.35.0"
    }
  }
}
```

### Install specific version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/headlamp": {
      "version": "0.34.0"
    }
  }
}
```

### Combined with Kubernetes tools

```json
{
  "features": {
    "ghcr.io/devcontainers/features/kubectl": {},
    "ghcr.io/ruanzx/devcontainer-features/kubernetes-outside-of-docker": {},
    "ghcr.io/ruanzx/devcontainer-features/headlamp": {}
  }
}
```

## What is Headlamp?

Headlamp is a modern, user-friendly Kubernetes dashboard that provides:

- **Easy cluster management**: View and manage your Kubernetes resources through an intuitive web interface
- **Multi-cluster support**: Connect to multiple Kubernetes clusters and switch between them
- **Resource visualization**: See your deployments, services, pods, and other resources at a glance
- **Real-time monitoring**: Monitor cluster health and resource usage in real-time
- **Plugin system**: Extend functionality with custom plugins
- **Desktop and web access**: Run as a desktop application or web service

## Usage After Installation

### Starting Headlamp

After installation, you can start Headlamp in several ways:

#### Web Mode (Recommended for containers)
```bash
# Start Headlamp web server (accessible via browser)
headlamp --port 4466 --no-sandbox
```

#### Desktop Mode (if X11 forwarding is available)
```bash
# Start Headlamp as desktop application
headlamp --no-sandbox
```

### Accessing the UI

- **Web interface**: Open `http://localhost:4466` in your browser
- **Desktop**: Headlamp will open as a native application window

### Container Considerations

When running in containers (especially as root), Headlamp requires the `--no-sandbox` flag:

```bash
headlamp --port 4466 --no-sandbox
```

This is normal and safe in containerized environments.

## Kubernetes Integration

Headlamp works best when combined with Kubernetes access. Common setup patterns:

### With local Kubernetes cluster
```json
{
  "features": {
    "ghcr.io/devcontainers/features/kubectl": {},
    "ghcr.io/ruanzx/devcontainer-features/kubernetes-outside-of-docker": {},
    "ghcr.io/ruanzx/devcontainer-features/headlamp": {}
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

### With remote clusters
Headlamp can connect to any Kubernetes cluster accessible via kubectl configuration.

## Key Features

### Cluster Overview
- View cluster health and status
- Monitor resource usage and capacity
- See running workloads at a glance

### Resource Management
- **Workloads**: Deployments, StatefulSets, DaemonSets, Jobs, CronJobs
- **Discovery**: Services, Ingresses, Network Policies
- **Config**: ConfigMaps, Secrets, PVCs
- **Access Control**: RBAC, Service Accounts, Roles

### Advanced Features
- **Logs viewing**: Stream and search pod logs
- **Shell access**: Execute commands in pods
- **YAML editing**: Edit resources directly
- **Event monitoring**: Track cluster events
- **Port forwarding**: Access services locally

## System Requirements

- **OS**: Linux (amd64, arm64, armv7)
- **Dependencies**: GTK3, NSS3, ALSA (automatically installed)
- **Kubernetes**: Works with any Kubernetes cluster (local or remote)
- **Browser**: For web interface (Chrome, Firefox, Edge, Safari)

## Verification

After installation, verify Headlamp is working:

```bash
# Check installation
verify-headlamp

# Test command exists
headlamp --help

# Start in web mode (background)
headlamp --port 4466 --no-sandbox &

# Access web interface
curl http://localhost:4466 || echo "Headlamp is starting..."
```

## Troubleshooting

### Common Issues

#### "Running as root without --no-sandbox" error
This is expected in containers. Always use `--no-sandbox` flag:
```bash
headlamp --no-sandbox
```

#### Cannot connect to cluster
Ensure kubectl is configured and working:
```bash
kubectl cluster-info
kubectl get nodes
```

#### Port already in use
Change the port number:
```bash
headlamp --port 8080 --no-sandbox
```

#### Missing display for desktop mode
Use web mode instead:
```bash
headlamp --port 4466 --no-sandbox
```

## Development Workflow

Headlamp is perfect for Kubernetes development workflows:

1. **Start your development environment**
2. **Launch Headlamp**: `headlamp --port 4466 --no-sandbox &`
3. **Open browser**: Navigate to `http://localhost:4466`
4. **Monitor your applications** in real-time
5. **Debug issues** using logs and shell access

## Supported Platforms

- **Linux x64**: ✅ Fully supported
- **Linux ARM64**: ✅ Fully supported  
- **Linux ARMv7**: ✅ Fully supported
- **Other platforms**: Not supported by this feature

## Links

- **Homepage**: https://headlamp.dev/
- **Documentation**: https://headlamp.dev/docs/
- **GitHub**: https://github.com/headlamp-k8s/headlamp
- **Releases**: https://github.com/headlamp-k8s/headlamp/releases

## License

This feature installs Headlamp which is licensed under the [Apache License 2.0](https://github.com/headlamp-k8s/headlamp/blob/main/LICENSE).
