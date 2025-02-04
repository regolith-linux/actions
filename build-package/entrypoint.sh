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

echo -e "\033[0;34mBuilding ${PACKAGE_NAME} for ${DISTRO}/${CODENAME} (stage=${STAGE} arch=${ARCH} component=${COMPONENT})...\033[0m"

# working directories
WORKSPACE_PATH=$(realpath "$(realpath "$WORKSPACE_PATH")/../")
WORKING_DIR=$(realpath "/build/")

# raw build log file
TARGET_ID="${DISTRO}-${CODENAME}-${STAGE}-${ARCH}"
RAW_BUILD_LOG="${WORKING_DIR}/buildlog/BUILD_LOG_${TARGET_ID}.raw.txt"

"${VOULAGE_PATH}/.github/scripts/ci-build.sh" \
  --package-name "${PACKAGE_NAME}" \
  --extension "ext-debian.sh" \
  --pkg-build-path "${WORKSPACE_PATH}" \
  --pkg-publish-path "${WORKING_DIR}/publish" \
  --distro "${DISTRO}" \
  --codename "${CODENAME}" \
  --stage "${STAGE}" \
  --suite "${SUITE}" \
  --component "${COMPONENT}" \
  --arch "${ARCH}" \
  | tee -a "${RAW_BUILD_LOG}"

# generate changelog and sourcelog
echo "::group::Generating buildlogs"
grep ^CHLOG: "${RAW_BUILD_LOG}" | cut -c 7- > "${WORKING_DIR}/buildlog/CHANGELOG_${TARGET_ID}.txt"
echo -e "\033[0;34mGenerated ${WORKING_DIR}/buildlog/CHANGELOG_${TARGET_ID}.txt successfully.\033[0m"

grep ^SRCLOG: "${RAW_BUILD_LOG}" | cut -c 8- > "${WORKING_DIR}/buildlog/SOURCELOG_${TARGET_ID}.txt"
echo -e "\033[0;34mGenerated ${WORKING_DIR}/buildlog/SOURCELOG_${TARGET_ID}.txt successfully.\033[0m"
echo "::endgroup::"

# list the generated files for debugging purposes
echo "::group::Listing content of publish folder"
find "${WORKING_DIR}/publish"
echo "::endgroup::"

# cleanup build log
rm "${RAW_BUILD_LOG}"

# print changelog and sourcelog for debugging purposes
echo "::group::Printing changelog"
cat "${WORKING_DIR}/buildlog/CHANGELOG_${TARGET_ID}.txt"
echo "::endgroup::"

echo "::group::Printing sourcelog"
cat "${WORKING_DIR}/buildlog/SOURCELOG_${TARGET_ID}.txt"
echo "::endgroup::"

# shellcheck disable=SC2086
echo "publish-path=${WORKING_DIR}/publish/" >> $GITHUB_OUTPUT

# shellcheck disable=SC2086
echo "buildlog-path=${WORKING_DIR}/buildlog/" >> $GITHUB_OUTPUT
