# BMAD-METHOD: Docker vs Native Installation

This document compares the Docker-based and native Node.js installations of BMAD-METHOD.

## Comparison Table

| Aspect | Docker (this example) | Native ([bmad-method](../bmad-method/)) |
|--------|----------------------|------------------------------------------|
| **Prerequisites** | Docker only | Node.js v20+, npm, git |
| **Installation Size** | ~50MB (wrapper only) | ~200MB+ (full dependencies) |
| **Setup Time** | ~30 seconds | ~2-3 minutes |
| **Isolation** | ✅ Full (containerized) | ❌ Partial (uses host Node.js) |
| **Updates** | Pull new Docker image | `npm update -g bmad-method` |
| **Disk Space** | Lower (shared image) | Higher (per-project) |
| **Startup Time** | Fast (<1s) | Fast (<1s) |
| **Network Required** | First run only | Install + updates |
| **Customization** | Limited (image-based) | Full (npm packages) |
| **Best For** | Docker workflows, CI/CD | Node.js developers |

## Use Cases

### Choose Docker When:

1. **No Node.js Environment**
   - You don't have or want Node.js installed
   - Working in polyglot teams
   - Standardizing across different tech stacks

2. **Containerized Workflows**
   - Already using Docker for development
   - CI/CD pipelines with Docker
   - Kubernetes-based deployments

3. **Quick Testing**
   - Trying BMAD-METHOD without commitment
   - Temporary project needs
   - Demo or proof-of-concept

4. **Isolation Requirements**
   - Don't want global npm packages
   - Need reproducible environments
   - Multiple projects with different needs

### Choose Native When:

1. **Node.js Development**
   - Already have Node.js installed
   - Working on Node.js projects
   - Need tight integration with npm ecosystem

2. **Customization Needs**
   - Want to install additional npm packages
   - Need to modify BMAD configuration deeply
   - Developing BMAD extensions

3. **Offline Work**
   - Limited network connectivity
   - Air-gapped environments
   - Local development without Docker

4. **Performance Critical**
   - Very frequent BMAD invocations
   - Need millisecond-level optimization
   - Large-scale automation

## Technical Differences

### Docker Version

```bash
# Command execution
bmad install
↓
docker run --rm -v $PWD:/workspace ruanzx/bmad install
↓
Container starts → Executes bmad → Container stops
```

**Architecture**:
- Wrapper script at `/usr/local/bin/bmad`
- Mounts workspace to `/workspace` in container
- Passes commands to containerized bmad
- Automatically translates paths in dev containers

### Native Version

```bash
# Command execution
bmad install
↓
npx bmad-method install
↓
Direct execution via Node.js
```

**Architecture**:
- Global npm package installation
- Direct system integration
- Full access to Node.js ecosystem
- Traditional package management

## Migration Between Versions

### Docker → Native

```bash
# Install Node.js and npm first
npm install -g bmad-method

# Verify installation
bmad --version

# Continue using existing project
bmad status
```

### Native → Docker

```bash
# Remove global npm package
npm uninstall -g bmad-method

# Install Docker-based version
# (Use the bmad-method-docker example)

# Continue using existing project
bmad status
```

**Note**: Both versions can work with the same BMAD project files. The `.bmad/` directory and configuration remain compatible.

## Feature Parity

Both versions provide:
- ✅ Full BMAD-METHOD functionality
- ✅ All agent capabilities
- ✅ Expansion pack support
- ✅ Same commands and options
- ✅ Compatible project files

The only differences are in installation, updates, and execution environment.

## Recommendations

### For Teams

- **Standardize on Docker** if team uses multiple languages
- **Standardize on Native** if team is primarily Node.js

### For Individuals

- **Use Docker** for experimentation and learning
- **Use Native** for daily development if you're a Node.js developer

### For CI/CD

- **Use Docker** for consistency and reproducibility
- Both work well, but Docker offers better isolation

## Performance Notes

### Docker Overhead

- **First run**: ~2-3 seconds (image pull if needed)
- **Subsequent runs**: <1 second overhead
- **Large projects**: Negligible difference

### Native Performance

- **Consistent**: No container startup time
- **Slightly faster**: Direct execution
- **Network independent**: After installation

In practice, the performance difference is minimal for typical BMAD workflows.

## Conclusion

Both installations are fully functional. Choose based on your:
- Development environment preferences
- Team standards and workflows
- Existing tooling and infrastructure
- Isolation and reproducibility needs

Can't decide? Try the Docker version first - it's easier to get started with and you can always switch to native later if needed.
