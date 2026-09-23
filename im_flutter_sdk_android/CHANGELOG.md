## 5.0.0
- Upgraded the Android native SDK dependency to 5.0.0;
- Adapted to Token login, data sync, batch read receipts, and the group configuration rework;
- Removed the legacy wrapper routes and listener callbacks deleted in native 5.0.0;
- Consolidated disconnection events into `onDisconnected` with platform reason codes passed through: `onDisconnected(int)` no longer splits events by reason code, and the device info for code 206 is merged into `onLogout` and delivered with the same event;
- Reason codes now use `EMError` constants, and pending listener callbacks are cleaned up according to the logout reason;
- Batch read receipts are no longer pre-validated by the wrapper: messageIds that cannot be resolved to local messages are skipped instead of failing the whole batch with 1; whether they are accepted is determined by the native SDK (110 when the whole batch cannot be resolved);
- Attachment and thumbnail downloads now use the overloads with `EMCallBack`, replacing the single-argument overloads deprecated in native 5.0.0;
- Removed the unreachable `from` fallback in server-side history fetch options: Dart now only sends `senders`, and the native `setFrom` is deprecated in favor of `setFromIds`;
- Added the native implementation of `deleteConversations` for batch local conversation deletion (`asyncDeleteConversations`);
- Removed the listenerless per-message `onMessageDeliveryAck` emission and the leftover `onMessagesRecalled` constant;
- Removed the unreachable `from` fallback in conversation keyword search (`loadMsgWithKeywords`): Dart now only sends `senders`;
- Removed the image message body `thumbnailSecret` pass-through (deprecated in native 5.0.0 and already removed in RN; the video body keeps it);
- Removed the dead wrapper routes that no Dart code can reach: `uploadLog`, `removeMsgFromServerWithTimeStamp`, `getImPushConfig`, `updateHMSPushToken`, `updateFCMPushToken`, `reportPushAction`, `updateOwnUserInfoWithType`, and `fetchUserInfoByIdWithType`, together with the unreachable `pushConfig` parsing in `EMHelper`;

## 4.24.0
- Upgraded the Android native SDK dependency to 4.24.1;
- Added the native implementation of server-side message search;

## 4.22.0
- Upgraded the Android native SDK dependency to 4.22.1;
- Added native implementations for new APIs including original (full-size) image download, speech-to-text, group business cards, contact sync, and user attribute subscription;

## 4.19.2
- Upgraded the Android native SDK dependency to 4.19.3.1;
- Fixed an issue on Flutter Android where sending a video failed when no first-frame thumbnail was set;

## 4.19.1
- Upgraded the Android native SDK dependency to 4.19.2;
- Fixed an issue where large files could not be uploaded in chunks;

## 4.19.0
- Upgraded the Android native SDK dependency to 4.19.1;
- Added support for receiving stream messages;

## 4.18.0
- Upgraded the Android native SDK dependency to 4.18.1;
- Added secure DNS resolution (DoH) at the underlying layer to improve connectivity;

## 4.17.0
- Upgraded the Android native SDK dependency to 4.17.1;
- The long connection now supports the WebSocket protocol;
- Private deployments can now switch between TCP and WebSocket for the underlying link;

## 4.16.0
- Upgraded the Android native SDK dependency to 4.16.1;
- Added the `loadMessagesWithIds` API;
- Fixed an issue where `Thread` conversations were added to the `conversation` list;
- Fixed an issue where the `EEMChatEventHandler#onMessageContentChanged` callback did not return the modification when a message other than text or custom was modified;
- Fixed an issue where fetching roaming messages with saving disabled (`FetchMessageOptions#needSave` set to false) still created a new local conversation;
- Fixed an issue where members still fetched group or chat room details from the server after the group or chat room was destroyed;
- Fixed an issue where updating group attributes affected the group avatar;
- Updated the `AOSL` library to 1.3.0;
- Added support for setting IPv6-format REST addresses in private deployments;

## 4.15.2
- Fixed an issue where the 220 error code returned on being logged out could not trigger the callback;
- Fixed a crash when `fetchReactionDetail` fetched a non-existent reaction;
- Added the `getCurrentDeviceId` API;
- Added the `loadConversationMessagesWithKeyword` API;
- Fixed ANR issues caused by frequent conversation API calls;

## 4.15.1

## 4.15.0

## 4.13.0+1

- Fixed a crash when the `announcement` was empty in the `onAnnouncementChangedFromChatRoom` callback.
- Fixed a crash when the `announcement` was empty in the `onAnnouncementChangedFromGroup` callback.

## 4.13.0

* Updated the native SDK to 4.13.0
