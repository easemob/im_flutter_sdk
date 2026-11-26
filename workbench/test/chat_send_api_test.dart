import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
// Use the installed platform bridge with mocked channels, without changing dependencies.
// ignore: depend_on_referenced_packages
import 'package:im_flutter_sdk_android/im_flutter_sdk_android.dart';

import 'package:example/registry/apis/chat_apis.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const codec = JSONMethodCodec();
  const channel = MethodChannel('com.chat.im/chat_manager', codec);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final send =
      chatApis.singleWhere((api) => api.name == 'ChatManager.sendMessage');
  final params = <String, dynamic>{
    'to': 'bob',
    'body': {'type': 0, 'content': 'delivery-test'},
  };

  Future<void> emit(String method, Map<String, dynamic> message,
      {String? localId}) async {
    final done = Completer<void>();
    messenger.handlePlatformMessage(
      'com.chat.im/chat_message',
      codec.encodeMethodCall(MethodCall(method, {
        'localId': localId ?? message['msgId'],
        'message': {...message, 'msgId': 'server-message', 'status': 2},
        if (method == ChatMethodKeys.onMessageError)
          'error': {'code': 201, 'description': 'not logged in'},
      })),
      (_) => done.complete(),
    );
    await done.future;
  }

  setUp(() {
    ClientAndroid.registerWith();
  });

  tearDown(() {
    expect(MessageCallBackManager.getInstance.cacheHandleMap, isEmpty,
        reason: 'Each terminal path must remove its send listener.');
    messenger.setMockMethodCallHandler(channel, null);
    ChatClient.getInstance.chatManager.clearMessageEvent();
  });

  test('captures success before the native method reply and ignores other IDs',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final message = Map<String, dynamic>.from(call.arguments as Map);
      await emit(ChatMethodKeys.onMessageSuccess, message,
          localId: 'unrelated');
      await emit(ChatMethodKeys.onMessageSuccess, message);
      return {call.method: message};
    });
    final result = await send.invoke(params) as ChatMessage;
    expect(result.msgId, 'server-message');
  });

  test('captures an error before the native reply without an unhandled future',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final message = Map<String, dynamic>.from(call.arguments as Map);
      await emit(ChatMethodKeys.onMessageError, message);
      return {call.method: message};
    });
    await expectLater(send.invoke(params),
        throwsA(isA<ChatError>().having((e) => e.code, 'code', 201)));
  });

  test('removes its listener when the native method rejects the send',
      () async {
    messenger.setMockMethodCallHandler(
        channel,
        (_) async => {
              'error': {'code': 500, 'description': 'invalid recipient'}
            });
    await expectLater(send.invoke(params),
        throwsA(isA<ChatError>().having((e) => e.code, 'code', 500)));
  });

  testWidgets('times out without a callback and ignores a late completion',
      (tester) async {
    late Map<String, dynamic> message;
    messenger.setMockMethodCallHandler(channel, (call) async {
      message = Map<String, dynamic>.from(call.arguments as Map);
      return {call.method: message};
    });
    final check =
        expectLater(send.invoke(params), throwsA(isA<TimeoutException>()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 31));
    await check;
    expect(MessageCallBackManager.getInstance.cacheHandleMap, isEmpty);
    final lateEvent = emit(ChatMethodKeys.onMessageSuccess, message);
    await tester.pump();
    await lateEvent;
  });
}
