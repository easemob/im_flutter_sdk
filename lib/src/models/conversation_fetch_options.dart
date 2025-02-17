import '../internal/inner_headers.dart';

/// ~english
/// The conversation filter class.
/// ~end
///
/// ~chinese
/// 会话过滤类。
/// ~end
class ConversationFetchOptions {
  /// ~english
  /// The constructor of ConversationFetchOptions.
  /// Gets marked conversations.
  ///
  /// [mark] The conversation mark.
  /// [pageSize] The number of conversations to retrieve per page. The value range is [1,50]. If you retrieve marked conversations, the value range is [1,10], with 10 as the default.
  /// [cursor] The cursor to specify where to start retrieving conversations.
  /// ~end
  ///
  /// ~chinese
  /// ConversationFetchOptions 的构造函数。
  /// 获取标记的会话。
  ///
  /// [mark] 会话标记。
  /// [pageSize] 每页查询的会话数量，取值范围为[1,50]。查询标记的会话时，取值范围为 [1,10]，默认为 10。
  /// [cursor] 查询游标，即会话查询的起始位置。
  /// ~end
  ConversationFetchOptions.mark(
    ConversationMarkType mark, {
    int pageSize = 10,
    String? cursor,
  }) : this._(
          mark: mark,
          pageSize: pageSize,
          cursor: cursor,
          pinned: false,
        );

  ConversationFetchOptions._({
    this.mark,
    this.pageSize = 10,
    this.cursor,
    this.pinned = false,
  }) {
    if (mark != null) {
      assert(pageSize >= 1 && pageSize <= 10, "the value range is [1,10]");
    } else {
      assert(pageSize >= 1 && pageSize <= 50, "the value range is [1,50]");
    }
  }

  /// ~english
  /// The constructor of ConversationFetchOptions.
  /// [pageSize] The number of conversations to retrieve per page. The value range is [1,50], with 20 as the default.
  /// [cursor] The cursor to specify where to start retrieving conversations.
  /// ~end
  ///
  /// ~chinese
  /// ConversationFetchOptions 的构造函数。
  /// [pageSize] 每页查询的会话数量, 取值范围为[1,50], 默认为 20。
  /// [cursor] 查询游标，即会话查询的起始位置。
  /// ~end
  ConversationFetchOptions({
    int pageSize = 20,
    String? cursor,
  }) : this._(
          mark: null,
          pageSize: pageSize,
          cursor: cursor,
          pinned: false,
        );

  /// ~english
  /// The constructor of ConversationFetchOptions.
  /// Gets pinned conversations.
  ///
  /// [pageSize] The number of conversations to retrieve per page. The value range is [1,50], with 20 as the default.
  /// [cursor] The cursor to specify where to start retrieving conversations.
  /// ~end
  ///
  /// ~chinese
  /// ConversationFetchOptions 的构造函数。
  /// 获取置顶会话。
  ///
  /// [pageSize] 每页查询的会话数量, 取值范围为[1,50], 默认为 20。
  /// [cursor] 查询游标，即会话查询的起始位置。
  /// ~end
  ConversationFetchOptions.pinned({
    int pageSize = 20,
    String? cursor,
  }) : this._(
          mark: null,
          pageSize: pageSize,
          cursor: cursor,
          pinned: true,
        );

  /// ~english
  /// The conversation mark.
  /// ~end
  /// ~chinese
  /// 会话标记。
  /// ~end
  final ConversationMarkType? mark;

  /// ~english
  /// The number of conversations to retrieve per page. The value range is [1,10], with 10 as the default.
  /// ~end
  /// ~chinese
  /// 每页查询的会话数量, 取值范围为[1,10], 默认为 10。
  /// ~end
  final int pageSize;

  /// ~english
  /// The cursor to specify where to start retrieving conversations.
  /// ~end
  /// ~chinese
  /// 查询游标，即会话查询的起始位置。
  /// ~end
  final String? cursor;

  /// ~english
  /// Whether to get pinned conversation:
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  /// ~chinese
  /// 是否获取置顶会话。
  /// - `true`：是。
  /// - `false`：否。
  /// ~end
  final bool pinned;

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("mark", mark?.index);
    data.putIfNotNull("pageSize", pageSize);
    data.putIfNotNull('cursor', cursor ?? "");
    data.putIfNotNull('pinned', pinned);
    return data;
  }

  ConversationFetchOptions copyWith({String? cursor}) =>
      ConversationFetchOptions._(
        pageSize: pageSize,
        cursor: cursor,
        mark: mark,
        pinned: pinned,
      );
}
