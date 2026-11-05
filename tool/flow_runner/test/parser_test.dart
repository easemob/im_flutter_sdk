import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:flow_runner/ast.dart';
import 'package:flow_runner/parser.dart';

FlowSpec parse(String yaml) => parseFlow(
      yaml,
      options: const ParseOptions(verifyCommandIds: false),
    );

void main() {
  const head = '''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: ''}
  a2: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
''';

  group('top level', () {
    test('parses agents and defaults', () {
      final spec = parse('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: ''}
defaults:
  stepTimeoutMs: 5000
  onFail: abort_flow
  skipOnFailedDeps: false
steps: []
''');
      expect(spec.agents.keys, ['a1']);
      expect(spec.defaults.stepTimeoutMs, 5000);
      expect(spec.defaults.onFail, OnFail.abortFlow);
      expect(spec.defaults.skipOnFailedDeps, isFalse);
    });

    test('rejects missing name / agents / steps', () {
      expect(() => parse('agents: {}\nsteps: []'),
          throwsA(isA<FlowParseError>()));
      expect(() => parse('name: t\nsteps: []'),
          throwsA(isA<FlowParseError>()));
      expect(() => parse('name: t\nagents: {}\nsteps: {}'),
          throwsA(isA<FlowParseError>()));
    });

    test('rejects bad endpoint', () {
      expect(
          () => parse('''
name: t
agents:
  a1: {endpoint: 'not-a-url', script: ''}
steps: []
'''),
          throwsA(isA<FlowParseError>()));
    });
  });

  group('steps', () {
    test('cmd with full fields', () {
      final spec = parse('''
$head
  - cmd: send_msg
    agent: a1
    inputs: {to: '\$group', body: 'hi'}
    as: msg
    timeoutMs: 1234
    onFail: abort_all
    skipOnFailedDeps: false
''');
      final s = spec.steps.single as CmdStep;
      expect(s.cmd, 'send_msg');
      expect(s.agent, 'a1');
      expect(s.inputs, {'to': r'$group', 'body': 'hi'});
      expect(s.as, 'msg');
      expect(s.timeoutMs, 1234);
      expect(s.onFail, OnFail.abortAll);
      expect(s.skipOnFailedDeps, isFalse);
    });

    test('cmd requires agent', () {
      expect(() => parse('$head\n  - cmd: x\n'),
          throwsA(isA<FlowParseError>()));
    });

    test('cmd referencing undeclared agent fails statically', () {
      expect(
          () => parse('$head\n  - cmd: x\n    agent: nope\n'),
          throwsA(isA<FlowParseError>()));
    });

    test('wait_event with match map', () {
      final spec = parse('''
$head
  - wait_event: onMessageReceived
    agent: a2
    match: {from: '\$agents.a1.userId', 'body.type': 0}
    as: recv
    timeoutMs: 9999
''');
      final s = spec.steps.single as WaitEventStep;
      expect(s.event, 'onMessageReceived');
      expect(s.agent, 'a2');
      expect(s.match['from'], r'$agents.a1.userId');
      expect(s.as, 'recv');
      expect(s.timeoutMs, 9999);
    });

    test('if / for / while / set / delay / barrier', () {
      final spec = parse('''
$head
  - if: \$msg.success == true
    then:
      - cmd: a
        agent: a1
    else:
      - cmd: b
        agent: a1
  - for: i in 1..3
    do:
      - cmd: c
        agent: a1
  - for: x in \$items
    do:
      - delay: 5
  - while: \$flag
    do:
      - barrier: sync
  - set: {k1: 'v', k2: '\$k1'}
''');
      expect(spec.steps[0], isA<IfStep>());
      final f1 = spec.steps[1] as ForStep;
      expect(f1.rangeStart, 1);
      expect(f1.rangeEnd, 3);
      final f2 = spec.steps[2] as ForStep;
      expect(f2.listRef, r'$items');
      expect(spec.steps[3], isA<WhileStep>());
      expect((spec.steps[3] as WhileStep).doSteps.single, isA<BarrierStep>());
      final set = spec.steps[4] as SetStep;
      expect(set.assignments['k2'], r'$k1');
    });

    test('parallel parses branches; nesting is rejected', () {
      final spec = parse('''
$head
  - parallel:
      line1:
        - cmd: a
          agent: a1
      line2:
        - cmd: b
          agent: a2
''');
      final p = spec.steps.single as ParallelStep;
      expect(p.branches.keys, ['line1', 'line2']);
      expect(p.branches['line1']!.single, isA<CmdStep>());

      expect(
          () => parse('''
$head
  - parallel:
      line1:
        - parallel:
            inner:
              - cmd: a
                agent: a1
'''),
          throwsA(isA<FlowParseError>()));
    });

    test('unknown step kind is rejected', () {
      expect(() => parse('$head\n  - teleport: now\n'),
          throwsA(isA<FlowParseError>()));
    });

    test('for spec variants', () {
      expect(() => parse('$head\n  - for: x in banana\n    do: []\n'),
          throwsA(isA<FlowParseError>()));
      expect(() => parse('$head\n  - for: 1 in 5..1\n    do: []\n'),
          throwsA(isA<FlowParseError>()));
    });
  });

  group('command id verification', () {
    late File scriptFile;

    setUp(() {
      scriptFile = File(
          '${Directory.systemTemp.path}/flow_runner_test_${DateTime.now().millisecondsSinceEpoch}.json')
        ..writeAsStringSync(jsonEncode({
          'stages': {
            'known_cmd': {'api': 'ChatManager.sendMessage'},
          }
        }));
    });

    tearDown(() => scriptFile.deleteSync());

    String yamlFor(String cmdLine) => '''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${scriptFile.path}'}
steps:
  - cmd: $cmdLine
    agent: a1
''';

    test('known cmd id passes', () {
      expect(() => parseFlow(yamlFor('known_cmd')), returnsNormally);
    });

    test('unknown cmd id is rejected with a hint', () {
      expect(
          () => parseFlow(yamlFor('ghost_cmd')),
          throwsA(isA<FlowParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('ghost_cmd'), contains('--no-verify-commands')),
          )));
    });

    test('missing script file is rejected', () {
      expect(
          () => parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '/nonexistent/x.json'}
steps:
  - cmd: any
    agent: a1
'''),
          throwsA(isA<FlowParseError>()));
    });
  });
}
