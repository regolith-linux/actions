#!/usr/bin/env bash

set -e

VOULAGE_PATH="/tmp/voulage-actions-repo"
VOULAGE_REPO="https://github.com/regolith-linux/voulage.git"

if [ -z "$VOULAGE_REF" ]; then
  echo "Error: ref is missing"
  exit 1
fi

if [ ! -d "$VOULAGE_PATH" ]; then
  git clone --quiet --no-tags --branch "$VOULAGE_REF" "$VOULAGE_REPO" "$VOULAGE_PATH"
else
  pushd "$VOULAGE_PATH" >/dev/null || exit 1

  git fetch
  git checkout --quiet "$VOULAGE_REF"
  git pull --quiet

  popd >/dev/null || exit 1
fi

# shellcheck disable=SC2086
echo "path=$VOULAGE_PATH" >> $GITHUB_OUTPUT
