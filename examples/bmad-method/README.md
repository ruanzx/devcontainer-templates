# BMAD-METHOD AI Agent Framework Example

This example demonstrates how to set up a development environment with the BMAD-METHOD Universal AI Agent Framework for Agentic Agile Driven Development.

## 🚀 What's Included

This DevContainer provides a complete development environment with:

- **Node.js v20** - Required runtime for BMAD-METHOD
- **BMAD-METHOD Framework** - Universal AI Agent Framework
- **Git** - Version control (required dependency)
- **Zsh with Oh My Zsh** - Enhanced shell experience
- **VS Code Extensions** - Pre-configured for optimal development

## 🎯 Getting Started

### 1. Open in DevContainer

1. Clone this repository
2. Open in VS Code
3. When prompted, click "Reopen in Container"
4. Wait for the container to build and start

### 2. Initialize BMAD-METHOD

The framework is automatically installed in workspace mode. To set up your first project:

```bash
# The framework should already be initialized, but you can run setup again
npx bmad-method install

# Check version
npx bmad-method --version
```

### 3. Start with Web UI (Fastest)

1. **Get a team file**: Save or clone the [full stack team file](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/dist/teams/team-fullstack.txt)
2. **Create AI agent**: Create a new Gemini Gem or CustomGPT
3. **Upload & configure**: Upload the file and set instructions: "Your critical operating instructions are attached, do not break character as directed"
4. **Start planning**: Type `*help` to see available commands or `*analyst` to start creating a brief
5. **Ask questions**: Use `#bmad-orchestrator` command to ask about the workflow

### 4. Development Workflow

#### Planning Phase (Web UI)
- Create Product Requirements Document (PRD)
- Design Architecture documentation  
- Generate UX briefs (optional)

#### Development Phase (IDE)
- Shard documentation into manageable pieces
- Use Scrum Master to create detailed stories
- Implement with Dev agent using story context
- Validate with QA agent

## 🔧 Key Features

### Agentic Planning
- **Analyst Agent**: Collaborates to create detailed briefs
- **PM Agent**: Helps with product management decisions  
- **Architect Agent**: Designs system architecture

### Context-Engineered Development
- **Scrum Master Agent**: Transforms plans into hyper-detailed stories
- **Dev Agent**: Implements features with full context
- **QA Agent**: Validates implementations

### Universal Framework
- Works beyond software development
- Creative writing, business strategy, wellness, education
- Expansion packs for specialized domains

## 📂 Project Structure

After initialization, your project will include:

```
.bmad-core/                    # Core BMAD framework files
├── agents/                    # AI agent definitions
├── templates/                 # Project templates
└── core-config.yaml          # Configuration

docs/                          # Project documentation
├── prd/                      # Product Requirements
├── architecture/             # System architecture
└── stories/                  # Development stories

src/                          # Your source code
```

## 🛠️ Common Commands

```bash
# Check installation
npx bmad-method --version

# Update framework
npx bmad-method install

# Start development server (if applicable)
npm start

# Run tests
npm test
```

## 🌟 What Makes This Special

### Two-Phase Approach
1. **Planning**: Dedicated agents create comprehensive specifications
2. **Development**: Context-engineered stories eliminate information loss

### Beyond Task Running
- Not just a task master or simple task runner
- Full collaborative agent ecosystem
- Human-in-the-loop refinement process

## 📚 Resources

- **Documentation**: [User Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md)
- **Architecture**: [Core Architecture](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/core-architecture.md)
- **Community**: [Discord Server](https://discord.gg/gk8jAdXWmj)
- **Repository**: [GitHub](https://github.com/bmad-code-org/BMAD-METHOD)
- **Expansion Packs**: [Guide](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/expansion-packs.md)

## 🚨 Important Notes

### Prerequisites Met
- ✅ Node.js v20+ (included)
- ✅ npm (included)
- ✅ git (included)

### Installation Mode
This example uses `installWorkspace: true`, which:
- Installs BMAD-METHOD as a local npm dependency
- Runs the interactive setup wizard
- Creates project-specific configuration

### Port Forwarding
The DevContainer forwards these ports:
- **3000**: Development Server
- **8000**: API Server  
- **8080**: Web UI

## 🎮 Try It Out

1. **Start with Planning**: Use the web UI to create your PRD and architecture
2. **Move to Development**: Switch to the IDE for implementation
3. **Leverage Context**: Use the story-based development approach
4. **Iterate**: Refine and improve with agent collaboration

This setup gives you everything needed to experience the full power of Agentic Agile Driven Development with BMAD-METHOD! 🚀

---

💡 **Tip**: Review the [workflow diagrams](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md) to understand how planning and development phases work together.