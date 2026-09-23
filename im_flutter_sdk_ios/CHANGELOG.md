## 5.0.0
- Upgraded the iOS native SDK dependency to 5.0.0, keeping CocoaPods and SPM consistent;
- Added the PushKit (VoIP push) route: `bindPushKitToken` calls `registerPushKitToken:completion:` and `unbindPushKitToken` calls `unRegisterPushKitTokenWithCompletion:`;
- `OptionsHelper` maps the certificate names as initialization options again: `apnsCertName` and `pushKitCertName` are read from the init payload and written to `EMOptions` (and returned by `toJson`), instead of being assigned while binding a token;
- `bindDeviceToken` no longer writes `options.apnsCertName` at runtime, and it ignores the `notifierName` sent by Dart;
- Adapted to Token login, data sync, batch read receipts, and the group configuration rework;
- Adapted to per-conversation delegates and the removals in native 5.0.0;
- Fixed an issue where paged group read receipt fetches did not return `totalCount`;
- Consolidated disconnection events into `onDisconnected`: each disconnection delegate is mapped to a platform reason code and dispatched uniformly, and force-logout callbacks now pass the reason code through as-is (including the active-number-limit case);
- Removed `activeNumbersReachLimitation`, which no longer exists in 5.0.0, and the unused `LoginExtensionInfoHelper`;
- The muted list in chat room info now uses the native 5.0.0 `muteMembers` (a user ID list) instead of the deprecated `muteList`; the external JSON structure is unchanged;
- Batch read receipts are no longer pre-validated by the wrapper: messageIds that cannot be resolved to local messages are skipped instead of failing the whole batch with 500; whether they are accepted is determined by the native SDK (110 when the whole batch cannot be resolved);
- Removed the unreachable `from` assignment in server-side history fetch options: Dart now only sends `senders`, and the native `from` is deprecated in favor of `fromIds`;
- Added the native implementation of `deleteConversations` for batch local conversation deletion: conversations are resolved one by one via `getConversationWithConvId`, non-existent IDs are skipped, and `deleteConversations:isDeleteMessages:completion:` is called;
- Fixed a crash in the `onRequestToJoinDeclined` event when the event dictionary was constructed with nil `reason`/`decliner`; the event now always carries `decliner` (an empty string when nil);
- Removed the listenerless per-message `onMessageDeliveryAck` emission, the dead `messagesDidRecall:` delegate method, and the related constants;
- Removed the unreachable `sender` fallback in conversation keyword search (`loadMsgWithKeywords`): Dart now only sends `senders`;
- Removed the image message body `thumbnailSecret` pass-through (removed in RN as well; the video body keeps it);
- Fixed the video message body toJson key mistakenly written as `thumbnailSecretKey`; it is now `thumbnailSecret` to align with Dart/Android (the native property name is unchanged);
- Removed the dead wrapper routes that no Dart code can reach: `uploadLog`, `removeMsgFromServerWithTimeStamp`, `getAllChatRooms`, `getImPushConfig`, the legacy `updateAPNsPushToken`/`updateFCMPushToken`/`reportPushAction` push routes, `updateOwnUserInfoWithType`, and `fetchUserInfoByIdWithType`, together with the unreachable `pushConfig` read/write in `OptionsHelper`;

## 4.24.0
- Upgraded the iOS native SDK dependency to 4.24.1;
- Added the native implementation of server-side message search;

## 4.22.0
- Upgraded the iOS native SDK dependency to 4.22.1;
- Added native implementations for new APIs including original (full-size) image download, speech-to-text, group business cards, contact sync, and user attribute subscription;

## 4.19.2
- Added iOS Swift Package Manager integration support;

## 4.19.1

## 4.19.0
- Upgraded the iOS native SDK dependency to 4.19.1;
- Added support for receiving stream messages;

## 4.18.0
- Upgraded the iOS native SDK dependency to 4.18.1;
- Added secure DNS resolution (DoH) at the underlying layer to improve connectivity;

## 4.17.0
- Upgraded the iOS native SDK dependency to 4.17.1;
- The long connection now supports the WebSocket protocol;
- Private deployments can now switch between TCP and WebSocket for the underlying link;

## 4.16.0
- Upgraded the iOS native SDK dependency to 4.16.2;
- Added the `loadMessagesWithIds` API;
- Fixed an issue where the `EEMChatEventHandler#onMessageContentChanged` callback did not return the modification when a message other than text or custom was modified;
- Fixed an issue where fetching roaming messages with saving disabled (`FetchMessageOptions#needSave` set to false) still created a new local conversation;
- Fixed an issue where members still fetched group or chat room details from the server after the group or chat room was destroyed;
- Fixed an issue where updating group attributes affected the group avatar;
- Updated the `AOSL` library to 1.3.0;
- Added support for setting IPv6-format REST addresses in private deployments;

## 4.15.2
- Fixed a crash when `fetchReactionDetail` fetched a non-existent reaction;
- Added the `getCurrentDeviceId` API;
- Added the `loadConversationMessagesWithKeyword` API;

## 4.15.1

## 4.15.0

## 4.13.0+1

- Fixed a crash when the `announcement` was empty in the `onAnnouncementChangedFromChatRoom` callback.
- Fixed a crash when the `announcement` was empty in the `onAnnouncementChangedFromGroup` callback.

## 4.13.0

* Updated the native SDK to 4.13.0
