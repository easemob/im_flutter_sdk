import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/em_extension.dart';

/// ~english
/// The conversation filter class.
/// ~end
///
/// ~chinese
/// 会话过滤类。
/// ~end
class ConversationFetchOptions {
  /// ~english
  /// The constructor of EMConversationFetchOptions.
  /// Get marked conversation.
  ///
  /// [mark] The mark type of the conversation.
  /// [pageSize] The page size of the conversation, when using mark, the value range is [1,10], default is 10.
  /// [cursor] The cursor of the conversation.
  /// ~end
  ///
  /// ~chinese
  /// EMConversationFetchOptions的构造函数。
  /// 获取标记的会话
  ///
  /// [mark] 会话标记类型。
  /// [pageSize] 会话分页大小, 在使用mark时，取值范围为[1,10], 默认为10。
  /// [cursor] 会话游标。
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
  /// The constructor of EMConversationFetchOptions.
  /// [pageSize] The page size of the conversation, when using page, the value range is [1,50], default is 20.
  /// [cursor] The cursor of the conversation.
  /// ~end
  ///
  /// ~chinese
  /// EMConversationFetchOptions的构造函数。
  /// [pageSize] 会话分页大小, 取值范围为[1,50], 默认为20。
  /// [cursor] 会话游标。
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
  /// The constructor of EMConversationFetchOptions.
  /// Get pinned conversation.
  ///
  /// [pageSize] The page size of the conversation, when using page, the value range is [1,50], default is 20.
  /// [cursor] The cursor of the conversation.
  /// ~end
  ///
  /// ~chinese
  /// EMConversationFetchOptions的构造函数。
  /// 获取置顶会话。
  ///
  /// [pageSize] 会话分页大小, 取值范围为[1,50], 默认为20。
  /// [cursor] 会话游标。
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
  /// The mark type of the conversation.
  /// ~end
  /// ~chinese
  /// 会话标记类型。
  /// ~end
  final ConversationMarkType? mark;

  /// ~english
  /// The page size of the conversation, when using mark, the value range is [1,10], default is 10. Otherwise, the value range is [1,50].
  /// ~end
  /// ~chinese
  /// 会话分页大小, 在使用mark时，取值范围为[1,10], 默认为10。否则，取值范围为[1,50], 默认为20。
  /// ~end
  final int pageSize;

  /// ~english
  /// The cursor of the conversation.
  /// ~end
  /// ~chinese
  /// 会话游标。
  /// ~end
  final String? cursor;

  /// ~english
  /// Whether to get pinned conversation.
  /// ~end
  /// ~chinese
  /// 是否获取置顶会话。
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

  ConversationFetchOptions copyWith({String? cursor}) => ConversationFetchOptions._(
        pageSize: pageSize,
        cursor: cursor,
        mark: mark,
        pinned: pinned,
      );
}
