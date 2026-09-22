# Contributor Guide

This document is for developers and maintainers of im_flutter_sdk; it covers repository structure, environment preparation, verification methods, and the release process. SDK users should read [im_flutter_sdk/README.md](im_flutter_sdk/README.md).

## Repository Structure

Federated Plugin architecture; the four packages are linked via local `path:` dependencies:

| Package | Responsibility |
|---|---|
| `im_flutter_sdk/` | Main package: public API, Models, Managers, includes the `example/` test app |
| `im_flutter_sdk_interface/` | Platform interface layer: MethodChannel abstraction |
| `im_flutter_sdk_android/` | Android platform implementation |
| `im_flutter_sdk_ios/` | iOS platform implementation |

Call chain: `Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`. Changing the interface affects all upper-layer packages.

Beyond the four packages, the repository root also contains: `Makefile` (local development entry point), `tool/ci/` (quality gate and device test scripts), `tool/auto_report.dart` (auto-mode runner), `docs/porting/<version>/` (diff, contract, implementation, and acceptance docs for each version upgrade), `reports/` (local auto-run artifacts, gitignored).

## Environment Preparation

Requires Flutter, Xcode + CocoaPods (iOS), and Android Studio (Android).

> **Flutter version**: use **Flutter 3.47.0** consistently for developing this repository (matching `FLUTTER_VERSION` in CI's `.github/workflows/ci.yml`). The dev dependency `flutter_lints 6` requires Dart >= 3.8 (Flutter >= 3.32); below that version the repository's dev dependencies cannot be resolved. The Flutter >= 3.3.0 declared in each package's `environment` is the minimum supported version for SDK users — do not confuse the two.

The `Makefile` at the project root is the local development entry point; run `make setup` for first-time setup. `make help` lists all targets:

| target | Purpose |
|--------|---------|
| `make setup` | Runs `config` + `deps` + `pods` in sequence |
| `make config` | Generates `example/config.local.json` (from `example/templates/config.local.example.json`) and a placeholder `example/lib/env.dart` (from `example/templates/env.example.dart`); skipped if they already exist |
| `make env-gettoken` | Exchanges user tokens for each account on the host per `config.local.json` and writes `example/lib/env.dart` directly; exits non-zero when required fields are missing or still `TODO` |
| `make deps` | Runs `flutter pub get` in the example directory, resolving the path dependencies of the 4 sub-packages |
| `make pods` | Runs `deps` first, then uses mtime to check whether Podfile/podspec is newer than Podfile.lock, running `pod install` in `example/ios` only when needed |
| `make auto-report PLATFORM=<android\|ios> [DEVICE=<id>] [SCRIPT=<json>]` | Runs the 5.0.0 auto script and writes a traceable report to `reports/5.0.0/<run-id>/` (on Android it first ensures the debug build is installed, then pushes the script into the app's internal directory by App uid) |
| `make auto-compare ANDROID=<run-dir> IOS=<run-dir>` | Compares two Android/iOS runs of the same path; exits non-zero when steps diverge |
| `make clean` | Cleans the example's build artifacts, iOS Pods, and Podfile.lock |
| `make help` | Shows all commands |

> **Important**: after changing the native dependency version (e.g. HyphenateChat) in `im_flutter_sdk_ios.podspec`, you must run `make pods`. `flutter run` does not track podspec changes and will skip pod install, causing iOS to compile against the old native SDK and fail with compilation errors.

## Test Data Preparation

Example run data is prepared in two steps; both products are local files and neither is committed:

1. **Credentials and test data**: `make config` generates `im_flutter_sdk/example/config.local.json`; fill in `restApi`, `appKey`, `clientId` / `clientSecret`, plus the test `accounts`, `groups`, and `rooms` per the `TODO` placeholders in `example/templates/config.local.example.json`.
   - The project configures **one environment only**: this file describes the environment currently being run. To switch environments, edit this file's values directly, or keep multiple copies outside Git (e.g. `config.ngi.json` / `config.ebs.json`) and swap them in; the tooling does not do multi-environment selection.
   - Private deployment is not a separate mode: set the top-level `enablePrivateConfig` to `true` and fill in `webSocketServer` / `restServer` / `msyncServer`; the generated `env.dart` will carry these server fields and force `enableDNSConfig=false`.
2. **Environment and tokens**: `make env-gettoken` exchanges an app token for each account's user token on the host and writes them directly into `example/lib/env.dart`. The app token and `clientSecret` are not written to the env file.

`example/config.local.json` and `example/lib/env.dart` are both gitignored (see the last two entries of `im_flutter_sdk/.gitignore`); do not commit them.

## Running and Verification

The example is a visual API test app supporting two modes:

- **Manual mode**: initialize → log in → search for an API → fill in JSON parameters and call; results and listener callbacks are viewed in the floating log.
- **Script mode** (suited for AI / automation): pass a JSON script via `--dart-define=API_SCRIPT=...` to execute a batch of APIs in order; each event is output as a single-line JSON with the `[APITEST]` prefix to stdout and a log file.

For page flows, script fields (`steps`, `expect`, `$config.*` / `$prev` / `$step.<id>.*` references, `timeoutMs`), log channels, and Android path caveats, see [im_flutter_sdk/example/README.md](im_flutter_sdk/example/README.md). Manual runs:

```bash
cd im_flutter_sdk/example
flutter run -d <device>                                       # manual mode
flutter run -d <device> --dart-define=API_SCRIPT=<script path>  # script mode
```

For 5.0.0, the logged-in scripts are split into positive/negative paths (both single-account):

- `example/scripts/script_500_apis_positive.json`: the normal path — 20 steps, all expected to succeed, including batch interfaces mixed with unparseable message ids;
- `example/scripts/script_500_apis_negative.json`: the error path — 10 steps, each expecting a specific error code. Among them, passing a missing message to `fetchGroupMessageReadReceipts` crashes the Android native process, so that step is not executed; the runner always records a `fetch-group-receipt-missing-disabled` candidate.

When evidence needs to be preserved, use the runner at the repository root (more reproducible than typing `flutter run` by hand: it automatically boots/activates the emulator and pushes the script into the Android app's private directory):

```bash
make auto-report PLATFORM=android DEVICE=emulator-5554
make auto-report PLATFORM=ios DEVICE=<udid of a booted simulator>
make auto-report PLATFORM=android SCRIPT=im_flutter_sdk/example/scripts/script_500_apis_negative.json
make auto-compare ANDROID=reports/5.0.0/<android-run> IOS=reports/5.0.0/<ios-run>
```

Each run writes `run.json`, `events.jsonl`, `crash.log`, `steps.json`, `summary.md`, and `issues.md` under `reports/5.0.0/<run-id>/`; comparisons write `comparison-<path>-<timestamp>.md` under `reports/5.0.0/`. Reports may contain account and resource identifiers, so the entire `reports/` directory is gitignored; only reviewed and sanitized conclusions go into `docs/porting/`.

### Quality Gate

`tool/ci/run_quality.sh` is CI's quality job — locally and in CI the same gate applies. It first calls `tool/ci/ensure_example_env.sh`: if `im_flutter_sdk/example/lib/env.dart` does not exist, it generates an empty placeholder from `example/templates/env.example.dart`; if it already exists, it is kept as-is. This file is gitignored; without it a fresh checkout of the example cannot compile at all, and `flutter analyze` directly reports `Target of URI doesn't exist: '../env.dart'`. The script fills in only this one file — it **does not generate `example/config.local.json`**: the credentials in that file belong to each user's own environment configuration, read only by local `make env-gettoken`; CI does not fabricate one for anyone. It then runs in order:

1. `flutter pub get` in the 5 packages in sequence;
2. `dart format --set-exit-if-changed`: checks only changed `.dart` files; the baseline is specified by `FORMAT_BASE_SHA` (CI passes the PR base / pre-push sha), falling back to `HEAD^` when unset locally;
3. `flutter analyze --fatal-infos` in the 5 packages in sequence: `info`-level issues also count as failures;
4. `flutter test --coverage` under `im_flutter_sdk`;
5. Three consistency scripts: `tool/ci/check_case_mapping.dart` (native ↔ Flutter naming mapping), `tool/ci/check_contracts.dart` (MethodChannel method-name constants and routing branches on all three ends), `tool/ci/check_versions.dart` (pubspec versions of the 4 packages, the iOS podspec version, and the native SDK versions declared in Android `build.gradle` and the iOS podspec).

> Note: step 4 only runs `im_flutter_sdk/test/`; `im_flutter_sdk/example/test/` is outside the gate — after changing the example, run `cd im_flutter_sdk/example && flutter test` separately.

### Deprecated API Scan

When wrapper code calls deprecated native APIs, javac / clang emit compile-time warnings with file and line numbers. The scan script recompiles the wrappers on both platforms, keeps the full build logs, and extracts call sites from them, producing an actionable to-do list:

```bash
make scan-deprecated                # scan both platforms
make scan-deprecated PLATFORM=ios   # scan iOS only
```

- A **clean build is required**: incremental builds do not re-emit warnings for unchanged files, so the script runs `clean` for each platform first. If the parser finds reused compilation in the log (`UP-TO-DATE` / `FROM-CACHE`), it marks the scan as failed rather than reporting "0 entries".
- Only wrapper sources are scanned (`im_flutter_sdk_android/android/src/main/java`, `im_flutter_sdk_ios/ios`); third-party warnings from the example and Pods / pub cache do not enter the report.
- Android requires `-Xlint:deprecation` (AGP does not enable it by default — it only prints `Note: ...` without file/line numbers), injected via `tool/ci/enable_deprecation_lint.gradle` with `-I`, **without modifying the plugin's own build.gradle**, so user builds are unaffected.
- Artifacts are archived by current branch name into `reports/<version>/deprecated/` (gitignored; e.g. the `5.0.0` branch writes `reports/5.0.0/deprecated/`, at the same level as auto reports): `{android,ios}-raw.log` raw build logs, `{android,ios}-deprecated-api.json`, and the `native-deprecated-api.md` summary report. When HEAD is not on a branch (detached), the script errors out directly instead of guessing a directory.
- Report-only, non-blocking: finding deprecated calls does not fail the command; only build failures or untrustworthy logs do. For the parsing contract and CI reuse plan, see [docs/spec/2026-09-21-deprecated-api-scan-spec.md](docs/spec/2026-09-21-deprecated-api-scan-spec.md).

### Device Integration Tests

Every device task on CI has an equivalent local script; the scripts first compare the local Flutter version against CI's pinned 3.47.0 (a mismatch only warns):

| Workflow | Trigger | Content | Local equivalent |
|----------|---------|---------|------------------|
| `.github/workflows/ci.yml` | PR, push to `flutter2_stable` / `4.*` / `5.*`, manual | Quality gate + Android debug build + iOS simulator build | `bash tool/ci/run_quality.sh` |
| `.github/workflows/device-smoke.yml` | Daily schedule + manual | Android / iOS login-free Presence smoke (`integration_test/no_login_presence_test.dart`, uses the test's built-in public demo appKey, no credentials needed) | `bash tool/ci/smoke_local.sh android\|ios` |
| `.github/workflows/single-account-nightly.yml` | Daily schedule + manual | Android / iOS single-account login + local database (`integration_test/single_account_local_test.dart`), requires `E2E_APP_KEY`, `E2E_USER_ID`, `E2E_REST_API`, `E2E_CLIENT_ID`, `E2E_CLIENT_SECRET`; the user token is freshly exchanged on each run by `tool/ci/fetch_e2e_user_token.sh` (5.0.0 no longer has password login; the token expires in ~24h and cannot be stored as a secret) | `E2E_APP_KEY=... E2E_USER_ID=... E2E_REST_API=... E2E_CLIENT_ID=... E2E_CLIENT_SECRET=... bash tool/ci/nightly_local.sh android\|ios` |

> The cron in `single-account-nightly.yml` (`37 18 * * *`, one hour earlier than RN's nightly) only takes effect on the **default branch** (`flutter2_stable`) — GitHub scheduled workflows "run the latest commit of the default branch using the default branch's workflow file", so before this file lands on the default branch, scheduled triggers on the 5.0.0 branch will not happen; only manual dispatch works.

Android requires a booted emulator (the scripts hard-connect to `emulator-5554`); on iOS, `run_ios_simulator_test.sh` boots the simulator itself, with logs written to `artifacts/*.log` (gitignored).

The two example build jobs in `ci.yml` and both `run_*_test.sh` scripts first call `tool/ci/ensure_example_env.sh` to generate the `example/lib/env.dart` placeholder (filling in only this one file, without touching `config.local.json`), so they can run directly on a fresh checkout (or CI) without `make config` first; an existing real local environment is not overwritten — which environment to run is still decided by local `config.local.json` + `make env-gettoken`.

Both `run_*_test.sh` scripts wipe the app's data on the device before running (`adb uninstall` / `xcrun simctl uninstall`, ignored if the app is absent). Reason: `flutter test` over-installs an already-installed app and only uninstalls after the run ends; leftover login state on a local device would fail cold-start-dependent cases (e.g. `FL-APP-001`). CI uses fresh devices every time and is unaffected.

## Coding Conventions

Naming conventions, bilingual comment rules, the standard chain for adding an API (Dart → constants → Android → iOS), and the pre-commit self-check list are maintained centrally in [AGENTS.md](AGENTS.md); they apply equally to human developers and are not repeated here.

## Naming and Compatibility Conventions

- Since 4.22.0, public APIs use the unified `Chat` prefix naming (aligned with the overseas agora_chat_sdk);
- Legacy `EM*` names remain compatible via `@Deprecated` typedefs in `im_flutter_sdk/lib/em_compat.dart`; new code must not use the old names. `em_compat.dart` is generated uniformly by a script — do not add entries by hand;
- A few names that cannot be typedef'd (`ChatLog`, `ChatTools`, `ChatGroupPermissionTypeExtension`, etc.) have no legacy-name compatibility — take care when referencing them.

## Generating API Documentation

Public APIs of the main package use bilingual (Chinese + English) comments (`~english` / `~chinese` / `~end` marker blocks; format in AGENTS.md "Documentation Comment Conventions"). After modifying comments or adding APIs, regenerate the API docs to check the rendering:

```bash
cd im_flutter_sdk
scripts/gen-apidoc.sh        # Chinese version → output/apidoc-cn/
scripts/gen-apidoc.sh en     # English version → output/apidoc-en/
```

- The script strips the other language block and the marker lines in a temporary copy, then runs `dart doc` without modifying the sources; `im_flutter_sdk/output/` is gitignored and generated artifacts never enter the repository;
- The side navigation is loaded dynamically via JS and must be accessed over HTTP; double-clicking `index.html` (file:// protocol) yields a blank sidebar. Local preview:

  ```bash
  cd im_flutter_sdk/output/apidoc-cn && python3 -m http.server 8765
  # open http://localhost:8765/ in a browser
  ```

- For deployment, serve the contents of `output/apidoc-cn/im_flutter_sdk/` as the site root (class pages must be mounted under the root path);
- `dart doc` reports unresolved doc reference warnings for `[xxx]`-style text in comments — a pre-existing style issue that does not affect generation.

## Version Numbers and CHANGELOG

- The four sub-packages must keep identical version numbers; modifying only one of them is forbidden.
- The CHANGELOG is bilingual: each version keeps a `## <version>` heading with a `### 中文` section and an `### English` section; new entries must be added in both languages. Public API names in entries must use the new naming (`Chat*`); legacy `EM*` names must not appear.
- When adding an API: the main package's CHANGELOG records the new API entry; the interface / android / ios CHANGELOGs record their respective actual changes.

## Branching and Release Process

- **Since 4.x, each release version corresponds to a branch with the same name** (e.g. `4.22.0`); tags are not used. 3.x leftover tags are history only.
- The default branch is `flutter2_stable`; `alpha`, `dev` etc. are feature or historical branches — no version development on them.
- Version development flow:
  1. After confirming the working tree is clean, create a branch named after the target version from `flutter2_stable`;
  2. Complete development and verification on that branch: pass the quality gate with `bash tool/ci/run_quality.sh`, build and run the example on both Android/iOS, and run through `script_500_apis_positive.json` / `script_500_apis_negative.json` (or `make auto-report`), keeping the reports;
  3. After verification passes, merge back into `flutter2_stable`.
- Version upgrades (aligning with the public APIs of a new native SDK version) have a dedicated workflow and acceptance report template; see the `platform-sdk-porting-v2` skill in the team workspace and past upgrade reports.
