# Reference: https://github.com/mingrammer/diagrams/blob/master/docker/dev/Dockerfile
# docker build -t ruanzx/diagrams .
# docker run --rm -it ruanzx/diagrams /bin/sh

FROM python:3.13.3-alpine3.20

RUN apk add --no-cache graphviz && \
    pip install diagrams graphviz

WORKDIR /output

ENTRYPOINT [ "/usr/local/bin/diagrams" ]