import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../support/recording_client.dart';

/// Pins the JSON contracts of the APIs that survived the 5.0.0 removal of the
/// deprecated Dart API (see `docs/deprecated-apis.md`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatGroup JSON contract', () {
    test('reads the native name/desc keys into the surviving fields', () {
      final group = ChatGroup.fromJson(<String, dynamic>{
        'groupId': 'g1',
        'name': 'group-name',
        'desc': 'group-desc',
        'permissionType': 1,
      });

      expect(group.groupName, 'group-name');
      expect(group.desc, 'group-desc');
    });

    test('keeps the native JSON keys when serializing', () {
      final data = ChatGroup(
        groupId: 'g1',
        groupName: 'group-name',
        desc: 'group-desc',
      ).toJson();

      expect(data['name'], 'group-name');
      expect(data['desc'], 'group-desc');
      expect(data.containsKey('description'), isFalse);
    });
  });

  group('FetchMessageOptions JSON contract', () {
    test('sends senders only', () {
      final data =
          const FetchMessageOptions(senders: <String>['alice', 'bob']).toJson();

      expect(data['senders'], <String>['alice', 'bob']);
      expect(data.containsKey('from'), isFalse);
    });
  });

  group('loadMessagesWithKeyword payload contract', () {
    late Client originalClient;
    late RecordingClient recordingClient;

    setUp(() {
      originalClient = Client.instance;
      recordingClient = RecordingClient((manager, method, arguments) async {
        return <String, Object?>{method: <Object?>[]};
      });
      Client.instance = recordingClient;
    });

    tearDown(() {
      Client.instance = originalClient;
    });

    test('sends senders only', () async {
      final conversation = ChatConversation(
        'conv-1',
        ChatConversationType.Chat,
        null,
        false,
        false,
        0,
        null,
      );

      await conversation.loadMessagesWithKeyword(
        'hello',
        senders: <String>['alice'],
      );

      final arguments = recordingClient.calls.single.arguments as Map;
      expect(arguments['senders'], <String>['alice']);
      expect(arguments.containsKey('from'), isFalse);
    });
  });

  group('ChatOptions JSON contract', () {
    test('no longer sends the removed pushConfig block', () {
      final data = ChatOptions.withAppKey('app-key').toJson();

      expect(data.containsKey('pushConfig'), isFalse);
    });
  });
}
