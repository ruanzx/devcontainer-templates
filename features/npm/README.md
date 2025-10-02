# npm Global Package Installer

This feature installs global npm packages in your development container, providing easy access to Node.js command-line tools and utilities.

## Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,nodemon,@angular/cli"
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `packages` | string | `""` | Comma-separated list of global npm packages to install |
| `registry` | string | `""` | Custom npm registry URL (optional, defaults to npmjs.org) |
| `installLatest` | boolean | `true` | Install latest versions of packages (append @latest to package names) |
| `updateNpm` | boolean | `false` | Update npm to the latest version before installing packages |

## Examples

### Basic Package Installation

```json
{
  "features": {
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,eslint,prettier"
    }
  }
}
```

### With Specific Versions

```json
{
  "features": {
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript@4.9.5,@angular/cli@15.0.0",
      "installLatest": false
    }
  }
}
```

### With Custom Registry

```json
{
  "features": {
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "my-company-tool,@my-org/utils",
      "registry": "https://npm.company.com"
    }
  }
}
```

### Update npm First

```json
{
  "features": {
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,nodemon",
      "updateNpm": true
    }
  }
}
```

## Popular Package Categories

### TypeScript Development
```json
{
  "packages": "typescript,ts-node,nodemon,@types/node"
}
```

### React Development
```json
{
  "packages": "create-react-app,@storybook/cli,react-scripts"
}
```

### Angular Development
```json
{
  "packages": "@angular/cli,@angular/cdk,ng-packagr"
}
```

### Vue.js Development
```json
{
  "packages": "@vue/cli,@vue/cli-service,vue-tsc"
}
```

### Linting and Formatting
```json
{
  "packages": "eslint,prettier,stylelint,commitizen"
}
```

### Build Tools
```json
{
  "packages": "webpack,rollup,vite,parcel"
}
```

### Testing Tools
```json
{
  "packages": "jest,mocha,cypress,playwright"
}
```

### Development Utilities
```json
{
  "packages": "nodemon,concurrently,cross-env,rimraf"
}
```

### Documentation Tools
```json
{
  "packages": "typedoc,jsdoc,docsify-cli,gitbook-cli"
}
```

## Requirements

- **Node.js**: This feature requires Node.js to be installed first
- **npm**: Comes bundled with Node.js

Make sure to include the Node.js feature in your devcontainer:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:latest": {},
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,eslint"
    }
  }
}
```

## Package Name Format

Package names support the standard npm format:

- **Simple package**: `typescript`
- **Scoped package**: `@angular/cli`
- **Specific version**: `typescript@4.9.5`
- **Version range**: `typescript@^4.0.0`
- **Tag**: `typescript@beta`

## Verification

After installation, verify your packages:

```bash
# List all global packages
npm list -g --depth=0

# Check specific package
npm list -g typescript

# Verify CLI tool is available
tsc --version
```

## Troubleshooting

### Node.js Not Found
If you get "Node.js is not installed" error:
1. Add the Node.js feature to your devcontainer.json
2. Rebuild your container

### Permission Issues
If you encounter permission errors:
- The feature runs with appropriate permissions during container build
- Avoid running `sudo npm install -g` manually

### Package Installation Fails
If package installation fails:
1. Check package name spelling
2. Verify the package exists on npm registry
3. Check network connectivity
4. Try installing without version constraints first

### Custom Registry Issues
If using a custom registry:
1. Ensure the registry URL is correct
2. Check authentication if required
3. Verify network access to the registry

## Integration Examples

### Full Stack Development Environment

```json
{
  "name": "Full Stack Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/devcontainers/features/node:latest": {
      "version": "18"
    },
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,@angular/cli,express-generator,nodemon,eslint,prettier"
    }
  }
}
```

### TypeScript Microservices

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:latest": {},
    "ghcr.io/ruanzx/features/npm:latest": {
      "packages": "typescript,ts-node,nodemon,@types/node,@types/express,prisma"
    }
  }
}
```

## Notes

- Global packages are installed for all users in the container
- The feature respects existing npm configuration
- Package versions are resolved at container build time
- Use specific versions for reproducible builds
- The feature installs packages globally (`-g` flag)
- CLI tools from installed packages are immediately available in PATH

## Related Features

- [Node.js](https://github.com/devcontainers/features/tree/main/src/node): Required dependency for npm
- [Python pip](../pip/): Similar package management for Python
- [APT](../apt/): System-level package management