# Flutter-only CI stages

These stages intentionally run without `im-test-hub`.

1. `Flutter CI` is the required PR gate. It runs Dart formatting, analysis,
   unit tests, MethodChannel contracts, package/podspec versions, the static
   Native case mapping, and Android/iOS example builds.
2. `Flutter Device Smoke` runs the same logged-out SDK initialization and five
   Presence error cases on Android Emulator and iOS Simulator. It needs no
   account or secret.
3. `Flutter Single Account Nightly` logs in with one protected account and
   validates native client state plus local conversation/message database
   behavior. Android and iOS are serialized so the fixed account is never used
   concurrently. A daily cron is configured, but scheduled runs use the default
   branch, so until this file lands on `flutter2_stable` the job only runs on
   manual dispatch.

Stage 3 reads `E2E_APP_KEY`, `E2E_USER_ID`, `E2E_REST_API`, `E2E_CLIENT_ID`, and
`E2E_CLIENT_SECRET` only from the protected `flutter-single-account` GitHub
Environment. 5.0.0 has no password login, and user tokens expire in ~24h, so a
token cannot be stored as a secret: each job exchanges the app credentials for a
fresh one (`tool/ci/fetch_e2e_user_token.sh`) before the emulator/simulator
boots, which fails fast on auth problems and keeps the client secret off the
device. The job masks the token, writes the app key, user id, and token to a
mode-0600 temporary dart-define file, never uploads that file, and deletes it in
an `always()` step.

Cross-device message delivery, ACK/callback correlation, offline replay,
contacts, groups, chat rooms, reactions, threads, and push are excluded here.
Those need multiple independently controlled clients and belong in the later
`im-test-hub` stage.

Every stage that compiles the example app first runs
`tool/ci/ensure_example_env.sh`, which creates the gitignored
`im_flutter_sdk/example/lib/env.dart` from `example/templates/env.example.dart`
(the same empty placeholder `make config` copies locally) and leaves an existing
file untouched. Without it a fresh checkout cannot resolve the `import
'../env.dart'` in `auto_mode.dart`, `init_page.dart`, and `login_page.dart`, so
analysis and the example builds fail before any test runs. The script
deliberately creates only that file: `example/config.local.json` describes the
environment a developer tests against and holds its credentials, so it stays a
local `make config` / `make env-gettoken` artifact and is never fabricated by CI.
