#!/usr/bin/env bash
set -euo pipefail

# sync_dart_api_from_commit.sh
# Sync Dart-side API/callback changes from an upstream Git commit into the local plugin.
# Focus: files under im_flutter_sdk/lib/** (Dart only).
#
# USAGE
#   ./scripts/sync_dart_api_from_commit.sh --url https://github.com/easemob/im_flutter_sdk.git --commit f688ae5 [--build] [--dry-run]
#   UPSTREAM_URL=... UPSTREAM_COMMIT=... ./scripts/sync_dart_api_from_commit.sh --build
#
# Behavior
#   - Clones the upstream repo at the specified commit to a temp dir
#   - Computes the changed Dart files under im_flutter_sdk/lib for that commit
#   - Copies those files into the local repo (path-preserving) or prints what would change when --dry-run
#   - Optionally runs analyzer and sample builds (Android/iOS)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"   # points to local plugin root: .../im_flutter_sdk
GROUP_ROOT="${GROUP_ROOT:-$(cd "$REPO_ROOT/.." && pwd)}" # monorepo root that contains im_flutter_sdk, im_flutter_sdk_android, im_flutter_sdk_ios, etc.

UPSTREAM_URL="${UPSTREAM_URL:-}"
UPSTREAM_COMMIT="${UPSTREAM_COMMIT:-}"
DO_BUILD=false
DRY_RUN=false

color() { local c="$1"; shift; printf "\033[%sm%s\033[0m\n" "$c" "$*"; }
info(){ color 36 "$*"; }
ok(){ color 32 "$*"; }
warn(){ color 33 "$*"; }
err(){ color 31 "$*"; }

die(){ err "$*"; exit 1; }

# arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) UPSTREAM_URL="$2"; shift 2;;
    --commit) UPSTREAM_COMMIT="$2"; shift 2;;
    --build) DO_BUILD=true; shift;;
    --no-build) DO_BUILD=false; shift;;
    --dry-run) DRY_RUN=true; shift;;
    -h|--help)
      cat <<USAGE
Usage: $(basename "$0") --url <git-url> --commit <sha> [--build] [--dry-run]
Env: UPSTREAM_URL, UPSTREAM_COMMIT, REPO_ROOT, GROUP_ROOT
USAGE
      exit 0;;
    *) warn "Unknown arg: $1"; shift;;
  esac
done

[[ -n "$UPSTREAM_URL" ]] || die "--url or UPSTREAM_URL is required"
[[ -n "$UPSTREAM_COMMIT" ]] || die "--commit or UPSTREAM_COMMIT is required"

TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t dartsync)"
trap 'rm -rf "$TMP_DIR"' EXIT

info "Cloning upstream…"
(
  cd "$TMP_DIR"
  git init -q
  git remote add origin "$UPSTREAM_URL"
  git fetch --depth 1 origin "$UPSTREAM_COMMIT"
  git checkout -q FETCH_HEAD
)

info "Detecting changed Dart files under im_flutter_sdk/lib for commit $UPSTREAM_COMMIT"
(
  cd "$TMP_DIR"
  # List files changed in the commit and filter for Dart under im_flutter_sdk/lib
  FILES=$(git diff-tree --no-commit-id --name-only -r "$UPSTREAM_COMMIT" | grep -E '^im_flutter_sdk/lib/.*\.dart$' || true)
  if [[ -z "$FILES" ]]; then
    warn "No Dart files detected under im_flutter_sdk/lib for this commit. Fallback to known paths (if present)."
    FILES=$(ls -1 im_flutter_sdk/lib/im_flutter_sdk.dart 2>/dev/null || true)
  fi
  printf '%s\n' $FILES > "$TMP_DIR/.files.txt"
)

CHANGED_COUNT=0
while IFS= read -r relpath; do
  [[ -z "$relpath" ]] && continue
  src="$TMP_DIR/$relpath"
  dst="$GROUP_ROOT/$relpath"
  if [[ ! -f "$src" ]]; then
    warn "Skip missing upstream file: $relpath"
    continue
  fi
  if $DRY_RUN; then
    if [[ -f "$dst" ]] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
      echo "Would update: $relpath"
    elif [[ ! -f "$dst" ]]; then
      echo "Would add:    $relpath"
    fi
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "Updated: $relpath"
    CHANGED_COUNT=$((CHANGED_COUNT+1))
  fi

done < "$TMP_DIR/.files.txt"

if $DRY_RUN; then
  ok "Dry-run complete. No files were modified."
  exit 0
fi

info "Formatting Dart sources…"
dart format "$GROUP_ROOT/im_flutter_sdk/lib" >/dev/null

if $DO_BUILD; then
  info "Running flutter analyze…"
  (cd "$GROUP_ROOT/im_flutter_sdk/example" && flutter pub get && flutter analyze)
  info "Building Android debug APK…"
  (cd "$GROUP_ROOT/im_flutter_sdk/example" && flutter build apk --debug)
  info "Building iOS (simulator, Debug)…"
  (cd "$GROUP_ROOT/im_flutter_sdk/example/ios" && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'generic/platform=iOS Simulator' build)
fi

ok "Sync complete. Files changed: $CHANGED_COUNT"
