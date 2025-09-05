
# Bun

Installs [Bun](https://github.com/oven-sh/bun), a fast all-in-one JavaScript runtime. Bundle, transpile, install and run JavaScript & TypeScript projects — all in Bun.

## Description

Bun is a fast JavaScript runtime built from scratch to serve the modern JavaScript ecosystem. It's designed as a drop-in replacement for Node.js with built-in bundling, transpilation, package management, and testing capabilities.

**Key Features:**
- **Fast Runtime**: Native performance with optimized JavaScript execution
- **Built-in Bundler**: No need for Webpack, Rollup, or other bundlers
- **TypeScript Support**: Run TypeScript directly without compilation
- **Package Manager**: Drop-in replacement for npm with faster installs
- **Testing Framework**: Built-in test runner with Jest-compatible APIs
- **Hot Reloading**: Fast development server with instant refresh

## Use Cases

- **Full-Stack Development**: Build modern web applications with JavaScript/TypeScript
- **Performance-Critical Applications**: High-performance JavaScript runtime
- **Package Management**: Fast dependency installation and management
- **Testing**: Unit and integration testing with built-in test runner
- **Build Tools**: Bundling and transpilation without complex toolchain setup
- **Server Development**: API servers and backend services

## Options

### `version` (string)
Specify the version of Bun to install.

- **Default**: `"latest"`
- **Example**: `"bun-v1.2.20"`
- **Description**: Install a specific version or use "latest" for the most recent release

**Note**: Version format should include the "bun-" prefix when specifying exact versions (e.g., "bun-v1.2.20").

## Basic Usage

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {
      "version": "bun-v1.2.20"
    }
  }
}
```

## Advanced Usage

### Full-Stack JavaScript Development

```json
{
  "name": "Full-Stack Bun Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,git,build-essential"
    }
  },
  "postCreateCommand": "bun install"
}
```

### React/Next.js Development

```json
{
  "name": "React Development with Bun",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {},
    "ghcr.io/devcontainers/features/git:1": {}
  },
  "postCreateCommand": [
    "bun create react my-app",
    "cd my-app && bun install"
  ]
}
```

### API Development Environment

```json
{
  "name": "Bun API Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,postgresql-client"
    }
  },
  "forwardPorts": [3000, 8080],
  "postCreateCommand": "bun install"
}
```

### Monorepo Development

```json
{
  "name": "Bun Monorepo Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "build-essential,python3"
    }
  },
  "postCreateCommand": [
    "bun install --frozen-lockfile"
  ]
}
```

## Command Line Usage

Bun provides a comprehensive set of commands for JavaScript development:

### Basic Commands

```bash
# Check version
bun --version

# Show help
bun --help

# Install dependencies
bun install

# Run a script
bun run start
bun run dev
bun run build
```

### Package Management

```bash
# Install a package
bun add react
bun add -d typescript  # Development dependency
bun add -g nodemon     # Global package

# Remove a package
bun remove react

# Update packages
bun update

# Install from package.json
bun install

# Show installed packages
bun pm ls
```

### Running Scripts

```bash
# Run JavaScript/TypeScript files directly
bun index.js
bun server.ts
bun --watch server.ts  # Watch mode

# Run package.json scripts
bun start
bun dev
bun build
bun test

# Run with specific environment
NODE_ENV=production bun start
```

### Testing

```bash
# Run tests
bun test

# Run tests in watch mode
bun test --watch

# Run specific test file
bun test my-test.test.js

# Coverage report
bun test --coverage
```

### Project Creation

```bash
# Create new projects
bun create react my-app
bun create next-app my-next-app
bun create svelte my-svelte-app

# Custom templates
bun create github:user/repo my-project
```

### Development Server

```bash
# Start development server
bun --hot server.ts

# Serve static files
bun --serve ./dist

# Custom port
bun --port 8080 server.ts
```

### Building and Bundling

```bash
# Bundle for production
bun build ./index.ts --outdir ./dist
bun build ./index.ts --outfile ./dist/bundle.js

# Watch and rebuild
bun build ./index.ts --outdir ./dist --watch

# Minify output
bun build ./index.ts --outdir ./dist --minify

# Target specific platform
bun build ./index.ts --target node
bun build ./index.ts --target browser
```

## Configuration Examples

### TypeScript Project Setup

```json
{
  "name": "TypeScript Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {}
  },
  "postCreateCommand": [
    "bun add -d typescript @types/node",
    "bun add -d @types/bun"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next"
      ]
    }
  }
}
```

### Docker Integration

```json
{
  "name": "Bun with Docker",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "postCreateCommand": "bun install"
}
```

### Database Development

```json
{
  "name": "Bun with Database",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ruanzx/features/bun:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "postgresql-client,sqlite3"
    }
  },
  "services": {
    "postgres": {
      "image": "postgres:15",
      "environment": {
        "POSTGRES_PASSWORD": "postgres"
      }
    }
  }
}
```

## Supported Platforms

- **Linux x86_64**: Full support with AVX2 optimization
- **Linux x86_64 (baseline)**: Support for older CPUs without AVX2
- **Linux ARM64**: Full support for ARM-based systems

## Performance Optimizations

### CPU Feature Detection

The feature automatically detects your CPU capabilities:

- **AVX2 Support**: Uses optimized builds for better performance
- **Baseline Builds**: Falls back to compatible builds for older hardware
- **Architecture Detection**: Automatically selects the correct binary

### Installation Best Practices

```bash
# Verify installation
bun --version

# Check runtime performance
bun --print "console.time('test'); for(let i=0;i<1000000;i++){} console.timeEnd('test')"

# Profile memory usage
bun --smol server.ts  # Use less memory

# Enable debugging
bun --inspect server.ts
```

## Common Workflows

### Starting a New Project

```bash
# Initialize new project
mkdir my-project && cd my-project
bun init

# Install dependencies
bun add express
bun add -d @types/express typescript

# Create entry point
echo 'console.log("Hello from Bun!")' > index.ts

# Run the project
bun index.ts
```

### Migrating from Node.js

```bash
# Install dependencies from package.json
bun install

# Run existing scripts
bun run start
bun run test

# Update scripts for Bun
# package.json: "start": "bun server.ts"
```

### Testing Setup

```bash
# Install testing dependencies
bun add -d @types/jest
bun add -d happy-dom  # For DOM testing

# Create test file
echo 'test("basic test", () => { expect(1 + 1).toBe(2); });' > test/basic.test.ts

# Run tests
bun test
```

### Building for Production

```bash
# Build optimized bundle
bun build src/index.ts --outdir dist --minify --target node

# Bundle for browser
bun build src/client.ts --outfile public/bundle.js --target browser

# Generate declarations
bun build src/lib.ts --outdir dist --target node --emit=types
```

## Package.json Integration

Bun works seamlessly with existing package.json configurations:

```json
{
  "name": "my-bun-project",
  "scripts": {
    "dev": "bun --hot src/server.ts",
    "build": "bun build src/index.ts --outdir dist",
    "start": "bun dist/index.js",
    "test": "bun test",
    "type-check": "bun --dry-run src/index.ts"
  },
  "dependencies": {
    "fastify": "^4.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  }
}
```

## Environment Variables

Bun respects standard Node.js environment variables and adds its own:

```bash
# Runtime configuration
BUN_CONFIG_VERBOSE=1 bun install  # Verbose output
BUN_CONFIG_REGISTRY=https://registry.npmjs.org/ bun install

# Performance tuning
BUN_JSC_useJIT=0 bun server.ts  # Disable JIT compilation
BUN_GARBAGE_COLLECTOR_LEVEL=2 bun server.ts  # GC tuning
```

## Verification

After installation, verify Bun is working correctly:

```bash
# Check installation
bun --version

# Test basic functionality
echo 'console.log("Bun is working!")' | bun -

# Test package management
bun add --dry-run lodash

# Test TypeScript support
echo 'const x: number = 42; console.log(x);' | bun -

# Test bundling
echo 'export const hello = "world";' > test.ts && bun build test.ts --outfile bundle.js
```

## Troubleshooting

### Installation Issues

**Problem**: Installation fails with download errors
**Solution**: Check internet connectivity and GitHub access:
```bash
curl -I https://github.com/oven-sh/bun/releases/latest
```

**Problem**: Binary not found after installation
**Solution**: Check PATH and verify installation:
```bash
which bun
echo $PATH
ls -la /usr/local/bin/bun
```

**Problem**: Permission denied errors
**Solution**: Ensure the script runs as root or fix permissions:
```bash
sudo chmod +x /usr/local/bin/bun
```

### Runtime Issues

**Problem**: "GLIBC version not supported" error
**Solution**: Use the baseline build by forcing the target:
```bash
# Reinstall with baseline target
curl -fsSL https://bun.sh/install | bash -s -- bun-linux-x64-baseline
```

**Problem**: Module resolution errors
**Solution**: Clear Bun's cache and reinstall:
```bash
bun pm cache rm
rm -rf node_modules bun.lockb
bun install
```

**Problem**: TypeScript compilation errors
**Solution**: Ensure TypeScript configuration is correct:
```bash
# Create tsconfig.json
bun add -d typescript
bunx tsc --init

# Check types
bun --dry-run src/index.ts
```

### Performance Issues

**Problem**: Slow startup times
**Solution**: Check if you're using the optimized build:
```bash
# Verify CPU features
cat /proc/cpuinfo | grep avx2

# Use profile mode for debugging
bun --profile server.ts
```

**Problem**: High memory usage
**Solution**: Use memory-optimized flags:
```bash
# Use smaller memory footprint
bun --smol server.ts

# Adjust garbage collection
BUN_GARBAGE_COLLECTOR_LEVEL=1 bun server.ts
```

### Compatibility Issues

**Problem**: Package compatibility with Node.js modules
**Solution**: Check Bun's compatibility status:
```bash
# Test package compatibility
bun add package-name --dry-run

# Use Node.js fallback if needed
bunx --bun package-command
```

## Migration from Node.js

### Package.json Scripts

Most Node.js scripts work directly with Bun:

```json
{
  "scripts": {
    "start": "bun server.js",    // was: "node server.js"
    "dev": "bun --hot app.ts",   // was: "nodemon app.ts"
    "build": "bun build.js",     // was: "node build.js"
    "test": "bun test"           // was: "jest" or "node test.js"
  }
}
```

### Lock File Migration

```bash
# From npm
rm package-lock.json && bun install

# From yarn
rm yarn.lock && bun install

# From pnpm
rm pnpm-lock.yaml && bun install
```

## Related Features

- **[Node.js](https://github.com/devcontainers/features/tree/main/src/node)**: Alternative JavaScript runtime
- **[TypeScript](https://github.com/devcontainers/features/tree/main/src/typescript)**: TypeScript compiler (Bun has built-in support)
- **[Git](https://github.com/devcontainers/features/tree/main/src/git)**: Version control for projects
- **[Common Utils](https://github.com/devcontainers/features/tree/main/src/common-utils)**: Required dependency

## Contributing

This feature is part of the [devcontainer-templates](https://github.com/ruanzx/devcontainer-templates) collection. Contributions and issues are welcome!

## License

This feature installs Bun which is licensed under the [MIT License](https://github.com/oven-sh/bun/blob/main/LICENSE.md).

---

**Note**: Bun is a rapidly evolving runtime. For the latest information about Bun's features and compatibility, visit the [official website](https://bun.sh) and [GitHub repository](https://github.com/oven-sh/bun).
