#!/usr/bin/env bash
# Creates im_flutter_sdk/example/lib/env.dart if it is missing.
#
# The example app imports lib/env.dart, which is gitignored because
# `make env-gettoken` fills it with the credentials and test data of whichever
# cluster `config.local.json` selected (ebs, ngi, or a private deployment). A
# fresh checkout therefore cannot compile the example, and every job that
# touches it fails with "Error when reading 'lib/env.dart': No such file or
# directory": the quality job's `flutter analyze` of im_flutter_sdk/example, and
# the Android/iOS example builds.
#
# Only the compile-time placeholder is created here, from the same
# templates/env.example.dart that `make config` copies. This deliberately does
# not go through `env_tool.dart ensure` / `make config`: those also create
# example/config.local.json, which is exactly where the ebs/ngi cluster
# selection and the credentials live. Nothing in CI reads that file, and writing
# a `defaultCluster: "ebs"` placeholder would put a cluster choice into the
# workspace that nobody made. Picking a cluster stays a local
# `make env-gettoken` / `make env-use` action; the CI device jobs take their
# cluster from the E2E_* credentials passed as dart-defines.
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
