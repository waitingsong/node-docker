#!/bin/bash
set -e

cat >./Dockerfile <<EOL

FROM docker:latest

# Mirrors
# http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt
# https://uk.alpinelinux.org/alpine/
# https://mirrors.tuna.tsinghua.edu.cn/alpine/
# https://mirrors.sjtug.sjtu.edu.cn/alpine/
# https://mirrors.ustc.edu.cn/alpine/
# https://mirrors.nju.edu.cn/alpine/
# https://mirror.lzu.edu.cn/alpine/

ENV ENV "/root/.ashrc"

RUN set -xe \\
  && cat /etc/alpine-release \\
  && MIRROR="https://mirrors.tuna.tsinghua.edu.cn" \\
  && sed -i "s#http://dl-cdn.alpinelinux.org#\$MIRROR#g" /etc/apk/repositories \\
  && echo "@edge \$MIRROR/alpine/edge/main" >> /etc/apk/repositories \\
  && apk add bash curl git jq nodejs@edge npm@edge openssh postgresql-client@edge tar tzdata zstd \\
  && sed -i "s#:/bin/ash#:/bin/bash#g" /etc/passwd \\
  && echo "alias crontab='crontab -i'; \\
    alias ll='ls -l --color=auto'; \\
    alias time='/usr/bin/time '; \\
    alias tarz='tar -I zstdmt'; \\
    export XZ_DEFAULTS='-T 0 -4'; \\
    export ZSTD_CLEVEL=9; \\
    " > \$ENV \\
  && echo "export XZ_DEFAULTS='-T 0 -4'; \\
    export ZSTD_CLEVEL=9; \\
    " >> /etc/profile \\
  && cp /root/.ashrc /root/.bashrc \\
  && echo "alias sh='/bin/bash ';" >> /root/.bashrc \\
  && npm config set registry https://registry.npm.taobao.org \\
  && docker -v \\
  && bash --version \\
  && npm -v && node -v \\
  && ssh -V \\
  && tar --version \\
  && git --version \\
  && npm i -g lerna && lerna -v \\
  && rm /usr/local/include/node -rf \\
  && cd \$(npm -g root) \\
  && rm ./npm/man -rf \\
  && find . -type d -iname "docs" -print0 | xargs -0i rm -rf {} \\
  && find . -type d -iname "example" -print0 | xargs -0i rm -rf {} \\
  && find . -type d -iname "test" -print0 | xargs -0i rm -rf {} \\
  && find . -type f -iname ".coveralls.yml" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".DS_Store" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".dockerignore" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".editorconfig" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".eslint*" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".github" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".jshintrc" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".jscs.json" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".jscsrc" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".npmignore" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".prettierrc*" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".travis.yml" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".tslint*" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".vscode" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "appveyor.yml" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "docker-compose.yml" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "CHANGELOG*" -print0 | xargs -0i rm -rf {} \\
  && find . -type f -iname "Makefile" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "package-lock.json" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "yarn.lock" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "*.d.ts" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "*.html" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "*.markdown" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "*.md" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "*.swp" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname "LICENCE*" -print0 | xargs -0i gzip {} \\
  && find . -type f -iname "LICENSE*" -print0 | xargs -0i gzip {} \\
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf 
 

CMD ["bash"]

EOL

