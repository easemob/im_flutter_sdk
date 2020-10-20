class EMSDKMethod {
  /// EMClient methods
  static const String init = 'init';
  static const String createAccount = 'createAccount';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String changeAppKey = 'changeAppKey';
  static const String isLoggedInBefore = 'isLoggedInBefore';
  static const String setNickname = 'setNickname';
  static const String uploadLog = 'uploadLog';
  static const String compressLogs = 'compressLogs';
  static const String kickDevice = 'kickDevice';
  static const String kickAllDevices = 'kickAllDevices';
  static const String currentUser =  'currentUser';
  static const String getLoggedInDevicesFromServer = 'getLoggedInDevicesFromServer';

  /// EMClient listener
  static const String onMultiDeviceEvent = 'onMultiDeviceEvent';
  static const String onConnected = 'onConnected';
  static const String onDisconnected = 'onDisconnected';

  /// EMContactManager methods
  static const String addContact = 'addContact';
  static const String deleteContact = 'deleteContact';
  static const String getAllContactsFromServer = 'getAllContactsFromServer';
  static const String addUserToBlackList = 'addUserToBlackList';
  static const String removeUserFromBlackList = 'removeUserFromBlackList';
  static const String getBlackListFromServer = 'getBlackListFromServer';
  static const String acceptInvitation = 'acceptInvitation';
  static const String declineInvitation = 'declineInvitation';
  static const String getSelfIdsOnOtherPlatform = 'getSelfIdsOnOtherPlatform';

  /// EMContactManager listener
  static const String onContactChanged = 'onContactChanged';

  /// EMChatManager methods
  static const String sendMessage = 'sendMessage';
  static const String ackMessageRead = 'ackMessageRead';
  static const String recallMessage = 'recallMessage';
  static const String getConversation = 'getConversation';
  static const String markAllChatMsgAsRead = 'markAllChatMsgAsRead';
  static const String getUnreadMessageCount = 'getUnreadMessageCount';
  static const String updateChatMessage = 'updateChatMessage';
  static const String downloadAttachment = 'downloadAttachment';
  static const String downloadThumbnail = 'downloadThumbnail';
  static const String importMessages = 'importMessages';
  static const String loadAllConversations = 'loadAllConversations';
  static const String deleteConversation = 'deleteConversation';
//  static const String setVoiceMessageListened = 'setVoiceMessageListened';
//  static const String updateParticipant = 'updateParticipant';
  static const String fetchHistoryMessages = 'fetchHistoryMessages';
  static const String searchChatMsgFromDB = 'searchChatMsgFromDB';
  static const String getMessage = 'getMessage';

  // 需确认安卓用法，是否可以去掉？
  static const String getCursor = 'getCursor';


  /// EMChatManager listener
  static const String onMessagesReceived = 'onMessagesReceived';
  static const String onCmdMessagesReceived = 'onCmdMessagesReceived';
  static const String onMessagesRead = 'onMessagesRead';
  static const String onMessagesDelivered = 'onMessagesDelivered';
  static const String onMessagesRecalled = 'onMessagesRecalled';
  static const String onMessageChanged = 'onMessageChanged';

  static const String onConversationUpdate = 'onConversationUpdate';

  /// EMMessage listener
  static const String onMessageProgressUpdate = 'onMessageProgressUpdate';
  static const String onMessageError = 'onMessageError';
  static const String onMessageSuccess = 'onMessageSuccess';
  static const String onMessageReadAck = 'onMessageReadAck';
  static const String onMessageDeliveryAck = 'onMessageDeliveryAck';
  static const String onMessageStatusChanged = 'onMessageStatusChanged';

  /// EMConversation
  static const String getUnreadMsgCount = 'getUnreadMsgCount';
  static const String markAllMessagesAsRead = 'markAllMessagesAsRead';
  static const String markMessageAsRead = 'markMessageAsRead';
  static const String removeMessage = 'removeMessage';
  static const String getLatestMessage = 'getLatestMessage';
  static const String getLatestMessageFromOthers = 'getLatestMessageFromOthers';
  static const String clearAllMessages = 'clearAllMessages';
  static const String insertMessage = 'insertMessage';
  static const String appendMessage = 'appendMessage';
  static const String updateConversationMessage = 'updateConversationMessage';

  // 根据消息id获取消息
  static const String loadMsgWithId = 'loadMsgWithId';
  // 根据起始消息id获取消息
  static const String loadMsgWithStartId = 'loadMsgWithStartId';
  // 根据关键字获取消息
  static const String loadMsgWithKeywords = 'loadMsgWithKeywords';
  // 根据消息类型获取消息
  static const String loadMsgWithMsgType = 'loadMsgWithMsgType';
  // 通过时间获取消息
  static const String loadMsgWithTime = 'loadMsgWithTime';

  ///EMChatRoomManager methods
  static final String joinChatRoom = 'joinChatRoom';
  static final String leaveChatRoom = 'leaveChatRoom';
  static final String fetchPublicChatRoomsFromServer = 'fetchPublicChatRoomsFromServer';
  static final String fetchChatRoomInfoFromServer = 'fetchChatRoomInfoFromServer';
  static final String getChatRoom = 'getChatRoom';
  static final String getAllChatRooms = 'getAllChatRooms';
  static final String createChatRoom = 'createChatRoom';
  static final String destroyChatRoom = 'destroyChatRoom';
  static final String changeChatRoomSubject = 'changeChatRoomSubject';
  static final String changeChatRoomDescription = 'changeChatRoomDescription';
  static final String fetchChatRoomMembers = 'fetchChatRoomMembers';
  static final String muteChatRoomMembers = 'muteChatRoomMembers';
  static final String unMuteChatRoomMembers = 'unMuteChatRoomMembers';
  static final String changeChatRoomOwner = 'changeChatRoomOwner';
  static final String addChatRoomAdmin = 'addChatRoomAdmin';
  static final String removeChatRoomAdmin = 'removeChatRoomAdmin';
  static final String fetchChatRoomMuteList = 'fetchChatRoomMuteList';
  static final String removeChatRoomMembers = 'removeChatRoomMembers';
  static final String blockChatRoomMembers = 'blockChatRoomMembers';
  static final String unBlockChatRoomMembers = 'unBlockChatRoomMembers';
  static final String fetchChatRoomBlackList = 'fetchChatRoomBlackList';
  static final String updateChatRoomAnnouncement = 'updateChatRoomAnnouncement';
  static final String fetchChatRoomAnnouncement = 'fetchChatRoomAnnouncement';


  /// EMChatRoomManagerListener
  static final String chatRoomChange = 'onChatRoomChanged';

  /// EMGroupManager
  static const String getGroupWithId = 'getGroupWithId';
  static const String getJoinedGroups = 'getJoinedGroups';
  static const String getGroupsWithoutPushNotification = 'getGroupsWithoutPushNotification';
  static const String getJoinedGroupsFromServer = 'getJoinedGroupsFromServer';
  static const String getPublicGroupsFromServer = 'getPublicGroupsFromServer';
  static const String createGroup = 'createGroup';
  static const String getGroupSpecificationFromServer = 'getGroupSpecificationFromServer';
  static const String getGroupMemberListFromServer = 'getGroupMemberListFromServer';
  static const String getGroupBlacklistFromServer = 'getGroupBlacklistFromServer';
  static const String getGroupMuteListFromServer = 'getGroupMuteListFromServer';
  static const String getGroupWhiteListFromServer = 'getGroupWhiteListFromServer';
  static const String isMemberInWhiteListFromServer = 'isMemberInWhiteListFromServer';
  static const String getGroupFileListFromServer = 'getGroupFileList';
  static const String getGroupAnnouncementFromServer = 'getGroupAnnouncementFromServer';
  static const String addMembers = 'addMembers';
  static const String removeMembers = 'removeMembers';
  static const String blockMembers = 'blockMembers';
  static const String unblockMembers = 'unblockMembers';
  static const String updateGroupSubject = 'updateGroupSubject';
  static const String updateDescription = 'updateDescription';
  static const String leaveGroup = 'leaveGroup';
  static const String destroyGroup = 'destroyGroup';
  static const String blockGroup = 'blockGroup';
  static const String unblockGroup = 'unblockGroup';
  static const String updateGroupOwner = 'updateGroupOwner';
  static const String addAdmin = 'addAdmin';
  static const String removeAdmin = 'removeAdmin';
  static const String muteMembers = 'muteMembers';
  static const String unMuteMembers = 'unMuteMembers';
  static const String muteAllMembers = 'muteAllMembers';
  static const String unMuteAllMembers = 'unMuteAllMembers';
  static const String addWhiteList = 'addWhiteList';
  static const String removeWhiteList = 'removeWhiteList';
  static const String uploadGroupSharedFile = 'uploadGroupSharedFile';
  static const String downloadGroupSharedFile = 'downloadGroupSharedFile';
  static const String removeGroupSharedFile = 'removeGroupSharedFile';
  static const String updateGroupAnnouncement = 'updateGroupAnnouncement';
  static const String updateGroupExt = 'updateGroupExt';
  static const String joinPublicGroup = 'joinPublicGroup';
  static const String requestToJoinPublicGroup = 'requestToJoinPublicGroup';
  static const String acceptJoinApplication = 'acceptJoinApplication';
  static const String declineJoinApplication = 'declineJoinApplication';
  static const String acceptInvitationFromGroup = 'acceptInvitationFromGroup';
  static const String declineInvitationFromGroup = 'declineInvitationFromGroup';
  static const String ignoreGroupPush = 'ignoreGroupPush';

  /// EMGroupManagerListener
  static const String onGroupChanged = 'onGroupChanged';

  /// EMPushManager
  static const String getImPushConfigs = 'getImPushConfigs';
  static const String getImPushConfigsFromServer = 'getImPushConfigsFromServer';
  static const String updatePushNickname = 'updatePushNickname';

  /// ImPushConfigs
  static const String imPushNoDisturb = 'imPushNoDisturb';
  static const String updateImPushStyle = 'updateImPushStyle';
  static const String updateGroupPushService = 'updateGroupPushService';
  static const String getNoDisturbGroups = 'getNoDisturbGroups';

  /// EMCallManager
  static const String setCallOptions = 'setCallOptions';
  static const String getCallOptions = 'getCallOptions';
  static const String startCall = 'startCall';
  static const String answerComingCall = 'answerComingCall';
  static const String endCall = 'endCall';
  static const String releaseView = 'releaseView';
  
  /// EMCallManager Listener
  static const String onCallReceived = 'onCallReceived';
  static const String onCallDidEnd = 'onCallDidEnd';

  /// EMCallSessionListener
  static const String onCallDidAccept = 'onCallDidAccept';
  static const String onDidConnected = 'onDidConnected';
  static const String onCallStateDidChange = 'onCallStateDidChange';
  static const String onCallNetworkDidChange = 'onCallNetworkDidChange';

  /// ICallSession
  static const String pauseVoice = 'pauseVoice';
  static const String pauseVideo = 'pauseVideo';
  static const String switchCameraPosition = 'switchCameraPosition';
  static const String setLocalView = 'setLocalView';
  static const String setRemoteView = 'setRemoteView';

  /// EMConferenceManager
  static const String createAndJoinConference = 'createAndJoinConference';
  static const String joinConference = 'joinConference';
  static const String registerConferenceSharedManager = 'registerConferenceSharedManager';



}
