import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// Shared by init page and auto mode: JSON -> ChatOptions.
/// appKey is required; other keys fall back to SDK defaults; unknown keys are ignored.
ChatOptions emOptionsFromJson(Map<String, dynamic> j) {
  final appKey = j['appKey'] as String?;
  if (appKey == null || appKey.isEmpty) {
    throw ArgumentError('appKey 不能为空');
  }
  bool? b(String k) => j[k] as bool?;
  String? s(String k) => j[k] as String?;
  int? i(String k) => j[k] as int?;
  return ChatOptions.withAppKey(
    appKey,
    autoLogin: b('autoLogin') ?? true,
    debugMode: b('debugMode') ?? false,
    acceptInvitationAlways: b('acceptInvitationAlways') ?? false,
    autoAcceptGroupInvitation: b('autoAcceptGroupInvitation') ?? false,
    requireAck: b('requireAck') ?? true,
    requireDeliveryAck: b('requireDeliveryAck') ?? false,
    deleteMessagesAsExitGroup: b('deleteMessagesAsExitGroup') ?? true,
    deleteMessagesAsExitChatRoom: b('deleteMessagesAsExitChatRoom') ?? true,
    isChatRoomOwnerLeaveAllowed: b('isChatRoomOwnerLeaveAllowed') ?? true,
    sortMessageByServerTime: b('sortMessageByServerTime') ?? true,
    usingHttpsOnly: b('usingHttpsOnly') ?? true,
    serverTransfer: b('serverTransfer') ?? true,
    isAutoDownloadThumbnail: b('isAutoDownloadThumbnail') ?? true,
    enableDNSConfig: b('enableDNSConfig') ?? true,
    dnsUrl: s('dnsUrl'),
    restServer: s('restServer'),
    imPort: i('imPort'),
    imServer: s('imServer'),
    webSocketServer: s('webSocketServer'),
    webSocketPort: i('webSocketPort'),
    chatAreaCode: i('chatAreaCode'),
    enableEmptyConversation: b('enableEmptyConversation') ?? false,
    deviceName: s('deviceName'),
    osType: i('osType'),
    useReplacedMessageContents: b('useReplacedMessageContents') ?? false,
    enableTLS: b('enableTLS') ?? false,
    messagesReceiveCallbackIncludeSend:
        b('messagesReceiveCallbackIncludeSend') ?? false,
    regardImportMessagesAsRead: b('regardImportMessagesAsRead') ?? false,
    workPathCopiable: b('workPathCopiable') ?? false,
    enableUserInfo: b('enableUserInfo') ?? false,
    enableAutoSyncContacts: b('enableAutoSyncContacts') ?? false,
    loginExtension: s('loginExtension'),
  );
}

/// Init page pre-fill template: contains only required fields.
const String emOptionsTemplate = '''{
  "appKey": "",
  "autoLogin": false,
  "debugMode": true
}''';
