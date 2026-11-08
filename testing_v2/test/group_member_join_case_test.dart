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
  late Directory temporary;
  late LoadedCase loaded;
  late Map<String, _Agent> agents;
  late ReportCollector report;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('group-join-case-test-');
    loaded = await CaseLoader(DataService()).freeze(
      p.absolute('data/5.0.0-multi-group-member-join-positive.yaml'),
      Directory(p.join(temporary.path, 'cases')),
    );
    agents = {'alice': _Agent(), 'bob': _Agent()};
    report = ReportCollector();
  });

  tearDown(() => temporary.delete(recursive: true));

  void respond({
    bool matchingEvent = true,
    String? failedApi,
    String failedRole = 'bob',
    bool unknownCreate = false,
    bool emptyGroupId = false,
    bool disconnected = false,
  }) {
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
          return Envelope(success: true, status: 'ok', data: !disconnected);
        }
        if (api == 'ChatGroupManager.createGroup') {
          expect(role, 'bob');
          expect(params['groupName'], 'unique-group');
          expect(params.containsKey('inviteMembers'), isFalse);
          expect(params['configs'], {
            'maxCount': 200,
            'isPublic': true,
            'joinApprovalRequired': false,
            'inviteNeedConfirm': false,
            'allowInvites': true,
          });
          if (unknownCreate) return Envelope.timeout(50);
          return Envelope(
              success: true,
              status: 'ok',
              data: {'groupId': emptyGroupId ? '' : 'this-run-group'});
        }
        if (api == 'ChatGroupManager.joinPublicGroup') {
          expect(role, 'alice');
          expect(params, {'groupId': 'this-run-group'});
          // Correct fields in different notifications must not combine.
          agents['bob']!.events.addAll(const [
            AgentEvent(
              seq: 1,
              source: 'onMembersJoinedFromGroup',
              payload: {
                'groupId': 'old-group',
                'userIds': ['user-a'],
              },
            ),
            AgentEvent(
              seq: 2,
              source: 'onMembersJoinedFromGroup',
              payload: {
                'groupId': 'this-run-group',
                'userIds': ['user-a-suffix', 'unrelated-user'],
              },
            ),
          ]);
          if (matchingEvent) {
            // Arrive before the join response; the wait must use its cache.
            agents['bob']!.events.add(const AgentEvent(
                  seq: 3,
                  source: 'onMembersJoinedFromGroup',
                  payload: {
                    'groupId': 'this-run-group',
                    'userIds': ['unrelated-user', 'user-a'],
                  },
                ));
          }
        }
        if (api == 'ChatGroupManager.destroyGroup') {
          expect(role, 'bob');
          expect(params, {'groupId': 'this-run-group'});
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
        'account1': {'userId': 'user-a', 'userToken': 'token-a'},
        'account2': {'userId': 'user-b', 'userToken': 'token-b'},
      },
      'biz': {
        'config': {
          'initConfig': {'appKey': 'org#app'},
        },
        'input': {'groupName': 'unique-group'},
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

  void expectNoGroupActions() {
    expect(parameters('bob', 'ChatGroupManager.createGroup'), isEmpty);
    expect(parameters('alice', 'ChatGroupManager.joinPublicGroup'), isEmpty);
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), isEmpty);
  }

  test(
      'matches this group and member in one cached event and recycles the group',
      () async {
    respond();
    await runCase();
    expect(getRequiredPassed(), isTrue);
    expect(loaded.definition.requiredBindings, hasLength(12));
    expect(report.records, hasLength(12));
    expect(report.records.every((record) => record.status == 'passed'), isTrue);
    expect(
      report.records
          .singleWhere((record) => record.name == 'onMembersJoinedFromGroup')
          .result!['seq'],
      3,
    );
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), [
      {'groupId': 'this-run-group'},
    ]);
    expectLogouts();
  });

  test('wrong group and member notifications cannot replace the target event',
      () async {
    respond(matchingEvent: false);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
      report.records
          .singleWhere((record) => record.name == 'onMembersJoinedFromGroup')
          .status,
      'timeout',
    );
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), hasLength(1));
    expectLogouts();
  });

  test('a rejected join still destroys the already created group', () async {
    respond(failedApi: 'ChatGroupManager.joinPublicGroup', failedRole: 'alice');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
        parameters('alice', 'ChatGroupManager.joinPublicGroup'), hasLength(1));
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), hasLength(1));
    expectLogouts();
  });

  test('a rejected create never joins or destroys any group', () async {
    respond(failedApi: 'ChatGroupManager.createGroup');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('bob', 'ChatGroupManager.createGroup'), hasLength(1));
    expect(parameters('alice', 'ChatGroupManager.joinPublicGroup'), isEmpty);
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), isEmpty);
    expectLogouts();
  });

  test('an unknown creation is not retried or cleaned up with an unknown ID',
      () async {
    respond(unknownCreate: true);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(parameters('bob', 'ChatGroupManager.createGroup'), hasLength(1));
    expect(parameters('alice', 'ChatGroupManager.joinPublicGroup'), isEmpty);
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), isEmpty);
    expectLogouts();
  });

  test('a successful create without a group ID cannot enable dependent actions',
      () async {
    respond(emptyGroupId: true);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
        report.records
            .singleWhere((record) => record.name == 'create_group')
            .status,
        'failed');
    expect(parameters('alice', 'ChatGroupManager.joinPublicGroup'), isEmpty);
    expect(parameters('bob', 'ChatGroupManager.destroyGroup'), isEmpty);
    expectLogouts();
  });

  test('cleanup failure stays visible and cannot skip either logout', () async {
    respond(failedApi: 'ChatGroupManager.destroyGroup');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expect(
        report.records
            .singleWhere((record) => record.name == 'destroy_group')
            .status,
        'failed');
    expectLogouts();
  });

  test('failed login prevents group creation and only the logged-in role exits',
      () async {
    respond(failedApi: 'ChatClient.loginWithToken');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expectNoGroupActions();
    expect(parameters('bob', 'ChatClient.logout'), isEmpty);
    expect(agents['alice']!.calls.last.api, 'ChatClient.logout');
  });

  test('disconnected devices cannot start group operations', () async {
    respond(disconnected: true);
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expectNoGroupActions();
    expectLogouts();
  });

  test('one logout failure cannot suppress the other logout', () async {
    respond(failedApi: 'ChatClient.logout', failedRole: 'alice');
    await runCase();
    expect(getRequiredPassed(), isFalse);
    expectLogouts();
    expect(
        report.records
            .singleWhere(
                (record) => record.agent == 'bob' && record.name == 'logout')
            .status,
        'passed');
  });
}
