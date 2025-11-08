# Spec-Kit Docker Example

This example demonstrates how to use the `spec-kit-in-docker` DevContainer feature for spec-driven development with AI coding agents.

## What's Included

- **Docker-based spec-kit**: No Python installation required
- **GitHub Copilot**: Pre-configured VS Code extensions
- **Docker access**: Via docker-outside-of-docker feature
- **Easy updates**: Use `specify --wrapper-upgrade`

## Quick Start

### 1. Open in DevContainer

Open this folder in VS Code and select "Reopen in Container" when prompted.

### 2. Verify Installation

```bash
# Check spec-kit is working
specify check

# View wrapper help
specify --wrapper-help
```

### 3. Initialize a Project

```bash
# Initialize in current directory
specify init --here --ai copilot

# Or create a new project directory
specify init my-awesome-app --ai copilot
```

### 4. Use Spec-Kit Workflow

After initialization, use these commands in your AI coding agent (e.g., GitHub Copilot Chat):

```
/speckit.constitution
Create principles focused on code quality, clean architecture, 
and maintainability.

/speckit.specify
Build a photo album manager that allows users to organize photos 
into albums, add tags, and search by date or tags.

/speckit.plan
Use React with TypeScript, Vite for bundling, and SQLite for 
local storage. Keep dependencies minimal.

/speckit.tasks
Generate actionable tasks from the implementation plan.

/speckit.implement
Execute the implementation plan.
```

## Features Used

### spec-kit-in-docker

Provides the `specify` command wrapper that runs spec-kit in Docker:

```json
{
  "ghcr.io/ruanzx/features/spec-kit-in-docker:1": {
    "version": "latest",
    "imageName": "ruanzx/spec-kit"
  }
}
```

### docker-outside-of-docker

Provides Docker daemon access from within the DevContainer:

```json
{
  "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
}
```

## Available Commands

### Wrapper Commands

```bash
# Show wrapper-specific help
specify --wrapper-help

# Upgrade spec-kit Docker image
specify --wrapper-upgrade
```

### Spec-Kit Commands

```bash
# Initialize project
specify init [PROJECT_NAME] [OPTIONS]

# Check requirements
specify check

# Get help
specify --help
```

## Environment Variables

Customize the Docker image used:

```bash
# Use custom image
export SPECKIT_IMAGE_NAME="my-custom/spec-kit"
export SPECKIT_IMAGE_TAG="v1.0.0"

specify check
```

## Workflow Example

Here's a complete example of building a task management app:

### Step 1: Initialize

```bash
mkdir task-manager
cd task-manager
specify init --here --ai copilot
```

### Step 2: Define Principles (in Copilot Chat)

```
/speckit.constitution
Create principles for a task management application focusing on:
- Simple, intuitive user interface
- Fast performance (< 100ms response time)
- Offline-first architecture
- Data privacy and security
```

### Step 3: Create Specification

```
/speckit.specify
Build a task management application that allows users to:
- Create, edit, and delete tasks
- Organize tasks into projects
- Set due dates and priorities
- Filter and search tasks
- Track task completion status
```

### Step 4: Technical Planning

```
/speckit.plan
Technology stack:
- Frontend: React with TypeScript
- State Management: Zustand
- UI: Tailwind CSS
- Storage: IndexedDB via Dexie.js
- Build Tool: Vite
- Testing: Vitest + React Testing Library
```

### Step 5: Generate Tasks

```
/speckit.tasks
Break down the implementation into actionable tasks.
```

### Step 6: Implement

```
/speckit.implement
Execute the implementation plan following the tasks.
```

## Tips

### 1. Use with Different AI Agents

The feature works with various AI agents:

```bash
# GitHub Copilot
specify init my-app --ai copilot

# Claude Code
specify init my-app --ai claude

# Gemini CLI
specify init my-app --ai gemini
```

### 2. Git Integration

The wrapper automatically mounts your git config:

```bash
# Git commands work inside the container
cd my-project
git init
git add .
git commit -m "Initial commit"
```

### 3. Upgrade Regularly

Keep spec-kit up to date:

```bash
# Pull latest Docker image
specify --wrapper-upgrade
```

### 4. Custom Docker Image

Build and use your own image:

```bash
# Build custom image
cd /path/to/spec-kit-docker
docker build -t my-spec-kit:custom .

# Use custom image
export SPECKIT_IMAGE_NAME="my-spec-kit"
export SPECKIT_IMAGE_TAG="custom"
specify check
```

## Troubleshooting

### Issue: Docker image not found

**Solution**: Build the image locally:

```bash
# Navigate to Docker directory
cd /workspaces/devcontainer-templates/features/spec-kit-in-docker/docker

# Build image
docker build -t ruanzx/spec-kit:latest .
```

### Issue: Permission denied

**Solution**: The wrapper handles permissions automatically, but if issues persist:

```bash
# Check Docker is accessible
docker info

# Verify wrapper is executable
ls -la /usr/local/bin/specify
```

### Issue: Changes not persisting

**Solution**: Ensure you're working in mounted directories:

```bash
# Current directory is automatically mounted
pwd  # Should show /workspace in container

# Files created here persist on host
touch test.txt
ls -la  # File exists on both host and container
```

## Additional Resources

- [Spec-Kit Documentation](https://github.com/github/spec-kit)
- [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [DevContainer Features](https://containers.dev/features)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Next Steps

1. Try the quick start above
2. Explore the [spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md) methodology
3. Build your first feature with spec-kit
4. Share your experience and contribute improvements

Happy spec-driven development! 🚀
