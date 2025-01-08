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
if [ ! -f "$VOULAGE_PATH/.github/scripts/ci-build.sh" ]; then
  echo "Error: voulage ci-build.sh script not found"
  exit 1
fi

export DEBEMAIL="${GPG_EMAIL}"
export DEBFULLNAME="${GPG_NAME}"

echo "Building ${PACKAGE_NAME} for ${DISTRO}/${CODENAME} (stage=${STAGE} arch=${ARCH} component=${COMPONENT})..."

REAL_WORKSPACE_PATH=$(realpath "$(realpath "$WORKSPACE_PATH")/../")
REAL_PUBLISH_PATH=$(realpath "$PUBLISH_PATH")

"${VOULAGE_PATH}/.github/scripts/ci-build.sh" \
  --package-name "${PACKAGE_NAME}" \
  --extension "ext-debian.sh" \
  --pkg-build-path "${REAL_WORKSPACE_PATH}" \
  --pkg-publish-path "${REAL_PUBLISH_PATH}/publish" \
  --distro "${DISTRO}" \
  --codename "${CODENAME}" \
  --stage "${STAGE}" \
  --suite "${SUITE}" \
  --component "${COMPONENT}" \
  --arch "${ARCH}"

find "${REAL_PUBLISH_PATH}/publish"

# shellcheck disable=SC2086
echo "publish-path=${REAL_PUBLISH_PATH}/publish" >> $GITHUB_OUTPUT
