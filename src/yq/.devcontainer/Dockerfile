FROM mcr.microsoft.com/devcontainers/base:${templateOption:imageVariant}

# Install yq
ENV YQ_VERSION=4.40.5
ENV YQ_BINARY=yq_linux_amd64
RUN curl -fsSL -o ${YQ_BINARY}.tar.gz "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${YQ_BINARY}.tar.gz" \
  && tar -xzvf ${YQ_BINARY}.tar.gz \
  && mv ${YQ_BINARY} /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq
