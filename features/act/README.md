# act

Installs [act](https://github.com/nektos/act), a tool that allows you to run GitHub Actions workflows locally without pushing to GitHub. Test your CI/CD pipelines locally before committing changes.

## Description

act is a command-line tool that brings the convenience of local testing to GitHub Actions workflows. It reads your GitHub Actions from `.github/workflows/` and determines the set of actions that need to be run, then uses Docker to run them locally in the same way they would run on GitHub.

**Key Features:**
- **Local Testing**: Run GitHub Actions workflows on your local machine
- **Fast Feedback**: Test workflows without committing and pushing to GitHub
- **Docker Integration**: Uses Docker to provide the same runtime environment as GitHub Actions
- **Event Simulation**: Simulate different GitHub events (push, pull_request, etc.)
- **Secret Management**: Support for local secrets and environment variables
- **Matrix Builds**: Support for matrix strategies and job dependencies

## Use Cases

- **CI/CD Development**: Test and debug GitHub Actions workflows locally
- **Fast Iteration**: Rapid testing of workflow changes without remote execution
- **Offline Development**: Work on workflows without internet connectivity
- **Cost Optimization**: Reduce GitHub Actions minutes usage during development
- **Learning**: Understand how GitHub Actions work by running them locally
- **Integration Testing**: Test complex workflows with multiple steps and dependencies

## Options

### `version` (string)
Specify the version of act to install.

- **Default**: `"latest"`
- **Example**: `"v0.2.80"`
- **Description**: Install a specific version or use "latest" for the most recent release

## Basic Usage

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/act:latest": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/act:latest": {
      "version": "v0.2.80"
    }
  }
}
```

## Advanced Usage

### Complete CI/CD Development Environment

```json
{
  "name": "CI/CD Development with act",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/ruanzx/features/act:latest": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,jq,zip,unzip"
    }
  },
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ]
}
```

### GitHub Actions Testing Environment

```json
{
  "name": "GitHub Actions Local Testing",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/ruanzx/features/act:latest": {},
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/devcontainers/features/git:1": {}
  }
}
```

### Multi-Language Development

```json
{
  "name": "Multi-Language CI Testing",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/ruanzx/features/act:latest": {},
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/devcontainers/features/go:1": {},
    "ghcr.io/ruanzx/features/bun:latest": {}
  }
}
```

### DevOps Toolchain Environment

```json
{
  "name": "DevOps Toolchain",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/ruanzx/features/act:latest": {},
    "ghcr.io/devcontainers/features/kubectl:1": {},
    "ghcr.io/devcontainers/features/helm:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {}
  }
}
```

## Command Line Usage

act provides comprehensive workflow testing capabilities:

### Basic Commands

```bash
# Check version
act --version

# Show help
act --help

# List available workflows
act --list

# Run default workflow (usually push event)
act

# Run specific event
act push
act pull_request
act release
```

### Event-Specific Execution

```bash
# Run push event workflow
act push

# Run pull request workflow
act pull_request

# Run workflow dispatch event
act workflow_dispatch

# Run scheduled workflow
act schedule

# Run release workflow
act release
```

### Advanced Options

```bash
# Dry run (show what would be executed)
act --dry-run

# Use specific workflow file
act -W .github/workflows/ci.yml

# Run specific job
act -j test

# Use custom event payload
act -e event.json

# Set environment variables
act -e EVENT_VAR=value

# Use secrets file
act --secret-file .secrets
```

### Docker Configuration

```bash
# Use specific Docker image for runner
act -P ubuntu-latest=ubuntu:20.04

# Use custom platform mapping
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Pull latest images
act --pull

# Use specific Docker network
act --network host

# Mount additional volumes
act --bind /host/path:/container/path
```

### Debugging and Verbose Output

```bash
# Verbose output
act -v

# Very verbose output
act -vv

# Reuse containers for faster iteration
act --reuse

# Keep containers after execution
act --no-cleanup

# Interactive debugging
act --interactive
```

## Configuration

### Platform Configuration

Create `.actrc` file in your project root or home directory:

```bash
# Use specific images for different platforms
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04
-P ubuntu-18.04=catthehacker/ubuntu:act-18.04
```

### Secrets Configuration

Create `.secrets` file (add to .gitignore):

```bash
GITHUB_TOKEN=your_personal_access_token
NPM_TOKEN=your_npm_token
DOCKER_PASSWORD=your_docker_password
API_KEY=your_api_key
```

### Environment Variables

Create `.env` file:

```bash
NODE_ENV=development
API_URL=http://localhost:3000
DEBUG=true
```

## Example Workflows

### Simple CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
```

Run locally:
```bash
act push
```

### Multi-Job Workflow

```yaml
# .github/workflows/build.yml
name: Build and Test
on: push

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run lint
  
  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
  
  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run build
```

Run locally:
```bash
act push -j test  # Run only test job
act push          # Run all jobs in dependency order
```

### Matrix Strategy Workflow

```yaml
# .github/workflows/matrix.yml
name: Matrix Build
on: push

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

Run locally:
```bash
act push  # Runs all matrix combinations
```

## Common Use Cases

### Testing Before Commit

```bash
# Test your changes locally before committing
git add .
act push  # Test the push workflow
git commit -m "Add new feature"
git push  # Now push with confidence
```

### Debugging Failed Workflows

```bash
# Run with verbose output to debug issues
act push -vv

# Keep containers for inspection
act push --no-cleanup

# Interactive debugging
act push --interactive
```

### Testing with Different Runners

```bash
# Test with different Ubuntu versions
act -P ubuntu-latest=ubuntu:20.04 push
act -P ubuntu-latest=ubuntu:22.04 push

# Use act-specific images with more tools
act -P ubuntu-latest=catthehacker/ubuntu:act-latest push
```

### Custom Event Testing

Create custom event file `event.json`:
```json
{
  "pull_request": {
    "number": 123,
    "head": {
      "ref": "feature-branch"
    },
    "base": {
      "ref": "main"
    }
  }
}
```

Run with custom event:
```bash
act pull_request -e event.json
```

### Secret Testing

```bash
# Test with secrets from file
act push --secret-file .secrets

# Test with inline secrets
act push -s GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# Test without secrets (use defaults)
act push --use-gitignore=false
```

## Docker Integration

### Required Docker Setup

act requires Docker to be running. In dev containers:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ]
}
```

### Performance Optimization

```bash
# Pre-pull commonly used images
docker pull catthehacker/ubuntu:act-latest
docker pull node:18
docker pull python:3.9

# Use faster image variants
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

### Image Recommendations

For better performance and compatibility, use act-specific images:

```bash
# In .actrc file
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04
-P ubuntu-18.04=catthehacker/ubuntu:act-18.04
-P windows-latest=catthehacker/windows:act-latest
```

## Supported Platforms

- **Linux x86_64**: Full support
- **Linux ARM64**: Full support for ARM-based systems

## Best Practices

### 1. Use Appropriate Images

```bash
# Use act-specific images for better compatibility
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Or configure in .actrc for persistent settings
echo "-P ubuntu-latest=catthehacker/ubuntu:act-latest" >> .actrc
```

### 2. Manage Secrets Securely

```bash
# Never commit .secrets file
echo ".secrets" >> .gitignore

# Use environment-specific secret files
act push --secret-file .secrets.dev
act push --secret-file .secrets.staging
```

### 3. Optimize for Speed

```bash
# Reuse containers during development
act push --reuse

# Use dry-run for quick validation
act push --dry-run

# Run specific jobs to save time
act push -j lint
```

### 4. Handle Dependencies

```bash
# Test job dependencies by running full workflow
act push  # Runs jobs in correct order

# Test individual jobs when dependencies allow
act push -j test  # Only if lint job passes
```

### 5. Local Development Workflow

```bash
# Create a development script
cat > test-local.sh << 'EOF'
#!/bin/bash
echo "Testing GitHub Actions locally..."
act push --reuse -j test
if [ $? -eq 0 ]; then
    echo "✅ All tests passed locally!"
else
    echo "❌ Tests failed locally"
    exit 1
fi
EOF
chmod +x test-local.sh
```

## Verification

After installation, verify act is working correctly:

```bash
# Check installation
act --version

# List available workflows
act --list

# Test basic functionality (dry run)
act --dry-run

# Test with a simple workflow
mkdir -p .github/workflows
cat > .github/workflows/test.yml << 'EOF'
name: Test
on: push
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello from act!"
EOF

# Run the test workflow
act push
```

## Troubleshooting

### Installation Issues

**Problem**: Installation fails with download errors
**Solution**: Check internet connectivity and GitHub access:
```bash
curl -I https://github.com/nektos/act/releases/latest
```

**Problem**: Binary not found after installation
**Solution**: Check PATH and verify installation:
```bash
which act
echo $PATH
ls -la /usr/local/bin/act
```

### Docker Issues

**Problem**: "Cannot connect to Docker daemon" error
**Solution**: Ensure Docker is running and accessible:
```bash
docker ps
sudo systemctl start docker  # On systemd systems
```

**Problem**: Permission denied accessing Docker
**Solution**: Add user to docker group or use sudo:
```bash
sudo usermod -aG docker $USER
# Or run with sudo
sudo act push
```

### Workflow Issues

**Problem**: "No workflows found" error
**Solution**: Check workflow file location and syntax:
```bash
# Verify workflow files exist
ls -la .github/workflows/

# Validate workflow syntax
act --list

# Use specific workflow file
act -W .github/workflows/ci.yml
```

**Problem**: Action not found errors
**Solution**: Ensure internet connectivity for action downloads:
```bash
# Test with simple built-in actions
act push --dry-run

# Use cached actions if available
act push --use-gitignore=false
```

**Problem**: Container startup failures
**Solution**: Try different base images:
```bash
# Use act-specific images
act -P ubuntu-latest=catthehacker/ubuntu:act-latest push

# Use official Ubuntu image
act -P ubuntu-latest=ubuntu:22.04 push

# Pull latest images
act --pull push
```

### Performance Issues

**Problem**: Slow execution times
**Solution**: Optimize Docker usage and caching:
```bash
# Pre-pull base images
docker pull catthehacker/ubuntu:act-latest

# Use container reuse
act push --reuse

# Run specific jobs only
act push -j test
```

**Problem**: Disk space issues
**Solution**: Clean up Docker resources:
```bash
# Clean up act containers
docker container prune

# Clean up unused images
docker image prune

# Remove all stopped containers
docker rm $(docker ps -aq)
```

### Secrets and Environment Issues

**Problem**: Secrets not available in workflow
**Solution**: Verify secret configuration:
```bash
# Check secrets file format
cat .secrets

# Test with inline secrets
act push -s GITHUB_TOKEN=test_token

# Use environment variables
export GITHUB_TOKEN=your_token
act push
```

**Problem**: Environment variables not set
**Solution**: Use proper environment configuration:
```bash
# Create .env file
echo "NODE_ENV=development" > .env

# Use act env flag
act push --env NODE_ENV=development

# Set in workflow file
act push -e NODE_ENV=test
```

## GitHub Actions Compatibility

### Supported Features

- ✅ Basic workflow syntax
- ✅ Job dependencies (needs)
- ✅ Matrix strategies
- ✅ Environment variables
- ✅ Secrets
- ✅ Most GitHub Actions from marketplace
- ✅ Custom Docker actions
- ✅ Conditional execution (if)

### Limitations

- ❌ GitHub-hosted runner specific features
- ❌ GitHub Apps authentication
- ❌ Some GitHub-specific contexts
- ❌ Workflow artifacts between jobs
- ❌ GitHub Packages authentication

### Workarounds

```bash
# For missing contexts, use environment variables
act push -e GITHUB_REPOSITORY=owner/repo

# For artifacts, use local file system
act push --bind ./artifacts:/github/workspace/artifacts

# For authentication, use personal access tokens
act push -s GITHUB_TOKEN=$GITHUB_TOKEN
```

## Related Features

- **[Docker-in-Docker](https://github.com/devcontainers/features/tree/main/src/docker-in-docker)**: Required for running act
- **[Git](https://github.com/devcontainers/features/tree/main/src/git)**: Version control for workflow files
- **[Node.js](https://github.com/devcontainers/features/tree/main/src/node)**: For JavaScript/TypeScript projects
- **[Python](https://github.com/devcontainers/features/tree/main/src/python)**: For Python projects
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Required dependency

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature installs act which is licensed under the [MIT License](https://github.com/nektos/act/blob/master/LICENSE).

---

**Note**: act is an active open-source project. For the latest information about features and compatibility, visit the [official repository](https://github.com/nektos/act) and [documentation](https://github.com/nektos/act#readme).
