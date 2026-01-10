FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install basic utilities
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        ca-certificates \
        python3 \
        python3-pip \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
