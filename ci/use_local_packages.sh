#!/usr/bin/env bash
# Generate gitignored overrides for local development without changing pubspecs.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_overrides() {
  local package="$1"
  local relative_root="$2"
  shift 2
  local target="$repo_root/$package/pubspec_overrides.yaml"
  local dependency

  if [[ -e "$target" || -L "$target" ]]; then
    echo "Keep: $package/pubspec_overrides.yaml"
    return
  fi

  {
    echo 'dependency_overrides:'
    for dependency in "$@"; do
      printf '  %s:\n    path: %s%s\n' "$dependency" "$relative_root" "$dependency"
    done
  } > "$target"
  echo "Created: $package/pubspec_overrides.yaml"
}

ensure_overrides im_flutter_sdk ../ \
  im_flutter_sdk_interface im_flutter_sdk_android im_flutter_sdk_ios
ensure_overrides im_flutter_sdk_android ../ im_flutter_sdk_interface
ensure_overrides im_flutter_sdk_ios ../ im_flutter_sdk_interface
# The workbench already depends on the main package through path: ../im_flutter_sdk.
ensure_overrides workbench ../ \
  im_flutter_sdk_interface im_flutter_sdk_android im_flutter_sdk_ios
# The minimal published example depends on the hosted main package; override
# it locally so pre-release development resolves against the checkout. The
# main package is the example's parent directory, so the generic generator
# (which builds paths from dependency names) cannot express this override.
# Overrides do not inherit across resolution roots: the main package's pinned
# sibling dependencies (unpublished for pre-release versions) must be
# overridden from here as well.
example_overrides="$repo_root/im_flutter_sdk/example/pubspec_overrides.yaml"
if [[ -e "$example_overrides" || -L "$example_overrides" ]]; then
  echo "Keep: im_flutter_sdk/example/pubspec_overrides.yaml"
else
  {
    echo 'dependency_overrides:'
    echo '  im_flutter_sdk:'
    echo '    path: ..'
    echo '  im_flutter_sdk_interface:'
    echo '    path: ../../im_flutter_sdk_interface'
    echo '  im_flutter_sdk_android:'
    echo '    path: ../../im_flutter_sdk_android'
    echo '  im_flutter_sdk_ios:'
    echo '    path: ../../im_flutter_sdk_ios'
  } > "$example_overrides"
  echo "Created: im_flutter_sdk/example/pubspec_overrides.yaml"
fi
