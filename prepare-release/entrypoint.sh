#!/usr/bin/env bash

set -e

if [ -z "$VOULAGE_PATH" ]; then
  echo "error: VOULAGE_PATH is empty"
  exit 1
fi
if [ ! -d "$VOULAGE_PATH" ]; then
  echo "error: voulage repo not found"
  exit 1
fi

RELEASE_EXISTS=""
RELEASE_VERSION=""

generate_tag_name() {
  local full_version=""
  local release_version=""

  full_version=$(dpkg-parsechangelog --show-field Version)
  release_version="v${full_version}"

  case "$PACKAGE_REF" in
    # default main/master branches ~ convention is main
    "main"|"master")                              ;;

    # distro/codename specific branches ~ convention is <distro>-<codename>
    "ubuntu-jammy"|"ubuntu/jammy")                release_version+="-ubuntu-jammy" ;;
    "ubuntu-focal"|"ubuntu/focal")                release_version+="-ubuntu-focal" ;;
    "debian-bullseye")                            release_version+="-debian-bullseye" ;;
    "debian-testing"|"debian/testing")            release_version+="-debian-testing" ;;
    "debian-bookworm"|"debian-bookworm-compat")   release_version+="-debian-bookworm" ;;

    # library/platform specific branches ~ convention is <library-name>-<version>
    "regolith/1%43.0-1")                          release_version+="-gnome-43" ;;
    "regolith/46")                                release_version+="-gnome-46" ;;
  esac

  local separator=":::"

  # Miscellaneous edge cases
  case "${PACKAGE_NAME}${separator}${PACKAGE_REF}" in
    "fonts-nerd-fonts:::debian")                  ;;
    "i3status-rs:::ubuntu/v0.22.0")               release_version+="-ubuntu-jammy" ;;
    "i3status-rs:::ubuntu/v0.32.1")               ;;
    "picom:::debian-v9")                          ;;
    "regolith-rofi-config:::i3cp")                ;;
    "sway-regolith:::packaging/v1.7-regolith")    release_version+="-ubuntu-jammy" ;;
    "sway-regolith:::packaging/v1.8-regolith")    release_version+="-debian-testing" ;;
    "sway-regolith:::packaging/v1.9-regolith")    ;;
    "whitesur-gtk-theme:::debian")                ;;

    # This package is exceptional. It is not built from a regolith repo and cannot push tags.
    #
    # Deprecated.
    "xcb-util:::applied/ubuntu/groovy")           release_version="" ;;
  esac

  RELEASE_VERSION="$release_version"
}

process_model() {
  # model_sub_path can be empty, or ends with a slash
  local model_sub_path=$1

  echo "= Processing '${PACKAGE_NAME}' in 'unstable/${model_sub_path}'"

  if ! get_model "unstable/${model_sub_path}"; then
    echo "  skip further processing"
    echo ""
    return
  fi

  if ! update_model "testing/${model_sub_path}"; then
    echo "  update package at 'testing/${model_sub_path}' failed"
    echo ""
    return
  fi

  echo ""
}

get_model() {
  # stage_path ends with a slash (e.g. unstable/, unstable/ubuntu/noble/)
  local stage_path=$1

  local model_file="stage/${stage_path%/}/package-model.json"

  if [ ! -f "$model_file" ]; then
    echo "error: $model_file not found"
    return 1
  fi

  echo "  looking for package in model"

  packages=$(jq -r '.packages' "$model_file")
  has_package=$(echo "$packages" | jq 'has("'"${PACKAGE_NAME}"'")')

  if [ "$has_package" == "true" ]; then
    package=$(echo "$packages" | jq -r '.["'"${PACKAGE_NAME}"'"]')

    # Package is explictly set to null. Skip it.
    if [ "$package" == "null" ]; then
      echo "  package is explicitly set to null"
      return 1
    else
      ref=$(echo "$package" | jq -r '.ref')

      if [ "$ref" != "$PACKAGE_REF" ]; then
        echo "  model ref ($ref) and requested ref ($PACKAGE_REF) don't match"
        return 1
      fi

      # This is the only place that the process should continue.
      # Nothing needs to be done on this line, the functions only
      # needs to return normally.
      return 0
    fi
  else
    echo "  package not found"
    return 1
  fi
}

update_model() {
  # stage_path ends with a slash (e.g. testing/, testing/ubuntu/noble/)
  local stage_path=$1

  local model_path="stage/${stage_path%/}/"
  local model_file="${model_path%/}/package-model.json"

  echo "  updating package in 'testing/${model_sub_path}'"

  mkdir -p "${model_path}"
  touch "${model_path%/}/package-model.json"

  jq -S '.packages.["'"${PACKAGE_NAME}"'"].ref="'"$RELEASE_VERSION"'" | .packages.["'"${PACKAGE_NAME}"'"].source="'"$PACKAGE_REPO"'" ' "$model_file" > "$model_file.tmp"

  if cmp -s "$model_file" "$model_file.tmp"; then
    rm "$model_file.tmp"
  else
    mv "$model_file.tmp" "$model_file"
  fi

  echo "  updated package ref to ${RELEASE_VERSION}"
}

main() {
  generate_tag_name

  if [ -z "$RELEASE_VERSION" ]; then
    echo "error: could not determine the release version"
    exit 1
  fi

  echo "Package name: ${PACKAGE_NAME}"
  echo "Package repo: ${PACKAGE_REPO}"
  echo "Package ref : ${PACKAGE_REF}"
  echo "Release name: ${RELEASE_VERSION}"
  echo ""

  echo "= Looking for release '${RELEASE_VERSION}' in ${PACKAGE_REPO}"

  # current tag does exist in the repository, do not recreate it again
  if [ "$(git tag --list "${RELEASE_VERSION}" | wc -l)" != 0 ] ; then
    RELEASE_EXISTS=true
    echo "Release exists! Do not recreate it again!"

    return
  fi

  RELEASE_EXISTS=false
  echo "Release not found!"
  echo ""

  pushd "$VOULAGE_PATH" >/dev/null || exit 1

  # process package-models at stage root level
  process_model ""

  # process package-models at distro/codename level
  for dir in stage/unstable/*/*/; do
    distro=$(echo "$dir" | cut -d/ -f3)
    codename=$(echo "$dir" | cut -d/ -f4)

    process_model "$distro/$codename/"
  done

  popd >/dev/null || exit 1
}

main

# shellcheck disable=SC2086
echo "release-exists=${RELEASE_EXISTS}" >> $GITHUB_OUTPUT

# shellcheck disable=SC2086
echo "release-version=${RELEASE_VERSION}" >> $GITHUB_OUTPUT
