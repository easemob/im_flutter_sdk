class EMGroupInfo {
  final String groupId;
  final String groupName;

  EMGroupInfo._private({
    required this.groupId,
    required this.groupName,
  });

  factory EMGroupInfo.fromJson(Map map) {
    String groupId = map["groupId"];
    String groupName = map["groupName"];
    return EMGroupInfo._private(
      groupId: groupId,
      groupName: groupName,
    );
  }
}
