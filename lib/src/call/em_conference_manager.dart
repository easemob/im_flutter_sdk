import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/call/em_conference_listeners.dart';

class EMConferenceManager {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_conference_manager', JSONMethodCodec());


  EMConferenceManager(){
    _registerCallHandler();
  }

  final List<EMConferenceManagerListener> _managerListener =  List<EMConferenceManagerListener>();

  /// 添加conferenceManager listener
  void addConferenceManagerListener(EMConferenceManagerListener listener) {
    if(!_managerListener.contains(listener)) {
      _managerListener.add(listener);
    }
  }

  /// 移除conferenceManager listener
  void removeConferenceManagerListener(EMConferenceManagerListener listener) => _managerListener.remove(listener);

  /// 设置会议使用的[appKey], [username], [token]
  Future<bool>setConferenceAppKey(String appKey, String username, String token) async {
    Map req = {'appKey': appKey, 'username': username, 'token': token};
    Map result = await _channel.invokeMethod(EMSDKMethod.setConferenceAppKey, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.setConferenceAppKey);
  }

  /// 根据[conferenceId], [password] 判断会议是否存在
  Future<bool> conferenceHasExists (String conferenceId, String password) async {
    Map req = {'conf_id':conferenceId, 'pwd': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.conferenceHasExists, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.conferenceHasExists);
  }

  /// 根据[conferenceId], [password] 加入Conference
  Future<EMConference> joinConference (String conferenceId, String password) async {
    Map req = {'conf_id':conferenceId, 'pwd': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.joinConference, req);
    EMError.hasErrorFromResult(result);
    return EMConference.fromJson(result[EMSDKMethod.joinConference]);
  }

  /// 根据[房间名], [password] 加入Conference
  Future<EMConference> joinRoom (String roomName, String password, [int conferenceRole = 0]) async {
    Map req = {'roomName':roomName, 'pwd': password, 'role': conferenceRole};
    Map result = await _channel.invokeMethod(EMSDKMethod.joinRoom, req);
    EMError.hasErrorFromResult(result);
    return EMConference.fromJson(result[EMSDKMethod.joinRoom]);
  }

  void _registerCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      dynamic argMap = call.arguments;
      if(call.method == EMSDKMethod.onMemberJoined) {
        _onMemberJoined(argMap);
      }
      else if(call.method == EMSDKMethod.onMemberExited) {
        _onMemberExited(argMap);
      }
      else if(call.method == EMSDKMethod.onStreamAdded) {
        _onStreamAdded(argMap);
      }
      else if(call.method == EMSDKMethod.onStreamRemoved) {
        _onStreamRemoved(argMap);
      }
      else if(call.method == EMSDKMethod.onStreamUpdate) {
        _onStreamUpdate(argMap);
      }
      else if(call.method == EMSDKMethod.onPassiveLeave) {
        _onPassiveLeave(argMap);
      }
      else if(call.method == EMSDKMethod.onMemberAdminAdd) {
        _onMemberAdminAdd(argMap);
      }
      else if(call.method == EMSDKMethod.onMemberAdminRemoved) {
        _onMemberAdminRemoved(argMap);
      }
      else if(call.method == EMSDKMethod.onPubStreamFailed) {
        _onPubStreamFailed(argMap);
      }
      else if(call.method == EMSDKMethod.onStreamSetup) {
        _onStreamSetup(argMap);
      }
      else if(call.method == EMSDKMethod.onUpdateStreamFailed) {
        _onUpdateStreamFailed(argMap);
      }
      else if(call.method == EMSDKMethod.onConferenceStateChanged) {
        _onConferenceStateChanged(argMap);
      }
      else if(call.method == EMSDKMethod.onStreamStateUpdated) {
        _onStreamStateUpdated(argMap);
      }
      else if(call.method == EMSDKMethod.onSpeakers) {
        _onSpeakers(argMap);
      }
      else if(call.method == EMSDKMethod.onReceiveInvite) {
        _onReceiveInvite(argMap);
      }
      else if(call.method == EMSDKMethod.onRoleChanged) {
        _onRoleChanged(argMap);
      }
      else if(call.method == EMSDKMethod.onReqSpeaker) {
        _onReqSpeaker(argMap);
      }
      else if(call.method == EMSDKMethod.onReqAdmin) {
        _onReqAdmin(argMap);
      }
      else if(call.method == EMSDKMethod.onMute) {
        _onMute(argMap);
      }
      else if(call.method == EMSDKMethod.onMuteAll) {
        _onMuteAll(argMap);
      }
      else if(call.method == EMSDKMethod.onApplySpeakerRefused) {
        _onApplySpeakerRefused(argMap);
      }
      else if(call.method == EMSDKMethod.onApplyAdminRefused) {
        _onApplyAdminRefused(argMap);
      }

      return null;
    });
  }

  Future<Null> _onMemberJoined(dynamic event) async {
    _managerListener.forEach((element) {
      EMConferenceMember member = EMConferenceMember.fromJson(event as Map);
      element.onMemberJoined(member);
    });
  }

  Future<Null> _onMemberExited(dynamic event) async {
    _managerListener.forEach((element) {
      EMConferenceMember member = EMConferenceMember.fromJson(event as Map);
      element.onMemberJoined(member);
    });
  }

  Future<Null> _onStreamAdded(dynamic event) async {
    _managerListener.forEach((element) {
      EMConferenceStream stream = EMConferenceStream.fromJson(event as Map);
      element.onStreamAdded(stream);
    });
  }

  Future<Null> _onStreamRemoved(dynamic event) async {
    _managerListener.forEach((element) {
      EMConferenceStream stream = EMConferenceStream.fromJson(event as Map);
      element.onStreamRemoved(stream);
    });
  }

  Future<Null> _onStreamUpdate(dynamic event) async {
    _managerListener.forEach((element) {
      EMConferenceStream stream = EMConferenceStream.fromJson(event as Map);
      element.onStreamUpdate(stream);
    });
  }

  Future<Null> _onPassiveLeave(dynamic event) async {
    _managerListener.forEach((element) {
      EMError error = EMError.fromJson(event as Map);
      element.onPassiveLeave(error);
    });
  }

  Future<Null> _onMemberAdminAdd(dynamic event) async {
    _managerListener.forEach((element) {
      element.onAdminAdd(event as String);
    });
  }

  Future<Null> _onMemberAdminRemoved(dynamic event) async {
    _managerListener.forEach((element) {
      element.onAdminRemoved(event as String);
    });
  }

  Future<Null> _onPubStreamFailed(dynamic event) async {
    _managerListener.forEach((element) {
      element.onPubStreamFailed(EMError.fromJson(event as Map));
    });
  }

  Future<Null> _onStreamSetup(dynamic event) async {
    _managerListener.forEach((element) {
      element.onStreamSetup(element as String);
    });
  }

  Future<Null> _onUpdateStreamFailed(dynamic event) async {
    _managerListener.forEach((element) {
      element.onUpdateStreamFailed(EMError.fromJson(event as Map));
    });
  }

  Future<Null> _onConferenceStateChanged(dynamic event) async {
    _managerListener.forEach((element) {
      element.onConferenceStateChanged(event as int);
    });
  }

  // TODO:
  Future<Null> _onStreamStateUpdated(dynamic event) async {
    _managerListener.forEach((element) {
//      String streamId = (event as Map)["stream_id"];
//      EMConferenceStreamType type = (event as Map)["state"];
//      element.onStreamStateUpdated(streamId, type);
    });
  }

  Future<Null> _onSpeakers(dynamic event) async {
    _managerListener.forEach((element) {
      element.onSpeakers(element as List<String>);
    });
  }

  Future<Null> _onReceiveInvite(dynamic event) async {
    _managerListener.forEach((element) {
      String confId = (event as Map)["conf_id"];
      String pwd = (event as Map)["pwd"];
      String ext = (event as Map)["ext"];
      element.onReceiveInvite(confId, pwd, ext);
    });
  }

  Future<Null> _onRoleChanged(dynamic event) async {
    _managerListener.forEach((element) {
      element.onRoleChanged(event as int);
    });
  }

  Future<Null> _onReqSpeaker(dynamic event) async {
    _managerListener.forEach((element) {
      String memId = (event as Map)["mem_id"];
      String memName = (event as Map)["memName"];
      String nickname = (event as Map)["nickname"];
      element.onReqSpeaker(memId, memName, nickname);
    });
  }

  Future<Null> _onReqAdmin(dynamic event) async {
    _managerListener.forEach((element) {
      String memId = (event as Map)["mem_id"];
      String memName = (event as Map)["memName"];
      String nickname = (event as Map)["nickname"];
      element.onReqAdmin(memId, memName, nickname);
    });
  }

  Future<Null> _onMute(dynamic event) async {
    _managerListener.forEach((element) {
      element.onMute(element as bool);
    });
  }

  Future<Null> _onMuteAll(dynamic event) async {
    _managerListener.forEach((element) {
      element.onMuteAll(event as bool);
    });
  }

  Future<Null> _onApplySpeakerRefused(dynamic event) async {
    _managerListener.forEach((element) {
      element.onApplySpeakerRefused(event as String);
    });
  }

  Future<Null> _onApplyAdminRefused(dynamic event) async {
    _managerListener.forEach((element) {
      String adminId = (event as Map)["admin_id"];
      element.onApplyAdminRefused(event as String);
    });
  }
}
