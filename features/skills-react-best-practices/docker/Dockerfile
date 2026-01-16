# Usage:
# docker build -t ruanzx/skills-react-best-practices .
# docker run --rm -it ruanzx/skills-react-best-practices /bin/sh

FROM node:25-alpine

RUN apk update \
  && apk add git

WORKDIR /app
RUN npx add-skill -y vercel-labs/agent-skills