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
  ///
  /// Adds a reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Deletes a reaction.
  ///
  /// This is a synchronous method and blocks the current thread.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Gets the list of Reactions.
  ///
  /// Param [messageIds] The message IDs.
  ///
  /// Param [chatType] The chat type. Only one-to-one chat ({@link EMMessage.ChatType#Chat} and group chat ({@link EMMessage.ChatType#GroupChat}) are allowed.
  ///
  /// Param [groupId] which is invalid only when the chat type is group chat.
  ///
  /// **Return** The Reaction list under the specified message ID（The UserList of EMMessageReaction is the summary data, which only contains the information of the first three users）.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Gets the reaction details.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// Param [cursor] The cursor position from which to get Reactions.
  ///
  /// Param [pageSize] The number of Reactions you expect to get on each page.
  ///
  /// **Return** The result callback, which contains the reaction list obtained from the server and the cursor for the next query. Returns null if all the data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
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
