# Python Pip Packages Feature

Installs Python packages using [pip](https://pip.pypa.io/en/stable/), the standard package manager for Python.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {}
  }
}
```

## Options

| Option        | Type    | Default | Description                                                              |
| ------------- | ------- | ------- | ------------------------------------------------------------------------ |
| `packages`    | string  | `""`    | Comma-separated list of Python package names to install                 |
| `upgrade`     | boolean | `false` | Upgrade packages if they are already installed                          |
| `requirements`| string  | `""`    | Path to requirements.txt file to install packages from                  |
| `extraArgs`   | string  | `""`    | Additional arguments to pass to pip install command                     |

## Examples

### Install specific packages

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "packages": "requests,numpy,pandas"
    }
  }
}
```

### Install packages with version specifiers

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "packages": "django>=4.0,requests==2.28.1,numpy<2.0"
    }
  }
}
```

### Install from requirements file

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "requirements": "./requirements.txt"
    }
  }
}
```

### Install with upgrade and extra arguments

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "packages": "tensorflow,scikit-learn",
      "upgrade": true,
      "extraArgs": "--no-cache-dir --user"
    }
  }
}
```

### Combined usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "packages": "flask,gunicorn",
      "requirements": "./requirements-dev.txt",
      "upgrade": true
    }
  }
}
```

## Package Name Format

The feature supports various Python package name formats:

- **Simple names**: `requests`, `numpy`, `pandas`
- **Version specifiers**: `django>=4.0`, `requests==2.28.1`, `numpy<2.0`
- **Package extras**: `flask[async]`, `sqlalchemy[postgresql]`
- **Complex specifiers**: `tensorflow>=2.0,<3.0`

## Requirements File Support

You can specify a path to a requirements.txt file using the `requirements` option. The file should contain one package per line:

```txt
# requirements.txt
requests>=2.25.0
numpy>=1.20.0
pandas>=1.3.0
matplotlib
jupyter
```

## Prerequisites

This feature requires Python 3 and pip to be installed. It's designed to work with the official Python DevContainer feature:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python": {},
    "ghcr.io/ruanzx/devcontainer-features/pip": {
      "packages": "your-packages-here"
    }
  }
}
```

## Container Environment

This feature is optimized for container environments and automatically uses the `--break-system-packages` flag to handle externally-managed Python environments commonly found in modern container images.

## Verification

After installation, you can verify the setup using the included verification script:

```bash
verify-pip-packages
```

Or check manually:

```bash
pip list
python -c "import requests; print('✅ requests imported successfully')"
```

## Supported Platforms

- Linux (all architectures)
- Works with Python 3.6+
- Compatible with most Linux distributions

## Error Handling

The feature includes comprehensive error handling:

- Validates package names before installation
- Reports failed installations clearly
- Continues installing other packages if one fails
- Provides detailed logs for troubleshooting

## License

This feature installs Python packages from [PyPI](https://pypi.org/), which are distributed under their respective licenses. Check individual package licenses for compliance requirements.
