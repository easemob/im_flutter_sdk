///
/// The class that defines basic information of chat groups.
///
class EMGroupInfo {
  /// The group ID.
  final String groupId;

  /// The group name.
  final String? name;

  EMGroupInfo._private({
    required this.groupId,
    required this.name,
  });

  factory EMGroupInfo.fromJson(Map map) {
    String groupId = map["groupId"];
    String? groupName = map["name"];
    return EMGroupInfo._private(
      groupId: groupId,
      name: groupName,
    );
  }
}
