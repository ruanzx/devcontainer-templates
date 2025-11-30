# btop++ Example

This example demonstrates how to use the btop++ feature in a dev container.

## What is btop++?

[btop++](https://github.com/aristocratos/btop) is a resource monitor that shows usage and stats for processor, memory, disks, network and processes. It's a modern alternative to tools like `top` and `htop` with a beautiful, customizable interface.

## Features Included

- ✅ btop++ (version 1.4.5)
- ✅ All available themes
- ✅ Pre-configured and ready to use

## Usage

### Starting btop++

Simply run in your terminal:

```bash
btop
```

### Basic Keyboard Shortcuts

- `q` or `Ctrl+C` - Quit
- `Esc` - Open menu
- `1-4` - Jump to boxes (CPU, Memory, Network, Processes)
- `Tab` / `Shift+Tab` - Navigate between boxes
- `Up/Down` - Select process
- `Enter` - Show detailed process info
- `t` - Toggle tree mode
- `k` - Kill process (SIGTERM)
- `K` - Kill process (SIGKILL)
- `f` - Filter processes
- `h` - Show help
- `+/-` - Change update interval

### Configuration

btop++ stores its configuration in `~/.config/btop/btop.conf`. On first run, a default configuration will be created.

You can customize:
- Color theme (20+ themes available)
- Update interval
- Shown boxes
- Process sorting
- Temperature units
- Network interface
- And much more...

### Changing Themes

1. Press `Esc` to open the menu
2. Use arrow keys to navigate to the theme option
3. Press Enter to see available themes
4. Select your preferred theme

Some popular themes:
- `default` - Default btop++ theme
- `nord` - Nord color scheme
- `gruvbox_dark` - Gruvbox dark theme
- `solarized_dark` - Solarized dark theme
- `dracula` - Dracula theme
- `tokyo-night` - Tokyo Night theme
- `monokai` - Monokai theme

### Advanced Usage

#### Running btop++ with Options

```bash
# Show version
btop --version

# Use specific theme
btop -t nord

# Set update interval (in milliseconds)
btop -u 1000

# Force UTF-8 mode
btop --utf-force

# Help and available options
btop --help
```

#### Monitoring Specific Processes

1. Run btop
2. Press `f` to filter
3. Type process name or pattern
4. Press Enter

#### Tree View for Process Hierarchy

Press `t` in the processes box to toggle tree view, which shows parent-child relationships between processes.

## Verification

After the container is created, verify the installation:

```bash
# Check if btop is installed
which btop

# Check version
btop --version

# List available themes
ls /usr/local/share/btop/themes/
```

## Example Output

When you run `btop`, you'll see:

```
┌─ CPU ─────────────────────────────────┐┌─ Memory ──────────────────────────────┐
│ CPU Usage: 25%                        ││ Used: 2.3 GB / 8.0 GB (29%)          │
│ [████████░░░░░░░░░░░░░░░░░░░░░░]     ││ [████████░░░░░░░░░░░░░░░░░░░░░░]    │
└───────────────────────────────────────┘└───────────────────────────────────────┘
┌─ Network ─────────────────────────────┐┌─ Processes ───────────────────────────┐
│ Download: 1.2 MB/s                    ││ PID   USER      CPU%  MEM%  COMMAND  │
│ Upload:   0.5 MB/s                    ││ 1234  vscode    15.2  2.1   node     │
└───────────────────────────────────────┘└───────────────────────────────────────┘
```

## Tips

1. **Performance**: btop++ is designed to be lightweight, but if you notice high CPU usage, try increasing the update interval with `+` key
2. **Remote Sessions**: btop++ works great over SSH and in dev containers
3. **Customization**: Explore the configuration file to customize btop++ to your needs
4. **Help**: Press `h` anytime to see all available keyboard shortcuts

## Troubleshooting

### btop++ doesn't start

Try running with verbose output:
```bash
btop --debug
```

### Theme doesn't apply

Make sure the theme files are installed:
```bash
ls /usr/local/share/btop/themes/
```

### High CPU usage

Increase the update interval:
- Press `+` multiple times while btop++ is running, or
- Edit `~/.config/btop/btop.conf` and change `update_ms` to a higher value

## References

- [btop++ GitHub](https://github.com/aristocratos/btop)
- [btop++ Documentation](https://github.com/aristocratos/btop#readme)
