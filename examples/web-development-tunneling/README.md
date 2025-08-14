# Web Development with Tunneling Example

This example demonstrates a complete web development environment with tunneling capabilities using ngrok, perfect for:

- **Local development with external access** (webhooks, mobile testing, demos)
- **API development** with third-party service integration
- **Collaborative development** where team members need to access your local server
- **Testing on different devices** without complex network setup

## Features Used

- **Node.js LTS**: Modern JavaScript runtime for web development
- **ngrok**: Tunneling service to expose local servers to the internet
- **APT packages**: Essential development utilities (curl, jq, tree)

## Configuration

The devcontainer includes:

```jsonc
{
  "features": {
    "ghcr.io/devcontainers/features/node:latest": {
      "version": "lts"
    },
    "ghcr.io/ruanzx/features/ngrok:latest": {
      "version": "latest",
      "addToPath": true
    },
    "ghcr.io/ruanzx/features/apt:latest": {
      "packages": "curl,jq,tree",
      "cleanCache": true
    }
  }
}
```

## Quick Start

1. **Create a simple Express server:**
   ```bash
   npm init -y
   npm install express
   ```

2. **Create `server.js`:**
   ```javascript
   const express = require('express');
   const app = express();
   const port = 3000;

   app.get('/', (req, res) => {
     res.json({ 
       message: 'Hello from your tunneled server!',
       timestamp: new Date().toISOString(),
       headers: req.headers
     });
   });

   app.listen(port, () => {
     console.log(`Server running at http://localhost:${port}`);
   });
   ```

3. **Start your server:**
   ```bash
   node server.js
   ```

4. **In another terminal, create a tunnel:**
   ```bash
   # First time setup (you'll need an ngrok account)
   ngrok config add-authtoken <your-ngrok-token>
   
   # Create tunnel
   ngrok http 3000
   ```

## Common Use Cases

### Webhook Development
Perfect for testing webhooks from services like GitHub, Stripe, or Slack:

```bash
# Start your webhook handler
node webhook-server.js

# Create tunnel for webhook endpoint
ngrok http 8080

# Use the https URL in your webhook configuration
# Example: https://abc123.ngrok.io/webhook
```

### Mobile App Testing
Test your local API with mobile devices:

```bash
# Start your API server
npm run dev

# Create tunnel
ngrok http 3000

# Use the ngrok URL in your mobile app settings
```

### Live Demos
Share your work-in-progress with clients or team members:

```bash
# Start your development server
npm start

# Create tunnel with basic auth for security
ngrok http 3000 --basic-auth "demo:password"
```

## Port Configuration

The devcontainer pre-configures common ports:

- **3000**: Main development server
- **8080**: Alternative server port  
- **4040**: ngrok web interface (local only)

Access the ngrok web interface at `http://localhost:4040` to:
- Inspect HTTP requests and responses
- Replay requests for debugging
- View tunnel statistics

## Environment Variables

You can set ngrok configuration via environment variables:

```bash
# In your terminal or .env file
export NGROK_AUTHTOKEN="your-token-here"
export NGROK_REGION="us"  # or eu, ap, au, sa, jp, in
```

## Security Best Practices

1. **Use authentication** for sensitive applications:
   ```bash
   ngrok http 3000 --basic-auth "username:password"
   ```

2. **Limit tunnel duration** for temporary sharing:
   ```bash
   # Tunnel expires after 2 hours
   timeout 7200 ngrok http 3000
   ```

3. **Use specific subdomains** (requires ngrok pro):
   ```bash
   ngrok http 3000 --subdomain myapp
   ```

4. **Monitor access** via the ngrok web interface at localhost:4040

## Development Workflow

### API Development
```bash
# Terminal 1: Start your API
npm run dev:api

# Terminal 2: Create tunnel
ngrok http 8080

# Terminal 3: Test with the public URL
curl https://abc123.ngrok.io/api/users
```

### Frontend + Backend
```bash
# Terminal 1: Start backend
npm run backend

# Terminal 2: Start frontend  
npm run frontend

# Terminal 3: Tunnel backend for external API calls
ngrok http 8080

# Terminal 4: Tunnel frontend for sharing
ngrok http 3000
```

## Advanced ngrok Features

### Configuration File
Create `~/.config/ngrok/ngrok.yml`:

```yaml
version: 2
authtoken: your-token
tunnels:
  web:
    addr: 3000
    proto: http
  api:
    addr: 8080
    proto: http
    auth: "api:secret"
```

Start multiple tunnels:
```bash
ngrok start web api
```

### Custom Domains (Pro/Business)
```bash
ngrok http 3000 --hostname your-domain.com
```

## Troubleshooting

### Tunnel Creation Issues
```bash
# Check ngrok configuration
ngrok config check

# Verify authtoken
ngrok authtoken --list

# Test basic connectivity
ngrok http 80 --log stdout
```

### Port Conflicts
```bash
# Check what's using a port
lsof -i :3000

# Use different port for ngrok web interface
ngrok http 3000 --web-addr localhost:4041
```

## Related Examples

- [Basic All Features](../basic-all-features/) - See all available features
- [APT Packages](../apt-packages/) - System package management
- [Security Tools](../security-tools/) - Security-focused development

This example provides everything you need for modern web development with external access capabilities!
