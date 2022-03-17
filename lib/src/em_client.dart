import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tools/em_extension.dart';
import '../im_flutter_sdk.dart';
import 'chat_method_keys.dart';
import 'em_chat_room_manager.dart';

class EMClient {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel =
      const MethodChannel('$_channelPrefix/em_client', JSONMethodCodec());
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

  /// instance fields
  bool _connected = false;
  EMOptions? _options;

  String _sdkVersion = '1.0.0';

  String? _currentUsername;

  bool? _isLoginBefore;

  /// 获取配置信息[EMOptions].
  EMOptions? get options => _options;

  /// 获取当前是否连接到服务器
  bool get connected => _connected;

  /// 获取当前登录的环信id
  String? get currentUsername => _currentUsername;

  /// 获取是否登录
  bool? get isLoginBefore => _isLoginBefore;

  static EMClient get getInstance =>
      _instance = _instance ?? EMClient._internal();

  /// @nodoc private constructor
  EMClient._internal() {
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onConnected) {
        return _onConnected();
      } else if (call.method == ChatMethodKeys.onDisconnected) {
        return _onDisconnected(argMap);
      } else if (call.method == ChatMethodKeys.onMultiDeviceEvent) {
        return _onMultiDeviceEvent(argMap!);
      } else if (call.method == ChatMethodKeys.onSendDataToFlutter) {
        return _onReceiveCustomData(argMap!);
      } else if (call.method == ChatMethodKeys.onTokenWillExpire) {
        return _onTokenWillExpire(argMap);
      } else if (call.method == ChatMethodKeys.onTokenDidExpire) {
        return _onTokenDidExpire(argMap);
      }

      return null;
    });
  }

  /// 获取已登录账号的环信Token
  Future<String?> getAccessToken() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getToken);
    EMError.hasErrorFromResult(result);
    return result[ChatMethodKeys.getToken];
  }

  /// 初始化SDK 指定[options].
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
    // 直接返回当前登录账号和是否登陆过
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.init, options.toJson());
    Map map = result[ChatMethodKeys.init];
    _currentUsername = map['username'];
    _isLoginBefore = () {
      if (map.containsKey("isLoginBefore")) {
        return map['isLoginBefore'] as bool;
      } else {
        return false;
      }
    }();

    return null;
  }

  /// 注册环信id，[username],[password],
  /// 需要在环信后台的console中设置为开放注册才能通过sdk注册，否则只能使用rest api注册。
  /// 返回注册成功的环信id
  Future<String> createAccount(String username, String password) async {
    EMLog.v('create account: $username : $password');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(ChatMethodKeys.createAccount, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.createAccount];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 使用用户名(环信id)和密码(或token)登录，[username], [pwdOrToken]
  /// 返回登录成功的id(环信id)
  Future<void> login(String username, String pwdOrToken,
      [bool isPassword = true]) async {
    EMLog.v('login: $username : $pwdOrToken, isPassword: $isPassword');
    Map req = {
      'username': username,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await _channel.invokeMethod(ChatMethodKeys.login, req);
    EMError.hasErrorFromResult(result);

    _currentUsername = result[ChatMethodKeys.login]['username'];
    _isLoginBefore = true;
  }

  Future<void> loginWithAgoraToken(String username, String agoraToken) async {
    Map req = {
      "username": username,
      "agoratoken": agoraToken,
    };

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.loginWithAgoraToken, req);
    EMError.hasErrorFromResult(result);
    _currentUsername = result[ChatMethodKeys.loginWithAgoraToken]['username'];

    _isLoginBefore = true;
  }

  /// 退出登录，是否解除deviceToken绑定[unbindDeviceToken]
  /// 返回退出是否成功
  Future<bool> logout([
    bool unbindDeviceToken = true,
  ]) async {
    EMLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await _channel.invokeMethod(ChatMethodKeys.logout, req);
    try {
      EMError.hasErrorFromResult(result);
      _clearAllInfo();
      return result.boolValue(ChatMethodKeys.logout);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 修改appKey [newAppKey].
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

  // /// @nodoc 上传日志到环信, 不对外暴露
  // Future<bool> _uploadLog() async {
  //   Map result = await _channel.invokeMethod(ChatMethodKeys.uploadLog);
  //   EMError.hasErrorFromResult(result);
  //   return true;
  // }

  /// 压缩环信日志
  /// 返回日志路径
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

  /// 获取账号名下登陆的在线设备列表
  /// 当前登录账号和密码 [username]/[password].
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

  /// 根据设备ID，将该设备下线,
  /// 账号和密码 [username]/[password] 设备ID[resource].
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

  /// 将该账号下的所有设备都踢下线
  /// 账号和密码 [username]/[password].
  Future<bool> kickAllDevices(
      {required String username, required String password}) async {
    EMLog.v('kickAllDevices: $username, "******"');
    Map req = {'username': username, 'password': password};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.kickAllDevices, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.kickAllDevices);
    } on EMError catch (e) {
      throw e;
    }
  }

  /* Listeners*/

  /// @nodoc 添加多设备监听的接口 [listener].
  void addMultiDeviceListener(EMMultiDeviceListener listener) {
    _multiDeviceListeners.add(listener);
  }

  /// @nodoc 移除多设备监听的接口[listener].
  void removeMultiDeviceListener(EMMultiDeviceListener listener) {
    if (_multiDeviceListeners.contains(listener)) {
      _multiDeviceListeners.remove(listener);
    }
  }

  /// 添加链接状态监听的接口[listener].
  void addConnectionListener(EMConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  /// 移除链接状态监听的接口[listener].
  void removeConnectionListener(EMConnectionListener listener) {
    if (_connectionListeners.contains(listener)) {
      _connectionListeners.remove(listener);
    }
  }

  /// 添加从原生到flutter的监听
  void addCustomListener(EMCustomListener listener) {
    _customListeners.add(listener);
  }

  /// 移除从原生到flutter的监听
  void removeCustomListener(EMCustomListener listener) {
    if (_customListeners.contains(listener)) {
      _customListeners.remove(listener);
    }
  }

  /// @nodoc once connection changed, listeners to be informed.
  Future<void> _onConnected() async {
    _connected = true;
    for (var listener in _connectionListeners) {
      listener.onConnected();
    }
  }

  /// @nodoc
  Future<void> _onDisconnected(Map? map) async {
    _connected = false;
    for (var listener in _connectionListeners) {
      int? errorCode = map!['errorCode'];
      listener.onDisconnected(errorCode);
    }
  }

  /// @nodoc on multi device event emitted, call listeners func.
  Future<void> _onMultiDeviceEvent(Map map) async {
    var event = map['event'];
    for (var listener in _multiDeviceListeners) {
      if (event >= 10) {
        listener.onGroupEvent(convertIntToEMContactGroupEvent(event),
            map['target'], map['userNames']);
      } else {
        listener.onContactEvent(
            convertIntToEMContactGroupEvent(event), map['target'], map['ext']);
      }
    }
  }

  void _onReceiveCustomData(Map map) {
    debugPrint("map ---- $map");
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

  /// @nodoc chatManager - retrieve [EMChat Manager] handle.
  EMChatManager get chatManager {
    return _chatManager;
  }

  /// @nodoc  contactManager - retrieve [EMContactManager] handle.
  EMContactManager get contactManager {
    return _contactManager;
  }

  /// @nodoc
  EMChatRoomManager get chatRoomManager {
    return _chatRoomManager;
  }

  /// @nodoc  groupManager - retrieve [EMGroupManager] handle.
  EMGroupManager get groupManager {
    return _groupManager;
  }

  /// @nodoc  pushManager - retrieve [EMPushManager] handle.
  EMPushManager get pushManager {
    return _pushManager;
  }

  EMUserInfoManager get userInfoManager {
    return _userInfoManager;
  }

  /// @nodoc
  EMContactGroupEvent? convertIntToEMContactGroupEvent(int? i) {
    switch (i) {
      case 2:
        return EMContactGroupEvent.CONTACT_REMOVE;
      case 3:
        return EMContactGroupEvent.CONTACT_ACCEPT;
      case 4:
        return EMContactGroupEvent.CONTACT_DECLINE;
      case 5:
        return EMContactGroupEvent.CONTACT_BAN;
      case 6:
        return EMContactGroupEvent.CONTACT_ALLOW;
      case 10:
        return EMContactGroupEvent.GROUP_CREATE;
      case 11:
        return EMContactGroupEvent.GROUP_DESTROY;
      case 12:
        return EMContactGroupEvent.GROUP_JOIN;
      case 13:
        return EMContactGroupEvent.GROUP_LEAVE;
      case 14:
        return EMContactGroupEvent.GROUP_APPLY;
      case 15:
        return EMContactGroupEvent.GROUP_APPLY_ACCEPT;
      case 16:
        return EMContactGroupEvent.GROUP_APPLY_DECLINE;
      case 17:
        return EMContactGroupEvent.GROUP_INVITE;
      case 18:
        return EMContactGroupEvent.GROUP_INVITE_ACCEPT;
      case 19:
        return EMContactGroupEvent.GROUP_INVITE_DECLINE;
      case 20:
        return EMContactGroupEvent.GROUP_KICK;
      case 21:
        return EMContactGroupEvent.GROUP_BAN;
      case 22:
        return EMContactGroupEvent.GROUP_ALLOW;
      case 23:
        return EMContactGroupEvent.GROUP_BLOCK;
      case 24:
        return EMContactGroupEvent.GROUP_UNBLOCK;
      case 25:
        return EMContactGroupEvent.GROUP_ASSIGN_OWNER;
      case 26:
        return EMContactGroupEvent.GROUP_ADD_ADMIN;
      case 27:
        return EMContactGroupEvent.GROUP_REMOVE_ADMIN;
      case 28:
        return EMContactGroupEvent.GROUP_ADD_MUTE;
      case 29:
        return EMContactGroupEvent.GROUP_REMOVE_MUTE;
      default:
        return null;
    }
  }

  String get flutterSDKVersion => _sdkVersion;

  void _clearAllInfo() {
    _isLoginBefore = false;
    _connected = false;
    _currentUsername = '';
    _userInfoManager.clearUserInfoCache();
  }
}
