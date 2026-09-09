import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

/// ~english
/// The option class for searching messages from the server.
///
/// This feature is a value-added service. To use it, you need to activate the message search service on the Console.
/// ~end
///
/// ~chinese
/// 服务端消息搜索选项类。
///
/// 该功能为增值服务，需在环信 Console 开通「消息搜索」服务后方可使用。
/// ~end
class ChatMessageSearchOption {
  /// ~english
  /// Creates a message search option.
  ///
  /// Param [keywordList] The keyword list, which can contain up to 5 keywords. Each keyword contains 1-120 characters, and all keywords together contain up to 120 characters.
  ///
  /// Param [keywordMatchType] The match type for the keyword list. The default value is [ChatKeywordListMatchType.OR].
  ///
  /// Param [conversationId] The conversation ID. If it is not set, messages in all conversations are searched.
  ///
  /// Param [msgTypes] The message type list. The CMD and VOICE types are not supported.
  ///
  /// Param [startTime] The start timestamp for the search, in milliseconds. It must be set in pair with [endTime].
  ///
  /// Param [endTime] The end timestamp for the search, in milliseconds. It must be set in pair with [startTime].
  ///
  /// Param [searchScope] The message search scope. The default value is [MessageSearchScope.Content].
  /// ~end
  ///
  /// ~chinese
  /// 创建服务端消息搜索选项。
  ///
  /// Param [keywordList] 关键词列表，最多 5 个关键词。每个关键词 1-120 个字符，所有关键词总共最大 120 个字符。
  ///
  /// Param [keywordMatchType] 多关键词的匹配方式，默认为 [ChatKeywordListMatchType.OR]。
  ///
  /// Param [conversationId] 会话 ID，不设置时搜索所有会话。
  ///
  /// Param [msgTypes] 消息类型列表，不支持 CMD 和 VOICE 类型。
  ///
  /// Param [startTime] 搜索的起始时间戳，单位为毫秒，须与 [endTime] 成对设置。
  ///
  /// Param [endTime] 搜索的结束时间戳，单位为毫秒，须与 [startTime] 成对设置。
  ///
  /// Param [searchScope] 消息搜索范围，默认为 [MessageSearchScope.Content]。
  /// ~end
  ChatMessageSearchOption({
    required this.keywordList,
    this.keywordMatchType = ChatKeywordListMatchType.OR,
    this.conversationId,
    this.msgTypes,
    this.startTime,
    this.endTime,
    this.searchScope = MessageSearchScope.Content,
  });

  factory ChatMessageSearchOption.fromJson(Map map) {
    return ChatMessageSearchOption(
      keywordList: (map['keywordList'] as List?)?.cast<String>() ?? [],
      keywordMatchType: ChatKeywordListMatchType
          .values[map['keywordMatchType'] ?? ChatKeywordListMatchType.OR.index],
      conversationId: map['conversationId'],
      msgTypes: (map['msgTypes'] as List?)
          ?.map((e) => MessageType.values[e as int])
          .toList(),
      startTime: map['startTime'],
      endTime: map['endTime'],
      searchScope: MessageSearchScope
          .values[map['searchScope'] ?? MessageSearchScope.Content.index],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['keywordMatchType'] = keywordMatchType.index;
    data.putIfNotNull('conversationId', conversationId);
    if (msgTypes != null) {
      data['msgTypes'] = msgTypes!.map((e) => e.index).toList();
    }
    // startTime and endTime are sent only as a pair.
    if (startTime != null && endTime != null) {
      data['startTime'] = startTime;
      data['endTime'] = endTime;
    }
    data['searchScope'] = searchScope.index;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// ~english
  /// The keyword list, which can contain up to 5 keywords. Each keyword contains 1-120 characters, and all keywords together contain up to 120 characters.
  /// ~end
  ///
  /// ~chinese
  /// 关键词列表，最多 5 个关键词。每个关键词 1-120 个字符，所有关键词总共最大 120 个字符。
  /// ~end
  final List<String> keywordList;

  /// ~english
  /// The match type for the keyword list. The default value is [ChatKeywordListMatchType.OR].
  /// ~end
  ///
  /// ~chinese
  /// 多关键词的匹配方式，默认为 [ChatKeywordListMatchType.OR]。
  /// ~end
  final ChatKeywordListMatchType keywordMatchType;

  /// ~english
  /// The conversation ID.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat or chat room, it is the group or chat room ID.
  ///
  /// If it is not set, messages in all conversations are searched.
  /// ~end
  ///
  /// ~chinese
  /// 会话 ID。
  /// - 单聊：对方用户 ID；
  /// - 群聊或聊天室：群组或聊天室 ID。
  ///
  /// 不设置时搜索所有会话。
  /// ~end
  final String? conversationId;

  /// ~english
  /// The message type list. See [MessageType].
  ///
  /// The CMD and VOICE types are not supported.
  /// ~end
  ///
  /// ~chinese
  /// 消息类型列表，详见 [MessageType]。
  ///
  /// 不支持 CMD 和 VOICE 类型。
  /// ~end
  final List<MessageType>? msgTypes;

  /// ~english
  /// The start timestamp for the search, in milliseconds.
  ///
  /// It takes effect only when set in pair with [endTime].
  /// ~end
  ///
  /// ~chinese
  /// 搜索的起始时间戳，单位为毫秒。
  ///
  /// 须与 [endTime] 成对设置才生效。
  /// ~end
  final int? startTime;

  /// ~english
  /// The end timestamp for the search, in milliseconds.
  ///
  /// It takes effect only when set in pair with [startTime].
  /// ~end
  ///
  /// ~chinese
  /// 搜索的结束时间戳，单位为毫秒。
  ///
  /// 须与 [startTime] 成对设置才生效。
  /// ~end
  final int? endTime;

  /// ~english
  /// The message search scope. The default value is [MessageSearchScope.Content].
  /// ~end
  ///
  /// ~chinese
  /// 消息搜索范围，默认为 [MessageSearchScope.Content]。
  /// ~end
  final MessageSearchScope searchScope;
}
