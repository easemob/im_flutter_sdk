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

## Multi-lane parallelism

`--lanes N` runs N independent lanes, each with 2 emulators. Per-lane isolation:
- account prefix `g0..gN-1` (via `TEST_USER_PREFIX`, avoids login conflicts)
- relay port `40100+N` (topic reused, isolation by port)
- AVD `im_flutter_test_a/b` (lane 0) or `im_flutter_test_*_laneN`
- adb ports `5554+N*4`

Test files under the given paths are sharded round-robin across lanes; all lanes write to a shared `allure-results` and a single merged report is generated. Memory: ~3.7GB per emulator, so 24GB machines should prefer `--lanes 1` (2 emulators) or `--lanes 2` (4 emulators, near the limit).

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
