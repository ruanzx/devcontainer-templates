# Skills-Ref Example

This example demonstrates how to use the Skills-Ref feature in a DevContainer to validate and manage agent skills.

## Overview

[Skills-Ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) is a tool for validating and managing agent skills following the AgentSkills standard format. It provides three main commands:

- `validate` - Validates skill structure and format
- `read-properties` - Reads metadata from skill definitions
- `to-prompt` - Generates prompts from one or more skills

## Usage

1. Open this folder in VS Code with Dev Containers extension
2. Reopen in container when prompted
3. The `skills-ref` command will be available

## Testing the Installation

### 1. Validate a Skill

Validate the example skill included in this directory:

```bash
skills-ref validate ./file-operations
```

**Expected output:**
```
Valid skill: file-operations
```

### 2. Read Skill Properties

Read the properties from the example skill:

```bash
skills-ref read-properties ./file-operations
```

**Expected output:**
```json
{
  "name": "file-operations",
  "description": "Provides capabilities for reading and writing files in the local filesystem",
  "license": "MIT"
}
```

### 3. Generate Prompt from Skills

Generate a prompt from the example skill:

```bash
skills-ref to-prompt ./file-operations
```

This will output the skill content formatted as XML suitable for AI agent prompts.

You can also combine multiple skills:

```bash
skills-ref to-prompt ./file-operations ./another-skill
```

## Example Skill Structure

This example includes a sample skill in the `file-operations/` directory:

```
file-operations/
├── SKILL.md          # Skill definition with metadata and capabilities
└── examples/         # Optional examples directory
    └── usage.md
```

## Creating Your Own Skills

To create a new skill:

1. Create a new directory for your skill (use lowercase with hyphens)
2. Add a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: your-skill-name
description: What this skill does
license: MIT
---

# your-skill-name

## Capabilities

- Capability 1
- Capability 2

## Usage Examples

...
```

**Important naming rules:**
- Skill name must be lowercase
- Use hyphens to separate words (e.g., `file-operations`)
- Directory name must match skill name exactly
- Only letters, digits, and hyphens allowed in name

3. Validate your skill:

```bash
skills-ref validate ./your-skill-name
```

## Integration with AI Agents

Skills-Ref is designed to work with AI agents that follow the AgentSkills standard. You can:

1. **Validate skills** during development to ensure they meet the standard
2. **Read properties** programmatically to build skill catalogs
3. **Generate prompts** to provide skills to AI agents at runtime

### Example Workflow

```bash
# Validate all skills in a project
for skill in skills/*; do
  skills-ref validate "$skill"
done

# Generate a combined prompt for an agent
skills-ref to-prompt skills/file-ops skills/api-client skills/data-processing > agent-prompt.txt
```

## Troubleshooting

If you encounter issues:

1. **Check Docker is running:**
   ```bash
   docker info
   ```

2. **Verify skills-ref command:**
   ```bash
   which skills-ref
   skills-ref --help
   ```

3. **Check skill structure:**
   - Ensure `SKILL.md` exists in the skill directory
   - Verify YAML frontmatter is valid
   - Check that required fields (name, description, version) are present

4. **Docker image issues:**
   If the image needs to be pulled, it will happen automatically on first use:
   ```bash
   docker pull ruanzx/skills-ref:latest
   ```

## Resources

- [AgentSkills Project](https://github.com/agentskills/agentskills)
- [Skills-Ref Documentation](https://github.com/agentskills/agentskills/tree/main/skills-ref)
- [Skills Format Specification](https://github.com/agentskills/agentskills#skills-format)
- [Example Skills](https://github.com/agentskills/agentskills/tree/main/skills)

## Next Steps

- Explore the [AgentSkills repository](https://github.com/agentskills/agentskills) for more example skills
- Create custom skills for your AI agents
- Integrate skills-ref validation into your CI/CD pipeline
- Build agent systems that dynamically compose skills
