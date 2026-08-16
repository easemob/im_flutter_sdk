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
   concurrently.

Stage 3 reads `E2E_APP_KEY`, `E2E_USER_ID`, and `E2E_USER_PASSWORD` only from
the protected `flutter-single-account` GitHub Environment. The workflow writes
them to a mode-0600 temporary dart-define file, never uploads that file, and
deletes it in an `always()` step.

Cross-device message delivery, ACK/callback correlation, offline replay,
contacts, groups, chat rooms, reactions, threads, and push are excluded here.
Those need multiple independently controlled clients and belong in the later
`im-test-hub` stage.
