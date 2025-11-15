# Usage:
# docker build -t ruanzx/tldr .
# docker run --rm -it ruanzx/tldr /bin/sh

FROM node:25-alpine

RUN npm install -g tldr \
  && tldr --update

ENTRYPOINT [ "/usr/local/bin/tldr" ]

CMD [ "--help" ]