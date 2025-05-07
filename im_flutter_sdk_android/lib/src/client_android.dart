import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';
import 'package:im_flutter_sdk_android/src/chat_manager_android.dart';
import 'package:im_flutter_sdk_android/src/chat_room_manager_android.dart';
import 'package:im_flutter_sdk_android/src/chat_thread_manager_android.dart';
import 'package:im_flutter_sdk_android/src/contact_manager_android.dart';
import 'package:im_flutter_sdk_android/src/group_manager_android.dart';
import 'package:im_flutter_sdk_android/src/presence_manager_android.dart';
import 'package:im_flutter_sdk_android/src/push_manager_android.dart';
import 'package:im_flutter_sdk_android/src/user_info_manager_android.dart';

class ClientAndroid extends Client {
  static void registerWith() {
    Client.instance = ClientAndroid();
  }

  ClientAndroid() : super();

  final ChatManager _chatManager = ChatManagerAndroid();
  final ChatRoomManager _chatRoomManager = ChatRoomManagerAndroid();
  final ChatThreadManager _chatThreadManager = ChatThreadManagerAndroid();
  final ContactManager _contactManager = ContactManagerAndroid();
  final GroupManager _groupManager = GroupManagerAndroid();
  final PresenceManager _presenceManager = PresenceManagerAndroid();
  final PushManager _pushManager = PushManagerAndroid();
  final UserInfoManager _userInfoManager = UserInfoManagerAndroid();
  // ignore: unused_field
  ProgressManager? _progressManager;

  @override
  ChatManager get chatManager => _chatManager;

  @override
  ChatRoomManager get chatRoomManager => _chatRoomManager;

  @override
  ChatThreadManager get chatThreadManager => _chatThreadManager;

  @override
  ContactManager get contactManager => _contactManager;

  @override
  GroupManager get groupManager => _groupManager;

  @override
  PresenceManager get presenceManager => _presenceManager;

  @override
  PushManager get pushManager => _pushManager;

  @override
  UserInfoManager get userInfoManager => _userInfoManager;

  EMOptions? _options;
  String? _currentUserId;

  @override
  EMOptions? get options => _options;

  @override
  String? get currentUserId => _currentUserId;

  void _clearAllInfo() {
    _currentUserId = null;
    _userInfoManager.clearUserInfoCache();
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
  @override
  Future<void> startCallback() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.startCallback);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<bool> isConnected() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.isConnected);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<bool> isLoginBefore() async {
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.isLoggedInBefore);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<String?> getCurrentUserId() async {
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.getCurrentUser);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<String> getAccessToken() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.getToken);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getToken];
    } catch (e) {
      rethrow;
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
  @override
  Future<void> init(EMOptions options) async {
    _updataHandler();
    _options = options;
    EMLog.v('init: $options');
    await ClientChannel.invokeMethod(ChatMethodKeys.init, options.toJson());
    _currentUserId = await getCurrentUserId();
  }

  _updataHandler() {
    initHandler();
    chatManager.initHandler();
    chatRoomManager.initHandler();
    chatThreadManager.initHandler();
    contactManager.initHandler();
    groupManager.initHandler();
    presenceManager.initHandler();
    presenceManager.initHandler();
    pushManager.initHandler();
    userInfoManager.initHandler();
    _progressManager?.initHandler();
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
  @override
  Future<void> createAccount(String userId, String password) async {
    EMLog.v('create account: $userId : $password');
    Map req = {'userId': userId, 'password': password};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.createAccount, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      'userId': userId,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.login, req);
    try {
      EMError.hasErrorFromResult(result);
      _currentUserId = userId;
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  @override
  Future<void> loginWithToken(
    String userId,
    String token,
  ) async {
    // ignore: deprecated_member_use_from_same_package
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
  @override
  Future<void> loginWithPassword(
    String userId,
    String password,
  ) async {
    // ignore: deprecated_member_use_from_same_package
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
  @override
  Future<void> renewAgoraToken(String agoraToken) async {
    Map req = {"agora_token": agoraToken};

    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.renewToken, req);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<void> logout([
    bool unbindDeviceToken = true,
  ]) async {
    EMLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.logout, req);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<bool> changeAppKey({required String newAppKey}) async {
    EMLog.v('changeAppKey: $newAppKey');
    Map req = {'appKey': newAppKey};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppKey, req);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<bool> changeAppId({required String newAppId}) async {
    EMLog.v('newAppId: $newAppId');
    Map req = {'appId': newAppId};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.changeAppId, req);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<String> compressLogs() async {
    EMLog.v('compressLogs:');
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.compressLogs);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.compressLogs];
    } catch (e) {
      rethrow;
    }
  }

  @override
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
    Map req = {'userId': userId, 'password': password};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(EMDeviceInfo.fromJson(info));
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
  @override
  Future<List<EMDeviceInfo>> fetchLoggedInDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    Map req = {'userId': userId, 'password': pwdOrToken, 'isPwd': isPwd};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.getLoggedInDevicesFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMDeviceInfo> list = [];
      result[ChatMethodKeys.getLoggedInDevicesFromServer]?.forEach((info) {
        list.add(EMDeviceInfo.fromJson(info));
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
  @override
  Future<void> kickDevice({
    required String userId,
    required String pwdOrToken,
    required String resource,
    bool isPwd = true,
  }) async {
    EMLog.v('kickDevice: $userId, "******"');
    Map req = {
      'userId': userId,
      'password': pwdOrToken,
      'resource': resource,
      'isPwd': isPwd,
    };
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickDevice, req);
    try {
      EMError.hasErrorFromResult(result);
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
  @override
  Future<void> kickAllDevices({
    required String userId,
    required String pwdOrToken,
    bool isPwd = true,
  }) async {
    Map req = {'userId': userId, 'password': pwdOrToken, 'isPwd': isPwd};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickAllDevices, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

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
  @override
  Future<void> updateUsingHttpsOnlySetting(bool usingHttpsOnly) async {
    Map req = {'usingHttpsOnly': usingHttpsOnly};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateUsingHttpsOnlySetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(usingHttpsOnly: usingHttpsOnly);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  ///
  @override
  Future<void> updateLoginExtensionInfoSetting(String extension) async {
    Map req = {'extension': extension};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateLoginExtensionInfo, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(loginExtension: extension);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeleteMessagesWhenLeaveGroupSetting(
      bool deleteMessagesWhenLeaveGroup) async {
    Map req = {'deleteMessagesWhenLeaveGroup': deleteMessagesWhenLeaveGroup};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessagesWhenLeaveGroupSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessagesWhenLeaveGroup: deleteMessagesWhenLeaveGroup);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeleteMessageWhenLeaveRoomSetting(
      bool deleteMessageWhenLeaveRoom) async {
    Map req = {'deleteMessageWhenLeaveRoom': deleteMessageWhenLeaveRoom};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeleteMessageWhenLeaveRoomSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          deleteMessageWhenLeaveRoom: deleteMessageWhenLeaveRoom);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRoomOwnerCanLeaveSetting(bool roomOwnerCanLeave) async {
    Map req = {'roomOwnerCanLeave': roomOwnerCanLeave};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRoomOwnerCanLeaveSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(roomOwnerCanLeave: roomOwnerCanLeave);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAutoAcceptGroupInvitationSetting(
      bool autoAcceptGroupInvitation) async {
    Map req = {'autoAcceptGroupInvitation': autoAcceptGroupInvitation};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoAcceptGroupInvitationSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(
          autoAcceptGroupInvitation: autoAcceptGroupInvitation);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAutoAcceptFriendInvitationSetting(
      bool acceptInvitationAlways) async {
    Map req = {'acceptInvitationAlways': acceptInvitationAlways};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAcceptInvitationAlways, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(acceptInvitationAlways: acceptInvitationAlways);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAutoDownloadAttachmentThumbnailSetting(
      bool autoDownloadThumbnail) async {
    Map req = {'autoDownloadThumbnail': autoDownloadThumbnail};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateAutoDownloadAttachmentThumbnailSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(autoDownloadThumbnail: autoDownloadThumbnail);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRequireAckSetting(bool requireAck) async {
    Map req = {'requireAck': requireAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRequireAckSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireAck: requireAck);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeliveryAckSetting(bool requireDeliveryAck) async {
    Map req = {'requireDeliveryAck': requireDeliveryAck};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateDeliveryAckSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(requireDeliveryAck: requireDeliveryAck);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSortMessageByServerTimeSetting(
      bool sortMessageByServerTime) async {
    Map req = {'sortMessageByServerTime': sortMessageByServerTime};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateSortMessageByServerTimeSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(sortMessageByServerTime: sortMessageByServerTime);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMessagesReceiveCallbackIncludeSendSetting(
      bool includeSend) async {
    Map req = {'includeSend': includeSend};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateMessagesReceiveCallbackIncludeSendSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options =
          _options?.copyWith(messagesReceiveCallbackIncludeSend: includeSend);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRegradeMessagesAsReadSetting(bool isRead) async {
    Map req = {'isRead': isRead};
    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.updateRegradeMessagesSetting, req);
    try {
      EMError.hasErrorFromResult(result);
      _options = _options?.copyWith(regardImportMessagesAsRead: isRead);
    } catch (e) {
      rethrow;
    }
  }
}
