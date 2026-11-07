# Flutter-only CI stages

CI uses Flutter unit, contract, and device integration tests. AI script tests
and manual example usage have separate entry points; see the
[verification architecture](../../../AGENTS.md#verification-architecture).

1. `Flutter CI` is the required PR gate. It runs Dart formatting, analysis,
   unit tests, MethodChannel contracts, package/podspec versions, the static
   Native case mapping, and Android/iOS example builds.
2. `Flutter Device Smoke` runs the same logged-out SDK initialization and five
   Presence error cases on Android Emulator and iOS Simulator. It needs no
   account or secret.
3. `Flutter Single Account Nightly` targets 22 positive cases covering client
   state, contacts/blacklists, group lifecycle and queries, local conversations,
   and messages. One account logs into the device; another prepared account is
   used as a peer without running a second client. Android and iOS are serialized.
   The expanded entry's configuration preparation is incomplete, as noted below.

The two device entries remain `example/integration_test/no_login_presence_test.dart`
and `single_account_local_test.dart`. The logged-in entry registers cases from
`modules/`; `support/` supplies shared helpers. IDs, assertions, and source files
are listed in [native-case-mapping.json](native-case-mapping.json).

Contacts and groups are verifiable on one device with prepared resources and
independent REST checks. Message sending correlates the final SDK callback with
the sent message to verify server confirmation; it does not establish recipient
delivery. Multi-device collaboration, Thread, Room, Push, and active network-loss
simulation are outside this scope. Full API exclusions and selection rationale
are in the [selection record](../../../docs/refs/ci-basic-api-tests/2026-11-07-api-selection.md).

The Nightly workflow reads `E2E_APP_KEY`, `E2E_USER_ID`, `E2E_REST_API`,
`E2E_CLIENT_ID`, and `E2E_CLIENT_SECRET` from the protected
`flutter-single-account` GitHub Environment and fetches a fresh user token.
Its temporary dart-define file currently contains only the app key, user ID,
and user token. The expanded entry also requires `E2E_PEER_ID`, `E2E_REST_API`,
and `E2E_APP_TOKEN`; neither the workflow nor `nightly_local.sh` supplies these
yet. Do not add token or fixed-peer Secrets to work around this preparation gap.
The input contract, direct device command, and log handling are documented in
[CONTRIBUTING.md](../../../CONTRIBUTING.md#device-integration-tests).

`tool/ci/ensure_example_env.sh` creates the missing gitignored `example/lib/env.dart`
placeholder for compilation and preserves an existing file. Integration tests
take credentials from dart-defines, independently of the example's local data
under `testing/config/environment.local.json`.

Positive-case acceptance remains incomplete: iOS has two preparation failures,
the cloud preparation path needs completion, and new negative cases have not
started. Existing negative cases remain in the smoke suite. The
[verification record](../../../docs/refs/ci-basic-api-tests/2026-11-07-positive-verification.md)
contains platform results, per-case CSV, and unresolved issues. Daily schedules
run the default branch's workflow; branch-specific validation uses manual dispatch.
