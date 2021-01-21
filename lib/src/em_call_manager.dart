import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/em_call_setup.dart';
import 'em_sdk_method.dart';

typedef SuccessCallBack = Function();
typedef ErrorCallBack = Function(int code, String desc);

class EMCallManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emCallManagerChannel =
      const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());

  EMCallType _callType;
  bool _isRecordOnServer;
  String _callExt, _callId, _localName, _remoteName, _serverRecordId;

  /// 获取CallExt内容
  String get callExt => _callExt;

  /// 当前通话id
  String get callId => _callId;

  /// 获取本地username
  String get localName => _localName;

  /// 获取对方username
  String get remoteName => _remoteName;

  /// 获取当前通话服务器录制id
  String get serverRecordId => _serverRecordId;

  /// 是否开启服务器录制
  bool get isRecordOnServer => _isRecordOnServer;

  /// 获取当前通话类型
  EMCallType get callType => _callType;

  static EMCallManager _instance;

  final List<EMCallStateChangeListener> _callStateChangeListeners =
      List<EMCallStateChangeListener>();

  factory EMCallManager.getInstance() {
    return _instance = _instance ?? EMCallManager._internal();
  }

  EMCallManager._internal() {
    _emCallManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onCallChanged) {
        _onCallChanged(argMap);
      }
      return null;
    });
  }

  void addCallStateChangeListener(EMCallStateChangeListener listener) {
    assert(listener != null);
    _callStateChangeListeners.add(listener);
  }

  void removeCallStateChangeListener(EMCallStateChangeListener listener) {
    assert(listener != null);
    _callStateChangeListeners.remove(listener);
  }

  Future<void> _onCallChanged(Map event) async {
    String type = event['type'];
    for (var listener in _callStateChangeListeners) {
      switch (type) {
        case EMCallEvent.ON_CONNECTING:
          _callId = event['callId'];
          _localName = event['localName'];
          _remoteName = event['remoteName'];
          _serverRecordId = event['serverVideoId'];
          _callExt = event['callExt'];
          _isRecordOnServer = event['isRecordOnServer'] as bool;
          _callType = event['callType'].toInt() == 0
              ? EMCallType.Voice
              : EMCallType.Video;

          listener.onConnecting();
          break;
        case EMCallEvent.ON_CONNECTED:
          listener.onConnected();
          break;
        case EMCallEvent.ON_ACCEPTED:
          if (event['serverVideoId'] != null) {
            _serverRecordId = event['serverVideoId'] as String;
          }
          listener.onAccepted();
          break;
        case EMCallEvent.ON_NET_WORK_DISCONNECTED:
          listener.onNetworkDisconnected();
          break;
        case EMCallEvent.ON_NET_WORK_UNSTABLE:
          listener.onNetworkUnstable();
          break;
        case EMCallEvent.ON_NET_WORK_NORMAL:
          listener.onNetworkNormal();
          break;

        case EMCallEvent.ON_DISCONNECTED:
          _clearData();
          listener.onDisconnected(fromCallReason(event['reason']));
          break;
      }
    }
  }

  /// 发起实时会话
  /// [type] 通话类型;
  /// [remoteName] 被呼叫的用户（不能与自己通话）;
  /// [isRecord] 是否开启服务端录制;
  /// [isMerge] 录制时是否合并数据流;
  /// [ext] 通话扩展信息，会传给被呼叫方;
  /// [onSuccess] 发起通话成功;
  /// [onError] 发起通话失败;
  void startCall(
    String remoteName, {
    EMCallType callType = EMCallType.Voice,
    bool recordOnServer = false,
    bool isMerge = false,
    String ext = '',
    SuccessCallBack onSuccess,
    ErrorCallBack onError,
  }) {
    _remoteName = remoteName;
    _callType = callType;
    _isRecordOnServer = recordOnServer;
    _callExt = ext;
    _localName = EMClient.getInstance().getUser();
    Future<Map> result = _emCallManagerChannel.invokeMethod(
      EMSDKMethod.startCall,
      {
        "callType": callType == EMCallType.Voice ? 0 : 1,
        "remoteName": remoteName,
        "record": recordOnServer,
        "mergeStream": isMerge,
        "ext": ext
      },
    );
    result.then(
      (response) {
        if (response["success"]) {
          _callId = response['callId'];
          if (onSuccess != null) onSuccess();
        } else {
          _clearData();
          if (onError != null)
            onError(
              response['code'],
              response['desc'],
            );
        }
      },
    );
  }

  /// 设置通话配置
  Future<void> setCallOptions(EMCallOptions options) async {
    await _emCallManagerChannel.invokeMethod(
        EMSDKMethod.setCallOptions, convertToMap(options));
  }

  /// Android端用来注册广播服务调起音视频通话界面
  Future<void> registerCallReceiver() async {
    await _emCallManagerChannel.invokeMethod(EMSDKMethod.registerCallReceiver);
  }

  ///iOS端用来初始化1v1通话单例，监听相关回调
  Future<void> registerCallSharedManager() async {
    await _emCallManagerChannel
        .invokeMethod(EMSDKMethod.registerCallSharedManager);
  }

  _clearData() {
    _callExt = null;
    _callType = null;
    _localName = null;
    _remoteName = null;
    _callId = null;
    _serverRecordId = null;
    _isRecordOnServer = null;
  }
}
