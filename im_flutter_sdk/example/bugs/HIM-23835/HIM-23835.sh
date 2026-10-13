#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$repo_root"
exec dart run im_flutter_sdk/example/bugs/HIM-23835/run.dart "$@"
