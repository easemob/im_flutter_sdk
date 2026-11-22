#!/usr/bin/env bash
# Resolve a HarmonyOS SDK plus the Command Line Tools on a headless Linux CI
# runner (no DevEco Studio). The official Huawei downloads require a Huawei-ID
# login, so this script consumes mirrored archives provided through repository
# variables (see .github/workflows/ci.yml).
#
# Required repository variable:
#   OHOS_CLI_TOOLS_URL  URL of the command-line-tools zip for Linux (contains
#                 ohpm / hdc / sdkmgr). Mirror the official "Command Line
#                 Tools" package once and host it on an internal artifact
#                 store or a private release.
# Optional:
#   OHOS_SDK_URL  URL of a pre-baked SDK tarball (produced once on a Linux
#                 machine by unpacking the CLI tools and running
#                 `sdkmgr install <packages> --accept-license`, then tarring
#                 the resulting sdk directory). Preferred: no sdkmgr run at job
#                 time.
#   OHOS_SDK_PACKAGES  sdkmgr package list used when OHOS_SDK_URL is not set
#                 (default below; run `sdkmgr list` in a job log to adjust).
#
# Exports (via $GITHUB_ENV when present): PATH (ohpm/hdc/sdkmgr), OHOS_SDK_HOME,
# HOS_SDK_HOME, DEVECO_SDK_HOME — the fork flutter_tools resolves the SDK from
# any of them (packages/flutter_tools/lib/src/ohos/ohos_sdk.dart).
set -euo pipefail

TOOLS_URL="${OHOS_CLI_TOOLS_URL:-}"
if [ -z "$TOOLS_URL" ]; then
  echo "error: repository variable OHOS_CLI_TOOLS_URL is not set." >&2
  echo "       The official HarmonyOS command-line-tools download requires a" >&2
  echo "       Huawei-ID login, so CI consumes a mirrored archive instead:" >&2
  echo "       1. download 'Command Line Tools (Linux)' from" >&2
  echo "          https://developer.huawei.com/consumer/cn/download/" >&2
  echo "       2. re-host the zip on an internal artifact store" >&2
  echo "       3. set OHOS_CLI_TOOLS_URL (and optionally OHOS_SDK_URL) as a" >&2
  echo "          repository variable on github.com/easemob/im_flutter_sdk" >&2
  exit 2
fi

TOOLS_DIR="$HOME/ohos-command-line-tools"
SDK_PARENT="$HOME/harmonyos-sdk"

echo "Downloading command-line-tools..."
curl -fSL --retry 3 -o /tmp/ohos-cli-tools.zip "$TOOLS_URL"
rm -rf "$TOOLS_DIR"
mkdir -p "$TOOLS_DIR"
unzip -q /tmp/ohos-cli-tools.zip -d "$TOOLS_DIR"
TOOLS_HOME="$(dirname "$(find "$TOOLS_DIR" -name sdkmgr -path '*/bin/*' | head -1)")/.."
TOOLS_HOME="$(cd "$TOOLS_HOME" && pwd)"

SDK_DIR=""
if [ -n "${OHOS_SDK_URL:-}" ]; then
  echo "Downloading pre-baked HarmonyOS SDK..."
  curl -fSL --retry 3 -o /tmp/ohos-sdk.tar.gz "$OHOS_SDK_URL"
  rm -rf "$SDK_PARENT"
  mkdir -p "$SDK_PARENT"
  tar -xzf /tmp/ohos-sdk.tar.gz -C "$SDK_PARENT"
  # Accept either a tarball whose root is the sdk or one with a wrapper dir.
  if [ -d "$SDK_PARENT/sdk" ]; then
    SDK_DIR="$SDK_PARENT/sdk"
  else
    SDK_DIR="$SDK_PARENT"
  fi
else
  SDKMGR="$TOOLS_HOME/sdkmanager/bin/sdkmgr"
  chmod +x "$SDKMGR" || true
  PACKAGES="${OHOS_SDK_PACKAGES:-HarmonyOS:12 toolchains:12}"
  echo "Installing SDK packages via sdkmgr: $PACKAGES"
  echo "(sdkmgr list output follows; adjust OHOS_SDK_PACKAGES if names drift)"
  JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Duser.country=CN" "$SDKMGR" list || true
  mkdir -p "$SDK_PARENT"
  (
    cd "$SDK_PARENT"
    JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Duser.country=CN" "$SDKMGR" install $PACKAGES --accept-license
  )
  SDK_DIR="$SDK_PARENT/hwsdk"
fi

[ -d "$SDK_DIR" ] || { echo "error: SDK directory not found at $SDK_DIR" >&2; exit 1; }
echo "HarmonyOS SDK resolved at $SDK_DIR"

if [ -n "${GITHUB_ENV:-}" ]; then
  {
    echo "$TOOLS_HOME/bin" >> "$GITHUB_PATH" 2>/dev/null || echo "PATH=$TOOLS_HOME/bin:\$PATH" >> "$GITHUB_ENV"
    echo "OHOS_SDK_HOME=$SDK_DIR"
    echo "HOS_SDK_HOME=$SDK_DIR"
    echo "DEVECO_SDK_HOME=$SDK_DIR"
  } >> "$GITHUB_ENV"
else
  export PATH="$TOOLS_HOME/bin:$PATH"
  export OHOS_SDK_HOME="$SDK_DIR"
  export HOS_SDK_HOME="$SDK_DIR"
  export DEVECO_SDK_HOME="$SDK_DIR"
fi
