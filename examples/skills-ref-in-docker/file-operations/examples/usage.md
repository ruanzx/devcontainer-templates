# File Operations Skill - Usage Examples

This document provides practical examples of how to use the File Operations skill.

## Example 1: Reading and Analyzing a File

```markdown
**User:** "Can you read the package.json file and tell me what dependencies are listed?"

**Agent using File Operations Skill:**
1. Read file: `package.json`
2. Parse JSON content
3. Extract dependencies section
4. Present formatted list to user
```

## Example 2: Creating Project Structure

```markdown
**User:** "Set up a basic Node.js project structure"

**Agent using File Operations Skill:**
1. Create directory: `src/`
2. Create directory: `tests/`
3. Create file: `src/index.js` with boilerplate code
4. Create file: `tests/index.test.js` with test template
5. Create file: `README.md` with project description
6. Confirm structure created successfully
```

## Example 3: File Cleanup

```markdown
**User:** "Delete all temporary files with .tmp extension"

**Agent using File Operations Skill:**
1. List all files in current directory
2. Filter for .tmp extension
3. For each .tmp file:
   - Confirm it's safe to delete
   - Delete the file
   - Log the deletion
4. Report number of files deleted
```

## Example 4: Backup Before Modification

```markdown
**User:** "Update the config.yaml file to change the port to 8080"

**Agent using File Operations Skill:**
1. Read current content from `config.yaml`
2. Create backup: `config.yaml.backup`
3. Modify port value in content
4. Write updated content to `config.yaml`
5. Confirm change and backup location
```

## Best Practices

1. **Always validate paths** before operations
2. **Check file existence** before reading
3. **Create backups** before destructive operations
4. **Use relative paths** when possible
5. **Report results clearly** to the user
6. **Handle errors gracefully** with helpful messages
