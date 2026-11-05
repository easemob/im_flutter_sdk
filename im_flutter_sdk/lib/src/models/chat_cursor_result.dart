typedef CursorResultCallback = Object Function(dynamic obj);

/// ~english
/// The ChatCursorResult class, which specifies the cursor from which to query results.
/// When querying using this class, the SDK returns the queried instance and the cursor.
///
///   ```dart
///     final ChatCursorResult<ChatMessage> result = await ChatClient.getInstance
///         .chatManager.fetchHistoryMessagesByOption(
///       conversationId,
///       ChatConversationType.Chat,
///     );
///     final List<ChatMessage> messages = result.data;
///     final String? nextCursor = result.cursor;
///   ```
/// ~end
///
/// ~chinese
/// 带游标及分页获取结果的泛型类。
/// 做为分页获取且含有游标的返回对象。
///
/// 示例代码如下：
///   ```dart
///     final ChatCursorResult<ChatMessage> result = await ChatClient.getInstance
///         .chatManager.fetchHistoryMessagesByOption(
///       conversationId,
///       ChatConversationType.Chat,
///     );
///     final List<ChatMessage> messages = result.data;
///     final String? nextCursor = result.cursor;
///   ```
/// ~end
class ChatCursorResult<T> {
  ChatCursorResult(this.cursor, this.data, {this.totalCount});

  factory ChatCursorResult.fromJson(
    Map<String, dynamic> map, {
    dataItemCallback = CursorResultCallback,
  }) {
    List<T> list = [];
    for (var element in (map['list'] as List)) {
      list.add(dataItemCallback(element));
    }
    ChatCursorResult<T> result = ChatCursorResult<T>(
      map['cursor'],
      list,
      totalCount: map['totalCount'],
    );

    return result;
  }

  /// ~english
  /// Gets the cursor.
  /// ~end
  ///
  /// ~chinese
  /// 获取游标。
  /// ~end
  final String? cursor;

  /// ~english
  /// Gets the data list.
  /// ~end
  ///
  /// ~chinese
  /// 获取一页数据列表。
  /// ~end
  final List<T> data;

  /// ~english
  /// Gets the total number of results on the server.
  ///
  /// This field is null when the native SDK does not provide it.
  /// ~end
  ///
  /// ~chinese
  /// 获取服务端结果总数。
  ///
  /// 当原生 SDK 未提供该字段时，此字段为 null。
  /// ~end
  final int? totalCount;
}
