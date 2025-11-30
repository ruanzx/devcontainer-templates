# bottom Example

This example demonstrates how to use the bottom feature in a dev container.

## What is bottom?

[bottom](https://github.com/ClementTsang/bottom) (also known as `btm`) is a customizable cross-platform graphical process/system monitor for the terminal. Written in Rust, it's inspired by tools like gtop, gotop, and htop, offering a beautiful and performant way to monitor your system.

## Features Included

- ✅ bottom (version 0.11.4)
- ✅ Command-line utility: `btm`
- ✅ Fast and lightweight Rust implementation
- ✅ Graphical widgets with real-time updates
- ✅ Extensive customization options

## Usage

### Starting bottom

Simply run in your terminal:

```bash
btm
```

### Basic Command-Line Options

```bash
# Start with default settings
btm

# Use basic mode (no graphs, htop-like)
btm -b

# Show average CPU usage
btm -a

# Enable tree mode for processes
btm -T

# Filter processes on startup
btm -f "firefox"

# Set update rate (milliseconds)
btm -r 1000

# Use custom config file
btm -C ~/.config/bottom/bottom.toml

# Generate default config
btm --generate_config > ~/.config/bottom/bottom.toml

# Show help
btm --help

# Show version
btm --version
```

### Keyboard Shortcuts

#### General Navigation
- `q` / `Ctrl+C` - Quit
- `Esc` - Close dialogs/reset filters
- `?` - Show help menu
- `Ctrl+R` - Reset display
- `Ctrl+F` / `/` - Search/filter processes

#### Widget Navigation
- `Up` / `Down` / `j` / `k` - Move in lists
- `Left` / `Right` / `h` / `l` - Switch widgets
- `Tab` - Next widget
- `Shift+Tab` - Previous widget
- `1-9` - Jump to specific widget

#### Process Management
- `dd` - Kill selected process (SIGTERM)
- `F9` - Kill with signal selection
- `e` - Toggle process grouping
- `t` - Toggle tree mode
- `P` - Sort by PID
- `n` - Sort by name
- `c` - Sort by CPU usage
- `m` - Sort by memory usage

#### Display Controls
- `+` / `-` - Zoom graphs
- `=` - Reset zoom
- `a` - Toggle all CPU cores
- `f` - Freeze/unfreeze
- `Ctrl+L` - Force redraw

## Configuration

bottom stores its configuration in `~/.config/bottom/bottom.toml`.

### Generate Default Configuration

```bash
btm --generate_config > ~/.config/bottom/bottom.toml
```

### Example Configuration

```toml
# Update rate in milliseconds
rate = 1000

# Start in basic mode (no graphs)
basic = false

# Show average CPU or all cores
average_cpu_row = false

# Show tree view by default
tree = false

# Default widget to select
default_widget = "cpu"

# Temperature unit (celsius, kelvin, fahrenheit)
temperature_type = "celsius"

# Memory unit (kibibyte, mebibyte, gibibyte)
mem_as_value = false

# Network unit (bit, byte)
network_use_bytes = true

# Process CPU percentage type (total or average)
process_cpu_percentage = "total"

[colors]
border_color = "gray"
highlighted_border_color = "light blue"
text_color = "gray"
selected_text_color = "black"
selected_bg_color = "light blue"
widget_title_color = "gray"
graph_color = "gray"
```

## Themes and Customization

### Popular Color Schemes

#### Nord Theme
```toml
[colors]
border_color = "#4c566a"
highlighted_border_color = "#88c0d0"
text_color = "#eceff4"
selected_text_color = "#2e3440"
selected_bg_color = "#88c0d0"
widget_title_color = "#eceff4"
graph_color = "#88c0d0"
```

#### Dracula Theme
```toml
[colors]
border_color = "#6272a4"
highlighted_border_color = "#bd93f9"
text_color = "#f8f8f2"
selected_text_color = "#282a36"
selected_bg_color = "#bd93f9"
widget_title_color = "#f8f8f2"
graph_color = "#bd93f9"
```

#### Gruvbox Dark Theme
```toml
[colors]
border_color = "#665c54"
highlighted_border_color = "#fe8019"
text_color = "#ebdbb2"
selected_text_color = "#282828"
selected_bg_color = "#fe8019"
widget_title_color = "#ebdbb2"
graph_color = "#fe8019"
```

## Custom Layouts

You can create custom widget layouts in the configuration file:

```toml
# Two-column layout
[[row]]
  [[row.child]]
  type = "cpu"
  
[[row]]
  [[row.child]]
  type = "mem"
  
[[row]]
  [[row.child]]
  type = "net"
  
[[row]]
  [[row.child]]
  type = "proc"
  default = true  # Selected by default
```

## Advanced Features

### Process Filtering

Use regular expressions to filter processes:

```bash
# Filter by name
btm -f "firefox"

# Multiple processes
btm -f "firefox|chrome|code"

# Regex pattern
btm -f "^node"

# Case-insensitive
btm -f "(?i)python"
```

### Performance Tuning

If bottom uses too much CPU:

```bash
# Increase update interval
btm -r 2000  # Update every 2 seconds

# Use basic mode
btm -b

# Disable graphs for specific widgets in config
```

### Battery Monitoring

On laptops, bottom automatically displays:
- Battery percentage
- Charging status
- Power consumption
- Time remaining

### Temperature Monitoring

bottom shows CPU temperatures when available:
- Per-core temperatures
- Average temperature
- Sensor readings

## Verification

After the container is created, verify the installation:

```bash
# Check if btm is installed
which btm

# Check version
btm --version

# Test basic mode
btm -b

# Generate sample config
btm --generate_config
```

## Comparison with Other Monitors

| Feature | bottom (btm) | btop++ | htop | top |
|---------|-------------|--------|------|-----|
| Language | Rust | C++ | C | C |
| Graphs | ✅ Beautiful | ✅ Good | ❌ | ❌ |
| Tree View | ✅ | ✅ | ✅ | ❌ |
| Config File | ✅ TOML | ✅ | ⚠️ Limited | ❌ |
| Cross-platform | ✅ | ✅ | ✅ | ❌ |
| Battery | ✅ | ✅ | ❌ | ❌ |
| Search/Filter | ✅ Regex | ✅ | ✅ | ❌ |
| Basic Mode | ✅ | ❌ | N/A | N/A |

## Tips & Tricks

1. **Quick Start**: Run `btm -b` for a simple htop-like interface
2. **Filter Quickly**: Press `/` to instantly filter processes
3. **Freeze Display**: Press `f` to freeze the display while analyzing
4. **Custom Themes**: Create themes that match your terminal color scheme
5. **Performance**: Use basic mode (`-b`) for lower resource usage
6. **Tree View**: Press `t` to see parent-child process relationships
7. **Zoom Graphs**: Use `+` and `-` to zoom in/out on graphs for better detail

## Troubleshooting

### Display Issues

If you experience display problems:
```bash
# Force terminal type
TERM=xterm-256color btm

# Use basic mode
btm -b

# Force redraw
# Press Ctrl+L while running
```

### Configuration Errors

If config file has errors:
```bash
# Regenerate default config
btm --generate_config > ~/.config/bottom/bottom.toml

# Run without config
btm --override_config
```

### High CPU Usage

If bottom uses too much resources:
```bash
# Increase update rate
btm -r 2000  # 2 seconds

# Use basic mode
btm -b
```

### Missing Features

Some features require specific support:
- **GPU monitoring**: Not currently supported
- **Temperature**: Requires sensor access
- **Battery**: Only on laptops with battery support

## References

- [bottom GitHub](https://github.com/ClementTsang/bottom)
- [Official Documentation](https://clementtsang.github.io/bottom/)
- [Configuration Guide](https://clementtsang.github.io/bottom/stable/configuration/config-file/)
- [Changelog](https://github.com/ClementTsang/bottom/blob/main/CHANGELOG.md)
