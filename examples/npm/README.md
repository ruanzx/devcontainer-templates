# npm Global Packages Development Environment

This example demonstrates how to use the npm global packages feature to set up a Node.js development environment with commonly used CLI tools and utilities.

## Features Included

- **Node.js 20** - Latest LTS version of Node.js runtime
- **npm Global Packages** - Essential development tools:
  - `typescript` - TypeScript compiler and language support
  - `nodemon` - Automatic Node.js application restarter
  - `eslint` - JavaScript and TypeScript linter
  - `prettier` - Code formatter
  - `@angular/cli` - Angular CLI for Angular development

## VS Code Extensions

- TypeScript language support
- Prettier code formatter
- ESLint integration
- Angular language service

## Getting Started

1. Open this folder in VS Code with the Dev Containers extension
2. Choose "Reopen in Container" when prompted
3. Wait for the container to build and the tools to install
4. Verify installation with: `npm list -g --depth=0`

## Available CLI Tools

After the container is ready, you can use these globally installed tools:

### TypeScript Development
```bash
# Compile TypeScript files
tsc app.ts

# Check TypeScript version
tsc --version

# Initialize TypeScript project
tsc --init
```

### Node.js Development with Nodemon
```bash
# Run Node.js app with auto-restart
nodemon app.js

# Run TypeScript app with auto-restart
nodemon --exec ts-node app.ts
```

### Code Quality Tools
```bash
# Lint JavaScript/TypeScript files
eslint src/

# Format code with Prettier
prettier --write src/

# Check code formatting
prettier --check src/
```

### Angular Development
```bash
# Create new Angular project
ng new my-app

# Generate Angular components
ng generate component my-component

# Serve Angular application
ng serve

# Build Angular application
ng build
```

## Sample Projects

### TypeScript Node.js Project

Create a simple TypeScript Node.js application:

```bash
# Initialize npm project
npm init -y

# Install local dependencies
npm install express
npm install -D @types/express @types/node

# Create TypeScript config
tsc --init

# Create app.ts
cat > app.ts << 'EOF'
import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from TypeScript Node.js!');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
EOF

# Run with nodemon
nodemon --exec ts-node app.ts
```

### Angular Project

Create a new Angular application:

```bash
# Create new Angular app
ng new my-angular-app --routing --style=css

# Navigate to project
cd my-angular-app

# Serve the application
ng serve --host 0.0.0.0 --port 4200
```

### Express API with TypeScript

```bash
# Initialize project
npm init -y

# Install dependencies
npm install express cors helmet
npm install -D typescript @types/node @types/express @types/cors @types/helmet ts-node

# Initialize TypeScript
tsc --init

# Create server.ts
cat > server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
  ]);
});

app.listen(port, () => {
  console.log(`API server running at http://localhost:${port}`);
});
EOF

# Run with nodemon
nodemon --exec ts-node server.ts
```

## Package Configuration

The example installs these packages by default:

```json
{
  "packages": "typescript,nodemon,eslint,prettier,@angular/cli",
  "installLatest": true,
  "updateNpm": false
}
```

## Customization

You can modify the `.devcontainer/devcontainer.json` file to:

### Add More Packages
```json
{
  "packages": "typescript,nodemon,eslint,prettier,@vue/cli,create-react-app,webpack"
}
```

### Use Specific Versions
```json
{
  "packages": "typescript@4.9.5,@angular/cli@15.0.0",
  "installLatest": false
}
```

### Use Custom Registry
```json
{
  "packages": "typescript,company-tool",
  "registry": "https://npm.company.com"
}
```

## Port Configuration

The example configures these ports:
- **3000**: Node.js applications
- **4200**: Angular development server
- **8080**: General development server

## Verification Commands

```bash
# List installed global packages
npm list -g --depth=0

# Check individual tool versions
tsc --version
nodemon --version
eslint --version
prettier --version
ng version

# Test TypeScript compilation
echo "console.log('Hello TypeScript');" > test.ts
tsc test.ts
node test.js
```

## Troubleshooting

### Tools Not Found
If CLI tools are not available:
1. Check if they were installed: `npm list -g --depth=0`
2. Restart your terminal or reload VS Code window
3. Rebuild the container

### Permission Issues
The feature handles global package installation during container build with appropriate permissions.

### Package Installation Failures
If specific packages fail to install:
1. Check package names in npm registry
2. Try with simplified package list first
3. Check network connectivity

## Development Workflow

1. **Container Setup**: Open in Dev Container and wait for build
2. **Project Initialization**: Use CLI tools to create new projects
3. **Development**: Write code with TypeScript, linting, and formatting
4. **Testing**: Use nodemon for live reloading during development
5. **Building**: Use TypeScript compiler and build tools for production

## Related Examples

- [Basic All Features](../basic-all-features/): Comprehensive development environment
- [Web Development with Tunneling](../web-development-tunneling/): Frontend development with ngrok
- [Performance Testing](../performance-testing/): Testing with k6

## Notes

- All packages are installed globally and available system-wide
- CLI tools are immediately available in PATH
- The container uses Node.js 20 LTS for stability
- VS Code extensions are configured for optimal TypeScript and Node.js development