// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/services.dart';
import '../chat_sdk.dart';
import 'internal/inner_headers.dart';

/// ~english
/// The Client class, which is the entry point of the Chat SDK.
/// With this class, you can log in, log out, and access other functionalities such as group and chatroom.
/// ~end
///
/// ~chinese
/// 该类是 Chat SDK 的入口，负责登录、退出及连接管理等，由此可以获得其他模块的入口。
/// ~end
class Client {
  static Client? _instance;
  final ChatManager _chatManager = ChatManager();
  final ContactManager _contactManager = ContactManager();
  final ChatRoomManager _chatRoomManager = ChatRoomManager();
  final GroupManager _groupManager = GroupManager();
  final PushManager _pushManager = PushManager();
  final UserInfoManager _userInfoManager = UserInfoManager();

  final PresenceManager _presenceManager = PresenceManager();
  final ThreadManager _chatThreadManager = ThreadManager();

  final Map<String, ConnectionEventHandler> _connectionEventHandler = {};
  final Map<String, MultiDeviceEventHandler> _multiDeviceEventHandler = {};

  // ignore: unused_field
  ProgressManager? _progressManager;

  Options? _options;

  /// ~english
  /// Gets the configurations.
  /// ~end
  ///
  /// ~chinese
  /// 获取配置信息。
  /// ~end
  Options? get options => _options;

  String? _currentUserId;

  /// ~english
  /// Gets the SDK instance.
  /// ~end
  ///
  /// ~chinese
  /// 获取 SDK 实例。
  /// ~end
  static Client get getInstance => _instance ??= Client._internal();

  /// ~english
  /// Sets a custom event handler to receive data from iOS or Android devices.
  ///
  /// Param [customEventHandler] The custom event handler.
  /// ~end
  ///
  /// ~chinese
  /// 设置一个自定义事件句柄来接收来自 iOS 或 Android 设备的数据。
  /// ~end
  void Function(Map map)? customEventHandler;

  /// ~english
  /// Gets the current logged-in user ID.
  /// ~end
  ///
  /// ~chinese
  /// 当前登录用户 ID.
  /// ~end
  String? get currentUserId => _currentUserId;

  Client._internal() {
    _progressManager = ProgressManager();
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    ClientChannel.setMethodCallHandler((MethodCall call) async {
      Map<String, dynamic>? argMap = call.arguments;
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
    _connectionEventHandler[identifier] = handler;
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
    _connectionEventHandler.remove(identifier);
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
    return _connectionEventHandler[identifier];
  }

  /// ~english
  /// Clears all connection event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所以连接状态监听。
  /// ~end
  void clearConnectionEventHandles() {
    _connectionEventHandler.clear();
  }

  /// ~english
  /// Adds the multi-device event handler. After calling this method, you can handle for new multi-device events when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, which is used to find the corresponding handler.
  ///
  /// Param [handler] The handler multi-device event. See [MultiDeviceEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加多设备事件监听。
  ///
  /// Param [identifier] 多设备事件监听对应 ID。
  ///
  /// Param [handler] 多设备事件监听。 请见 [MultiDeviceEventHandler]。
  /// ~end
  void addMultiDeviceEventHandler(
    String identifier,
    MultiDeviceEventHandler handler,
  ) {
    _multiDeviceEventHandler[identifier] = handler;
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
    _multiDeviceEventHandler.remove(identifier);
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
  MultiDeviceEventHandler? getMultiDeviceEventHandler(String identifier) {
    return _multiDeviceEventHandler[identifier];
  }

  /// ~english
  /// Clears all multi-device event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有多设备事件监听。
  /// ~end
  void clearMultiDeviceEventHandles() {
    _multiDeviceEventHandler.clear();
  }

  /// ~english
  /// Starts contact and group, chatroom callback.
  ///
  /// Call this method when you UI is ready, then will receive [ChatRoomEventHandler], [ContactEventHandler], [GroupEventHandler] event.
  /// ~end
  ///
  /// ~chinese
  /// /// 开始回调通知。
  ///
  /// 当UI准备好后调用，调用之后才能收到 [ChatRoomEventHandler], [ContactEventHandler], [GroupEventHandler] 监听。
  /// ~end
  Future<void> startCallback() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.startCallback);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
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
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.isConnected);
    try {
      Error.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isConnected);
    } on Error catch (e) {
      throw e;
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
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.isLoggedInBefore);
    try {
      Error.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isLoggedInBefore);
    } on Error catch (e) {
      throw e;
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
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.getCurrentUser);
    try {
      Error.hasErrorFromResult(result);
      _currentUserId = result[ChatMethodKeys.getCurrentUser];
      if (_currentUserId != null) {
        if (_currentUserId!.length == 0) {
          _currentUserId = null;
        }
      }
      return _currentUserId;
    } on Error catch (e) {
      throw e;
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
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.getToken);
    try {
      Error.hasErrorFromResult(result);
      return result[ChatMethodKeys.getToken];
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Initializes the SDK.
  ///
  /// Param [options] The configurations: [Options]. Ensure that you set this parameter.
  /// ~end
  ///
  /// ~chinese
  /// 初始化 SDK。
  ///
  /// Param [options] 配置，不可为空。
  /// ~end
  Future<void> init(Options options) async {
    _options = options;
    ChatLog.v('init: $options');
    await ClientChannel.invokeMethod(ChatMethodKeys.init, options.toJson());
    _currentUserId = await getCurrentUserId();
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
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 创建账号。
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。请确保同一个 app 下，userId 唯一；`userId` 用户 ID 是会公开的信息，请勿使用 UUID、邮箱地址、手机号等敏感信息。
  ///
  /// Param [password] 密码，长度不超过 64 个字符。请确保你对该参数设值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> createAccount(String userId, String password) async {
    ChatLog.v('create account: $userId : $password');
    Map req = {'username': userId, 'password': password};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.createAccount, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> login(
    String userId,
    String pwdOrToken, [
    bool isPassword = true,
  ]) async {
    ChatLog.v('login: $userId : $pwdOrToken, isPassword: $isPassword');
    Map req = {
      'username': userId,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.login, req);
    try {
      Error.hasErrorFromResult(result);
      _currentUserId = userId;
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> loginWithAgoraToken(String userId, String agoraToken) async {
    return login(userId, agoraToken, false);
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> loginWithToken(
    String userId,
    String token,
  ) async {
    return login(userId, token, false);
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> loginWithPassword(
    String userId,
    String password,
  ) async {
    return login(userId, password, true);
  }

  @Deprecated('Use [renewToken] instead')

  /// ~english
  /// Renews the Agora token.
  ///
  /// If a user is logged in with an Agora token, when the token expires, you need to call this method to update the token.
  ///
  /// Param [agoraToken] The new Agora token.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 当用户在声网 token 登录状态时，且在 [ConnectionEventHandler.onTokenWillExpire] 实现类中收到 token 即将过期事件的回调通知可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
  ///
  /// Param [agoraToken] 新声网 Token.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> renewAgoraToken(String agoraToken) async {
    Map req = {"agora_token": agoraToken};

    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.renewToken, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Renews token.
  ///
  /// If a user is logged in with an token, when the token expires, you need to call this method to update the token.
  ///
  /// Param [token] The new token.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 当用户在 token 登录状态时，且在 [ConnectionEventHandler.onTokenWillExpire] 实现类中收到 token 即将过期事件的回调通知可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
  ///
  /// Param [token] 新Token.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> renewToken(String token) async {
    Map req = {"agora_token": token};

    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.renewToken, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 退出登录。
  ///
  /// Param [unbindDeviceToken] 退出时是否解绑设备 token。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> logout([
    bool unbindDeviceToken = true,
  ]) async {
    ChatLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.logout, req);
    try {
      Error.hasErrorFromResult(result);
      _clearAllInfo();
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<bool> changeAppKey({required String newAppKey}) async {
    ChatLog.v('changeAppKey: $newAppKey');
    Map req = {'appKey': newAppKey};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppKey, req);
    try {
      Error.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<bool> changeAppId({required String newAppId}) async {
    ChatLog.v('newAppId: $newAppId');
    Map req = {'appId': newAppId};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppId, req);
    try {
      Error.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Compresses the debug log into a gzip archive.
  ///
  /// Best practice is to delete this debug archive as soon as it is no longer used.
  ///
  /// **Return** The path of the compressed gzip file.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 压缩 log 文件，并返回压缩后的文件路径。强烈建议方法完成之后删除该压缩文件。
  ///
  /// **Return** 压缩后的 log 文件路径。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<String> compressLogs() async {
    ChatLog.v('compressLogs:');
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.compressLogs);
    try {
      Error.hasErrorFromResult(result);
      return result[ChatMethodKeys.compressLogs];
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<List<DeviceInfo>> getLoggedInDevicesFromServer(
      {required String userId, required String password}) async {
    Map req = {'username': userId, 'password': password};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      Error.hasErrorFromResult(result);
      List<DeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(DeviceInfo.fromJson(info));
      });
      return list;
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<List<DeviceInfo>> fetchLoggedInDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    Map req = {'username': userId, 'password': pwdOrToken, 'isPwd': isPwd};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      Error.hasErrorFromResult(result);
      List<DeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(DeviceInfo.fromJson(info));
      });
      return list;
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Forces the specified account to log out from the specified device.
  ///
  /// Param [userId] The account you want to force to log out.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [resource] The device ID. For how to fetch the device ID, See [DeviceInfo.resource].
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 将指定账号登录的指定设备踢下线。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [pwdOrToken] 密码 / token。
  ///
  /// Param [resource] 设备 ID，详见 [DeviceInfo.resource]。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  /// ~end
  Future<void> kickDevice({
    required String userId,
    required String pwdOrToken,
    required String resource,
    bool isPwd = true,
  }) async {
    ChatLog.v('kickDevice: $userId, "******"');
    Map req = {
      'username': userId,
      'password': pwdOrToken,
      'resource': resource,
      'isPwd': isPwd,
    };
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickDevice, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
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
  /// **Throws** A description of the exception. See [Error].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [Error]。
  ///
  /// ~end
  Future<void> kickAllDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    Map req = {'username': userId, 'password': pwdOrToken, 'isPwd': isPwd};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickAllDevices, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> _onConnected() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onConnected?.call();
    }
  }

  Future<void> _onDisconnected() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onDisconnected?.call();
    }
  }

  Future<void> _onUserDidLoginFromOtherDevice(LoginExtensionInfo info) async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidLoginFromOtherDevice?.call(info);
    }
    _clearAllInfo();
  }

  Future<void> _onUserDidRemoveFromServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidRemoveFromServer?.call();
    }
    _clearAllInfo();
  }

  Future<void> _onUserDidForbidByServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidForbidByServer?.call();
    }
    _clearAllInfo();
  }

  Future<void> _onUserDidChangePassword() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidChangePassword?.call();
    }
    _clearAllInfo();
  }

  Future<void> _onUserDidLoginTooManyDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidLoginTooManyDevice?.call();
    }
    _clearAllInfo();
  }

  Future<void> _onUserKickedByOtherDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserKickedByOtherDevice?.call();
    }
    _clearAllInfo();
  }

  Future<void> _onUserAuthenticationFailed() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onDisconnected?.call();
    }
    _clearAllInfo();
  }

  void _onTokenWillExpire(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onTokenWillExpire?.call();
    }
  }

  void _onTokenDidExpire(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onTokenDidExpire?.call();
    }
  }

  void _onAppActiveNumberReachLimit(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onAppActiveNumberReachLimit?.call();
    }
    _clearAllInfo();
  }

  void _onOfflineMessageSyncStart(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onOfflineMessageSyncStart?.call();
    }
  }

  void _onOfflineMessageSyncFinish(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onOfflineMessageSyncFinish?.call();
    }
  }

  Future<void> _onMultiDeviceGroupEvent(Map map) async {
    MultiDevicesEvent event = convertIntToMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    List<String>? users = map.getList("users");

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onGroupEvent?.call(event, target, users);
    }
  }

  Future<void> _onMultiDeviceContactEvent(Map map) async {
    MultiDevicesEvent event = convertIntToMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    String? ext = map['ext'];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onContactEvent?.call(event, target, ext);
    }
  }

  Future<void> _onMultiDeviceThreadEvent(Map map) async {
    MultiDevicesEvent event = convertIntToMultiDevicesEvent(map['event'])!;
    String target = map['target'] ?? '';
    List<String> users = map.getList("users") ?? [];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onChatThreadEvent?.call(event, target, users);
    }
  }

  Future<void> _onMultiDeviceRoamMessagesRemovedEvent(Map map) async {
    String convId = map['convId'];
    String deviceId = map['deviceId'];
    for (var handler in _multiDeviceEventHandler.values) {
      handler.onRemoteMessagesRemoved?.call(convId, deviceId);
    }
  }

  Future<void> _onMultiDevicesConversationEvent(Map map) async {
    MultiDevicesEvent event = convertIntToMultiDevicesEvent(map['event'])!;
    String convId = map['convId'];
    ConversationType type = ConversationType.values[map['convType']];
    for (var handler in _multiDeviceEventHandler.values) {
      handler.onConversationEvent?.call(event, convId, type);
    }
  }

  void _onReceiveCustomData(Map map) {
    customEventHandler?.call(map);
  }

  /// ~english
  /// Gets the [ChatManager] class. Make sure to call it after Client has been initialized.
  ///
  /// **Return** The `ChatManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [ChatManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return**  `ChatManager` 类。
  /// ~end
  ChatManager get chatManager {
    return _chatManager;
  }

  /// ~english
  /// Gets the [ContactManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `ContactManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [ContactManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `ContactManager` 类。
  /// ~end
  ContactManager get contactManager {
    return _contactManager;
  }

  /// ~english
  /// Gets the [ChatRoomManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `ChatRoomManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [ChatRoomManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `ChatRoomManager` 类。
  /// ~end
  ChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  /// ~english
  /// Gets the [GroupManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `GroupManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [GroupManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `GroupManager` 类。
  /// ~end
  GroupManager get groupManager {
    return _groupManager;
  }

  /// ~english
  /// Gets the [PushManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `PushManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [PushManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `PushManager` 类。
  /// ~end
  PushManager get pushManager {
    return _pushManager;
  }

  /// ~english
  /// Gets the [UserInfoManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `UserInfoManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [UserInfoManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `UserInfoManager` 类。
  /// ~end
  UserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  /// ~english
  /// Gets the [ThreadManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `ThreadManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [ThreadManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `ThreadManager` 类。
  /// ~end
  ThreadManager get chatThreadManager {
    return _chatThreadManager;
  }

  /// ~english
  /// Gets the [PresenceManager] class. Make sure to call it after the Client has been initialized.
  ///
  /// **Return** The `PresenceManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [PresenceManager] 类。请确保在 Client 初始化之后调用本方法，详见 [Client.init]。
  ///
  /// **Return** `PresenceManager` 类。
  /// ~end
  PresenceManager get presenceManager {
    return _presenceManager;
  }

  void _clearAllInfo() {
    _currentUserId = null;
    _userInfoManager.clearUserInfoCache();
  }

  // 481

  /// ~english
  /// Whether only HTTPS is used for REST operations.
  ///
  /// Param [usingHttpsOnly] Whether only HTTPS is used.
  /// ~end
  ///
  /// ~chinese
  /// 是否只用 HTTPS。
  ///
  /// Param [usingHttpsOnly] 是否只用 HTTPS。
  /// ~end
  Future<void> updateUsingHttpsOnlySetting(bool usingHttpsOnly) async {
    Map req = {'usingHttpsOnly': usingHttpsOnly};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateUsingHttpsOnlySetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(usingHttpsOnly: usingHttpsOnly);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  ///
  Future<void> updateLoginExtensionInfoSetting(String extension) async {
    Map req = {'extension': extension};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateLoginExtensionInfo, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(loginExtension: extension);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateDeleteMessagesWhenLeaveGroupSetting(
      bool deleteMessagesWhenLeaveGroup) async {
    Map req = {'deleteMessagesWhenLeaveGroup': deleteMessagesWhenLeaveGroup};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessagesWhenLeaveGroupSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessagesWhenLeaveGroup: deleteMessagesWhenLeaveGroup);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateDeleteMessageWhenLeaveRoomSetting(
      bool deleteMessageWhenLeaveRoom) async {
    Map req = {'deleteMessageWhenLeaveRoom': deleteMessageWhenLeaveRoom};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessageWhenLeaveRoomSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessageWhenLeaveRoom: deleteMessageWhenLeaveRoom);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateRoomOwnerCanLeaveSetting(bool roomOwnerCanLeave) async {
    Map req = {'roomOwnerCanLeave': roomOwnerCanLeave};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRoomOwnerCanLeaveSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(roomOwnerCanLeave: roomOwnerCanLeave);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoAcceptGroupInvitationSetting(
      bool autoAcceptGroupInvitation) async {
    Map req = {'autoAcceptGroupInvitation': autoAcceptGroupInvitation};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoAcceptGroupInvitationSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(
          autoAcceptGroupInvitation: autoAcceptGroupInvitation);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoAcceptFriendInvitationSetting(
      bool acceptInvitationAlways) async {
    Map req = {'acceptInvitationAlways': acceptInvitationAlways};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAcceptInvitationAlways, req);
    try {
      Error.hasErrorFromResult(result);
      _options =
          _options?.copyWith(acceptInvitationAlways: acceptInvitationAlways);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoDownloadAttachmentThumbnailSetting(
      bool autoDownloadThumbnail) async {
    Map req = {'autoDownloadThumbnail': autoDownloadThumbnail};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoDownloadAttachmentThumbnailSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options =
          _options?.copyWith(autoDownloadThumbnail: autoDownloadThumbnail);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateRequireAckSetting(bool requireAck) async {
    Map req = {'requireAck': requireAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRequireAckSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(requireAck: requireAck);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateDeliveryAckSetting(bool requireDeliveryAck) async {
    Map req = {'requireDeliveryAck': requireDeliveryAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeliveryAckSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(requireDeliveryAck: requireDeliveryAck);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateSortMessageByServerTimeSetting(
      bool sortMessageByServerTime) async {
    Map req = {'sortMessageByServerTime': sortMessageByServerTime};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateSortMessageByServerTimeSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options =
          _options?.copyWith(sortMessageByServerTime: sortMessageByServerTime);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateMessagesReceiveCallbackIncludeSendSetting(
      bool includeSend) async {
    Map req = {'includeSend': includeSend};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateMessagesReceiveCallbackIncludeSendSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options =
          _options?.copyWith(messagesReceiveCallbackIncludeSend: includeSend);
    } on Error catch (e) {
      throw e;
    }
  }

  Future<void> updateRegradeMessagesAsReadSetting(bool isRead) async {
    Map req = {'isRead': isRead};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRegradeMessagesSetting, req);
    try {
      Error.hasErrorFromResult(result);
      _options = _options?.copyWith(regardImportMessagesAsRead: isRead);
    } on Error catch (e) {
      throw e;
    }
  }
}
