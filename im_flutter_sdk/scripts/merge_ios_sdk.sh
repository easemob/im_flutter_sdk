#!/bin/bash
# iOS wrapper multi-version merge (mirror of Android mergeWrapperSrc)
# topology: Classes/base500/ = 5.0 baseline; Classes/sdkXXX/ = final diff from base500.
# usage: merge_ios_sdk.sh [sdk500|sdk510|sdk520|...] (default sdk500)
# output: Classes/generated/active/ for non-sdk500 flavors. sdk500 compiles base500 directly.
set -euo pipefail

FLAVOR="${1:-sdk500}"
DIR="$(cd "$(dirname "$0")/../../im_flutter_sdk_ios" && pwd)/ios"
BASE="$DIR/Classes/base500"
GENERATED="$DIR/Classes/generated/active"

if [ ! -d "$BASE" ]; then
  echo "ERROR: baseline dir missing: $BASE"
  exit 1
fi

if [ "$FLAVOR" = "sdk500" ]; then
  echo "iOS wrapper sdk500: use Classes/base500 directly; no merge needed"
  exit 0
fi

rm -rf "$GENERATED"
mkdir -p "$(dirname "$GENERATED")"
cp -R "$BASE" "$GENERATED"

if [ "$FLAVOR" != "sdk500" ] && [ -d "$DIR/Classes/$FLAVOR" ]; then
  echo "merge diffs: $FLAVOR"
  cp -R "$DIR/Classes/$FLAVOR"/* "$GENERATED"/
fi

echo "generated iOS wrapper ($FLAVOR): $(ls "$GENERATED"/*.m | wc -l | tr -d ' ') .m files"
