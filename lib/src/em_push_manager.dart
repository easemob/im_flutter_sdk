

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_domain_terms.dart';

import 'em_sdk_method.dart';

class EMPushManager{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emPushManagerChannel =
  const MethodChannel('$_channelPrefix/em_push_manager', JSONMethodCodec());

  /// 开启离线消息推送
  void enableOfflinePush({
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.enableOfflinePush);
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          onSuccess();
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 在指定的时间段(24小时制)内，不推送离线消息
  void disableOfflinePush(
      int startTime,
      int endTime,
      {onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.disableOfflinePush, {'startTime' : startTime, 'endTime' : endTime});
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          onSuccess();
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从缓存获取推送配置信息
  void getPushConfigs({onSuccess(EMPushConfigs pushConfigs),onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.getPushConfigs);
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          Map<String, dynamic> value = response['value'];
          onSuccess(EMPushConfigs.from(value));
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从服务器获取推送配置信息
  void getPushConfigsFromServer({onSuccess(EMPushConfigs pushConfigs),onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.getPushConfigsFromServer);
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          Map<String, dynamic> value = response['value'];
          onSuccess(EMPushConfigs.from(value));
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 设置指定的群组是否接受离线消息推送
  void updatePushServiceForGroup(
      List<String> groupIds,
      bool noPush,
      {onSuccess(),onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.updatePushServiceForGroup, {'groupIds' : groupIds, 'noPush' : noPush});
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          onSuccess();
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 获取关闭了离线消息推送的群组，需要先调用"从服务器获取推送配置信息"的方法
  void getNoPushGroups({onSuccess(List<String> groupIds), onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.getNoPushGroups);
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          List<String> groupIds = [];
          if(response['value'] != null){
            var list = response['value'] as List<dynamic>;
            list.forEach((item) => groupIds.add(item));
          }
          onSuccess(groupIds);
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 更新当前用户的nickname,这样离线消息推送的时候可以显示用户昵称而不是id，需要登录环信服务器成功后调用才生效
  Future<bool> updatePushNickname (String nickname) async{
    Map<String, dynamic> result = await _emPushManagerChannel
        .invokeMethod(EMSDKMethod.updatePushNickname, {'nickname' : nickname});
    if(result['success']){
        return result['value'];
    }
    return false;
  }
  
  /// 设置消息推送的显示风格，仅支持对iOS的设置
  void updatePushDisplayStyle(
      EMPushDisplayStyle style,
      {onSuccess(),onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emPushManagerChannel
        .invokeMethod(EMSDKMethod.updatePushDisplayStyle, {'pushDisplayStyle' : toEMPushDisplayStyle(style)});
    result.then((response){
      if(response['success']){
        if(onSuccess != null){
          onSuccess();
        }
      }else{
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }
  
}