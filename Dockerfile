
FROM waitingsong/node:docker

RUN set -xe \
  && apk add --no-cache ansible \
  && ansible --version \
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf 

