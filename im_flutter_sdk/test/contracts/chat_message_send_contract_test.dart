import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../support/recording_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Client originalClient;
  late RecordingClient recordingClient;

  setUp(() {
    originalClient = Client.instance;
    recordingClient = RecordingClient((manager, method, arguments) async {
      return <String, Object?>{
        method: Map<String, dynamic>.from(arguments as Map),
      };
    });
    Client.instance = recordingClient;
  });

  tearDown(() {
    Client.instance = originalClient;
  });

  test('sendMessage preserves the outgoing text-message contract', () async {
    final message = ChatMessage.createTxtSendMessage(
      targetId: 'room-001',
      content: 'hello',
      targetLanguages: <String>['zh-Hans', 'en'],
      chatType: ChatType.ChatRoom,
    )
      ..from = 'alice'
      ..localTime = 1700000000000
      ..serverTime = 0
      ..attributes = <String, Object>{
        'trace': 'trace-001',
        'retry': 2,
        'silent': true,
        'score': 1.5,
        'meta': <String, Object>{
          'source': 'contract-test',
          'level': 3,
        },
        'tags': <String>['a', 'b'],
      }
      ..deliverOnlineOnly = true
      ..receiverList = <String>['bob', 'carol']
      ..chatroomMessagePriority = ChatRoomMessagePriority.High;
    final localId = message.msgId;

    final returned =
        await ChatClient.getInstance.chatManager.sendMessage(message);

    expect(returned, same(message));
    expect(recordingClient.calls, hasLength(1));
    final call = recordingClient.calls.single;
    expect(call.manager, 'chat');
    expect(call.method, 'sendMessage');
    expect(call.arguments, <String, Object?>{
      'from': 'alice',
      'to': 'room-001',
      'body': <String, Object>{
        'type': MessageType.TXT.index,
        'content': 'hello',
        'targetLanguages': <String>['zh-Hans', 'en'],
      },
      'attributes': <String, Object>{
        'trace': 'trace-001',
        'retry': 2,
        'silent': true,
        'score': 1.5,
        'meta': <String, Object>{
          'source': 'contract-test',
          'level': 3,
        },
        'tags': <String>['a', 'b'],
      },
      'direction': MessageDirection.SEND.index,
      'hasRead': true,
      'hasReadAck': false,
      'hasDeliverAck': false,
      'needGroupAck': false,
      'msgId': localId,
      'convId': 'room-001',
      'chatType': ChatType.ChatRoom.index,
      'localTime': 1700000000000,
      'serverTime': 0,
      'status': MessageStatus.PROGRESS.index,
      'isThread': false,
      'isContentReplaced': false,
      'chatroomMessagePriority': ChatRoomMessagePriority.High.index,
      'deliverOnlineOnly': true,
      'receiverList': <String>['bob', 'carol'],
    });
  });
}
