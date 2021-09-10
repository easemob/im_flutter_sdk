import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'em_chat_manager.dart';
import 'em_contact_manager.dart';
import 'em_chat_room_manager.dart';
import 'em_userInfo_manager.dart';

import 'em_group_manager.dart';
import 'em_listeners.dart';
import 'em_push_manager.dart';
import 'em_sdk_method.dart';

import 'models/em_domain_terms.dart';
import 'models/em_options.dart';
import 'tools/em_log.dart';

class EMClient {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel =
      const MethodChannel('$_channelPrefix/em_client', JSONMethodCodec());
  static EMClient _instance;
  final EMChatManager _chatManager = EMChatManager();
  final EMContactManager _contactManager = EMContactManager();
  final EMChatRoomManager _chatRoomManager = EMChatRoomManager();
  final EMGroupManager _groupManager = EMGroupManager();
  final EMPushManager _pushManager = EMPushManager();
  final EMUserInfoManager _userInfoManager = EMUserInfoManager();
  final _connectionListeners = List<EMConnectionListener>();
  final _multiDeviceListeners = List<EMMultiDeviceListener>();

  /// instance fields
  bool _connected = false;
  EMOptions _options;
  String _accessToken;

  String _sdkVersion = '3.8.3';

  String _currentUsername;
  bool _isLoginBefore = false;

  /// 获取配置信息[EMOptions].
  EMOptions get options => _options;

  /// 获取当前登录用户token
  String get accessToken => _accessToken;

  /// 获取当前是否连接到服务器
  bool get connected => _connected;

  /// 获取当前登录的环信id
  String get currentUsername => _currentUsername;

  /// 获取是否登录
  bool get isLoginBefore => _isLoginBefore;

  static EMClient get getInstance =>
      _instance = _instance ?? EMClient._internal();

  /// @nodoc private constructor
  EMClient._internal() {
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onConnected) {
        return _onConnected();
      } else if (call.method == EMSDKMethod.onDisconnected) {
        return _onDisconnected(argMap);
      } else if (call.method == EMSDKMethod.onMultiDeviceEvent) {
        return _onMultiDeviceEvent(argMap);
      }
      return null;
    });
  }

  /// 初始化SDK 指定[options].
  Future<void> init(EMOptions options) async {
    _options = options;
    EMLog.v('init: $options');
    // 直接返回当前登录账号和是否登陆过
    Map result =
        await _channel.invokeMethod(EMSDKMethod.init, options.toJson());
    Map map = result[EMSDKMethod.init];
    _currentUsername = map['currentUsername'];
    _isLoginBefore = map['isLoginBefore'] as bool;

    return null;
  }

  /// 注册环信id，[username],[password],
  /// 需要在环信后台的console中设置为开放注册才能通过sdk注册，否则只能使用rest api注册。
  /// 返回注册成功的环信id
  Future<String> createAccount(String username, String password) async {
    EMLog.v('create account: $username : $password');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.createAccount, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.createAccount];
  }

  /// 使用用户名(环信id)和密码(或token)登录，[username], [pwdOrToken]
  /// 返回登录成功的id(环信id)
  Future<String> login(String username, String pwdOrToken,
      [bool isPassword = true]) async {
    EMLog.v('login: $username : $pwdOrToken, isPassword: $isPassword');
    Map req = {
      'username': username,
      'pwdOrToken': pwdOrToken,
      'isPassword': isPassword
    };
    Map result = await _channel.invokeMethod(EMSDKMethod.login, req);
    EMError.hasErrorFromResult(result);

    _currentUsername = result[EMSDKMethod.login]['username'];
    _accessToken = result[EMSDKMethod.login]['token'];
    _isLoginBefore = true;

    return _currentUsername;
  }

  /// 退出登录，是否解除deviceToken绑定[unbindDeviceToken]
  /// 返回退出是否成功
  Future<bool> logout([
    bool unbindDeviceToken = true,
  ]) async {
    EMLog.v('logout unbindDeviceToken: $unbindDeviceToken');
    Map req = {'unbindToken': unbindDeviceToken};
    Map result = await _channel.invokeMethod(EMSDKMethod.logout, req);
    EMError.hasErrorFromResult(result);
    _clearAllInfo();
    return result.boolValue(EMSDKMethod.logout);
  }

  /// 修改appKey [appKey].
  Future<bool> changeAppKey({@required String newAppKey}) async {
    EMLog.v('changeAppKey: $newAppKey');
    Map req = {'appKey': newAppKey};
    Map result = await _channel.invokeMethod(EMSDKMethod.changeAppKey, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.changeAppKey);
  }

  // /// @nodoc 上传日志到环信, 不对外暴露
  // Future<bool> _uploadLog() async {
  //   Map result = await _channel.invokeMethod(EMSDKMethod.uploadLog);
  //   EMError.hasErrorFromResult(result);
  //   return true;
  // }

  /// 压缩环信日志
  /// 返回日志路径
  Future<String> compressLogs() async {
    EMLog.v('compressLogs:');
    Map result = await _channel.invokeMethod(EMSDKMethod.compressLogs);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.compressLogs];
  }

  /// 获取账号名下登陆的在线设备列表
  /// 当前登录账号和密码 [username]/[password].
  Future<List<EMDeviceInfo>> getLoggedInDevicesFromServer(
      {@required String username, @required String password}) async {
    EMLog.v('getLoggedInDevicesFromServer: $username, "******"');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(
        EMSDKMethod.getLoggedInDevicesFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMDeviceInfo> list = List();
    result[EMSDKMethod.getLoggedInDevicesFromServer]?.forEach((info) {
      list.add(EMDeviceInfo.fromJson(info));
    });
    return list;
  }

  /// 根据设备ID，将该设备下线,
  /// 账号和密码 [username]/[password] 设备ID[resource].
  Future<bool> kickDevice(
      {@required String username,
      @required String password,
      @required String resource}) async {
    EMLog.v('kickDevice: $username, "******"');
    Map req = {
      'username': username,
      'password': password,
      'resource': resource
    };
    Map result = await _channel.invokeMethod(EMSDKMethod.kickDevice, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.kickDevice);
  }

  /// 将该账号下的所有设备都踢下线
  /// 账号和密码 [username]/[password].
  Future<bool> kickAllDevices(
      {@required String username, @required String password}) async {
    EMLog.v('kickAllDevices: $username, "******"');
    Map req = {'username': username, 'password': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.kickAllDevices, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.kickAllDevices);
  }

  /* Listeners*/

  /// @nodoc 添加多设备监听的接口 [listener].
  void addMultiDeviceListener(EMMultiDeviceListener listener) {
    assert(listener != null);
    _multiDeviceListeners.add(listener);
  }

  /// @nodoc 移除多设备监听的接口[listener].
  void removeMultiDeviceListener(EMMultiDeviceListener listener) {
    assert(listener != null);
    _multiDeviceListeners.remove(listener);
  }

  /// 添加链接状态监听的接口[listener].
  void addConnectionListener(EMConnectionListener listener) {
    assert(listener != null);
    _connectionListeners.add(listener);
  }

  /// 移除链接状态监听的接口[listener].
  void removeConnectionListener(EMConnectionListener listener) {
    assert(listener != null);
    _connectionListeners.remove(listener);
  }

  /// @nodoc once connection changed, listeners to be informed.
  Future<void> _onConnected() async {
    _connected = true;
    for (var listener in _connectionListeners) {
      listener.onConnected();
    }
  }

  /// @nodoc
  Future<void> _onDisconnected(Map map) async {
    _connected = false;
    for (var listener in _connectionListeners) {
      int errorCode = map['errorCode'];
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
  EMContactGroupEvent convertIntToEMContactGroupEvent(int i) {
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
    _accessToken = '';
    _currentUsername = '';
    _userInfoManager.clearUserInfoCache();
  }
}
