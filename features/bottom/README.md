# bottom Feature

Installs [bottom](https://github.com/ClementTsang/bottom) (also known as `btm`), a customizable cross-platform graphical process/system monitor for the terminal. Written in Rust, it's inspired by other terminal applications like gtop, gotop, and htop.

## Features

- 🚀 **Fast and Lightweight** - Written in Rust for optimal performance
- 📊 **Graphical Widgets** - Beautiful charts and graphs for CPU, memory, network, and disk usage
- 🎨 **Customizable** - Extensive configuration options and theming support
- 🔍 **Process Management** - Search, filter, sort, and manage processes
- 📈 **Multiple Modes** - Basic and grouped process modes, tree view support
- 🌡️ **Temperature Monitoring** - CPU and sensor temperature display
- 💾 **Disk Usage** - Detailed disk I/O statistics
- 📡 **Network Stats** - Real-time network usage monitoring
- ⚙️ **Battery Info** - Battery status and percentage (laptops)
- 🎯 **Process Details** - Detailed information about selected processes

## Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bottom:1": {}
  }
}
```

## Options

| Option    | Type   | Default  | Description                    |
| --------- | ------ | -------- | ------------------------------ |
| `version` | string | `0.11.4` | Version of bottom to install   |

## Examples

### Basic Usage

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bottom:1": {}
  }
}
```

### Install Specific Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bottom:1": {
      "version": "0.11.4"
    }
  }
}
```

### Install Latest Version

```json
{
  "features": {
    "ghcr.io/ruanzx/devcontainer-features/bottom:1": {
      "version": "latest"
    }
  }
}
```

## Supported Platforms

- Linux x86_64 (amd64)
- Linux aarch64 (arm64)
- Linux armv7 (armhf)
- Linux i686 (32-bit)

All binaries are statically linked with musl for maximum compatibility.

## Usage

After installation, run the command:

```bash
btm
```

### Command-Line Options

```bash
# Start with default settings
btm

# Use a custom config file
btm -C /path/to/config.toml

# Set update rate in milliseconds
btm -r 1000

# Start in basic mode (no graphs)
btm -b

# Show average CPU usage
btm -a

# Show tree view for processes
btm -T

# Filter processes
btm -f "firefox"

# Show help
btm --help

# Show version
btm --version
```

### Keyboard Shortcuts

#### General
- `q` / `Ctrl+C` - Quit
- `Esc` - Close dialogs/reset filters
- `Ctrl+R` - Reset display
- `?` - Show help menu
- `Ctrl+F` / `/` - Search/filter processes

#### Navigation
- `Up` / `Down` / `j` / `k` - Navigate lists
- `Left` / `Right` / `h` / `l` - Switch between widgets
- `Tab` - Next widget
- `Shift+Tab` - Previous widget
- `1-9` - Jump to specific widget

#### Process Management
- `dd` - Kill selected process (send SIGTERM)
- `F9` - Kill selected process with signal selection
- `e` - Toggle process grouping
- `t` - Toggle tree mode
- `P` - Sort by PID
- `n` - Sort by name
- `c` - Sort by CPU usage
- `m` - Sort by memory usage

#### Display
- `+` / `-` - Zoom in/out on graphs
- `=` - Reset zoom
- `a` - Toggle all CPU cores vs average
- `f` - Freeze/unfreeze display
- `Ctrl+L` - Force redraw

### Configuration

bottom stores its configuration in:
- Linux: `~/.config/bottom/bottom.toml`

You can generate a default configuration file:

```bash
btm --generate_config > ~/.config/bottom/bottom.toml
```

#### Configuration Options

```toml
# Update rate in milliseconds
rate = 1000

# Start in basic mode (no graphs)
basic = false

# Show average CPU or all cores
average_cpu_row = false

# Show tree view by default
tree = false

# Default widget to select on startup
default_widget = "cpu"

# Theme colors
[colors]
border_color = "gray"
highlighted_border_color = "light blue"
text_color = "gray"
selected_text_color = "black"
selected_bg_color = "light blue"
widget_title_color = "gray"
graph_color = "gray"
```

### Themes and Customization

bottom supports extensive theming through its configuration file. You can customize:
- Border colors
- Text colors
- Graph colors
- Widget colors
- Background colors

Example theme configuration:

```toml
[colors]
border_color = "#7c8696"
highlighted_border_color = "#7dcfff"
text_color = "#c0caf5"
selected_text_color = "#1d202f"
selected_bg_color = "#7dcfff"
widget_title_color = "#c0caf5"
graph_color = "#7dcfff"
```

## Comparison with Other Monitors

| Feature | bottom (btm) | btop++ | htop | top |
|---------|-------------|--------|------|-----|
| Written in | Rust | C++ | C | C |
| Graphs | ✅ | ✅ | ❌ | ❌ |
| Process Tree | ✅ | ✅ | ✅ | ❌ |
| GPU Support | ❌ | ✅ | ❌ | ❌ |
| Customizable | ✅ | ✅ | ⚠️ | ❌ |
| Cross-platform | ✅ | ✅ | ✅ | ❌ |
| Battery Info | ✅ | ✅ | ❌ | ❌ |

## Advanced Usage

### Process Filtering

```bash
# Filter by process name
btm -f "firefox"

# Filter by multiple criteria
btm -f "firefox|chrome"

# Use regex patterns
btm -f "^node"
```

### Custom Layouts

Create custom widget layouts in the config file:

```toml
[[row]]
  [[row.child]]
  type = "cpu"
  [[row.child]]
  type = "mem"

[[row]]
  [[row.child]]
  type = "proc"
  default = true
```

## Verification

To verify the installation:

```bash
# Check if btm is installed
which btm

# Check version
btm --version

# Generate default config
btm --generate_config

# Run bottom
btm
```

## Troubleshooting

### Display Issues

If you experience display issues:
```bash
# Try forcing a specific terminal mode
TERM=xterm-256color btm

# Or use basic mode
btm -b
```

### Performance Issues

If bottom uses too much CPU:
```bash
# Increase update rate (less frequent updates)
btm -r 2000  # Update every 2 seconds
```

### Configuration Errors

If you have configuration errors:
```bash
# Regenerate default config
btm --generate_config > ~/.config/bottom/bottom.toml

# Or start with no config
btm --override_config
```

## License

This feature installs bottom which is licensed under the [MIT License](https://github.com/ClementTsang/bottom/blob/main/LICENSE).

## References

- [bottom GitHub Repository](https://github.com/ClementTsang/bottom)
- [bottom Documentation](https://clementtsang.github.io/bottom/)
- [Configuration Guide](https://clementtsang.github.io/bottom/stable/configuration/config-file/)
