import 'em_chat_manager.dart';
import 'internal/chat_method_keys.dart';
import 'internal/em_channel_manager.dart';
import 'internal/em_transform_tools.dart';
import 'models/em_chat_enums.dart';
import 'models/em_cursor_result.dart';
import 'models/em_error.dart';
import 'models/em_message_reaction.dart';
import 'tools/em_extension.dart';

extension EMReactionPlugin on EMChatManager {
  Future<void> addReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.addReaction, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> removeReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.removeReaction, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<Map<String, List<EMMessageReaction>>> fetchReactionList({
    required List<String> messageIds,
    required ChatType chatType,
    String? groupId,
  }) async {
    Map req = {
      "msgIds": messageIds,
      "chatType": chatTypeToInt(chatType),
    };
    req.setValueWithOutNull("groupId", groupId);
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchReactionList, req);

    try {
      EMError.hasErrorFromResult(result);
      Map<String, List<EMMessageReaction>> ret = {};
      for (var info in result.entries) {
        List<EMMessageReaction> reactions = [];
        for (var item in info.value) {
          reactions.add(EMMessageReaction.fromJson(item));
        }
        ret[info.key] = reactions;
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<EMCursorResult<EMMessageReaction>> fetchReactionDetail({
    required String messageId,
    required String reaction,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {
      "msgId": messageId,
      "reaction": reaction,
    };
    req.setValueWithOutNull("cursor", cursor);
    req.setValueWithOutNull("pageSize", pageSize);
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchReactionDetail, req);

    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessageReaction>.fromJson(
          result[ChatMethodKeys.fetchReactionDetail],
          dataItemCallback: (value) {
        return EMMessageReaction.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }
}
