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
3. `Flutter Single Account Nightly` runs the four stable logged-in categories:
   base, group, contact, and user info. One account logs into the device; prepared
   offline peers and REST fixtures do not require a second running client.
   Android and iOS are serialized.

The five stable entries under `example/integration_test/` classify tests by login
precondition and explicit synchronization settings. Cases remain in business
`modules/`; negative cases use `*_cases.negative.dart`, and `support/` supplies
shared helpers. IDs, assertions, and implementation files are listed in
[native-case-mapping.json](native-case-mapping.json).

| Entry | Explicit `dataSyncType` | `enableUserInfo` | Existing cases |
|---|---|---|---|
| `logged_out_test.dart` | `conversations` | `false` | 17: APP-001; PRESENCE-001–005; AUTH-004/005; CONTACT-005–009; GROUP-003–005; MSG-006 |
| `logged_in_base_test.dart` | `conversations` | `false` | 26: AUTH-001/002/003/006/007; CONV-001–010, CONV-014, and CONV-013 with chatroom conversations disabled; MSG-001–005 and MSG-007–010 |
| `logged_in_group_test.dart` | `conversations \| joinedGroups` | `false` | 19: GROUP-001/002/006/007/008–022 |
| `logged_in_contact_test.dart` | `conversations \| contacts` | `false` | 6: CONTACT-001–004/010/011 |
| `logged_in_user_info_test.dart` | `conversations` | `true` | 2: USERINFO-001/002 |

All IDs have the `FL-` prefix. The normal entries explicitly use
`autoLoadConversations=true` and `enableChatroomConversation=false`. Group and
contact synchronization are independent from conversation synchronization;
`autoLoadConversations` and `enableChatroomConversation` are separate options.
“Base” is the selected explicit CI configuration, not a test of omitted SDK defaults.

**Special-configuration migration pending confirmation:** FL-CONV-011/012 require
`autoLoadConversations=false`; FL-CONV-013 also has an execution with
`enableChatroomConversation=true`. Preserve these three execution items and their
assertions until their destination is agreed. They are not included in the normal
entry counts above. The registered inventory contains 72 distinct IDs and
73 execution items; this is an inventory, not an execution result. Two additional
Presence cases (FL-PRESENCE-006/007) are implemented but await confirmation of
base-entry wiring and are excluded from these registered counts. See the
[batch-one coverage and validation record](../../../docs/testing/2026-11-10-ci-api-batch1.md).

Login classification describes the scenario's precondition, not a requirement to
remain logged in or out throughout a test. Logout/relogin belongs to base; invalid
login parameters belong to logged out. Message tests stay in base even when their
recipient is a group or REST preparation establishes friendship. Group list sync
is not a prerequisite for sending group messages, and friendship is not a universal
prerequisite for sending messages.

Add ordinary cases only to their business module's existing registration function.
Do not edit the five stable entries, change their shared initialization, add or
rename an entry, or modify workflows/runners as part of adding cases. If a new
business module requires entry imports or registration wiring, explain the need
and obtain confirmation before editing the entry; wiring is not exempt. If a
case needs an incompatible configuration, document the conflict and obtain
confirmation before changing batches; never remove a valid assertion to make the
case fit.

Both local and hosted nightly commands use `tool/ci/nightly_local.sh`. Its loop
calls the existing device runner for each selected logged-in category. Each batch
starts a fresh app because changing SDK initialization options requires an app
restart. A failed batch does not prevent later batches from running, and the final
summary and exit code retain any failure. No extra suite dispatcher is used.

Each run writes a human-readable case summary and JSON statistics under
`artifacts/ci/<run-id>/`, with links to per-attempt logs and Flutter JSON events.
The existing device runners accept `CI_TEST_NAME` for a single-test name regex;
full suites and selected tests both produce reports. Select the entry that actually
registers the requested case. Output files, counting rules, and regeneration
commands are documented in the [report guide](../../../docs/testing/2026-11-09-reports.md);
commands and configuration are in the [CI operating guide](../../../tool/ci/README.md).
Do not rerun the entire nightly suite when the current task has explicitly skipped
a known failure.

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
