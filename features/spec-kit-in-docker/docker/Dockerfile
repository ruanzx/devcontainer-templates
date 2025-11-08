# Spec-Kit in Docker
# A containerized version of spec-kit for spec-driven development
# Documentation: https://github.com/github/spec-kit

FROM python:3.12-slim

# Set metadata
LABEL maintainer="spec-kit contributors"
LABEL description="Spec-Kit - A toolkit for spec-driven development with AI coding agents"
LABEL org.opencontainers.image.source="https://github.com/github/spec-kit"
LABEL org.opencontainers.image.description="Containerized Spec-Kit CLI with uv package manager"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/root/.local/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install spec-kit CLI using uv
RUN /root/.local/bin/uv tool install specify-cli \
    --from git+https://github.com/github/spec-kit.git

# Create working directory
WORKDIR /workspace

# Set the default command to display help
CMD ["specify", "--help"]
