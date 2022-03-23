import 'package:flutter/services.dart';
import '../../im_flutter_sdk.dart';
import '../chat_method_keys.dart';
import '../tools/em_extension.dart';

enum EMImPushStyle { Simple, Summary }

class EMPushConfigs {
  EMPushConfigs._private();

  EMImPushStyle? _pushStyle;
  bool? _noDisturb;
  int? _noDisturbStartHour;
  int? _noDisturbEndHour;
  List<String>? _noDisturbGroups = [];

  EMImPushStyle? get pushStyle => _pushStyle;
  bool? get noDisturb => _noDisturb;
  int? get noDisturbStartHour => _noDisturbStartHour;
  int? get noDisturbEndHour => _noDisturbEndHour;
  List<String>? get noDisturbGroups => _noDisturbGroups;

  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs._private()
      .._pushStyle =
          map['pushStyle'] == 0 ? EMImPushStyle.Simple : EMImPushStyle.Summary
      .._noDisturb = map.boolValue('noDisturb')
      .._noDisturbStartHour = map['noDisturbStartHour']
      .._noDisturbEndHour = map['noDisturbEndHour'];
  }

  Map toJson() {
    Map data = Map();
    data['pushStyle'] = _pushStyle == EMImPushStyle.Simple;
    data['noDisturb'] = _noDisturb;
    data['noDisturbStartHour'] = _noDisturbStartHour;
    data['noDisturbEndHour'] = _noDisturbEndHour;
    return data;
  }
}

extension EMPushConfigsExtension on EMPushConfigs {
  // channel的命名与pushManager中的channel一致，本质上还是一个channel。
  static const MethodChannel _channel =
      const MethodChannel('com.chat.im/chat_push_manager', JSONMethodCodec());

  /// 设置是否免打扰[isNoDisturb], [startTime], [endTime]
  Future<bool> setNoDisturb(
    bool isNoDisturb, [
    int startTime = 0,
    int endTime = 24,
  ]) async {
    if (startTime < 0) startTime = 0;
    if (endTime > 24) endTime = 24;
    Map req = {
      'noDisturb': isNoDisturb,
      'startTime': startTime,
      'endTime': endTime
    };
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.imPushNoDisturb, req);
    EMError.hasErrorFromResult(result);
    bool success = result.boolValue(ChatMethodKeys.imPushNoDisturb);
    if (success) {
      _noDisturb = isNoDisturb;
      _noDisturbStartHour = startTime;
      _noDisturbEndHour = endTime;
    }
    return success;
  }

  /// 设置消息推送显示样式[pushStyle]
  Future<bool> setPushStyle(EMImPushStyle pushStyle) async {
    EMLog.v('setPushStyle: ' + pushStyle.toString());
    Map req = {'pushStyle': pushStyle == EMImPushStyle.Simple ? 0 : 1};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    EMError.hasErrorFromResult(result);
    bool success = result.boolValue(ChatMethodKeys.updateImPushStyle);
    if (success) _pushStyle = pushStyle;
    return success;
  }

  /// 通过群id[groupId]设置群组是否免打扰[isNoDisturb]
  Future<EMGroup> setGroupToDisturb(
    String groupId,
    bool isNoDisturb,
  ) async {
    Map req = {'noDisturb': isNoDisturb, 'group_id': groupId};
    EMLog.v('setGroupToDisturb: ' + req.toString());
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupPushService, req);
    EMError.hasErrorFromResult(result);
    EMGroup group =
        EMGroup.fromJson(result[ChatMethodKeys.updateGroupPushService]);
    _noDisturbGroups!.removeWhere((e) => e == group.groupId);
    if (isNoDisturb) _noDisturbGroups!.add(group.groupId);
    return group;
  }

  /// 获取免打扰群组列表
  Future<List<String>?> noDisturbGroupsFromServer() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getNoDisturbGroups);
    EMError.hasErrorFromResult(result);
    _noDisturbGroups =
        result[ChatMethodKeys.getNoDisturbGroups]?.cast<String>();
    return _noDisturbGroups;
  }
}