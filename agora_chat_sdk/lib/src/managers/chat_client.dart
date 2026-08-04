import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The ChatClient class, which is the entry point of the Chat SDK.
/// With this class, you can log in, log out, and access other functionalities such as group and chatroom.
/// ~end
///
/// ~chinese
/// 该类是 Chat SDK 的入口，负责登录、退出及连接管理等，由此可以获得其他模块的入口。
/// ~end
class ChatClient {
  static ChatClient? _instance;

  static ChatClient get getInstance => _instance ??= ChatClient._internal();
  ChatClient._internal() {
    platform_interface.Client.instance.updateNativeHandler((call) async {
      Map<String, dynamic>? argMap = call.arguments;
      ChatLog.d("${call.method}: arguments: $argMap");
      if (call.method == ChatMethodKeys.onConnected) {
        return _onConnected();
      } else if (call.method == ChatMethodKeys.onDisconnected) {
        return _onDisconnected();
      } else if (call.method == ChatMethodKeys.onUserDidLoginFromOtherDevice) {
        LoginExtensionInfo info = LoginExtensionInfo.fromJson(argMap!);
        _onUserDidLoginFromOtherDevice(info);
      } else if (call.method == ChatMethodKeys.onUserDidRemoveFromServer) {
        _onUserDidRemoveFromServer();
      } else if (call.method == ChatMethodKeys.onUserDidForbidByServer) {
        _onUserDidForbidByServer();
      } else if (call.method == ChatMethodKeys.onUserDidChangePassword) {
        _onUserDidChangePassword();
      } else if (call.method == ChatMethodKeys.onUserDidLoginTooManyDevice) {
        _onUserDidLoginTooManyDevice();
      } else if (call.method == ChatMethodKeys.onUserKickedByOtherDevice) {
        _onUserKickedByOtherDevice();
      } else if (call.method == ChatMethodKeys.onUserAuthenticationFailed) {
        _onUserAuthenticationFailed();
      } else if (call.method == ChatMethodKeys.onMultiDeviceGroupEvent) {
        _onMultiDeviceGroupEvent(argMap!);
      } else if (call.method == ChatMethodKeys.onMultiDeviceContactEvent) {
        _onMultiDeviceContactEvent(argMap!);
      } else if (call.method == ChatMethodKeys.onMultiDeviceThreadEvent) {
        _onMultiDeviceThreadEvent(argMap!);
      } else if (call.method ==
          ChatMethodKeys.onMultiDeviceRemoveMessagesEvent) {
        _onMultiDeviceRoamMessagesRemovedEvent(argMap!);
      } else if (call.method ==
          ChatMethodKeys.onMultiDevicesConversationEvent) {
        _onMultiDevicesConversationEvent(argMap!);
      } else if (call.method == ChatMethodKeys.onSendDataToFlutter) {
        _onReceiveCustomData(argMap!);
      } else if (call.method == ChatMethodKeys.onTokenWillExpire) {
        _onTokenWillExpire(argMap);
      } else if (call.method == ChatMethodKeys.onTokenDidExpire) {
        _onTokenDidExpire(argMap);
      } else if (call.method == ChatMethodKeys.onAppActiveNumberReachLimit) {
        _onAppActiveNumberReachLimit(argMap);
      } else if (call.method == ChatMethodKeys.onOfflineMessageSyncStart) {
        _onOfflineMessageSyncStart(argMap);
      } else if (call.method == ChatMethodKeys.onOfflineMessageSyncFinish) {
        _onOfflineMessageSyncFinish(argMap);
      }
    });
  }

  Future<void> _onConnected() async {
    for (var handler in _connectionHandlers.values) {
      handler.onConnected?.call();
    }
  }

  Future<void> _onDisconnected() async {
    for (var handler in _connectionHandlers.values) {
      handler.onDisconnected?.call();
    }
  }

  Future<void> _onUserDidLoginFromOtherDevice(LoginExtensionInfo info) async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserDidLoginFromOtherDevice?.call(info);
    }
  }

  Future<void> _onUserDidRemoveFromServer() async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserDidRemoveFromServer?.call();
    }
  }

  Future<void> _onUserDidForbidByServer() async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserDidForbidByServer?.call();
    }
  }

  Future<void> _onUserDidChangePassword() async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserDidChangePassword?.call();
    }
  }

  Future<void> _onUserDidLoginTooManyDevice() async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserDidLoginTooManyDevice?.call();
    }
  }

  Future<void> _onUserKickedByOtherDevice() async {
    for (var handler in _connectionHandlers.values) {
      handler.onUserKickedByOtherDevice?.call();
    }
  }

  Future<void> _onUserAuthenticationFailed() async {
    for (var handler in _connectionHandlers.values) {
      handler.onDisconnected?.call();
    }
  }

  void _onTokenWillExpire(Map? map) {
    for (var item in _connectionHandlers.values) {
      item.onTokenWillExpire?.call();
    }
  }

  void _onTokenDidExpire(Map? map) {
    for (var item in _connectionHandlers.values) {
      item.onTokenDidExpire?.call();
    }
  }

  void _onAppActiveNumberReachLimit(Map? map) {
    for (var item in _connectionHandlers.values) {
      item.onAppActiveNumberReachLimit?.call();
    }
  }

  void _onOfflineMessageSyncStart(Map? map) {
    for (var item in _connectionHandlers.values) {
      item.onOfflineMessageSyncStart?.call();
    }
  }

  void _onOfflineMessageSyncFinish(Map? map) {
    for (var item in _connectionHandlers.values) {
      item.onOfflineMessageSyncFinish?.call();
    }
  }

  Future<void> _onMultiDeviceGroupEvent(Map map) async {
    ChatMultiDevicesEvent event = convertIntToChatMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    List<String>? users = map.getList("userIds");

    for (var handler in _multiDeviceHandlers.values) {
      handler.onGroupEvent?.call(event, target, users);
    }
  }

  Future<void> _onMultiDeviceContactEvent(Map map) async {
    ChatMultiDevicesEvent event = convertIntToChatMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    String? ext = map['ext'];

    for (var handler in _multiDeviceHandlers.values) {
      handler.onContactEvent?.call(event, target, ext);
    }
  }

  Future<void> _onMultiDeviceThreadEvent(Map map) async {
    ChatMultiDevicesEvent event = convertIntToChatMultiDevicesEvent(map['event'])!;
    String target = map['target'] ?? '';
    List<String> users = map.getList("userIds") ?? [];

    for (var handler in _multiDeviceHandlers.values) {
      handler.onChatThreadEvent?.call(event, target, users);
    }
  }

  Future<void> _onMultiDeviceRoamMessagesRemovedEvent(Map map) async {
    String convId = map['convId'];
    String deviceId = map['deviceId'];
    for (var handler in _multiDeviceHandlers.values) {
      handler.onRemoteMessagesRemoved?.call(convId, deviceId);
    }
  }

  Future<void> _onMultiDevicesConversationEvent(Map map) async {
    ChatMultiDevicesEvent event = convertIntToChatMultiDevicesEvent(map['event'])!;
    String convId = map['convId'];
    ChatConversationType type = ChatConversationType.values[map['convType']];
    for (var handler in _multiDeviceHandlers.values) {
      handler.onConversationEvent?.call(event, convId, type);
    }
  }

  void _onReceiveCustomData(Map map) {
    customEventHandler?.call(map);
  }

  ChatManager? _chatManager;
  ChatContactManager? _contactManager;
  ChatGroupManager? _groupManager;
  ChatRoomManager? _roomManager;
  ChatPresenceManager? _presenceManager;
  ChatPushManager? _pushManager;
  ChatThreadManager? _threadManager;
  ChatUserInfoManager? _userInfoManager;

  ChatManager get chatManager => _chatManager ??= ChatManager();
  ChatContactManager get contactManager => _contactManager ??= ChatContactManager();
  ChatRoomManager get chatRoomManager => _roomManager ??= ChatRoomManager();
  ChatGroupManager get groupManager => _groupManager ??= ChatGroupManager();
  ChatPushManager get pushManager => _pushManager ??= ChatPushManager();
  ChatPresenceManager get presenceManager =>
      _presenceManager ??= ChatPresenceManager();
  ChatUserInfoManager get userInfoManager =>
      _userInfoManager ??= ChatUserInfoManager();

  ChatThreadManager get chatThreadManager =>
      _threadManager ??= ChatThreadManager();

  String? get currentUserId => _currentUserId;
  String? _currentUserId;

  ChatOptions? get options => _options;
  ChatOptions? _options;

  final Map<String, ConnectionEventHandler> _connectionHandlers = {};
  final Map<String, ChatMultiDeviceEventHandler> _multiDeviceHandlers = {};

  void Function(Map map)? customEventHandler;

  void _updataHandler() {
    chatManager;
    contactManager;
    chatRoomManager;
    groupManager;
    pushManager;
    presenceManager;
    userInfoManager;
    chatThreadManager;
  }

  /// ~english
  /// Adds the connection event handler. After calling this method, you can handle new connection events when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, which is used to find the corresponding handler.
  ///
  /// Param [handler] The handler for connection event. See [ConnectionEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加连接状态监听事件。
  ///
  /// Param [identifier] 监听事件对应 ID。
  ///
  /// Param [handler] 监听的事件。 请见 [ConnectionEventHandler]。
  /// ~end
  void addConnectionEventHandler(
    String identifier,
    ConnectionEventHandler handler,
  ) {
    _connectionHandlers[identifier] = handler;
  }

  /// ~english
  /// Removes the connection event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除连接状态监听事件。
  ///
  /// Param [identifier] 监听事件对应 ID。
  /// ~end
  void removeConnectionEventHandler(String identifier) {
    _connectionHandlers.remove(identifier);
  }

  /// ~english
  /// Gets the connection event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The connection event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取连接状态监听事件。
  ///
  /// Param [identifier] 监听事件对应 ID。
  ///
  /// **Return** 连接状态监听。
  /// ~end
  ConnectionEventHandler? getConnectionEventHandler(String identifier) {
    return _connectionHandlers[identifier];
  }

  /// ~english
  /// Clears all connection event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所以连接状态监听。
  /// ~end
  void clearConnectionEventHandlers() {
    return _connectionHandlers.clear();
  }

  /// ~english
  /// Adds the multi-device event handler. After calling this method, you can handle for new multi-device events when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, which is used to find the corresponding handler.
  ///
  /// Param [handler] The handler multi-device event. See [ChatMultiDeviceEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加多设备事件监听。
  ///
  /// Param [identifier] 多设备事件监听对应 ID。
  ///
  /// Param [handler] 多设备事件监听。 请见 [ChatMultiDeviceEventHandler]。
  /// ~end
  void addMultiDeviceEventHandler(
    String identifier,
    ChatMultiDeviceEventHandler handler,
  ) {
    _multiDeviceHandlers[identifier] = handler;
  }

  /// ~english
  /// Removes the multi-device event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除多设备事件监听。
  ///
  /// Param [identifier] 要移除多设备事件监听对应的 ID。
  /// ~end
  void removeMultiDeviceEventHandler(String identifier) {
    _multiDeviceHandlers.remove(identifier);
  }

  /// ~english
  /// Gets the multi-device event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The multi-device event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取多设备事件监听。
  ///
  /// Param [identifier] 多设备事件监听对应的 ID。
  ///
  /// **Return** 多设备事件监听。
  /// ~end
  ChatMultiDeviceEventHandler? getMultiDeviceEventHandler(String identifier) {
    return _multiDeviceHandlers[identifier];
  }

  /// ~english
  /// Clears all multi-device event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有多设备事件监听。
  /// ~end
  void clearMultiDeviceEventHandlers() {
    return _multiDeviceHandlers.clear();
  }

  /// ~english
  /// Starts contact and group, chatroom callback.
  ///
  /// Call this method when you UI is ready, then will receive [ChatRoomEventHandler], [ChatContactEventHandler], [ChatGroupEventHandler] event.
  /// ~end
  ///
  /// ~chinese
  /// 开始回调通知。
  ///
  /// 当UI准备好后调用，调用之后才能收到 [ChatRoomEventHandler], [ChatContactEventHandler], [ChatGroupEventHandler] 监听。
  /// ~end
  Future<void> startCallback() async {
    try {
      await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.startCallback);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Checks whether the SDK is connected to the chat server.
  ///
  /// **Return** Whether the SDK is connected to the chat server.
  /// `true`: The SDK is connected to the chat server.
  /// `false`: The SDK is not connected to the chat server.
  /// ~end
  ///
  /// ~chinese
  /// 检查 SDK 是否连接到 Chat 服务器。
  /// **Return** SDK 是否连接到 Chat 服务器。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  Future<bool> isConnected() async {
    try {
      Map result = await platform_interface.Client.instance.callNativeMethod(
        ChatMethodKeys.isConnected,
      );
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isConnected);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Checks whether the user has logged in before and did not log out.
  ///
  /// If you need to check whether the SDK is connected to the server, please use [isConnected].
  ///
  /// **Return** Whether the user has logged in before.
  /// `true`: The user has logged in before,
  /// `false`: The user has not logged in before or has called the [logout] method.
  /// ~end
  ///
  /// ~chinese
  /// 检查用户是否已登录 Chat 服务。
  ///
  /// **Return** 用户是否已经登录 Chat 服务。
  ///   - `true`：是；
  ///   - `false`：否。
  /// ~end
  Future<bool> isLoginBefore() async {
    try {
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.isLoggedInBefore);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isLoggedInBefore);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the current login user ID.
  ///
  /// **Return** The current login user ID.
  /// ~end
  ///
  /// ~chinese
  /// 获取当前登录的用户 ID。
  ///
  /// **Return** 当前登录的用户 ID。
  /// ~end
  Future<String?> getCurrentUserId() async {
    try {
      Map result =
          await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.getCurrentUser);
      ChatError.hasErrorFromResult(result);
      _currentUserId = result[ChatMethodKeys.getCurrentUser];
      if (_currentUserId != null) {
        if (_currentUserId!.isEmpty) {
          _currentUserId = null;
        }
      }
      return _currentUserId;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the token of the current logged-in user.
  /// ~end
  ///
  /// ~chinese
  /// 获取当前登录账号的 Token。
  ///
  /// **Return** 当前登录账号的 Token。
  /// ~end
  Future<String> getAccessToken() async {
    try {
      Map result =
          await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.getToken);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getToken];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the current device ID.
  ///
  /// **Return** The current device ID.
  /// ~end
  ///
  /// ~chinese
  /// 获取当前设备 ID。
  ///
  /// **Return** 当前设备 ID。
  /// ~end
  Future<String> getCurrentDeviceId() async {
    try {
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.getCurrentDeviceId);
      ChatError.hasErrorFromResult(result);
      ChatDeviceInfo deviceInfo =
          ChatDeviceInfo.fromJson(result[ChatMethodKeys.getCurrentDeviceId]);
      return deviceInfo.deviceUUID ?? '';
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Initializes the SDK.
  ///
  /// Param [options] The configurations: [ChatOptions]. Ensure that you set this parameter.
  /// ~end
  ///
  /// ~chinese
  /// 初始化 SDK。
  ///
  /// Param [options] 配置，不可为空。
  /// ~end
  Future<void> init(ChatOptions options) async {
    _updataHandler();

    try {
      _options = options;
      ChatLog.v('init: $options');
      await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.init, options.toJson());
      _currentUserId = await getCurrentUserId();
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Registers a new user.
  ///
  /// Param [userId] The user Id. The maximum length is 64 characters. Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-),
  /// and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones.
  /// If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [password] The password. The maximum length is 64 characters. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 创建账号。
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。请确保同一个 app 下，userId 唯一；`userId` 用户 ID 是会公开的信息，请勿使用 UUID、邮箱地址、手机号等敏感信息。
  ///
  /// Param [password] 密码，长度不超过 64 个字符。请确保你对该参数设值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> createAccount(String userId, String password) async {
    try {
      ChatLog.v('create account: $userId : $password');
      Map req = {'userId': userId, 'password': password};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.createAccount, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [loginWithToken or loginWithPassword] instead')

  /// ~english
  /// Logs in to the chat server with a password or token.
  ///
  /// Param [userId] The user ID. The maximum length is 64 characters. Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.).
  /// This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones.
  /// If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [isPassword] Whether to log in with a password or a token.
  /// (Default) `true`: A password is used.
  /// `false`: A token is used.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 使用密码或 Token 登录服务器。
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。
  /// 支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。
  /// 该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
  ///
  /// Param [pwdOrToken] 登录密码或 Token。
  ///
  /// Param [isPassword] 是否用密码登录。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> login(
    String userId,
    String pwdOrToken, [
    bool isPassword = true,
  ]) async {
    try {
      ChatLog.v('login: $userId : $pwdOrToken, isPassword: $isPassword');
      Map req = {
        'userId': userId,
        'pwdOrToken': pwdOrToken,
        'isPassword': isPassword
      };
      Map result =
          await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.login, req);
      ChatError.hasErrorFromResult(result);
      _currentUserId = userId;
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [loginWithToken] instead')

  /// ~english
  /// Logs in to the chat server by user ID and Agora token. This method supports automatic login.
  ///
  /// Another method to login to chat server is to login with user ID and token, See [login].
  ///
  /// Param [userId] The user Id.
  ///
  /// Param [agoraToken] The Agora token.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 用声网 Token 登录服务器，该方法支持自动登录。
  ///
  /// **Note**
  /// 通过 token 登录服务器的方法见[login]。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [agoraToken] Token。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> loginWithAgoraToken(String userId, String agoraToken) async {
    try {
      return login(userId, agoraToken, false);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Logs in to the chat server with a token.
  ///
  /// Param [userId]  The user ID. The maximum length is 64 characters.
  /// Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.).
  /// This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [token] The token for login to the chat server.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 用户使用 token 登录。
  ///
  /// **Note**
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。
  /// 支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。
  /// 该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
  ///
  /// Param [token] 登录 Token。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> loginWithToken(
    String userId,
    String token,
  ) async {
    try {
      // ignore: deprecated_member_use_from_same_package
      return login(userId, token, false);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Logs in to the chat server with a password.
  ///
  /// Param [userId]  The user ID. The maximum length is 64 characters.
  /// Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.).
  /// This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [password] The password. The maximum length is 64 characters. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 用户使用密码登录聊天服务器。
  ///
  /// **Note**
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。
  /// 支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。
  /// 该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
  ///
  /// Param [password] 密码，长度不超过 64 个字符。请确保你对该参数设值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> loginWithPassword(
    String userId,
    String password,
  ) async {
    try {
      // ignore: deprecated_member_use_from_same_package
      return login(userId, password, true);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Renews the Agora token.
  ///
  /// If a user is logged in with an Agora token, when the token expires, you need to call this method to update the token.
  ///
  /// Param [agoraToken] The new Agora token.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 当用户在声网 token 登录状态时，且在 [ConnectionEventHandler.onTokenWillExpire] 实现类中收到 token 即将过期事件的回调通知可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
  ///
  /// Param [agoraToken] 新声网 Token.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> renewAgoraToken(String agoraToken) async {
    try {
      Map req = {"agora_token": agoraToken};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.renewToken, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Logs out.
  ///
  /// Param [unbindDeviceToken] Whether to unbind the token upon logout.
  ///
  /// `true` (default) Yes.
  /// `false` No.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 退出登录。
  ///
  /// Param [unbindDeviceToken] 退出时是否解绑设备 token。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> logout([
    bool unbindDeviceToken = true,
  ]) async {
    try {
      ChatLog.v('logout unbindDeviceToken: $unbindDeviceToken');
      Map req = {'unbindToken': unbindDeviceToken};
      Map result =
          await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.logout, req);
      ChatError.hasErrorFromResult(result);
      _clearAllInfo();
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the App Key, which is the unique identifier to access Agora Chat.
  ///
  /// You can retrieve the new App Key from Agora Console.
  ///
  /// As this key controls all access to Agora Chat for your app, you can only update the key when the current user is logged out.
  ///
  /// Param [newAppKey] The App Key. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改 App Key。
  ///
  /// @note
  /// 只有在未登录状态才能修改 App Key。
  ///
  /// Param [newAppKey] App Key，请确保设置该参数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<bool> changeAppKey({required String newAppKey}) async {
    try {
      ChatLog.v('changeAppKey: $newAppKey');
      Map req = {'appKey': newAppKey};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.changeAppKey, req);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the App Id, which is the unique identifier to access Agora Chat.
  ///
  /// You can retrieve the new App Key from Agora Console.
  ///
  /// As this key controls all access to Agora Chat for your app, you can only update the key when the current user is logged out.
  ///
  /// Param [newAppId] The App Id. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改 App Id
  ///
  /// @note
  /// 只有在未登录状态才能修改 App Id
  ///
  /// Param [newAppId] App Id
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<bool> changeAppId({required String newAppId}) async {
    try {
      ChatLog.v('newAppId: $newAppId');
      Map req = {'appId': newAppId};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.changeAppId, req);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Compresses the debug log into a gzip archive.
  ///
  /// Best practice is to delete this debug archive as soon as it is no longer used.
  ///
  /// **Return** The path of the compressed gzip file.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 压缩 log 文件，并返回压缩后的文件路径。强烈建议方法完成之后删除该压缩文件。
  ///
  /// **Return** 压缩后的 log 文件路径。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<String> compressLogs() async {
    try {
      ChatLog.v('compressLogs:');
      Map result =
          await platform_interface.Client.instance.callNativeMethod(ChatMethodKeys.compressLogs);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.compressLogs];
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [fetchLoggedInDevices] instead')

  /// ~english
  /// Gets the list of currently logged-in devices of a specified account.
  ///
  /// Param [userId] The user ID.
  ///
  /// Param [password] The password.
  ///
  /// **Return** The list of the logged-in devices.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取指定账号下登录的在线设备列表。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [password] 密码。
  ///
  /// **Return**  获取到到设备列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatDeviceInfo>> getLoggedInDevicesFromServer(
      {required String userId, required String password}) async {
    try {
      Map req = {'userId': userId, 'password': password};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.getLoggedInDevicesFromServer, req);
      ChatError.hasErrorFromResult(result);
      List<ChatDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(ChatDeviceInfo.fromJson(info));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the list of currently logged-in devices of a specified account.
  ///
  /// Param [userId] The user ID.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [isPwd] Whether a password or token is used: (Default)`true`: A password is used; `false`: A token is used.
  ///
  /// **Return** The list of the logged-in devices.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取指定账号下登录的在线设备列表。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [pwdOrToken] 密码或者 token。
  ///
  /// Param [isPwd] 是否使用密码或 token：（默认）`true`：使用密码；`false`：使用 token。
  ///
  /// **Return**  获取到到设备列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatDeviceInfo>> fetchLoggedInDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    try {
      Map req = {'userId': userId, 'password': pwdOrToken, 'isPwd': isPwd};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.getLoggedInDevicesFromServer, req);
      ChatError.hasErrorFromResult(result);
      List<ChatDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(ChatDeviceInfo.fromJson(info));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Forces the specified account to log out from the specified device.
  ///
  /// Param [userId] The account you want to force to log out.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [resource] The device ID. For how to fetch the device ID, See [ChatDeviceInfo.resource].
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定账号登录的指定设备踢下线。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [pwdOrToken] 密码 / token。
  ///
  /// Param [resource] 设备 ID，详见 [ChatDeviceInfo.resource]。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> kickDevice({
    required String userId,
    required String pwdOrToken,
    required String resource,
    bool isPwd = true,
  }) async {
    try {
      ChatLog.v('kickDevice: $userId, "******"');
      Map req = {
        'userId': userId,
        'password': pwdOrToken,
        'resource': resource,
        'isPwd': isPwd,
      };
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.kickDevice, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Forces the specified account to log out from all devices.
  ///
  /// Param [userId] The account you want to force to log out from all the devices.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [isPwd] Whether a password or token is used: (Default)`true`: A password is used; `false`: A token is used.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定账号登录的所有设备都踢下线。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [pwdOrToken] 密码 或 token。
  ///
  /// Param [isPwd] 是否使用密码或 token：（默认）`true`：使用密码；`false`：使用 token。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  ///
  /// ~end
  Future<void> kickAllDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    try {
      Map req = {'userId': userId, 'password': pwdOrToken, 'isPwd': isPwd};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.kickAllDevices, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUsingHttpsOnlySetting(bool usingHttpsOnly) async {
    try {
      Map req = {'usingHttpsOnly': usingHttpsOnly};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateUsingHttpsOnlySetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(usingHttpsOnly: usingHttpsOnly);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  ///

  Future<void> updateLoginExtensionInfoSetting(String extension) async {
    try {
      Map req = {'extension': extension};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateLoginExtensionInfo, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(loginExtension: extension);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDeleteMessagesWhenLeaveGroupSetting(
      bool deleteMessagesWhenLeaveGroup) async {
    try {
      Map req = {'deleteMessagesWhenLeaveGroup': deleteMessagesWhenLeaveGroup};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateDeleteMessagesWhenLeaveGroupSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessagesWhenLeaveGroup: deleteMessagesWhenLeaveGroup);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDeleteMessageWhenLeaveRoomSetting(
      bool deleteMessageWhenLeaveRoom) async {
    try {
      Map req = {'deleteMessageWhenLeaveRoom': deleteMessageWhenLeaveRoom};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateDeleteMessageWhenLeaveRoomSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessageWhenLeaveRoom: deleteMessageWhenLeaveRoom);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoomOwnerCanLeaveSetting(bool roomOwnerCanLeave) async {
    try {
      Map req = {'roomOwnerCanLeave': roomOwnerCanLeave};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateRoomOwnerCanLeaveSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(roomOwnerCanLeave: roomOwnerCanLeave);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAutoAcceptGroupInvitationSetting(
      bool autoAcceptGroupInvitation) async {
    try {
      Map req = {'autoAcceptGroupInvitation': autoAcceptGroupInvitation};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateAutoAcceptGroupInvitationSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          autoAcceptGroupInvitation: autoAcceptGroupInvitation);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAutoAcceptFriendInvitationSetting(
      bool acceptInvitationAlways) async {
    try {
      Map req = {'acceptInvitationAlways': acceptInvitationAlways};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateAcceptInvitationAlways, req);
      ChatError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(acceptInvitationAlways: acceptInvitationAlways);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAutoDownloadAttachmentThumbnailSetting(
      bool autoDownloadThumbnail) async {
    try {
      Map req = {'autoDownloadThumbnail': autoDownloadThumbnail};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateAutoDownloadAttachmentThumbnailSetting, req);
      ChatError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(autoDownloadThumbnail: autoDownloadThumbnail);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRequireAckSetting(bool requireAck) async {
    try {
      Map req = {'requireAck': requireAck};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateRequireAckSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireAck: requireAck);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDeliveryAckSetting(bool requireDeliveryAck) async {
    try {
      Map req = {'requireDeliveryAck': requireDeliveryAck};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateDeliveryAckSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireDeliveryAck: requireDeliveryAck);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSortMessageByServerTimeSetting(
      bool sortMessageByServerTime) async {
    try {
      Map req = {'sortMessageByServerTime': sortMessageByServerTime};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateSortMessageByServerTimeSetting, req);
      ChatError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(sortMessageByServerTime: sortMessageByServerTime);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMessagesReceiveCallbackIncludeSendSetting(
      bool includeSend) async {
    try {
      Map req = {'includeSend': includeSend};
      Map result = await platform_interface.Client.instance.callNativeMethod(
          ChatMethodKeys.updateMessagesReceiveCallbackIncludeSendSetting, req);
      ChatError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(messagesReceiveCallbackIncludeSend: includeSend);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRegradeMessagesAsReadSetting(bool isRead) async {
    try {
      Map req = {'isRead': isRead};
      Map result = await platform_interface.Client.instance
          .callNativeMethod(ChatMethodKeys.updateRegradeMessagesSetting, req);
      ChatError.hasErrorFromResult(result);
      _options = _options?.copyWith(regardImportMessagesAsRead: isRead);
    } catch (e) {
      rethrow;
    }
  }

  void _clearAllInfo() {
    _currentUserId = null;
    userInfoManager.clearUserInfoCache();
  }
}
