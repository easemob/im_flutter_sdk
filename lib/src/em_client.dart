// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'internal/inner_headers.dart';

///
/// The EMClient class, which is the entry point of the Chat SDK. With this class, you can log in, log out, and access other functionalities such as group and chatroom.
///
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

  final List<EMConnectionListener> _connectionListeners = [];
  final List<EMMultiDeviceListener> _multiDeviceListeners = [];
  @deprecated
  final List<EMCustomListener> _customListeners = [];
  // ignore: unused_field
  EMProgressManager? _progressManager;

  EMOptions? _options;

  /// Gets the configurations.
  EMOptions? get options => _options;

  String? _currentUserId;

  static EMClient get getInstance => _instance ??= EMClient._internal();

  ///
  /// Set a custom event handle to receive data from iOS or Android devices.
  ///
  /// Param [customEventHandler] The custom event handler.
  ///
  void Function(Map map)? customEventHandler;

  /// Gets the current logged-in username.
  String? get currentUserId => _currentUserId;

  EMClient._internal() {
    _progressManager = EMProgressManager();
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    ClientChannel.setMethodCallHandler((MethodCall call) async {
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
  /// Adds the connection event handler. After calling this method, you can handle for new room event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handler for connection event. See [EMConnectionEventHandler].
  ///
  void addConnectionEventHandler(
    String identifier,
    EMConnectionEventHandler handler,
  ) {
    _connectionEventHandler[identifier] = handler;
  }

  ///
  /// Remove the connection event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  void removeConnectionEventHandler(String identifier) {
    _connectionEventHandler.remove(identifier);
  }

  ///
  /// Get the connection event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The connection event handler.
  ///
  EMConnectionEventHandler? getConnectionEventHandler(String identifier) {
    return _connectionEventHandler[identifier];
  }

  ///
  /// Clear all connection event handlers.
  ///
  void clearConnectionEventHandles() {
    _connectionEventHandler.clear();
  }

  ///
  /// Adds the multi-device event handler. After calling this method, you can handle for new room event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handler multi-device event. See [EMMultiDeviceEventHandler].
  ///
  void addMultiDeviceEventHandler(
    String identifier,
    EMMultiDeviceEventHandler handler,
  ) {
    _multiDeviceEventHandler[identifier] = handler;
  }

  ///
  /// Remove the multi-device event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  void removeMultiDeviceEventHandler(String identifier) {
    _multiDeviceEventHandler.remove(identifier);
  }

  ///
  /// Get the multi-device event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The multi-device event handler.
  ///
  EMMultiDeviceEventHandler? getMultiDeviceEventHandler(String identifier) {
    return _multiDeviceEventHandler[identifier];
  }

  ///
  /// Clear all multi-device event handlers.
  ///
  void clearMultiDeviceEventHandles() {
    _multiDeviceEventHandler.clear();
  }

  ///
  /// Start contact and group, chatroom callback.
  ///
  /// Reference:
  /// Call this method when you ui is ready, then will receive [EMChatRoomEventHandler], [EMContactEventHandler], [EMGroupEventHandler] event.
  ///
  Future<void> startCallback() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.startCallback);
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
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.isConnected);
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
  /// If you need to check whether the SDK is connected to the server, please use [isConnected].
  ///
  /// **Return** The result of whether the user has logged in before.
  /// `true`: means that the user has logged in before,
  /// `false`: means that the user has not login before or has called [logout] method.
  ///
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

  ///
  /// Gets the current login user ID.
  ///
  /// **Return** The current login user ID.
  ///
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

  /// Gets the token of the current logged-in user.
  Future<String> getAccessToken() async {
    Map result = await ClientChannel.invokeMethod(ChatMethodKeys.getToken);
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
  /// Param [options] The configurations: [EMOptions]. Ensure that you set this parameter.
  ///
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
    await ClientChannel.invokeMethod(ChatMethodKeys.init, options.toJson());
    _currentUserId = await getCurrentUsername();
  }

  ///
  /// Register a new user.
  ///
  /// Param [userId] The userId. The maximum length is 64 characters. Ensure that you set this parameter.
  /// Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-),
  /// and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones.
  /// If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
  ///
  /// Param [password] The password. The maximum length is 64 characters. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
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

  ///
  /// An app user logs in to the chat server with a password or token.
  ///
  /// Param [userId] The username.
  ///
  /// Param [pwdOrToken] The password or token.
  ///
  /// Param [isPassword] Whether to log in with password or token.
  /// `true`: (default) Log in with password.
  /// `false`: Log in with token.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> login(String userId, String pwdOrToken,
      [bool isPassword = true]) async {
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

  ///
  /// An app user logs in to the chat server by username and Agora token. This method supports automatic login.
  ///
  /// See also: Another method to login to chat server is to login with user ID and token, See [login].
  ///
  /// Param [userId] The userId.
  ///
  /// Param [agoraToken] The Agora token.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> loginWithAgoraToken(String userId, String agoraToken) async {
    Map req = {
      "username": userId,
      "agora_token": agoraToken,
    };

    Map result = await ClientChannel.invokeMethod(
        ChatMethodKeys.loginWithAgoraToken, req);
    try {
      EMError.hasErrorFromResult(result);
      _currentUserId = userId;
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
  /// **Throws** A description of the exception. See [EMError].
  ///
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

  ///
  /// An app user logs out.
  ///
  /// Param [unbindDeviceToken] Whether to unbind the token when logout.
  ///
  /// `true` (default) Yes.
  /// `false` No.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
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

  ///
  /// Updates the App Key, which is the unique identifier to access Agora Chat.
  ///
  /// You can retrieve the new App Key from Agora Console.
  ///
  /// As this key controls all access to Agora Chat for your app, you can only update the key when the current user is logged out.
  ///
  /// Param [newAppKey] The App Key. Ensure that you set this parameter.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
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

  ///
  /// Compresses the debug log into a gzip archive.
  ///
  /// Best practice is to delete this debug archive as soon as it is no longer used.
  ///
  /// **Return** The path of the compressed gzip file.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
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

  ///
  /// Gets all the information about the logged in devices under the specified account.
  ///
  /// Param [userId] The username you want to get the device information.
  ///
  /// Param [password] The password.
  ///
  /// **Return** TThe list of the logged-in devices.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<List<EMDeviceInfo>> getLoggedInDevicesFromServer(
      {required String userId, required String password}) async {
    EMLog.v('getLoggedInDevicesFromServer: $userId, "******"');
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

  ///
  /// Forces the specified account to log out from the specified device.
  ///
  /// Param [userId] The account you want to force logout.
  ///
  /// Param [password] The account's password.
  ///
  /// Param [resource] The device ID. For how to fetch the device ID, See [EMDeviceInfo.resource].
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<bool> kickDevice(
      {required String userId,
      required String password,
      required String resource}) async {
    EMLog.v('kickDevice: $userId, "******"');
    Map req = {'username': userId, 'password': password, 'resource': resource};
    Map result =
        await ClientChannel.invokeMethod(ChatMethodKeys.kickDevice, req);
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
  /// Param [userId] The account you want to log out from all the devices.
  ///
  /// Param [password] The password.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> kickAllDevices(
      {required String userId, required String password}) async {
    EMLog.v('kickAllDevices: $userId, "******"');
    Map req = {'username': userId, 'password': password};
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

    for (var listener in _connectionListeners) {
      listener.onConnected();
    }
  }

  Future<void> _onDisconnected() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onDisconnected?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onDisconnected();
    }
  }

  Future<void> _onUserDidLoginFromOtherDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidLoginFromOtherDevice?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onUserDidLoginFromOtherDevice();
    }
  }

  Future<void> _onUserDidRemoveFromServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidRemoveFromServer?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onUserDidRemoveFromServer();
    }
  }

  Future<void> _onUserDidForbidByServer() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidForbidByServer?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onUserDidForbidByServer();
    }
  }

  Future<void> _onUserDidChangePassword() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidChangePassword?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onUserDidChangePassword();
    }
  }

  Future<void> _onUserDidLoginTooManyDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserDidLoginTooManyDevice?.call();
    }

    for (var listener in _connectionListeners) {
      listener.onUserDidLoginTooManyDevice();
    }
  }

  Future<void> _onUserKickedByOtherDevice() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onUserKickedByOtherDevice?.call();
    }
    for (var listener in _connectionListeners) {
      listener.onUserKickedByOtherDevice();
    }
  }

  Future<void> _onUserAuthenticationFailed() async {
    for (var handler in _connectionEventHandler.values) {
      handler.onDisconnected?.call();
    }
    for (var listener in _connectionListeners) {
      listener.onDisconnected();
    }
  }

  void _onTokenWillExpire(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onTokenWillExpire?.call();
    }

    for (EMConnectionListener listener in _connectionListeners) {
      listener.onTokenWillExpire();
    }
  }

  void _onTokenDidExpire(Map? map) {
    for (var item in _connectionEventHandler.values) {
      item.onTokenDidExpire?.call();
    }

    for (EMConnectionListener listener in _connectionListeners) {
      listener.onTokenDidExpire();
    }
  }

  Future<void> _onMultiDeviceGroupEvent(Map map) async {
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    List<String> users = map['users'];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onGroupEvent?.call(event, target, users);
    }

    for (var listener in _multiDeviceListeners) {
      listener.onGroupEvent(event, target, users);
    }
  }

  Future<void> _onMultiDeviceContactEvent(Map map) async {
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    String? ext = map['ext'];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onContactEvent?.call(event, target, ext);
    }

    for (var listener in _multiDeviceListeners) {
      listener.onContactEvent(event, target, ext);
    }
  }

  Future<void> _onMultiDeviceThreadEvent(Map map) async {
    EMMultiDevicesEvent event = convertIntToEMMultiDevicesEvent(map['event'])!;
    String target = map['target'];
    List<String> users = map['users'];

    for (var handler in _multiDeviceEventHandler.values) {
      handler.onChatThreadEvent?.call(event, target, users);
    }

    for (var listener in _multiDeviceListeners) {
      listener.onChatThreadEvent(
        convertIntToEMMultiDevicesEvent(map['event'])!,
        map['target'],
        map['users'],
      );
    }
  }

  void _onReceiveCustomData(Map map) {
    customEventHandler?.call(map);
  }

  ///
  /// Gets the [EMChatManager] class. Make sure to call it after EMClient has been initialized.
  ///
  /// **Return** The `EMChatManager` class.
  ///
  EMChatManager get chatManager {
    return _chatManager;
  }

  ///
  /// Gets the [EMContactManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMContactManager` class.
  ///
  EMContactManager get contactManager {
    return _contactManager;
  }

  ///
  /// Gets the [EMChatRoomManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMChatRoomManager` class.
  ///
  EMChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  ///
  /// Gets the [EMGroupManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMGroupManager` class.
  ///
  EMGroupManager get groupManager {
    return _groupManager;
  }

  ///
  /// Gets the [EMPushManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMPushManager` class.
  ///
  EMPushManager get pushManager {
    return _pushManager;
  }

  ///
  /// Gets the [EMUserInfoManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMUserInfoManager` class.
  ///
  EMUserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  ///
  /// Gets the [EMChatThreadManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMChatThreadManager` class.
  ///
  EMChatThreadManager get chatThreadManager {
    return _chatThreadManager;
  }

  ///
  /// Gets the [EMPresenceManager] class. Make sure to call it after the EMClient has been initialized.
  ///
  /// **Return** The `EMPresenceManager` class.
  ///
  EMPresenceManager get presenceManager {
    return _presenceManager;
  }

  void _clearAllInfo() {
    _currentUserId = null;
    _userInfoManager.clearUserInfoCache();
  }
}

extension EMClientDeprecated on EMClient {
  ///
  /// Adds the multi-device listener.
  ///
  /// Param [listener] The listener to be added: {EMMultiDeviceListener}.
  ///
  @Deprecated("Use #addMultiDeviceEventHandler to instead.")
  void addMultiDeviceListener(EMMultiDeviceListener listener) {
    _multiDeviceListeners.add(listener);
  }

  ///
  /// Removes the multi-device listener.
  ///
  /// Param [listener] The listener to be removed: {EMMultiDeviceListener}.
  ///
  @Deprecated("Use #removeMultiDeviceEventHandler to instead.")
  void removeMultiDeviceListener(EMMultiDeviceListener listener) {
    if (_multiDeviceListeners.contains(listener)) {
      _multiDeviceListeners.remove(listener);
    }
  }

  ///
  /// Removes all multi-device listener.
  ///
  @Deprecated("Use #clearMultiDeviceEventHandles to instead.")
  void clearAllMultiDeviceListeners() {
    _multiDeviceListeners.clear();
  }

  ///
  /// Adds the connection listener of chat server.
  ///
  /// Param [listener] The chat server connection listener to be added.
  ///
  @Deprecated("Use #addConnectionEventHandler to instead.")
  void addConnectionListener(EMConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  ///
  /// Removes the chat server connection listener.
  ///
  /// Param [listener]  The chat server connection listener to be removed.
  ///
  @Deprecated("Use #removeConnectionEventHandler to instead.")
  void removeConnectionListener(EMConnectionListener listener) {
    if (_connectionListeners.contains(listener)) {
      _connectionListeners.remove(listener);
    }
  }

  ///
  ///  Removes all chat server connection listeners.
  ///
  @Deprecated("Use #clearConnectionEventHandles to instead.")
  void clearAllConnectionListeners() {
    _connectionListeners.clear();
  }

  ///
  /// Adds a custom listener to receive data from iOS or Android devices.
  ///
  /// Param [listener] The custom native listener to be added.
  ///
  @Deprecated("Use #customEventHandler to instead.")
  void addCustomListener(EMCustomListener listener) {
    _customListeners.add(listener);
  }

  ///
  /// Removes the custom listener.
  ///
  /// Param [listener] The custom native listener.
  ///
  @deprecated
  void removeCustomListener(EMCustomListener listener) {
    if (_customListeners.contains(listener)) {
      _customListeners.remove(listener);
    }
  }

  /// Removes all custom listeners.
  @deprecated
  void clearAllCustomListeners() {
    _customListeners.clear();
  }

  ///
  /// Gets the current login user ID.
  ///
  /// **Return** The current login user ID.
  ///
  @Deprecated("Use #getCurrentUserId to instead.")
  Future<String?> getCurrentUsername() async {
    return getCurrentUserId();
  }

  /// Gets the current logged-in username.
  @Deprecated("Use #currentUserId to instead.")
  String? get currentUsername => _currentUserId;
}
