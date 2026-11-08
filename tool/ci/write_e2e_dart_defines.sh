#!/usr/bin/env bash
# Prepares the dart-define file read by integration_test through
# `flutter test --dart-define-from-file`. The file carries real credentials, so
# it is written with mode 0600 to a path outside the repo and deleted after the
# run (the workflow and nightly_local.sh both do this). Never commit it.
#
# Required environment:
#   E2E_APP_KEY  E2E_USER_ID  E2E_REST_API  E2E_CLIENT_ID  E2E_CLIENT_SECRET
# Tokens and the reusable peer account are prepared automatically.
#
# Usage:
#   E2E_APP_KEY=... E2E_USER_ID=... E2E_REST_API=... \
#   E2E_CLIENT_ID=... E2E_CLIENT_SECRET=... \
#     bash tool/ci/write_e2e_dart_defines.sh OUTPUT_PATH
set -euo pipefail

output_path="${1:?usage: write_e2e_dart_defines.sh OUTPUT_PATH}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="$(bash "$script_dir/fetch_e2e_user_token.sh" --json)"

if ! printf '%s\n' "$config" | jq -e '
  [.E2E_APP_KEY, .E2E_USER_ID, .E2E_USER_TOKEN, .E2E_PEER_ID,
   .E2E_REST_API, .E2E_APP_TOKEN] as $fields |
  all($fields[]; type == "string" and length > 0) and
  (.E2E_USER_ID != .E2E_PEER_ID)
' >/dev/null; then
  echo 'Invalid prepared E2E configuration: six nonempty fields and distinct accounts required' >&2
  exit 1
fi

umask 077
temporary_path="$(mktemp "${output_path}.XXXXXX")"
trap 'rm -f "$temporary_path"' EXIT
printf '%s\n' "$config" >"$temporary_path"
mv -f "$temporary_path" "$output_path"

printf 'E2E dart-define file created with six fields and mode 0600\n'
