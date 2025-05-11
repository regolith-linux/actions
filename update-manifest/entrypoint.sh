#!/usr/bin/env bash

set -e

if [ -z "${VOULAGE_PATH}" ]; then
  echo "Error: VOULAGE_PATH is empty"
  exit 1
fi
if [ ! -d "${VOULAGE_PATH}" ]; then
  echo "Error: voulage repo not found"
  exit 1
fi

while read -r item; do
  distro=$(echo "$item" | jq -r .distro)
  codename=$(echo "$item" | jq -r .codename)

  echo "Updating ${SUITE} manifest for ${NAME} for ${distro}/${codename}"

  # Copy existing manifest into /build/manifests/
  MANIFEST_FOLDER="${distro}/${codename}/${SUITE}-${COMPONENT}"

  if [ -f "${VOULAGE_PATH}/manifests/${MANIFEST_FOLDER}/manifest.txt" ]; then
    cp "${VOULAGE_PATH}/manifests/${MANIFEST_FOLDER}/manifest.txt" /build/manifests/
  fi

  # Update manifest file with the change
  touch /build/manifests/manifest.txt

  if ! grep "^${NAME} " /build/manifests/manifest.txt >/dev/null; then
    echo "${NAME} ${REPO} ${REF} ${SHA}" >> /build/manifests/manifest.txt
  fi
  sed -i -E "s|^${NAME}[[:space:]](.*)$|${NAME} ${REPO} ${REF} ${SHA}|g" /build/manifests/manifest.txt

  # always sort the file
  sort -o /build/manifests/manifest.txt /build/manifests/manifest.txt

  # Copy back manifest from /build/manifests/ to Voulage cloned folder
  mkdir -p "${VOULAGE_PATH}/manifests/${MANIFEST_FOLDER}/"
  cp /build/manifests/manifest.txt "${VOULAGE_PATH}/manifests/${MANIFEST_FOLDER}/"

  # Clean up /build/manifests/ folder
  rm /build/manifests/manifest.txt
done < <(echo "$MATRIX" | jq -c '.[]')
