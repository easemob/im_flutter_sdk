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
  late Future<Envelope> Function(String, Json) command;

  @override
  Future<Json> info() async => {'version': 2, 'state': 'accepting'};

  @override
  Future<Envelope> runCommand(String api, Json params, int timeoutMs) {
    calls.add((api: api, params: params));
    return command(api, params);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
          {int limit = 200, int waitMs = 1000}) async =>
      events.where((event) => event.seq > afterSeq).take(limit).toList();

  @override
  Future<void> finish() async {}
}

void main() {
  const description = 'presence-current-attempt';
  late Directory temporary;
  late LoadedCase loaded;
  late Map<String, _Agent> agents;
  late ReportCollector report;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('presence-case-test-');
    loaded = await CaseLoader(DataService()).freeze(
      p.absolute('data/5.0.0-multi-presence-positive.yaml'),
      Directory(p.join(temporary.path, 'cases')),
    );
    agents = {'alice': _Agent(), 'bob': _Agent()};
    report = ReportCollector();
  });

  tearDown(() => temporary.delete(recursive: true));

  void respond({
    bool originalAvailable = true,
    bool matchingEvent = true,
    String? failedApi,
    String failedRole = 'alice',
    bool unknownPublication = false,
    bool failCleanup = false,
  }) {
    var currentDescription = '';
    var publications = 0;
    var aliceUnsubscribes = 0;
    for (final entry in agents.entries) {
      final role = entry.key;
      entry.value.command = (api, params) async {
        if (role == failedRole && api == failedApi) {
          return const Envelope(
            success: false,
            status: 'error',
            failureKind: 'sdk',
            error: {'code': 500, 'message': 'injected SDK failure'},
          );
        }
        if (api == 'ChatClient.isConnected') {
          return const Envelope(success: true, status: 'ok', data: true);
        }
        if (api == 'ChatPresenceManager.unsubscribe' && role == 'alice') {
          aliceUnsubscribes++;
          if (failCleanup && aliceUnsubscribes == 2) {
            return const Envelope(
              success: false,
              status: 'error',
              failureKind: 'sdk',
              error: {'code': 500, 'message': 'cleanup failed'},
            );
          }
        }
        if (api == 'ChatPresenceManager.fetchPresenceStatus') {
          return Envelope(success: true, status: 'ok', data: [
            {'publisher': 'unrelated-user', 'statusDescription': 'unrelated'},
            if (originalAvailable)
              {
                'publisher': 'user-b',
                'statusDescription': currentDescription,
              },
          ]);
        }
        if (api == 'ChatPresenceManager.subscribe') {
          return Envelope(success: true, status: 'ok', data: [
            {'publisher': 'user-b', 'statusDescription': currentDescription},
          ]);
        }
        if (api == 'ChatPresenceManager.publishPresence') {
          currentDescription = params['desc'] as String;
          publications++;
          if (publications == 1) {
            // A stale description and another publisher must not combine.
            agents['alice']!.events.add(const AgentEvent(
                  seq: 1,
                  source: 'onPresenceStatusChanged',
                  payload: {
                    'list': [
                      {'publisher': 'user-b', 'statusDescription': 'stale'},
                      {
                        'publisher': 'unrelated-user',
                        'statusDescription': description,
                      },
                    ],
                  },
                ));
            if (matchingEvent) {
              agents['alice']!.events.add(const AgentEvent(
                    seq: 2,
                    source: 'onPresenceStatusChanged',
                    payload: {
                      'list': [
                        {
                          'publisher': 'unrelated-user',
                          'statusDescription': 'x'
                        },
                        {
                          'publisher': 'user-b',
                          'statusDescription': description,
                        },
                      ],
                    },
                  ));
            }
            // Model a request that reached the server before its result was lost.
            if (unknownPublication) return Envelope.timeout(50);
          }
        }
        return const Envelope(success: true, status: 'ok');
      };
    }
  }

  Future<void> runCase() async {
    final yaml = await File(loaded.definition.yaml.path).readAsString();
    final flow = parseFlow(
      yaml.replaceFirst('stepTimeoutMs: 30000', 'stepTimeoutMs: 50'),
      sourcePath: loaded.definition.yaml.path,
    );
    final global = GlobalData({
      'account': {
        'alice': {'userId': 'user-a', 'userToken': 'token-a'},
        'bob': {'userId': 'user-b', 'userToken': 'token-b'},
      },
      'biz': {
        'config': {
          'initConfig': {'appKey': 'org#app'},
        },
        'input': {'presenceDescription': description, 'expiry': 600},
        'result': <String, Object?>{},
        'event': <String, Object?>{},
      },
    }, outputRoots: [
      'global.biz.result',
      'global.biz.event'
    ]);
    await Interpreter(
      spec: flow,
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

  bool getRequiredPassed() => loaded.definition.requiredBindings.every(
        (binding) => report.records.any(
          (record) =>
              record.result?['binding'] == binding && record.status == 'passed',
        ),
      );

  void expectLogouts() {
    for (final agent in agents.values) {
      expect(agent.calls.last.api, 'ChatClient.logout');
    }
  }

  test('matches one event element and restores the selected empty description',
      () async {
    respond();
    await runCase();
    expect(getRequiredPassed(), isTrue);
    expect(loaded.definition.requiredBindings, hasLength(16));
    expect(report.records.every((record) => record.status == 'passed'), isTrue);
    final event = report.records.singleWhere(
      (record) => record.name == 'onPresenceStatusChanged',
    );
    expect(event.result!['seq'], 2);
    expect(parameters('bob', 'ChatPresenceManager.publishPresence'), [
      {'desc': description},
      {'desc': ''},
    ]);
    expect(
        parameters('alice', 'ChatPresenceManager.subscribe').single['expiry'],
        600);
    expectLogouts();
  });

  test('missing original publisher prevents subscription and publication',
      () async {
    respond(originalAvailable: false);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('alice', 'ChatPresenceManager.subscribe'), isEmpty);
    expect(parameters('bob', 'ChatPresenceManager.publishPresence'), isEmpty);
    expectLogouts();
  });

  test('failed login still exits the other device without changing presence',
      () async {
    respond(failedApi: 'ChatClient.loginWithToken');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('alice', 'ChatClient.logout'), isEmpty);
    expect(agents['bob']!.calls.last.api, 'ChatClient.logout');
    expect(parameters('alice', 'ChatPresenceManager.subscribe'), isEmpty);
    expect(parameters('bob', 'ChatPresenceManager.publishPresence'), isEmpty);
  });

  test('subscription failure attempts cleanup without publishing', () async {
    respond(failedApi: 'ChatPresenceManager.subscribe');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
        parameters('alice', 'ChatPresenceManager.unsubscribe'), hasLength(2));
    expect(parameters('bob', 'ChatPresenceManager.publishPresence'), isEmpty);
    expectLogouts();
  });

  test(
      'unknown publication result restores once and never republishes the test',
      () async {
    respond(unknownPublication: true);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('bob', 'ChatPresenceManager.publishPresence'), [
      {'desc': description},
      {'desc': ''},
    ]);
    expect(
        parameters('alice', 'ChatPresenceManager.unsubscribe'), hasLength(2));
    expectLogouts();
  });

  test('query success cannot replace missing notification; cleanup still runs',
      () async {
    respond(matchingEvent: false);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
      report.records
          .singleWhere((record) => record.name == 'onPresenceStatusChanged')
          .status,
      'timeout',
    );
    expect(
      report.records
          .singleWhere((record) => record.name == 'verify_presence')
          .status,
      'passed',
    );
    expect(parameters('bob', 'ChatPresenceManager.publishPresence').last,
        {'desc': ''});
    expect(
        parameters('alice', 'ChatPresenceManager.unsubscribe'), hasLength(2));
    expectLogouts();
  });

  test(
      'unsubscribe cleanup failure cannot prevent restoration or either logout',
      () async {
    respond(failCleanup: true);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('bob', 'ChatPresenceManager.publishPresence').last,
        {'desc': ''});
    expectLogouts();
  });
}
