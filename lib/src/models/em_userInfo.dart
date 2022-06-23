import '../tools/em_extension.dart';

///
/// 用户属性类。
///
class EMUserInfo {
  ///
  /// 创建用户属性。
  ///
  /// Param [userId] 用户名。
  ///
  EMUserInfo(
    this.userId, {

    /// Param [nickName] 用户昵称。
    this.nickName,

    /// Param [avatarUrl] 用户头像。
    this.avatarUrl,

    /// Param [mail] 用户邮箱。
    this.mail,

    /// Param [phone] 用户手机号。
    this.phone,

    /// Param [gender] 用户性别。
    /// - `0`: (Default) 未知;
    /// - `1`: 男;
    /// - `2`: 女.
    this.gender = 0,

    /// Param [sign] 用户签名。
    this.sign,

    /// Param [birth] 用户的出生日期。
    this.birth,

    /// Param [ext] 用户自定义属性字段。
    this.ext,
  });

  EMUserInfo._private({
    required this.userId,
    this.nickName,
    this.avatarUrl,
    this.mail,
    this.phone,
    this.gender = 0,
    this.sign,
    this.birth,
    this.ext,
  });

  /// @nodoc
  factory EMUserInfo.fromJson(Map map) {
    EMUserInfo info = EMUserInfo(
      map["userId"],
      nickName: map.getStringValue("nickName"),
      avatarUrl: map.getStringValue("avatarUrl"),
      mail: map.getStringValue("mail"),
      phone: map.getStringValue("phone"),
      gender: map.getIntValue("gender", defaultValue: 0)!,
      sign: map.getStringValue("sign"),
      birth: map.getStringValue("birth"),
      ext: map.getStringValue("ext"),
    );
    return info;
  }

  ///
  /// 设置用户属性。
  ///
  /// **Return** 用户属性新实例。
  ///
  EMUserInfo copyWith({
    /// Param [nickName] 用户昵称。
    String? nickName,

    /// Param [avatarUrl] 用户头像。
    String? avatarUrl,

    /// Param [mail] 用户邮箱。
    String? mail,

    /// Param [phone] 用户手机号。
    String? phone,

    /// Param [gender] 用户性别。
    /// - `0`: (Default) 未知;
    /// - `1`: 男;
    /// - `2`: 女.
    int? gender,

    /// Param [sign] 用户签名。
    String? sign,

    /// Param [birth] 用户的出生日期。
    String? birth,

    /// Param [ext] 用户自定义属性字段。
    String? ext,
  }) {
    return EMUserInfo._private(
      userId: this.userId,
      nickName: nickName ?? this.nickName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mail: mail ?? this.mail,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      sign: sign ?? this.sign,
      birth: birth ?? this.birth,
      ext: ext ?? this.birth,
    );
  }

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data['userId'] = userId;
    if (nickName != null) {
      data['nickName'] = nickName;
    }
    if (avatarUrl != null) {
      data['avatarUrl'] = avatarUrl;
    }
    if (mail != null) {
      data['mail'] = mail;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    data['gender'] = gender;
    if (sign != null) {
      data['sign'] = sign;
    }
    if (birth != null) {
      data['birth'] = birth;
    }
    if (ext != null) {
      data['ext'] = ext;
    }

    return data;
  }

  /// 用户名Id。
  final String userId;

  /// 用户昵称。
  final String? nickName;

  /// 用户头像。
  final String? avatarUrl;

  /// 用户邮箱地址。
  final String? mail;

  /// 用户手机号。
  final String? phone;

  /// 用户性别。
  /// - `0`: (默认) 未知;
  /// - `1`: 男;
  /// - `2`: 女.
  ///
  final int gender;

  /// 用户签名。
  final String? sign;

  /// 用户的出生日期。
  final String? birth;

  /// 用户自定义属性字段。
  final String? ext;

  final int _expireTime = DateTime.now().millisecondsSinceEpoch;
}

extension UserInfoPrivate on EMUserInfo {
  int get expireTime => _expireTime;
}
