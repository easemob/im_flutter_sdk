import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

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

  static EMClient get getInstance => _instance ??= EMClient._internal();
  EMClient._internal();

  final EMChatManager chatManager = EMChatManager();

  final EMGroupManager groupManager = EMGroupManager();

  final EMContactManager contactManager = EMContactManager();

  final EMChatRoomManager chatRoomManager = EMChatRoomManager();

  final EMPushManager pushManager = EMPushManager();

  final EMPresenceManager presenceManager = EMPresenceManager();

  final EMUserInfoManager userInfoManager = EMUserInfoManager();

  final EMChatThreadManager chatThreadManager = EMChatThreadManager();

  String? get currentUserId => Client.instance.currentUserId;

  EMOptions? get options => Client.instance.options;

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
    return Client.instance.addConnectionEventHandler(identifier, handler);
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
    return Client.instance.removeConnectionEventHandler(identifier);
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
    return Client.instance.getConnectionEventHandler(identifier);
  }

  /// ~english
  /// Clears all connection event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所以连接状态监听。
  /// ~end
  void clearConnectionEventHandlers() {
    return Client.instance.clearConnectionEventHandlers();
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
    return Client.instance.addMultiDeviceEventHandler(identifier, handler);
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
    return Client.instance.removeMultiDeviceEventHandler(identifier);
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
    return Client.instance.getMultiDeviceEventHandler(identifier);
  }

  /// ~english
  /// Clears all multi-device event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有多设备事件监听。
  /// ~end
  void clearMultiDeviceEventHandlers() {
    return Client.instance.clearMultiDeviceEventHandlers();
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
    return Client.instance.startCallback();
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
    return Client.instance.isConnected();
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
    return Client.instance.isLoginBefore();
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
    return Client.instance.getCurrentUserId();
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
    return Client.instance.getAccessToken();
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
    assert(
      options.appId?.isNotEmpty == true || options.appKey?.isNotEmpty == true,
      'appId and appKey cannot both be empty',
    );
    return Client.instance.init(options);
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
    return Client.instance.createAccount(userId, password);
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
    return Client.instance.login(userId, pwdOrToken, isPassword);
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
    return Client.instance.loginWithAgoraToken(userId, agoraToken);
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
    return Client.instance.loginWithToken(userId, token);
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
    return Client.instance.loginWithPassword(userId, password);
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
    return Client.instance.renewAgoraToken(agoraToken);
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
    return Client.instance.logout(unbindDeviceToken);
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
    return Client.instance.changeAppKey(newAppKey: newAppKey);
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
    return Client.instance.changeAppId(newAppId: newAppId);
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
    return Client.instance.compressLogs();
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
    return Client.instance.getLoggedInDevicesFromServer(
      userId: userId,
      password: password,
    );
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
    return Client.instance.fetchLoggedInDevices(
      userId: userId,
      pwdOrToken: pwdOrToken,
      isPwd: isPwd,
    );
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
    return Client.instance.kickDevice(
      userId: userId,
      pwdOrToken: pwdOrToken,
      resource: resource,
      isPwd: isPwd,
    );
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
    return Client.instance.kickAllDevices(
      userId: userId,
      pwdOrToken: pwdOrToken,
      isPwd: isPwd,
    );
  }
}
