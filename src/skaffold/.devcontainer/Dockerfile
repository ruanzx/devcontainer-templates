FROM mcr.microsoft.com/devcontainers/base:${templateOption:imageVariant}

# Install Skaffold
ENV SKAFFOLD_VERSION=2.16.1
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 \
  && chmod +x skaffold \
  && mv skaffold /usr/local/bin/