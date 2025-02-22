#!/bin/bash
set -x
set -e

APT_KEY_URL=$1
APT_REPO_LINE=$2
TARGET_PACKAGE=$3

apt update

# Install repo key
mkdir -p /etc/apt/keyrings/
wget -qO - "$APT_KEY_URL" | gpg --dearmor | sudo tee /etc/apt/keyrings/regolith.gpg >/dev/null

# Update apt configuration with new repository
echo "$APT_REPO_LINE" | tee /etc/apt/sources.list.d/regolith.list

# Install target package
apt update
# shellcheck disable=SC2086
DEBIAN_FRONTEND=noninteractive apt install -y $TARGET_PACKAGE
