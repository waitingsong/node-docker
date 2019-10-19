
FROM node:12.12-alpine

# Mirrors
# http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt
# https://uk.alpinelinux.org/alpine/
# https://mirrors.tuna.tsinghua.edu.cn/alpine/
# https://mirrors.sjtug.sjtu.edu.cn/alpine/
# https://mirrors.ustc.edu.cn/alpine/
# https://mirrors.nju.edu.cn/alpine/
# https://mirror.lzu.edu.cn/alpine/

ENV BRC="root/.bashrc"

RUN set -xe \
  && MIRROR="https://uk.alpinelinux.org" \
  && sed -i "s#http://dl-cdn.alpinelinux.org#$MIRROR#g" /etc/apk/repositories \
  && apk add bash curl jq openssh tar tzdata xz \
  && sed -i "s#:/bin/ash#:/bin/bash#g" /etc/passwd \
  && echo "alias crontab='crontab -i'; alias ll='ls -l --color=auto'; export XZ_DEFAULTS='-T 0';" > $BRC \
  && echo 'export XZ_DEFAULTS="-T 0"' >> /etc/profile \
  #&& npm config set registry https://registry.npm.taobao.org \
  && bash --version \
  && ssh -V \
  && npm -v && node -v \
  && tar --version \
  && rm /var/cache/apk/* -rf \
  && mkdir -p /app
 
WORKDIR /app
CMD ["bash"]

