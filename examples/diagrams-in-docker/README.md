# Diagrams Example

This example demonstrates how to use the Diagrams feature in a DevContainer.

## Overview

The [Diagrams](https://github.com/mingrammer/diagrams) library allows you to create cloud system architecture diagrams programmatically using Python.

## Usage

1. Open this folder in VS Code with Dev Containers extension
2. Reopen in container when prompted
3. The `diagrams` command will be available

## Creating Diagrams

Create a Python script that uses the Diagrams library:

```python
# example_diagram.py
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("Web Service", show=False, direction="TB"):
    lb = ELB("Load Balancer")
    web = EC2("Web Server")
    db = RDS("Database")

    lb >> web >> db
```

Run the script:

```bash
diagrams example_diagram.py
```

## Output

The diagram will be generated as `example_diagram.png` in the current directory.

## Customizing Output

Specify a custom output directory:

```bash
diagrams -o ./diagrams example_diagram.py
```

## Available Resources

The Diagrams library supports many cloud providers and services:

- AWS
- Azure
- GCP
- Kubernetes
- On-premises
- SaaS providers

Check the [Diagrams documentation](https://diagrams.mingrammer.com/) for the complete list of available icons and examples.

## Troubleshooting

If you encounter issues:

1. Ensure Docker is running: `docker info`
2. Check that the diagrams command is available: `diagrams --help`
3. Verify your Python script syntax
4. Make sure the Diagrams library is properly imported