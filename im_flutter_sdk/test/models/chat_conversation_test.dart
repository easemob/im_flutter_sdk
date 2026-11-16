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
      return switch (method) {
        'markMessagesAsReadWithTimestamp' => <String, Object>{
            'markMessagesAsReadWithTimestamp': true,
          },
        _ => <String, Object>{},
      };
    });
    Client.instance = recordingClient;
  });

  tearDown(() {
    Client.instance = originalClient;
  });

  test('markMessagesAsReadWithTimestamp forwards the timestamp', () async {
    final conversation = ChatConversation.fromJson(<String, dynamic>{
      'convId': 'conv-1',
      'type': 0,
    });

    final result = await conversation.markMessagesAsReadWithTimestamp(1500);

    expect(result, isTrue);
    final call = recordingClient.calls.single;
    expect(call.manager, 'conversation');
    expect(call.method, 'markMessagesAsReadWithTimestamp');
    expect(call.arguments, <String, Object>{
      'type': 0,
      'convId': 'conv-1',
      'isThread': false,
      'timestamp': 1500,
    });
  });
}
