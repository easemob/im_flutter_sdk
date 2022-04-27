import 'dart:async';

import 'package:flutter/services.dart';

import 'internal/em_transform_tools.dart';
import 'tools/em_extension.dart';
import '../im_flutter_sdk.dart';
import 'internal/chat_method_keys.dart';
import 'tools/em_log.dart';

///
/// The EMClient class, which is the entry point of the Chat SDK. With this class, you can log in, log out, and access other functionalities such as group and chatroom.
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
  final List<EMConnectionListener> _connectionListeners = [];
  final List<EMMultiDeviceListener> _multiDeviceListeners = [];
  final List<EMCustomListener> _customListeners = [];

  EMOptions? _options;

  /// Gets the configurations.
  EMOptions? get options => _options;

  String? _currentUsername;

  /// Gets the current logged-in username.
  String? get currentUsername => _currentUsername;

  static EMClient get getInstance =>
      _instance = _instance ?? EMClient._internal();

  EMClient._internal() {
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
      } else if (call.method == ChatMethodKeys.onMultiDeviceEvent) {
        _onMultiDeviceEvent(argMap!);
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
  /// Start contact and group, chatroom callback.
  ///
  /// Reference:
  /// Call this method when you ui is ready, then will receive `EMChatRoomEventListener`, `EMContactManagerListener`, `EMGroupEventListener` callback.
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
  /// Checks whether the SDK is connected to the chat server.
  ///
  /// **Return** the result whether the SDK is connected to the chat server.
  /// `true`: means that the SDK is connected to the chat server.
  /// `false`: means not.
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
  /// Checks whether the user has logged in before and did not log out.
  ///
  /// Reference:
  /// If you need to check whether the SDK is connected to the server, please use {@link #isConnected()}.
  ///
  /// **Return** The result of whether the user has logged in before.
  /// `true`: means that the user has logged in before,
  /// `false`: means that the user has not login before or has called {@link #logout()} method.
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
  /// Gets the current login user ID.
  ///
  /// **Return** The current login user ID.
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

  /// Gets the token of the current logged-in user.
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
  /// Initializes the SDK.
  ///
  /// Param [options] The configurations: {@link EMOptions}. Ensure that you set this parameter.
  ///
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
    await _channel.invokeMethod(ChatMethodKeys.init, options.toJson());
    _currentUsername = await getCurrentUsername();
  }

  ///
  /// Register a new user.
  ///
  /// Param [username] The username. The maximum length is 64 characters. Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-),
  /// and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones.
  /// If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [password] The password. The maximum length is 64 characters. Ensure that you set this parameter.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> createAccount(String username, String password) async {
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
  /// An app user logs in to the chat server with a password or token.
  ///
  /// Param [username] The username.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [isPassword] Whether to log in with password or token.
  /// `true`: (default) Log in with password.
  /// `false`: Log in with token.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// An app user logs in to the chat server by username and Agora token. This method supports automatic login.
  ///
  /// See also: Another method to login to chat server is to login with user ID and token, see {@link #login(String, String, bool)}.
  ///
  /// Param [username] The username.
  ///
  /// Param [agoraToken] The Agora token.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> loginWithAgoraToken(String username, String agoraToken) async {
    Map req = {
      "username": username,
      "agoratoken": agoraToken,
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
  /// Renews the Agora token.
  ///
  /// If a user is logged in with an Agora token, when the token expires, you need to call this method to update the token.
  ///
  /// Param [agoraToken] The new Agora token.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// An app user logs out.
  ///
  /// Param [unbindDeviceToken] Whether to unbind the token when logout.
  ///
  /// `true` (default) Yes.
  /// `false` No.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Updates the App Key, which is the unique identifier to access Agora Chat.
  ///
  /// You can retrieve the new App Key from Agora Console.
  ///
  /// As this key controls all access to Agora Chat for your app, you can only update the key when the current user is logged out.
  ///
  /// Param [newAppKey] The App Key. Ensure that you set this parameter.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Compresses the debug log into a gzip archive.
  ///
  /// Best practice is to delete this debug archive as soon as it is no longer used.
  ///
  /// **Return** The path of the compressed gzip file.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets all the information about the logged in devices under the specified account.
  ///
  /// Param [username] The username you want to get the device information.
  ///
  /// Param [password] The password.
  ///
  /// **Return** TThe list of the logged-in devices.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Forces the specified account to log out from the specified device.
  ///
  /// Param [username] The account you want to force logout.
  ///
  /// Param [password] The account's password.
  ///
  /// Param [resource] The device ID. For how to fetch the device ID, ee {@link EMDeviceInfo#resource}.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Kicks out all the devices logged in under the specified account.
  ///
  /// Param [username] The account you want to log out from all the devices.
  ///
  /// Param [password] The password.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Adds the multi-device listener.
  ///
  /// Param [listener] The listener to be added: {EMMultiDeviceListener}.
  ///
  void addMultiDeviceListener(EMMultiDeviceListener listener) {
    _multiDeviceListeners.add(listener);
  }

  ///
  /// Removes the multi-device listener.
  ///
  /// Param [listener] The listener to be removed: {EMMultiDeviceListener}.
  ///
  void removeMultiDeviceListener(EMMultiDeviceListener listener) {
    if (_multiDeviceListeners.contains(listener)) {
      _multiDeviceListeners.remove(listener);
    }
  }

  ///
  /// Adds the connection listener of chat server.
  ///
  /// Param [listener] The chat server connection listener to be added.
  ///
  void addConnectionListener(EMConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  ///
  /// Removes the chat server connection listener.
  ///
  /// Param [listener]  The chat server connection listener to be removed.
  ///
  void removeConnectionListener(EMConnectionListener listener) {
    if (_connectionListeners.contains(listener)) {
      _connectionListeners.remove(listener);
    }
  }

  ///
  /// Adds a custom listener to receive data from iOS or Android devices.
  ///
  /// Param [listener] The custom native listener to be added.
  ///
  void addCustomListener(EMCustomListener listener) {
    _customListeners.add(listener);
  }

  ///
  /// Removes the custom listener.
  ///
  /// Param [listener] The custom native listener.
  ///
  void removeCustomListener(EMCustomListener listener) {
    if (_customListeners.contains(listener)) {
      _customListeners.remove(listener);
    }
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

  Future<void> _onMultiDeviceEvent(Map map) async {
    var event = map['event'];
    for (var listener in _multiDeviceListeners) {
      if (event >= 10) {
        listener.onGroupEvent(
          convertIntToEMContactGroupEvent(event)!,
          map['target'],
          map['userNames'],
        );
      } else {
        listener.onContactEvent(
          convertIntToEMContactGroupEvent(event)!,
          map['target'],
          map['ext'],
        );
      }
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
  /// Gets the `EMChatManager` class. Make sure to call it after EMClient has been initialized.
  ///
  /// **Return** The `EMChatManager` class.
  ///
  EMChatManager get chatManager {
    return _chatManager;
  }

  ///
  /// Gets the `EMContactManager` class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMContactManager` class.
  ///
  EMContactManager get contactManager {
    return _contactManager;
  }

  ///
  /// Gets the `ChatRoomManager` class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMChatRoomManager` class.
  ///
  EMChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  ///
  /// Gets the `EMGroupManager` class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMGroupManager` class.
  ///
  EMGroupManager get groupManager {
    return _groupManager;
  }

  ///
  /// Gets the `EMPushManager` class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMPushManager` class.
  ///
  EMPushManager get pushManager {
    return _pushManager;
  }

  ///
  /// Gets the `EMUserInfoManager` class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMUserInfoManager` class.
  ///
  EMUserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  void _clearAllInfo() {
    _currentUsername = null;
    _userInfoManager.clearUserInfoCache();
  }
}
