/// Regression guard for the YAML / JSON snippets embedded in README.md:
/// they must keep parsing and matching. Update this test together with the
/// README whenever the flow language evolves.
library;

import 'dart:convert';

import 'package:flow_runner/expect.dart';
import 'package:flow_runner/parser.dart';
import 'package:test/test.dart';

void main() {
  test('README flow YAML snippets parse (all step kinds)', () {
    const yaml = '''
version: 1
name: readme_examples
flowTimeoutMs: 120000

agents:
  alice:
    endpoint: 'http://127.0.0.1:8801'
    script: ''
    meta: {udid: 'SIM-A'}
  bob:
    endpoint: 'http://127.0.0.1:8802'

defaults:
  stepTimeoutMs: 30000
  onFail: continue
  skipOnFailedDeps: true

steps:
  - set: {attempt: 1, target: 'unset'}
  - delay: 1000
  - cmd: create_group
    agent: alice
    as: group
    timeoutMs: 20000
    onFail: abort_flow
    skipOnFailedDeps: false
  - cmd: send_group_msg
    agent: alice
    inputs: {groupId: '\$group.data.groupId', text: 'hello'}
    as: msg_a
  - wait_event: onMessageReceived
    agent: bob
    match: {from: '\$agents.alice.userId', 'body.type': 0}
    as: recv
    timeoutMs: 20000
  - parallel:
      alice_line:
        - barrier: both_ready
        - cmd: send_msg
          agent: alice
      bob_line:
        - barrier: both_ready
        - wait_event: onMessageReceived
          agent: bob
  - if: '\$group.success and \$group.data.memberCount >= 2'
    then:
      - cmd: send_group_msg
        agent: alice
        inputs: {groupId: '\$group.data.groupId'}
    else:
      - cmd: report_degraded
        agent: alice
  - for: item in \$group.data.members
    do:
      - cmd: send_to_member
        agent: alice
        inputs: {userId: '\$item.userId'}
  - for: i in 1..5
    do:
      - cmd: probe
        agent: alice
  - while: '\$poll.success == false'
    do:
      - cmd: fetch_status
        agent: alice
        as: poll
''';
    final spec = parseFlow(
      yaml,
      options: const ParseOptions(verifyCommandIds: false),
    );
    expect(spec.agents.keys, containsAll(['alice', 'bob']));
    expect(
      spec.steps.map((s) => s.runtimeType.toString()).toList(),
      equals([
        'SetStep',
        'DelayStep',
        'CmdStep',
        'CmdStep',
        'WaitEventStep',
        'ParallelStep',
        'IfStep',
        'ForStep',
        'ForStep',
        'WhileStep',
      ]),
    );
  });

  test('README device-script JSON and expect blocks are valid', () {
    const deviceScript = '''
{
  "steps": [
    {
      "api": "ChatManager.sendMessage",
      "id": "send_hello",
      "params": {
        "to": "\$inputs.userId",
        "chatType": 0,
        "body": {"type": 0, "content": "\$inputs.text"}
      },
      "expect": {"success": true, "checks": [{"path": "msgId", "notEmpty": true}]}
    },
    {
      "api": "ChatGroupManager.fetchGroupInfoFromServer",
      "id": "group_info",
      "params": {"groupId": "\$inputs.groupId"},
      "expect": {"checks": [
        {"path": "group.memberCount", "gte": 2},
        {"path": "members", "containsItem": {"role": "owner"}}
      ]}
    },
    {
      "api": "ChatManager.sendMessage",
      "id": "expect_error",
      "params": {"to": "\$config.accounts.1.id"},
      "expect": {"errorCode": 110}
    }
  ]
}
''';
    final decoded = const JsonDecoder().convert(deviceScript) as Map;
    final steps = decoded['steps'] as List;
    for (final raw in steps) {
      final step = raw as Map;
      expect(step['api'], isA<String>());
      validateExpect(step['expect'], where: 'step "${step['id']}"');
    }

    // Matcher spot-checks mirroring the README semantics table.
    final positive = evaluateExpect(
      {'success': true, 'data': {'msgId': 'm1'}, 'failureKind': 'sdk'},
      steps[0]['expect'],
    );
    expect(positive.matched, isTrue);

    final negative = evaluateExpect(
      {
        'success': false,
        'data': null,
        'failureKind': 'sdk',
        'error': {'code': 110, 'message': 'x'},
      },
      steps[2]['expect'],
    );
    expect(negative.matched, isTrue);

    // Tool faults never pass regardless of the expect block.
    final toolFault = evaluateExpect(
      {'success': false, 'failureKind': 'tool', 'error': {'code': -1}},
      steps[0]['expect'],
    );
    expect(toolFault.matched, isFalse);
  });
}
