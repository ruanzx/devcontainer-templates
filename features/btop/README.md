# btop++ Feature

Installs [btop++](https://github.com/aristocratos/btop), a resource monitor that shows usage and stats for processor, memory, disks, network and processes.

## Features

- 📊 Easy to use with game inspired menu system
- 🎨 Fast and responsive UI with UP, DOWN keys process selection
- 🖥️ Function for showing detailed stats for selected process
- 📈 Ability to filter processes
- 🎯 Easy switching between sorting options
- 🌈 Tree view of processes
- 📡 Send any signal to selected process
- 🎨 UI is correlated by theme with 20+ themes available
- 💾 Network usage for download and upload
- 🔌 Shows message in menu if new version is available
- 🌐 Shows current network speeds

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/btop:1": {}
  }
}
```

## Options

| Option    | Type   | Default | Description                   |
| --------- | ------ | ------- | ----------------------------- |
| `version` | string | `1.4.5` | Version of btop++ to install  |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/btop:1": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/btop:1": {
      "version": "1.4.5"
    }
  }
}
```

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/btop:1": {
      "version": "latest"
    }
  }
}
```

## Supported Platforms

- Linux x86_64 (amd64)
- Linux aarch64 (arm64)
- Linux armv7l
- Linux i686 (32-bit)

All binaries are statically linked with musl and work on kernel 2.6.39 and newer.

## Usage

After installation, simply run:

```bash
btop
```

### Keyboard Shortcuts

- `q` or `Ctrl+C` - Quit
- `Esc` - Close help menu
- `1-4` - Jump to respective box (CPU, Memory, Network, Processes)
- `Tab` - Next box
- `Shift+Tab` - Previous box
- `Up/Down` - Select process
- `Enter` - Show detailed process info
- `Space` - Tag process
- `t` - Toggle tree mode
- `k` - Kill process (SIGTERM)
- `K` - Kill process (SIGKILL)
- `f` - Filter processes
- `/` - Search processes
- `h` - Show help
- `+/-` - Increase/decrease update interval
- `p` - Pause

### Configuration

btop++ stores its configuration in:
- Linux: `~/.config/btop/btop.conf`

You can customize:
- Color theme
- Update interval
- Shown boxes
- Process sorting
- Network interface
- And much more...

### Themes

This feature installs btop++ with all available themes. To change the theme:
1. Press `Esc` to open the menu
2. Navigate to theme selection
3. Choose your preferred theme

Available themes include:
- default
- TTY
- nord
- gruvbox_dark
- gruvbox_light
- solarized_dark
- solarized_light
- And many more...

## Notes

- The installed binaries do not include GPU support
- For GPU monitoring, you'll need to compile btop++ from source
- All binaries are statically linked with musl for maximum compatibility

## Verification

To verify the installation:

```bash
# Check if btop is installed
which btop

# Check version
btop --version

# Run btop
btop
```

## License

This feature installs btop++ which is licensed under the [Apache License 2.0](https://github.com/aristocratos/btop/blob/main/LICENSE).

## References

- [btop++ GitHub Repository](https://github.com/aristocratos/btop)
- [btop++ Documentation](https://github.com/aristocratos/btop#readme)
