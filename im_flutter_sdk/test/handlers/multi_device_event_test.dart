import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// Captures the native-event handler [ChatClient] registers so a test can replay
/// exactly what the platform sends for a multi-device change.
final class _CapturingClient extends Client {
  Future<dynamic> Function(MethodCall call)? nativeEventHandler;

  @override
  void updateNativeHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    nativeEventHandler = handler;
  }

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return <String, Object?>{};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final capturingClient = _CapturingClient();
  late Future<dynamic> Function(MethodCall call) dispatch;
  late ChatClient client;

  setUpAll(() {
    // ChatClient registers its native-event handler when the singleton is first
    // created, so the capturing client must be installed before that.
    Client.instance = capturingClient;
    client = ChatClient.getInstance;
    dispatch = capturingClient.nativeEventHandler!;
  });

  late List<ChatMultiDevicesEvent> received;
  late String? receivedChatThreadId;
  late List<String>? receivedChatThreadUserIds;

  setUp(() {
    received = <ChatMultiDevicesEvent>[];
    receivedChatThreadId = null;
    receivedChatThreadUserIds = null;
    client.addMultiDeviceEventHandler(
      'multi-device-event-test',
      ChatMultiDeviceEventHandler(
        onGroupEvent: (event, groupId, userIds) => received.add(event),
        onChatThreadEvent: (event, chatThreadId, userIds) {
          received.add(event);
          receivedChatThreadId = chatThreadId;
          receivedChatThreadUserIds = userIds;
        },
      ),
    );
  });

  tearDown(() {
    client.removeMultiDeviceEventHandler('multi-device-event-test');
  });

  Future<void> sendGroupEvent(int? value) {
    final args = <String, Object?>{
      'event': value,
      'target': 'group-id',
      'userIds': <String>['member-id'],
    };
    return dispatch(MethodCall(ChatMethodKeys.onMultiDeviceGroupEvent, args));
  }

  Future<void> sendChatThreadEvent(int? value) {
    final args = <String, Object?>{
      'event': value,
      'target': 'thread-id',
      'userIds': <String>['member-id'],
    };
    return dispatch(MethodCall(ChatMethodKeys.onMultiDeviceThreadEvent, args));
  }

  test('conversion covers every value the 4.25.0 native SDKs declare', () {
    // Values mapped by lib/src/internal/chat_transform_tools.dart for the
    // HyphenateChat 4.22 native SDKs.
    const nativeValues = <int>[
      -1,
      2,
      3,
      4,
      5,
      6,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      40,
      41,
      42,
      43,
      44,
      45,
      52,
      60,
      61,
      62,
      63,
      64,
    ];
    for (final value in nativeValues) {
      expect(
        convertIntToChatMultiDevicesEvent(value),
        isNotNull,
        reason: 'native value $value has no Dart mapping',
      );
    }
  });

  test('delivers group events', () async {
    const expected = <int, ChatMultiDevicesEvent>{
      10: ChatMultiDevicesEvent.GROUP_CREATE,
      11: ChatMultiDevicesEvent.GROUP_DESTROY,
      20: ChatMultiDevicesEvent.GROUP_KICK,
    };
    for (final entry in expected.entries) {
      received.clear();
      await sendGroupEvent(entry.key);
      expect(received, <ChatMultiDevicesEvent>[entry.value],
          reason: 'native value ${entry.key}');
    }
  });

  test('delivers thread events with target and users', () async {
    const expected = <int, ChatMultiDevicesEvent>{
      40: ChatMultiDevicesEvent.CHAT_THREAD_CREATE,
      41: ChatMultiDevicesEvent.CHAT_THREAD_DESTROY,
      42: ChatMultiDevicesEvent.CHAT_THREAD_JOIN,
      43: ChatMultiDevicesEvent.CHAT_THREAD_LEAVE,
    };
    for (final entry in expected.entries) {
      received.clear();
      await sendChatThreadEvent(entry.key);
      expect(received, <ChatMultiDevicesEvent>[entry.value],
          reason: 'native value ${entry.key}');
      expect(receivedChatThreadId, 'thread-id',
          reason: 'native value ${entry.key}');
      expect(receivedChatThreadUserIds, <String>['member-id'],
          reason: 'native value ${entry.key}');
    }
  });
}
