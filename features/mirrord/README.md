# mirrord DevContainer Feature

This feature installs [mirrord](https://github.com/metalbear-co/mirrord), an open-source tool that lets you easily mirror traffic from your Kubernetes cluster to your development environment. It enables testing code changes in a real environment without deploying to the cluster.

## Usage

Reference this feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ruanzx/features/mirrord:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | Version of mirrord to install. Use 'latest' for the most recent release or specify a version like '3.161.0' |
| `sha256` | string | `"automatic"` | SHA256 checksum for verification. Use 'automatic' to download checksums, 'dev-mode' to skip verification, or provide a specific checksum |

## Examples

### Latest Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/mirrord:latest": {}
    }
}
```

### Specific Version

```json
{
    "features": {
        "ghcr.io/ruanzx/features/mirrord:latest": {
            "version": "3.161.0"
        }
    }
}
```

### Skip Checksum Verification

```json
{
    "features": {
        "ghcr.io/ruanzx/features/mirrord:latest": {
            "version": "3.161.0",
            "sha256": "dev-mode"
        }
    }
}
```

### Combined with Kubernetes Tools

```json
{
    "features": {
        "ghcr.io/ruanzx/features/mirrord:latest": {},
        "ghcr.io/ruanzx/features/kubectl:latest": {},
        "ghcr.io/ruanzx/features/helm:latest": {},
        "ghcr.io/devcontainers/features/docker-in-docker:latest": {}
    }
}
```

## What's Installed

This feature installs:
- **mirrord CLI**: Tool for mirroring Kubernetes traffic to your local development environment

## Prerequisites

To use mirrord effectively, you need:
- A Kubernetes cluster with network policies that allow mirroring
- kubectl configured to access your cluster
- Appropriate RBAC permissions to create pods and read services
- Your application should be running in the target cluster

## Verification

After installation, you can verify mirrord is working:

```bash
# Check version
mirrord --version

# Get help
mirrord --help

# Check if mirrord can connect to your cluster (requires kubectl access)
mirrord ls

# Run a simple mirror test (replace with your pod name)
mirrord exec --target pod/my-app-pod -- echo "Hello from mirrored environment"
```

## Use Cases

### Local Development Against Production Data
- Test your local code changes against real production traffic
- Debug issues that only occur with real user data
- Validate API changes with actual client requests

### CI/CD Pipeline Testing
- Run integration tests against live environments
- Validate deployments before they go live
- Test canary deployments with real traffic

### Microservices Development
- Develop one service while using real versions of others
- Test service-to-service communication patterns
- Debug complex distributed system interactions

## Common Commands

### Basic Mirroring

```bash
# List available targets in your cluster
mirrord ls

# Mirror traffic from a pod to your local process
mirrord exec --target pod/my-app-pod -- python app.py

# Mirror traffic from a deployment
mirrord exec --target deployment/my-app -- python app.py

# Mirror traffic from a service
mirrord exec --target service/my-service -- python app.py
```

### Advanced Options

```bash
# Mirror only specific ports
mirrord exec --target pod/my-app-pod --override-ports 8080,9090 -- python app.py

# Mirror with specific namespace
mirrord exec --target pod/my-app-pod --target-namespace production -- python app.py

# Mirror without stealing traffic (read-only mode)
mirrord exec --target pod/my-app-pod --no-steal -- python app.py

# Mirror with custom configuration file
mirrord exec --config-file mirrord.toml --target pod/my-app-pod -- python app.py
```

### Configuration File Usage

Create a `mirrord.toml` configuration file:

```toml
# mirrord.toml
[target]
path = "pod/my-app-pod"
namespace = "default"

[feature]
network = true
fs = "read"
env = true

[network]
incoming = "steal"
outgoing = true

[fs]
mode = "read"
read_write = ["."]
read_only = ["/etc", "/var"]
```

Then use it:

```bash
mirrord exec --config-file mirrord.toml -- python app.py
```

### Language-Specific Examples

#### Python
```bash
# Run a Python application with mirrord
mirrord exec --target pod/python-app -- python main.py

# Run with pip install in mirrored environment
mirrord exec --target pod/python-app -- pip install -r requirements.txt && python main.py
```

#### Node.js
```bash
# Run a Node.js application with mirrord
mirrord exec --target pod/node-app -- node index.js

# Run with npm in mirrored environment
mirrord exec --target pod/node-app -- npm start
```

#### Go
```bash
# Run a Go application with mirrord
mirrord exec --target pod/go-app -- go run main.go

# Build and run Go application
mirrord exec --target pod/go-app -- sh -c "go build -o app && ./app"
```

#### Java
```bash
# Run a Java application with mirrord
mirrord exec --target pod/java-app -- java -jar app.jar

# Run with Maven
mirrord exec --target pod/java-app -- mvn spring-boot:run
```

### VS Code Integration

Create a `.vscode/launch.json` for debugging with mirrord:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: mirrord",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/main.py",
            "console": "integratedTerminal",
            "env": {
                "MIRRORD_TARGET": "pod/my-app-pod",
                "MIRRORD_NAMESPACE": "default"
            },
            "preLaunchTask": "mirrord-setup"
        }
    ]
}
```

Create a `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "mirrord-setup",
            "type": "shell",
            "command": "mirrord",
            "args": [
                "exec",
                "--target",
                "${env:MIRRORD_TARGET}",
                "--target-namespace",
                "${env:MIRRORD_NAMESPACE}",
                "--",
                "echo",
                "mirrord setup complete"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
```

## Integration Examples

### Docker Compose with mirrord

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    environment:
      - MIRRORD_TARGET=pod/my-app-pod
      - MIRRORD_NAMESPACE=production
    volumes:
      - ~/.kube:/root/.kube:ro
    command: ["mirrord", "exec", "--target", "${MIRRORD_TARGET}", "--target-namespace", "${MIRRORD_NAMESPACE}", "--", "python", "app.py"]
```

### GitHub Actions Integration

```yaml
name: Test with mirrord
on:
  pull_request:
    branches: [main]

jobs:
  test-with-mirrord:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'
      
      - name: Install mirrord
        run: |
          curl -fsSL https://github.com/metalbear-co/mirrord/raw/latest/scripts/install.sh | bash
          
      - name: Setup kubeconfig
        run: |
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
      
      - name: Test application with mirrord
        run: |
          mirrord exec --target pod/test-app --target-namespace testing -- python -m pytest tests/
```

### Makefile Integration

```makefile
# Makefile
.PHONY: dev-mirror
dev-mirror:
	@echo "Starting development with mirrored traffic..."
	mirrord exec --target pod/$(APP_POD) --target-namespace $(NAMESPACE) -- $(DEV_COMMAND)

.PHONY: test-mirror
test-mirror:
	@echo "Running tests with mirrored environment..."
	mirrord exec --target pod/$(TEST_POD) --target-namespace $(TEST_NAMESPACE) -- python -m pytest

.PHONY: debug-mirror
debug-mirror:
	@echo "Starting debug session with mirrored traffic..."
	mirrord exec --target pod/$(APP_POD) --target-namespace $(NAMESPACE) -- python -m debugpy --listen 0.0.0.0:5678 --wait-for-client app.py

# Usage:
# make dev-mirror APP_POD=my-app-pod NAMESPACE=production DEV_COMMAND="python app.py"
# make test-mirror TEST_POD=test-app TEST_NAMESPACE=testing
```

### Kubernetes Job for Testing

```yaml
# mirrord-test-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mirrord-test
  namespace: testing
spec:
  template:
    spec:
      containers:
      - name: test-runner
        image: my-test-image:latest
        command: ["mirrord"]
        args: [
          "exec",
          "--target", "pod/production-app",
          "--target-namespace", "production",
          "--",
          "python", "-m", "pytest", "tests/"
        ]
        env:
        - name: KUBECONFIG
          value: "/etc/kubeconfig/config"
        volumeMounts:
        - name: kubeconfig
          mountPath: /etc/kubeconfig
          readOnly: true
      restartPolicy: Never
      volumes:
      - name: kubeconfig
        secret:
          secretName: kubeconfig-secret
  backoffLimit: 4
```

## Configuration Options

### Network Mirroring

```toml
[network]
# How to handle incoming traffic
incoming = "steal"  # "steal", "mirror", or false
# Whether to mirror outgoing traffic
outgoing = true
# Override specific ports
override_ports = [8080, 9090]
```

### File System Mirroring

```toml
[fs]
# File system mirroring mode
mode = "read"  # "read", "write", or false
# Read-write directories
read_write = ["."]
# Read-only directories
read_only = ["/etc", "/var", "/tmp"]
```

### Environment Variables

```toml
[feature]
# Mirror environment variables
env = true
# Exclude specific environment variables
env_exclude = ["SECRET_KEY", "DATABASE_PASSWORD"]
```

## Troubleshooting

### Connection Issues

If mirrord can't connect to your cluster:

```bash
# Check kubectl connectivity
kubectl get nodes

# Verify RBAC permissions
kubectl auth can-i create pods
kubectl auth can-i get pods

# Check if target exists
mirrord ls
kubectl get pods -A | grep my-app
```

### Permission Errors

If you get permission denied errors:

```bash
# Check your kubeconfig
kubectl config current-context
kubectl config view

# Verify service account permissions
kubectl auth can-i "*" "*" --as=system:serviceaccount:default:default

# Check if mirrord operator is installed (if using operator mode)
kubectl get pods -n mirrord
```

### Network Issues

If traffic isn't being mirrored correctly:

```bash
# Check target pod status
kubectl describe pod my-app-pod

# Verify network policies
kubectl get networkpolicies

# Check if ports are being used
netstat -tulpn | grep 8080

# Test with read-only mode first
mirrord exec --target pod/my-app-pod --no-steal -- python app.py
```

### Performance Issues

If mirroring is slow:

```toml
# Optimize configuration
[network]
incoming = "mirror"  # Use mirror instead of steal
outgoing = false     # Disable outgoing if not needed

[fs]
mode = false         # Disable filesystem mirroring if not needed
```

### Version Compatibility

Check compatibility between mirrord versions:

```bash
# Check mirrord version
mirrord --version

# Check cluster version
kubectl version --short

# Check if operator version matches CLI
kubectl get pods -n mirrord -o jsonpath='{.items[0].spec.containers[0].image}'
```

## Platform Support

- ✅ Linux x86_64 (amd64)
- ✅ Linux ARM64 (aarch64)
- ❌ Windows (not supported in DevContainers)
- ❌ macOS (not supported in DevContainers)

## Security Considerations

- **RBAC Permissions**: Ensure proper Kubernetes RBAC is configured
- **Network Policies**: Consider impact on existing network policies
- **Sensitive Data**: Be careful when mirroring production traffic with sensitive data
- **Resource Usage**: Monitor resource consumption in target pods
- **Audit Logging**: Enable audit logging for mirrord operations

## Best Practices

- **Start with Read-Only**: Begin with `--no-steal` to understand traffic patterns
- **Use Staging First**: Test mirroring setup in staging before production
- **Monitor Resources**: Watch CPU and memory usage during mirroring
- **Selective Mirroring**: Only mirror the traffic you need for development
- **Configuration Files**: Use configuration files for complex setups
- **Version Pinning**: Pin mirrord versions for consistent behavior

## Performance Considerations

- **Target Selection**: Choose specific pods rather than broad deployments
- **Port Filtering**: Only mirror necessary ports to reduce overhead
- **File System**: Disable filesystem mirroring if not needed
- **Environment Variables**: Limit environment variable mirroring scope

## Related Features

- **kubectl**: Required for cluster access and pod management
- **Helm**: For installing applications to mirror from
- **Docker-in-Docker**: For building container images
- **Common Utils**: Required base utilities

## Integration with Other Tools

### Telepresence Comparison
- **mirrord**: Lightweight, focused on traffic mirroring
- **Telepresence**: Full environment replacement, more complex setup

### Skaffold Integration
```yaml
# skaffold.yaml
apiVersion: skaffold/v2beta24
kind: Config
build:
  artifacts:
  - image: my-app
deploy:
  kubectl:
    manifests:
    - k8s/*.yaml
profiles:
- name: mirrord-dev
  activation:
  - env: MIRRORD_DEV=true
  deploy:
    kubectl:
      manifests:
      - k8s/dev/*.yaml
```

## Additional Resources

- [mirrord Documentation](https://mirrord.dev/docs/)
- [mirrord GitHub Repository](https://github.com/metalbear-co/mirrord)
- [mirrord VS Code Extension](https://marketplace.visualstudio.com/items?itemName=MetalBear.mirrord)
- [mirrord Configuration Reference](https://mirrord.dev/docs/reference/configuration/)
- [Kubernetes Traffic Mirroring Patterns](https://kubernetes.io/docs/concepts/services-networking/)
- [Local Development Best Practices](https://mirrord.dev/docs/guides/local-development/)
- [Production Debugging Guide](https://mirrord.dev/docs/guides/production-debugging/)
