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
  local short_version=""
  local full_version=""

  short_version=$(dpkg-parsechangelog --show-field Version)
  full_version=$(echo "v${short_version}" | sed 's/:/./g' | sed 's/[\~\^\?\[\*]/-/g')

  local unsupported_ref="false"

  case "$PACKAGE_REF" in
    # default main/master branches ~ convention is main
    "main"|"master")                              ;;

    # distro/codename specific branches ~ convention is <distro>-<codename>
    "ubuntu-jammy"|"ubuntu/jammy")                full_version+="-ubuntu-jammy" ;;
    "ubuntu-focal"|"ubuntu/focal")                full_version+="-ubuntu-focal" ;;
    "debian-bullseye")                            full_version+="-debian-bullseye" ;;
    "debian-testing"|"debian/testing")            full_version+="-debian-testing" ;;
    "debian-bookworm"|"debian-bookworm-compat")   full_version+="-debian-bookworm" ;;

    # library/platform specific branches ~ convention is <library-name>-<version>
    "regolith/1%43.0-1")                          full_version+="-gnome-43" ;;
    "regolith/46")                                full_version+="-gnome-46" ;;

    # unknown package ref
    *) unsupported_ref="true" ;;
  esac

  local separator=":::"
  local unsupported_combo="false"

  # Miscellaneous edge cases
  case "${PACKAGE_NAME}${separator}${PACKAGE_REF}" in
    "fonts-nerd-fonts:::debian")                  ;;
    "i3status-rs:::ubuntu/v0.22.0")               full_version+="-ubuntu-jammy" ;;
    "i3status-rs:::ubuntu/v0.32.1")               ;;
    "picom:::debian-v9")                          ;;
    "regolith-rofi-config:::i3cp")                ;;
    "sway-regolith:::packaging/v1.7-regolith")    full_version+="-ubuntu-jammy" ;;
    "sway-regolith:::packaging/v1.8-regolith")    full_version+="-debian-testing" ;;
    "sway-regolith:::packaging/v1.9-regolith")    ;;
    "whitesur-gtk-theme:::debian")                ;;

    # This package is exceptional. It is not built from a regolith repo and cannot push tags.
    #
    # Deprecated.
    "xcb-util:::applied/ubuntu/groovy")           full_version="" ;;

    # unknown package name and ref combo
    *) unsupported_combo="true" ;;
  esac

  if [ "$unsupported_ref" == "true" ] && [ "$unsupported_combo" == "true" ]; then
    echo -e "\033[0;31m'${PACKAGE_REF}' is not a valid ref to release from.\033[0m"
    return 1
  fi

  RELEASE_VERSION="$full_version"
}

process_model() {
  # model_sub_path can be empty, or ends with a slash
  local model_sub_path=$1

  echo -e "\033[0;34mProcessing '${PACKAGE_NAME}' in 'unstable/${model_sub_path}'\033[0m"

  if ! get_model "unstable/${model_sub_path}"; then
    echo "Skip further processing."
    echo ""
    return
  fi

  if ! update_model "testing/${model_sub_path}"; then
    echo -e "\033[0;31mUpdate package at 'testing/${model_sub_path}' failed.\033[0m"
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

  echo "Looking for package in model..."

  packages=$(jq -r '.packages' "$model_file")
  has_package=$(echo "$packages" | jq 'has("'"${PACKAGE_NAME}"'")')

  if [ "$has_package" == "true" ]; then
    package=$(echo "$packages" | jq -r '.["'"${PACKAGE_NAME}"'"]')

    # Package is explictly set to null. Skip it.
    if [ "$package" == "null" ]; then
      echo "Package is explicitly set to null."
      return 1
    else
      ref=$(echo "$package" | jq -r '.ref')

      if [ "$ref" != "$PACKAGE_REF" ]; then
        echo "Model ref ($ref) and requested ref ($PACKAGE_REF) don't match."
        return 1
      fi

      # This is the only place that the process should continue.
      # Nothing needs to be done on this line, the functions only
      # needs to return normally.
      echo "Package found."
      return 0
    fi
  else
    echo "Package not found."
    return 1
  fi
}

update_model() {
  # stage_path ends with a slash (e.g. testing/, testing/ubuntu/noble/)
  local stage_path=$1

  local model_path="stage/${stage_path%/}/"
  local model_file="${model_path%/}/package-model.json"

  echo "Updating package in 'testing/${model_sub_path}'."

  if [ ! -d "$model_path" ] || [ ! -f "$model_file" ]; then
    echo "Warning: Model file 'testing/${model_sub_path}' not found."
    return 1
  fi

  jq -S '.packages.["'"${PACKAGE_NAME}"'"].ref="'"$RELEASE_VERSION"'" | .packages.["'"${PACKAGE_NAME}"'"].source="'"$PACKAGE_REPO"'" ' "$model_file" > "$model_file.tmp"

  if cmp -s "$model_file" "$model_file.tmp"; then
    rm "$model_file.tmp"
  else
    mv "$model_file.tmp" "$model_file"
  fi

  echo "Updated package ref to '${RELEASE_VERSION}'."
}

main() {
  # if changelog defines 'UNRELEASED' do not proceed further
  distro_name=$(dpkg-parsechangelog --show-field Distribution)
  if [ "$distro_name" == "UNRELEASED" ]; then
    RELEASE_EXISTS=true
    echo "Changelog is set to 'UNRELEASED'! Do not proceed any further!"

    return
  fi

  if ! generate_tag_name; then
    exit 1
  fi

  if [ -z "$RELEASE_VERSION" ]; then
    echo "error: could not determine the release version"
    exit 1
  fi

  echo "Package name: ${PACKAGE_NAME}"
  echo "Package repo: ${PACKAGE_REPO}"
  echo "Package ref : ${PACKAGE_REF}"
  echo "Release name: ${RELEASE_VERSION}"
  echo ""

  echo -e "\033[0;34mLooking for release '${RELEASE_VERSION}' in ${PACKAGE_REPO}\033[0m"

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
