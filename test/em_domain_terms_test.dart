import "package:flutter_test/flutter_test.dart";
import "package:im_flutter_sdk/im_flutter_sdk.dart";

main() {
  test('EMOptions created successfully with options set with default values',
      () {
    EMOptions options =
        EMOptions(appKey: 'test#key', imPort: 8080, imServer: 'im.easemob.com');
    expect(options.appKey, 'test#key');
    expect(options.imServer, 'im.easemob.com');
    expect(options.imPort, 8080);
    expect(options.acceptInvitationAlways, true);
    expect(options.accessToken, null);
  });

  test('EMMessage created successfully with fields set with default values',
      () {
    EMMessage message = EMMessage(
        msgId: '123456',
        from: '123',
        to: '456',
        chatType: ChatType.Chat,
        direction: Direction.SEND);
    expect(message.msgId, '123456');
    expect(message.from, '123');
    expect(message.to, '456');
    expect(message.chatType, ChatType.Chat);
    expect(message.direction, Direction.SEND);
    expect(message.acked, false);
    expect(message.body, null);
  });

  test('EMMessage.createSendMessage() populates a default EMMessage object',
      () {
    EMMessage message = EMMessage.createSendMessage(Type.TXT);
    message.to = 'user1';
    TextMessageBody body = TextMessageBody('hello from easemob IM SDK');
    message.body = body;
    expect(message.type, Type.TXT);
    expect(message.to, 'user1');
    expect(message.body, body);
  });
}
