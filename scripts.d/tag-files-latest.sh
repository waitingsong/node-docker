#!/bin/bash
set -e

cat >./Dockerfile <<EOL

FROM node:latest

ENV ENV "/root/.ashrc"

RUN set -xe \\
  && echo "alias crontab='crontab -i'; \\
    alias ll='ls -l --color=auto'; \\
    alias time='/usr/bin/time '; \\
    alias ztar='tar -I zstdmt'; \\
    export XZ_DEFAULTS='-T 0 -4'; \\
    export ZSTD_CLEVEL=9; \\
    " > \$ENV \\
  && echo "export XZ_DEFAULTS='-T 0 -4'; \\
    export ZSTD_CLEVEL=9; \\
    " >> /etc/profile \\
  && apt-get update \\
  && apt-get -yq install curl git jq openssh-server tar zstd \\
  && apt-get -yq clean \\
  && git --version \\
  && node -v \\
  && npm -v \\
  && ssh -V \\
  && yarn -v \\
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf \\
  && mkdir -p /app
 
EOL

