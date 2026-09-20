# IM API Tester (example)

A visual test harness for `im_flutter_sdk`. It lets a human tester — or an AI
agent — call SDK APIs with JSON parameters and inspect the results, for
verifying real data correctness after SDK upgrades.

## Setup

Before first run, from the project root:

```bash
make setup
```

This creates the ignored local files `config.local.json` and `lib/env.dart`
from templates, runs `flutter pub get`, and runs `pod install` if the Podfile or
podspec changed. Fill `config.local.json` with the environment you test against,
then fetch user tokens and generate the environment:

```bash
make env-gettoken
```

The project configures a single environment: `config.local.json` holds that
environment's `restApi`, `appKey`, `clientId`, `clientSecret`, accounts, groups,
rooms, and chat options, and `make env-gettoken` writes them into `lib/env.dart`.
To switch environments, edit or replace that file — keep your own copies (for
example `config.ngi.json` / `config.ebs.json`) outside Git; the tool does not
choose between environments.

Token acquisition happens on the host: the tool gets an app token with
`clientId` / `clientSecret`, uses it to get each account's user token, and never
writes the app token or client secret to `env.dart`. Private deployment is not a
separate mode: set the top-level `enablePrivateConfig` to `true` and fill
`webSocketServer` / `restServer` / `msyncServer`; `msyncServer` is then mapped to
Flutter's `imServer` and `enableDNSConfig` is forced to `false`.

## Page flow

```
Init page ──init ok──▶ Login page ──login ok──▶ Search page ──tap──▶ API call page
```

- **Init** (one-shot): edit the `EMOptions` JSON template and initialize. Cannot
  be redone without restarting the app.
- **Login**: password or token (toggle). Also hosts logout / re-login; later
  pages can navigate back here.
- **Search**: live, case-insensitive substring matching over API name and group.
- **API call**: pre-filled required-field JSON template → invoke → result JSON
  (copyable). Results are also written to the log.

The full API list is registered in `lib/registry/apis/` — add an `ApiEntry`
there to cover more APIs.

## Logs

Every event (API results, listener callbacks, lifecycle) is emitted as a
single-line JSON record:

```
[APITEST] {"ts":..., "seq":..., "source":"api.EMChatManager.sendMessage", "payload":{...}}
```

- **stdout**: prefixed with `[APITEST]`, easy to grep from `flutter run`.
- **file**: appended to `api_test.log` in the app documents directory; the
  absolute path is printed at startup (`source: "log.path"`). Prefer this
  channel on Android, where logcat may truncate long lines.
- **in-app**: a floating log ball appears after init (drag, open, clear, copy).

## Script mode (AI-friendly)

Run a whole scenario without touching the UI:

```
flutter run --dart-define=API_SCRIPT=/absolute/path/script.json \
            --dart-define=API_CONFIG=/absolute/path/config.json   # optional override
```

The generated `lib/env.dart` is the default test-data source. `API_CONFIG` can
point to an external JSON file to override it for one run. `init` is derived
from the environment's ChatOptions keys and `login` from the first account's
`id` + `token`; explicit `init` / `login` blocks in the script take precedence.

```json
{
  "steps": [
    { "api": "ChatManager.sendMessage", "params": { "to": "$config.accounts.1.id", "chatType": 0, "direction": 0, "status": 0, "body": {"type": 0, "content": "hi"} } },
    { "api": "ChatManager.downloadBigImage", "params": { "message": "$prev" }, "delayAfterMs": 1000 }
  ]
}
```

- `login` accepts `token`. A failed login is retried up to 5
  times (1s apart, each attempt logged) — native init can report success
  before the SDK is actually ready.
- Reference syntax (a param string that matches exactly is replaced, keeping
  the original value type):
  - `"$config.key"` / `"$config.key.sub"` — value from the config file;
  - `"$prev"` / `"$prev.a.b"` — previous step's `data` (dot path digs deeper,
    list indexes allowed);
  - `"$step.id"` / `"$step.id.a.b"` — `data` of any step that declared an
    `"id"`, for references spanning multiple steps.
- `TestUtil.writeBase64File` (script mode only, not in the registry) writes a
  base64 blob into the documents directory — use it to create local files for
  image/voice messages: `{ "api": "TestUtil.writeBase64File", "id": "f",
  "params": {"fileName": "a.png", "base64": "..."} }`, then
  `"$step.f.path"`.
- Each step is guarded by a timeout (default 30s, override per step with
  `"timeoutMs"`): a timed-out step logs `{"code": -2}` and the run continues —
  native calls sometimes never call back (e.g. some APIs while logged out).
- Optional `expect` assertions determine whether a step counts as failed:
  `{"success": true}`, `{"success": false}`, or `{"errorCode": 305}`. Without
  `expect`, only a successful API result passes.
- Steps run sequentially; a failed step is counted and does not abort the run.
- Ends with `{"source":"script.done","payload":{"total":N,"failed":M}}`; the app
  keeps running so listeners keep logging.
- Without `API_SCRIPT`, the app behaves as the manual tester above.

**Android note**: the emulator/device has its own filesystem — host paths do not
exist there (the iOS simulator shares the host fs, Android does not). The app can
only read its own internal files dir, and `adb push` into
`/sdcard/Android/data/com.example.example/files/` only works when the app created
that directory itself (an adb-created one belongs to `shell:ext_data_rw` with
mode 0770 and the app cannot even traverse it). Write the script as the app uid
instead:

```
adb shell "run-as com.example.example sh -c 'cat > /data/data/com.example.example/files/script_422_apis.json'" < scripts/script_422_apis.json
flutter run --dart-define=API_SCRIPT=/data/data/com.example.example/files/script_422_apis.json
```

`run-as` needs the debug build installed and the app's internal files dir to
exist, so run the app once (or `adb install -r` a debug APK) before pushing.
`make auto-report PLATFORM=android` does all of this by itself.

A full example covering the 4.22 additions lives at `scripts/script_422_apis.json`
(expects at least two accounts and one group in the generated environment).
The 5.0.0 login-state scenario is split into two single-account scripts:
`scripts/script_500_apis_positive.json` (20 steps, each expecting success,
including batches that mix an unresolvable message id) and
`scripts/script_500_apis_negative.json` (10 steps, each expecting an error code).
Receipt results are decided by native: Flutter builds no error codes and does not
drop a batch because of an unresolvable id. The missing-message case of
`fetchGroupMessageReadReceipts` crashes the Android native process, so it is not
executed: the negative script masks it and the runner always records a
`fetch-group-receipt-missing-disabled` candidate.

For a traceable local run, execute from the worktree root:

```bash
make auto-report PLATFORM=android DEVICE=emulator-5554
make auto-report PLATFORM=ios DEVICE=<booted-simulator-udid>
make auto-report PLATFORM=android SCRIPT=im_flutter_sdk/example/scripts/script_500_apis_negative.json
make auto-compare ANDROID=reports/5.0.0/<android-run> IOS=reports/5.0.0/<ios-run>
```

The runner brings the simulator app to the foreground where possible, pushes the
script to Android's app-specific directory, and writes a timestamped report to
`reports/5.0.0/<run-id>/`. Reports are Git-ignored because local events may
contain account or resource identifiers. Each report contains `run.json`,
`events.jsonl`, `crash.log`, `summary.md`, `steps.json`, and `issues.md`; only
confirmed, sanitized conclusions belong in `docs/porting/`.

`make auto-compare` reads two finished runs of the same path and writes
`reports/5.0.0/comparison-<path>-<timestamp>.md`: step status, result semantics,
and response shape for both paths, plus an `expected / Android / iOS` error-code
table for the negative path. It exits non-zero when steps disagree.

An Android AVD started with `-no-window` is headless and cannot be brought to
the foreground; the runner reports that state explicitly. Step parameters that
reference `$step.<id>` also establish a dependency: if the referenced producer
fails, the dependent step is marked `blocked` and skipped without invoking the
SDK.

## Coverage scope

The registry covers the 4.22 additions and the 5.0.0 APIs needed by the scripted
regression scenarios. Model-level additions are verified through API outputs and
event callbacks.
