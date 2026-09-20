#!/usr/bin/env bash
# Renders the dart-define file read by integration_test through
# `flutter test --dart-define-from-file`. The file carries real credentials, so
# it is written with mode 0600 to a path outside the repo and deleted after the
# run (the workflow and nightly_local.sh both do this). Never commit it.
#
# Required environment:
#   E2E_APP_KEY    app key used for ChatClient.init
#   E2E_USER_ID    account user id used for login
#   E2E_USER_TOKEN user token for login. 5.0.0 has no password login, and user
#                  tokens expire in ~24h, so they cannot be stored as secrets:
#                  fetch a fresh one with tool/ci/fetch_e2e_user_token.sh right
#                  before calling this script.
#
# Usage:
#   E2E_APP_KEY=... E2E_USER_ID=... E2E_USER_TOKEN=... \
#     bash tool/ci/write_e2e_dart_defines.sh OUTPUT_PATH
set -euo pipefail

output_path="${1:?usage: write_e2e_dart_defines.sh OUTPUT_PATH}"
required=(E2E_APP_KEY E2E_USER_ID E2E_USER_TOKEN)

for name in "${required[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    printf 'Required environment variable %s is empty\n' "$name" >&2
    exit 1
  fi
done

umask 077
jq -n \
  --arg app_key "$E2E_APP_KEY" \
  --arg user_id "$E2E_USER_ID" \
  --arg token "$E2E_USER_TOKEN" \
  '{
    E2E_APP_KEY: $app_key,
    E2E_USER_ID: $user_id,
    E2E_USER_TOKEN: $token
  }' >"$output_path"

printf 'E2E dart-define file created with mode 0600\n'
