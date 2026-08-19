#!/usr/bin/env bash
set -euo pipefail

output_path="${1:?usage: write_e2e_dart_defines.sh OUTPUT_PATH}"
required=(E2E_APP_KEY E2E_USER_ID E2E_USER_PASSWORD)

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
  --arg password "$E2E_USER_PASSWORD" \
  '{
    E2E_APP_KEY: $app_key,
    E2E_USER_ID: $user_id,
    E2E_USER_PASSWORD: $password
  }' >"$output_path"

printf 'E2E dart-define file created with mode 0600\n'
