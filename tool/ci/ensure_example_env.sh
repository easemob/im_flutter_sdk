#!/usr/bin/env bash
# Creates im_flutter_sdk/example/lib/env.dart if it is missing.
#
# The example app imports lib/env.dart, which is gitignored because
# `make env-gettoken` writes the environment a developer tests against into it
# (that file's credentials and test data come from example/config.local.json). A
# fresh checkout therefore cannot compile the example, and every job that
# touches it fails with "Error when reading 'lib/env.dart': No such file or
# directory": the quality job's `flutter analyze` of im_flutter_sdk/example, and
# the Android/iOS example builds.
#
# Only the compile-time placeholder is created here, from the same
# templates/env.example.dart that `make config` copies. This deliberately does
# not go through `env_tool.dart ensure` / `make config`: those also create
# example/config.local.json, which holds the credentials of the environment
# under test. Nothing in CI reads that file, so CI has no business fabricating
# one. Which environment to run against stays a local decision
# (`config.local.json` + `make env-gettoken`); the CI device jobs take theirs
# from the E2E_* credentials passed as dart-defines.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
template="$repo_root/im_flutter_sdk/example/templates/env.example.dart"
target="$repo_root/im_flutter_sdk/example/lib/env.dart"

if [[ -e "$target" ]]; then
  echo "Skip: $target already exists"
  exit 0
fi

cp "$template" "$target"
# Same mode env_tool.dart applies, because the generated file holds credentials.
chmod 600 "$target"
echo "Created: $target"
