
FROM waitingsong/node:12.12-alpine

RUN set -xe \
  && apk add curl jq openssh tar xz \
  # && npm config set registry https://registry.npm.taobao.org \
  && bash --version \
  && ssh -V \
  && npm -v && node -v \
  && tar --version \
  && rm /var/cache/apk/* -rf 
 
CMD ["bash"]

