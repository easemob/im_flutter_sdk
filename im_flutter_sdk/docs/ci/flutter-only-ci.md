# Flutter-only CI stages

CI uses Flutter unit, contract, and device integration tests. AI script tests
and manual example usage have separate entry points; see the
[verification architecture](../../../AGENTS.md#verification-architecture).

1. `Flutter CI` is the required PR gate. It runs Dart formatting, analysis,
   unit tests, MethodChannel contracts, package/podspec versions, the static
   Native case mapping, and Android/iOS example builds.
2. `Flutter Device Smoke` runs 17 cases: SDK initialization, five existing
   Presence errors, and 11 negative client/contact/group/message cases on
   Android Emulator and iOS Simulator. It needs no account or secret.
3. `Flutter Single Account Nightly` targets 22 positive and eight negative cases covering client
   state, contacts/blacklists, group lifecycle and queries, local conversations,
   and messages. One account logs into the device; another prepared account is
   used as a peer without running a second client. Android and iOS are serialized.

The two device entries remain `example/integration_test/no_login_presence_test.dart`
and `single_account_local_test.dart`. The logged-in entry registers cases from
`modules/`; new negative cases use `*_cases.negative.dart`, and `support/` supplies shared helpers. IDs, assertions, and source files
are listed in [native-case-mapping.json](native-case-mapping.json).

Contacts and groups are verifiable on one device with prepared resources and
independent REST checks. Contact deletion checks only successful API completion
for both `keepConversation` values; REST is used for fixture preparation and
restoration, not to recheck the delete result. Message sending correlates the
final SDK callback with the sent message to verify server confirmation; it does not establish recipient
delivery. Multi-device collaboration, Thread, Room, Push, and active network-loss
simulation are outside this scope. Full API exclusions and selection rationale
are in the [selection record](../../../docs/refs/ci-basic-api-tests/2026-11-07-api-selection.md).

The Nightly workflow reads `E2E_APP_KEY`, `E2E_USER_ID`, `E2E_REST_API`,
`E2E_CLIENT_ID`, and `E2E_CLIENT_SECRET` from the protected
`flutter-single-account` GitHub Environment and fetches a fresh user token.
The temporary dart-define file contains the app key, user ID, user token,
peer ID, REST API and app token. Both the workflow and `nightly_local.sh`
prepare these six fields automatically; peer and token Secrets are not required.
The input contract, direct device command, and log handling are documented in
[CONTRIBUTING.md](../../../CONTRIBUTING.md#device-integration-tests).

`tool/ci/ensure_example_env.sh` creates the missing gitignored `example/lib/env.dart`
placeholder for compilation and preserves an existing file. Integration tests
take credentials from dart-defines, independently of the example's local data
under `im_flutter_sdk/example/config.local.json`.

The latest local positive-suite run passed 22/22 on each platform. Contact
deletion cases check API completion; earlier local-sync failures remain recorded.
The 19 new negative cases
include two send-error cases that currently fail on both platforms: the callback
has the expected error code but still reports message status `PROGRESS` instead
of `FAIL`. Assertions remain intact pending review; see the
[negative verification record](../../../docs/refs/ci-basic-api-tests/2026-11-07-negative-verification.md).
The
[verification record](../../../docs/refs/ci-basic-api-tests/2026-11-07-positive-verification.md)
contains platform results, per-case CSV, and unresolved issues. Daily schedules
run the default branch's workflow; branch-specific validation uses manual dispatch.
