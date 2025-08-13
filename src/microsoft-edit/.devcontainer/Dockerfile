FROM mcr.microsoft.com/devcontainers/base:${templateOption:imageVariant}

# Microsoft Edit
# - https://github.com/microsoft/edit

ENV EDIT_VERSION=1.2.0
RUN wget -O edit.tar.zst https://github.com/microsoft/edit/releases/download/v${EDIT_VERSION}/edit-${EDIT_VERSION}-x86_64-linux-gnu.tar.zst \
  && unzstd edit.tar.zst \
  && tar -xvf edit.tar \
  && chmod +x edit \
  && mv edit /usr/local/bin/edit \
  && rm -f edit.tar.zst edit.tar