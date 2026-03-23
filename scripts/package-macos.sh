#!/usr/bin/env bash
set -euo pipefail

APP_NAME="LeetBar"
BUNDLE_ID="com.leetbar.app"
BUILD_DIR=".build"
DIST_DIR="dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
ZIP_PATH="${DIST_DIR}/${APP_NAME}-macOS.zip"
VERSION="${VERSION:-$(git describe --tags --always 2>/dev/null || echo "dev")}"

echo "==> Building ${APP_NAME} in release mode"
swift build -c release

echo "==> Locating built binary"
BIN_PATH="$(find "${BUILD_DIR}" -type f -name "${APP_NAME}" -perm -111 | grep "/release/" | head -n 1 || true)"
if [[ -z "${BIN_PATH}" ]]; then
  echo "Failed to locate release binary for ${APP_NAME}"
  exit 1
fi

echo "==> Preparing app bundle"
rm -rf "${APP_BUNDLE}" "${ZIP_PATH}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Resources"
cp "${BIN_PATH}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
EOF

echo "==> Ad-hoc signing app bundle"
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "==> Creating zip artifact"
mkdir -p "${DIST_DIR}"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "${APP_BUNDLE}" "${ZIP_PATH}"

echo "==> Writing SHA256 checksums"
shasum -a 256 "${ZIP_PATH}" > "${DIST_DIR}/SHA256SUMS.txt"

echo "Done."
echo "Artifact: ${ZIP_PATH}"
echo "Checksum: ${DIST_DIR}/SHA256SUMS.txt"
