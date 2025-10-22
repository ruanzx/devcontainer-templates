# Optimized DevContainer base image for fast builds
# Includes popular frameworks and programming languages
# docker build -t ruanzx/devcontainers-base:ubuntu-22.04 .
# docker run --rm ruanzx/devcontainers-base:ubuntu-22.04 python3 --version
# docker push ruanzx/devcontainers-base:ubuntu-22.04
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies and common development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    tar \
    gzip \
    jq \
    tree \
    htop \
    net-tools \
    dnsutils \
    telnet \
    iputils-ping \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    zlib1g-dev \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Install Python with essential packages (using system Python 3.10)
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
        wheel \
        setuptools \
        requests \
        pyyaml \
        black \
        pytest

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript ts-node yarn && \
    rm -rf /var/lib/apt/lists/*

# Install .NET 8 LTS
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1) && \
    curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" | tar -xzC /usr/local

# Install Java OpenJDK 17
RUN apt-get update && apt-get install -y openjdk-17-jdk maven && \
    rm -rf /var/lib/apt/lists/*

# Install yq for YAML processing
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Set up environment variables
RUN echo 'export PATH=/usr/local/go/bin:$PATH' >> /etc/environment && \
    echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> /etc/environment && \
    echo 'export DOTNET_ROOT=/usr/share/dotnet' >> /etc/environment

# Clean up
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]



