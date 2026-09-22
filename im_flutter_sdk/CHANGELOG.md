## 5.0.0

- Upgraded the iOS/Android native SDK dependencies to 5.0.0;

### Breaking Changes

#### Login and Disconnection

- Login now supports Token only: removed registration `createAccount`, password login `login`/`loginWithPassword`/`loginWithAgoraToken`, and `isLoginBefore`; use `loginWithToken` instead;
- `fetchLoggedInDevices`/`kickDevice`/`kickAllDevices` now accept only a token (the `isPassword` password branch was removed), and the deprecated `getLoggedInDevicesFromServer` alias was deleted;
- Removed `ChatOptions.autoLogin`/`requireAck`/`enableAutoSyncContacts` and `ChatClient.updateRequireAckSetting`; renamed `renewAgoraToken` to `renewToken`;
- Consolidated disconnection events into a single `onDisconnected(int? errorCode, LoginExtensionInfo? info)`:
  - Removed the 8 callbacks `onUserDidLoginFromOtherDevice`, `onUserDidRemoveFromServer`, `onUserDidForbidByServer`, `onUserDidChangePassword`, `onUserDidLoginTooManyDevice`, `onUserKickedByOtherDevice`, `onUserAuthenticationFailed`, and `onAppActiveNumberReachLimit`;
  - Reason codes match the platform `EMError` values and are passed through as-is; unlisted reason codes are delivered as well;
  - Added the `ChatDisconnectErrorCode` constant table: 13 of them are "logout reasons" (the user has been logged out and must log in again) and 5 are "connection reasons" (the user remains online and the SDK reconnects automatically);
  - Device information is carried via `info` only when logging in on another device;
  - `LoginExtensionInfo.fromJson` falls back to an empty string instead of throwing when the native side does not carry `deviceName`;
  - Token expiry is still only reported via `onTokenDidExpire` and does not trigger `onDisconnected`;

#### Message Read Receipts

- Reworked message read receipts:
  - Added `sendMessageReadReceipts`, `getGroupMessageReadReceipts`, `fetchGroupMessageReadReceipts`, `clearConversationUnreadMessageCount`, `clearAllConversationUnreadMessageCount`, plus `ChatMessageReadReceipt` and `ChatGroupReadReceipt`;
  - Removed `sendMessageReadAck`, `sendGroupMessageReadAck`, `sendConversationReadAck`, `markAllConversationsAsRead`, `ChatConversation.markMessageAsRead`/`markAllMessagesAsRead`, `fetchGroupAcks`, `ChatMessage.groupAckCount`, and `ChatGroupMessageAck`;
  - `ChatMessage.hasReadAck`/`hasRead`/`needGroupAck` became the read-only `isPeerRead`/`isRead` and the writable `isNeedReadReceipt`, and a read-only `groupReadReceiptCount` was added;

#### Group Configuration

- Reworked the group configuration model: removed `ChatGroupStyle` and `ChatGroupOptions`; the `options` parameter of `createGroup` became `configs`; renamed `ChatGroup.isMemberOnly` to `isJoinApprovalRequired`; added `ChatGroupConfigs`, `ChatGroupConfigsType`, and `updateGroupConfigs`;

#### Removed Legacy APIs

- Removed legacy server-side fetch APIs in favor of local data automatically synced after login: `ChatManager.getConversationsFromServer`, `fetchConversationListFromServer`, `fetchConversation`, `fetchConversationsByOptions`, `fetchPinnedConversations`, `ChatContactManager.getAllContactsFromServer`/`fetchAllContacts`/`fetchAllContactIds`/`fetchContacts`, `ChatGroupManager.fetchJoinedGroupsFromServer`/`fetchPublicGroupsFromServer`;
- Removed the legacy `fetchHistoryMessages`; `fetchHistoryMessagesByOption` is kept;
- Removed client-side message reporting `reportMessage` and chat room creation/destruction `createChatRoom`/`destroyChatRoom`;
- Removed the contact sync events `onContactSyncStart`/`onContactSyncFinish`; use the connection-level data sync events uniformly instead;
- Removed deprecated (`@Deprecated`) public Dart APIs; see `docs/deprecated-apis.md` for the full list:
  - Methods: `ChatManager.searchMsgFromDB`, `ChatContactManager.getAllContactsFromDB`, `ChatContactManager.getBlockListFromServer`, `ChatContactManager.getBlockListFromDB`, `ChatGroupManager.changeGroupName`, `ChatGroupManager.changeGroupDescription`, `ChatPushManager.updateHMSPushToken`, `ChatPushManager.updateFCMPushToken`, `ChatPushManager.updateAPNsDeviceToken`;
  - Fields and parameters: `ChatGroup.name`, `ChatGroup.description` (including constructor parameters), `FetchMessageOptions.from` (including constructor parameters), the `sender` parameter of `ChatConversation.loadMessagesWithKeyword`, and the `fetchMembers` parameter of `ChatGroupManager.fetchGroupInfoFromServer` and `ChatRoomManager.fetchChatRoomInfoFromServer`;
  - Callbacks: `ChatEventHandler.onMessagesRecalled` is replaced by `onMessagesRecalledInfo`; `onMemberExitedFromGroup`/`onMemberJoinedFromGroup` of `ChatGroupEventHandler` are replaced by `onMembersExitedFromGroup`/`onMembersJoinedFromGroup`;
  - The 8 vendor push switches of `ChatOptions` (`enableOppoPush`, `enableMiPush`, `enableMeiZuPush`, `enableFCM`, `enableVivoPush`, `enableHWPush`, `enableAPNs`, `enableHonorPush`) are replaced by `ChatPushManager.bindDeviceToken`;
  - `ChatOptions` no longer serializes the `pushConfig` field (the native reading branch is unchanged);
  - Deleted the `ChatPushConfig` class and its file `lib/src/internal/chat_push_config.dart`: it only served the push switches above and was removed together with them; the `EMPushConfig` typedef pointing to it in `em_compat.dart` was deleted accordingly;
  - The remaining `EM*` compatibility typedefs in `em_compat.dart` and the default `ChatOptions` constructor are kept this time;

#### Other Signature Changes

- Completed two public signatures previously inferred implicitly as dynamic: `ChatError.hasErrorFromResult` returns `void` and `ChatPageResult.pageCount` returns `int?` (code relying on dynamic invocation needs to be adjusted accordingly);

### New Features

- Added `ChatManager.deleteConversations` to delete multiple local conversations at once, with an option to also delete the local messages in them; IDs of conversations that do not exist are ignored;
- Added post-login data sync configuration, data sync events, and the database-opened event: `ChatDataSyncType`, `ChatOptions.dataSyncType`, and `ConnectionEventHandler.onDataSyncStart`/`onDataSyncFinish`/`onDatabaseOpened`;
- `ChatMultiDevicesEvent` added `GROUP_UPDATE` (the iOS group info update event);
- `ChatConversation` added read-only `name` and `avatar`; `modifyMessage` added an optional `attributes`;

### Improvements

- Batch read receipts are no longer pre-validated by the wrapper: when `sendMessageReadReceipts`/`getGroupMessageReadReceipts` encounter a messageId that cannot be resolved to a local message, that entry is skipped (previously Android returned 1 GENERAL_ERROR for the whole batch and iOS returned 500 MESSAGE_INVALID); success is now determined by the native SDK, and when the whole batch cannot be resolved, the native 110 INVALID_PARAM is returned;
- Paged group message read receipt results now include a `totalCount` field (the iOS wrapper previously did not pass it down; fixed), and the Dart-side `ChatCursorResult` gained a nullable `totalCount` to carry it;
- `getUnreadMessageCount` no longer counts chat rooms, threads, and do-not-disturb conversations;

### Bug Fixes

- Fixed multi-device event mapping: filled in the missing group allowlist and muting-all-members events (native 30-33), corrected the swapped thread update/kick events (native 44/45), and unknown event values no longer throw during event handling;
- Fixed an issue where `onUserAuthenticationFailed` was incorrectly forwarded as `onDisconnected`;
- Fixed an issue where iOS did not report reaching the active-count limit (reason code 8);

## 4.24.0

- Added the server-side message search `searchMessagesFromServer` API;
- `ChatMessage` added the `webhookEnv` property, supporting environment identifiers for message callback routing;
- `ChatOptions` added the `ntpServers` option, supporting custom NTP servers;
- Upgraded the iOS/Android native SDK dependencies to 4.24.1;

## 4.22.0

- Upgraded the Android native SDK dependency to 4.22.1;
- Upgraded the iOS native SDK dependency to 4.22.2;
- Unified public API naming with the `Chat` prefix, aligned with the overseas agora_chat_sdk:
  - Public names with the old `EM` prefix (classes, enums, etc.) were renamed uniformly, e.g. `EMClient` → `ChatClient`, `EMOptions` → `ChatOptions`, `EMMessage` → `ChatMessage`;
  - Old names are kept as `@Deprecated`-marked typedefs in `em_compat.dart`; existing code continues to compile and run unchanged, but gradual migration to the new names is recommended, as the old names will be removed in a future major version;
  - A few names that cannot be typedef'd were renamed directly in an incompatible way: `EMLog` → `ChatLog`, `EMTools` → `ChatTools`, `EMGroupPermissionTypeExtension` → `ChatGroupPermissionTypeExtension`;
  - Deep-path imports (e.g. `package:im_flutter_sdk/src/models/em_options.dart`) are no longer compatible; import everything from the package entry `package:im_flutter_sdk/im_flutter_sdk.dart`;
- iOS supports Swift Package Manager integration, coexisting with CocoaPods:
  - The iOS plugin sources were migrated to the `Sources/im_flutter_sdk_ios` directory, with CocoaPods and SPM sharing the same sources;
  - With SPM integration, the native SDK is depended on via the Swift package `HyphenateChat_iOS` (4.22.2);
  - The minimum supported iOS version was raised to 13.0;
- Added the `downloadBigImage` API for downloading the original (big) image of an image message;
- Added the voice-to-text APIs `voiceMessageToText` and `voiceFileToText`;
- `ChatMessage` added message sender information `senderInfo`;
- `ChatImageMessageBody` added the original (big) image fields `bigImageLocalPath`, `bigImageRemotePath`, and `bigImageDownloadStatus`;
- `ChatVoiceMessageBody` added the voice transcription `text` field;
- Added the group namecard APIs `updateGroupNamecard`, `getGroupNamecard` and the group namecard change event `onUserGroupNamecardChanged`;
- `GroupMemberInfo` added the group member namecard `namecard`, nickname `nickname`, and avatar `avatarUrl` fields;
- `ChatContact` added the user attributes `userInfo` and add-time `addTimestamp` fields;
- Added the contact sync events `onContactSyncStart`, `onContactSyncFinish` and the contact info update event `onContactInfoUpdate`;
- Added the user attributes subscription APIs `subscribeUsersInfo`, `unsubscribeUsersInfo`, `fetchSubscribedUsers`, and `getLocalUserInfoByIds`;
- Added the user attributes update events `onSelfUserInfoUpdate` and `onUserInfoUpdate`;
- `ChatOptions` added the `enableUserInfo` and `enableAutoSyncContacts` options;

## 4.19.3

- Fixed an issue where calling `getUnreadMessageCount` on Flutter iOS also counted unread chat room messages;

## 4.19.2

- Upgraded the Android native SDK dependency to 4.19.3.1;
- Fixed an issue where videos could not be sent on Flutter Android when no first-frame thumbnail was set;
- Added iOS Swift Package Manager integration support;

## 4.19.1

- Upgraded the Android native SDK dependency to 4.19.2;
- Fixed an issue where large files could not be uploaded in chunks on Flutter Android;

## 4.19.0

- Upgraded the Android native SDK dependency to 4.19.1;
- Upgraded the iOS native SDK dependency to 4.19.1;
- Support receiving streaming messages;
- Fixed an issue where `loadConversationMessagesWithKeyword` and `getAllMessageCount` were not included in EMChatManager;

## 4.18.1

- Fixed the group events `onGroupMembersJoined和onGroupMembersExited` triggering the wrong callbacks;

## 4.18.0

- Upgraded the Android native SDK dependency to 4.18.1;
- Upgraded the iOS native SDK dependency to 4.18.1;
- The underlying layer supports secure DNS resolution (DoH), improving connectivity;

## 4.17.0

- Upgraded the Android native SDK dependency to 4.17.1;
- Upgraded the iOS native SDK dependency to 4.17.1;
- The persistent connection supports the WebSocket protocol;
- The underlying link of private deployment supports switching between TCP and WebSocket;

## 4.16.0

- Upgraded the Android native SDK dependency to 4.16.1;
- Upgraded the iOS native SDK dependency to 4.16.2;
- Added the `loadMessagesWithIds` API;
- Fixed `Thread` threads being added to the `conversation` list;
- Fixed an issue where, when modifying messages other than text and custom messages, the modified information was not returned in the `EEMChatEventHandler#onMessageContentChanged` callback;
- Fixed an issue where pulling roaming messages with saving disabled (`FetchMessageOptions#needSave set to false`) still generated a new local conversation;
- Fixed an issue where, after a group or chat room was dissolved, members still fetched the group or chat room details from the server after receiving the callback;
- Fixed an issue where updating group attributes affected the group avatar;
- Updated the `AOSL` library version to 1.3.0;
- Support setting REST addresses in `IPv6` format for private deployment;

## 4.15.2

- Fixed an issue where the 220 error code returned when logged out could not trigger the callback;
- Fixed a crash when `fetchReactionDetail` fetched a nonexistent Reaction;
- Added the `getCurrentDeviceId` API;
- Added the `loadConversationMessagesWithKeyword` API;
- Fixed an ANR issue on Android caused by frequently calling the APIs in `EMConversation`;

## 4.15.1

- Fixed a crash caused by `updatePushNickname` when not logged in or when parameters were invalid;
- Fixed a crash caused by `fetchChatroomInfoFromServer` after the `fetchMembers` parameter was removed;
- Fixed a crash caused by `modifyMessage` when an empty message body was passed;

## 4.15.0

- Upgraded the Android native SDK dependency to 4.15.0;
- Upgraded the iOS native SDK dependency to 4.15.0;
- Support GIF image messages;
- Support the group avatar feature;
- Support message attachment authentication. This feature requires contacting business to enable; once enabled, message attachments can only be downloaded by calling the SDK API.
- Support pulling only messages sent by specified group members when pulling roaming messages;
- Support loading only messages sent by specified group members when loading local conversation messages;
- Support including the member's join time when getting group member information;
- Fixed a parsing failure when getting one's own group member attributes on Android;
- Fixed `ChatRoomEventHandler#onRemovedFromChatRoom` not being invoked;
- Added the `onMembersJoinedFromGroup` and `onMembersExitedFromGroup` callbacks; `onMemberJoinedFromGroup` and `onMemberExitedFromGroup` are marked as deprecated;
- Added the `EMGroupManager#updateGroupName` and `EMGroupManager#updateGroupDesc` methods; the `EMGroupManager#changeGroupName` and `EMGroupManager#changeGroupDescription` methods are marked as deprecated;

## 4.13.0+1

- Fixed a crash caused by an empty `announcement` when receiving the `onAnnouncementChangedFromChatRoom` callback.
- Fixed a crash caused by an empty `announcement` when receiving the `onAnnouncementChangedFromGroup` callback.
- Added the `EMMultiDevicesEvent.UnKnow` type to prevent failures to parse newly added multi-device events;

## 4.13.0

### New Features

- The send-then-modify message API `EMChatManager#modifyMessage` supports modifying various message types:
  - Text/custom messages: support modifying the message content (body) and the extension `attributes`;
  - File/video/audio/image/location/combined-forward messages: only support modifying the message extension `attributes`.
  - Command messages: modification not supported.
- Added the `ExtSettings.kDisableIosEnterBackground` control, which controls the behavior and usage of iOS in the background; see the [initialization document]([initialization.html](https://doc.easemob.com/document/flutter/initialization.html)) for details.

#### Optimizations

- Optimized the reconnection logic, switching reconnection addresses by default.
- Rewrote the SDK in a federated plugin form;
- Upgraded the iOS dependency library to 4.13.0;
- Upgraded the Android dependency library to 4.13.0;

### Bug Fixes

- Fixed an issue where the latest message of a conversation fetched by the `EMChatManager#fetchConversation` method did not include reactions (Reaction) or translation information.

## 4.12.1

- Fixed `EMConversation.marks` being unavailable on Android;
- Fixed inaccurate results of `EMGroupManager.fetchMemberAttributes` on Android;
- Fixed a crash when the announcement callback received in chat rooms/groups was empty;
- Fixed the thumbnail status of image/video messages;
- Added exception throwing when `updateMessage` is called with a nonexistent message;
- Added the API `EMChatRoomManager.isMemberInChatRoomMuteList` to check whether the current user is in the chat room mute list;

## 4.12.0

#### New Features

- [IM SDK] After joining a chat room, the user receives the following information, i.e. the success callback after calling the joinChatroom method contains:
  1. Current chat room member count EMChatRoom#memberCount
  2. Chat room all-member mute status EMChatRoom#isAllMemberMuted
  3. Chat room creation timestamp EMChatRoom#createTimestamp, a new property.
  4. Whether the current user is in the chat room allowlist EMChatRoom#isInWhitelist. This is a new property, updated when the member receives an allowlist change callback.
  5. The timestamp when the current user's mute expires EMChatRoom#muteExpireTimestamp. This is a new property, updated when the member receives a mute change callback.

## 4.11.0

- Modified the parameters of `EMChatRoomEventHandler#onMuteListAddedFromChatRoom`;

## 4.10.1

- Fixed inaccurate direction of `fetchHistoryMessagesByOption` in Android installation environments;

## 4.10.0

- Fixed a failure of the `fetchSilentModeForConversations` method to get the do-not-disturb status of conversations.
- Fixed `applicationDidEnterBackground` and `applicationWillEnterForeground` not being invoked on iOS.

## 4.8.2+1

- Fixed possible message format conversion failures on Android;

## 4.8.2

#### Fixed

- Fixed inaccurate types of the iOS `EMChatManager.searchMsgsByOptions` and `EMConversation.searchMsgsByOptions` methods;

## 4.8.1+1

#### New Features

- Added the `EMChatRoomManager.joinChatRoom(String roomId, {bool leaveOther = true,String? ext,})` method, supporting carrying extension information when joining a chat room and specifying whether to leave all other chat rooms.
- Added the `EMChatRoomEventHandler.onMemberJoinedFromChatRoom(String roomId, String participant, String? ext)` callback. When a user joins a chat room with extension information, other members in the chat room can get the extension information in the user-joined callback.
- Added the `EMPushManager.syncConversationsSilentMode()` method, supporting fetching the push notification settings of all conversations from the server.
- Added the `EMPushManager.bindDeviceToken(String notifierName, String deviceToken)` method.
- Added the `EMConversation.remindType()` method for locally storing the push notification mode of a conversation.
- Added the `EMConversation.getLocalMessageCount()` method, which gets the number of messages in the local database within a specified time range.
- Added the `LoginExtensionInfo` user device extension information.
- Added `EMOptions.loginExtension` to set the extension information carried at login.
- Added `EMChatManager.searchMsgsByOptions` to search messages of all conversations in the local database by one or more message types.
- Added `EMConversation.searchMsgsByOptions` to search messages of all conversations in the local database by one or more message types.



#### Optimizations

- Support the AUT protocol, improving the service connection success rate under weak network conditions;
- The `updateHMSPushToken`, `updateFCMPushToken`, and `updateAPNsDeviceToken` methods are deprecated; `enableOppoPush`, `enableMiPush`, `enableMeiZuPush`, `enableFCM`, `enableVivoPush`, `enableHWPush`, `enableAPNs`, and `enableHonorPush` in `EMOptions` are deprecated; use `EMPushManager.bindDeviceToken` instead;
- Changed the `EMConnectionEventHandler.onUserDidLoginFromOtherDevice(String deviceName)` method to `EMConnectionEventHandler.onUserDidLoginFromOtherDevice(LoginExtensionInfo info)`

#### Fixed

- Fixed occasional crashes caused by `fetchConversationsByOptions`;
- Fixed an issue where the cache was not updated in time when blocking a contact.
- Fixed an issue where push might not work after logging out and logging back in.

## 4.6.1+3

- Fixed an OOM issue caused by the Android thread pool.

## 4.6.1+2

- On Android, updated OPPO push to oppo_push_3.5.2.aar. OPPO push supports REALME devices.
- On Android, updated vivo push to vivo_push_v4.0.4.0_504.aar.
- On Android, updated Mi push to MiPush_SDK_Client_6_0_1-C_3rd.aar.
- On Android, updated Meizu push to com.meizu.flyme.internet:push-internal:4.3.0.

## 4.6.1+1

- Optimized connection issues

## 4.6.1

#### Optimizations

- The recallMessage method added an ext parameter, supporting carrying custom information of type String when recalling a message;
- Added the message recall event EMChatEventHandler#onMessagesRecalledInfo, supporting notifying the receiver of messages recalled while they were offline.

#### Fixed

- Fixed an issue where, when fetching the contact list (including contact remarks) from the server, the second request returned no data if the contact list had not changed.
- Fixed an issue where, in special cases, attachment sending failed but the message was still sent successfully.
- Fixed an incorrect nextkey when pulling roaming messages.
- Fixed an issue on Android where, in some scenarios, after the user upgraded the database and then logged in a new user in the same process, building the database tables failed.

## 4.5.0

#### New Features

- Added the `EMChatManager#deleteAllMessageAndConversation` method for [clearing the current user's chat history](message_delete.html#清空聊天记录), including messages and conversations, with an option to also clear the server-side chat history.
- Added [searching messages by search scope](message.search.html#根据搜索范围搜索所有会话中的消息): when searching messages by keyword, you can choose a search scope from `MessageSearchScope`.
  - `MessageSearchScope`: contains three message search scopes — searching message content, searching only message extension information, and searching both message content and extension information.
  - `EMChatManager#loadMessagesWithKeyword`: searches messages of all conversations by search scope.
  - `EMConversation#loadMessagesWithKeyword`: searches messages of the current conversation by search scope.
- Support the [conversation mark](conversation_mark.html) feature.
  - `ConversationFetchOptions`: options for fetching conversations from the server, which can be used to get pinned conversations or marked conversations.
  - `EMChatManager#addRemoteAndLocalConversationsMark`: marks conversations.
  - `EMChatManager#deleteRemoteAndLocalConversationsMark`: unmarks conversations.
  - `EMChatManager#fetchConversationsByOptions`: pages through the conversation list from the server according to the `ConversationFetchOptions` options.
  - `EMConversation#marks`: gets all marks of a single local conversation.
  - `EMChatMultiDevicesEvent#CONVERSATION_UPDATE_MARK`: the conversation mark event in multi-device scenarios. When the current user updates conversation marks, including adding and removing marks, on one logged-in device, other logged-in devices receive this event.
- Support [chat room roaming messages](message_retrieve.html#从服务器获取指定会话的历史消息).
- Added the `EMChatOptions#useReplacedMessageContents` switch. When enabled, if the content is replaced by content moderation when sending a message, the sender can receive the replaced content.
- Added the [pinned messages](message_pin.html) feature.
  - Added the `EMChatManager#pinMessage` method for pinning messages.
  - Added the `EMChatManager#unpinMessage` method for unpinning messages.
  - Added the `EMChatManager#fetchPinnedMessages` method to fetch the pinned messages of a specified conversation from the server.
  - Added the `EMConversation#loadPinnedMessages` method, returning all pinned messages of the conversation.
  - Added the `MessagePinInfo` class, containing the operator and time of pinning and unpinning.
  - Added the `EMChatMessage#pinInfo` method, showing the pin details of a message.
  - Added the `EMChatEventHandler#onMessagePinChanged` event. When a user performs a pin operation in a group or chat room conversation, other members of the group or chat room receive this callback.
- Added the `EMOptions#messagesReceiveCallbackIncludeSend` switch. When enabled, successfully sent messages are also included in the `EMChatEventHandler#onMessagesReceived` callback.
- The message modification callback `EMChatEventHandler#onMessageContentChanged` supports returning custom messages modified via the RESTful API.

#### Optimizations

- `EMChatManager#fetchConversation` and `EMChatManager#fetchPinnedConversations` are no longer provided; use the `EMChatManager#fetchConversationsByOptions` method instead.
- Support [single-message forwarding](message_forward.html) using the message body, without re-uploading the attachment.
- In some scenarios, reduced the number of group detail fetches when receiving large numbers of group member event notifications.
- [Update the chat room member count when members join or leave](room_manage.html#实时更新聊天室成员人数), making the count updates more timely and accurate.
- Optimized the error messages for token login, making them more precise.
- Optimized the time taken to mark all conversations as read.
- Optimized the SDK's internal logic for randomly picking server addresses, improving the request success rate.
- Optimized the timeout for joining and leaving chat rooms.
- Optimized the reconnection logic after connection failures in some scenarios.
- Optimized attachment upload when sending attachment messages, supporting chunked upload.
- Optimized the retry logic when sending messages.
- The Android/iOS SDK removed the catch of the `NetworkOnMainThreadException` during network requests.
- Optimized the database upgrade logic.
- Increased the single log file size from 2 MB to 5 MB.
- Added the privacy manifest `PrivacyInfo.xcprivacy` on the iOS platform.
- Adapted to Android 14 Beta on the Android platform: adapted to the requirement that dynamically registered broadcast receivers must set `RECEIVER_EXPORTED` or `RECEIVER_NOT_EXPORTED` when targeting Android 14.

#### Fixed

- Fixed an issue where, in special scenarios, chat room listener events were lost after the SDK exited and logged in again.
- Fixed duplicate group member count calculation in some scenarios.
- Fixed occasional crashes in the data reporting module.
- Fixed crashes caused by calling the `EMChatManager#updateMessage` method to update messages in some scenarios.

## 4.2.1

#### Added

- Added the privacy manifest PrivacyInfo.xcprivacy to the iOS SDK;

#### Fixed

- Fixed occasional db issues;
- Fixed duplicate group member count calculation in some scenarios.
- Fixed possible duplicate upload of combined-forward attachments;
- Fixed attachment message forwarding failures;
- Fixed crashes caused by `EMChatManager#updateMessage` message updates in some scenarios;

#### Optimizations

- The `login` method is deprecated; use the `loginWithToken` and `loginWithPassword` methods instead;
- Optimized attachment upload;
- Reduced the Android package size;
- In some scenarios, reduced the number of group detail fetches when receiving large numbers of group member event notifications;
- Update the chat room member count when members join or leave, making the count updates more timely and accurate;
- Optimized the error messages for token login, making them more precise;
- Optimized the SDK's internal logic for randomly picking server addresses, improving the request success rate;
- Optimized the SDK's internal logic for randomly picking server addresses, improving the request success rate;
- When joining a chat room, if the passed chat room ID does not exist, the chat room can be created automatically;
- Support fetching chat room roaming messages;
- Optimized the timeout for joining and leaving chat rooms;
- Optimized reconnection after connection failures in some scenarios;

## 4.2.0

#### Added

- Added the contact remark feature.
- Added the `EMContactManager#fetchContacts` and `EMContactManager#fetchAllContacts` methods to fetch the contact list from the server all at once or paged; each contact object contains the contact's user ID and remark.
- Added the `EMContactManager#getContact` method to get a single contact's user ID and remark locally.
- Added the `EMContactManager#getAllContacts` method to page through the contact list locally; each contact object contains the contact's user ID and remark.
- Added the `EMMessage#isBroadcast` property to determine whether the message is a chat room global broadcast message. Chat room global broadcast messages can be sent by calling the REST API.
- Added the `EMGroupManager#fetchJoinedGroupCount` method to fetch the number of groups the current user has joined from the server.
- Added error code `706` indicating that the chat room owner is not allowed to leave the chat room. If `EMOptions#isChatRoomOwnerLeaveAllowed` is set to false at initialization, the chat room owner gets this error when calling the `EMChatRoomManager#leaveChatroom` method to leave the chat room.
- Added the `EMOptions#enableEmptyConversation` property to configure at initialization whether empty conversations may be returned when fetching the conversation list.
- Added the decliner and applicant parameters to the join-request-declined callback `EMGroupEventHandler#onRequestToJoinDeclinedFromGroup`, representing the user IDs of the decliner and the applicant.

#### Optimizations

- Unified the Agora Token and EaseMob Token login methods; the original `EMClient#login` method is deprecated, replaced by the `EMClient#loginWithToken` and `EMClient#loginWithPassword` methods. In addition, callbacks for the EaseMob Token being about to expire and already expired were added: the `EMConnectionEventHandler#onTokenDidExpire` and `EMClientDelegate#onTokenWillExpire` callbacks are also returned when the EaseMob Token has expired or half of its validity has passed.

#### Fixed

- Fixed reconnecting twice when the network recovered.
- Fixed inaccurate error messages returned when calling the leaveChatroom method while not logged in.

## 4.1.3

#### Added

- Support Android 14;
- Added the method `EMOptions#enableHonorPush` to enable the Honor push switch;

#### Fixed

- Fixed an error when calling `EMChatManager#getThreadConversation`;
- Fixed an error in the `EMMessage#chatThread` method;
- Fixed the `EMChatRoomEventHandler#onSpecificationChanged` callback not being invoked.
- Fixed a crash in `EMChatThreadManager#fetchChatThreadMembers`.
- Fixed an issue where, in special scenarios, chat room listener events were lost on the Android platform after exiting and logging in again.
- Fixed an issue where, after a message was modified, the message body lacked the from attribute when offline users came online and pulled history messages.

## 4.1.0

#### Added:
- Added the `EMOptions#osType` and `EMOptions#deviceName` properties for users to set the device type and device name;
- Added the `Combine` message type for combined-forward messages;
- Added the `EMChatManager#fetchCombineMessageDetail` method;
- Added the `EMChatManager#modifyMessage` method for users to modify sent messages; currently only text messages are supported;
- Added the `EMChatEventHandler#onMessageContentChanged` callback for users to listen for message edit implementations;
- Added the `EMClient#fetchLoggedInDevices` method, which can use a token to get the list of logged-in devices;
- Added the `EMClient#kickDevice` method, which can use a token to kick a specified device;
- Added the `EMClient#kickAllDevices` method, which can use a token to kick all logged-in devices;
- Added the `EMChatManager#fetchConversation` method to get the server conversation list; the original method `EMChatManager#getConversationsFromServer` is deprecated;
- Added the `EMChatManager#pinConversation` method to pin/unpin conversations in the server conversation list;
- Added the `hatManager#fetchPinnedConversations` method to fetch pinned conversations from the server;
- Added the `EMMessage#receiverList` property for sending targeted messages in groups/chat rooms;

#### Fixed:
- Fixed an issue where `EMConnectionEventHandler#onConnected` and `EMConnectionEventHandler#onDisconnected` could not be received on iOS;
- Fixed an issue where, in Android messages, a string type in the sender's `attributes` became an int type on the receiver side;

#### Optimizations:
- Added the leave reason to the `EMChatRoomEventHandler#onRemovedFromChatRoom` callback;
- Added the operator's deviceName to the `EMConnectionEventHandler#onUserDidLoginFromOtherDevice` callback for being kicked offline by another device;

## 4.0.2

#### Added:
- Added the `EMGroupManager#setMemberAttributes` method for setting group member attributes;
- Added the `EMGroupManager#fetchMemberAttributes` and `GroupManager#fetchMembersAttributes` methods for getting group member attributes;
- Added the `EMGroupEventHandler#onAttributesChangedOfGroupMember` group member attribute change callback;
- Added the `EMChatManager#fetchHistoryMessagesByOption` method;
- Added the `EMConversation#deleteMessagesWithTs` method;
- Added the `EMMessage#deliverOnlineOnly` property for delivering messages only to online users;

#### Fixed:
- Fixed multiple callbacks after Android hot reload;
- Fixed a crash caused by passing null as the key when getting chat room attributes on iOS;

#### Optimizations:
- Added a fetch direction to the `ChatManager#fetchHistoryMessages` method;

## 4.0.0+7

- Fixed the issue of initialization returning no result.

## 4.0.0+6

- Fixed inaccurate status after attachment download finished.

## 4.0.0+7

- Fixed initialization issues.

## 4.0.0+6

- Fixed inaccurate status after attachment download finished.

## 4.0.0+5

- Fixed the download attachment callback not being invoked.

## 4.0.0+4

- Crash when building video messages on Android.

## 4.0.0+3

- `onRemovedFromChatRoom` not called back on Android.

## 4.0.0+2

- Fixed List<String>? conversion failure;
- Fixed image message and video message conversion failure;

## 4.0.0

#### New Features

- Upgraded the dependent native `iOS` and `Android` SDKs to v4.0.0.
- Added the `EMChatManager#fetchConversationListFromServer` method to page through the conversation list from the server.
- Added the `EMMessage#chatroomMessagePriority` property implementing the chat room message priority feature, ensuring high-priority messages are processed first.

#### Optimizations

Changed the send-message result callback from `EMMessage#setMessageStatusCallBack` to `EMChatManager#addMessageEvent`.

#### Fixed

Fixed the failure of `EMChatManager#deleteMessagesBeforeTimestamp` to execute.

# 3.9.9+1

1. Fixed iOS group read receipts not being executed;
2. Added the API `EMConversation#removeServerMessageBeforeTimeStamp(timestamp)` to delete server roaming messages of a conversation by time.

# 3.9.9

Fixed:
1. Fixed SDK crashes in extreme cases.

## 3.9.7+4

Fixed:
1. The onGroupDestroyed callback not invoked on Android;
2. Unable to set buildingName when constructing location messages;

## 3.9.7+3

Fixed:
1. The onAutoAcceptInvitationFromGroup callback not invoked on Android;

## 3.9.7+2

Fixed:
1. Fixed StartCallback() not being called back;
2. Fixed the failure to fetch messages by time on iOS;

## 3.9.7+1

Fixed:
  1. Fixed the Android FCM send id occasionally being empty;
  2. Fixed the Android `SilentModeResult` expireTs being empty;

## 3.9.7

New Features:
  1. Added the chat room custom attributes feature.
  2. Added the `areaCode` method to limit the range of edge nodes to connect to.
  3. Added the `isDisabled` property to `EMGroup` to show the group's disabled status, which needs to be set by the developer on the server side. This property is returned when fetching group details via the `fetchGroupInfoFromServer` method in `EMGroupManager`.

Optimizations:
  1. Removed some redundant SDK logs.

Fixed:
  1. Fixed failures when fetching a large number of messages from the server in very rare scenarios.
  2. Fixed incorrect data statistics.
  3. Fixed crashes caused by printing logs in very rare scenarios.

## 3.9.5

- Marked the AddManagerListener method as deprecated;
- Added customEventHandler;
- Added EventHandler;
- Added the PushTemplate method;
- Added the Group isDisabled property;
- Added the PushConfigs displayName property;
- Updated API references;
- Upgraded native dependencies to 3.9.5

## 3.9.4+3

- Fixed `loadAllConversations` crash on Android.

## 3.9.4+2

- Fixed occasional Android crashes when executing `EMClient.getInstance.startCallback()`;

## 3.9.4+1

- Added ChatSilentMode;

## 3.9.4

- Removed deprecated APIs;

## 3.9.3

- Added the thread implementation;
- Fixed some bugs;
- The native SDK dependency version is 3.9.3

## 3.9.2

- Added the Reaction implementation;
- Added the reporting feature;
- Added the API for getting group read receipts;
- Added a download progress callback for group files;
- Fixed occasional video download failures;
- Fixed failures to get group do-not-disturb details;
- Fixed occasional iOS crash in startCallback;

## 3.9.1

- Added the user online presence (Presence) subscription feature;
- Added translation feature updates, including an auto-translation API. Users can translate on demand, and translate automatically when sending messages.

## 3.9.0+2

- Modified the user logout/offline callbacks;
  - EMConnectionListener#onConnected: the persistent connection recovered;
  - EMConnectionListener#onDisconnected: the persistent connection disconnected;
  - EMConnectionListener#onUserDidLoginFromOtherDevice: the current account logged in on another device;
  - EMConnectionListener#onUserDidRemoveFromServer: the current account was deleted by the server;
  - EMConnectionListener#onUserDidForbidByServer: the current account's login was rejected by the server;
  - EMConnectionListener#onUserDidChangePassword: the current account's password changed;
  - EMConnectionListener#onUserDidLoginTooManyDevice: the current account logged in on too many devices;
  - EMConnectionListener#onUserKickedByOtherDevice: the current account was forced offline by another logged-in device;
  - EMConnectionListener#onUserAuthenticationFailed: the current account's authentication failed;
- The native SDK dependency version is 3.9.2.1;
- Fixed iOS group ack issues;

## 3.9.0+1

- Fixed inaccurate message.attribute;
- Added the EMClient.getInstance.startCallback() method
  ```dart
  EMClient.getInstance.startCallback();
  ```
  The `EMContactManagerListener`, `EMGroupEventListener`, and `EMChatRoomEventListener` callbacks only start executing after this method is called;
- Fixed the failure to remove chat room allowlist members;

## 3.9.0

- Added the single-user push do-not-disturb API;
- Added API reference;
- Added the renewToken API;
- Modified the message callback approach;
- iOS removed automatic deviceToken binding; if needed, it must be added separately on the iOS side;
- Android removed redundant permissions;
- Fixed known bugs;

## 3.8.9

- Added do-not-disturb for one-to-one chat messages;
- Removed unnecessary information collection;
- Fixed crashes caused by database corruption in some Android scenarios;
- Removed the dependency on FCM11.4.0;
- Fixed crashes caused by the Android WAKE_LOCK permission;
- Added an error code for sending messages while the user is globally muted;
- Enhanced data transmission security;
- Enhanced local data storage security;
- Added a callback for token expiry when logging in with a token;
- Fixed the bug of incomplete history roaming message pulls;
- Use https by default;
- Optimized login speed;

## 3.8.3+9

- Moved push-related setting operations from EMPushConfigs to EMPushManager;
- Fixed known bugs;

## 3.8.3+8

- Fixed iOS token login failure;
- Modified the return values of the Login and Logout methods;

## 3.8.3+6

- Renamed EMImPushConfig to EMPushConfigs;
- Removed EMPushConfig from EMOptions. To set the push certificate, call EMOptions directly;
- Removed ShareFiles from EMGroup; to get shared files, call the API:
  `EMClient.getInstance.groupManager.getGroupFileListFromServer(groupId)`
- Changed isConnected, isLoginBefore, and Token to be fetched from native;
- Fixed group do-not-disturb settings not taking effect on Android;
- Fixed a crash when getting public groups;
- Modified the throw error logic;
- Modified the text message construction method to require parameter names;
- Modified some native method logic;
- Adjusted the project directory structure;
- Made the `onConversationRead` callback parameters required;
-

## 3.8.3+5

- Updated the Android native SDK dependency version;
- Fixed a crash when getting local groups;

## 3.8.3+4

* Fixed the message attribute type becoming a bool type;
* Fixed inaccurate group do-not-disturb attribute;
* Fixed the iOS importMessages method bug;
* Fixed the bug where callbacks were not invoked when groups/chat rooms were muted;
* Fixed the download method not invoking the callback;
* File message construction now provides a property for setting the file size;
* Renamed `EMGroupChangeListener` to `EMGroupEventListener`

## 3.8.3+3

* Fixed resendMessage not calling back onError when sending fails on Android;
* Fixed the wrong return type of fetchChatRoomMembers;

## 3.8.3+2

* Added group read receipts;
* The EMContact class is no longer provided; the username is returned directly as a String;

## 3.8.3

### English

* Added user attributes;
* Fixed known bugs;

## 1.0.0

* User management;
* Group management;
* Chat room management;
* Conversation management;
* Contact management;
* Push management;
