import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:test/test.dart';

class _Agent implements AgentClient {
  final calls = <String>[];
  final events = <AgentEvent>[];
  late Future<Envelope> Function(String, Map<String, Object?>) respond;

  @override
  Future<Map<String, Object?>> info() async => {};

  @override
  Future<Envelope> runCommand(
      String api, Map<String, Object?> params, int timeoutMs) async {
    calls.add(api);
    return respond(api, params);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
          {int limit = 200, int waitMs = 1000}) async =>
      events.where((event) => event.seq > afterSeq).take(limit).toList();

  @override
  Future<void> finish() async {}
}

void main() {
  late Map<String, _Agent> agents;
  late GlobalData global;

  setUp(() {
    agents = {'alice': _Agent(), 'bob': _Agent()};
    global = GlobalData({
      'account': {
        'account1': {'userId': 'user-a', 'userToken': 'token-a'},
        'account2': {'userId': 'user-b', 'userToken': 'token-b'},
      },
      'biz': {
        'config': {
          'initConfig': {'appKey': 'org#app'}
        },
        'input': {
          'messageContent': 'unique-message',
          'inviteReason': 'unique-invite'
        },
        'result': <String, Object?>{},
        'event': <String, Object?>{},
      },
    }, outputRoots: [
      'global.biz.result',
      'global.biz.event'
    ]);
  });

  Future<ReportCollector> execute(String feature) async {
    final file = File('data/5.0.0-multi-$feature-positive.yaml');
    final spec = parseFlow(
        (await file.readAsString())
            .replaceAll('stepTimeoutMs: 30000', 'stepTimeoutMs: 30'),
        sourcePath: file.absolute.path);
    final report = ReportCollector();
    await Interpreter(
            spec: spec, agents: agents, report: report, global: global)
        .run();
    return report;
  }

  void readResponses(
      {bool wrongLoadedMessage = false,
      bool omitReceipt = false,
      bool loginFails = false}) {
    final message = <String, Object?>{
      'msgId': 'server-message',
      'from': 'user-a',
      'to': 'user-b',
      'chatType': 0,
      'body': {'type': 0, 'content': 'unique-message'},
    };
    for (final role in agents.keys) {
      agents[role]!.respond = (api, params) async {
        if (loginFails &&
            role == 'alice' &&
            api == 'ChatClient.loginWithToken') {
          return const Envelope(
              success: false,
              status: 'error',
              failureKind: 'sdk',
              error: {'code': 201, 'message': 'login failed'});
        }
        if (api == 'ChatClient.isConnected') {
          return const Envelope(success: true, status: 'ok', data: true);
        }
        if (api == 'ChatManager.sendMessage') {
          agents['bob']!
              .events
              .add(AgentEvent(seq: 1, source: 'onMessagesReceived', payload: {
                'messages': [message]
              }));
          return Envelope(success: true, status: 'ok', data: message);
        }
        if (api == 'ChatManager.loadMessage') {
          expect(params['messageId'], 'server-message');
          return Envelope(success: true, status: 'ok', data: {
            ...message,
            if (wrongLoadedMessage) 'msgId': 'wrong-message'
          });
        }
        if (api == 'ChatManager.sendMessageReadReceipts') {
          expect(params['messages'], [message]);
          // A wrong receipt precedes the exact receipt, before the command reply.
          agents['alice']!.events.add(const AgentEvent(
                  seq: 1,
                  source: 'onMessageReadReceipts',
                  payload: {
                    'receipts': [
                      {
                        'messageId': 'server-message',
                        'conversationId': 'other-user',
                        'isPeerReceipt': true
                      },
                      {
                        'messageId': 'other-message',
                        'conversationId': 'user-b',
                        'isPeerReceipt': true
                      },
                    ]
                  }));
          if (!omitReceipt) {
            agents['alice']!.events.add(const AgentEvent(
                    seq: 2,
                    source: 'onMessageReadReceipts',
                    payload: {
                      'receipts': [
                        {
                          'messageId': 'server-message',
                          'conversationId': 'user-b',
                          'isPeerReceipt': true
                        },
                      ]
                    }));
          }
        }
        return const Envelope(success: true, status: 'ok');
      };
    }
  }

  test(
      'read receipt matches one complete receipt and passes the loaded message',
      () async {
    readResponses();
    final report = await execute('message-read-receipt');
    expect(report.records, hasLength(13));
    expect(report.records.every((record) => record.status == 'passed'), isTrue);
    expect(
        report.records
            .singleWhere((record) => record.name == 'onMessageReadReceipts')
            .result!['seq'],
        2);
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test(
      'a successful load with the wrong message blocks acknowledgement and still logs out',
      () async {
    readResponses(wrongLoadedMessage: true);
    final report = await execute('message-read-receipt');
    expect(
        report.records
            .singleWhere((record) => record.name == 'load_received')
            .status,
        'failed');
    expect(agents['bob']!.calls,
        isNot(contains('ChatManager.sendMessageReadReceipts')));
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test(
      'missing target receipt cannot borrow fields from different receipts and preserves logout',
      () async {
    readResponses(omitReceipt: true);
    final report = await execute('message-read-receipt');
    expect(
        report.records
            .singleWhere((record) => record.name == 'onMessageReadReceipts')
            .status,
        'timeout');
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test('a failed login prevents sending and only the logged-in peer exits',
      () async {
    readResponses(loginFails: true);
    await execute('message-read-receipt');
    expect(agents['alice']!.calls, isNot(contains('ChatManager.sendMessage')));
    expect(agents['alice']!.calls, isNot(contains('ChatClient.logout')));
    expect(agents['bob']!.calls.last, 'ChatClient.logout');
  });

  void contactResponses({
    bool omitCurrentInvite = false,
    bool omitAcceptanceEvent = false,
    bool uncertainAcceptance = false,
    bool cleanupFails = false,
  }) {
    for (final role in agents.keys) {
      agents[role]!.respond = (api, params) async {
        if (api == 'ChatClient.isConnected') {
          return const Envelope(success: true, status: 'ok', data: true);
        }
        if (api == 'ChatContactManager.addContact') {
          expect(params, {'userId': 'user-b', 'reason': 'unique-invite'});
          agents['bob']!.events.add(const AgentEvent(
              seq: 1,
              source: 'onContactInvited',
              payload: {'userId': 'user-a', 'reason': 'old-invite'}));
          if (!omitCurrentInvite) {
            agents['bob']!.events.add(const AgentEvent(
                seq: 2,
                source: 'onContactInvited',
                payload: {'userId': 'user-a', 'reason': 'unique-invite'}));
          }
        }
        if (api == 'ChatContactManager.acceptInvitation') {
          expect(params, {'userId': 'user-a'});
          if (uncertainAcceptance) {
            return const Envelope(
                success: false,
                status: 'timeout',
                failureKind: 'timeout',
                error: {'code': -1, 'message': 'response missing'});
          }
          if (!omitAcceptanceEvent) {
            agents['alice']!.events.add(const AgentEvent(
                seq: 1,
                source: 'onFriendRequestAccepted',
                payload: {'userId': 'user-b'}));
          }
        }
        if (api == 'ChatContactManager.deleteContact') {
          expect(params, {'userId': 'user-b', 'keepConversation': true});
          if (cleanupFails) {
            return const Envelope(
                success: false,
                status: 'error',
                failureKind: 'sdk',
                error: {'code': 201, 'message': 'cleanup failed'});
          }
        }
        return const Envelope(success: true, status: 'ok');
      };
    }
  }

  test(
      'contact acceptance waits for this invitation and recycles only its peer',
      () async {
    contactResponses();
    final report = await execute('contact-add');
    expect(report.records, hasLength(13));
    expect(report.records.every((record) => record.status == 'passed'), isTrue);
    expect(
        report.records
            .singleWhere((record) => record.name == 'onContactInvited')
            .result!['seq'],
        2);
    expect(
        agents['alice']!.calls, contains('ChatContactManager.deleteContact'));
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test(
      'a historical invitation cannot trigger acceptance or relationship cleanup',
      () async {
    contactResponses(omitCurrentInvite: true);
    final report = await execute('contact-add');
    expect(
        report.records
            .singleWhere((record) => record.name == 'onContactInvited')
            .status,
        'timeout');
    expect(agents['bob']!.calls,
        isNot(contains('ChatContactManager.acceptInvitation')));
    expect(agents['alice']!.calls,
        isNot(contains('ChatContactManager.deleteContact')));
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test('accepted relationship is removed even when its notification is absent',
      () async {
    contactResponses(omitAcceptanceEvent: true);
    final report = await execute('contact-add');
    expect(
        report.records
            .singleWhere((record) => record.name == 'onFriendRequestAccepted')
            .status,
        'timeout');
    expect(
        report.records
            .singleWhere((record) => record.name == 'delete_contact')
            .status,
        'passed');
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test('unknown acceptance is not retried or followed by a blind delete',
      () async {
    contactResponses(uncertainAcceptance: true);
    final report = await execute('contact-add');
    expect(
        report.records.singleWhere((record) => record.name == 'accept').status,
        isNot('passed'));
    expect(
        agents['bob']!
            .calls
            .where((api) => api == 'ChatContactManager.acceptInvitation'),
        hasLength(1));
    expect(agents['alice']!.calls,
        isNot(contains('ChatContactManager.deleteContact')));
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });

  test(
      'relationship cleanup failure stays visible without skipping either logout',
      () async {
    contactResponses(cleanupFails: true);
    final report = await execute('contact-add');
    expect(
        report.records
            .singleWhere((record) => record.name == 'delete_contact')
            .status,
        'failed');
    expect(
        agents.values.every((agent) => agent.calls.last == 'ChatClient.logout'),
        isTrue);
  });
}
