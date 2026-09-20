#!/usr/bin/env bash
# Fetch a fresh user token for the single-account nightly run. 5.0.0 has no
# password login, and user tokens expire (server default ~24h), so a token
# cannot be stored as a GitHub secret: each test job calls this script right
# before generating the dart-define file.
#
# Flow (same as TokenClient in example/tool/env_tool.dart): exchange
# clientId/clientSecret for an app token, then exchange that for a user token
# with grant_type=inherit (autoCreateUser=true, so the account is created on
# first use). Mirrors scripts/ci/fetch_e2e_user_token.js in the React Native
# repo, including the retry budget and the stdout contract.
#
# Required environment:
#   E2E_REST_API      REST base URL of the cluster, e.g. http://host
#   E2E_APP_KEY       app key in orgName#appName form
#   E2E_CLIENT_ID     app client id
#   E2E_CLIENT_SECRET app client secret
#   E2E_USER_ID       account user id to fetch a token for
#
# Output contract: the user token is the ONLY stdout line (callers capture it
# with $(...)); diagnostics go to stderr. Exit code is non-zero on failure.
#
# Usage:
#   E2E_USER_TOKEN="$(bash tool/ci/fetch_e2e_user_token.sh)"
set -euo pipefail

max_attempts="${MAX_ATTEMPTS:-3}"
retry_interval_seconds="${RETRY_INTERVAL_SECONDS:-1}"
request_timeout_seconds="${REQUEST_TIMEOUT_SECONDS:-15}"

for name in E2E_REST_API E2E_APP_KEY E2E_CLIENT_ID E2E_CLIENT_SECRET \
  E2E_USER_ID; do
  if [ -z "${!name:-}" ]; then
    printf 'fetch_e2e_user_token: environment variable %s is not set\n' \
      "$name" >&2
    exit 2
  fi
done

for tool in curl jq; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'fetch_e2e_user_token: %s not found in PATH\n' "$tool" >&2
    exit 2
  }
done

invalid_app_key() {
  printf 'fetch_e2e_user_token: invalid E2E_APP_KEY (expect orgName#appName)\n' \
    >&2
  exit 2
}
case "$E2E_APP_KEY" in
  *'#'*) ;;
  *) invalid_app_key ;;
esac
org_name="${E2E_APP_KEY%%#*}"
app_name="${E2E_APP_KEY#*#}"
case "$app_name" in
  *'#'*) invalid_app_key ;;
esac
if [ -z "$org_name" ] || [ -z "$app_name" ]; then
  invalid_app_key
fi

# Trailing slashes are stripped for the same reason as in TokenClient.
rest_api="${E2E_REST_API%/}"
token_url="$rest_api/$org_name/$app_name/token"

# POSTs a JSON body and echoes the access_token. $1 url, $2 body, $3 bearer
# token (optional).
post_token() {
  local url="$1"
  local body="$2"
  local bearer="${3:-}"
  local curl_args response http_code payload token detail
  curl_args=(
    --silent
    --show-error
    --max-time "$request_timeout_seconds"
    --request POST "$url"
    --header 'Content-Type: application/json'
    --header 'Accept: application/json'
    --data "$body"
    --write-out $'\n%{http_code}'
  )
  if [ -n "$bearer" ]; then
    curl_args+=(--header "Authorization: Bearer $bearer")
  fi
  if ! response="$(curl "${curl_args[@]}")"; then
    printf 'fetch_e2e_user_token: request to %s failed\n' "$url" >&2
    return 1
  fi
  # --write-out appends the status code as the last line, so the body is
  # everything before it even when the server sends multi-line JSON.
  http_code="${response##*$'\n'}"
  payload="${response%$'\n'*}"
  if [ "$http_code" != "200" ]; then
    detail="$(printf '%s' "$payload" | jq -r \
      '[.error, .error_description] | map(select(. != null)) | join(" ")' \
      2>/dev/null || true)"
    if [ -z "$detail" ]; then
      detail="$(printf '%s' "$payload" | head -c 200)"
    fi
    printf 'fetch_e2e_user_token: HTTP %s from %s: %s\n' \
      "$http_code" "$url" "$detail" >&2
    return 1
  fi
  token="$(printf '%s' "$payload" | jq -r '.access_token // empty')"
  if [ -z "$token" ]; then
    printf 'fetch_e2e_user_token: token response missing access_token\n' >&2
    return 1
  fi
  printf '%s\n' "$token"
}

# Exchanges the app credentials for a user token; echoes the token.
fetch_user_token() {
  local app_token user_token
  app_token="$(post_token "$token_url" "$(jq -n \
    --arg client_id "$E2E_CLIENT_ID" \
    --arg client_secret "$E2E_CLIENT_SECRET" \
    '{grant_type: "client_credentials", client_id: $client_id, client_secret: $client_secret}')")" ||
    return 1
  user_token="$(post_token "$token_url" "$(jq -n \
    --arg username "$E2E_USER_ID" \
    '{username: $username, grant_type: "inherit", autoCreateUser: true}')" \
    "$app_token")" || return 1
  printf '%s\n' "$user_token"
}

attempt=1
while [ "$attempt" -le "$max_attempts" ]; do
  if user_token="$(fetch_user_token)"; then
    printf 'fetch_e2e_user_token: got a token for %s (attempt %s)\n' \
      "$E2E_USER_ID" "$attempt" >&2
    printf '%s\n' "$user_token"
    exit 0
  fi
  printf 'fetch_e2e_user_token: attempt %s/%s failed\n' \
    "$attempt" "$max_attempts" >&2
  if [ "$attempt" -lt "$max_attempts" ]; then
    sleep "$retry_interval_seconds"
  fi
  attempt=$((attempt + 1))
done

printf 'fetch_e2e_user_token: giving up after %s attempts\n' "$max_attempts" >&2
exit 1
