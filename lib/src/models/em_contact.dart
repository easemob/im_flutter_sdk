class EMContact {
  factory EMContact.fromJson(Map map) {
    return EMContact._private()
      .._eid = map['eid']
      .._nickname = map['nickname']
      .._avatarURL = map['avatarURL']
      .._markName = map['markName'];
  }

  Map toJson() {
    Map data = Map();
    data['eid'] = _eid;
    data['nickname'] = _nickname;
    data['avatarURL'] = _avatarURL;
    data['markName'] = _markName;
    return data;
  }

  EMContact._private([this._eid]);

  String _eid;
  String _nickname;
  String _avatarURL = '';
  String _markName;

  /// 环信id
  String get eid => _eid;

  /// 头像地址
  String get avatarURL => _avatarURL;

  /// nickname
  String get nickname => _nickname ?? _eid;

  /// 备注名称
  String get markName => _markName ?? _nickname ?? _eid;

  Future<void> setMarkName(String markName) async {
    _markName = markName;
    // TODO: 更新备注到服务器？
  }
}
