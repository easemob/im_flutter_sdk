class EMConferenceMember {
  String _memberId;
  String _memberName;
  String _ext;
  String _nickname;

  String get memberId => _memberId;
  String get memberName => _memberName;
  String get ext => _ext;
  String get nickname => _nickname;


  EMConferenceMember._private();

  factory EMConferenceMember.fromJson(Map map) {
    return EMConferenceMember._private()
      .._memberId = map['memberId']
      .._memberName = map['memberName']
      .._ext = map['ext']
      .._nickname = map['nickname'];
  }

  Map toJson() {
    Map data = Map();
    data['memberId'] = _memberId;
    data['memberName'] = _memberName;
    data['ext'] = _ext;
    data['nickname'] = _nickname;
    return data;
  }

}