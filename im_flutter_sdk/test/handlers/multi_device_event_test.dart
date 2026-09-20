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

  setUp(() {
    received = <ChatMultiDevicesEvent>[];
    client.addMultiDeviceEventHandler(
      'multi-device-event-test',
      ChatMultiDeviceEventHandler(
        onGroupEvent: (event, groupId, userIds) => received.add(event),
        onChatThreadEvent: (event, chatThreadId, userIds) =>
            received.add(event),
      ),
    );
  });

  tearDown(() {
    client.removeMultiDeviceEventHandler('multi-device-event-test');
  });

  Future<void> sendGroupEvent(int? value) {
    return dispatch(
      MethodCall(ChatMethodKeys.onMultiDeviceGroupEvent, <String, Object?>{
        'event': value,
        'target': 'group-id',
        'userIds': <String>['member-id'],
      }),
    );
  }

  Future<void> sendChatThreadEvent(int? value) {
    return dispatch(
      MethodCall(ChatMethodKeys.onMultiDeviceThreadEvent, <String, Object?>{
        'event': value,
        'target': 'thread-id',
        'userIds': <String>['member-id'],
      }),
    );
  }

  test('conversion covers every value the native SDKs declare', () {
    // Values from HyphenateChat 5.0.0: EMMultiDevicesEvent (iOS) and
    // EMMultiDeviceListener (Android). A missing mapping used to make the
    // handlers throw "Null check operator used on a null value".
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
      30,
      31,
      32,
      33,
      34,
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
      65,
      66,
    ];
    for (final value in nativeValues) {
      expect(
        convertIntToChatMultiDevicesEvent(value),
        isNotNull,
        reason: 'native value $value has no Dart mapping',
      );
    }

    // 44 and 45 were swapped: native 44 is the thread update and 45 the kick.
    expect(
      convertIntToChatMultiDevicesEvent(44),
      ChatMultiDevicesEvent.CHAT_THREAD_UPDATE,
    );
    expect(
      convertIntToChatMultiDevicesEvent(45),
      ChatMultiDevicesEvent.CHAT_THREAD_KICK,
    );
    // 34 is iOS-only (`EMMultiDevicesEventGroupUpdate`).
    expect(
      convertIntToChatMultiDevicesEvent(34),
      ChatMultiDevicesEvent.GROUP_UPDATE,
    );
  });

  test('delivers the group allow list, all-ban, and update events', () async {
    const expected = <int, ChatMultiDevicesEvent>{
      30: ChatMultiDevicesEvent.GROUP_ADD_USER_ALLOW_LIST,
      31: ChatMultiDevicesEvent.GROUP_REMOVE_USER_ALLOW_LIST,
      32: ChatMultiDevicesEvent.GROUP_ALL_BAN,
      33: ChatMultiDevicesEvent.GROUP_REMOVE_ALL_BAN,
      34: ChatMultiDevicesEvent.GROUP_UPDATE,
    };
    for (final entry in expected.entries) {
      received.clear();
      await sendGroupEvent(entry.key);
      expect(received, <ChatMultiDevicesEvent>[entry.value],
          reason: 'native value ${entry.key}');
    }
  });

  test('delivers the thread update and kick events', () async {
    const expected = <int, ChatMultiDevicesEvent>{
      44: ChatMultiDevicesEvent.CHAT_THREAD_UPDATE,
      45: ChatMultiDevicesEvent.CHAT_THREAD_KICK,
    };
    for (final entry in expected.entries) {
      received.clear();
      await sendChatThreadEvent(entry.key);
      expect(received, <ChatMultiDevicesEvent>[entry.value],
          reason: 'native value ${entry.key}');
    }
  });

  test('unmapped native values fall back to UnKnow instead of throwing',
      () async {
    // 99 is not declared by any SDK version; a null value covers a payload
    // without an "event" key. Neither may throw out of the handler.
    for (final value in <int?>[99, null]) {
      received.clear();
      await sendGroupEvent(value);
      expect(
        received,
        <ChatMultiDevicesEvent>[ChatMultiDevicesEvent.UnKnow],
        reason: 'native value $value',
      );
    }
  });
}
