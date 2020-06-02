# `Node.js` images with additional useful applications 

`Node.js` docker image creating script, forked from [`tarampampam/node-docker`].

[![License][license_badge]][license_link]


## Why this image created?

Base [`node`][link_base_node_image] images does not contains additional utils such as `git`.

Applications from base apline images:
- `node`
- `curl`
- `zstd`

Additional applications list for ci images:
- `bash`
- `git`
- `jq`
- `lerna`
- `npm`
- `openssh`
- `tar`
- `tzdata`
- `xz`

Additional configuations list:
- use cdn `https://uk.alpinelinux.org/` with `https` instead of default `http://dl-cdn.alpinelinux.org`

> Page on `hub.docker.com` can be [found here][link_hub].


## How can I use this?

For example:

```sh
docker run --rm \
  --volume "$PWD:/app" \
  --workdir "/app" \
  --user "$(id -u):$(id -g)" \
  waitingsong/node:alpine \
  npm install
```

Or using with `docker-compose.yml`:

```yml
services:
  node:
    image: waitingsong/node:alpine
    volumes:
    - ./src:/app:rw
    working_dir: /app
    command: []
```

## Create
```sh
./scripts.d/create-alpine.sh <version>
./scripts.d/create-ci.sh <version>
./scripts.d/create-tag.sh
```

## License

[MIT](LICENSE)


[`tarampampam/node-docker`]: https://github.com/tarampampam/node-docker 

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT

[link_base_node_image]: https://hub.docker.com/_/node?tab=tags
[link_hub]: https://hub.docker.com/r/waitingsong/node/
