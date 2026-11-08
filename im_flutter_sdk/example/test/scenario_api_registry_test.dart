import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
// Use the installed platform bridge with mocked channels.
// ignore: depend_on_referenced_packages
import 'package:im_flutter_sdk_android/im_flutter_sdk_android.dart';

import 'package:example/registry/api_entry.dart';
import 'package:example/registry/apis/chat_apis.dart';
import 'package:example/registry/apis/group_apis.dart';
import 'package:example/registry/apis/user_info_apis.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const codec = JSONMethodCodec();
  const chatChannel = MethodChannel('com.chat.im/chat_manager', codec);
  const groupChannel = MethodChannel('com.chat.im/chat_group_manager', codec);
  const clientChannel = MethodChannel('com.chat.im/chat_client', codec);
  const userInfoChannel =
      MethodChannel('com.chat.im/chat_userInfo_manager', codec);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final recall =
      chatApis.singleWhere((api) => api.name == 'ChatManager.recallMessage');
  final leave =
      groupApis.singleWhere((api) => api.name == 'ChatGroupManager.leaveGroup');
  final fetchOwnInfo = userInfoApis
      .singleWhere((api) => api.name == 'ChatUserInfoManager.fetchOwnInfo');

  setUp(() {
    ClientAndroid.registerWith();
    ChatClient.getInstance.userInfoManager.clearUserInfoCache();
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(chatChannel, null);
    messenger.setMockMethodCallHandler(groupChannel, null);
    messenger.setMockMethodCallHandler(clientChannel, null);
    messenger.setMockMethodCallHandler(userInfoChannel, null);
    ChatClient.getInstance.userInfoManager.clearUserInfoCache();
  });

  test('recall forwards the server message ID and exact extension', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(chatChannel, (call) async {
      calls.add(call);
      return <String, Object?>{};
    });
    expect(
      await runApi(
          recall, {'messageId': 'server-message', 'ext': 'run-unique'}),
      {'success': true},
    );
    expect(calls.single.method, ChatMethodKeys.recallMessage);
    expect(calls.single.arguments,
        {'msgId': 'server-message', 'ext': 'run-unique'});
  });

  test('recall preserves the SDK optional-extension behavior', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(chatChannel, (call) async {
      calls.add(call);
      return <String, Object?>{};
    });
    await recall.invoke({'messageId': 'server-message'});
    await recall.invoke({'messageId': 'server-message', 'ext': null});
    expect(calls, hasLength(2));
    for (final call in calls) {
      expect(call.arguments, {'msgId': 'server-message'});
    }
  });

  test('leave forwards only the intended group ID', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(groupChannel, (call) async {
      calls.add(call);
      return <String, Object?>{};
    });
    expect(
        await runApi(leave, {'groupId': 'this-run-group'}), {'success': true});
    expect(calls.single.method, ChatMethodKeys.leaveGroup);
    expect(calls.single.arguments, {'groupId': 'this-run-group'});
  });

  for (final entry in [
    (
      api: recall,
      channel: chatChannel,
      params: {'messageId': 'server-message'}
    ),
    (api: leave, channel: groupChannel, params: {'groupId': 'this-run-group'}),
  ]) {
    test('${entry.api.name} retains the SDK error without retrying', () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(entry.channel, (call) async {
        calls++;
        return {
          'error': {'code': 500, 'description': 'injected SDK rejection'}
        };
      });
      expect(await runApi(entry.api, entry.params), {
        'success': false,
        'failureKind': 'sdk',
        'error': {'code': 500, 'message': 'injected SDK rejection'},
      });
      expect(calls, 1);
    });
  }

  test('recall event payload remains structured through JSON encoding', () {
    final message = ChatMessage.fromJson({
      'msgId': 'server-message',
      'from': 'alice',
      'to': 'bob',
      'body': {'type': 0, 'content': 'original text'},
    });
    final payload = jsonDecode(jsonEncode(toJsonSafe({
      'recallMessageInfos': [
        RecallMessageInfo(
          recallBy: 'alice',
          recallMessageId: 'server-message',
          conversationId: 'alice',
          recallMessage: message,
          ext: 'run-unique',
        ),
      ],
    }))) as Map;
    final info = (payload['recallMessageInfos'] as List).single as Map;
    expect(info['recallMessageId'], 'server-message');
    expect(info['recallBy'], 'alice');
    expect(info['conversationId'], 'alice');
    expect(info['ext'], 'run-unique');
    expect(info['recallMessage']['msgId'], 'server-message');
    expect(info['recallMessage']['body']['content'], 'original text');
  });

  test('fetchOwnInfo resolves the logged-in user and returns one user object',
      () async {
    messenger.setMockMethodCallHandler(clientChannel, (call) async {
      expect(call.method, ChatMethodKeys.getCurrentUser);
      return {call.method: 'bob'};
    });
    messenger.setMockMethodCallHandler(userInfoChannel, (call) async {
      expect(call.method, ChatMethodKeys.fetchUserInfoById);
      expect(call.arguments, {
        'userIds': ['bob']
      });
      return {
        call.method: {
          'bob': {'userId': 'bob', 'nickName': 'original nickname'}
        }
      };
    });
    expect(await runApi(fetchOwnInfo, {}), {
      'success': true,
      'data': {'userId': 'bob', 'nickName': 'original nickname', 'gender': 0},
    });
  });

  test('fetchOwnInfo forwards expireTime to the SDK cache policy', () async {
    var requests = 0;
    messenger.setMockMethodCallHandler(
        clientChannel, (call) async => {call.method: 'bob'});
    messenger.setMockMethodCallHandler(userInfoChannel, (call) async {
      requests++;
      return {
        call.method: {
          'bob': {'userId': 'bob', 'nickName': 'cached nickname'}
        }
      };
    });
    await fetchOwnInfo.invoke({'expireTime': 3600});
    await fetchOwnInfo.invoke({'expireTime': 3600});
    expect(requests, 1);
    // A negative validity period deterministically expires the same SDK cache.
    await fetchOwnInfo.invoke({'expireTime': -1});
    expect(requests, 2);
  });

  test('fetchOwnInfo preserves an absent nickname without inventing a value',
      () async {
    messenger.setMockMethodCallHandler(
        clientChannel, (call) async => {call.method: 'bob'});
    messenger.setMockMethodCallHandler(
        userInfoChannel,
        (call) async => {
              call.method: {
                'bob': {'userId': 'bob'}
              }
            });
    expect(await runApi(fetchOwnInfo, {}), {
      'success': true,
      'data': {'userId': 'bob', 'gender': 0},
    });
  });

  test('recall without the original message retains nullable fields', () {
    expect(
      jsonDecode(jsonEncode(toJsonSafe(const RecallMessageInfo(
        recallBy: 'alice',
        recallMessageId: 'server-message',
      )))),
      {
        'recallMessageId': 'server-message',
        'recallBy': 'alice',
        'conversationId': null,
        'recallMessage': null,
        'ext': null,
      },
    );
  });
}
