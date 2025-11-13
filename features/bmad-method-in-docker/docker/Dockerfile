# Usage:
# docker build -t ruanzx/bmad .
# docker run --rm -it ruanzx/bmad /bin/sh

FROM node:25-alpine

RUN npm install -g bmad-method

ENTRYPOINT [ "/usr/local/bin/bmad" ]

CMD [ "help" ]