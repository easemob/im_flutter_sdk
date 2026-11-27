## 2.0.0

Synced with im_flutter_sdk 5.2.0@3989d6b2. Includes all features and fixes up to that version.

### Changes since the previous sync (7abddf49 (easemob/4.16.0), 144 commits)

- 3989d6b2 test: rename em_-prefixed model test files to chat_ prefix
- ae15b11c feat: add dohVendor option to ChatOptions across Dart/Android/iOS wrappers
- 55811ac8 docs(example): document flutter create scaffolding step, ignore platform dirs
- 816e84fc Reorganize test assets into their owning areas
- 9b049ff2 Move internal test app out of the published package
- 66fe4e68 fix: doc description error
- 90b9d5b8 chore(example): deintegrate stale CocoaPods setup from the iOS example
- a9a816ac test: add 5.2.0 multi-body message coverage
- d503710a feat: port native SDK 5.2.0 APIs to Flutter (iOS 5.2.0 / Android 5.2.1)
- c7af3b40 docs: record the iOS deleteContact keepConversation fix in 5.1.0 changelogs
- 85b890b6 build: require im_flutter_sdk_interface ^5.1.0 across federated packages
- dc2676a2 build: require im_flutter_sdk_interface ^5.1.0 across federated packages
- f94c03b5 ci: isolate nightly accounts behind the 5x line marker, suspend presence description assertion
- ca6bf3ef docs: enforce English-only content on the 5.x line for Agora overseas whitelabel
- 92fbd925 test: tolerate missing peer conversation in FL-CONV-016 unread baseline clear
- 52e2b859 test: poll after deleteAllMessages in FL-CONV-006 (HIM-24174 known issue)
- f65cacff refactor: unify console log control under debugMode
- 5c8eddd4 iOS: bridge native SDK logs to unified log, disable core cout
- 783d755a test: annotate HIM-24173 and HIM-24170 native fix tracking in CI cases
- 48a34dd5 fix: wire group shared file download events to Dart
- 3283d277 test: expand single-account CI coverage and update mapping
- c0fc7a9c docs: explain CI cases and record HIM-24170 investigation
- 3c39febc test: add first batch of logged-in API coverage
- 2a08faf7 test: reorganize CI cases by login and sync configuration
- a803922b test: add reproducible CI and upgrade execution reports
- cd71d16f test: cover SDK 5.1.0 changes across CI and device scenarios
- adf9764b feat: port native SDK 5.1.0 APIs to Flutter
- 33cfc60a refactor: organize test suites and document verification
- 5e6bc2b2 chore: remove legacy testing infrastructure and references
- 347a8c10 feat: add optional sorting to local conversation loading
- 55401355 refactor(testing): separate account and device selection
- 9afa268f refactor: move presence and recall serialization into SDK models
- 85006933 test: add six multi-device scenarios and record verification
- 349687d5 test: add and validate six multi-device scenarios
- 4652ab88 docs(test): explain CI case scenarios and expectations
- b039b50f test(ci): add negative API integration cases
- d83b93f5 fix(ios): correct deleteContact mapping and scope CI assertions
- 10fc186c docs: update CI coverage and execution guidance
- 51cc8018 test: expand basic API integration coverage and record verification
- 909d092f test: add contact collaboration flow and troubleshooting guides
- 454daab7 feat: agent loginWithToken registry entry and connection info copy UI
- ed0bed35 fix: bypass lowercase http_proxy in test-tool HttpClients
- dda1523d feat: example-side agent control service (listening mode, API_CONTROL)
- 58ff0abe test: strengthen example assertions, registry APIs and data tooling
- d5dbad9a modify default values in chat_options.dart
- d1b060b1 Modify Flutter v5.0.0 API Reference
- 52a5b656 build: separate release dependencies from local SDK overrides
- 8c2fafbc perf: optimize API documentation generation
- eee49684 [HIM-23835] fix: align iOS thread callback target
- 41d2cf17 feat(push): add iOS PushKit APIs and make iOS certificate names init options
- 1230e20c docs: correct and extend the Flutter 5.0.0 migration guide
- e9874dba chore: update
- 7c38b298 refactor: remove dead method keys and unreachable native wrapper routes
- 89e5d1b7 docs: correct the getUnreadMessageCount exclusion note
- dc0c4d36 fix: clean up 5.0.0 leftovers and fix the iOS onRequestToJoinDeclined nil crash
- 8294991a feat: add ChatManager.deleteConversations for batch local conversation deletion
- 7ea031af docs: translate docs to English and reorganize the 5.0.0 changelog
- bf6862cb docs: cover the iOS wrapper totalCount fix in the 5.0.0 changelog
- 14b4992f fix(android,ios): drop the deprecated fetch-history sender fallback
- 3d9dd092 docs: expand the 5.0.0 changelog from the porting commits
- 5091974e refactor(api): remove the deprecated Dart public APIs
- af006163 docs: add deprecated Dart API inventory report
- b83ba494 chore(tooling): scan the wrappers for deprecated native APIs
- fb201114 feat(sdk)!: unify the disconnection callbacks into onDisconnected(errorCode, info)
- ece93914 refactor(example): configure a single environment instead of clusters
- 2c4de92e fix(ci): create the example env placeholder before building it
- c456d35e fix(sdk): map every native multi-device event value
- 6c210e93 test(example): pin the conversation unread count to measured behaviour
- 1ca6b49a fix(ci): fetch a fresh user token for the single-account nightly
- 6e53b8a2 fix: deliver the android auto script through run-as
- e4bd1d8d fix: clear app data before device integration tests
- 6358b143 chore: align package dependencies and migrate the example to file_picker 13
- 5c2c6124 fix: let native decide 5.0.0 receipt batch results
- e6c2e3db test: split 5.0.0 API paths and compare platforms
- 3066c03c fix: harden 5.0.0 regression verification
- 4c555667 feat: add traceable auto-mode reports
- 6d16ce85 feat: automate 5.0.0 example token and API regression flow
- a2f27eff feat: expose group read receipt total count
- dbab80b3 feat: port native SDK 5.0.0 APIs to Flutter
- 95117750 ci: trigger push builds on 5.* branches and reformat chat_message_search_option.dart
- c64bdb36 feat: port native SDK 4.22.1-4.24.1 public APIs to Flutter 4.24.0
- 56f0d0b7 chore: update template config.json
- 24f48e8c docs: translate code comments from Chinese to English
- fb75f9d7 chore: update
- 6b2885c8 chore: update ios version to  4.22.2
- d6a4b5a3 chore(example): upgrade Android build toolchain to Flutter 3.47 template
- 8854aa34 test(example): skip loadMessage assertions after delete on iOS
- bd4ab70e chore(example): refresh pubspec.lock for Flutter 3.47.0
- 9568d1f7 refactor(client): drop no-op try/catch in login wrappers
- e75552a6 style(example): format listeners.dart and init_page.dart
- 1839a801 fix(ios): align podspec version with Flutter package version 4.22.0
- bba04c15 fix(ci): point contract checker at SPM iOS source layout
- 0afb655f refactor(example): replace deprecated EM* aliases with Chat* names
- 974a3fa8 style: apply dart format to files changed by 4.22.0 merge
- bb11f9df fix: stop logging app key in init and changeAppKey
- ea7bf665 test: add chat message contract tests for Dart, Android and iOS
- 441dc9bb chore: regenerate lock files after 4.22.0 merge
- 180b3fa1 fix: mask sensitive credentials in log output
- 0319ca20 chore: update changlog
- f222de49 ci: narrow initial workflow rollout
- b77bfeff ci: add standalone Flutter CI stages
- bf16dacd fix: ChatMessage.fromJson 对有默认值的状态字段缺省回退
- ca215b3b feat(example): 新增悬浮附件选择工具,输出 JSON 供 API 验证使用
- 03d4889f docs: 新增 API 文档生成脚本与贡献者说明,修复双语注释标记异常
- 32729878 docs: 4.22.0 changelog 与 README 更新命名统一说明
- fb259466 refactor(dart): 统一公开 API 命名为海外 Chat* 风格，旧 EM* 名收拢至 em_compat.dart
- 8f9b75de chore: update example
- df626565 test(example): add presence/userinfo/translate API entries and verification scripts
- b4a44192 docs: split docs by audience — user README, CONTRIBUTING guide, AI-oriented AGENTS.md
- 67699160 chore(example): script-mode polish, 4.22 verification assets and make setup
- 40fcd106 fix: correct method-result key extraction and iOS init error propagation
- cef0e7dc fix(example): layout polish and README
- ae8fd418 fix(example): floating log overlay, script robustness and polish
- 42bd1e51 feat(example): rewrite as visual API tester with script mode
- 659f2718 feat: upgrade to 4.22.0 (iOS 4.22.1 / Android 4.22.1)
- 1458955d feat: add iOS Swift Package Manager support
- bc7b5075 chore: update config
- 0b24dae8 chore: update
- c21a4419 update changelog
- 1fd9d123 update lock files
- 778c4a26 update version to 4.19.2
- c61a11ec update lock files.
- 3d7fc2ad update changelog for 4.19.1
- 43b6a072 remove ohos from pubspec.yaml, will add the dependent back when ohos is added into the same repo.
- 600d8ea7 update version to 4.19.1
- d5fda189 add comments for APIs.
- be8b30f7 update changelog to add bugfix information.
- 7b25db10 bug fix: loadConversationMessagesWithKeyword and getAllMessageCount are not wrapped in EMChatManager.
- 9d288c5e update lock files under example
- 0a466da9 update changelog
- f688ae5f add stream message related code.
- 001e8d05 update version to 4.19.0
- 8c0c2b91 update pubspec.lock under example.
- c4f67c2a update changelog
- cfea6f9a bug fix: event onGroupMembersJoined and onGroupMembersExited trigger wrong callback.
- f4629429 update version to 4.18.1
- 97c1127b update version to 4.18.0 for ios, android and interface.
- 5a8ad012 update lock files in example dir.
- bcaae0d8 update changelogs.
- d6c1766d update version to 4.18.0
- 0b3a08bc update CHANGELOG.md files.
- 2e31593b Add webSocketServer and webSocketPort in EMOptions for private deploy.
- 47d77fb2 update ios and android dependents.
- f28786b4 update version from 4.16.0 to 4.17.0

## 1.4.0+1

### New features

- Added support for Apple PushKit (VoIP push) on iOS with the `ChatPushManager#bindPushKitToken` and `ChatPushManager#unbindPushKitToken` methods. Both methods take effect on iOS only and do nothing on other platforms.
- Added the `ChatOptions.pushKitCertName` option, which sets the name of the PushKit certificate uploaded in the console when the SDK is initialized. This option is specific to iOS and cannot be changed at runtime.

#### Improvements

- Upgraded the dependent Android SDK to 4.16.4.
- Upgraded the dependent iOS SDK to 4.16.4.
- Updated the `AOSL` library to 1.3.16.

## 1.4.0

### New features

- Added the `loadMessagesWithIds` API.
- Added the `getCurrentDeviceId` API.
- Added the `loadConversationMessagesWithKeyword` API.
- Added support for GIF image messages.
- Added support for group avatars.
- Added support for message attachment authorization. To use this feature, contact Agora business support to enable it. After it is enabled, message attachments must be downloaded through SDK APIs.
- Added support for pulling roaming messages sent only by specified group members.
- Added support for loading local conversation messages sent only by specified group members.
- Added support for returning the time when a member joined a group when fetching group member information.
- Added the `onMembersJoinedFromGroup` and `onMembersExitedFromGroup` callbacks. Marked `onMemberJoinedFromGroup` and `onMemberExitedFromGroup` deprecated.
- Added the `ChatGroupManager#updateGroupName` and `ChatGroupManager#updateGroupDesc` methods. Marked `ChatGroupManager#changeGroupName` and `ChatGroupManager#changeGroupDescription` deprecated.
- Added the `ChatMultiDevicesEvent.UnKnow` type to prevent parse failures when new multi-device events are added.
- Added the `ExtSettings.kDisableIosEnterBackground` option to control iOS background behavior and usage. 
- Added an exception when `updateMessage` is called for a message that does not exist.
- Added the `ChatRoomManager.isMemberInChatRoomMuteList` API to check whether the current user is in the chat room mute list.
- Added support for modifying various message types after sending through `ChatManager#modifyMessage`:
  - Text and custom messages: The message body and `attributes` can be modified.
  - File, video, audio, image, location, and combined forward messages: Only `attributes` can be modified.
  - Command messages: Modification is not supported.
- After a user joins a chat room, the success callback of `joinChatroom` now includes the following information:
  1. The current chat room member count, `ChatRoom#memberCount`.
  2. The chat room all-member mute status, `ChatRoom#isAllMemberMuted`.
  3. The chat room creation timestamp, `ChatRoom#createTimestamp`, which is a new property.
  4. Whether the current user is in the chat room allow list, `ChatRoom#isInWhitelist`, which is a new property. This property is updated when the member receives an allow list change callback.
  5. The timestamp when the current user's mute expires, `ChatRoom#muteExpireTimestamp`, which is a new property. This property is updated when the member receives a mute change callback.

#### Improvements

- Upgraded the dependent Android SDK to 4.16.1.
- Upgraded the dependent iOS SDK to 4.16.2.
- Updated the `AOSL` library to 1.3.0.
- Added support for setting an IPv6 REST address for private deployments.
- Optimized the reconnection logic and default reconnection address switching.
- Rewrote the SDK as a federated plugin.
- Changed the parameters of `ChatRoomEventHandler#onMuteListAddedFromChatRoom`.

#### Issues fixed

- Fixed an issue where chat thread sub-conversations were added to the `conversation` list.
- Fixed an issue where `EChatEventHandler#onMessageContentChanged` did not return modified content when modifying messages other than text and custom messages.
- Fixed an issue where a new local conversation was still created when pulling roaming messages with `FetchMessageOptions#needSave` set to `false`.
- Fixed an issue where members still fetched group or chat room details from the server after receiving the callback that a group or chat room was destroyed.
- Fixed an issue where updating group attributes affected the group avatar.
- Fixed an issue where the 220 error code returned during logout did not trigger the callback.
- Fixed a crash when `fetchReactionDetail` fetched a non-existent Reaction.
- Fixed an ANR issue on Android caused by frequent calls to APIs in `ChatConversation`.
- Fixed a crash in `updatePushNickname` when the user was not logged in or when invalid parameters were passed.
- Fixed a crash in `fetchChatroomInfoFromServer` after the `fetchMembers` parameter was removed.
- Fixed a crash in `modifyMessage` when an empty message body was passed.
- Fixed an issue where Android failed to parse the current user's group member attributes.
- Fixed an issue where `ChatRoomEventHandler#onRemovedFromChatRoom` was not executed.
- Fixed crashes caused by an empty `announcement` when receiving the `onAnnouncementChangedFromChatRoom` or `onAnnouncementChangedFromGroup` callback.
- Fixed an issue where the latest message in the conversation fetched by `ChatManager#fetchConversation` did not include Reaction and translation information.
- Fixed an issue where Android could not get `ChatConversation.marks`.
- Fixed inaccurate results from `ChatGroupManager.fetchMemberAttributes` on Android.
- Fixed crashes caused by empty announcement callbacks received from chat rooms or groups.
- Fixed the thumbnail status of image and video messages.


## v1.3.3

### New features

- Added the `ChatRoomManager.joinChatRoom(String, bool, String)` method;
- Added the `ChatRoomEventHandler.onMemberJoinedFromChatRoom(String, String, String)` callback;

### Issues fixed

- Fixed an issue where the return format of `GroupManager.fetchMemberAttributes` was incorrect on the Android platform.

## v1.3.2

### New features

- Added the `ChatGroupManager.isMemberInGroupMuteList` method to check whether the current user is in the group mute list.
- Added the `ChatRoomManager.isMemberInChatRoomMuteList` method to check whether the current user is in the chat room mute list.

### Issues fixed

- Build issue for Android platform on Flutter 3.29.0.

## v1.3.1+1

#### Improvements

- Pin message support 1v1 chat.
- Optimized the success rate of server connection under weak network conditions.

#### Issues fixed

- native: Fixed the issue where the second request to get the friend list (including friend remarks) from the server would not get data if there was no change in the friend list.
- native: Fixed the issue where the message would still be sent successfully when the attachment failed to send under special circumstances.
- native: Fixed the issue of incorrect nextkey when pulling roaming messages.
- native: Optimized the success rate of server connection under weak network conditions.
- native: Fixed the issue where the cache was not updated in time when blacklisting contacts.
- native: Fixed the issue where push notifications might not work after logging out and logging back in.

## v1.3.0

#### New features

- Added the `ChatManager#deleteAllMessageAndConversation` method to uni-directionally clear all conversations and messages in them. Meanwhile, you can choose whether to clear the chat history on the server.
- Added the function of searching for messages by search scope in `MessageSearchScope` during keyword-based search.
  - `MessageSearchScope`: Includes three message search scopes: the message content, message extension information, and both. 
  - `ChatManager#loadMessagesWithKeyword`: Searches for messages in all conversations by search scope.
  - `conversation#loadMessagesWithKeyword`: Searches for messages in a conversation by search scope.
- Added the function of marking a conversation: 
  - `ConversationFetchOptions`: Includes options for filtering conversations retrieved from the server. You can only retrieve pinned conversations or marked conversations by setting the options.
  - `ChatManager#addRemoteAndLocalConversationsMark`: Marks a conversation.
  - `ChatManager#deleteRemoteAndLocalConversationsMark`: Unmarks a conversation.
  - `ChatManager#fetchConversationsByOptions`: Gets conversations from the server by setting `ConversationFetchOptions`.
  - `Conversation#marks`: Gets all marks of a local conversation.
  - `ChatMultiDevicesEvent#CONVERSATION_UPDATE_MARK`: Conversation mark update event in a multi-device login scenario. If a user adds or removes a conversation mark on one device,  this event is received on other devices of the user.
- Added the `ChatMessage#isBroadcast` property to indicate whether the message is a broadcast message sent via a RESTful API to all chat rooms under an app.
- Added the `ChatMessage#deliverOnlineOnly` property to set whether the message is delivered only when the recipient(s) is/are online. If this property is set to `true`, the message is discarded when the recipient is offline.
- Added the `GroupManager#fetchJoinedGroupCount` method to allow the current user to retrieve the total number of joined groups.
- Added the error code 706 `CHATROOM_OWNER_NOT_ALLOW_LEAVE` that occurs when the chat room owner leaves the chat room. If `ChatOptions#isChatRoomOwnerLeaveAllowed` is set to `false` during SDK initialization, the chat room is not allowed to leave the chat room. In this case, error 706 is reported if the chat room owner calls the `leaveChatRoom` method to leave the chat room.
- Added the support for retrieval of historical messages of chat rooms from the server.
- Added the `ChatOptions#useReplacedMessageContents` property to determine whether the server returns the adjusted text message to the sender if the message content is replaced during text moderation.
- Added the function of pinning a message:
  - `ChatManager#pinMessage`: Pins a message.   
  - `ChatManager#unpinMessage`: Unpins a message.  
  - `ChatManager#fetchPinnedMessages`: Gets the list of pinned messages in a conversation from the server. 
  - `Conversation#loadPinnedMessages`: Gets the list of pinned messages in a local conversation.
  - `MessagePinInfo`: Includes the operator that pins or unpins the message and the operation time.
  - `ChatMessage#pinInfo`: Includes the message pinning information.
  - `ChatEventHandler#onMessagePinChanged`: Occurs when the message pinning status changed. When a message is pinned or unpinned in a group or chat room, all members in the group or chat room receive this event. 
- Added the `ChatOptions#enableEmptyConversation` property to set whether to include empty conversations in the retrieved list of local conversations. This property is set during SDK initialization.
- Added the `applicant` and `decliner` parameters to the `ChatGroupEventHandler#onRequestToJoinDeclinedFromGroup` event to respectively indicate the user that applies to join the group and the user that declines the join request. 
- Added the `ChatOptions#messagesReceiveCallbackIncludeSend` property to set whether to return the successfully sent message in the `ChatEventHandler#onMessagesReceived` event.
- Added the support for returning the modified custom message via the `ChatEventHandler#onMessageContentChanged` event if the message is modified via the RESTful API. 

#### Improvements

- Marked `ChatManager#fetchConversation` and `ChatManager#fetchPinnedConversations` deprecated. Use `ChatManager#fetchConversationsByOptions` instead.
- Supported the forwarding of single attachment messages by passing in the message body and extension fields, without reuploading the attachment.  
- Reduced the number of times group specifications are retrieved when a large number of group member events are received during certain scenarios. 
- Delivered a more accurate chat room member count by optimizing the way to update the member count when members join or leave the chat room.
- Shortened the time used to call the `ChatManager#markAllConversationsAsRead` method by marking all conversations read more efficiently.
- Optimized the way the SDK randomly gets server addresses to increase the success rate of requests.
- Adjusted the timeout period for joining or leaving chat rooms.
- Optimized the way the connection is re-established upon a connection failure in certain scenarios.
- Supported for uploading the attachment by fragment when sending an attachment message.
- Marked the `ChatClient#loginWithAgoraToken` method deprecated. Use the `ChatClient#loginWithToken` method instead.
- Fine tuned the error message for token-based login for the sake of accuracy.
- Optimized the way messages are resent.
- Removed the internal `NetworkOnMainThreadException` exception catching during a network request.
- Optimized the database upgrade logic.
- Increased the maximum allowed size of a log file from 2 MB to 5 MB.
- Added the iOS privacy protocol `PrivacyInfo.xcprivacy`.
- Updates minimum supported SDK version to Flutter 3.3.0/Dart 3.3.0 .

#### Issues fixed

- For a modified message, the `from` property is missing from the body of the message pulled from the server by an offline user that gets online. 
- In special scenarios, chat room events are missing when users exit the SDK before login to it.
- The SDK reconnects to the server twice after the network is back to normal.
- An incorrect error message is returned for an unlogged-in user that calls the `leaveChatRoom` method.
- The members in a group are double counted in certain scenarios.
- The data reporting module crashes occasionally.
- The SDK is instantiated repeatedly when the `ChatManager#updateMessage` method is called frequently for SDK initialization in multi-thread scenarios.



## v1.2.0(Dec 5, 2023)

#### New features

- Adds the function of sending a combined message:
  - `MessageType.COMBINE`: The combined message type.
  - `CombineMessageBody`: The combined message body class.
  - `ChatManager#fetchCombineMessageDetail`: Gets the list of original messages included in a combined message from the server.
- Adds the function of modifying a text message that is sent:
  - `ChatManager#modifyMessage`: Modifies a text message that is sent.
  - `ChatEventHandler#onMessageContentChanged`: Occurs when a sent message is modified. The message recipient receives this callback.
  - `ChatTextMessageBody#lastModifyTime`: Indicates when the content of a sent message is modified last time.
  - `ChatTextMessageBody#lastModifyOperatorId`: Indicates the user ID of user that modifies a sent message last time.
  - `ChatTextMessageBody#modifyCount`: Indicates the number of times a sent message is modified.
- Adds the function of pinning a conversation:
  - `ChatManager#pinConversation`: Pins or unpins a conversation.
  - `ChatManager#fetchPinnedConversations`: Gets the list of pinned conversations from the server.
  - `ChatConversation#isPinned`: Specifies whether the conversation is pinned.
  - `ChatConversation#pinnedTime`: Specifies when the conversation is pinned.
- Adds the `fetchConversation` method to get the conversation list from the server. Marks the `ChatManager#getConversationsFromServer` method deprecated.
- Adds `FetchMessageOptions` as the parameter configuration class for pulling historical messages from the server.
- Adds the `ChatManager#fetchHistoryMessagesByOption` method to get historical messages of a conversation from the server according to `FetchMessageOptions`, the parameter configuration class for pulling historical messages.
- Adds the `direction` parameter to `ChatManager#fetchHistoryMessages` to allow you to retrieve historical messages from the server according to the message search direction.
- Adds the `ChatConversation#deleteMessagesWithTs` method to delete messages sent or received in a certain period from the local database.
- Adds the `ChatMessage#deliverOnlineOnly` field to specify whether the message is delivered only when the recipient(s) is/are online.
- Adds the function of managing custom attributes of group members:
  - `ChatGroupManager#setMemberAttributes`: Sets custom attributes of a group member.
  - `ChatGroupManager#fetchMemberAttributes` and `GroupManager#fetchMembersAttributes`: Gets custom attributes of group members.
  - `ChatGroupEventHandler#onAttributesChangedOfGroupMember`: Occurs when a custom attribute is changed for a group member.
- Adds the `reason` parameter to `ChatRoomEventHandler#onRemovedFromChatRoom` so that the member removed from the chat room knows the removal reason.
- Adds the `ConnectionEventHandler#onAppActiveNumberReachLimit` callback that occurs when the number of daily active users (DAU) or monthly active users (MAU) for the app has reached the upper limit.
- Adds the `IMultiDeviceDelegate#OnRoamDeleteMultiDevicesEvent` callback that occurs when historical messages in a conversation are deleted from the server on one device. This event is received by other devices.
- Adds the support for user tokens in the following methods:
  - `ChatClient#fetchLoggedInDevices`: Gets the list of online login devices of a user.
  - `ChatClient#kickDevice`: Kicks a user out of the app on a device.
  - `ChatClient#kickAllDevices`: Kicks a user out of the app on all devices.
- Adds the `ChatMultiDeviceEventHandler#onRemoteMessagesRemoved` callback that occurs when historical messages in a conversation are deleted from the server on one device. This event is received by other devices.
- Adds the Reaction operation class `ReactionOperate`:
  - `Add`: Adds a Reaction.
  - `Remove`: Removes a Reaction.
- Adds the `ChatRoomEventHandler#onSpecificationChanged` callback that occurs when details of a chat room are changed.

### Improvements

- Optimized the `ChatManager#searchMsgFromDB` method to include custom messages in the message retrieval result.
- Adapted to the Android 14 system.


#### Issues fixed

- `ConnectionEventHandler#onConnected` and `ConnectionEventHandler#onDisconnected` cannot be received on the iOS system.
- Message extension attributes of the string type in the Android system turn into the Int type.
- Upon a hot reload on Android, the callback is triggered repeatedly.
- When you retrieve custom chat room attributes, passing `null` to the key of an attribute causes the app to crash.
- Chat room events cannot be received by a user that logs in to the Agora Chat server again after logout on the Android platform.
- `ChatManager#getThreadConversation` error.
- The `ChatMessage#chatThread` error.
- The `ChatRoomEventHandler#onSpecificationChanged` is not triggered when the chat room announcement changes.
- The Android platform crashes when a user is removed from a thread.
- An error occurs when `ChatThreadManager#fetchChatThreadMembers` is called.



## v1.1.1(June 16, 2023)

#### Issues fixed

- Fix: Callback methods executing multiple times due to multiple initialization of android.


## v1.1.0+1(April 4, 2023)

#### Issues fixed

- Fixed Android sending video message url error.

## v1.1.0(February 28, 2023)

#### New features

- Upgrades the native platforms `iOS` and `Android` that the Flutter platform depends on to v1.1.0.
- Adds the function of managing custom chat room attributes to implement functions like seat control and synchronization in voice chatrooms.
- Adds the `ChatManager#fetchConversationListFromServer` method to allow users to get the conversation list from the server with pagination.
- Adds the `ChatMessage#chatroomMessagePriority` attribute to implement the chat room message priority function to ensure that high-priority messages are dealt with first.

#### Improvements

Changed the message sending result callback from `ChatMessage#setMessageStatusCallBack` to `ChatManager#addMessageEvent`.

#### Issues fixed

`ChatManager#deleteMessagesBeforeTimestamp` execution failures.

## v1.0.9(December 19, 2022)


#### Issues fixed

- Some alerts on Android 12.
- The inconsistency of messages in the memory and the database due to a call to the `updateMessage` method in rare scenarios.
- The `ChatGroupEventHandler#onDestroyedFromGroup` callback that occurs when a group is destroyed does not work on the Android platform.
- The `ChatGroupEventHandler#onAutoAcceptInvitationFromGroup` callback that occurs when a user's group invitation is accepted automatically does not work on the Android platform.
- Crashes in rare scenarios.

## v1.0.8(November 22, 2022)

#### Improvements

Removed some redundant logs of the SDK.

#### Issues fixed

- Failures in getting a large number of messages from the server in few scenarios.
- The issue of incorrect data statistics.
- Crashes caused by log printing in rare scenarios.

## v1.0.7(September 7, 2022)


#### New features

- Adds the `customEventHandler` attribute in `ChatClient` to allow you to set custom listeners to receive the data sent from the Android or iOS device to the Flutter. 
- Adds event listener classes for event listening.
- Adds the `PushTemplate` method in `PushManager to support custom push templates. 
- Adds the `isDisabled` attribute in `Group` to to indicate whether a group is disabled. This attribute needs to be set by developers at the server side. This attribute is returned when you call the `fetchGroupInfoFromServer` method to get group details.
- Adds the the `displayName` attribute in `PushConfigs` to allow you to check the nickname displayed in your push notifications.

#### Improvements

- Marked `AddXXXManagerListener` methods (like `addChatManagerListener`  and `addContactManagerListener`) as deprecated.

- Modified API references.

## v1.0.6(July 21, 2022)

#### Issues fixed

- The callbacks for messaging thread were not triggered on iOS.
- The callbacks for reaction were not triggered in iOS.
- Occasional crashes occurred on Android when retrieving conversations from the server.

## v1.0.5(June 17, 2022)

This is the first release for the Agora Chat Flutter SDK, which enables you to add real-time chatting functionalities to an Android or iOS app. Major features include the following:

- Sending and receiving messages in one-to-one chats, chat groups, and chat rooms.
- Retrieving and managing conversations and messages.
- Managing chat groups and chat rooms.
- Managing contact and block lists.

For the complete feature list, see [Product Overview](./agora_chat_overview?platform=Flutter).

Agora Chat is charged on a MAU (Monthly Active Users) basis. For details, see [Pricing for Agora Chat](./agora_chat_pricing?platform=Flutter) and [Pricing Plan Details](./agora_chat_plan?platform=Flutter).

Refer to the following documentations to enable Agora Chat and use the Chat SDK to implement real-time chatting functionalities in your app:

- [Enable and Configure Agora Chat](./enable_agora_chat)
- [Get Started with Agora Chat](./agora_chat_get_started_flutter)
- [Messages](./agora_chat_message_overview?platform=Flutter)
- [Chat Group](./agora_chat_group_overview?platform=Flutter)
- [Chat Room](./agora_chat_chatroom_overview?platform=Flutter)
- [API Reference](./api-ref?platform=Flutter)
