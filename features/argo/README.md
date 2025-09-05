
# Argo

Installs [Argo Workflows](https://github.com/argoproj/argo-workflows) and [Argo CD](https://github.com/argoproj/argo-cd) command-line tools for GitOps and workflow automation in Kubernetes environments.

## Description

Argo is a collection of open-source tools for Kubernetes that provide advanced deployment and workflow capabilities. This feature installs two key components:

**Argo CD**: A declarative, GitOps continuous delivery tool for Kubernetes that follows the GitOps pattern of using Git repositories as the source of truth for defining desired application state.

**Argo Workflows**: A container-native workflow engine for orchestrating parallel jobs on Kubernetes, designed for compute intensive and data processing tasks.

## Use Cases

- **GitOps Continuous Delivery**: Automated application deployment using Git as source of truth
- **Workflow Orchestration**: Complex data processing and ML pipelines
- **CI/CD Pipelines**: Kubernetes-native continuous integration workflows  
- **Batch Processing**: Large-scale data processing and analytics jobs
- **Multi-Environment Deployments**: Managing deployments across dev/staging/prod
- **Application Lifecycle Management**: Automated rollbacks, canary deployments

## Options

### `argocd` (boolean)
Install Argo CD CLI for GitOps continuous delivery.

- **Default**: `true`
- **Description**: Installs the `argocd` command-line tool for managing Argo CD applications, repositories, and clusters

### `argo` (boolean)  
Install Argo Workflows CLI for container-native workflow engine.

- **Default**: `true`
- **Description**: Installs the `argo` command-line tool for managing workflows, templates, and workflow executions

## Basic Usage

### Install Both Tools (Default)

```json
{
  "features": {
    "ghcr.io/ruanzx/features/argo:latest": {}
  }
}
```

### Install Only Argo CD

```json
{
  "features": {
    "ghcr.io/ruanzx/features/argo:latest": {
      "argocd": true,
      "argo": false
    }
  }
}
```

### Install Only Argo Workflows

```json
{
  "features": {
    "ghcr.io/ruanzx/features/argo:latest": {
      "argocd": false,
      "argo": true
    }
  }
}
```

## Advanced Usage

### Complete GitOps Development Environment

```json
{
  "name": "GitOps Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/kubectl:1": {},
    "ghcr.io/devcontainers/features/helm:1": {},
    "ghcr.io/ruanzx/features/argo:latest": {
      "argocd": true,
      "argo": true
    },
    "ghcr.io/ruanzx/features/yq:latest": {},
    "ghcr.io/devcontainers/features/git:1": {}
  }
}
```

### Data Processing Pipeline Environment

```json
{
  "name": "Data Pipeline Development", 
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/kubectl:1": {},
    "ghcr.io/ruanzx/features/argo:latest": {
      "argocd": false,
      "argo": true
    },
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,jq"
    }
  }
}
```

### Full Kubernetes Development Stack

```json
{
  "name": "Kubernetes Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/kubectl:1": {},
    "ghcr.io/devcontainers/features/helm:1": {},
    "ghcr.io/ruanzx/features/k9s:latest": {},
    "ghcr.io/ruanzx/features/argo:latest": {},
    "ghcr.io/ruanzx/features/skaffold:latest": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  }
}
```

### CI/CD Pipeline Development

```json
{
  "name": "CI/CD Pipeline Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu", 
  "features": {
    "ghcr.io/devcontainers/features/kubectl:1": {},
    "ghcr.io/ruanzx/features/argo:latest": {},
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,jq,yq"
    }
  }
}
```

## Command Line Usage

### Argo CD CLI Commands

The Argo CD CLI provides comprehensive application management capabilities:

#### Basic Commands

```bash
# Check version
argocd version

# Login to Argo CD server
argocd login <ARGOCD_SERVER>

# List applications
argocd app list

# Get application details
argocd app get <APP_NAME>

# Sync application
argocd app sync <APP_NAME>
```

#### Application Management

```bash
# Create application from Git repository
argocd app create my-app \
  --repo https://github.com/user/repo \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Set application to auto-sync
argocd app set my-app --sync-policy automated

# Delete application
argocd app delete my-app

# View application tree
argocd app tree my-app

# View application logs
argocd app logs my-app
```

#### Repository Management

```bash
# Add Git repository
argocd repo add https://github.com/user/repo

# List repositories
argocd repo list

# Remove repository
argocd repo rm https://github.com/user/repo
```

#### Cluster Management

```bash
# Add cluster
argocd cluster add <CONTEXT_NAME>

# List clusters
argocd cluster list

# Remove cluster
argocd cluster rm <CLUSTER_URL>
```

### Argo Workflows CLI Commands

The Argo Workflows CLI manages workflow definitions and executions:

#### Basic Commands

```bash
# Check version
argo version

# List workflows
argo list

# Submit workflow
argo submit workflow.yaml

# Get workflow status
argo get <WORKFLOW_NAME>

# View workflow logs
argo logs <WORKFLOW_NAME>
```

#### Workflow Management

```bash
# Submit workflow with parameters
argo submit workflow.yaml -p param1=value1

# Delete workflow
argo delete <WORKFLOW_NAME>

# Stop running workflow
argo stop <WORKFLOW_NAME>

# Retry failed workflow
argo retry <WORKFLOW_NAME>

# Watch workflow in real-time
argo watch <WORKFLOW_NAME>
```

#### Template Management

```bash
# List workflow templates
argo template list

# Create workflow from template
argo submit --from wftmpl/<TEMPLATE_NAME>

# Delete workflow template
argo template delete <TEMPLATE_NAME>
```

#### Workflow Archives

```bash
# List archived workflows
argo archive list

# Get archived workflow
argo archive get <WORKFLOW_UID>

# Delete archived workflow
argo archive delete <WORKFLOW_UID>
```

## Configuration Examples

### Argo CD Application Manifest

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/repo
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Argo Workflows Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  entrypoint: whalesay
  templates:
  - name: whalesay
    container:
      image: docker/whalesay:latest
      command: [cowsay]
      args: ["hello world"]
```

### Data Processing Workflow

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: data-pipeline-
spec:
  entrypoint: data-pipeline
  templates:
  - name: data-pipeline
    dag:
      tasks:
      - name: extract
        template: extract-data
      - name: transform
        template: transform-data
        dependencies: [extract]
      - name: load
        template: load-data
        dependencies: [transform]
  
  - name: extract-data
    container:
      image: python:3.9
      command: [python]
      args: ["/scripts/extract.py"]
  
  - name: transform-data
    container:
      image: python:3.9
      command: [python] 
      args: ["/scripts/transform.py"]
  
  - name: load-data
    container:
      image: python:3.9
      command: [python]
      args: ["/scripts/load.py"]
```

## Supported Platforms

- **Linux x86_64**: Full support for both Argo CD and Argo Workflows
- **Linux ARM64**: Full support for ARM-based systems

## Common Workflows

### GitOps Application Deployment

```bash
# 1. Login to Argo CD
argocd login argocd.example.com

# 2. Add Git repository
argocd repo add https://github.com/user/k8s-manifests

# 3. Create application
argocd app create my-app \
  --repo https://github.com/user/k8s-manifests \
  --path overlays/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production

# 4. Enable auto-sync
argocd app set my-app --sync-policy automated

# 5. Monitor deployment
argocd app get my-app
argocd app logs my-app
```

### Data Pipeline Execution

```bash
# 1. Submit data processing workflow
argo submit data-pipeline.yaml \
  --parameter input-path=/data/raw \
  --parameter output-path=/data/processed

# 2. Monitor workflow progress
argo watch data-pipeline-xxxxx

# 3. View logs from specific step
argo logs data-pipeline-xxxxx -c transform

# 4. Check final status
argo get data-pipeline-xxxxx
```

### Multi-Environment Deployment

```bash
# Deploy to staging
argocd app create staging-app \
  --repo https://github.com/user/app \
  --path manifests/staging \
  --dest-namespace staging

# Wait for staging validation
argocd app wait staging-app --health

# Promote to production
argocd app create prod-app \
  --repo https://github.com/user/app \
  --path manifests/production \
  --dest-namespace production
```

## Integration Examples

### With Helm Charts

```bash
# Argo CD with Helm
argocd app create helm-app \
  --repo https://github.com/user/helm-charts \
  --path charts/my-app \
  --helm-set image.tag=v1.2.3 \
  --dest-namespace default

# Argo Workflows with Helm rendering
argo submit --from wftmpl/helm-deploy \
  --parameter chart-version=1.0.0 \
  --parameter values-file=production.yaml
```

### With Kustomize

```bash
# Argo CD with Kustomize
argocd app create kustomize-app \
  --repo https://github.com/user/k8s-config \
  --path overlays/production \
  --dest-namespace production
```

### CI/CD Integration

```yaml
# GitHub Actions workflow
name: Deploy with Argo
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Install Argo CD CLI
      run: |
        curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        chmod +x argocd
        sudo mv argocd /usr/local/bin/
    
    - name: Sync application
      run: |
        argocd login ${{ secrets.ARGOCD_SERVER }} --username ${{ secrets.ARGOCD_USER }} --password ${{ secrets.ARGOCD_PASSWORD }}
        argocd app sync my-app
```

## Environment Variables

### Argo CD Configuration

```bash
# Server configuration
export ARGOCD_SERVER=argocd.example.com
export ARGOCD_AUTH_TOKEN=your-auth-token

# Skip TLS verification (for development)
export ARGOCD_OPTS="--insecure"

# Default repository
export ARGOCD_REPO_DEFAULT=https://github.com/user/k8s-manifests
```

### Argo Workflows Configuration

```bash
# Namespace configuration
export ARGO_NAMESPACE=argo

# Server configuration  
export ARGO_SERVER=argo-server.argo.svc.cluster.local:2746
export ARGO_TOKEN=your-auth-token

# Default workflow parameters
export ARGO_WORKFLOW_DEFAULT_IMAGE=python:3.9
```

## Authentication Setup

### Argo CD Authentication

```bash
# Username/password login
argocd login argocd.example.com --username admin

# Token-based authentication
argocd login argocd.example.com --auth-token $ARGOCD_TOKEN

# SSO login
argocd login argocd.example.com --sso

# Configure CLI permanently
argocd login argocd.example.com --username admin --password $PASSWORD
```

### Argo Workflows Authentication

```bash
# Service account token
argo auth token

# Login with service account
kubectl create token argo -n argo | argo auth login

# Configure server endpoint
argo server-config set-server argo-server.argo.svc.cluster.local:2746
```

## Verification

After installation, verify both tools are working correctly:

```bash
# Check installations
argocd version --client
argo version --short

# Test basic functionality
argocd app list --server-side-list
argo list

# Verify help commands work
argocd --help
argo --help
```

## Troubleshooting

### Installation Issues

**Problem**: Installation fails with download errors
**Solution**: Check internet connectivity and GitHub access:
```bash
curl -I https://github.com/argoproj/argo-cd/releases/latest
curl -I https://github.com/argoproj/argo-workflows/releases/latest
```

**Problem**: Binary not found after installation
**Solution**: Check PATH and verify installation:
```bash
which argocd
which argo
echo $PATH
ls -la /usr/local/bin/argo*
```

**Problem**: Permission denied errors
**Solution**: Ensure proper file permissions:
```bash
sudo chmod +x /usr/local/bin/argocd
sudo chmod +x /usr/local/bin/argo
```

### Argo CD Issues

**Problem**: Cannot connect to Argo CD server
**Solution**: Check server accessibility and credentials:
```bash
# Test connectivity
curl -k https://argocd.example.com

# Verify credentials
argocd login argocd.example.com --username admin --password $PASSWORD

# Check certificate issues
argocd login argocd.example.com --insecure
```

**Problem**: Application sync failures
**Solution**: Check repository access and permissions:
```bash
# Verify repository connectivity
argocd repo list

# Check application status
argocd app get my-app

# View detailed error logs
argocd app logs my-app --tail 50
```

**Problem**: RBAC permission errors
**Solution**: Verify user permissions and project access:
```bash
# Check user info
argocd account get

# List available projects
argocd proj list

# Verify cluster access
argocd cluster list
```

### Argo Workflows Issues

**Problem**: Workflow submission failures
**Solution**: Check workflow syntax and permissions:
```bash
# Validate workflow syntax
argo lint workflow.yaml

# Check service account permissions
kubectl get serviceaccount argo -n argo

# Verify workflow controller is running
kubectl get pods -n argo -l app=workflow-controller
```

**Problem**: Workflow stuck in pending state
**Solution**: Check resource availability and node selectors:
```bash
# Check workflow status
argo get workflow-name -o yaml

# View workflow events
kubectl describe workflow workflow-name

# Check cluster resources
kubectl top nodes
kubectl get pods --all-namespaces | grep Pending
```

**Problem**: Cannot access workflow logs
**Solution**: Check pod status and log retention:
```bash
# Check pod status
kubectl get pods -l workflows.argoproj.io/workflow=workflow-name

# View pod logs directly
kubectl logs pod-name

# Check workflow controller logs
kubectl logs -n argo -l app=workflow-controller
```

### Network and Connectivity Issues

**Problem**: Connection timeouts
**Solution**: Check network policies and firewall settings:
```bash
# Test cluster connectivity
kubectl cluster-info

# Check service endpoints
kubectl get endpoints -n argo
kubectl get endpoints -n argocd

# Verify DNS resolution
nslookup argo-server.argo.svc.cluster.local
```

### Performance Issues

**Problem**: Slow workflow execution
**Solution**: Check resource limits and cluster capacity:
```bash
# Check workflow resource usage
argo top workflow-name

# Monitor cluster resources
kubectl top nodes
kubectl top pods

# Review workflow template resource requests
argo template get template-name -o yaml
```

## Best Practices

### Argo CD Best Practices

1. **Repository Organization**: Structure Git repositories with clear environments and applications
2. **Application of Applications**: Use the app-of-apps pattern for managing multiple applications
3. **Resource Hooks**: Implement pre-sync and post-sync hooks for complex deployments
4. **Health Checks**: Define custom health checks for applications
5. **RBAC**: Implement proper role-based access control

### Argo Workflows Best Practices

1. **Resource Management**: Always set resource requests and limits
2. **Workflow Templates**: Use reusable workflow templates for common patterns
3. **Parameter Management**: Use parameters for workflow flexibility
4. **Error Handling**: Implement proper retry and failure handling
5. **Data Management**: Use artifacts for data passing between steps

## Related Features

- **[kubectl](https://github.com/devcontainers/features/tree/main/src/kubectl)**: Kubernetes command-line tool
- **[Helm](https://github.com/devcontainers/features/tree/main/src/helm)**: Kubernetes package manager
- **[k9s](../k9s)**: Kubernetes cluster management
- **[Skaffold](../skaffold)**: Kubernetes development workflow
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Required dependency

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature installs Argo tools which are licensed under the [Apache License 2.0](https://github.com/argoproj/argo-workflows/blob/master/LICENSE).

---

**Note**: Argo CD and Argo Workflows are actively developed projects. For the latest information about features and compatibility, visit the [Argo Project website](https://argoproj.github.io/) and their respective GitHub repositories.
