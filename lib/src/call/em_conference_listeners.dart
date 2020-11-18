import '../../im_flutter_sdk.dart';

abstract class EMConferenceManagerListener {
  /// 有用户加入
  void onMemberJoined(EMConferenceMember member);

  /// 用户离开会议
  void onMemberExited(EMConferenceMember member);

  /// 新发布的流
  void onStreamAdded(EMConferenceStream stream);

  /// 有流停止发送
  void onStreamRemoved(EMConferenceStream stream);

  /// 有流更新
  void onStreamUpdate(EMConferenceStream stream);

  /// 离开会议
  void onPassiveLeave(EMError error);

  /// 有新管理员
  void onAdminAdd(String addedName);

  /// 有管理员被移除
  void onAdminRemoved(String removedName);

  /// 发布流失败
  void onPubStreamFailed(EMError error);

  /// 发布/订阅流 成功
  void onStreamSetup(String streamId);

  /// 更新流失败
  void onUpdateStreamFailed(EMError error);

  /// 会议状态变更
  void onConferenceStateChanged(int code);

  /// 流状态变化
  void onStreamStateUpdated(String streamId, EMConferenceStreamType steamType);

  /// 正在说话的用户
  void onSpeakers(List<String> list);

  /// 收到会议邀请
  void onReceiveInvite(String confId, String password, String extension);

  /// 自己在会议中角色变化
  void onRoleChanged(int role);

  /// 收到上麦申请
  void onReqSpeaker(String memId, String memName, String nickname);

  /// 收到变更为管路员申请
  void onReqAdmin(String memId, String memName, String nickname);

  /// 取消/静音
  void onMute(bool isMute);

  /// 全体取消/静音
  void onMuteAll(bool isMute);

  /// 上麦申请被同意拒绝
  void onApplySpeakerRefused (String adminId);

  /// 申请管理员被拒绝
  void 	onApplyAdminRefused (String adminId);

//  void onAttributesUpdated (EMConferenceAttribute[] attributes);
}