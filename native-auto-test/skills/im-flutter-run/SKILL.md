---
name: im-flutter-run
description: |
  One-command local release E2E run for this repo's Flutter IM SDK test app.
  Builds two im_flutter_test release APKs (deviceA/deviceB), boots two headless Android emulators,
  installs the APKs, starts the local WebSocket bridge, runs pytest cases, and generates the Allure report.
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

# download release APKs from a specific repo
bash skills/im-flutter-run/scripts/run.sh --repo easemob/im_flutter_sdk -q tests/client/test_client.py

# build APKs locally instead of downloading (developer mode)
bash skills/im-flutter-run/scripts/run.sh --build -q tests/client/test_client.py

# keep the emulators after the run (shut down by default)
bash skills/im-flutter-run/scripts/run.sh --keep-emulator
```

Flow: detect/install emulator env → obtain APKs (download latest release by default, or `--build` locally) → boot two emulators → install APKs → push `config.yaml` (startup injection) → `make ws-bridge-up` (relay + reverse) → launch apps (auto-connect) → `make test-local` (pytest) → `allure generate` → auto-open report.

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
- Two devices (deviceA/deviceB) are required; device is selected at build time via `--dart-define=DEVICE=...` and topic is resolved from `topics.deviceA`/`topics.deviceB`.
- The script does not modify `config.yaml`, REST config, or business accounts.

## References

- Design: `.doc/specs/release-test-automation/design.md`
- Test app: `../im_flutter_test/`
- Cases and reports: `README.md`
