# Skills-Ref (in Docker) Feature

Installs a command-line wrapper for [Skills-Ref](https://github.com/agentskills/agentskills/tree/main/skills-ref), a tool for validating and managing agent skills that runs in a Docker container. This feature makes it easy to validate skill definitions, read skill properties, and generate prompts from skills directly from your dev container.

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/features/skills-ref-in-docker:1": {}
  }
}
```

## Options

| Option      | Type   | Default              | Description                                        |
| ----------- | ------ | -------------------- | -------------------------------------------------- |
| `version`   | string | `latest`             | Version tag of the Skills-Ref Docker image to use  |
| `imageName` | string | `ruanzx/skills-ref`  | Docker image name for Skills-Ref                   |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/features/skills-ref-in-docker:1": {}
  }
}
```

### Use Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/features/skills-ref-in-docker:1": {
      "version": "1.0.0"
    }
  }
}
```

### Use Custom Docker Image

```json
{
  "features": {
    "ghcr.io/ruanzx/features/skills-ref-in-docker:1": {
      "imageName": "myorg/custom-skills-ref",
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
    "ghcr.io/ruanzx/features/skills-ref-in-docker:1": {}
  }
}
```

## Commands Available

After installation, the `skills-ref` command is available with three main subcommands:

### Validate Skill

Validates a skill directory to ensure it follows the correct structure and format:

```bash
# Validate a skill
skills-ref validate path/to/skill

# Example
skills-ref validate ./skills/my-skill
```

### Read Skill Properties

Reads and displays properties from a skill's SKILL.md file:

```bash
# Read properties from a skill
skills-ref read-properties path/to/skill

# Example
skills-ref read-properties ./skills/my-skill
```

### Generate Prompt from Skills

Generates a combined prompt from one or more skills for use with AI agents:

```bash
# Generate prompt from single skill
skills-ref to-prompt path/to/skill

# Generate prompt from multiple skills
skills-ref to-prompt path/to/skill-a path/to/skill-b path/to/skill-c

# Example
skills-ref to-prompt ./skills/file-operations ./skills/api-integration
```

## What is Skills-Ref?

Skills-Ref is part of the [AgentSkills](https://github.com/agentskills/agentskills) project, which provides a standardized format for defining and managing agent skills. Skills are reusable capabilities that can be composed together to create powerful AI agents.

Each skill is defined by a `SKILL.md` file that contains:
- Skill metadata (name, description, version)
- Capabilities and limitations
- Example usage
- Implementation guidelines

Skills-Ref helps you:
- **Validate** skill definitions to ensure they meet the standard format
- **Read** skill properties programmatically
- **Generate** prompts for AI agents by combining multiple skills

## Example Skill Structure

A typical skill directory looks like this:

```
my-skill/
├── SKILL.md          # Skill definition
└── examples/         # Optional examples
    └── example.md
```

The `SKILL.md` file should contain metadata in YAML frontmatter:

```markdown
---
name: my-skill
description: What this skill does
license: MIT
---

# my-skill

This skill provides the following capabilities:
- Capability 1
- Capability 2
...
```

**Important naming conventions:**
- Skill name must be **lowercase**
- Use **hyphens** to separate words (e.g., `file-operations`)
- Directory name must **match skill name** exactly
- Only letters, digits, and hyphens are allowed in the name

## Integration with Development Workflows

Skills-Ref is particularly useful for:
- **Agent Development**: Validate skills before deploying agents
- **CI/CD Pipelines**: Automated skill validation in testing workflows
- **Documentation Generation**: Extract skill metadata for documentation
- **Prompt Engineering**: Compose skills into effective agent prompts

## Resources

- [Skills-Ref Source Code](https://github.com/agentskills/agentskills/tree/main/skills-ref)
- [AgentSkills Project](https://github.com/agentskills/agentskills)
- [Skills Standard Documentation](https://github.com/agentskills/agentskills#skills-format)
- [Example Skills](https://github.com/agentskills/agentskills/tree/main/skills)

## Notes

- The tool runs in a Docker container and mounts your current working directory to `/output`
- All file paths should be relative to your current directory or absolute paths
- The Docker image is pulled automatically on first use
- Requires Docker daemon to be running and accessible
