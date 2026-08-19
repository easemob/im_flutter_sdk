// 兼容层: 旧 EM* 命名 -> 新 Chat* 命名(与海外版 agora_chat_sdk 对齐)。
// 新代码请直接使用新名字; 旧名字标记为 Deprecated, 将在未来大版本移除。
//
// 以下名字无法通过 typedef 兼容, 已直接改名(不兼容点):
//   convertIntToEMMultiDevicesEvent -> convertIntToChatMultiDevicesEvent (function)
//   EMGroupPermissionTypeExtension -> ChatGroupPermissionTypeExtension (extension)
//   EMLog -> ChatLog (class)
//   EMTools -> ChatTools (class)
import 'im_flutter_sdk.dart';

@Deprecated('请改用 ChatEventHandler(Use ChatEventHandler instead)。')
typedef EMChatEventHandler = ChatEventHandler;

@Deprecated('请改用 ChatManager(Use ChatManager instead)。')
typedef EMChatManager = ChatManager;

@Deprecated('请改用 ChatRoom(Use ChatRoom instead)。')
typedef EMChatRoom = ChatRoom;

@Deprecated('请改用 ChatRoomEvent(Use ChatRoomEvent instead)。')
typedef EMChatRoomEvent = ChatRoomEvent;

@Deprecated('请改用 ChatRoomEventHandler(Use ChatRoomEventHandler instead)。')
typedef EMChatRoomEventHandler = ChatRoomEventHandler;

@Deprecated('请改用 ChatRoomManager(Use ChatRoomManager instead)。')
typedef EMChatRoomManager = ChatRoomManager;

@Deprecated('请改用 ChatRoomPermissionType(Use ChatRoomPermissionType instead)。')
typedef EMChatRoomPermissionType = ChatRoomPermissionType;

@Deprecated('请改用 ChatThread(Use ChatThread instead)。')
typedef EMChatThread = ChatThread;

@Deprecated('请改用 ChatThreadEvent(Use ChatThreadEvent instead)。')
typedef EMChatThreadEvent = ChatThreadEvent;

@Deprecated('请改用 ChatThreadEventHandler(Use ChatThreadEventHandler instead)。')
typedef EMChatThreadEventHandler = ChatThreadEventHandler;

@Deprecated('请改用 ChatThreadManager(Use ChatThreadManager instead)。')
typedef EMChatThreadManager = ChatThreadManager;

@Deprecated('请改用 ChatThreadOperation(Use ChatThreadOperation instead)。')
typedef EMChatThreadOperation = ChatThreadOperation;

@Deprecated('请改用 ChatClient(Use ChatClient instead)。')
typedef EMClient = ChatClient;

@Deprecated('请改用 ChatCmdMessageBody(Use ChatCmdMessageBody instead)。')
typedef EMCmdMessageBody = ChatCmdMessageBody;

@Deprecated('请改用 CombineMessageBody(Use CombineMessageBody instead)。')
typedef EMCombineMessageBody = CombineMessageBody;

@Deprecated('请改用 ConnectionEventHandler(Use ConnectionEventHandler instead)。')
typedef EMConnectionEventHandler = ConnectionEventHandler;

@Deprecated('请改用 ChatContact(Use ChatContact instead)。')
typedef EMContact = ChatContact;

@Deprecated('请改用 ChatContactChangeEvent(Use ChatContactChangeEvent instead)。')
typedef EMContactChangeEvent = ChatContactChangeEvent;

@Deprecated('请改用 ChatContactEventHandler(Use ChatContactEventHandler instead)。')
typedef EMContactEventHandler = ChatContactEventHandler;

@Deprecated('请改用 ChatContactManager(Use ChatContactManager instead)。')
typedef EMContactManager = ChatContactManager;

@Deprecated('请改用 ChatConversation(Use ChatConversation instead)。')
typedef EMConversation = ChatConversation;

@Deprecated('请改用 ChatConversationType(Use ChatConversationType instead)。')
typedef EMConversationType = ChatConversationType;

@Deprecated('请改用 ChatCursorResult(Use ChatCursorResult instead)。')
typedef EMCursorResult<T> = ChatCursorResult<T>;

@Deprecated('请改用 ChatCustomMessageBody(Use ChatCustomMessageBody instead)。')
typedef EMCustomMessageBody = ChatCustomMessageBody;

@Deprecated('请改用 ChatDeviceInfo(Use ChatDeviceInfo instead)。')
typedef EMDeviceInfo = ChatDeviceInfo;

@Deprecated('请改用 ChatDownloadCallback(Use ChatDownloadCallback instead)。')
typedef EMDownloadCallback = ChatDownloadCallback;

@Deprecated('请改用 ChatError(Use ChatError instead)。')
typedef EMError = ChatError;

@Deprecated('请改用 ChatFileMessageBody(Use ChatFileMessageBody instead)。')
typedef EMFileMessageBody = ChatFileMessageBody;

@Deprecated('请改用 ChatGroup(Use ChatGroup instead)。')
typedef EMGroup = ChatGroup;

@Deprecated('请改用 ChatGroupChangeEvent(Use ChatGroupChangeEvent instead)。')
typedef EMGroupChangeEvent = ChatGroupChangeEvent;

@Deprecated('请改用 ChatGroupEventHandler(Use ChatGroupEventHandler instead)。')
typedef EMGroupEventHandler = ChatGroupEventHandler;

@Deprecated('请改用 ChatGroupInfo(Use ChatGroupInfo instead)。')
typedef EMGroupInfo = ChatGroupInfo;

@Deprecated('请改用 ChatGroupManager(Use ChatGroupManager instead)。')
typedef EMGroupManager = ChatGroupManager;

@Deprecated('请改用 ChatGroupMessageAck(Use ChatGroupMessageAck instead)。')
typedef EMGroupMessageAck = ChatGroupMessageAck;

@Deprecated('请改用 ChatGroupOptions(Use ChatGroupOptions instead)。')
typedef EMGroupOptions = ChatGroupOptions;

@Deprecated('请改用 ChatGroupPermissionType(Use ChatGroupPermissionType instead)。')
typedef EMGroupPermissionType = ChatGroupPermissionType;

@Deprecated('请改用 ChatGroupSharedFile(Use ChatGroupSharedFile instead)。')
typedef EMGroupSharedFile = ChatGroupSharedFile;

@Deprecated('请改用 ChatGroupStyle(Use ChatGroupStyle instead)。')
typedef EMGroupStyle = ChatGroupStyle;

@Deprecated('请改用 ChatImageMessageBody(Use ChatImageMessageBody instead)。')
typedef EMImageMessageBody = ChatImageMessageBody;

@Deprecated('请改用 ChatLocationMessageBody(Use ChatLocationMessageBody instead)。')
typedef EMLocationMessageBody = ChatLocationMessageBody;

@Deprecated('请改用 ChatMessage(Use ChatMessage instead)。')
typedef EMMessage = ChatMessage;

@Deprecated('请改用 ChatMessageBody(Use ChatMessageBody instead)。')
typedef EMMessageBody = ChatMessageBody;

@Deprecated('请改用 ChatMessageReaction(Use ChatMessageReaction instead)。')
typedef EMMessageReaction = ChatMessageReaction;

@Deprecated(
    '请改用 ChatMessageReactionEvent(Use ChatMessageReactionEvent instead)。')
typedef EMMessageReactionEvent = ChatMessageReactionEvent;

@Deprecated('请改用 ChatMessageSenderInfo(Use ChatMessageSenderInfo instead)。')
typedef EMMessageSenderInfo = ChatMessageSenderInfo;

@Deprecated(
    '请改用 ChatMultiDeviceEventHandler(Use ChatMultiDeviceEventHandler instead)。')
typedef EMMultiDeviceEventHandler = ChatMultiDeviceEventHandler;

@Deprecated('请改用 ChatMultiDevicesEvent(Use ChatMultiDevicesEvent instead)。')
typedef EMMultiDevicesEvent = ChatMultiDevicesEvent;

@Deprecated('请改用 ChatOptions(Use ChatOptions instead)。')
typedef EMOptions = ChatOptions;

@Deprecated('请改用 ChatPageResult(Use ChatPageResult instead)。')
typedef EMPageResult<T> = ChatPageResult<T>;

@Deprecated('请改用 ChatPresence(Use ChatPresence instead)。')
typedef EMPresence = ChatPresence;

@Deprecated(
    '请改用 ChatPresenceEventHandler(Use ChatPresenceEventHandler instead)。')
typedef EMPresenceEventHandler = ChatPresenceEventHandler;

@Deprecated('请改用 ChatPresenceManager(Use ChatPresenceManager instead)。')
typedef EMPresenceManager = ChatPresenceManager;

@Deprecated(
    '请改用 ChatPresenceStatusDetail(Use ChatPresenceStatusDetail instead)。')
typedef EMPresenceStatusDetail = ChatPresenceStatusDetail;

@Deprecated('请改用 ChatPushConfig(Use ChatPushConfig instead)。')
typedef EMPushConfig = ChatPushConfig;

@Deprecated('请改用 ChatPushConfigs(Use ChatPushConfigs instead)。')
typedef EMPushConfigs = ChatPushConfigs;

@Deprecated('请改用 ChatPushManager(Use ChatPushManager instead)。')
typedef EMPushManager = ChatPushManager;

@Deprecated('请改用 ChatSearchDirection(Use ChatSearchDirection instead)。')
typedef EMSearchDirection = ChatSearchDirection;

@Deprecated('请改用 ChatStreamChunk(Use ChatStreamChunk instead)。')
typedef EMStreamChunk = ChatStreamChunk;

@Deprecated('请改用 ChatStreamStatus(Use ChatStreamStatus instead)。')
typedef EMStreamStatus = ChatStreamStatus;

@Deprecated('请改用 ChatTextMessageBody(Use ChatTextMessageBody instead)。')
typedef EMTextMessageBody = ChatTextMessageBody;

@Deprecated('请改用 ChatTranslateLanguage(Use ChatTranslateLanguage instead)。')
typedef EMTranslateLanguage = ChatTranslateLanguage;

@Deprecated('请改用 ChatUserInfo(Use ChatUserInfo instead)。')
typedef EMUserInfo = ChatUserInfo;

@Deprecated('请改用 ChatUserInfoChangeEvent(Use ChatUserInfoChangeEvent instead)。')
typedef EMUserInfoChangeEvent = ChatUserInfoChangeEvent;

@Deprecated(
    '请改用 ChatUserInfoEventHandler(Use ChatUserInfoEventHandler instead)。')
typedef EMUserInfoEventHandler = ChatUserInfoEventHandler;

@Deprecated('请改用 ChatUserInfoManager(Use ChatUserInfoManager instead)。')
typedef EMUserInfoManager = ChatUserInfoManager;

@Deprecated('请改用 ChatVideoMessageBody(Use ChatVideoMessageBody instead)。')
typedef EMVideoMessageBody = ChatVideoMessageBody;

@Deprecated('请改用 ChatVoiceFormat(Use ChatVoiceFormat instead)。')
typedef EMVoiceFormat = ChatVoiceFormat;

@Deprecated('请改用 ChatVoiceMessageBody(Use ChatVoiceMessageBody instead)。')
typedef EMVoiceMessageBody = ChatVoiceMessageBody;

@Deprecated('请改用 ChatVoiceParam(Use ChatVoiceParam instead)。')
typedef EMVoiceParam = ChatVoiceParam;
