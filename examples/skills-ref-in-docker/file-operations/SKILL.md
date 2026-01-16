---
name: file-operations
description: Provides capabilities for reading and writing files in the local filesystem
license: MIT
---

# file-operations

This skill provides fundamental file system operations for AI agents, enabling them to interact with files and directories in a controlled manner.

## Capabilities

This skill enables the following operations:

### Read Operations
- **Read file contents**: Retrieve the full contents of a text file
- **Read file lines**: Get specific lines or line ranges from a file
- **List directory contents**: Enumerate files and subdirectories
- **Check file existence**: Verify if a file or directory exists
- **Get file metadata**: Retrieve size, permissions, modification time

### Write Operations
- **Create files**: Create new files with specified content
- **Append to files**: Add content to existing files without overwriting
- **Update files**: Replace existing file contents
- **Create directories**: Make new directories with proper permissions
- **Copy files**: Duplicate files to new locations
- **Move files**: Relocate files to different paths
- **Delete files**: Remove files (with safety checks)

### Safety Features
- Path validation to prevent directory traversal attacks
- Confirmation required for destructive operations
- Automatic backup before overwriting files
- Size limits to prevent resource exhaustion
- Permission checks before operations

## Limitations

- Cannot access files outside the designated workspace
- Maximum file size: 10MB for read operations
- Binary files are read as base64-encoded strings
- No support for symbolic links or special files
- Cannot modify system files or protected directories

## Usage Examples

### Example 1: Reading a Configuration File

**User Request:** "Read the config.json file and show me its contents"

**Agent Actions:**
1. Validate the file path `config.json`
2. Check if file exists
3. Read file contents
4. Parse JSON and present to user

### Example 2: Creating a New File

**User Request:** "Create a new README.md file with a project description"

**Agent Actions:**
1. Prepare content based on user description
2. Validate filename `README.md`
3. Check if file already exists (warn if it does)
4. Write content to new file
5. Confirm creation to user

### Example 3: Organizing Files

**User Request:** "Move all .log files to the logs directory"

**Agent Actions:**
1. List all files in current directory
2. Filter for .log extension
3. Check if logs directory exists (create if needed)
4. For each .log file:
   - Move to logs directory
   - Track results
5. Report summary of operations

## Error Handling

The skill should handle these error scenarios:

- **File not found**: Provide clear message with suggested similar filenames
- **Permission denied**: Explain the issue and suggest alternative approaches
- **Disk full**: Warn about space issues before attempting writes
- **Invalid paths**: Sanitize and validate all path inputs
- **Encoding errors**: Detect and handle different file encodings

## Security Considerations

When implementing this skill:

1. **Validate all paths** to prevent directory traversal
2. **Implement size limits** to prevent DoS attacks
3. **Require confirmation** for destructive operations
4. **Log all operations** for audit trail
5. **Use least privilege** when accessing files
6. **Sanitize file names** to prevent injection attacks

## Integration Notes

This skill should be combined with:
- **Text Processing Skill**: For analyzing file contents
- **Search Skill**: For finding files by content or metadata
- **Backup Skill**: For creating backups before modifications
- **Validation Skill**: For checking file formats and content

## Version History

- **1.0.0** (2026-01-16): Initial version with core file operations
