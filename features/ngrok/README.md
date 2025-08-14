# ngrok DevContainer Feature

Installs [ngrok](https://ngrok.com), a tunneling and reverse proxy service for developing and understanding networked, HTTP services.

## Usage

```json
{
    "features": {
        "ghcr.io/ruanzx/features/ngrok:latest": {}
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version of ngrok to install. Can be `latest` or specific version like `3.18.4` |
| `addToPath` | boolean | `true` | Add ngrok to system PATH for global access |

## Examples

### Basic Installation
```json
{
    "features": {
        "ghcr.io/ruanzx/features/ngrok:latest": {}
    }
}
```

### Specific Version
```json
{
    "features": {
        "ghcr.io/ruanzx/features/ngrok:latest": {
            "version": "3.18.4"
        }
    }
}
```

### Install Without Adding to PATH
```json
{
    "features": {
        "ghcr.io/ruanzx/features/ngrok:latest": {
            "addToPath": false
        }
    }
}
```

## Getting Started with ngrok

After installation, you'll need to set up authentication:

1. **Sign up** for a free account at [ngrok.com](https://ngrok.com)
2. **Get your authtoken** from the [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)
3. **Configure authentication**:
   ```bash
   ngrok config add-authtoken <your-token>
   ```

## Common Use Cases

### Expose Local Web Server
```bash
# Start your local development server
npm start  # or python -m http.server 8000, etc.

# In another terminal, create a tunnel
ngrok http 3000
```

### Expose Local API for Webhook Testing
```bash
# Start your local API server
uvicorn main:app --host 0.0.0.0 --port 8000

# Create a tunnel for webhook endpoints
ngrok http 8000
```

### Secure Tunnels with Basic Auth
```bash
ngrok http 8080 --basic-auth "username:password"
```

### Custom Subdomain (requires paid plan)
```bash
ngrok http 3000 --subdomain myapp
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `ngrok http 8080` | Tunnel HTTP traffic from port 8080 |
| `ngrok tcp 22` | Tunnel TCP traffic from port 22 |
| `ngrok config check` | Verify ngrok configuration |
| `ngrok status` | Show active tunnel status |
| `ngrok help` | Show all available commands |

## Configuration

ngrok stores its configuration in `~/.config/ngrok/ngrok.yml`. You can edit this file to set default options:

```yaml
version: 2
authtoken: <your-authtoken>
tunnels:
  webapp:
    addr: 8080
    proto: http
  api:
    addr: 3000
    proto: http
    auth: "user:password"
```

Start named tunnels with:
```bash
ngrok start webapp
ngrok start api
```

## Web Interface

ngrok provides a local web interface at `http://localhost:4040` when running, where you can:

- Inspect HTTP requests and responses
- Replay requests
- View tunnel status and metrics

## Security Considerations

- **Free accounts** have limitations on concurrent tunnels and request volume
- **Authtoken is sensitive** - don't commit it to version control
- **Public tunnels** are accessible to anyone with the URL
- Use **basic auth or custom domains** for sensitive applications

## Troubleshooting

### Authentication Issues
```bash
# Check if authtoken is set
ngrok config check

# Re-add authtoken if needed
ngrok config add-authtoken <your-token>
```

### Port Already in Use
```bash
# Check what's using the port
lsof -i :4040

# Use different port for ngrok web interface
ngrok http 8080 --web-addr localhost:4041
```

### Connection Issues
- Verify your internet connection
- Check if corporate firewall blocks ngrok
- Try different tunnel protocols (http vs tcp)

## Version Information

This feature installs ngrok v3, which includes:
- Improved performance and reliability
- Better configuration management
- Enhanced security features
- Backward compatibility with v2 commands

For more information, visit the [ngrok documentation](https://ngrok.com/docs).
