import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMConference {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_conference_manager', JSONMethodCodec());

  EMConference._private();

  String _callId;
  String _confId;
  String _localName;
  EMConferenceType _type;
  EMConferenceRole _role;
  List<String> _adminIds;
  List<String> _speakerIds;
  int _memberCount;
  bool _willRecord;
  String _nickname;
  String _memId;
  bool _isCreator;
  int _audiencesCount;

  String get callId => _callId;
  String get confId => _confId;
  String get localName => _localName;
  EMConferenceType get type => _type;
  EMConferenceRole get role => _role;
  List<String> get adminIds => _adminIds;
  List<String> get speakerIds => _speakerIds;
  int get memberCount => _memberCount;
  bool get willRecord => _willRecord;
  String get nickname => _nickname;
  String get memId => _memId;
  bool get isCreator => _isCreator;
  int get audiencesCount => _audiencesCount;

  factory EMConference.fromJson(Map map) {
    return EMConference._private()
      .._callId = map['callId']
      .._confId = map['confId']
      .._localName = map['localName']
      .._type = EMConferenceType.values[map['type']]
      .._role = map['role']
      .._adminIds = map['adminIds']
      .._speakerIds = map['speakerIds']
      .._memberCount = map['memberCount']
      .._willRecord = map.boolValue('willRecord')
      .._nickname = map['nickname']
      .._memId = map['memId']
      .._isCreator = map['isCreator']
      .._audiencesCount = map['audiencesCount'];
  }

  Map toJson() {
    Map data = Map();
    data['callId'] = _callId;
    data['confId'] = _confId;
    data['localName'] = _localName;
    data['type'] = _type.index;
    data['role'] = _role;
    data['adminIds'] = _adminIds;
    data['speakerIds'] = _speakerIds;
    data['memberCount'] = _memberCount;
    data['willRecord'] = _willRecord;
    data['nickname'] = _nickname;
    data['memId'] = _memId;
    data['isCreator'] = _isCreator;
    data['audiencesCount'] = _audiencesCount;
    return data;
  }
}

extension ConferenceManager on EMConference {

  /// 向会议中发送流
  Future<String> publishConference(EMConferenceStream stream, EMRTCView view) async {
    Map req = {'conference_id':this.callId, 'stream': stream.toJson(), 'view_id': view.id, 'type': view.viewType.index};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.publishConference, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.publishConference];
  }

  /// 停止向会议中发送流
  Future<bool> unPublishConference() async {
    Map req = {'conference_id':this.callId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.unPublishConference, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.unPublishConference);
  }

  /// 订阅会议中的流[steamId], 并在[remoteView] 上显示
  Future<bool> subscribeConference(String steamId, EMRTCView remoteView) async {
    Map req = {'conference_id':this.callId, 'stream_id': steamId, 'view_id': remoteView.id};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.unPublishConference, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.unPublishConference);
  }

  /// 取消订阅会议中的流[steamId]
  Future<bool> unSubscribeConference(String steamId) async {
    Map req = {'conference_id':this.callId, 'stream_id': steamId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.unSubscribeConference, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.unSubscribeConference);
  }

  /// 改变会议中的成员[member]角色, 改变其他成员角色，需要管理员权限，也可以改变自己的角色
  Future<bool> changeMemberRole(String memberName, int role) async {
    Map req = {'conference_id': this.callId, 'memberName': memberName, 'role': role};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.changeMemberRoleWithMemberName, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.changeMemberRoleWithMemberName);
  }

  /// 从会议中踢出用户[memberNames], 需要管理员以上权限
  Future<bool> kickMember(List<String>memberNames) async {
    Map req = {'conference_id': this.callId, 'memberNames': memberNames};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.kickConferenceMember, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.kickConferenceMember);
  }

  /// 销毁会议，需要管理员权限
  Future<bool> destroy() async {
    Map req = {'conference_id': this.callId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.destroyConference, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.destroyConference);
  }

  /// 离开会议，最后一人离开后会议会被销毁
  Future<bool> leave() async {
    Map req = {'conference_id': this.callId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.leaveConference, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.leaveConference);
  }

  /// 监听会议中谁在说话，TODO: 完整描述
  Future<bool> startMonitorSpeaker([int timeMillisecond = 0]) async {
    Map req = {'conference_id': this.callId, 'time': timeMillisecond};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.startMonitorSpeaker, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.startMonitorSpeaker);
  }

  /// 停止监听会议中谁在说话
  Future<bool> stopMonitorSpeaker() async {
    Map req = {'conference_id': this.callId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.stopMonitorSpeaker, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.stopMonitorSpeaker);
  }

  /// 观众[EMConferenceRole.Audience]向管理员[adminId]申请连麦成为会议主播[EMConferenceRole.Speaker]
  Future<bool> requestTobeSpeaker(String adminId) async {
    Map req = {'conference_id': this.callId, 'admin_id': adminId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.requestTobeConferenceSpeaker, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.requestTobeConferenceSpeaker);
  }

  /// 主播[EMConferenceRole.Speaker]向管理员[adminId]申请连麦成为会议管理员[EMConferenceRole.Admin]
  Future<bool> requestTobeAdmin(String adminId) async {
    Map req = {'conference_id': this.callId, 'admin_id': adminId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.requestTobeConferenceAdmin, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.requestTobeConferenceAdmin);
  }

  /// 管理员[EMConferenceRole.Admin]让会议中的指定成员[memberId]闭嘴
  Future<bool> muteMember(String memberId, bool isMute) async {
    Map req = {'conference_id': this.callId, 'member_id': memberId, 'isMute': isMute};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.muteConferenceMember, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteConferenceMember);
  }

  /// 管理员同意/拒绝观众的上麦申请，管理员调用
  Future<bool> responseReqSpeaker(String aMemberId, bool agree) async {
    Map req = {'conference_id': this.callId, 'member_id': aMemberId, 'agree': agree};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.responseReqSpeaker, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.responseReqSpeaker);
  }

  /// 管理员同意/拒绝主播的申请管理员请求，管理员调用
  Future<bool> responseReqAdmin(String aMemberId, bool agree) async {
    Map req = {'conference_id': this.callId, 'member_id': aMemberId, 'agree': agree};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.responseReqAdmin, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.responseReqAdmin);
  }

  /// 切换前后摄像头
  Future<bool> updateConferenceWithSwitchCamera() async {
    Map req = {'conference_id': this.callId};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.updateConferenceWithSwitchCamera, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updateConferenceWithSwitchCamera);
  }

  /// 设置是否关闭麦克风
  Future<bool> updateToMute(bool mute) async {
    Map req = {'conference_id': this.callId, 'mute': mute};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.updateConferenceMute, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updateConferenceMute);
  }

  /// 设置是否开启摄像头
  Future<bool> updateToEnableVideo(bool enable) async {
    Map req = {'conference_id': this.callId, 'enable': enable};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.updateConferenceVideo, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updateConferenceVideo);
  }

  /// 设置会议属性
  Future<bool> setConferenceAttribute(String key, String value) async {
    Map req = {'conference_id': this.callId, 'key': key, 'value': value};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.setConferenceAttribute, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.setConferenceAttribute);
  }

  /// 删除会议属性
  Future<bool> deleteAttributeWithKey(String key) async {
    Map req = {'conference_id': this.callId, 'key': key};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.deleteAttributeWithKey, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.deleteAttributeWithKey);
  }

  /// mute远端音频
  Future<bool> muteRemoteAudio(String steamId, bool isMute) async {
    Map req = {'steam_id': steamId, 'isMute': isMute};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.muteConferenceRemoteAudio, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteConferenceRemoteAudio);
  }

  /// mute远端视频
  Future<bool> muteRemoteVideo(String steamId,bool isMute) async {
    Map req = {'conference_id': this.callId, 'isMute': isMute};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.muteConferenceRemoteVideo, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteConferenceRemoteVideo);
  }

  /// 全部禁言
  Future<bool>muteAll(bool isMute) async {
    Map req = {'conference_id': this.callId, 'isMute': isMute};
    Map result = await EMConference._channel.invokeMethod(EMSDKMethod.muteConferenceAll, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteConferenceAll);
  }

}