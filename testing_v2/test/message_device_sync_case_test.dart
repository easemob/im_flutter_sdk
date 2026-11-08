import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/report.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/execution.dart';

const _caseName = '5.0.0-multi-message-device-sync-positive';

class _Agent implements AgentClient {
  _Agent(this.role, this.calls, this.respond);

  final String role;
  final List<String> calls;
  final Future<Envelope> Function(String, String, JsonObject) respond;
  final events = <AgentEvent>[];

  @override
  Future<Envelope> runCommand(
      String api, JsonObject params, int timeoutMs) async {
    calls.add('$role:$api');
    return respond(role, api, params);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    final available =
        events.where((event) => event.seq > afterSeq).take(limit).toList();
    if (available.isEmpty && waitMs > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return available;
  }

  @override
  Future<JsonObject> info() async => {};

  @override
  Future<void> finish() async {}
}

void main() {
  late Directory temporary;
  late LoadedCase loaded;
  late Map<String, _Agent> agents;
  late List<String> calls;
  late ReportCollector report;
  late JsonObject input;
  var sameDevice = false;
  var missingDevice = false;
  var includeMatchingEvent = true;
  String? disconnectedRole;
  String? failedCall;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('message-device-sync-');
    calls = [];
    report = ReportCollector();
    sameDevice = false;
    missingDevice = false;
    includeMatchingEvent = true;
    disconnectedRole = null;
    failedCall = null;
  });

  tearDown(() async => temporary.delete(recursive: true));

  Future<void> execute({bool includeRecipient = true}) async {
    final source = Directory(p.join(temporary.path, 'input'));
    await source.create();
    final metadata =
        jsonDecode(await File('data/$_caseName.json').readAsString())
            as JsonObject;
    await File(p.join(source.path, '$_caseName.json'))
        .writeAsString(jsonEncode(metadata));
    final yaml = await File('data/$_caseName.yaml').readAsString();
    await File(p.join(source.path, '$_caseName.yaml')).writeAsString(
        yaml.replaceFirst('stepTimeoutMs: 30000', 'stepTimeoutMs: 30'));
    final service = DataService();
    loaded = await CaseLoader(service).freeze(
        p.join(source.path, '$_caseName.yaml'),
        Directory(p.join(temporary.path, 'cases')));
    final prepared = service.createCaseData(
        context: OperationContext(
            runId: 'run-sync',
            operationId: 'prepare-sync',
            tmpDirectory: temporary,
            redactor: SecretRedactor()),
        environment: {
          'appKey': 'org#app',
          'accounts': [
            {'id': 'user-a', 'token': 'token-a'},
            {'id': 'user-b', 'token': 'token-b'}
          ],
          'groups': <Object?>[],
          'rooms': <Object?>[]
        },
        caseName: loaded.definition.name,
        caseBasename: _caseName,
        attempt: 1,
        accounts: {
          'account1': 'user-a',
          if (includeRecipient) 'account2': 'user-b'
        },
        metadata: loaded.metadata);
    expect(prepared.isSuccess, isTrue);
    final caseData = prepared.data!;
    input = caseData.input;
    agents = {
      for (final role in ['a1', 'a2'])
        role: _Agent(role, calls, (role, api, params) async {
          if ('$role:$api' == failedCall) {
            return const Envelope(
                success: false,
                status: 'error',
                failureKind: 'sdk',
                error: {'code': 201, 'message': 'test failure'});
          }
          switch (api) {
            case 'ChatClient.init':
              if (role == 'a2') {
                expect(params['overrides'],
                    {'messagesReceiveCallbackIncludeSend': true});
              }
              return const Envelope(success: true, status: 'ok');
            case 'ChatClient.loginWithToken':
              expect(params['userId'], 'user-a');
              return const Envelope(success: true, status: 'ok');
            case 'ChatClient.getCurrentDeviceId':
              return Envelope(
                  success: true,
                  status: 'ok',
                  data: sameDevice ? 'sdk-a1' : 'sdk-$role');
            case 'ChatClient.fetchLoggedInDevices':
              expect(params['userId'], 'user-a');
              return Envelope(success: true, status: 'ok', data: [
                {'deviceUUID': 'sdk-a1'},
                if (!missingDevice) {'deviceUUID': 'sdk-a2'}
              ]);
            case 'ChatClient.isConnected':
              return Envelope(
                  success: true, status: 'ok', data: role != disconnectedRole);
            case 'ChatManager.sendMessage':
              expect(params['to'], 'user-b');
              final message = <String, Object?>{
                ...params,
                'msgId': 'server-message',
                'from': 'user-a'
              };
              // Neither partial match may satisfy the same-element assertion.
              agents['a2']!.events.add(AgentEvent(
                      seq: 1,
                      source: 'onMessagesReceived',
                      payload: {
                        'messages': [
                          {
                            ...message,
                            'body': {'type': 0, 'content': 'old text'}
                          },
                          {...message, 'msgId': 'other-message'}
                        ]
                      }));
              if (includeMatchingEvent) {
                agents['a2']!.events.add(AgentEvent(
                        seq: 2,
                        source: 'onMessagesReceived',
                        payload: {
                          'messages': [
                            {...message, 'to': 'other-recipient'},
                            message
                          ]
                        }));
              }
              return Envelope(success: true, status: 'ok', data: message);
            case 'ChatClient.logout':
              return const Envelope(success: true, status: 'ok');
            default:
              throw StateError('Unexpected command $api');
          }
        })
    };
    final global = GlobalData({
      'account': caseData.accounts,
      'biz': {
        'config': {'initConfig': caseData.initConfig},
        'input': input,
        'result': <String, Object?>{},
        'event': <String, Object?>{}
      }
    }, outputRoots: [
      'global.biz.result',
      'global.biz.event'
    ]);
    await Interpreter(
            spec: loaded.flow, agents: agents, report: report, global: global)
        .run()
        .timeout(const Duration(seconds: 2));
  }

  void expectNoSend() {
    expect(calls, isNot(contains('a1:ChatManager.sendMessage')));
    expect(
        loaded.definition.requiredBindings, contains('global.biz.result.sent'));
    expect(report.records.where((record) => record.name == 'send'), isEmpty);
  }

  void expectBothLoggedOut() {
    expect(calls, contains('a1:ChatClient.logout'));
    expect(calls, contains('a2:ChatClient.logout'));
  }

  test(
      'requires two online SDK identities and an exact cached synchronized message',
      () async {
    await execute();
    expect(report.records, hasLength(13));
    expect(report.records.every((record) => record.status == 'passed'), isTrue);
    expect(loaded.definition.requiredBindings.toSet(),
        report.records.map((record) => record.result!['binding']).toSet());
    final notification = report.records
        .singleWhere((record) => record.name == 'onMessagesReceived');
    expect(notification.result!['seq'], 2);
    expect(calls.indexOf('a1:ChatClient.loginWithToken'),
        lessThan(calls.indexOf('a2:ChatClient.loginWithToken')));
    expect(calls.indexOf('a2:ChatClient.loginWithToken'),
        lessThan(calls.indexOf('a1:ChatClient.isConnected')));
    expect(calls.where((call) => call == 'a1:ChatManager.sendMessage'),
        hasLength(1));
    expectBothLoggedOut();
  });

  test('missing recipient is a configuration failure before SDK dispatch',
      () async {
    await execute(includeRecipient: false);
    expect(calls, isEmpty);
    expectNoSend();
    expect(
        report.records.any((r) => r.result?['failureKind'] == 'tool'), isTrue);
  });

  test('duplicate SDK identity blocks sending but preserves both logouts',
      () async {
    sameDevice = true;
    await execute();
    expectNoSend();
    expectBothLoggedOut();
  });

  test('missing online device fails even when the list API succeeds', () async {
    missingDevice = true;
    await execute();
    expect(report.records.singleWhere((r) => r.name == 'online_devices').status,
        'failed');
    expectNoSend();
    expectBothLoggedOut();
  });

  test('first device disconnected after second login prevents sending',
      () async {
    disconnectedRole = 'a1';
    await execute();
    expectNoSend();
    expectBothLoggedOut();
  });

  test('second login failure still logs out the first device', () async {
    failedCall = 'a2:ChatClient.loginWithToken';
    await execute();
    expectNoSend();
    expect(calls, contains('a1:ChatClient.logout'));
    expect(calls, isNot(contains('a2:ChatClient.logout')));
  });

  test('send failure is not retried and both devices log out', () async {
    failedCall = 'a1:ChatManager.sendMessage';
    await execute();
    expect(calls.where((call) => call == failedCall), hasLength(1));
    expect(report.records.where((r) => r.kind == 'wait_event'), isEmpty);
    expectBothLoggedOut();
  });

  test(
      'partial matches across messages never pass the synchronization assertion',
      () async {
    includeMatchingEvent = false;
    await execute();
    expect(
        report.records
            .singleWhere((r) => r.name == 'onMessagesReceived')
            .status,
        'timeout');
    expectBothLoggedOut();
  });

  test('one failed logout does not suppress the other device logout', () async {
    failedCall = 'a1:ChatClient.logout';
    await execute();
    expectBothLoggedOut();
    expect(
        report.records
            .singleWhere((r) => r.name == 'logout' && r.agent == 'a1')
            .status,
        'failed');
    expect(
        report.records
            .singleWhere((r) => r.name == 'logout' && r.agent == 'a2')
            .status,
        'passed');
  });
}
