//用户属性类型

enum EMUserInfoType {
  EMUserInfoTypeNickName,
  EMUserInfoTypeAvatarURL,
  EMUserInfoTypePhone,
  EMUserInfoTypeMail,
  EMUserInfoTypeGender,
  EMUserInfoTypeSign,
  EMUserInfoTypeBirth,
  EMUserInfoTypeExt,
}

class EMUserInfo {
  EMUserInfo(
    String aUserId, {
    String aNickName = '',
    String aAvatarUrl = '',
    String aMail = '',
    String aPhone = '',
    int aGender = 0,
    String aSign = '',
    String aBirth = '',
    String aExt = '',
    int aExpireTime = 0,
  });

  factory EMUserInfo.fromJson(Map map) {
    EMUserInfo info = EMUserInfo.private(map['userId']);
    info.nickName = map['nickName'];
    info.avatarUrl = map['avatarUrl'];
    info.mail = map['mail'];
    info.phone = map['phone'];
    info.gender = map['gender'];
    info.sign = map['sign'];
    info.birth = map['birth'];
    info.ext = map['ext'];
    if (map['expireTime'] != null) {
      info.expireTime = map['expireTime'];
    }

    return info;
  }

  Map toJson() {
    Map data = Map();
    data['userId'] = userId;
    data['nickName'] = nickName;
    data['avatarUrl'] = avatarUrl;
    data['mail'] = mail;
    data['phone'] = phone;
    data['gender'] = gender;
    data['sign'] = sign;
    data['birth'] = birth;
    data['ext'] = ext;
    data['expireTime'] = expireTime;
    return data;
  }

  EMUserInfo.private(this.userId);

  String userId = '';
  String? nickName = '';
  String? avatarUrl = '';
  String? mail = '';
  String? phone = '';
  int? gender = 0;
  String? sign = '';
  String? birth = '';
  String? ext = '';
  int expireTime = 0;
}
