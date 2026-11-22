#!/usr/bin/env bash
# Set up the pinned HarmonyOS fork of Flutter on CI: shallow-fetch the pinned
# revision, apply the OHOS_SKIP_CODESIGN flutter_tools patch from this repo
# (tool/ci/ohos_flutter_tools_nocodesign.patch, previously maintained as a
# local-only modification), and warm the tool snapshot.
#
# Required environment:
#   FLUTTER_OHOS_REPO       git URL of the fork (gitcode.com/CPF-Flutter).
#   FLUTTER_OHOS_REVISION   pinned framework revision.
# Optional:
#   FLUTTER_OHOS_DIR        destination (default: $HOME/flutter-ohos).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
: "${FLUTTER_OHOS_REPO:?set FLUTTER_OHOS_REPO}"
: "${FLUTTER_OHOS_REVISION:?set FLUTTER_OHOS_REVISION}"
DEST="${FLUTTER_OHOS_DIR:-$HOME/flutter-ohos}"
PATCH_FILE="$REPO_ROOT/tool/ci/ohos_flutter_tools_nocodesign.patch"

if [ ! -d "$DEST/.git" ]; then
  echo "Cloning HarmonyOS fork Flutter..."
  git clone --filter=blob:none "$FLUTTER_OHOS_REPO" "$DEST"
fi
git -C "$DEST" fetch --depth 50 origin "$FLUTTER_OHOS_REVISION" || \
  git -C "$DEST" fetch origin
git -C "$DEST" checkout --force "$FLUTTER_OHOS_REVISION"

if git -C "$DEST" apply --check "$PATCH_FILE" 2>/dev/null; then
  echo "Applying OHOS_SKIP_CODESIGN flutter_tools patch..."
  git -C "$DEST" apply "$PATCH_FILE"
elif grep -q "OHOS_SKIP_CODESIGN" "$DEST/packages/flutter_tools/lib/src/ohos/ohos_device.dart"; then
  echo "OHOS_SKIP_CODESIGN patch already applied."
else
  echo "error: OHOS_SKIP_CODESIGN patch does not apply and is not present;" >&2
  echo "       refresh $PATCH_FILE against $FLUTTER_OHOS_REVISION" >&2
  exit 1
fi

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "FLUTTER_BIN=$DEST/bin/flutter" >> "$GITHUB_ENV"
else
  export FLUTTER_BIN="$DEST/bin/flutter"
fi

# Warm the snapshot: downloads the Dart SDK and the ohos engine artifacts on
# first use, then rebuilds flutter_tools with the patch applied.
"$DEST/bin/flutter" --version
