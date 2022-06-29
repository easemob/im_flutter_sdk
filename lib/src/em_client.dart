import 'dart:async';

import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// 该类是 Chat SDK 的入口，负责登录、退出及连接管理等，由此可以获得其他模块的入口。
///
class EMClient {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel =
      const MethodChannel('$_channelPrefix/chat_client', JSONMethodCodec());
  static EMClient? _instance;
  final EMChatManager _chatManager = EMChatManager();
  final EMContactManager _contactManager = EMContactManager();
  final EMChatRoomManager _chatRoomManager = EMChatRoomManager();
  final EMGroupManager _groupManager = EMGroupManager();
  final EMPushManager _pushManager = EMPushManager();
  final EMUserInfoManager _userInfoManager = EMUserInfoManager();

  final EMPresenceManager _presenceManager = EMPresenceManager();
  final EMChatThreadManager _chatThreadManager = EMChatThreadManager();
  final List<EMConnectionListener> _connectionListeners = [];
  final List<EMMultiDeviceListener> _multiDeviceListeners = [];
  final List<EMCustomListener> _customListeners = [];
  // ignore: unused_field
  EMProgressManager? _progressManager;

  EMOptions? _options;

  /// 通过 [EMOptions] 获取配置信息。
  EMOptions? get options => _options;

  String? _currentUsername;

  /// 获取当前登录用户的用户 ID。
  String? get currentUsername => _currentUsername;

  static EMClient get getInstance => _instance ??= EMClient._internal();

  EMClient._internal() {
    _progressManager = EMProgressManager();
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onConnected) {
        return _onConnected();
      } else if (call.method == ChatMethodKeys.onDisconnected) {
        return _onDisconnected();
      } else if (call.method == ChatMethodKeys.onUserDidLoginFromOtherDevice) {
        _onUserDidLoginFromOtherDevice();
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
      } else if (call.method == ChatMethodKeys.onSendDataToFlutter) {
        _onReceiveCustomData(argMap!);
      } else if (call.method == ChatMethodKeys.onTokenWillExpire) {
        _onTokenWillExpire(argMap);
      } else if (call.method == ChatMethodKeys.onTokenDidExpire) {
        _onTokenDidExpire(argMap);
      }
    });
  }

  ///
  /// 启动回调。该方法用于启动通讯录，群组，聊天室的回调。
  ///
  /// app 启动后，界面准备好后需要调用该方法，调用后 `EMContactManagerListener`、`EMGroupManagerListener` 和 `EMChatRoomManagerListener` 才会开始执行。
  ///
  Future<void> startCallback() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.startCallback);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 检查 SDK 是否连接到 Chat 服务器。
  /// **Return** SDK 是否连接到 Chat 服务器。
  /// - `true`：是；
  /// - `false`：否。
  ///
  Future<bool> isConnected() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.isConnected);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isConnected);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 检查用户是否已登录 Chat 服务。
  ///
  /// **Return** 用户是否已经登录 Chat 服务。
  ///   - `true`：是；
  ///   - `false`：否。
  ///
  Future<bool> isLoginBefore() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.isLoggedInBefore);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isLoggedInBefore);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取当前登录的用户 ID。
  ///
  /// **Return** 当前登录的用户 ID。
  ///
  Future<String?> getCurrentUsername() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getCurrentUser);
    try {
      EMError.hasErrorFromResult(result);
      _currentUsername = result[ChatMethodKeys.getCurrentUser];
      if (_currentUsername != null) {
        if (_currentUsername!.length == 0) {
          _currentUsername = null;
        }
      }
      return _currentUsername;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取当前登录账号的 Token。
  ///
  /// **Return** 当前登录账号的 Token。
  ///
  Future<String> getAccessToken() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getToken);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getToken];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 初始化 SDK。
  ///
  /// Param [options] 配置，不可为空。
  ///
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
    await _channel.invokeMethod(ChatMethodKeys.init, options.toJson());
    _currentUsername = await getCurrentUsername();
  }

  ///
  /// 创建账号。
  ///
  /// Param [username] 用户 ID，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。请确保同一个 app 下，username 唯一；`username` 用户 ID 是会公开的信息，请勿使用 UUID、邮箱地址、手机号等敏感信息。
  /// Param [password] 密码，长度不超过 64 个字符。请确保你对该参数设值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> createAccount(
    String username,
    String password,
  ) async {
    EMLog.v('create account: $username : $password');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(ChatMethodKeys.createAccount, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 使用密码或 Token 登录服务器。
  ///
  /// Param [username] 用户 ID。
  ///
  /// Param [pwdOrToken] 登录密码或 Token。
  ///
  /// Param [isPassword] 是否用密码登录。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> login(String username, String pwdOrToken,
      [bool isPassword = true]) async {
    EMLog.v('login: $username : $pwdOrToken, isPassword: $isPassword');
    Map req = {
      'username': username,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await _channel.invokeMethod(ChatMethodKeys.login, req);
    try {
      EMError.hasErrorFromResult(result);
      _currentUsername = username;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 用声网 Token 登录服务器，该方法支持自动登录。
  ///
  /// **Note**
  /// 通过 token 登录服务器的方法见 {@link #login(String, String, bool)}。
  ///
  /// Param [username] 用户 ID。
  ///
  /// Param [agoraToken] 声网 Token。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> loginWithAgoraToken(String username, String agoraToken) async {
    Map req = {
      "username": username,
      "agora_token": agoraToken,
    };

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.loginWithAgoraToken, req);
    try {
      EMError.hasErrorFromResult(result);
      _currentUsername = username;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 当用户在声网 token 登录状态时，且在 {@link EMConnectionListener} 实现类中收到 token 即将过期事件的回调通知可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
  ///
  /// Param [agoraToken] 新声网 Token.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> renewAgoraToken(String agoraToken) async {
    Map req = {"agora_token": agoraToken};

    Map result = await _channel.invokeMethod(ChatMethodKeys.renewToken, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 退出登录。
  ///
  /// Param [unbindDeviceToken] 退出时是否解绑设备 token。
  /// - （默认）`true`：是。
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> logout([
    bool unbindDeviceToken = true,
  ]) async {
    EMLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await _channel.invokeMethod(ChatMethodKeys.logout, req);
    try {
      EMError.hasErrorFromResult(result);
      _clearAllInfo();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 修改 App Key。
  ///
  /// @note
  /// 只有在未登录状态才能修改 App Key。
  ///
  /// Param [newAppKey] App Key，请确保设置该参数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<bool> changeAppKey({required String newAppKey}) async {
    EMLog.v('changeAppKey: $newAppKey');
    Map req = {'appKey': newAppKey};
    Map result = await _channel.invokeMethod(ChatMethodKeys.changeAppKey, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.changeAppKey);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 压缩 log 文件，并返回压缩后的文件路径。强烈建议方法完成之后删除该压缩文件。
  ///
  /// **Return** 压缩后的 log 文件路径。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<String> compressLogs() async {
    EMLog.v('compressLogs:');
    Map result = await _channel.invokeMethod(ChatMethodKeys.compressLogs);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.compressLogs];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取指定账号下登录的在线设备列表。
  ///
  /// Param [username] 用户 ID。
  ///
  /// Param [password] 密码。
  ///
  /// **Return**  获取到到设备列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<List<EMDeviceInfo>> getLoggedInDevicesFromServer(
      {required String username, required String password}) async {
    EMLog.v('getLoggedInDevicesFromServer: $username, "******"');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(
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

  ///
  /// 在指定账号下，根据设备 ID，将指定设备下线，设备 ID：{@link EMDeviceInfo#resource}。
  ///
  /// Param [username] 用户 ID。
  ///
  /// Param [password] 密码。
  ///
  /// Param [resource] 设备 ID，详见 {@link EMDeviceInfo#resource}。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<bool> kickDevice(
      {required String username,
      required String password,
      required String resource}) async {
    EMLog.v('kickDevice: $username, "******"');
    Map req = {
      'username': username,
      'password': password,
      'resource': resource
    };
    Map result = await _channel.invokeMethod(ChatMethodKeys.kickDevice, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.kickDevice);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将指定用户 ID 下的所有设备都踢下线。
  ///
  /// Param [username] 用户 ID。
  ///
  /// Param [password] 密码。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<void> kickAllDevices(
      {required String username, required String password}) async {
    EMLog.v('kickAllDevices: $username, "******"');
    Map req = {'username': username, 'password': password};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.kickAllDevices, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /* Listeners*/

  ///
  /// 设置多设备监听。
  ///
  /// Param [listener] 要设置的监听器，详见 {EMMultiDeviceListener}。
  ///
  void addMultiDeviceListener(EMMultiDeviceListener listener) {
    _multiDeviceListeners.add(listener);
  }

  ///
  /// 移除多设备监听。
  ///
  /// Param [listener] 要移除的监听，详见 {EMMultiDeviceListener}。
  ///
  void removeMultiDeviceListener(EMMultiDeviceListener listener) {
    if (_multiDeviceListeners.contains(listener)) {
      _multiDeviceListeners.remove(listener);
    }
  }

  ///
  /// 移除所有多设备监听。
  ///
  void clearAllMultiDeviceListeners() {
    _multiDeviceListeners.clear();
  }

  ///
  /// 设置 Chat 服务器连接监听。
  ///
  /// Param [listener] 要设置的 Chat 服务器连接监听。
  ///
  void addConnectionListener(EMConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  ///
  /// 移除 Chat 服务器连接监听。
  ///
  /// Param [listener]  要移除的 Chat 服务器连接监听。
  ///
  void removeConnectionListener(EMConnectionListener listener) {
    if (_connectionListeners.contains(listener)) {
      _connectionListeners.remove(listener);
    }
  }

  ///
  /// 移除所有 Chat 服务器连接监听。
  ///
  void clearAllConnectionListeners() {
    _connectionListeners.clear();
  }

  ///
  /// 设置自定义监听，接收安卓或者 iOS 设备发到 flutter 层的数据。
  ///
  /// Param [listener] 要设置的自定义监听器。
  ///
  void addCustomListener(EMCustomListener listener) {
    _customListeners.add(listener);
  }

  ///
  /// 移除自定义监听器。
  ///
  /// Param [listener] 要移除的自定义监听器。
  ///
  void removeCustomListener(EMCustomListener listener) {
    if (_customListeners.contains(listener)) {
      _customListeners.remove(listener);
    }
  }

  ///
  /// 移除所有自定义监听器。
  ///
  void clearAllCustomListeners() {
    _customListeners.clear();
  }

  Future<void> _onConnected() async {
    for (var listener in _connectionListeners) {
      listener.onConnected();
    }
  }

  Future<void> _onDisconnected() async {
    for (var listener in _connectionListeners) {
      listener.onDisconnected();
    }
  }

  Future<void> _onUserDidLoginFromOtherDevice() async {
    for (var listener in _connectionListeners) {
      listener.onUserDidLoginFromOtherDevice();
    }
  }

  Future<void> _onUserDidRemoveFromServer() async {
    for (var listener in _connectionListeners) {
      listener.onUserDidRemoveFromServer();
    }
  }

  Future<void> _onUserDidForbidByServer() async {
    for (var listener in _connectionListeners) {
      listener.onUserDidForbidByServer();
    }
  }

  Future<void> _onUserDidChangePassword() async {
    for (var listener in _connectionListeners) {
      listener.onUserDidChangePassword();
    }
  }

  Future<void> _onUserDidLoginTooManyDevice() async {
    for (var listener in _connectionListeners) {
      listener.onUserDidLoginTooManyDevice();
    }
  }

  Future<void> _onUserKickedByOtherDevice() async {
    for (var listener in _connectionListeners) {
      listener.onUserKickedByOtherDevice();
    }
  }

  Future<void> _onUserAuthenticationFailed() async {
    for (var listener in _connectionListeners) {
      listener.onDisconnected();
    }
  }

  Future<void> _onMultiDeviceGroupEvent(Map map) async {
    for (var listener in _multiDeviceListeners) {
      listener.onGroupEvent(
        convertIntToEMMultiDevicesEvent(map['event'])!,
        map['target'],
        map['users'],
      );
    }
  }

  Future<void> _onMultiDeviceContactEvent(Map map) async {
    for (var listener in _multiDeviceListeners) {
      listener.onContactEvent(
        convertIntToEMMultiDevicesEvent(map['event'])!,
        map['target'],
        map['ext'],
      );
    }
  }

  Future<void> _onMultiDeviceThreadEvent(Map map) async {
    for (var listener in _multiDeviceListeners) {
      listener.onChatThreadEvent(
        convertIntToEMMultiDevicesEvent(map['event'])!,
        map['target'],
        map['users'],
      );
    }
  }

  void _onReceiveCustomData(Map map) {
    for (var listener in _customListeners) {
      listener.onDataReceived(map);
    }
  }

  void _onTokenWillExpire(Map? map) {
    for (EMConnectionListener listener in _connectionListeners) {
      listener.onTokenWillExpire();
    }
  }

  void _onTokenDidExpire(Map? map) {
    for (EMConnectionListener listener in _connectionListeners) {
      listener.onTokenDidExpire();
    }
  }

  ///
  /// 获取 `EMChatManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return**  `EMChatManager` 类。
  ///
  EMChatManager get chatManager {
    return _chatManager;
  }

  ///
  /// 获取 `EMContactManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMContactManager` 类。
  ///
  EMContactManager get contactManager {
    return _contactManager;
  }

  ///
  /// 获取 `EMChatRoomManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMChatRoomManager` 类。
  ///
  EMChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  ///
  /// 获取 `EMGroupManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMGroupManager` 类。
  ///
  EMGroupManager get groupManager {
    return _groupManager;
  }

  ///
  /// 获取 `EMPushManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMPushManager` 类。
  ///
  EMPushManager get pushManager {
    return _pushManager;
  }

  ///
  /// 获取 `EMUserInfoManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMUserInfoManager` 类。
  ///
  EMUserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  ///
  /// 获取 `EMChatThreadManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMChatThreadManager` 类。
  ///
  EMChatThreadManager get chatThreadManager {
    return _chatThreadManager;
  }

  ///
  /// 获取 `EMPresenceManager` 类。请确保在 EMClient 初始化之后调用本方法，详见 {@link EMClient#init(EMOptions)}。
  ///
  /// **Return** `EMPresenceManager` 类。
  ///
  EMPresenceManager get presenceManager {
    return _presenceManager;
  }

  void _clearAllInfo() {
    _currentUsername = null;
    _userInfoManager.clearUserInfoCache();
  }
}
