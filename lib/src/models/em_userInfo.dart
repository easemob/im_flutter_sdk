import '../tools/em_extension.dart';

///
/// The user attribute class that contains user attributes.
///
class EMUserInfo {
  ///
  /// Creates a userInfo.
  ///
  /// Param [userId] The user Id.
  ///
  EMUserInfo(
    this.userId, {
    this.nickName,
    this.avatarUrl,
    this.mail,
    this.phone,
    this.gender = 0,
    this.sign,
    this.birth,
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

  /// @nodac
  factory EMUserInfo.fromJson(Map map) {
    EMUserInfo info = EMUserInfo(
      map.getValue("userId"),
      nickName: map.getValue("nickName"),
      avatarUrl: map.getValue("avatarUrl"),
      mail: map.getValue("mail"),
      phone: map.getValue("phone"),
      gender: map.getValueWithOutNull("gender", 0),
      sign: map.getValue("sign"),
      birth: map.getValue("birth"),
      ext: map.getValue("ext"),
    );
    return info;
  }

  ///
  /// Set user attribute.
  ///
  /// Param [nickName] The user's nickname.
  ///
  /// Param [avatarUrl] The avatar URL of the user.
  ///
  /// Param [mail] The email address of the user.
  ///
  /// Param [phone] The phone number of the user.
  ///
  /// Param [gender] The user's gender. The value can only be 0, 1, or 2. 0: default; 1: male; 2: female. Other values are invalid.
  ///
  /// Param [sign] The user's signature.
  ///
  /// Param [birth] The user's birthday.
  ///
  /// Param [ext] The user's extension information. You can set it to an empty string or type custom information and encapsulate them as a JSON string.
  ///
  /// **return** The new userInfo instance.
  ///
  EMUserInfo copyWith({
    String? nickName,
    String? avatarUrl,
    String? mail,
    String? phone,
    int? gender,
    String? sign,
    String? birth,
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

  /// @nodac
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

  /// The user ID.
  final String userId;

  ///  The user's nickname.
  final String? nickName;

  /// The avatar URL of the user.
  final String? avatarUrl;

  /// The email address of the user.
  final String? mail;

  /// The phone number of the user.
  final String? phone;

  /// The user's gender. The value can only be 0, 1, or 2. 0: default; 1: male; 2: female. Other values are invalid.
  final int gender;

  /// The user's signature.
  final String? sign;

  /// The user's birthday.
  final String? birth;

  /// The user's extension information. You can set it to an empty string or type custom information and encapsulate them as a JSON string.
  final String? ext;

  final int expireTime = DateTime.now().millisecondsSinceEpoch;
}
