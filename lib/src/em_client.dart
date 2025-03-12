// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

/// ~english
/// The EMClient class, which is the entry point of the Chat SDK.
/// With this class, you can log in, log out, and access other functionalities such as group and chatroom.
/// ~end
///
/// ~chinese
/// 该类是 Chat SDK 的入口，负责登录、退出及连接管理等，由此可以获得其他模块的入口。
/// ~end
class EMClient {
  static EMClient? _instance;
  final EMChatManager _chatManager = EMChatManager();
  final EMContactManager _contactManager = EMContactManager();
  final EMChatRoomManager _chatRoomManager = EMChatRoomManager();
  final EMGroupManager _groupManager = EMGroupManager();
  final EMPushManager _pushManager = EMPushManager();
  final EMUserInfoManager _userInfoManager = EMUserInfoManager();

  final EMPresenceManager _presenceManager = EMPresenceManager();
  final EMChatThreadManager _chatThreadManager = EMChatThreadManager();

  final Map<String, EMConnectionEventHandler> _connectionEventHandler = {};
  final Map<String, EMMultiDeviceEventHandler> _multiDeviceEventHandler = {};

  // ignore: unused_field
  EMProgressManager? _progressManager;

  EMOptions? _options;

  /// ~english
  /// Gets the configurations.
  /// ~end
  ///
  /// ~chinese
  /// 获取配置信息。
  /// ~end
  EMOptions? get options => _options;

  String? _currentUserId;

  /// ~english
  /// Gets the SDK instance.
  /// ~end
  ///
  /// ~chinese
  /// 获取 SDK 实例。
  /// ~end
  static EMClient get getInstance => _instance ??= EMClient._internal();

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

  EMClient._internal() {
    _progressManager = EMProgressManager();
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    ClientChannel.setMethodCallHandler((MethodCall call) async {
      Map<String, dynamic>? argMap = call.arguments;
      EMLog.d("${call.method}: arguments: $argMap");
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
  /// Param [handler] The handler for connection event. See [EMConnectionEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加连接状态监听事件。
  ///
  /// Param [identifier] 监听事件对应 ID。
  ///
  /// Param [handler] 监听的事件。 请见 [EMConnectionEventHandler]。
  /// ~end
  void addConnectionEventHandler(
    String identifier,
    EMConnectionEventHandler handler,
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
  EMConnectionEventHandler? getConnectionEventHandler(String identifier) {
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
  /// Param [handler] The handler multi-device event. See [EMMultiDeviceEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加多设备事件监听。
  ///
  /// Param [identifier] 多设备事件监听对应 ID。
  ///
  /// Param [handler] 多设备事件监听。 请见 [EMMultiDeviceEventHandler]。
  /// ~end
  void addMultiDeviceEventHandler(
    String identifier,
    EMMultiDeviceEventHandler handler,
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
  EMMultiDeviceEventHandler? getMultiDeviceEventHandler(String identifier) {
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
  /// Call this method when you UI is ready, then will receive [EMChatRoomEventHandler], [EMContactEventHandler], [EMGroupEventHandler] event.
  /// ~end
  ///
  /// ~chinese
  /// /// 开始回调通知。
  ///
  /// 当UI准备好后调用，调用之后才能收到 [EMChatRoomEventHandler], [EMContactEventHandler], [EMGroupEventHandler] 监听。
  /// ~end
  Future<void> startCallback() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.startCallback);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
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
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isConnected);
    } on EMError catch (e) {
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
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isLoggedInBefore);
    } on EMError catch (e) {
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
      EMError.hasErrorFromResult(result);
      _currentUserId = result[ChatMethodKeys.getCurrentUser];
      if (_currentUserId != null) {
        if (_currentUserId!.length == 0) {
          _currentUserId = null;
        }
      }
      return _currentUserId;
    } on EMError catch (e) {
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
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getToken];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Initializes the SDK.
  ///
  /// Param [options] The configurations: [EMOptions]. Ensure that you set this parameter.
  /// ~end
  ///
  /// ~chinese
  /// 初始化 SDK。
  ///
  /// Param [options] 配置，不可为空。
  /// ~end
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 创建账号。
  ///
  /// Param [userId] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。请确保同一个 app 下，userId 唯一；`userId` 用户 ID 是会公开的信息，请勿使用 UUID、邮箱地址、手机号等敏感信息。
  ///
  /// Param [password] 密码，长度不超过 64 个字符。请确保你对该参数设值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> createAccount(String userId, String password) async {
    EMLog.v('create account: $userId : $password');
    Map req = {'username': userId, 'password': password};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.createAccount, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> login(
    String userId,
    String pwdOrToken, [
    bool isPassword = true,
  ]) async {
    EMLog.v('login: $userId : $pwdOrToken, isPassword: $isPassword');
    Map req = {
      'username': userId,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.login, req);
    try {
      EMError.hasErrorFromResult(result);
      _currentUserId = userId;
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> loginWithPassword(
    String userId,
    String password,
  ) async {
    return login(userId, password, true);
  }

  /// ~english
  /// Renews the Agora token.
  ///
  /// If a user is logged in with an Agora token, when the token expires, you need to call this method to update the token.
  ///
  /// Param [agoraToken] The new Agora token.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 当用户在声网 token 登录状态时，且在 [EMConnectionEventHandler.onTokenWillExpire] 实现类中收到 token 即将过期事件的回调通知可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
  ///
  /// Param [agoraToken] 新声网 Token.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> renewAgoraToken(String agoraToken) async {
    Map req = {"agora_token": agoraToken};

    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.renewToken, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 退出登录。
  ///
  /// Param [unbindDeviceToken] 退出时是否解绑设备 token。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> logout([
    bool unbindDeviceToken = true,
  ]) async {
    EMLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.logout, req);
    try {
      EMError.hasErrorFromResult(result);
      _clearAllInfo();
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<bool> changeAppKey({required String newAppKey}) async {
    EMLog.v('changeAppKey: $newAppKey');
    Map req = {'appKey': newAppKey};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppKey, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<bool> changeAppId({required String newAppId}) async {
    EMLog.v('newAppId: $newAppId');
    Map req = {'appId': newAppId};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppId, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 压缩 log 文件，并返回压缩后的文件路径。强烈建议方法完成之后删除该压缩文件。
  ///
  /// **Return** 压缩后的 log 文件路径。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<String> compressLogs() async {
    EMLog.v('compressLogs:');
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.compressLogs);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.compressLogs];
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMDeviceInfo>> getLoggedInDevicesFromServer(
      {required String userId, required String password}) async {
    Map req = {'username': userId, 'password': password};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(EMDeviceInfo.fromJson(info));
      });
      return list;
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMDeviceInfo>> fetchLoggedInDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    Map req = {'username': userId, 'password': pwdOrToken, 'isPwd': isPwd};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(EMDeviceInfo.fromJson(info));
      });
      return list;
    } on EMError catch (e) {
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
  /// Param [resource] The device ID. For how to fetch the device ID, See [EMDeviceInfo.resource].
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定账号登录的指定设备踢下线。
  ///
  /// Param [userId] 用户 ID。
  ///
  /// Param [pwdOrToken] 密码 / token。
  ///
  /// Param [resource] 设备 ID，详见 [EMDeviceInfo.resource]。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> kickDevice({
    required String userId,
    required String pwdOrToken,
    required String resource,
    bool isPwd = true,
  }) async {
    EMLog.v('kickDevice: $userId, "******"');
    Map req = {
      'username': userId,
      'password': pwdOrToken,
      'resource': resource,
      'isPwd': isPwd,
    };
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickDevice, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
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
  }

  Future<void> _onUserDidRemoveFromServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidRemoveFromServer?.call();
    }
  }

  Future<void> _onUserDidForbidByServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidForbidByServer?.call();
    }
  }

  Future<void> _onUserDidChangePassword() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidChangePassword?.call();
    }
  }

  Future<void> _onUserDidLoginTooManyDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidLoginTooManyDevice?.call();
    }
  }

  Future<void> _onUserKickedByOtherDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserKickedByOtherDevice?.call();
    }
  }

  Future<void> _onUserAuthenticationFailed() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onDisconnected?.call();
    }
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
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    List<String>? users = map.getList("users");

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onGroupEvent?.call(event, target, users);
    }
  }

  Future<void> _onMultiDeviceContactEvent(Map map) async {
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    String? ext = map['ext'];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onContactEvent?.call(event, target, ext);
    }
  }

  Future<void> _onMultiDeviceThreadEvent(Map map) async {
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
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
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String convId = map['convId'];
    EMConversationType type = EMConversationType.values[map['convType']];
    for (var handler in _multiDeviceEventHandler.values) {
      handler.onConversationEvent?.call(event, convId, type);
    }
  }

  void _onReceiveCustomData(Map map) {
    customEventHandler?.call(map);
  }

  /// ~english
  /// Gets the [EMChatManager] class. Make sure to call it after EMClient has been initialized.
  ///
  /// **Return** The `EMChatManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMChatManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return**  `EMChatManager` 类。
  /// ~end
  EMChatManager get chatManager {
    return _chatManager;
  }

  /// ~english
  /// Gets the [EMContactManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMContactManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMContactManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMContactManager` 类。
  /// ~end
  EMContactManager get contactManager {
    return _contactManager;
  }

  /// ~english
  /// Gets the [EMChatRoomManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMChatRoomManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMChatRoomManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMChatRoomManager` 类。
  /// ~end
  EMChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  /// ~english
  /// Gets the [EMGroupManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMGroupManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMGroupManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMGroupManager` 类。
  /// ~end
  EMGroupManager get groupManager {
    return _groupManager;
  }

  /// ~english
  /// Gets the [EMPushManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMPushManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMPushManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMPushManager` 类。
  /// ~end
  EMPushManager get pushManager {
    return _pushManager;
  }

  /// ~english
  /// Gets the [EMUserInfoManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMUserInfoManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMUserInfoManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMUserInfoManager` 类。
  /// ~end
  EMUserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  /// ~english
  /// Gets the [EMChatThreadManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMChatThreadManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMChatThreadManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMChatThreadManager` 类。
  /// ~end
  EMChatThreadManager get chatThreadManager {
    return _chatThreadManager;
  }

  /// ~english
  /// Gets the [EMPresenceManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMPresenceManager` class.
  /// ~end
  ///
  /// ~chinese
  /// 获取 [EMPresenceManager] 类。请确保在 EMClient 初始化之后调用本方法，详见 [EMClient.init]。
  ///
  /// **Return** `EMPresenceManager` 类。
  /// ~end
  EMPresenceManager get presenceManager {
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
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(usingHttpsOnly: usingHttpsOnly);
    } on EMError catch (e) {
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
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(loginExtension: extension);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateDeleteMessagesWhenLeaveGroupSetting(
      bool deleteMessagesWhenLeaveGroup) async {
    Map req = {'deleteMessagesWhenLeaveGroup': deleteMessagesWhenLeaveGroup};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessagesWhenLeaveGroupSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessagesWhenLeaveGroup: deleteMessagesWhenLeaveGroup);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateDeleteMessageWhenLeaveRoomSetting(
      bool deleteMessageWhenLeaveRoom) async {
    Map req = {'deleteMessageWhenLeaveRoom': deleteMessageWhenLeaveRoom};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessageWhenLeaveRoomSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessageWhenLeaveRoom: deleteMessageWhenLeaveRoom);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateRoomOwnerCanLeaveSetting(bool roomOwnerCanLeave) async {
    Map req = {'roomOwnerCanLeave': roomOwnerCanLeave};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRoomOwnerCanLeaveSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(roomOwnerCanLeave: roomOwnerCanLeave);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoAcceptGroupInvitationSetting(
      bool autoAcceptGroupInvitation) async {
    Map req = {'autoAcceptGroupInvitation': autoAcceptGroupInvitation};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoAcceptGroupInvitationSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          autoAcceptGroupInvitation: autoAcceptGroupInvitation);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoAcceptFriendInvitationSetting(
      bool acceptInvitationAlways) async {
    Map req = {'acceptInvitationAlways': acceptInvitationAlways};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAcceptInvitationAlways, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(acceptInvitationAlways: acceptInvitationAlways);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateAutoDownloadAttachmentThumbnailSetting(
      bool autoDownloadThumbnail) async {
    Map req = {'autoDownloadThumbnail': autoDownloadThumbnail};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoDownloadAttachmentThumbnailSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(autoDownloadThumbnail: autoDownloadThumbnail);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateRequireAckSetting(bool requireAck) async {
    Map req = {'requireAck': requireAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRequireAckSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireAck: requireAck);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateDeliveryAckSetting(bool requireDeliveryAck) async {
    Map req = {'requireDeliveryAck': requireDeliveryAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeliveryAckSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireDeliveryAck: requireDeliveryAck);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateSortMessageByServerTimeSetting(
      bool sortMessageByServerTime) async {
    Map req = {'sortMessageByServerTime': sortMessageByServerTime};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateSortMessageByServerTimeSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(sortMessageByServerTime: sortMessageByServerTime);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateMessagesReceiveCallbackIncludeSendSetting(
      bool includeSend) async {
    Map req = {'includeSend': includeSend};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateMessagesReceiveCallbackIncludeSendSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(messagesReceiveCallbackIncludeSend: includeSend);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> updateRegradeMessagesAsReadSetting(bool isRead) async {
    Map req = {'isRead': isRead};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRegradeMessagesSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(regardImportMessagesAsRead: isRead);
    } on EMError catch (e) {
      throw e;
    }
  }
}
