import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerConversationNegativeCases({
  required ChatClient client,
  required String userId,
}) {
  ciTestWidgets('FL-CONV-009 negative update rejects an unpersisted message',
      (_) async {
    final manager = client.chatManager;
    final id = 'ci_conv_negative_${DateTime.now().microsecondsSinceEpoch}';
    addTearDown(() async {
      await manager.deleteConversation(id, deleteMessages: true);
      expect(await manager.getConversation(id, createIfNeed: false), isNull);
    });
    final conversation =
        (await manager.getConversation(id, createIfNeed: true))!;
    ChatMessage message(String suffix) {
      final draft =
          ChatMessage.createTxtSendMessage(targetId: id, content: suffix)
            ..from = userId
            ..conversationId = id
            ..status = MessageStatus.SUCCESS
            ..localTime = 1000
            ..serverTime = 1000;
      return ChatMessage.fromJson(
          {...draft.toJson(), 'msgId': '${id}_$suffix'});
    }

    final stored = message('stored');
    final absent = message('absent');
    await conversation.insertMessage(stored);
    expect(await conversation.messagesCount(), 1);
    expect(await manager.loadMessage(absent.msgId), isNull);

    await expectCiError(() => conversation.updateMessage(absent), 500);

    expect(await manager.loadMessage(absent.msgId), isNull);
    expect(await conversation.messagesCount(), 1);
    expect((await conversation.loadMessages()).map((item) => item.msgId),
        [stored.msgId]);
    final reloaded = await conversation.loadMessage(stored.msgId);
    expect((reloaded!.body as ChatTextMessageBody).content, 'stored');
  });
}
