# Kubernetes Development Environment

This example demonstrates how to set up a development environment that can access and manage Kubernetes clusters running on the host machine.

## Features Included

- **kubectl** - Kubernetes command-line tool
- **Host cluster access** - Connect to Kubernetes clusters running on your host machine
- **Helm** - Kubernetes package manager
- **K9s** - Kubernetes cluster management UI
- **Skaffold** - Continuous development for Kubernetes
- **yq** - YAML processing tool

## Prerequisites

- Kubernetes cluster running on host (Docker Desktop, kind, minikube, etc.)
- `.kube/config` file with valid cluster configuration

## Usage

1. **Ensure your Kubernetes cluster is running**:
   ```bash
   # For Docker Desktop: Enable Kubernetes in Docker Desktop settings
   # For kind (recommended for containers):
   kind create cluster --config - <<EOF
   kind: Cluster
   apiVersion: kind.x-k8s.io/v1alpha4
   networking:
     apiServerAddress: "0.0.0.0"
     apiServerPort: 6443
   EOF
   
   # For minikube:
   minikube start
   ```

2. **Open this directory in VS Code**

3. **Reopen in container** when prompted

4. **Verify kubectl access**:
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

## Sample Commands

```bash
# Check cluster status and connectivity
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Install applications with Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-nginx bitnami/nginx

# Launch K9s dashboard for cluster management
k9s

# Initialize Skaffold in your project for continuous development
skaffold init

# Process YAML files with yq
cat deployment.yaml | yq '.spec.replicas = 3'

# Port forward services for local development
kubectl port-forward service/my-nginx 8080:80

# View application logs
kubectl logs -f deployment/my-nginx
```

## What's Different

This environment automatically configures kubectl to access your **host machine's** Kubernetes cluster instead of requiring you to set up a separate cluster inside the container. This means:

- ✅ Use your existing Docker Desktop Kubernetes
- ✅ Access your kind or minikube clusters
- ✅ Connect to remote clusters configured on your host
- ✅ No additional cluster setup required

## Troubleshooting

### No nodes found
If `kubectl get nodes` returns "No resources found":
1. Ensure your Kubernetes cluster is running on the host
2. Verify the `.kube` directory is mounted and contains a valid config
3. For kind clusters, ensure they bind to `0.0.0.0` not `127.0.0.1`

### Connection issues
If you can't connect to the cluster:
1. Check that your host cluster is accessible
2. Restart the dev container
3. For kind: recreate with proper networking configuration (see usage section)
