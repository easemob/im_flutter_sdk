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
3. `Flutter Single Account Nightly` runs the shared logged-in suite covering client
   state, contacts/blacklists, group lifecycle and configuration, local conversations,
   chatroom conversation visibility, and messages. One account logs into the device;
   prepared offline peers and REST fixtures do not require a second client.
   Android and iOS are serialized. Independent initialization suites additionally
   verify explicit conversation synchronization, subscribed-user list membership,
   database pagination and enabled chatroom conversations. Saved-history cache
   updates run in the shared message module.

The smoke entry is `example/integration_test/no_login_presence_test.dart`;
`single_account_local_test.dart` registers logged-in cases from `modules/`.
New negative cases use `*_cases.negative.dart`, and `support/` supplies shared helpers.
IDs, assertions, and source files are listed in
[native-case-mapping.json](native-case-mapping.json).

Both local and hosted nightly commands use `tool/ci/nightly_local.sh`. Its loop
runs all four suites on the selected platform through the existing device runner.
Each suite starts a fresh app because changing SDK initialization options requires
an app restart. Separate logs are written under `artifacts/`; a failed suite does
not prevent the remaining suites from running, and the final summary and exit code
retain any failure. No extra suite dispatcher is used.

Each run also writes a human-readable case summary and JSON statistics under
`artifacts/ci/<run-id>/`, with links to per-attempt logs and Flutter JSON events.
The existing device runners accept `CI_TEST_NAME` for a single-test name regex;
full suites and selected tests both produce reports. Output files, counting rules
and regeneration commands are documented in the
[report guide](../../../docs/testing/2026-11-09-reports.md).

| Entry | Explicit initialization | Cases | Log suffix |
|---|---|---|---|
| `single_account_local_test.dart` | `dataSyncType=contacts\|joinedGroups`, `autoLoadConversations=true`, `enableChatroomConversation=false`, `enableUserInfo=false` | Existing modules, including FL-MSG-010 and FL-CONV-013 with chatroom creation disabled | `single-account.log` |
| `native_defaults_test.dart` | `dataSyncType=conversations`, `autoLoadConversations=true`, `enableChatroomConversation=false`, `enableUserInfo=false` | FL-AUTH-007; validates explicit conversation synchronization, not an omitted native default | `native-defaults.log` |
| `user_info_subscription_test.dart` | `dataSyncType=contacts\|joinedGroups`, `autoLoadConversations=true`, `enableChatroomConversation=false`, `enableUserInfo=true` | FL-USERINFO-001 | `user-info-subscription.log` |
| `conversation_config_test.dart` | `dataSyncType=contacts\|joinedGroups`, `autoLoadConversations=false`, `enableChatroomConversation=true`, `enableUserInfo=false` | FL-CONV-011/012/013 | `conversation-config.log` |

Log filenames have the platform prefix, for example
`artifacts/android-conversation-config.log`. Initialization-compatible tests stay
in `modules/`; only incompatible initialization configurations justify separate
suite entries. For focused verification, invoke the existing platform runner with
the desired entry and a distinct log name. Do not rerun the entire nightly suite
when the current task has explicitly skipped a known failure.

Contacts and groups are verifiable on one device with prepared resources and
independent REST checks. Contact deletion checks only successful API completion
for both `keepConversation` values; REST is used for fixture preparation and
restoration, not to recheck the delete result. Message sending correlates the
final SDK callback with the sent message to verify server confirmation; it does not establish recipient
delivery. Chatroom coverage is limited to local conversation visibility after
a correlated successful send; group invite configuration readback does not prove
an invite/accept business flow. Multi-device collaboration, Thread, Push, and active network-loss
simulation are outside this scope. Full API exclusions and selection rationale
are in the [selection record](../../../docs/refs/ci-basic-api-tests/2026-11-07-api-selection.md).

The Nightly workflow reads `E2E_APP_KEY`, `E2E_USER_ID`, `E2E_REST_API`,
`E2E_CLIENT_ID`, and `E2E_CLIENT_SECRET` from the protected
`flutter-single-account` GitHub Environment and fetches a fresh user token.
The temporary dart-define file contains the app key, user ID, user token,
peer ID, REST API and app token. The workflow prepares the file and passes it
through `E2E_CONFIG_PATH`; `nightly_local.sh` reuses it without deleting it. For
local runs without that path, the script prepares these six fields automatically
and deletes only its own temporary file. Peer and token Secrets are not required.
The input contract, direct device command, and log handling are documented in
[CONTRIBUTING.md](../../../CONTRIBUTING.md#device-integration-tests).

`tool/ci/ensure_example_env.sh` creates the missing gitignored `example/lib/env.dart`
placeholder for compilation and preserves an existing file. Integration tests
take credentials from dart-defines, independently of the example's local data
under `im_flutter_sdk/example/config.local.json`.

The historical 5.0.0 positive-suite run passed 22/22 on each platform. Contact
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

Current 5.1.0 coverage and actual execution totals are maintained in the
[coverage table](../../../docs/porting/5.1.0/2026-11-09-test-coverage.md) and
[verification report](../../../docs/porting/5.1.0/2026-11-09-test-verification.md).
