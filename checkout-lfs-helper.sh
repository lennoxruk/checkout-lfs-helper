#!/bin/bash

set -Euo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

escapeForwardSlash() {
  echo "$1" | sed 's/\//\\\//g'
}

if [[ -z "${INPUT_GITEA_REPO-}" ]]; then
  echo "No gitea repository"
  exit 1
fi

if [[ -z "${INPUT_GITEA_REF-}" ]]; then
  echo "No gitea ref"
  exit 1
fi

readonly replaceStr="escapeForwardSlash ${INPUT_GITEA_REPO}.git/info/lfs/objects/batch"

sed -i "s/\(\[http\)\( \".*\)\"\]/\1\2`${replaceStr}`\"]/" .git/config

git lfs install --local
git config --local lfs.transfer.maxretries 1

git lfs fetch origin "${INPUT_GITEA_REF}"
git lfs checkout
