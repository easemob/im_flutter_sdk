# ohos integration test suites

Device verification for the ohos line of `im_flutter_sdk`. The suites are
modelled after the 5.1.0 `example/integration_test` architecture: a small set of
stable entries, per-domain case modules, and shared support helpers. They run on
a HarmonyOS device or emulator (local gate, see decision D14 in
`docs/decisions/im-flutter-sdk-ohos-merge/2026-11-11-ohos-merge-key-decisions.md`).

## Layout

```text
integration_test/
  logged_out_test.dart            no login: initialization, logged-out guards
  logged_in_base_test.dart        login + message + conversation + local DB
  logged_in_contact_test.dart     contacts (enableAutoSyncContacts)
  logged_in_group_test.dart       groups
  logged_in_user_info_test.dart   user info (enableUserInfo)
  logged_in_special_test.dart     chat rooms + push + 505-classified APIs
  modules/                        case registrars, one file per domain
  support/                        ci_test, env, session, login, rest helpers
```

Case IDs follow the 4.25 coverage draft
(`docs/porting/ohos-4.25.0/2026-11-12-test-coverage-draft.md`) and are recorded,
with the current pass/deviation state, in
`docs/porting/ohos-4.25.0/2026-11-12-test-coverage.md` (status snapshot) and
`docs/porting/ohos-4.25.0/2026-11-12-test-failure-ledger.md` (failure analysis).
The final run record for this rewrite is
`docs/porting/ohos-4.25.0/2026-11-12-test-verification.md`.

Each case carries `// Test:` / `// Expected:` comments. Cases that document a
known SDK difference are marked `NOTE(deviation FL-XXX-YYY)` next to the
assertion they describe; the matching analysis lives in the failure ledger.
Environment-limited rows (505 value-added services, 100 search service) go
through the `expectCiSuccessOr505` helper and print the observed limitation.

## Environment

The entries read six dart-defines (see `support/env.dart`):

```text
E2E_APP_KEY  E2E_USER_ID  E2E_USER_TOKEN  E2E_PEER_ID  E2E_REST_API  E2E_APP_TOKEN
```

Only `E2E_APP_KEY` / `E2E_USER_ID` have safe defaults (`easemob#easeim` and
`ci_smoke_user`), so the logged-out suite needs no environment at all.

The harmony CI wrappers follow the same contract as the 5.1.0 entries: callers
never pass a token (tokens are short lived and would need manual refreshing).
Instead the wrappers fetch fresh app/user tokens on every run:

- `tool/ci/smoke_local.harmony.sh` — zero credentials (the logged-out suite
  uses the public demo app key; the only login attempt is expected to fail).
- `tool/ci/nightly_local.harmony.sh` — accepts the same five long-lived values
  as the 5.1.0 nightly entry:

  ```text
  E2E_APP_KEY  E2E_USER_ID  E2E_REST_API  E2E_CLIENT_ID  E2E_CLIENT_SECRET
  ```

  With no variables exported it falls back to the gitignored local data file
  `im_flutter_sdk/example/config.local.json` (created by `make config`).
  Either way `example/tool/env_tool.dart e2e-config` exchanges the credentials
  for the six dart-defines in a mode-600 temp file that is deleted on exit.

`E2E_CONFIG_PATH` remains an optional override when you already have the JSON.

To produce the token file manually (for example before running `flutter test`
directly), run the same command from the example directory:

```bash
cd im_flutter_sdk/.worktree/ohos/im_flutter_sdk/example
dart run tool/env_tool.dart e2e-config
# prints e.g. /var/folders/.../ohos_e2e_zuoyu01_<ms>.json (mode 600)
# or pass the five long-lived values:
#   --app-key KEY --user-id ID --rest-api URL --client-id ID --client-secret SECRET
```

Alternatively reuse the 5.1.0 helper (the ohos branch vendors the env tool but
not the legacy token script):

```bash
cd im_flutter_sdk/.worktree/5.1.0
E2E_REST_API=http://ngi-a1.easemob.com \
E2E_APP_KEY='easemob-demo#zuoyu' \
E2E_CLIENT_ID='...' E2E_CLIENT_SECRET='...' \
E2E_USER_ID=zuoyu01 \
  bash tool/ci/fetch_e2e_user_token.sh --json > /tmp/ohos_e2e_zuoyu01.json
chmod 600 /tmp/ohos_e2e_zuoyu01.json
```

Run the peer account (`zuoyu02`) the same way when a second identity is needed;
the suites only use the single `E2E_USER_*` account plus the REST-prepared peer.

`logged_in_contact`, `logged_in_group`, `logged_in_special` and (for the
destructive message cases that delete server data) `logged_in_base` also need
`E2E_REST_API` + `E2E_APP_TOKEN`; those cases prepare throw-away users and
restore relations through `support/rest.dart`.

## Running

HarmonyOS convenience entries (no token input; the wrapper refreshes tokens):

```bash
bash tool/ci/smoke_local.harmony.sh    # logged_out suite, zero credentials
bash tool/ci/nightly_local.harmony.sh  # all six suites, five long-lived values
                                       # or example/config.local.json

# subset:
bash tool/ci/nightly_local.harmony.sh harmony logged_in_base logged_in_group
```

Or invoke the fork directly with the HarmonyOS Flutter SDK (3.41.9+ohos) and an
online device/emulator:

```bash
cd im_flutter_sdk/.worktree/ohos/im_flutter_sdk/example
export PATH="$HOME/fvm/versions/custom_ohos/bin:$PATH"
OHOS_SKIP_CODESIGN=1 flutter test integration_test/logged_in_base_test.dart \
  -d 127.0.0.1:5555 --no-pub \
  --dart-define-from-file=/tmp/ohos_e2e_zuoyu01.json
```

`OHOS_SKIP_CODESIGN=1` is needed while the emulator build has no signing
configuration: it lets the fork use the unsigned hap and is documented in the
verification record. Without the fork patch, the same command fails with
"请通过DevEco Studio打开ohos工程后配置调试签名".

All six suites can be run in one go with the local wrapper (the only
ohos-specific runner; the Android/iOS CI scripts and workflows are unchanged):

```bash
bash tool/ci/ohos_local.sh              # needs E2E_CONFIG_PATH or the six fields
# or the harmony-only wrappers (they prepare the token file themselves):
bash tool/ci/smoke_local.harmony.sh     # logged_out suite (21 cases), no credentials
bash tool/ci/nightly_local.harmony.sh   # all six suites (302 cases), no token input
```

`smoke_local.harmony.sh` / `nightly_local.harmony.sh` are harmony-only entry
wrappers around `ohos_local.sh`. Both wrappers fetch fresh tokens on every
run, so no caller ever needs to obtain or export a user token.

Pass suite names (`logged_out logged_in_base ...`) to run a subset, set
`CI_TEST_NAME=<regexp>` to select a single test within a suite, and set
`FLUTTER_BIN` / `OHOS_DEVICE` when the defaults do not apply.

Event listener callbacks are covered by `FL-EVENT-201..210` in
`modules/event_callback_cases.dart` (registered by `logged_in_base_test.dart`):
one real server/native-triggered callback per listener family that a single
device can drive (connection, chat message, contact added/deleted, group
member-joined/removed/destroyed, self user-info, presence on login sync, room
destroyed). Callbacks that need a second logged-in client (multi-device
kick/login, token expiry) or a server operation this deployment does not
expose (room member join/exit) stay UNVERIFIED and are listed in the
verification record.

### Which CI script runs what

- `tool/ci/run_quality.sh` — host-only checks (format / analyze / Dart unit
  tests / mapping / contracts / versions). It runs with the official Flutter
  3.47.0 used by CI and does not touch a device; it passed for this branch.
  The Android/iOS-only `smoke_local.sh` / `nightly_local.sh` wrappers do not
  exist on this line; use the harmony wrappers below.
- `tool/ci/ohos_local.sh` — the ohos device entry: runs the six suites on the
  HarmonyOS emulator and writes report.py reports plus raw logs to
  `artifacts/ci/<timestamp>/harmony/<suite>/` (attempt-N.log /
  attempt-N.events.jsonl / attempt-N.hilog.log.gz; merged `summary.md` and
  `report.json` at the harmony level; console output in
  `artifacts/ci/<timestamp>/harmony/runner.log`). A suite that completes zero
  tests (load-stage failure) is retried once; `CI_TEST_NAME` selects a single
  test.
- `tool/ci/smoke_local.harmony.sh` — harmony-only smoke wrapper; runs
  `ohos_local.sh logged_out` (the 21-case no-login suite).
- `tool/ci/nightly_local.harmony.sh` — harmony-only nightly wrapper; runs all
  six suites (or the suite names passed as arguments) through
  `ohos_local.sh`.

> Important: `run_quality.sh` runs `flutter pub get` with the
> official Flutter SDK. That rewrites `example/.flutter-plugins-dependencies`
> without the `plugins.ohos` key, and the next fork build fails with hvigor
> `TypeError ... reading 'filter'`. Re-run `flutter pub get` with the fork
> (`PATH="$HOME/fvm/versions/custom_ohos/bin:$PATH"`) before any ohos device
> run.

## Notes

- The legacy `no_login_presence_test.dart` and `single_account_local_test.dart`
  remain as the Android/iOS CI entries; the new suites are the ohos rewrite and
  are additive.
- The room cases create their chat room through REST in `setUpAll`; the group
  cases create groups through the SDK (the REST group collection is
  `POST /chatgroups`; the earlier `/groups` 404 was a fixture path error, see
  verification §8.1). `support/rest.dart` uses `/chatgroups` for the REST
  group fixtures.
- Format the suites with the official Flutter 3.47.0 `dart format` (the same
  version `run_quality.sh` checks with), not the fork's Dart 3.11.
- Cleanup: entries log in and out through `support/login.dart`; fixtures either
  destroy their own resources or explicitly leave peer-owned groups orphaned
  and print a `CI cleanup:` line, which the failure ledger collects.
