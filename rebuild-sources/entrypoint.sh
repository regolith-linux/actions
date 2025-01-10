#!/usr/bin/env bash

set -e

if [ -z "$VOULAGE_PATH" ]; then
  echo "Error: VOULAGE_PATH is empty"
  exit 1
fi
if [ ! -d "$VOULAGE_PATH" ]; then
  echo "Error: voulage repo not found"
  exit 1
fi
if [ ! -f "$VOULAGE_PATH/.github/scripts/rebuild-sources.sh" ]; then
  echo "Error: voulage rebuild-sources.sh script not found"
  exit 1
fi

export DEBEMAIL="${GPG_EMAIL}"
export DEBFULLNAME="${GPG_NAME}"

command_arguments=(--pkg-build-path "${WORKSPACE_PATH}")

if [ -n "${ONLY_DISTRO}" ]; then
    command_arguments+=(--only-distro "${ONLY_DISTRO}")
fi
if [ -n "${ONLY_CODENAME}" ]; then
    command_arguments+=(--only-codename "${ONLY_CODENAME}")
fi
if [ -n "${ONLY_COMPONENT}" ]; then
    command_arguments+=(--only-component "${ONLY_COMPONENT}")
fi
if [ -n "${ONLY_PACKAGE}" ]; then
    command_arguments+=(--only-package "${ONLY_PACKAGE}")
fi

"${VOULAGE_PATH}/.github/scripts/rebuild-sources.sh" ${command_arguments[@]}
