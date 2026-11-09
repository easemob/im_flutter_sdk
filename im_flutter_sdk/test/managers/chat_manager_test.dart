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
      return <String, Object>{
        'loadAllConversations': [
          {'convId': 'z-user', 'type': 0},
          {'convId': 'a-group', 'type': 1},
        ],
      };
    });
    Client.instance = recordingClient;
  });

  tearDown(() {
    Client.instance = originalClient;
  });

  for (final isSort in <bool?>[null, true, false]) {
    test('loadAllConversations with isSort=${isSort ?? 'omitted'}', () async {
      final manager = ChatClient.getInstance.chatManager;
      final conversations = isSort == null
          ? await manager.loadAllConversations()
          : await manager.loadAllConversations(isSort: isSort);

      expect(recordingClient.calls, hasLength(1));
      final call = recordingClient.calls.single;
      expect(call.manager, 'chat');
      expect(call.method, 'loadAllConversations');
      expect(call.arguments, {'isSort': isSort ?? true});
      // Preserve the native result order regardless of the sorting option.
      expect(conversations.map((conversation) => conversation.id), [
        'z-user',
        'a-group',
      ]);
      expect(conversations.map((conversation) => conversation.type), [
        ChatConversationType.Chat,
        ChatConversationType.GroupChat,
      ]);
    });
  }

  group('getConversationsFromDB', () {
    setUp(() {
      recordingClient = RecordingClient((manager, method, arguments) async {
        return {
          'getConversationsFromDB': {
            'cursor': 'next-page',
            'list': [
              {
                'convId': 'z-group',
                'type': 1,
                'isPinned': true,
                'pinnedTime': 42,
                'name': 'A group',
              },
              {'convId': 'a-user', 'type': 0},
            ],
          },
        };
      });
      Client.instance = recordingClient;
    });

    test('omits the initial cursor and deserializes native order and metadata',
        () async {
      final page =
          await ChatClient.getInstance.chatManager.getConversationsFromDB();

      final call = recordingClient.calls.single;
      expect(call.manager, 'chat');
      expect(call.method, 'getConversationsFromDB');
      expect(call.arguments, {'pageSize': 20});
      expect(page.cursor, 'next-page');
      expect(page.data.map((conversation) => conversation.id),
          ['z-group', 'a-user']);
      expect(page.data.first.type, ChatConversationType.GroupChat);
      expect(page.data.first.isPinned, isTrue);
      expect(page.data.first.pinnedTime, 42);
      expect(page.data.first.name, 'A group');
    });

    test('passes an explicit cursor and page size unchanged', () async {
      await ChatClient.getInstance.chatManager.getConversationsFromDB(
        cursor: 'next-page',
        pageSize: 100,
      );
      expect(recordingClient.calls.single.arguments,
          {'cursor': 'next-page', 'pageSize': 100});
    });

    test('preserves an empty first-page cursor and empty last-page result',
        () async {
      recordingClient = RecordingClient((manager, method, arguments) async {
        return {
          'getConversationsFromDB': {'cursor': '', 'list': []},
        };
      });
      Client.instance = recordingClient;

      final page = await ChatClient.getInstance.chatManager
          .getConversationsFromDB(cursor: '');
      expect(recordingClient.calls.single.arguments,
          {'cursor': '', 'pageSize': 20});
      expect(page.cursor, '');
      expect(page.data, isEmpty);
    });

    test('lets native reject invalid input and preserves its error', () async {
      recordingClient = RecordingClient((manager, method, arguments) async {
        return {
          'error': {'code': 110, 'description': 'invalid cursor'},
        };
      });
      Client.instance = recordingClient;

      await expectLater(
        ChatClient.getInstance.chatManager.getConversationsFromDB(
          cursor: 'invalid-cursor',
          pageSize: 0,
        ),
        throwsA(isA<ChatError>()
            .having((error) => error.code, 'code', 110)
            .having(
                (error) => error.description, 'description', 'invalid cursor')),
      );
      expect(recordingClient.calls.single.arguments,
          {'cursor': 'invalid-cursor', 'pageSize': 0});
    });
  });
}
