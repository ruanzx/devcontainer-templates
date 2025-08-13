# Kubernetes Development Environment

This example creates a complete Kubernetes development environment with essential tools.

## Features Included

- **Docker-in-Docker** - Run Docker commands inside the container
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **K9s** - Kubernetes cluster management UI
- **Skaffold** - Continuous development for Kubernetes
- **yq** - YAML processing

## Usage

1. Open this folder in VS Code
2. Choose "Reopen in Container"
3. Start a local Kubernetes cluster: `minikube start`
4. Use K9s for cluster management: `k9s`
5. Use Skaffold for development: `skaffold dev`

## Sample Commands

```bash
# Check cluster status
kubectl cluster-info

# Install applications with Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-app bitnami/nginx

# Launch K9s dashboard
k9s

# Initialize Skaffold in your project
skaffold init

# Process YAML files
cat deployment.yaml | yq '.spec.replicas = 3'
```
