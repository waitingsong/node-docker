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

FROM alpine:3.12

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
  # && NODE_DIST="https://nodejs.org/dist" \\
  # && MIRROR="https://uk.alpinelinux.org" \\
  && NODE_DIST="https://npm.taobao.org/dist" \\
  && MIRROR="https://mirrors.tuna.tsinghua.edu.cn" \\
  && sed -i "s#http://dl-cdn.alpinelinux.org#\$MIRROR#g" /etc/apk/repositories \\
  && addgroup -g 1000 node \\
  && adduser -u 1000 -G node -s /bin/sh -D node \\
  && apk add --no-cache curl nodejs \\
  && ln -s /usr/bin/node /usr/bin/nodejs \\
  && node --version \\
  # && sed -i "s#:/bin/ash#:/bin/bash#g" /etc/passwd \\
  && echo "alias crontab='crontab -i'; alias ll='ls -l --color=auto'; export XZ_DEFAULTS='-T 0';" > \$ENV \\
  && echo 'export XZ_DEFAULTS="-T 0"' >> /etc/profile \\
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf \\
  && mkdir -p /app

WORKDIR /app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]

EOL

