import 'dart:async';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_push_manager.dart';

import 'em_chat_manager.dart';
import 'em_chatroom_manager.dart';
import 'em_contact_manager.dart';
import 'em_domain_terms.dart';
import 'em_group_manager.dart';
import 'em_call_manager.dart';
import 'em_conference_manager.dart';
import 'em_listeners.dart';
import 'em_sdk_method.dart';

class EMClient {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emClientChannel =
      const MethodChannel('$_channelPrefix/em_client', JSONMethodCodec());

  final EMChatManager _chatManager = EMChatManager.getInstance();

  final EMContactManager _contactManager = EMContactManager.getInstance();

  final EMChatRoomManager _chatRoomManager = EMChatRoomManager.getInstance();

  final EMGroupManager _groupManager = EMGroupManager.getInstance();

  final EMPushManager _pushManager = EMPushManager();

  final EMCallManager _callManager = EMCallManager.getInstance();

  final EMConferenceManager _conferenceManager = EMConferenceManager.getInstance();

  final _connectionListeners = List<EMConnectionListener>();
  final _multiDeviceListeners = List<EMMultiDeviceListener>();
  static EMClient _instance;

  /// instance fields
  String _currentUser;
  bool _connected = false;
  EMOptions _options;
  String _accessToken;

  factory EMClient.getInstance() {
    return _instance = _instance ?? EMClient._internal();
  }

  /// @nodoc private constructor
  EMClient._internal() {
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emClientChannel.setMethodCallHandler((MethodCall call) {
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

  /// 初始化SDK 指定[options] .
  void init(EMOptions options) {
    _options = options;
    _emClientChannel.invokeMethod(EMSDKMethod.init, options.convertToMap());
  }

  /// 注册环信账号[userName]/[password].
  /// 如果注册成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void createAccount(String userName, String password,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(
        EMSDKMethod.createAccount,
        {"userName": userName, "password": password});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 账号密码登录[id]/[password].
  /// 如果登录成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void login(String userName, String password,
      {onSuccess(String username), onError(int errorCode, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(
        EMSDKMethod.login, {"userName": userName, "password": password});
    result.then((response) {
      print(response);
      if (response['success']) {
        if (onSuccess != null) {
          // set current user name
          _currentUser = userName;
          onSuccess(_currentUser);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 使用账号和token登录 [userName] and [token].
  /// @nodoc 如果登录成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void loginWithToken(String userName, String token,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(
        EMSDKMethod.login, {"userName": userName, "token": token});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 退出登录.
  /// [unbindToken] true 解除推送绑定 ： false 不解除绑定
  /// 如果退出登录成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void logout(bool unbindToken, {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emClientChannel
        .invokeMethod(EMSDKMethod.logout, {"unbindToken": unbindToken});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 修改appkey [appKey].
  /// @nodoc 如果修改成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void changeAppKey(String appKey,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emClientChannel
        .invokeMethod(EMSDKMethod.changeAppKey, {"appKey": appKey});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 开启Debug模式 设置为在调试模式下运行
  void setDebugMode(bool debugMode) {
    _emClientChannel
        .invokeMethod(EMSDKMethod.setDebugMode, {"debugMode": debugMode});
  }

  /// 更新当前用户的nickname 此方法主要为了在苹果推送时能够推送nick而不是userid [nickName].
  Future<bool> updateCurrentUserNick(String nickName) async {
    Map<String, dynamic> result = await _emClientChannel.invokeMethod(
        EMSDKMethod.updateCurrentUserNick, {"nickName": nickName});
    if (result['success']) {
      return result['status'] as bool;
    } else {
      return false;
    }
  }

  /// @nodoc 上传log日志
  void uploadLog({onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(EMSDKMethod.uploadLog);
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        } else {
          if (onError != null) {
            onError(response['code'], response['desc']);
          }
        }
      }
    });
  }

  /// @nodoc 获取配置信息[EMOptions].
  EMOptions getOptions() {
    return _options;
  }

  /// @nodoc 压缩log文件，并返回压缩后的文件路径
  Future<String> compressLogs(onError(int code, String desc)) async {
    Map<String, dynamic> result =
        await _emClientChannel.invokeMethod(EMSDKMethod.compressLogs);
    if (result['success']) {
      return result['logs'] as String;
    } else {
      if (onError != null) onError(result['code'], result['desc']);
      return '';
    }
  }

  /// @nodoc 获取账号名下登陆的在线设备列表
  /// @nodoc 当前登录账号和密码 [userName]/[password]
  /// @nodoc 如果出现错误，请调用[onError]。
  Future<List<EMDeviceInfo>> getLoggedInDevicesFromServer(
      String userName, String password,
      {onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emClientChannel.invokeMethod(
        EMSDKMethod.getLoggedInDevicesFromServer,
        {"userName": userName, "password": password});
    if (result['success']) {
      return _convertDeviceList(result['devices']);
    } else {
      if (onError != null) onError(result['code'], result['desc']);
      return null;
    }
  }

  List<EMDeviceInfo> _convertDeviceList(List deviceList) {
    var result = List<EMDeviceInfo>();
    for (var device in deviceList) {
      result.add(
          EMDeviceInfo(device['resource'], device['UUID'], device['name']));
    }
    return result;
  }

  /// @nodoc 根据设备ID，将该设备下线,
  /// @nodoc 账号和密码 [userName]/[password] 设备ID[resource].
  /// @nodoc 如果出现错误，请调用[onError]。
  void kickDevice(String userName, String password, String resource,
      {onError(int code, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(EMSDKMethod.kickDevice,
        {"userName": userName, "password": password, "resource": resource});
    result.then((response) {
      if (!response['success']) {
        if (onError != null) onError(response['code'], response['desc']);
        return null;
      }
    });
  }

  /// @nodoc 将该账号下的所有设备都踢下线
  /// @nodoc 账号和密码 [userName]/[password] pair.
  /// @nodoc 如果出现错误，请调用[onError].
  void kickAllDevices(String userName, String password,
      {onError(int code, String desc)}) {
    Future<Map> result = _emClientChannel.invokeMethod(
        EMSDKMethod.kickAllDevices,
        {"userName": userName, "password": password});
    result.then((response) {
      if (!response['success']) {
        if (onError != null) onError(response['code'], response['desc']);
        return null;
      }
    });
  }

  /// @nodoc 获取AccessToken
  String getAccessToken() {
    return _accessToken;
  }

  /// 获取当前用户名
  /// 如果尚未成功登录IM服务器，则返回null
  Future<String> getCurrentUser() async {
    Map<String, dynamic> result =
        await _emClientChannel.invokeMethod(EMSDKMethod.getCurrentUser);
    if (result['success']) {
      return result['userName'];
    }
    return '';
  }

  /// 判断当前是否登录 true 已登录  false 未登录
  Future<bool> isLoggedInBefore() async {
    Map<String, dynamic> result =
        await _emClientChannel.invokeMethod(EMSDKMethod.isLoggedInBefore);
    if (result['success']) {
      return result['isLogged'];
    }
    return false;
  }

  /// 检查是否连接到聊天服务器
  bool isConnected() {
    return _connected;
  }

  List<EMContact> _convertContactList(contactList) {
    var result = List<EMContact>();
    for (var contact in contactList) {
      var c = EMContact(userName: contact["userName"]);
      c.nickName = contact["nickName"];
      result.add(c);
    }
    return result;
  }

  /// getChatConfigPrivate - TODO: implement later
  /// EMChatConfigPrivate getChatConfigPrivate() {}

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
      int errorCode = map["errorCode"];
      listener.onDisconnected(errorCode);
    }
  }

  /// @nodoc on multi device event emitted, call listeners func.
  Future<void> _onMultiDeviceEvent(Map map) async {
    var event = map["event"];
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

  /// @nodoc chatManager - retrieve [EMChatManager] handle.
  EMChatManager chatManager() {
    return _chatManager;
  }

  /// @nodoc  contactManager - retrieve [EMContactManager] handle.
  EMContactManager contactManager() {
    return _contactManager;
  }

  /// @nodoc
  EMChatRoomManager chatRoomManager() {
    return _chatRoomManager;
  }

  /// @nodoc  groupManager - retrieve [EMGroupManager] handle.
  EMGroupManager groupManager() {
    return _groupManager;
  }

  /// @nodoc  pushManager - retrieve [EMPushManager] handle.
  EMPushManager pushManager() {
    return _pushManager;
  }

  /// @nodoc  callManager - retrieve [EMCallManager] handle.
  EMCallManager callManager() {
    return _callManager;
  }

  EMConferenceManager conferenceManager() {
    return _conferenceManager;
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
}
