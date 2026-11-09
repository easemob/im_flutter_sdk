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

enum _Scenario {
  leave('group-member-leave', 'ChatGroupManager.leaveGroup',
      'onMembersExitedFromGroup'),
  namecard('group-namecard', 'ChatGroupManager.updateGroupNamecard',
      'onUserGroupNamecardChanged'),
  sync('group-create-device-sync', 'ChatGroupManager.createGroup',
      'onGroupEvent'),
  invite('group-invite-confirm', 'ChatGroupManager.addMembers',
      'onInvitationReceivedFromGroup');

  const _Scenario(this.name, this.operation, this.event);
  final String name;
  final String operation;
  final String event;

  bool get sameAccount => this == sync;
  List<String> get roles => sameAccount ? ['a1', 'a2'] : ['alice', 'bob'];
  String get owner => sameAccount ? 'a1' : (this == invite ? 'alice' : 'bob');
  String get observer => sameAccount ? 'a2' : 'bob';
}

class _Agent implements AgentClient {
  _Agent(this.role, this.harness);
  final String role;
  final _Harness harness;
  final events = <AgentEvent>[];

  @override
  Future<Json> info() async => {'version': 2, 'state': 'accepting'};

  @override
  Future<Envelope> runCommand(String api, Json params, int timeoutMs) =>
      harness.respond(role, api, params);

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    final result = events.where((e) => e.seq > afterSeq).take(limit).toList();
    if (result.isEmpty && waitMs > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return result;
  }

  @override
  Future<void> finish() async {}
}

class _Harness {
  _Harness(this.scenario);
  final _Scenario scenario;
  final calls = <({String role, String api, Json params})>[];
  final report = ReportCollector();
  late final agents = {for (final r in scenario.roles) r: _Agent(r, this)};
  late LoadedCase loaded;
  bool matchingEvent = true;
  bool matchingUpdate = true;
  String? missingMemberRole;
  bool unknownCreate = false;
  bool sameDevice = false;
  bool missingDevice = false;
  String? failedApi;

  List<Json> parameters(String api) =>
      calls.where((c) => c.api == api).map((c) => c.params).toList();

  bool get passed => loaded.definition.requiredBindings.every((binding) =>
      report.records.any((record) =>
          record.result?['binding'] == binding && record.status == 'passed'));

  void emit(String source, Json payload) {
    final events = agents[scenario.observer]!.events;
    events.add(
        AgentEvent(seq: events.length + 1, source: source, payload: payload));
  }

  void emitTarget() {
    final Json correct;
    final List<Json> wrong;
    switch (scenario) {
      case _Scenario.leave:
        correct = {
          'groupId': 'this-run-group',
          'userIds': ['unrelated-member', 'user-a']
        };
        wrong = [
          {...correct, 'groupId': 'old-group'},
          {
            'groupId': 'this-run-group',
            'userIds': ['user-a-suffix']
          }
        ];
      case _Scenario.namecard:
        correct = {
          'groupId': 'this-run-group',
          'userId': 'user-a',
          'namecard': 'this-run-group'
        };
        wrong = [
          {...correct, 'groupId': 'old-group'},
          {...correct, 'userId': 'user-b'},
          {...correct, 'namecard': 'old-card'}
        ];
      case _Scenario.invite:
        correct = {'groupId': 'this-run-group', 'inviter': 'user-a'};
        wrong = [
          {...correct, 'groupId': 'old-group'},
          {...correct, 'inviter': 'user-b'}
        ];
      case _Scenario.sync:
        correct = {'groupId': 'this-run-group', 'event': 'GROUP_CREATE'};
        wrong = [
          {...correct, 'groupId': 'old-group'},
          {...correct, 'event': 'GROUP_DESTROY'}
        ];
    }
    for (final event in wrong) {
      emit(scenario.event, event);
    }
    if (matchingEvent) emit(scenario.event, correct);
  }

  Future<Envelope> respond(String role, String api, Json params) async {
    calls.add((role: role, api: api, params: params));
    if (api == failedApi) {
      return const Envelope(
          success: false,
          status: 'error',
          failureKind: 'sdk',
          error: {'code': 500, 'message': 'injected failure'});
    }
    switch (api) {
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
        return const Envelope(success: true, status: 'ok', data: true);
      case 'ChatGroupManager.createGroup':
        expect(role, scenario.owner);
        expect(params['groupName'], 'this-run-name');
        expect(params.containsKey('inviteMembers'), isFalse);
        if (unknownCreate) return Envelope.timeout(80);
        // Cache the callback before the method returns its group ID.
        if (scenario.sameAccount) emitTarget();
        return const Envelope(
            success: true, status: 'ok', data: {'groupId': 'this-run-group'});
      case 'ChatGroupManager.joinPublicGroup':
        expect(role, 'alice');
        expect(params, {'groupId': 'this-run-group'});
        emit('onMembersJoinedFromGroup', {
          'groupId': 'this-run-group',
          'userIds': ['user-a']
        });
      case 'ChatGroupManager.leaveGroup':
        expect(role, 'alice');
        expect(params, {'groupId': 'this-run-group'});
        emitTarget();
      case 'ChatGroupManager.updateGroupNamecard':
        expect(role, 'alice');
        expect(params,
            {'groupId': 'this-run-group', 'namecard': 'this-run-group'});
        emitTarget();
      case 'ChatGroupManager.updateGroupName':
        expect(role, 'a1');
        expect(params, {'groupId': 'this-run-group', 'name': 'updated-name'});
        emit('onGroupEvent', {'groupId': 'old-group', 'event': 'GROUP_UPDATE'});
        emit('onGroupEvent', {
          'groupId': 'this-run-group',
          'event': 'GROUP_MEMBER_ATTRIBUTES_UPDATE'
        });
        if (matchingUpdate) {
          emit('onGroupEvent',
              {'groupId': 'this-run-group', 'event': 'GROUP_UPDATE'});
        }
      case 'ChatGroupManager.fetchGroupInfoFromServer':
        expect(role, 'a2');
        expect(params, {'groupId': 'this-run-group'});
        return const Envelope(
            success: true,
            status: 'ok',
            data: {'groupId': 'this-run-group', 'name': 'updated-name'});
      case 'ChatGroupManager.addMembers':
        expect(role, 'alice');
        expect(params, {
          'groupId': 'this-run-group',
          'members': ['user-b']
        });
        emitTarget();
      case 'ChatGroupManager.acceptInvitation':
        expect(role, 'bob');
        expect(params, {'groupId': 'this-run-group', 'inviter': 'user-a'});
      case 'ChatGroupManager.fetchMemberListFromServer':
        expect(params, {'groupId': 'this-run-group', 'pageSize': 200});
        return Envelope(success: true, status: 'ok', data: {
          'list': ['user-a', if (role != missingMemberRole) 'user-b'],
          'cursor': ''
        });
      case 'ChatGroupManager.destroyGroup':
        expect(role, scenario.owner);
        expect(params, {'groupId': 'this-run-group'});
      case 'ChatClient.init':
        if (scenario == _Scenario.invite && role == 'bob') {
          expect((params['overrides'] as Map)['autoAcceptGroupInvitation'],
              isFalse);
        }
      case 'ChatClient.loginWithToken':
      case 'ChatClient.logout':
        break;
      default:
        throw StateError('Unexpected command $api');
    }
    return const Envelope(success: true, status: 'ok');
  }

  Future<void> run(Directory temporary) async {
    final version = scenario == _Scenario.invite ? '5.1.0' : '5.0.0';
    final stem = '$version-multi-${scenario.name}-positive';
    loaded = await CaseLoader(DataService()).freeze(
        p.absolute('data/$stem.yaml'),
        Directory(p.join(temporary.path, 'cases')));
    final yaml = await File(loaded.definition.yaml.path).readAsString();
    final flow = parseFlow(
        yaml.replaceFirst('stepTimeoutMs: 30000', 'stepTimeoutMs: 80'),
        sourcePath: loaded.definition.yaml.path);
    final global = GlobalData({
      'account': {
        'account1': {'userId': 'user-a', 'userToken': 'token-a'},
        if (!scenario.sameAccount)
          'account2': {'userId': 'user-b', 'userToken': 'token-b'}
      },
      'biz': {
        'config': {
          'initConfig': {'appKey': 'org#app'}
        },
        'input': {'groupName': 'this-run-name', 'updatedName': 'updated-name'},
        'result': <String, Object?>{},
        'event': <String, Object?>{}
      }
    }, outputRoots: [
      'global.biz.result',
      'global.biz.event'
    ]);
    await Interpreter(
            spec: flow, agents: agents, report: report, global: global)
        .run()
        .timeout(const Duration(seconds: 3));
  }

  void expectLogouts() {
    expect(calls.where((c) => c.api == 'ChatClient.logout').map((c) => c.role),
        unorderedEquals(scenario.roles));
  }
}

void main() {
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('group-followup-test-');
  });
  tearDown(() => temporary.delete(recursive: true));

  for (final scenario in _Scenario.values) {
    test(
        '${scenario.name}: matches the exact cached notification and cleans up',
        () async {
      final h = _Harness(scenario);
      await h.run(temporary);
      expect(h.passed, isTrue);
      final count = scenario == _Scenario.sync
          ? 17
          : (scenario == _Scenario.invite ? 15 : 14);
      expect(h.loaded.definition.requiredBindings, hasLength(count));
      expect(h.report.records, hasLength(count));
      expect(h.report.records.every((r) => r.status == 'passed'), isTrue);
      final matched =
          h.report.records.lastWhere((r) => r.name == scenario.event);
      expect(
          matched.result!['seq'], h.agents[scenario.observer]!.events.last.seq);
      expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
      h.expectLogouts();
    });

    test(
        '${scenario.name}: partial matches cannot pass and still recycle group',
        () async {
      final h = _Harness(scenario)..matchingEvent = false;
      await h.run(temporary);
      expect(h.passed, isFalse);
      expect(
          h.report.records.singleWhere((r) => r.name == scenario.event).status,
          'timeout');
      expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
      h.expectLogouts();
    });

    test('${scenario.name}: unknown creation is not retried or blindly deleted',
        () async {
      final h = _Harness(scenario)..unknownCreate = true;
      await h.run(temporary);
      expect(h.passed, isFalse);
      expect(h.parameters('ChatGroupManager.createGroup'), hasLength(1));
      expect(h.parameters('ChatGroupManager.joinPublicGroup'), isEmpty);
      expect(h.parameters('ChatGroupManager.destroyGroup'), isEmpty);
      h.expectLogouts();
    });
  }

  for (final scenario in [
    _Scenario.leave,
    _Scenario.namecard,
    _Scenario.invite
  ]) {
    test(
        '${scenario.name}: failed operation preserves cleanup and both logouts',
        () async {
      final h = _Harness(scenario)..failedApi = scenario.operation;
      await h.run(temporary);
      expect(h.passed, isFalse);
      expect(h.parameters(scenario.operation), hasLength(1));
      expect(h.report.records.where((r) => r.name == scenario.event), isEmpty);
      expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
      h.expectLogouts();
    });
  }

  test('sync: unrelated update events fail without bypassing cleanup',
      () async {
    final h = _Harness(_Scenario.sync)..matchingUpdate = false;
    await h.run(temporary);
    expect(h.passed, isFalse);
    expect(h.report.records.lastWhere((r) => r.name == 'onGroupEvent').status,
        'timeout');
    expect(h.parameters('ChatGroupManager.fetchGroupInfoFromServer'), isEmpty);
    expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
    h.expectLogouts();
  });

  for (final role in ['alice', 'bob']) {
    test('invite: missing membership on $role fails and still cleans up',
        () async {
      final h = _Harness(_Scenario.invite)..missingMemberRole = role;
      await h.run(temporary);
      expect(h.passed, isFalse);
      expect(h.parameters('ChatGroupManager.fetchMemberListFromServer'),
          hasLength(2));
      expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
      h.expectLogouts();
    });
  }

  test('invite: failed acceptance still cleans up', () async {
    final h = _Harness(_Scenario.invite)
      ..failedApi = 'ChatGroupManager.acceptInvitation';
    await h.run(temporary);
    expect(h.passed, isFalse);
    expect(h.parameters('ChatGroupManager.fetchMemberListFromServer'), isEmpty);
    expect(h.parameters('ChatGroupManager.destroyGroup'), hasLength(1));
    h.expectLogouts();
  });

  test('sync: both login commands use one account slot', () async {
    final h = _Harness(_Scenario.sync);
    await h.run(temporary);
    final logins =
        h.calls.where((c) => c.api == 'ChatClient.loginWithToken').toList();
    expect(logins.map((c) => c.role).toSet(), {'a1', 'a2'});
    expect(
        logins.every((c) =>
            c.params['userId'] == 'user-a' && c.params['token'] == 'token-a'),
        isTrue);
  });

  test('sync: one SDK identity cannot count as two devices', () async {
    final h = _Harness(_Scenario.sync)..sameDevice = true;
    await h.run(temporary);
    expect(h.passed, isFalse);
    expect(h.parameters('ChatGroupManager.createGroup'), isEmpty);
    h.expectLogouts();
  });

  test('sync: a missing online device blocks group creation', () async {
    final h = _Harness(_Scenario.sync)..missingDevice = true;
    await h.run(temporary);
    expect(h.passed, isFalse);
    expect(h.parameters('ChatGroupManager.createGroup'), isEmpty);
    h.expectLogouts();
  });

  test('failed group cleanup remains a failure and still logs out both devices',
      () async {
    final h = _Harness(_Scenario.sync)
      ..failedApi = 'ChatGroupManager.destroyGroup';
    await h.run(temporary);
    expect(h.passed, isFalse);
    expect(
        h.report.records.singleWhere((r) => r.name == 'destroy_group').status,
        'failed');
    h.expectLogouts();
  });
}
