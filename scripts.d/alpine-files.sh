#!/bin/bash
set -e


echo '#!/bin/sh
set -e
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi
exec "$@"' > ./docker-entrypoint.sh


cat >./Dockerfile <<EOL
# https://stackoverflow.com/a/43743532
# Without NPM

FROM alpine:3.13

ENV NODE_VERSION $IMAGE_VER
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

RUN chmod a+x /usr/local/bin/docker-entrypoint.sh \\
  && cat /etc/alpine-release \\
  # && NODE_DIST="https://nodejs.org/dist" \\
  # && MIRROR="https://uk.alpinelinux.org" \\
  && NODE_DIST="https://npm.taobao.org/dist" \\
  && MIRROR="https://mirrors.tuna.tsinghua.edu.cn" \\
  && sed -i "s#https://dl-cdn.alpinelinux.org#\$MIRROR#g" /etc/apk/repositories \\
  && echo "@edge \$MIRROR/alpine/edge/main" >> /etc/apk/repositories \
  && addgroup -g 1000 node \\
  && adduser -u 1000 -G node -s /bin/sh -D node \\
  && apk add --no-cache curl nodejs=~\$NODE_VERSION \\
  && ln -s /usr/bin/node /usr/bin/nodejs \\
  && node --version \\
  # && sed -i "s#:/bin/ash#:/bin/bash#g" /etc/passwd \\
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
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf 

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]

EOL

