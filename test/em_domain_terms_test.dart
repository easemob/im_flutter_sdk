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
        EMMessage.createTxtSendMessage('this is a text message', 'user1');
    expect(message.type, EMMessageType.TXT);
    expect(message.to, 'user1');
    expect(message.direction, Direction.SEND);
    var body = message.body;
    expect(body.runtimeType, EMTextMessageBody);
  });

  test('EMMessage.createLocationSendMessage() creates a location message', () {
    EMMessage message =
        EMMessage.createLocationSendMessage(39.12, 103.25, 'beijing', 'user1');
    expect(message.type, EMMessageType.LOCATION);
    expect(message.to, 'user1');
    expect(message.direction, Direction.SEND);
    var body = message.body;
    expect(body.runtimeType, EMLocationMessageBody);
    EMLocationMessageBody location = body as EMLocationMessageBody;
    expect(location.latitude, 39.12);
    expect(location.longitude, 103.25);
    expect(location.address, 'beijing');
  });

  test('EMMessage.createFileSendMessage() creates a file message', () {
    EMMessage message = EMMessage.createFileSendMessage('C:\test.c', 'user1');
    expect(message.type, EMMessageType.FILE);
    expect(message.to, 'user1');
    expect(message.direction, Direction.SEND);
    var body = message.body;
    expect(body.runtimeType, EMFileMessageBody);
    EMFileMessageBody file = body as EMFileMessageBody;
    expect(file.localUrl, 'C:\test.c');
  });

  test('EMMessage.createImageSendMessage() creates an image message', () {
    EMMessage message =
        EMMessage.createImageSendMessage('c:\image1.png', true, 'user1');
    expect(message.type, EMMessageType.IMAGE);
    expect(message.to, 'user1');
    expect(message.direction, Direction.SEND);
    var body = message.body;
    expect(body.runtimeType, EMImageMessageBody);
    EMImageMessageBody image = body as EMImageMessageBody;
    expect(image.localUrl, 'c:\image1.png');
    expect(image.sendOriginalImage, true);
  });
}
