#!/usr/bin/env bash
# Example usage script for spec-kit Docker container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Display menu
echo "================================"
echo "  Spec-Kit Docker Examples"
echo "================================"
echo ""
echo "1. Build the Docker image"
echo "2. Check installed tools"
echo "3. Initialize a new project"
echo "4. Run interactive shell"
echo "5. Show spec-kit version"
echo "6. Run with docker-compose"
echo "7. Clean up images"
echo "0. Exit"
echo ""
read -p "Select an option: " choice

case $choice in
    1)
        info "Building spec-kit Docker image..."
        docker build -t spec-kit:latest -f Dockerfile .
        success "Image built successfully!"
        ;;
    
    2)
        info "Checking installed tools..."
        docker run --rm spec-kit:latest specify check
        ;;
    
    3)
        read -p "Enter project name: " project_name
        read -p "Enter AI agent (copilot/claude/gemini/cursor/etc): " ai_agent
        
        info "Initializing project '$project_name' with $ai_agent..."
        
        # Create project directory
        mkdir -p "$project_name"
        cd "$project_name"
        
        # Run initialization
        docker run -it --rm \
            -v "$(pwd):/workspace" \
            -w /workspace \
            spec-kit:latest \
            specify init --here --ai "$ai_agent"
        
        success "Project initialized in $project_name/"
        info "Next steps:"
        echo "  1. cd $project_name"
        echo "  2. Open with your AI coding agent"
        echo "  3. Start using /speckit.* commands"
        ;;
    
    4)
        info "Starting interactive shell..."
        info "You can now use 'specify' commands inside the container"
        
        docker run -it --rm \
            -v "$(pwd):/workspace" \
            -w /workspace \
            spec-kit:latest \
            bash
        ;;
    
    5)
        info "Checking spec-kit version..."
        docker run --rm spec-kit:latest specify --version 2>/dev/null || \
            warning "Build the image first with option 1"
        ;;
    
    6)
        info "Starting with docker-compose..."
        if [ ! -f "docker-compose.yml" ]; then
            error "docker-compose.yml not found in current directory"
            exit 1
        fi
        
        docker-compose up -d
        docker-compose exec spec-kit bash
        
        info "Stopping docker-compose..."
        docker-compose down
        ;;
    
    7)
        warning "Cleaning up spec-kit Docker images..."
        docker rmi spec-kit:latest 2>/dev/null || info "No images to remove"
        success "Cleanup complete!"
        ;;
    
    0)
        info "Exiting..."
        exit 0
        ;;
    
    *)
        error "Invalid option"
        exit 1
        ;;
esac

echo ""
success "Done!"
