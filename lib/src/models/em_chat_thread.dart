class EMChatThread {
  /// sub-zone id
  final String threadId;

  /// Subject of the sub-zone(There will be a list of requested sub-areas and sub-area details)
  final String? threadName;

  /// create  of the sub-zone, require fetch thread's detail first
  final String owner;

  /// A messageId that create sub-zone
  final String messageId;

  /// A messageContent that create sub-zone
  final String msgContent;

  /// A channelId that create sub-zone
  final String channelId;

  /// Member list of the sub-zone, require fetch thread's detail first
  final int memberCount;

  /// Timestamp of subarea creation
  final int timestamp;

  /// @nodoc
  EMChatThread._private({
    required this.threadId,
    required this.owner,
    required this.messageId,
    required this.msgContent,
    required this.channelId,
    required this.memberCount,
    required this.timestamp,
    this.threadName,
  });

  factory EMChatThread.fromJson(Map map) {
    String threadId = map["threadId"];
    String threadName = map["threadName"];
    String owner = map["owner"];
    String messageId = map["msgId"];
    String content = map["content"];
    String channelId = map["channelId"];
    int count = map["memberCount"];
    int timestamp = map["ts"];
    return EMChatThread._private(
      threadId: threadId,
      owner: owner,
      messageId: messageId,
      msgContent: content,
      channelId: channelId,
      memberCount: count,
      timestamp: timestamp,
      threadName: threadName,
    );
  }
}
