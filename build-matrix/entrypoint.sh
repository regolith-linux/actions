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

pushd "$VOULAGE_PATH" >/dev/null || exit 1

if [ ! -d stage ]; then
  echo "Error: stage doesn't exist"
  exit 1
fi
if [ ! -d stage/$BUILD_STAGE ]; then
  echo "Error: stage/$BUILD_STAGE doesn't exist"
  exit 1
fi

# # TODO
#
# echo "PACKAGE_NAME: '${PACKAGE_NAME}'"
# echo "PACKAGE_REF: '${PACKAGE_REF}'"
#
# if [ -f stage/$BUILD_STAGE/package-model.json ]; then
#   cat stage/$BUILD_STAGE/package-model.json | jq -r '.packages | .["'${PACKAGE_NAME}'"]'
# fi

includes=()

echo "Supported distro/codename:"

for dir in stage/$BUILD_STAGE/*/*/; do
  distro=$(echo "$dir" | cut -d/ -f3)
  codename=$(echo "$dir" | cut -d/ -f4)

  skip="false"
  model_file="stage/$BUILD_STAGE/$distro/$codename/package-model.json"

  if [ -f $model_file ]; then
    packages=$(cat $model_file | jq -r '.packages')
    has_package=$(echo "$packages" | jq 'has("'${PACKAGE_NAME}'")')

    # Package is listed in package-model.json file.
    #
    # This could mean either of:
    #  - the package ref gets overridden
    #  - the package should be completely skipped
    if [ "$has_package" == "true" ]; then
      package=$(echo "$packages" | jq -r '.["'${PACKAGE_NAME}'"]')

      # Package is explictly set to null. don't build it for this distro/codename
      if [ "$package" == "null" ]; then
        skip="true"
        echo "  - $distro/$codename: Don't Build"
      else
        ref=$(echo $package | jq -r '.ref')

        # Package ref is different that the ref we are executing this on
        if [ "$ref" != "$PACKAGE_REF" ]; then
          skip="true"
          echo "  - $distro/$codename: Skipped ($ref)"
        fi
      fi
    fi
  fi

  # Skip for this distro/codename pair.
  #
  # Possible reasons:
  #  - it is explictly set to "null" in package-model
  #  - it points to some other "ref" in package model
  if [ "$skip" == "true" ]; then
    continue
  fi

  echo "  - $distro/$codename: OK"
  for arch in $BUILD_ARCH; do
    includes+=("$(jq -n -c --arg distro "$distro" --arg codename "$codename" --arg arch "$arch" '$ARGS.named')")
  done
done

popd >/dev/null || exit 1

# shellcheck disable=SC2086
echo "includes=$(jq -n -c "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named')" >> $GITHUB_OUTPUT
