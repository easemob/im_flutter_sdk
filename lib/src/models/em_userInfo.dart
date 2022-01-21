//用户属性类型

enum EMUserInfoType {
  NickName,
  AvatarURL,
  Phone,
  Mail,
  Gender,
  Sign,
  Birth,
  Ext,
}

class EMUserInfo {
  EMUserInfo(String aUserId);

  EMUserInfo._private({
    required this.userId,
    this.nickName,
    this.avatarUrl,
    this.mail,
    this.phone,
    this.gender,
    this.sign,
    this.birth,
    this.ext,
  });

  factory EMUserInfo.fromJson(Map map) {
    EMUserInfo info = EMUserInfo._private(
      userId: map['userId'],
    );
    info.nickName = map['nickName'];
    info.avatarUrl = map['avatarUrl'];
    info.mail = map['mail'];
    info.phone = map['phone'];
    if (map.containsKey("gender")) {
      if (map['gender'] as int != 0) {
        info.gender = map['gender'] as int;
      }
    }
    info.sign = map['sign'];
    info.birth = map['birth'];
    info.ext = map['ext'];
    return info;
  }

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
    if (gender != null) {
      data['gender'] = gender;
    }
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

  String userId = '';
  String? nickName;
  String? avatarUrl;
  String? mail;
  String? phone;
  int? gender;
  String? sign;
  String? birth;
  String? ext;
  int expireTime = DateTime.now().millisecondsSinceEpoch;
}
