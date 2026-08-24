#!/bin/bash
# iOS wrapper multi-version merge (mirror of Android mergeWrapperSrc)
# topology: Classes/base500/ = 5.0 baseline; Classes/sdk424/ = 4.24 diffs.
# usage: merge_ios_sdk.sh [sdk500|sdk424] (default sdk500)
# output: Classes/merged/ (podspec points here). Run before pod install.
set -euo pipefail

FLAVOR="${1:-sdk500}"
DIR="$(cd "$(dirname "$0")/../../im_flutter_sdk_ios" && pwd)/ios"
BASE="$DIR/Classes/base500"
MERGED="$DIR/Classes/merged"

if [ ! -d "$BASE" ]; then
  echo "ERROR: baseline dir missing: $BASE"
  exit 1
fi

rm -rf "$MERGED"
cp -R "$BASE" "$MERGED"

if [ "$FLAVOR" != "sdk500" ] && [ -d "$DIR/Classes/$FLAVOR" ]; then
  echo "merge diffs: $FLAVOR"
  cp -R "$DIR/Classes/$FLAVOR"/* "$MERGED"/
fi

echo "merged ($FLAVOR): $(ls "$MERGED"/*.m | wc -l | tr -d ' ') .m files"
