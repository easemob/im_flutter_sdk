import "package:flutter_test/flutter_test.dart";

import '../lib/im_flutter_sdk.dart';

main() {
  test('EMOptions created successfully with options set with default values',
      () {
    EMOptions options =
        EMOptions(appKey: 'test#key');
    expect(options.appKey, 'test#key');
    expect(options.getIMServer(), 'im.easemob.com');
    expect(options.getImPort(), 8080);
    expect(options.getAcceptInvitationAlways(), true);
  });

  test('EMMessage created successfully with fields set with default values',
      () {
    EMMessage message = EMMessage(
        from: '123',
        to: '456',
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
    EMMessage message = EMMessage.createSendMessage(EMMessageType.TXT);
    message.to = 'user1';
    EMTextMessageBody body = EMTextMessageBody('hello from easemob IM SDK');
    message.body = body;
    expect(message.type, EMMessageType.TXT);
    expect(message.to, 'user1');
    expect(message.body, body);
  });

  test('EMMessage.createTxtSendMessage() returns a text message', () {
    EMMessage message =
    EMMessage.createTxtSendMessage( userName: 'user1',content:'this is a text message');
    expect(message.type, EMMessageType.TXT);
    expect(message.direction, Direction.SEND);
  });

  test('EMMessage.createLocationSendMessage() creates a location message', () {
    EMMessage message =
    EMMessage.createLocationSendMessage( userName: 'user1',latitude: 39.12,longitude:103.25,locationAddress: 'beijing' );
    expect(message.type, EMMessageType.LOCATION);
    expect(message.direction, Direction.SEND);
  });

  test('EMMessage.createFileSendMessage() creates a file message', () {
    EMMessage message = EMMessage.createFileSendMessage(userName: 'user1',filePath: "C:\test.c");
    expect(message.type, EMMessageType.FILE);
    expect(message.direction, Direction.SEND);
  });

  test('EMMessage.createImageSendMessage() creates an image message', () {
    EMMessage message =
    EMMessage.createImageSendMessage(userName: 'user1',filePath: 'c:\image1.png',sendOriginalImage: true);
    expect(message.type, EMMessageType.IMAGE);
    expect(message.direction, Direction.SEND);
  });


  test('EMMessage.createCustomSendMessage() creates a Custom message', () {
    EMMessage message =
    EMMessage.createCustomSendMessage(event: 'event', userName: 'user1',params: {"params":"ceshi"});
    expect(message.type, EMMessageType.CUSTOM);
    expect(message.direction, Direction.SEND);
  });

}
