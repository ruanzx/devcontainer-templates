# Lazygit

A simple terminal UI for git commands that makes git easy and intuitive. Lazygit provides a visual interface for common git operations like staging, committing, branching, merging, and more.

## Example Usage

```json
"features": {
    "ghcr.io/ruanzx/features/lazygit:0.54.2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Lazygit to install | string | 0.54.2 |

## Supported Platforms

- Linux (x86_64, arm64, armv6)

## What is Lazygit?

Lazygit is a simple terminal UI for git commands. It provides an intuitive interface that makes complex git operations easy to perform:

- **Visual File Staging**: Stage individual files or hunks with simple key presses
- **Interactive Rebasing**: Easily reorder, squash, or edit commits
- **Branch Management**: Create, switch, merge, and delete branches visually
- **Commit History**: Navigate through commit history with a beautiful graph
- **Merge Conflict Resolution**: Resolve conflicts with a visual interface
- **Stash Management**: Create, apply, and drop stashes effortlessly
- **Submodule Support**: Manage git submodules
- **Custom Commands**: Configure custom git commands and workflows

## Key Features

- **🎯 Intuitive Interface**: Navigate git operations with simple keypresses
- **🚀 Fast Performance**: Lightweight and responsive terminal UI
- **🔧 Highly Configurable**: Customize keybindings, themes, and behavior
- **📊 Visual Git Graph**: See your commit history and branches clearly
- **🔀 Interactive Rebasing**: Rewrite history with an easy-to-use interface
- **📝 Staging Made Easy**: Stage files, hunks, or individual lines
- **🌿 Branch Visualization**: Understand your branching strategy at a glance

## Usage

After installation, you can start Lazygit by running:

```bash
lazygit
```

Or create an alias for convenience:

```bash
echo "alias lg='lazygit'" >> ~/.bashrc
```

### Basic Navigation

- `j/k` or `↑/↓`: Navigate up/down
- `h/l` or `←/→`: Navigate between panels
- `enter`: Select/expand item
- `esc`: Go back/cancel
- `q`: Quit
- `?`: Show help

### Common Operations

- **Stage files**: Navigate to files panel, select files, press `space`
- **Commit**: Press `c` to commit staged changes
- **Create branch**: Press `b` in branches panel
- **Merge**: Select branch and press `M`
- **Interactive rebase**: Select commits and press `i`

## Configuration

Lazygit can be configured through a YAML config file. The default location is:
- Linux: `~/.config/lazygit/config.yml`

Example configuration:

```yaml
git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never
gui:
  theme:
    lightTheme: false
    activeBorderColor:
      - green
      - bold
    inactiveBorderColor:
      - white
```

For more configuration options, see the [official documentation](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md).

## Learning Resources

- [Official Documentation](https://github.com/jesseduffield/lazygit)
- [Video Tutorial: 15 Lazygit Features in 15 Minutes](https://youtu.be/CPLdltN7wgE)
- [Basics Tutorial](https://youtu.be/VDXvbHZYeKY)
- [Interactive Rebase Tutorial](https://youtu.be/4XaToVut_hs)

## Notes

- Requires Git to be installed
- Works best in terminals with good color support
- Supports most git workflows and edge cases
- Compatible with git hooks and custom git configurations
