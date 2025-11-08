.PHONY: help build run shell check init clean

# Default target
help:
	@echo "Spec-Kit Docker Management"
	@echo ""
	@echo "Usage:"
	@echo "  make build          Build the spec-kit Docker image"
	@echo "  make run            Run spec-kit container interactively"
	@echo "  make shell          Open a shell in the container"
	@echo "  make check          Check installed tools"
	@echo "  make init           Initialize a new project"
	@echo "  make clean          Remove built images"
	@echo ""

# Build the Docker image
build:
	@echo "🔨 Building spec-kit Docker image..."
	docker build -t spec-kit:latest -f Dockerfile .
	@echo "✅ Build complete!"

# Run container interactively
run:
	@echo "🚀 Starting spec-kit container..."
	docker run -it --rm \
		-v $$(pwd):/workspace \
		-w /workspace \
		spec-kit:latest bash

# Open shell in container
shell: run

# Check installed tools
check:
	@echo "🔍 Checking installed tools..."
	docker run --rm spec-kit:latest specify check

# Initialize a new project
init:
	@echo "📦 Initializing new spec-kit project..."
	@read -p "Enter project name: " project_name; \
	read -p "Enter AI agent (copilot/claude/gemini/etc): " ai_agent; \
	docker run -it --rm \
		-v $$(pwd):/workspace \
		-w /workspace \
		spec-kit:latest \
		specify init $$project_name --ai $$ai_agent

# Clean up Docker images
clean:
	@echo "🧹 Cleaning up Docker images..."
	docker rmi spec-kit:latest || true
	@echo "✅ Cleanup complete!"

# Show version
version:
	@docker run --rm spec-kit:latest specify --version 2>/dev/null || echo "Run 'make build' first"

# Run with docker-compose
compose-up:
	@echo "🐳 Starting with docker-compose..."
	docker-compose up -d
	docker-compose exec spec-kit bash

compose-down:
	@echo "🛑 Stopping docker-compose services..."
	docker-compose down
