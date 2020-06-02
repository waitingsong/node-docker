#!/usr/bin/env bash
set -e

cat >./Dockerfile <<EOL

FROM waitingsong/node:docker

RUN set -xe \\
  && cat /etc/alpine-release \\
  && apk add --no-cache ansible \\
  && ansible --version \\
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf 

EOL

