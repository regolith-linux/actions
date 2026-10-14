#!/usr/bin/env bash
#
# Run the autopkgtests of the package (debian/tests/control) against the binary
# packages that build-package has just built. The tests run in the same build
# container (autopkgtest's "null" testbed), with the same apt sources, which
# include the Regolith archive of the target stage when it exists.

set -eo pipefail

case "$RUN_AUTOPKGTEST" in
  auto)  enabled="$BUILD_ONLY" ;;
  true)  enabled="true" ;;
  false) enabled="false" ;;
  *)
    echo "Error: run-autopkgtest must be one of auto, true, false (got '${RUN_AUTOPKGTEST}')"
    exit 1
    ;;
esac

if [ "$enabled" != "true" ]; then
  echo "Skipping autopkgtests (run-autopkgtest=${RUN_AUTOPKGTEST}, only-build=${BUILD_ONLY})."
  exit 0
fi

# working directories, the same as in entrypoint.sh
WORKSPACE_PATH=$(realpath "$(realpath "$WORKSPACE_PATH")/../")
PACKAGE_PATH="${WORKSPACE_PATH}/${PACKAGE_NAME}"

if [ ! -f "${PACKAGE_PATH}/debian/tests/control" ]; then
  echo "${PACKAGE_NAME} has no debian/tests/control, skipping autopkgtests."
  exit 0
fi

pushd "$PACKAGE_PATH" >/dev/null
debian_package_name=$(dpkg-parsechangelog --show-field Source)
full_version=$(dpkg-parsechangelog --show-field Version)
popd >/dev/null

# the .changes file that 'debuild -b' wrote next to the package folder
CHANGES_FILE="${WORKSPACE_PATH}/${debian_package_name}_${full_version#*:}_$(dpkg --print-architecture).changes"
if [ ! -f "$CHANGES_FILE" ]; then
  echo "Error: $CHANGES_FILE not found"
  exit 1
fi

mapfile -t DEB_FILES < <(dcmd --deb "$CHANGES_FILE")
if [ "${#DEB_FILES[@]}" -eq 0 ]; then
  echo "Error: no .deb file listed in $CHANGES_FILE"
  exit 1
fi

TARGET_ID="${DISTRO}-${CODENAME}-${STAGE}-${ARCH}"
OUTPUT_PATH="${RUNNER_TEMP:-/tmp}/autopkgtest-${PACKAGE_NAME}-${TARGET_ID}"
rm -rf "$OUTPUT_PATH"

echo -e "\033[0;34mRunning autopkgtests of ${PACKAGE_NAME} for ${DISTRO}/${CODENAME} (stage=${STAGE} arch=${ARCH})...\033[0m"

echo "::group::Installing autopkgtest"
sudo apt-get update
sudo apt-get install -y --no-install-recommends autopkgtest
echo "::endgroup::"

# Tests without the needs-root restriction run as the build user, as they
# would on a regular testbed. autopkgtest itself needs root to install the
# test dependencies.
user_args=()
if [ "$(id -u)" != "0" ]; then
  user_args=(--user "$(id -un)")
fi

# shellcheck disable=SC2086
echo "output-path=${OUTPUT_PATH}" >> $GITHUB_OUTPUT

# --no-built-binaries: test the binaries built above, never rebuild the tree
rc=0
sudo autopkgtest \
  --output-dir "$OUTPUT_PATH" \
  --no-built-binaries \
  "${user_args[@]}" \
  "${DEB_FILES[@]}" \
  "$PACKAGE_PATH" \
  -- null || rc=$?

sudo chown -R "$(id -u):$(id -g)" "$OUTPUT_PATH" || true

echo "::group::autopkgtest summary"
cat "${OUTPUT_PATH}/summary" || true
echo "::endgroup::"

if [ -n "$GITHUB_STEP_SUMMARY" ] && [ -f "${OUTPUT_PATH}/summary" ]; then
  {
    echo "### autopkgtest: ${PACKAGE_NAME} on ${DISTRO}/${CODENAME} (${ARCH})"
    echo ""
    echo '```'
    cat "${OUTPUT_PATH}/summary"
    echo '```'
  } >> "$GITHUB_STEP_SUMMARY"
fi

# autopkgtest exit codes: 0 all tests passed, 2 at least one test was skipped
# (or a flaky test failed), 8 no test ran (all were skipped), 4 at least one
# test failed, 6 failed and skipped, 12 or more: erroneous package, testbed
# failure or bad arguments.
case "$rc" in
  0)
    echo -e "\033[0;32mAll autopkgtests passed.\033[0m"
    ;;
  2)
    echo -e "\033[0;33mautopkgtests passed, some were skipped.\033[0m"
    ;;
  8)
    echo "::warning::no autopkgtest of ${PACKAGE_NAME} ran on ${DISTRO}/${CODENAME}, all were skipped"
    ;;
  *)
    echo "::error::autopkgtests of ${PACKAGE_NAME} failed on ${DISTRO}/${CODENAME} (autopkgtest exit code ${rc})"
    exit "$rc"
    ;;
esac
