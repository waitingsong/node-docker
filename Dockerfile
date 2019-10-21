
FROM waitingsong/node:12.12.0-alpine

RUN set -xe \
  && apk add git jq openssh tar xz \
  # && npm config set registry https://registry.npm.taobao.org \
  && bash --version \
  && ssh -V \
  && npm -v && node -v \
  && tar --version \
  && npm i -g lerna \
  && cd $(npm -g root) \
  && find . -type d -iname "docs" -print0 | xargs -0i rm -rf {} \
  && find . -type d -iname "example" -print0 | xargs -0i rm -rf {} \
  && find . -type d -iname "test" -print0 | xargs -0i rm -rf {} \
  && find . -type f -iname ".editorconfig" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname ".eslint*" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname ".prettierrc*" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname ".travis.yml" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "appveyor.yml" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "CHANGELOG*" -print0 | xargs -0i rm -rf {} \
  && find . -type f -iname "Makefile" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "package-lock.json" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "yarn.lock" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "*.html" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "*.markdown" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "*.md" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "*.swp" -print0 | xargs -0i rm -f {} \
  && find . -type f -iname "LICENCE*" -print0 | xargs -0i gzip {} \
  && find . -type f -iname "LICENSE*" -print0 | xargs -0i gzip {} \
  && rm /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* -rf 
 
CMD ["bash"]

