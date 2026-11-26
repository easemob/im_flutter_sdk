#!/usr/bin/env bash
# Applies the upstream fix for the iOS simulator VM Service discovery race
# (flutter/flutter#181771) to the pinned Flutter SDK's flutter tool.
#
# On iOS 26 simulators `flutter test` sometimes never discovers the Dart VM
# Service of the launched app: the tool starts `simctl log stream` to capture
# the VM Service URI the app prints once at launch, and if the app wins the
# race the URI is missed permanently and the run hangs (see the header of
# run_ios_simulator_test.sh). The upstream fix (flutter/flutter#193142, merge
# commit c3ed85ef) makes startApp wait for the log stream before launching.
# It landed on master on 2026-10-15 but is in no stable release yet
# (verified absent from 3.47.9 and 3.50.1), so CI patches it onto the pinned
# SDK instead of waiting for an upgrade.
#
# The patch only touches packages/flutter_tools/lib/src/ios/simulators.dart.
# That alone is not enough: the flutter tool snapshot is considered fresh
# whenever bin/cache/flutter_tools.stamp matches "<revision>:<args>"
# (bin/internal/shared.sh), regardless of source mtimes, so the script
# deletes the snapshot and stamp to force a rebuild, then runs
# `flutter --version` — which also proves the patched tool still compiles.
#
# Idempotent: if the marker string of the fix is already present (patch
# already applied, or the pinned version ships the fix) the script is a
# no-op. Retirement: once FLUTTER_VERSION moves to a stable that contains
# the fix, delete this script, ci/patches/, and the two workflow steps
# that call it (the marker check makes the steps harmless until then).
set -euo pipefail

# Keep in sync with FLUTTER_VERSION in .github/workflows/ci-device.yml.
EXPECTED_FLUTTER_VERSION="3.47.0"
# Present in simulators.dart once the fix (applied or shipped) is in place.
MARKER="log stream did not start"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
patch_file="$repo_root/ci/patches/flutter-3.47.0-ios-simulator-log-stream.patch"

command -v flutter >/dev/null 2>&1 || {
  echo "error: flutter not found in PATH" >&2
  exit 2
}
command -v patch >/dev/null 2>&1 || {
  echo "error: patch not found in PATH" >&2
  exit 2
}

flutter_bin="$(command -v flutter)"
# Resolve symlinks: the launcher can be a symlink into the SDK checkout.
while [ -L "$flutter_bin" ]; do
  link="$(readlink "$flutter_bin")"
  case "$link" in
    /*) flutter_bin="$link" ;;
    *) flutter_bin="$(cd "$(dirname "$flutter_bin")" && pwd)/$link" ;;
  esac
done
flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
target="$flutter_root/packages/flutter_tools/lib/src/ios/simulators.dart"

[ -f "$target" ] || {
  echo "error: $target not found (unexpected Flutter SDK layout)" >&2
  exit 2
}

# Marker check first: a pinned version that already ships the fix is a
# no-op even before the version comparison below would reject it.
if grep -q "$MARKER" "$target"; then
  echo "skipped: flutter tool already contains the iOS simulator log stream fix"
  exit 0
fi

flutter_version="$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([^ ]*\).*/\1/p' | head -1)"
if [ "$flutter_version" != "$EXPECTED_FLUTTER_VERSION" ]; then
  echo "error: Flutter is '$flutter_version', but the patch was only verified against $EXPECTED_FLUTTER_VERSION" >&2
  echo "       re-verify the patch against the new version, then update EXPECTED_FLUTTER_VERSION in this script" >&2
  exit 1
fi

# -f suppresses interactive questions (an already-applied hunk would
# otherwise block on stdin). The marker check above keeps this a fresh
# apply in practice; a failure here means real context drift.
(cd "$flutter_root" && patch -f -p1 <"$patch_file")
grep -q "$MARKER" "$target" || {
  echo "error: patch reported success but the marker is missing from $target" >&2
  exit 1
}
echo "applied: iOS simulator log stream fix patched into $target"

# Force a tool rebuild: the snapshot freshness check ignores source mtimes,
# so without this the stale pre-patch snapshot keeps running.
rm -f "$flutter_root/bin/cache/flutter_tools.snapshot" \
      "$flutter_root/bin/cache/flutter_tools.stamp"
flutter --version
echo "done: flutter tool rebuilt with the patch"
