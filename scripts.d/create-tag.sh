#!/usr/bin/env bash
set -e

IMAGE_TAG="${1:-}"
TAGS="$IMAGE_TAG"
BR="image-$TAGS"

if [[ ! -z ${IMAGE_TAG} ]]; then

  while true; do
    echo -n "[Question] "; read -e -p "Tag '$TAGS'. Do you want to continue? [y|n] " -i "" yn
    case ${yn} in
      [Nn]*) exit 1;;
      [Yy]*) break;;
      *)     echo 'Please answer (y)es or (n)o';;
    esac;
  done;

  source scripts.d/tag-files-$IMAGE_TAG.sh

  rm scripts.d -rf
  git checkout --orphan "$BR"
  git rm -rf .
  git add .
  git commit -m "feat: create Dockerfile with tag: $TAGS"
  git push -f --set-upstream origin "$BR"
  git checkout master
else
  echo '[ERR] Tag name not passed. Tag should looks like "latest" | "docker" | "ansible" | "alpine" '
fi

