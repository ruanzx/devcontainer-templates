# Lazygit Development Environment

This example demonstrates how to set up a development environment with Lazygit for enhanced git workflow management.

## Features Included

- **Lazygit**: Simple terminal UI for git commands
- **Git**: Version control system (typically pre-installed)
- **Common utilities**: Basic developer tools

## Quick Start

1. Open this folder in VS Code
2. When prompted, click "Reopen in Container"
3. Once the container builds, open a terminal
4. Run `lazygit` to start the git UI

## Usage

### Basic Navigation
- Use `j/k` or arrow keys to navigate
- Press `enter` to expand/select items
- Press `?` to see help and keybindings

### Common Workflows

#### Stage and Commit Changes
1. Start lazygit: `lazygit`
2. Navigate to the Files panel (should be focused by default)
3. Select files with arrow keys
4. Press `space` to stage/unstage files
5. Press `c` to commit staged changes
6. Type your commit message and press `enter`

#### Create and Switch Branches
1. Press `b` to go to branches view
2. Press `n` to create a new branch
3. Type branch name and press `enter`
4. Or select existing branch and press `enter` to switch

#### Interactive Rebase
1. Navigate to Commits panel (`4` key)
2. Select a commit
3. Press `i` for interactive rebase
4. Use various options to squash, reword, or reorder commits

#### Merge Branches
1. Go to branches view (`b`)
2. Select the branch you want to merge into current
3. Press `M` to merge

### Configuration

Lazygit can be configured through `~/.config/lazygit/config.yml`. Example:

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
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `j/k` | Navigate up/down |
| `h/l` | Navigate left/right between panels |
| `1-5` | Switch between panels |
| `space` | Stage/unstage files |
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `b` | Branches view |
| `i` | Interactive rebase |
| `M` | Merge selected branch |
| `d` | Delete branch/file |
| `?` | Help |
| `q` | Quit |

## Tips

1. **Use the mouse**: Lazygit supports mouse interactions for clicking between panels
2. **Custom commands**: You can configure custom git commands in the config file
3. **Aliases**: Create shell aliases like `alias lg='lazygit'` for quick access
4. **Integration**: Works well with any git workflow and existing git hooks

## Learning Resources

- [Lazygit GitHub](https://github.com/jesseduffield/lazygit)
- [Video: 15 Lazygit Features in 15 Minutes](https://youtu.be/CPLdltN7wgE)
- [Configuration Documentation](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)
- [Keybindings Reference](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings)
