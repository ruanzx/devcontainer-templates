# Usage:
# docker build -t ruanzx/openspec .
# docker run --rm -it ruanzx/openspec /bin/sh

FROM node:25-alpine

RUN npm install -g @fission-ai/openspec

ENTRYPOINT [ "/usr/local/bin/openspec" ]

CMD [ "help" ]