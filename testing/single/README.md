# Single-device API scripts (ohos line)

`auto_report.dart` starts the example app in auto mode once per script, reads the
`[APITEST]` event stream and writes a report. Scripts live in `cases/`; the
engine that executes them is `im_flutter_sdk/example/lib/auto/auto_mode.dart`.

## Prepare

All commands run from the worktree root.

```bash
make config          # example/config.local.json + placeholder example/lib/env.dart
# fill config.local.json: appKey, clientId/clientSecret, restApi, accounts, groups
make env-gettoken    # rewrites example/lib/env.dart with fresh account tokens
cd im_flutter_sdk/example && ../../.fvm/flutter_sdk/bin/flutter pub get && cd ../..
```

The scripts read `$config.accounts.0` (the account auto mode logs in with),
`$config.accounts.1` (peer account) and `$config.groups.0` (a group the first
account belongs to). Tokens expire: rerun `make env-gettoken` when they do.
The host needs `dart` (>= 3.3), `python3` and `hdc` on PATH.

## Run

```bash
# positive path (default script)
dart testing/single/auto_report.dart --platform ohos

# negative path
dart testing/single/auto_report.dart --platform ohos \
  --script testing/single/cases/script_1.16.0_apis_negative.json

# explicit SDK and device
FLUTTER_BIN=/path/to/custom_ohos/bin/flutter OHOS_DEVICE=127.0.0.1:5555 \
  dart testing/single/auto_report.dart --platform ohos --device 127.0.0.1:5555
```

| variable | default | meaning |
| --- | --- | --- |
| `FLUTTER_BIN` | `<root>/.fvm/flutter_sdk/bin/flutter`, then PATH `flutter` | HarmonyOS fork used for `flutter run` |
| `OHOS_DEVICE` | `127.0.0.1:5555` | hdc target; `--device` wins over it |
| `OHOS_SKIP_CODESIGN` | `1` | set `0` when the project ships a real signing configuration |

hdc cannot write the app sandbox, so the runner passes the whole script body
inline as `--dart-define=API_SCRIPT=<json>`; the script is never copied to the
device. init and login are executed by the engine and must not be scripted.

Events come from the `[APITEST]` lines of `flutter run`. If that output carries
none, the run waits for its 8-minute timeout, stops the `hdc shell hilog`
capture and replays `device.log` through the same parser; the normal path stops
two seconds after `script.done`. The android/ios branches are kept identical to
the 4.x runner, but this line only builds for ohos.

## What the scripts cover

`script_1.16.0_apis_positive.json` (16 steps):

| step | api | intent |
| --- | --- | --- |
| `user_info_self` | `ChatUserInfoManager.fetchUserInfoById` | read own profile from the server |
| `user_info_update_self` | `ChatUserInfoManager.updateUserInfo` | write the `sign` field |
| `user_info_local_self` | `ChatUserInfoManager.getLocalUserInfoByIds` | read the cached profile back |
| `user_info_subscribe_peer` | `ChatUserInfoManager.subscribeUsersInfo` | subscribe to the peer's profile |
| `user_info_subscribed` | `ChatUserInfoManager.fetchSubscribedUsers` | list subscribed users |
| `user_info_unsubscribe_peer` | `ChatUserInfoManager.unsubscribeUsersInfo` | drop the subscription |
| `presence_publish` | `ChatPresenceManager.publishPresence` | publish a presence description |
| `presence_subscribe_peer` | `ChatPresenceManager.subscribe` | subscribe to peer presence |
| `presence_members` | `ChatPresenceManager.fetchSubscribedMembers` | paginate subscribed members |
| `presence_status_peer` | `ChatPresenceManager.fetchPresenceStatus` | query peer presence |
| `presence_unsubscribe_peer` | `ChatPresenceManager.unsubscribe` | drop the presence subscription |
| `msg_self` | `ChatManager.sendMessage` | self-chat text message, asserts a server `msgId` |
| `message_translate_self` | `ChatManager.translateMessage` | translate the sent message (`$step.msg_self`) |
| `conversations` | `ChatManager.fetchConversationsFromDB` | paginate the local conversation list, asserts it is non-empty |
| `group_namecard_set` | `ChatGroupManager.updateGroupNamecard` | set the namecard in `groups[0]` |
| `group_namecard_get` | `ChatGroupManager.getGroupNamecard` | read the namecard from the local cache |

The script sets `init.autoLoadConversations=false`, the documented precondition
of `fetchConversationsFromDB`.

`script_1.16.0_apis_negative.json` (6 steps, each must fail with a positive
SDK error code):

| step | api | intent |
| --- | --- | --- |
| `translate_missing_message` | `ChatManager.translateMessage` | msgId absent from the local DB, wrapper returns `500` |
| `namecard_empty_group` | `ChatGroupManager.updateGroupNamecard` | empty group id |
| `namecard_unknown_group` | `ChatGroupManager.updateGroupNamecard` | group that does not exist |
| `presence_desc_too_long` | `ChatPresenceManager.publishPresence` | 4000-character description exceeds the server limit |
| `presence_page_size_zero` | `ChatPresenceManager.fetchSubscribedMembers` | `pageSize: 0` |
| `conversations_invalid_cursor` | `ChatManager.fetchConversationsFromDB` | undecodable cursor |

Both scripts use only the names registered in
`im_flutter_sdk/example/lib/registry/apis/` (21 entries on this line). Registry
entries that exist on 4.x but not here — `createGroup`, `modifyMessage`,
`getUnreadMessageCount`, `loadAllConversations`, the client/contact/thread
registries — are not scripted; add them to the example registry first. The
translation step needs the message-translation service enabled, otherwise it
reports `305 SERVICE_NOT_ENABLE` as an environment limitation, and the namecard
steps need `groups[0]` to be a group the logged-in account belongs to.

## Reports

Each run writes `artifacts/single/<timestamp>/ohos/`:

| file | content |
| --- | --- |
| `upgrade-report.md` | human report; start here |
| `upgrade-report.json` | structured statistics |
| `run.json` | script hash, device, init options, execution errors |
| `steps.json`, `summary.md` | per-step assertions and run summary |
| `events.jsonl`, `crash.log`, `issues.md` | raw events, crash/timeout evidence, issue candidates |
| `device.log` | full `hdc shell hilog` capture |

`artifacts/` is Git-ignored. The exit code is 1 when a step does not match its
expectation or `script.done` is missing.

Static check without a device: `dart testing/single/auto_report.dart --self-test`.
