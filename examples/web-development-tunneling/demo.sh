#!/bin/bash

# Web Development with Tunneling Demo Script
# This script demonstrates ngrok tunneling capabilities

echo "🌐 Web Development with Tunneling Demo"
echo "======================================"
echo

echo "📦 Checking installed tools..."
echo

# Check each tool
tools=("node" "npm" "ngrok" "curl" "jq" "tree")

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        version=$(case "$tool" in
            "node") node --version ;;
            "npm") npm --version ;;
            "ngrok") ngrok version 2>&1 | head -n1 ;;
            "curl") curl --version 2>&1 | head -n1 ;;
            "jq") jq --version ;;
            "tree") tree --version 2>&1 | head -n1 ;;
        esac)
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: Not found"
    fi
done

echo
echo "🚀 Quick Start Example:"
echo "======================"
echo

# Create a simple Express app
echo "📝 Creating a simple Express server..."
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware to log requests
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Basic routes
app.get('/', (req, res) => {
    res.json({
        message: 'Hello from your tunneled server! 🚀',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        headers: {
            'user-agent': req.headers['user-agent'],
            'x-forwarded-for': req.headers['x-forwarded-for'],
            'x-forwarded-proto': req.headers['x-forwarded-proto']
        }
    });
});

app.get('/api/status', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        version: process.version
    });
});

app.get('/webhook', (req, res) => {
    console.log('Webhook received:', req.headers, req.query);
    res.json({
        message: 'Webhook received successfully',
        timestamp: new Date().toISOString(),
        headers: req.headers,
        query: req.query
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`🌐 Server running at http://localhost:${port}`);
    console.log(`📊 View requests at http://localhost:4040 (ngrok web interface)`);
    console.log(`🔗 To create tunnel: ngrok http ${port}`);
});
EOF

# Create package.json
echo "📦 Creating package.json..."
cat > package.json << 'EOF'
{
  "name": "tunneling-demo",
  "version": "1.0.0",
  "description": "Demo server for ngrok tunneling",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

echo
echo "📋 Files created:"
echo "  - server.js (Express server with demo endpoints)"
echo "  - package.json (Node.js project configuration)"
echo

echo "🎯 Next Steps:"
echo "=============="
echo "1. Install dependencies:"
echo "   npm install"
echo
echo "2. Start the server:"
echo "   npm start"
echo
echo "3. In another terminal, create ngrok tunnel:"
echo "   # First time setup (requires ngrok account):"
echo "   ngrok config add-authtoken <your-token>"
echo "   # Then create tunnel:"
echo "   ngrok http 3000"
echo
echo "4. Test your tunneled endpoints:"
echo "   - Main endpoint: GET /"
echo "   - Health check: GET /api/status"
echo "   - Webhook test: GET /webhook?test=true"
echo
echo "💡 Pro Tips:"
echo "============"
echo "• Access ngrok web interface at http://localhost:4040"
echo "• Use the HTTPS URL from ngrok for webhook testing"
echo "• Add basic auth: ngrok http 3000 --basic-auth 'user:pass'"
echo "• Monitor requests in real-time via the web interface"
echo
echo "🔗 Useful ngrok commands:"
echo "========================"
echo "ngrok http 3000              # Basic tunnel"
echo "ngrok http 3000 --subdomain myapp  # Custom subdomain (pro)"
echo "ngrok config check           # Verify configuration"
echo "ngrok status                 # Show tunnel status"
echo
echo "Happy tunneling! 🚀"
