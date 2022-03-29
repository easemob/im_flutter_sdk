import 'package:flutter/services.dart';

import '../internal/chat_method_keys.dart';
import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_error.dart';
import '../em_push_manager.dart';

class EMPushConfigs {
  EMPushConfigs._private();

  DisplayStyle? _displayStyle;
  @Deprecated("Switch to using DisplayStyle instead")
  EMPushStyle? _pushStyle;
  bool? _noDisturb;
  int? _noDisturbStartHour;
  int? _noDisturbEndHour;
  List<String>? _noDisturbGroups = [];

  @Deprecated("Switch to using DisplayStyle instead")
  EMPushStyle? get pushStyle => _pushStyle;

  DisplayStyle? get displayStyle => _displayStyle;

  bool? get noDisturb => _noDisturb;
  int? get noDisturbStartHour => _noDisturbStartHour;
  int? get noDisturbEndHour => _noDisturbEndHour;
  List<String>? get noDisturbGroups => _noDisturbGroups;

  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs._private()
      .._displayStyle =
          map['pushStyle'] == 0 ? DisplayStyle.Simple : DisplayStyle.Summary
      .._noDisturb = map.boolValue('noDisturb')
      .._noDisturbStartHour = map['noDisturbStartHour']
      .._noDisturbEndHour = map['noDisturbEndHour'];
  }

  Map toJson() {
    Map data = Map();
    data['pushStyle'] = _displayStyle == DisplayStyle.Simple;
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

  @Deprecated(
      "Switch to using EMPushManager#enableOfflinePush and EMPushManager#disableOfflinePush instead")
  Future<void> setNoDisturb(
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
    try {
      EMError.hasErrorFromResult(result);
      bool success = result.boolValue(ChatMethodKeys.imPushNoDisturb);
      if (success) {
        _noDisturb = isNoDisturb;
        _noDisturbStartHour = startTime;
        _noDisturbEndHour = endTime;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#updatePushDisplayStyle instead")
  Future<void> setPushStyle(EMPushStyle pushStyle) async {
    Map req = {'pushStyle': pushStyle == EMPushStyle.Simple ? 0 : 1};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#updatePushServiceForGroup instead")
  Future<void> setGroupToDisturb(
    String groupId,
    bool isNoDisturb,
  ) async {
    Map req = {'noDisturb': isNoDisturb, 'group_id': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#getNoPushGroups instead")
  Future<List<String>?> noDisturbGroupsFromServer() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getNoDisturbGroups);
    try {
      EMError.hasErrorFromResult(result);
      _noDisturbGroups =
          result[ChatMethodKeys.getNoDisturbGroups]?.cast<String>();
      return _noDisturbGroups;
    } on EMError catch (e) {
      throw e;
    }
  }
}
