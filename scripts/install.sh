#!/usr/bin/env bash
set -euo pipefail

APP_NAME="LeetBar"
APP_BUNDLE="${APP_NAME}.app"
INSTALL_DIR="/Applications"
TMP_DIR="$(mktemp -d)"
DEFAULT_REPO="moKshagna-p/LeetBar"
REPO="${LEETBAR_REPO:-${DEFAULT_REPO}}"
VERSION="${LEETBAR_VERSION:-latest}"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1"
    exit 1
  fi
}

require_cmd curl
require_cmd unzip

if [[ "${VERSION}" == "latest" ]]; then
  echo "==> Fetching latest release metadata for ${REPO}"
  api_url="https://api.github.com/repos/${REPO}/releases/latest"
else
  echo "==> Fetching release metadata for ${REPO} tag ${VERSION}"
  api_url="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}"
fi

zip_url="$(curl -fsSL "${api_url}" | sed -n 's/.*"browser_download_url":[[:space:]]*"\([^"]*LeetBar-macOS.zip\)".*/\1/p' | head -n 1)"

if [[ -z "${zip_url}" ]]; then
  echo "Could not find LeetBar-macOS.zip in release assets."
  exit 1
fi

echo "==> Downloading ${zip_url}"
curl -fL "${zip_url}" -o "${TMP_DIR}/LeetBar-macOS.zip"

echo "==> Unzipping"
unzip -q "${TMP_DIR}/LeetBar-macOS.zip" -d "${TMP_DIR}"

if [[ ! -d "${TMP_DIR}/${APP_BUNDLE}" ]]; then
  echo "App bundle not found in downloaded archive."
  exit 1
fi

echo "==> Installing to ${INSTALL_DIR}"
rm -rf "${INSTALL_DIR}/${APP_BUNDLE}"
cp -R "${TMP_DIR}/${APP_BUNDLE}" "${INSTALL_DIR}/${APP_BUNDLE}"

echo "==> Removing quarantine attribute"
xattr -dr com.apple.quarantine "${INSTALL_DIR}/${APP_BUNDLE}" 2>/dev/null || true

echo "==> Installation complete"
echo "Launching ${APP_NAME}..."
open "${INSTALL_DIR}/${APP_BUNDLE}"
