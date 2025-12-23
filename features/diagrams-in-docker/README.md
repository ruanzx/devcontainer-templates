# Diagrams (in Docker) Feature

Installs a command-line wrapper for [Diagrams](https://github.com/mingrammer/diagrams), a Python library for creating cloud system architecture diagrams that runs in a Docker container. This feature makes it easy to generate diagrams from Python scripts directly from your dev container.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/diagrams-in-docker:1.0.0": {}
  }
}
```

## Options

| Option      | Type   | Default           | Description                                     |
| ----------- | ------ | ----------------- | ----------------------------------------------- |
| `version`   | string | `latest`          | Version tag of the Diagrams Docker image to use |
| `imageName` | string | `ruanzx/diagrams` | Docker image name for Diagrams                  |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/diagrams-in-docker:1.0.0": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/diagrams-in-docker:1.0.0": {
      "version": "1.2.3"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/diagrams-in-docker:1.0.0": {
      "imageName": "myorg/custom-diagrams",
      "version": "latest"
    }
  }
}
```

## Requirements

This feature requires Docker to be available. It should be installed after the `docker-outside-of-docker` feature:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/ruanzx/devcontainer-features/diagrams-in-docker:1.0.0": {}
  }
}
```

## Commands Available

After installation, the `diagrams` command is available to run Python scripts that use the Diagrams library:

### Basic Usage

```bash
# Run a Python script that creates diagrams
diagrams my_diagram.py
```

### Specify Output Directory

```bash
# Generate diagrams to a specific output directory
diagrams -o ./diagrams-output my_diagram.py
```

### Verbose Output

```bash
# Enable verbose logging
diagrams --verbose diagram.py
```

### Help

```bash
# Show help message
diagrams --help
```

## Command Options

| Option         | Alias | Description                             | Required |
| -------------- | ----- | --------------------------------------- | -------- |
| `--output DIR` | `-o`  | Output directory for generated diagrams | No       |
| `--verbose`    | `-v`  | Enable verbose logging                  | No       |
| `--help`       |       | Show help message                       | No       |

## Environment Variables

You can customize the Docker image used by setting environment variables:

```bash
# Use a different Docker image
export DIAGRAMS_IMAGE_NAME="myorg/custom-diagrams"
export DIAGRAMS_IMAGE_TAG="1.2.3"

diagrams my_diagram.py
```

## How It Works

1. The feature installs a wrapper script at `/usr/local/bin/diagrams`
2. When you run `diagrams`, it executes the Diagrams Docker container with appropriate volume mounts
3. The script automatically handles:
   - Path translation between dev container and host (when running in a dev container)
   - Volume mounting for input scripts and output directories
   - Docker image pulling (if not already present)
4. The generated diagram files are saved to your specified output path

## Dev Container Integration

When running inside a dev container, the wrapper automatically:
- Detects the dev container environment
- Translates container paths to host paths for Docker volume mounting
- Ensures proper file access between the dev container and the Diagrams Docker container

## Creating Diagrams

To create diagrams, write Python scripts that use the Diagrams library. Here's a simple example:

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("Web Service", show=False):
    ELB("lb") >> EC2("web") >> RDS("userdb")
```

Save this as `my_diagram.py` and run:

```bash
diagrams my_diagram.py
```

## Verification

After installation, verify that Diagrams is working:

```bash
# Check if diagrams command is available
which diagrams

# View help message
diagrams --help

# Test with a simple diagram script
cat > test_diagram.py << 'EOF'
from diagrams import Diagram
from diagrams.aws.compute import EC2

with Diagram("Test", show=False):
    EC2("test")
EOF

diagrams test_diagram.py
```

## Troubleshooting

### Docker Not Running

If you see "Docker is not running", ensure Docker is started:

```bash
docker info
```

### Image Not Found

If the Diagrams image is not found, it will be automatically pulled on first use. You can also pull it manually:

```bash
docker pull ruanzx/diagrams:latest
```

### Permission Issues

If you encounter permission issues, ensure your user has access to Docker:

```bash
docker ps
```

### Python Script Errors

Ensure your Python scripts are syntactically correct and use the Diagrams library properly. Check the [Diagrams documentation](https://diagrams.mingrammer.com/) for examples and API reference.

## License

This feature installs a wrapper for Diagrams. Check the [Diagrams project](https://github.com/mingrammer/diagrams) for its licensing information.