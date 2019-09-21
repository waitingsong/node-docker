#!/bin/bash
set -e

IMAGE_VER="${1:-}"
IMAGE_TAG=alpine
TAGS="$IMAGE_VER-$IMAGE_TAG"
BR="image-$TAGS"

if [[ ! -z ${IMAGE_VER} ]]; then

  while true; do
    echo -n "[Question] "; read -e -p "Tag '$TAGS'. Do you want to continue? [y|n] " -i "" yn
    case ${yn} in
      [Nn]*) exit 1;;
      [Yy]*) break;;
      *)     echo 'Please answer (y)es or (n)o';;
    esac;
  done;

  source scripts.d/alpine-files.sh

  rm scripts.d -rf
  git checkout --orphan "$BR"
  git rm -rf .
  git add .
  git commit -m "feat: create Dockerfile with tag: $TAGS"
  git push -f --set-upstream origin "$BR"
  git checkout master
else
  echo '[ERR] Tag name not passed. Tag should looks like "12.13.0" (without any prefix or postfix)'
fi
