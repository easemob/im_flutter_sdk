// Compatibility layer: old EM* names -> new Chat* names (aligned with agora_chat_sdk).
// Use the new names in new code; old names are @Deprecated and will be removed in a future major version.
//
// The following names cannot be aliased via typedef and have been renamed (breaking changes):
//   convertIntToEMMultiDevicesEvent -> convertIntToChatMultiDevicesEvent (function)
//   EMGroupPermissionTypeExtension -> ChatGroupPermissionTypeExtension (extension)
//   EMLog -> ChatLog (class)
//   EMTools -> ChatTools (class)
import 'im_flutter_sdk.dart';

@Deprecated('Use [ChatEventHandler] instead')
typedef EMChatEventHandler = ChatEventHandler;

@Deprecated('Use [ChatManager] instead')
typedef EMChatManager = ChatManager;

@Deprecated('Use [ChatRoom] instead')
typedef EMChatRoom = ChatRoom;

@Deprecated('Use [ChatRoomEvent] instead')
typedef EMChatRoomEvent = ChatRoomEvent;

@Deprecated('Use [ChatRoomEventHandler] instead')
typedef EMChatRoomEventHandler = ChatRoomEventHandler;

@Deprecated('Use [ChatRoomManager] instead')
typedef EMChatRoomManager = ChatRoomManager;

@Deprecated('Use [ChatRoomPermissionType] instead')
typedef EMChatRoomPermissionType = ChatRoomPermissionType;

@Deprecated('Use [ChatThread] instead')
typedef EMChatThread = ChatThread;

@Deprecated('Use [ChatThreadEvent] instead')
typedef EMChatThreadEvent = ChatThreadEvent;

@Deprecated('Use [ChatThreadEventHandler] instead')
typedef EMChatThreadEventHandler = ChatThreadEventHandler;

@Deprecated('Use [ChatThreadManager] instead')
typedef EMChatThreadManager = ChatThreadManager;

@Deprecated('Use [ChatThreadOperation] instead')
typedef EMChatThreadOperation = ChatThreadOperation;

@Deprecated('Use [ChatClient] instead')
typedef EMClient = ChatClient;

@Deprecated('Use [ChatCmdMessageBody] instead')
typedef EMCmdMessageBody = ChatCmdMessageBody;

@Deprecated('Use [CombineMessageBody] instead')
typedef EMCombineMessageBody = CombineMessageBody;

@Deprecated('Use [ConnectionEventHandler] instead')
typedef EMConnectionEventHandler = ConnectionEventHandler;

@Deprecated('Use [ChatContact] instead')
typedef EMContact = ChatContact;

@Deprecated('Use [ChatContactChangeEvent] instead')
typedef EMContactChangeEvent = ChatContactChangeEvent;

@Deprecated('Use [ChatContactEventHandler] instead')
typedef EMContactEventHandler = ChatContactEventHandler;

@Deprecated('Use [ChatContactManager] instead')
typedef EMContactManager = ChatContactManager;

@Deprecated('Use [ChatConversation] instead')
typedef EMConversation = ChatConversation;

@Deprecated('Use [ChatConversationType] instead')
typedef EMConversationType = ChatConversationType;

@Deprecated('Use [ChatCursorResult] instead')
typedef EMCursorResult<T> = ChatCursorResult<T>;

@Deprecated('Use [ChatCustomMessageBody] instead')
typedef EMCustomMessageBody = ChatCustomMessageBody;

@Deprecated('Use [ChatDeviceInfo] instead')
typedef EMDeviceInfo = ChatDeviceInfo;

@Deprecated('Use [ChatDownloadCallback] instead')
typedef EMDownloadCallback = ChatDownloadCallback;

@Deprecated('Use [ChatError] instead')
typedef EMError = ChatError;

@Deprecated('Use [ChatFileMessageBody] instead')
typedef EMFileMessageBody = ChatFileMessageBody;

@Deprecated('Use [ChatGroup] instead')
typedef EMGroup = ChatGroup;

@Deprecated('Use [ChatGroupChangeEvent] instead')
typedef EMGroupChangeEvent = ChatGroupChangeEvent;

@Deprecated('Use [ChatGroupEventHandler] instead')
typedef EMGroupEventHandler = ChatGroupEventHandler;

@Deprecated('Use [ChatGroupInfo] instead')
typedef EMGroupInfo = ChatGroupInfo;

@Deprecated('Use [ChatGroupManager] instead')
typedef EMGroupManager = ChatGroupManager;

@Deprecated('Use [ChatGroupMessageAck] instead')
typedef EMGroupMessageAck = ChatGroupMessageAck;

@Deprecated('Use [ChatGroupOptions] instead')
typedef EMGroupOptions = ChatGroupOptions;

@Deprecated('Use [ChatGroupPermissionType] instead')
typedef EMGroupPermissionType = ChatGroupPermissionType;

@Deprecated('Use [ChatGroupSharedFile] instead')
typedef EMGroupSharedFile = ChatGroupSharedFile;

@Deprecated('Use [ChatGroupStyle] instead')
typedef EMGroupStyle = ChatGroupStyle;

@Deprecated('Use [ChatImageMessageBody] instead')
typedef EMImageMessageBody = ChatImageMessageBody;

@Deprecated('Use [ChatLocationMessageBody] instead')
typedef EMLocationMessageBody = ChatLocationMessageBody;

@Deprecated('Use [ChatMessage] instead')
typedef EMMessage = ChatMessage;

@Deprecated('Use [ChatMessageBody] instead')
typedef EMMessageBody = ChatMessageBody;

@Deprecated('Use [ChatMessageReaction] instead')
typedef EMMessageReaction = ChatMessageReaction;

@Deprecated('Use [ChatMessageReactionEvent] instead')
typedef EMMessageReactionEvent = ChatMessageReactionEvent;

@Deprecated('Use [ChatMessageSenderInfo] instead')
typedef EMMessageSenderInfo = ChatMessageSenderInfo;

@Deprecated('Use [ChatMultiDeviceEventHandler] instead')
typedef EMMultiDeviceEventHandler = ChatMultiDeviceEventHandler;

@Deprecated('Use [ChatMultiDevicesEvent] instead')
typedef EMMultiDevicesEvent = ChatMultiDevicesEvent;

@Deprecated('Use [ChatOptions] instead')
typedef EMOptions = ChatOptions;

@Deprecated('Use [ChatPageResult] instead')
typedef EMPageResult<T> = ChatPageResult<T>;

@Deprecated('Use [ChatPresence] instead')
typedef EMPresence = ChatPresence;

@Deprecated('Use [ChatPresenceEventHandler] instead')
typedef EMPresenceEventHandler = ChatPresenceEventHandler;

@Deprecated('Use [ChatPresenceManager] instead')
typedef EMPresenceManager = ChatPresenceManager;

@Deprecated('Use [ChatPresenceStatusDetail] instead')
typedef EMPresenceStatusDetail = ChatPresenceStatusDetail;

@Deprecated('Use [ChatPushConfig] instead')
typedef EMPushConfig = ChatPushConfig;

@Deprecated('Use [ChatPushConfigs] instead')
typedef EMPushConfigs = ChatPushConfigs;

@Deprecated('Use [ChatPushManager] instead')
typedef EMPushManager = ChatPushManager;

@Deprecated('Use [ChatSearchDirection] instead')
typedef EMSearchDirection = ChatSearchDirection;

@Deprecated('Use [ChatStreamChunk] instead')
typedef EMStreamChunk = ChatStreamChunk;

@Deprecated('Use [ChatStreamStatus] instead')
typedef EMStreamStatus = ChatStreamStatus;

@Deprecated('Use [ChatTextMessageBody] instead')
typedef EMTextMessageBody = ChatTextMessageBody;

@Deprecated('Use [ChatTranslateLanguage] instead')
typedef EMTranslateLanguage = ChatTranslateLanguage;

@Deprecated('Use [ChatUserInfo] instead')
typedef EMUserInfo = ChatUserInfo;

@Deprecated('Use [ChatUserInfoChangeEvent] instead')
typedef EMUserInfoChangeEvent = ChatUserInfoChangeEvent;

@Deprecated('Use [ChatUserInfoEventHandler] instead')
typedef EMUserInfoEventHandler = ChatUserInfoEventHandler;

@Deprecated('Use [ChatUserInfoManager] instead')
typedef EMUserInfoManager = ChatUserInfoManager;

@Deprecated('Use [ChatVideoMessageBody] instead')
typedef EMVideoMessageBody = ChatVideoMessageBody;

@Deprecated('Use [ChatVoiceFormat] instead')
typedef EMVoiceFormat = ChatVoiceFormat;

@Deprecated('Use [ChatVoiceMessageBody] instead')
typedef EMVoiceMessageBody = ChatVoiceMessageBody;

@Deprecated('Use [ChatVoiceParam] instead')
typedef EMVoiceParam = ChatVoiceParam;
