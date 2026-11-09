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
}
