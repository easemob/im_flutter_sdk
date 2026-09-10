---
name: im-flutter-run
description: |
  One-command local release E2E run for this repo's Flutter IM SDK test app.
  Downloads/builds a single release APK, boots two headless Android emulators, installs the APK
  with runtime device injection, starts the local WebSocket bridge, runs pytest cases, and generates the Allure report.
  Use when a contributor wants to run cases end-to-end without Android Studio or manual App setup.
---

# IM Flutter Run

One-command end-to-end test run for `im_flutter_test` (release) + `native-auto-test` (pytest).

## Minimal Dependencies (no Android Studio required)

`run.sh` auto-installs the full toolchain on first run (idempotent), so you only need:

- A network connection to GitHub and your test environment
- Python 3.10+ (`python3` on PATH; the venv is created automatically)

Auto-installed if missing: JDK 17+, Android cmdline-tools, `emulator`, `platform-tools`, `system-images;android-34;default` (matching host arch), two minimal AVDs (`im_flutter_test_a` / `im_flutter_test_b`), and the Python venv + dependencies.

## Usage

```bash
# from the native-auto-test directory
bash skills/im-flutter-run/scripts/run.sh

# run N lanes in parallel (N*2 emulators), shard test files, merge into one report
bash skills/im-flutter-run/scripts/run.sh --lanes 2 tests/chatroom

# download the release APK from a specific repo
bash skills/im-flutter-run/scripts/run.sh --repo easemob/im_flutter_sdk -q tests/client/test_client.py

# build the APK locally instead of downloading (developer mode)
bash skills/im-flutter-run/scripts/run.sh --build -q tests/client/test_client.py

# keep the emulators after the run (shut down by default)
bash skills/im-flutter-run/scripts/run.sh --keep-emulator
```

Flow: detect/install emulator env → obtain a single APK (download latest release by default, or `--build` locally) → boot emulators (2 by default, or N*2 with `--lanes N`) → install the same APK with runtime device injection (`--es device deviceA/deviceB`) → push `config.yaml` (startup injection) → `make ws-bridge-up` (relay + reverse) → launch apps (auto-connect) → `make test-local` (pytest) → `allure generate` → auto-open report.

## ADB mDNS crash prevention

Install/update the complete skill folder, including `scripts/adb_preflight.py`;
copying only `run.sh` is insufficient. The runner enforces `ADB_MDNS=0` for its
entire process tree on macOS/Linux, independent of shell configuration and even
when the caller sets `ADB_MDNS=1`. It does not edit global tool settings.

Before obtaining the APK or starting emulators, the runner starts/reuses ADB and
requires `server-status` to explicitly report `mdns_enabled: false`. The multi-lane
parent checks before launching lanes; each lane checks independently and again
before pytest. Failed/timed-out commands and missing/ambiguous state stop the run;
each probe has a 10-second timeout. Do not bypass this check or interpret unknown
state as disabled. Use platform-tools that supports the status field (verified
locally with 36.0.2); an older unsupported tool must be updated before testing.

An already-running server retains its original environment. If mDNS is enabled,
the runner stops and prints restart commands for the exact adb it selected.
After confirming no other ADB work is running, execute those commands once and
rerun the skill. For example, using the actual SDK path:

```bash
"$ANDROID_HOME/platform-tools/adb" kill-server
ADB_MDNS=0 "$ANDROID_HOME/platform-tools/adb" start-server
"$ANDROID_HOME/platform-tools/adb" server-status
```

Never restart the shared server from a child lane or during another test run:
that disconnects device transports and loses reverse mappings. Do not change
global shell settings on another machine merely to run this skill.

This disables wireless-debugging mDNS discovery to prevent the observed
OpenScreen `dns_data_graph.cc` assertion path. Emulator/USB connections still
work. It does not provide recovery from external server kills/replacements,
unrelated ADB crashes, or network failures during a run.

## Verified clean installation (destructive to test-App local data)

Every run removes this test App's local databases, attachments and configuration
on the two explicitly selected lane emulators. Install the complete skill folder,
including `scripts/clean_install.py`, on every contributor's machine.

Before deleting data, the helper verifies the serial's AVD name against the
expected `im_flutter_test_a/b[_laneN]`. It checks package presence, requires
successful uninstall and absence, resolves device EXTERNAL_STORAGE, then removes
only `Android/data/com.easemob.im_flutter_test` and verifies absence before
installing. Unknown storage, uninstall/cleanup/install failure or timeout stops
the lane before pytest. No UID is hard-coded; no root, chown, chmod 777, global
ADB restart or automatic AVD wipe is used. Other devices and server data are not
cleared. If cleanup is denied, stop and investigate the test AVD rather than
bypassing the check. This is not an App-identity writable probe.

Each lane prints a unique `Private device logs:` directory. Logcat starts before
installation and stops before emulator shutdown, including failed runs. Directories
are 0700 and log files 0600. Raw logs may contain credentials or attachment secrets:
do not upload/share them without redaction. Logs are retained for manual cleanup.
No SDK or test-App rebuild is needed for this runner change.

## Release APK cache

Default runs query GitHub's latest Release metadata every time. The cache compares
repository, Release ID, APK asset ID, update time, size and optional SHA-256 digest;
it also checks the local APK's size and SHA-256 before reuse. A cache hit skips the
APK download, not the online metadata query.

- Cache: `native-auto-test/.local/apk-cache/`, isolated by repository and asset identity.
- Missing, changed or damaged APK: download the specific Release attachment and
  validate it before atomically publishing the cache.
- Query failure (including GitHub anonymous API rate limits), download failure or
  validation failure: stop with an error. **Never silently run an old cached SDK.**
- Multi-lane: the outer runner obtains one APK and shares it with all child lanes.
- The cache retains old generations; it does not automatically delete them.
- Every device still uninstalls/reinstalls the App and receives the current runtime
  config. Caching the host APK does not preserve device login state or SDK databases.
  Clean installation is verified as described below; server-side data is not cleared.

```bash
# Force a fresh download even when the cached attachment is unchanged
bash skills/im-flutter-run/scripts/run.sh --refresh-apk -q tests/client

# Explicit local APK: bypass remote lookup/cache, single or multiple lanes
APK_PATH=/absolute/path/app-release.apk \
  bash skills/im-flutter-run/scripts/run.sh --lanes 2 -q tests/client
```

`--refresh-apk`, `--build`, and nonempty `APK_PATH` are mutually exclusive.
An explicitly supplied APK must be a readable, nonempty file; an invalid path is
an error, not a request to fall back to downloading. `--build` builds once in
multi-lane mode and never writes into the remote APK cache. Use `--build` to test
local Flutter/Android changes; downloading a Release does not include unbuilt local changes.

### Optional GitHub authentication

The API query reads nonempty `GH_TOKEN` first, then `GITHUB_TOKEN`; otherwise it
uses anonymous access. A token with public repository read access is sufficient
for this public Release; no write permissions are required. In the same zsh
terminal used for testing, set it without putting the value in shell history:

```bash
read -rs 'GH_TOKEN?Paste GitHub token (hidden), then Enter: '; echo; export GH_TOKEN
```

Then run your usual command. `GitHub API auth: token` confirms token mode (not
that GitHub has accepted it). Do not print or share the token. `unset GH_TOKEN`
removes it from this shell; a separately set `GITHUB_TOKEN` is still a fallback.

The Authorization header is passed to the API curl process through stdin, never
in its arguments or files. Both token environment variables are removed from
curl subprocess environments. APK download requests do not carry the API token.
Errors distinguish transport failures, HTTP 401 (invalid/expired authentication),
rate limits (HTTP 403/429 with available remaining/reset/retry-after fields), and
other HTTP errors. Authentication does not remove all GitHub rate limits; failure
still stops rather than using stale cache. Never enable shell tracing around
commands that assign a token.

## Multi-lane parallelism

`--lanes N` runs N independent lanes, each with 2 emulators. Per-lane isolation:
- account prefix `g0..gN-1` (via `TEST_USER_PREFIX`, avoids login conflicts)
- relay port `40100+N` (topic reused, isolation by port)
- AVD `im_flutter_test_a/b` (lane 0) or `im_flutter_test_*_laneN`
- adb ports `5554+N*4`

Test files under the given paths are sharded round-robin across lanes; all lanes write to a shared `allure-results` and a single merged report is generated. Memory: ~3.7GB per emulator, so 24GB machines should prefer `--lanes 1` (2 emulators) or `--lanes 2` (4 emulators, near the limit).

After all lanes finish, the terminal prints a **Combined pytest summary** with
the total selected tests, passed/failed/error/skipped/xfailed/xpassed/unreported
counts, and every failed/error nodeid across all lanes. For example, 8 failures
in one lane plus 7 in another produce `Total: 15` and `15 failed`; the last lane's
individual pytest summary is not the overall result. Each selected nodeid is
counted once; per-lane `deselected` counts are excluded.

The `Logs:` directory contains `laneN.nodeids`, `laneN.log`, `laneN.result.json`
and `laneN.exit`. Structured results come from `scripts/pytest_lane.py` and are
combined by this skill's `scripts/summarize_lanes.py`; update both with `run.sh`.
The results contain only nodeids/outcomes/exit status, not failure payloads.
If a lane aborts before reporting, or its result is missing/invalid, the summary
shows `INCOMPLETE`/`unreported` and the run fails rather than inventing outcomes.
Empty shards are excluded from missing-result checks. Raw pytest output and the
existing merged Allure report remain available.

## Config effectiveness rules (important)

`config.yaml` is injected at app startup (not bundled into the APK), so changing it does **not** require rebuilding the APK:

| Section | Consumer | How it reaches the app |
|---|---|---|
| `sdk_options` (app_key, servers) | App | `run.sh` pushes `config.yaml` to the emulator's external files dir |
| `websocket` (base_url, topic) | App | same |
| `topics` (multi-device) | App | same |
| `rest_api` (user provisioning) | Python side | read at runtime from the local `config.yaml` |

`run.sh` pushes the local `config.yaml` to both emulators before launching. Edit it, then re-run — no rebuild needed.

## Reused components

- emulator setup: `scripts/setup_emulator.sh` (auto-install + create minimal AVDs)
- relay + reverse + env: reuses `make ws-bridge-up` (`scripts/ws_bridge_local.sh` + `scripts/adb_reverse_ws_bridge.sh`)
- pytest: reuses `make test-local` (loads `.local/ws-bridge.env`)
- report: reuses allure (`out/allure-results` → `out/allure-report`)

## Notes

- The emulators run headless with software rendering (swiftshader), sufficient for API automation.
- Two devices (deviceA/deviceB) are required by default; the device is injected at launch time via intent extra `--es device <name>` (single APK serves any number of devices), and topic is resolved from `topics.<device>` in `config.yaml`.
- The script does not modify `config.yaml`, REST config, or business accounts.

## References

- Design: `.doc/specs/release-test-automation/design.md`
- Test app: `../im_flutter_test/`
- Cases and reports: `README.md`
