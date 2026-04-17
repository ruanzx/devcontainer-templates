# Spec-Kit in Docker - Runtime Base Image
# Provides Python + uv runtime; spec-kit is installed at container start.
# Documentation: https://github.com/github/spec-kit

# docker build -t ruanzx/spec-kit .

FROM python:3.12-slim

# Set metadata
LABEL maintainer="spec-kit contributors"
LABEL description="Spec-Kit runtime base - Python + uv for spec-driven development"
LABEL org.opencontainers.image.source="https://github.com/github/spec-kit"
LABEL org.opencontainers.image.description="Runtime base for Spec-Kit CLI (spec-kit installed at container start)"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    SPECKIT_VERSION="latest" \
    PATH="/root/.local/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create working directory
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["specify", "--help"]
