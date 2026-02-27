# DOCKER_BUILDKIT=0
# docker buildx build -t ruanzx/markitdown:0.1.5 .
# docker tag ruanzx/markitdown:0.1.5 ruanzx/markitdown:latest
# docker run --rm -it --entrypoint /bin/bash ruanzx/markitdown:0.1.5
# docker run --rm -it -v $(pwd)/:/data --entrypoint /bin/bash ruanzx/markitdown:0.1.5
#    markitdown /data/1.docx -o /data/1.md
#    markitdown /data/2.pdf -x pdf -o /data/2.md
# docker run --rm -it -v $(pwd)/:/data ruanzx/markitdown:0.1.5 /data/1.docx -o /data/1.md
# docker run --rm -i ruanzx/markitdown:0.1.5 < ./data/1.docx > ./data/1.md

FROM python:3.13-slim-bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV FFMPEG_PATH=/usr/bin/ffmpeg

# Runtime dependency
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ffmpeg \
    exiftool git

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

FROM base AS builder

ENV MARKITDOWN_VERSION=0.1.5

WORKDIR /src
RUN git clone -b v${MARKITDOWN_VERSION} https://github.com/microsoft/markitdown.git .
RUN pip install -e 'packages/markitdown[all]'

WORKDIR /data
ENTRYPOINT [ "/usr/local/bin/markitdown" ]