FROM mcr.microsoft.com/devcontainers/base:${templateOption:imageVariant}

# Install common packages
# k9s:
#   https://k9scli.io/topics/install/
#   https://k9scli.io/topics/commands/

ENV K9S_VERSION=0.50.9
RUN wget -O k9s_Linux_x86_64.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz \
  && mkdir -p k9s && tar -zxvf k9s_Linux_x86_64.tar.gz -C k9s \
  && mv k9s/k9s /usr/local/bin/ \
  && chmod +x /usr/local/bin/k9s \
  && rm -Rf k9s