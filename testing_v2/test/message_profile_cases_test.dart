import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/execution.dart';

typedef Json = Map<String, Object?>;

class _Agent implements AgentClient {
  final calls = <({String api, Json params})>[];
  final events = <AgentEvent>[];
  late Future<Envelope> Function(String, Json) respond;

  @override
  Future<Json> info() async => {};

  @override
  Future<Envelope> runCommand(String api, Json params, int timeoutMs) {
    calls.add((api: api, params: params));
    return respond(api, params);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
          {int limit = 200, int waitMs = 1000}) async =>
      events.where((event) => event.seq > afterSeq).take(limit).toList();

  @override
  Future<void> finish() async {}

  void emit(String source, Json payload) => events.add(
      AgentEvent(seq: events.length + 1, source: source, payload: payload));
}

void main() {
  const originalMessage = <String, Object?>{
    'msgId': 'current-message',
    'from': 'user-a',
    'to': 'user-b',
    'body': {'type': 0, 'content': 'original-content'},
  };
  final editedMessage = <String, Object?>{
    ...originalMessage,
    'body': {'type': 0, 'content': 'edited-content'},
    'attributes': {'testRun': 'edit-this-run'},
  };
  const sdkFailure = Envelope(
      success: false,
      status: 'error',
      failureKind: 'sdk',
      error: {'code': 500, 'message': 'injected SDK failure'});
  late Map<String, _Agent> agents;
  late Directory temporary;
  late LoadedCase loaded;
  late ReportCollector report;

  setUp(() async {
    agents = {'alice': _Agent(), 'bob': _Agent()};
    temporary = await Directory.systemTemp.createTemp('message-profile-cases-');
    report = ReportCollector();
  });
  tearDown(() => temporary.delete(recursive: true));

  Future<void> execute(String feature) async {
    loaded = await CaseLoader(DataService()).freeze(
      p.absolute('data/5.0.0-multi-$feature-positive.yaml'),
      Directory(p.join(temporary.path, 'cases')),
    );
    final text = await File(loaded.definition.yaml.path).readAsString();
    final global = GlobalData({
      'account': {
        'account1': {'userId': 'user-a', 'userToken': 'token-a'},
        'account2': {'userId': 'user-b', 'userToken': 'token-b'},
      },
      'biz': {
        'config': {
          'initConfig': {'appKey': 'org#app'},
        },
        'input': {
          'messageContent': 'original-content',
          'editedContent': 'edited-content',
          'editMarker': 'edit-this-run',
          'recallMarker': 'recall-this-run',
          'nickname': 'nickname-this-run',
        },
        'result': <String, Object?>{},
        'event': <String, Object?>{},
      },
    }, outputRoots: [
      'global.biz.result',
      'global.biz.event'
    ]);
    await Interpreter(
      spec: parseFlow(
          text.replaceFirst('stepTimeoutMs: 30000', 'stepTimeoutMs: 30'),
          sourcePath: loaded.definition.yaml.path),
      agents: agents,
      report: report,
      global: global,
    ).run();
  }

  List<Json> parameters(String role, String api) => agents[role]!
      .calls
      .where((call) => call.api == api)
      .map((call) => call.params)
      .toList();

  bool requiredPassed() => loaded.definition.requiredBindings.every((binding) =>
      report.records.any((record) =>
          record.result?['binding'] == binding && record.status == 'passed'));

  void expectLogouts() {
    for (final agent in agents.values) {
      expect(agent.calls.last.api, 'ChatClient.logout');
    }
  }

  void messageResponses({
    bool omitReceive = false,
    bool omitEdited = false,
    bool omitRecalled = false,
    bool wrongEditReturn = false,
    bool loginFails = false,
    String? unknownApi,
  }) {
    for (final role in agents.keys) {
      agents[role]!.respond = (api, params) async {
        if (loginFails &&
            role == 'alice' &&
            api == 'ChatClient.loginWithToken') {
          return sdkFailure;
        }
        if (api == 'ChatClient.isConnected') {
          return const Envelope(success: true, status: 'ok', data: true);
        }
        if (api == 'ChatManager.sendMessage') {
          if (!omitReceive) {
            agents['bob']!.emit('onMessagesReceived', {
              'messages': [originalMessage]
            });
          }
          return const Envelope(
              success: true, status: 'ok', data: originalMessage);
        }
        if (api == 'ChatManager.modifyMessage') {
          expect(params, {
            'messageId': 'current-message',
            'content': 'edited-content',
            'attributes': {'testRun': 'edit-this-run'},
          });
          // Each near-match is wrong for a different reason.
          for (final payload in <Json>[
            {'operatorId': 'other-user', 'message': editedMessage},
            {
              'operatorId': 'user-a',
              'message': {...editedMessage, 'msgId': 'other-message'},
            },
            {
              'operatorId': 'user-a',
              'message': {
                ...editedMessage,
                'attributes': {'testRun': 'stale-edit'},
              },
            },
          ]) {
            agents['bob']!.emit('onMessageContentChanged', payload);
          }
          if (!omitEdited) {
            agents['bob']!.emit('onMessageContentChanged', {
              'operatorId': 'user-a',
              'message': editedMessage,
            });
          }
          if (unknownApi == api) return Envelope.timeout(30);
          return Envelope(success: true, status: 'ok', data: {
            ...editedMessage,
            if (wrongEditReturn) 'msgId': 'other-message',
          });
        }
        if (api == 'ChatManager.recallMessage') {
          expect(params,
              {'messageId': 'current-message', 'ext': 'recall-this-run'});
          // No single element in this batch satisfies the whole assertion.
          agents['bob']!.emit('onMessagesRecalledInfo', {
            'recallMessageInfos': [
              {
                'recallMsgId': 'current-message',
                'recallBy': 'other-user',
                'ext': 'recall-this-run',
              },
              {
                'recallMsgId': 'other-message',
                'recallBy': 'user-a',
                'ext': 'recall-this-run',
              },
              {
                'recallMsgId': 'current-message',
                'recallBy': 'user-a',
                'ext': 'stale-recall',
              },
            ],
          });
          if (!omitRecalled) {
            agents['bob']!.emit('onMessagesRecalledInfo', {
              'recallMessageInfos': [
                {
                  'recallMsgId': 'current-message',
                  'recallBy': 'user-a',
                  'ext': 'recall-this-run',
                  'msg': null,
                },
              ],
            });
          }
          if (unknownApi == api) return Envelope.timeout(30);
        }
        return const Envelope(success: true, status: 'ok');
      };
    }
  }

  test('edit requires the matching operator, message, body, and unique marker',
      () async {
    messageResponses();
    await execute('message-edit');
    expect(requiredPassed(), isTrue);
    expect(report.records, hasLength(12));
    expect(
        report.records
            .singleWhere((record) => record.name == 'onMessageContentChanged')
            .result!['seq'],
        5);
    expectLogouts();
  });

  test('an edit event for another operator or stale content cannot pass',
      () async {
    messageResponses(omitEdited: true);
    await execute('message-edit');
    expect(requiredPassed(), isFalse);
    expectLogouts();
  });

  test('an edit response for another message stops event verification',
      () async {
    messageResponses(wrongEditReturn: true);
    await execute('message-edit');
    expect(requiredPassed(), isFalse);
    expect(report.records.where((r) => r.name == 'onMessageContentChanged'),
        isEmpty);
    expectLogouts();
  });

  test('recall matches one complete item and allows an absent original message',
      () async {
    messageResponses();
    await execute('message-recall');
    expect(requiredPassed(), isTrue);
    expect(report.records, hasLength(12));
    expect(
        report.records
            .singleWhere((record) => record.name == 'onMessagesRecalledInfo')
            .result!['seq'],
        3);
    expectLogouts();
  });

  test('recall cannot combine IDs and operators from separate event items',
      () async {
    messageResponses(omitRecalled: true);
    await execute('message-recall');
    expect(requiredPassed(), isFalse);
    expectLogouts();
  });

  for (final entry in {
    'message-edit': 'ChatManager.modifyMessage',
    'message-recall': 'ChatManager.recallMessage',
  }.entries) {
    test('${entry.key} does not mutate a message the peer has not received',
        () async {
      messageResponses(omitReceive: true);
      await execute(entry.key);
      expect(requiredPassed(), isFalse);
      expect(parameters('alice', entry.value), isEmpty);
      expectLogouts();
    });

    test('${entry.key} never retries an unknown mutation result', () async {
      messageResponses(unknownApi: entry.value);
      await execute(entry.key);
      expect(requiredPassed(), isFalse);
      expect(parameters('alice', entry.value), hasLength(1));
      expectLogouts();
    });

    test('${entry.key} exits the other device after a failed login', () async {
      messageResponses(loginFails: true);
      await execute(entry.key);
      expect(requiredPassed(), isFalse);
      expect(parameters('alice', 'ChatManager.sendMessage'), isEmpty);
      expect(parameters('alice', 'ChatClient.logout'), isEmpty);
      expect(agents['bob']!.calls.last.api, 'ChatClient.logout');
    });
  }

  void profileResponses({
    String? originalNickname = 'original-nickname',
    bool originalHasNickname = true,
    bool wrongOriginalUser = false,
    bool omitNotification = false,
    bool unknownUpdate = false,
    bool subscriptionFails = false,
    bool restorationFails = false,
    bool unsubscribeFails = false,
    bool loginFails = false,
  }) {
    var updates = 0;
    var unsubscribes = 0;
    for (final role in agents.keys) {
      agents[role]!.respond = (api, params) async {
        if (loginFails &&
            role == 'alice' &&
            api == 'ChatClient.loginWithToken') {
          return sdkFailure;
        }
        if (api == 'ChatClient.init') {
          expect(params['overrides'], {'enableUserInfo': true});
        }
        if (api == 'ChatClient.isConnected') {
          return const Envelope(success: true, status: 'ok', data: true);
        }
        if (api == 'ChatUserInfoManager.fetchOwnInfo') {
          expect(role, 'bob');
          return Envelope(success: true, status: 'ok', data: {
            'userId': wrongOriginalUser ? 'other-user' : 'user-b',
            if (originalHasNickname) 'nickName': originalNickname,
            'gender': 2,
          });
        }
        if (api == 'ChatUserInfoManager.unsubscribeUsersInfo') {
          expect(role, 'alice');
          expect(params, {
            'userIds': ['user-b']
          });
          unsubscribes++;
          if (unsubscribeFails && unsubscribes == 2) return sdkFailure;
        }
        if (api == 'ChatUserInfoManager.subscribeUsersInfo') {
          expect(role, 'alice');
          expect(params, {
            'userIds': ['user-b']
          });
          if (subscriptionFails) return sdkFailure;
        }
        if (api == 'ChatUserInfoManager.updateUserInfo') {
          expect(role, 'bob');
          updates++;
          expect(params['gender'], 2,
              reason: 'The native iOS helper defaults omitted gender to zero.');
          if (updates == 1) {
            expect(params['nickname'], 'nickname-this-run');
            agents['alice']!.emit('onUserInfoUpdate', {
              'userInfos': [
                {'userId': 'user-b', 'nickName': 'old-name', 'gender': 2},
                {
                  'userId': 'other-user',
                  'nickName': 'nickname-this-run',
                  'gender': 2,
                },
              ],
            });
            if (!omitNotification) {
              agents['alice']!.emit('onUserInfoUpdate', {
                'userInfos': [
                  {
                    'userId': 'user-b',
                    'nickName': 'nickname-this-run',
                    'gender': 2,
                  },
                ],
              });
            }
            if (unknownUpdate) return Envelope.timeout(30);
          } else {
            expect(params['nickname'], originalNickname);
            if (restorationFails) return sdkFailure;
          }
          return Envelope(success: true, status: 'ok', data: {
            'userId': 'user-b',
            'nickName': params['nickname'],
            'gender': params['gender'],
          });
        }
        return const Envelope(success: true, status: 'ok');
      };
    }
  }

  for (final nickname in ['original-nickname', '']) {
    test(
        'profile restores the exact original nickname ${nickname.isEmpty ? '(empty)' : ''}',
        () async {
      profileResponses(originalNickname: nickname);
      await execute('user-info-subscribe');
      expect(requiredPassed(), isTrue);
      expect(report.records, hasLength(15));
      expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), [
        {'nickname': 'nickname-this-run', 'gender': 2},
        {'nickname': nickname, 'gender': 2},
      ]);
      expect(
          report.records
              .singleWhere((record) => record.name == 'onUserInfoUpdate')
              .result!['seq'],
          2);
      expectLogouts();
    });
  }

  for (final present in [true, false]) {
    test(
        'profile ${present ? 'null' : 'missing'} nickname forbids all mutations',
        () async {
      profileResponses(originalNickname: null, originalHasNickname: present);
      await execute('user-info-subscribe');
      expect(requiredPassed(), isFalse);
      expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), isEmpty);
      expect(parameters('alice', 'ChatUserInfoManager.subscribeUsersInfo'),
          isEmpty);
      expectLogouts();
    });
  }

  test('a profile snapshot for another user forbids subscription and mutation',
      () async {
    profileResponses(wrongOriginalUser: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), isEmpty);
    expect(
        parameters('alice', 'ChatUserInfoManager.subscribeUsersInfo'), isEmpty);
    expectLogouts();
  });

  test('a wrong profile event fails and still restores and unsubscribes',
      () async {
    profileResponses(omitNotification: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(
        parameters('bob', 'ChatUserInfoManager.updateUserInfo'), hasLength(2));
    expect(parameters('alice', 'ChatUserInfoManager.unsubscribeUsersInfo'),
        hasLength(2));
    expectLogouts();
  });

  test('an unknown profile update is restored without retrying the test value',
      () async {
    profileResponses(unknownUpdate: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), [
      {'nickname': 'nickname-this-run', 'gender': 2},
      {'nickname': 'original-nickname', 'gender': 2},
    ]);
    expectLogouts();
  });

  test('a failed subscription is cleaned up without changing profile',
      () async {
    profileResponses(subscriptionFails: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), isEmpty);
    expect(parameters('alice', 'ChatUserInfoManager.unsubscribeUsersInfo'),
        hasLength(2));
    expectLogouts();
  });

  test('a restoration failure does not skip either logout or unsubscription',
      () async {
    profileResponses(restorationFails: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(parameters('alice', 'ChatUserInfoManager.unsubscribeUsersInfo'),
        hasLength(2));
    expectLogouts();
  });

  test('an unsubscribe failure does not skip restoration or either logout',
      () async {
    profileResponses(unsubscribeFails: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(
        parameters('bob', 'ChatUserInfoManager.updateUserInfo'), hasLength(2));
    expectLogouts();
  });

  test('failed profile login exits the peer without subscription or mutation',
      () async {
    profileResponses(loginFails: true);
    await execute('user-info-subscribe');
    expect(requiredPassed(), isFalse);
    expect(parameters('bob', 'ChatUserInfoManager.updateUserInfo'), isEmpty);
    expect(
        parameters('alice', 'ChatUserInfoManager.subscribeUsersInfo'), isEmpty);
    expect(parameters('alice', 'ChatClient.logout'), isEmpty);
    expect(agents['bob']!.calls.last.api, 'ChatClient.logout');
  });
}
