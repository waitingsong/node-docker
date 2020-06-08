#!/bin/bash
set -e


echo '#!/bin/sh
set -e
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi
exec "$@"' > ./docker-entrypoint.sh


cat >./Dockerfile <<EOL
# https://github.com/nodejs/docker-node/blob/master/14/alpine3.11/Dockerfile
# https://stackoverflow.com/a/43743532

FROM alpine:3.12

ENV NODE_VERSION 14.4.0
ENV ENV "/root/.ashrc"

# Mirrors
# http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt
# https://uk.alpinelinux.org/alpine/
# https://mirrors.tuna.tsinghua.edu.cn/alpine/
# https://mirrors.sjtug.sjtu.edu.cn/alpine/
# https://mirrors.ustc.edu.cn/alpine/
# https://mirrors.nju.edu.cn/alpine/
# https://mirror.lzu.edu.cn/alpine/

COPY docker-entrypoint.sh /usr/local/bin/

RUN cat /etc/alpine-release \\
  && chmod a+x /usr/local/bin/docker-entrypoint.sh \\
  # && NODE_DIST="https://nodejs.org/dist" \\
  # && MIRROR="https://uk.alpinelinux.org" \\
  && NODE_DIST="https://npm.taobao.org/dist" \\
  && MIRROR="https://mirrors.tuna.tsinghua.edu.cn" \\
  && sed -i "s#http://dl-cdn.alpinelinux.org#\$MIRROR#g" /etc/apk/repositories \\
  && addgroup -g 1000 node \\
    && adduser -u 1000 -G node -s /bin/sh -D node \\
    && apk add --no-cache \\
        libstdc++ \\
    && apk add --no-cache --virtual .build-deps \\
        curl \\
    && ARCH= && alpineArch="\$(apk --print-arch)" \\
      && case "\${alpineArch##*-}" in \\
        x86_64) \\
          ARCH='x64' \\
          CHECKSUM="c33037cadcd6caab8593b1b3f8befad6137b621378462fad24b4100eba879e4c" \\
          ;; \\
        *) ;; \\
      esac \\
  && if [ -n "\${CHECKSUM}" ]; then \\
    set -eu; \\
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v\$NODE_VERSION/node-v\$NODE_VERSION-linux-\$ARCH-musl.tar.xz"; \\
    echo "\$CHECKSUM  node-v\$NODE_VERSION-linux-\$ARCH-musl.tar.xz" | sha256sum -c - \\
      && tar -xJf "node-v\$NODE_VERSION-linux-\$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \\
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \\
  else \\
    echo "Building from source" \\
    # backup build
    && apk add --no-cache --virtual .build-deps-full \\
        binutils-gold \\
        g++ \\
        gcc \\
        gnupg \\
        libgcc \\
        linux-headers \\
        make \\
        python \\
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \\
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \\
      FD3A5288F042B6850C66B31F09FE44734EB7990E \\
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \\
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \\
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \\
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \\
      77984A986EBC2AA786BC0F66B01FBB92821C587A \\
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \\
      4ED778F539E3634C779C87C6D7062848A1AB005C \\
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \\
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \\
    ;  do \\
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "\$key" || \\
      gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "\$key" || \\
      gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "\$key" ; \\
    done \\
    && curl -fsSLO --compressed "\$NODE_DIST/v\$NODE_VERSION/node-v\$NODE_VERSION.tar.xz" \\
    && curl -fsSLO --compressed "\$NODE_DIST/v\$NODE_VERSION/SHASUMS256.txt.asc" \\
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \\
    && grep " node-v\$NODE_VERSION.tar.xz\\$" SHASUMS256.txt | sha256sum -c - \\
    && tar -xf "node-v\$NODE_VERSION.tar.xz" \\
    && cd "node-v\$NODE_VERSION" \\
    && ./configure \\
    && make -j\$(getconf _NPROCESSORS_ONLN) V= \\
    && make install \\
    && apk del .build-deps-full \\
    && cd .. \\
    && rm -Rf "node-v\$NODE_VERSION" \\
    && rm "node-v\$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \\
  fi \\
  && rm -f "node-v\$NODE_VERSION-linux-\$ARCH-musl.tar.xz" \\
  && apk del .build-deps \\
  # smoke tests
  && node --version \\
  && npm --version \\
  && apk add --no-cache curl tar zstd \\
  # && sed -i "s#:/bin/ash#:/bin/bash#g" /etc/passwd \\
  && echo "alias crontab='crontab -i'; \\
    alias ll='ls -l --color=auto'; \\
    alias time='/usr/bin/time '; \\
    alias ztar='tar -I zstdmt'; \\
    export XZ_DEFAULTS='-T 0'; \\
    export ZSTD_CLEVEL=9; \\
    " > \$ENV \\
  && echo "export XZ_DEFAULTS='-T 0'; \\
    export ZSTD_CLEVEL=9; \\
    " >> /etc/profile \\
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf \\
  && rm /usr/local/include/node -rf \\
  && cd /usr/local/lib/node_modules/ \\
  && find . -type d -iname "docs" -print0 | xargs -0i rm -rf {} \\
  && find . -type d -iname "example" -print0 | xargs -0i rm -rf {} \\
  && find . -type d -iname "test" -print0 | xargs -0i rm -rf {} \\
  && find . -type f -iname ".coveralls.yml" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".DS_Store" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".dockerignore" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".editorconfig" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".eslint*" -print0 | xargs -0i rm -f {} \\
  && find . -type f -iname ".github" -print0 | xargs -0i rm -f {} \\
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
  && cd - \\
  && mkdir -p /app

WORKDIR /app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]

EOL

