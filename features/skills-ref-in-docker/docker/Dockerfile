# Usage:
# docker build -t ruanzx/skills-ref .
# docker run --rm -it ruanzx/skills-ref /bin/sh

FROM python:3.12-slim

# Install git for cloning the repo
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install skills-ref from GitHub
RUN pip install --no-cache-dir git+https://github.com/agentskills/agentskills.git#subdirectory=skills-ref

WORKDIR /output

ENTRYPOINT [ "/usr/local/bin/skills-ref" ]