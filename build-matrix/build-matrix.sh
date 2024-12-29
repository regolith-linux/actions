#!/usr/bin/env bash

set -e

if [ -z "$VOULAGE_PATH" ]; then
  echo "Error: voulage-path is empty"
  exit 1
fi

pushd "$VOULAGE_PATH" >/dev/null || exit 1

echo "Supported distro/codename:"

includes=()
for dir in stage/unstable/*/*/; do
  distro=$(echo "$dir" | cut -d/ -f3)
  codename=$(echo "$dir" | cut -d/ -f4)

  echo "  - $distro/$codename"
  includes+=("$(jq -n -c --arg distro "$distro" --arg codename "$codename" '$ARGS.named')")
done

popd >/dev/null || exit 1

# shellcheck disable=SC2086
echo "includes=$(jq -n -c "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named')" >> $GITHUB_OUTPUT
