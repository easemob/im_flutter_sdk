import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/em_extension.dart';
import 'package:im_flutter_sdk/src/tools/em_log.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// ~english
/// The user attribute manager class, which gets and sets the user attributes.
/// ~end
///
/// ~chinese
/// 用户属性类，用于获取和更新用户属性。
/// ~end
class EMUserInfoManager {
  // The map of effective contacts.
  final Map<String, EMUserInfo> _effectiveUserInfoMap = {};

  EMUserInfoManager() {
    Client.instance.userInfoManager
        .updateNativeHandler((MethodCall call) async {
      EMLog.d("${call.method}: arguments: ${call.arguments}");
    });
  }

  /// ~english
  /// Modifies the user attributes of the current user.
  ///
  /// Param [nickname] The nickname of the user.
  ///
  /// Param [avatarUrl] The avatar URL of the user.
  ///
  /// Param [mail] The email address of the user.
  ///
  /// Param [phone] The phone number of the user.
  ///
  /// Param [gender] The gender of the user. The value can only be `0`, `1`, or `2`. Other values are invalid.
  /// - `0`: (Default) Unknown;
  /// - `1`: Male;
  /// - `2`: Female.
  /// Param [sign] The signature of the user.
  ///
  /// Param [birth] The birthday of the user.
  ///
  /// Param [ext] The custom extension information of the user. You can set it to an empty string or type custom information and encapsulate them as a JSON string.
  ///
  /// **Return** The user info.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 修改当前用户的属性信息。
  ///
  /// Param [nickname] 用户昵称。该昵称与推送设置中的昵称设置不同，我们建议这两种昵称的设置保持一致。设置推送昵称详见 [EMPushManager.updatePushNickname]。
  ///
  /// Param [avatarUrl] 用户头像。
  ///
  /// Param [mail] 用户邮箱。
  ///
  /// Param [phone] 用户手机号。
  ///
  /// Param [gender] 用户性别。
  /// - `0`: (默认) 未知;
  /// - `1`: 男;
  /// - `2`: 女.
  ///
  /// Param [sign] 用户签名。
  ///
  /// Param [birth] 用户的生日。
  ///
  /// Param [ext] 用户的自定义属性字段。该字段可为空，或设置为自定义扩展信息，封装为 JSON 字符串。
  ///
  /// **Return** 用户属性信息。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end

  Future<EMUserInfo> updateUserInfo({
    String? nickname,
    String? avatarUrl,
    String? mail,
    String? phone,
    int? gender,
    String? sign,
    String? birth,
    String? ext,
  }) async {
    try {
      Map req = {};
      req.putIfNotNull("nickName", nickname);
      req.putIfNotNull("avatarUrl", avatarUrl);
      req.putIfNotNull("mail", mail);
      req.putIfNotNull("phone", phone);
      req.putIfNotNull("gender", gender);
      req.putIfNotNull("sign", sign);
      req.putIfNotNull("birth", birth);
      req.putIfNotNull("ext", ext);

      Map result = await Client.instance.userInfoManager
          .callNativeMethod(ChatMethodKeys.updateOwnUserInfo, req);
      EMError.hasErrorFromResult(result);
      EMUserInfo info =
          EMUserInfo.fromJson(result[ChatMethodKeys.updateOwnUserInfo]);
      _effectiveUserInfoMap[info.userId] = info;
      return info;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the current user's attributes from the server.
  ///
  /// Param [expireTime] The time period(seconds) when the user attributes in the cache expire. If the interval between two callers is less than or equal to the value you set in the parameter, user attributes are obtained directly from the local cache; otherwise, they are obtained from the server. For example, if you set this parameter to 120(2 minutes), once this method is called again within 2 minutes, the SDK returns the attributes obtained last time.
  ///
  /// **Return** The user properties that are obtained. See [EMUserInfo].
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取当前用户的属性信息。
  ///
  /// Param [expireTime] 获取的用户属性到期时间。如果在到期时间内再次调用该方法，则 SDK 直接返回上次获取到的缓存数据。例如，将该参数设为 120，即 2 分钟，则如果你在 2 分钟内再次调用该方法获取用户属性，SDK 仍将返回上次获取到的属性。否则需从服务器获取。
  ///
  /// **Return** 用户属性。请参见 [EMUserInfo]。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end

  Future<EMUserInfo?> fetchOwnInfo({int expireTime = 0}) async {
    try {
      String? currentUser = await EMClient.getInstance.getCurrentUserId();
      if (currentUser == null) {
        throw EMError.fromJson({
          "code": 201,
          "description": "Not login",
        });
      }
      Map<String, EMUserInfo> ret = await fetchUserInfoById(
        [currentUser],
        expireTime: expireTime,
      );
      _effectiveUserInfoMap[ret.values.first.userId] = ret.values.first;
      return ret.values.first;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets user attributes of the specified users.
  ///
  /// Param [userIds] The username array.
  ///
  /// Param [expireTime] The time period(seconds) when the user attributes in the cache expire. If the interval between two callers is less than or equal to the value you set in the parameter, user attributes are obtained directly from the local cache; otherwise, they are obtained from the server. For example, if you set this parameter to 120(2 minutes), once this method is called again within 2 minutes, the SDK returns the attributes obtained last time.
  ///
  /// **Return** A map that contains key-value pairs where the key is the user ID and the value is user attributes.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据用户 ID，获取指定用户的用户属性。
  ///
  /// Param [userIds] 用户 ID 数组。
  ///
  /// Param [expireTime] 获取的用户属性到期时间。如果在到期时间内再次调用该方法，则 SDK 直接返回上次获取到的缓存数据。例如，将该参数设为 120，即 2 分钟，则如果你在 2 分钟内再次调用该方法获取用户属性，SDK 仍将返回上次获取到的属性。否则需从服务器获取。
  ///
  /// **Return** 返回 key-value 格式的 Map 类型数据，key 为用户 ID，value 为用户属性。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end

  Future<Map<String, EMUserInfo>> fetchUserInfoById(
    List<String> userIds, {
    int expireTime = 0,
  }) async {
    try {
      List<String> needReqIds = userIds
          .where((element) =>
              !_effectiveUserInfoMap.containsKey(element) ||
              (_effectiveUserInfoMap.containsKey(element) &&
                  DateTime.now().millisecondsSinceEpoch -
                          _effectiveUserInfoMap[element]!.expireTime >
                      expireTime * 1000))
          .toList();
      Map<String, EMUserInfo> resultMap = {};

      for (var element in userIds) {
        if (_effectiveUserInfoMap.containsKey(element)) {
          resultMap[element] = _effectiveUserInfoMap[element]!;
        }
      }
      if (needReqIds.isEmpty) {
        return resultMap;
      }

      Map req = {'userIds': needReqIds};
      Map result = await Client.instance.userInfoManager
          .callNativeMethod(ChatMethodKeys.fetchUserInfoById, req);
      EMError.hasErrorFromResult(result);
      result[ChatMethodKeys.fetchUserInfoById]?.forEach((key, value) {
        EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
        resultMap[key] = eUserInfo;
        _effectiveUserInfoMap[key] = eUserInfo;
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// clear all userInfo cache.
  ///  ~end
  ///
  /// ~chinese
  /// 清理内存中的用户属性。
  /// ~end

  void clearUserInfoCache() {
    _effectiveUserInfoMap.clear();
  }
}
