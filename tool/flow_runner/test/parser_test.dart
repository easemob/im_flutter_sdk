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
      expect(
          () => parse('agents: {}\nsteps: []'), throwsA(isA<FlowParseError>()));
      expect(() => parse('name: t\nsteps: []'), throwsA(isA<FlowParseError>()));
      expect(() => parse('name: t\nagents: {}\nsteps: {}'),
          throwsA(isA<FlowParseError>()));
    });

    test('rejects bad endpoint', () {
      expect(() => parse('''
name: t
agents:
  a1: {endpoint: 'not-a-url', script: ''}
steps: []
'''), throwsA(isA<FlowParseError>()));
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
      expect(
          () => parse('$head\n  - cmd: x\n'), throwsA(isA<FlowParseError>()));
    });

    test('cmd referencing undeclared agent fails statically', () {
      expect(() => parse('$head\n  - cmd: x\n    agent: nope\n'),
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

      expect(() => parse('''
$head
  - parallel:
      line1:
        - parallel:
            inner:
              - cmd: a
                agent: a1
'''), throwsA(isA<FlowParseError>()));
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
          'init': {'appKey': 'k'},
          'steps': [
            {'id': 'known_cmd', 'api': 'ChatManager.sendMessage', 'params': {}},
            {'id': 'other_cmd', 'api': 'ChatManager.loadMessage'},
          ]
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

    test('known cmd id passes and the library is loaded', () {
      final spec = parseFlow(yamlFor('known_cmd'));
      expect(spec.scripts['a1']!.stepsById.keys,
          allOf(contains('known_cmd'), contains('other_cmd')));
      expect(spec.scripts['a1']!.stepsById['known_cmd']!['api'],
          'ChatManager.sendMessage');
      expect(spec.scripts['a1']!.init, isNotNull);
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
      expect(() => parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '/nonexistent/x.json'}
steps:
  - cmd: any
    agent: a1
'''), throwsA(isA<FlowParseError>()));
    });
  });

  group('script and env loading', () {
    late Directory tmp;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('flow_runner_load_');
    });

    tearDown(() => tmp.deleteSync(recursive: true));

    test(r'env file loads into spec.envs (the $config / $agents source)',
        () async {
      final script = File('${tmp.path}/s.json')
        ..writeAsStringSync(jsonEncode({
          'steps': [
            {'id': 'x', 'api': 'A.x', 'params': {}}
          ]
        }));
      final env = File('${tmp.path}/env.json')
        ..writeAsStringSync(jsonEncode({
          'appKey': 'k1',
          'accounts': [
            {'id': 'u1', 'token': 't1'}
          ]
        }));
      final spec = parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${script.path}', env: '${env.path}'}
steps: []
''');
      expect(spec.envs['a1']!['appKey'], 'k1');
      expect((spec.envs['a1']!['accounts'] as List).first['id'], 'u1');
    });

    test('missing env file is rejected', () {
      final script = File('${tmp.path}/s.json')
        ..writeAsStringSync(jsonEncode({
          'steps': [
            {'id': 'x', 'api': 'A.x', 'params': {}}
          ]
        }));
      expect(() => parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${script.path}', env: '${tmp.path}/missing.json'}
steps: []
'''), throwsA(isA<FlowParseError>()));
    });

    test('duplicate step ids are rejected', () {
      final script = File('${tmp.path}/s.json')
        ..writeAsStringSync(jsonEncode({
          'steps': [
            {'id': 'x', 'api': 'A.x', 'params': {}},
            {'id': 'x', 'api': 'A.y', 'params': {}},
          ]
        }));
      expect(
          () => parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${script.path}'}
steps: []
'''),
          throwsA(isA<FlowParseError>().having(
              (e) => e.toString(), 'message', contains('duplicate step id'))));
    });

    test('malformed expect blocks are rejected statically', () {
      for (final bad in [
        {
          'expect': {'sucess': true}
        }, // typo'd field
        {
          'expect': {'checks': []}
        },
        {
          'expect': {
            'checks': [
              {'path': 'x', 'equals': 1, 'gte': 2}
            ]
          }
        },
        {
          'expect': {
            'checks': [
              {'path': 'x', 'wat': 1}
            ]
          }
        },
      ]) {
        final script = File('${tmp.path}/s.json')
          ..writeAsStringSync(jsonEncode({
            'steps': [
              {'id': 'x', 'api': 'A.x', 'params': {}, ...bad},
            ]
          }));
        expect(() => parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${script.path}'}
steps: []
'''), throwsA(isA<FlowParseError>()));
      }
    });

    test('steps without id are allowed but not referencable', () {
      final script = File('${tmp.path}/s.json')
        ..writeAsStringSync(jsonEncode({
          'steps': [
            {'api': 'A.noId', 'params': {}},
            {'id': 'x', 'api': 'A.x', 'params': {}},
          ]
        }));
      final spec = parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '${script.path}'}
steps: []
''');
      expect(spec.scripts['a1']!.stepsById.keys, ['x']);
    });
  });

  group('preconditions declaration', () {
    test('parses account references independently of device roles', () {
      final spec = parse('''
name: t
agents:
  a1: {script: ''}
  a2: {script: ''}
preconditions:
  - contacts: {between: [account1, account2], state: none}
steps: []
''');
      expect(spec.preconditions.length, 1);
      final p = spec.preconditions.single;
      expect(p.kind, 'contacts');
      expect(p.between, ['account1', 'account2']);
      expect(p.state, 'none');
    });

    test('absent preconditions is fine', () {
      final spec = parse('$head  - set: {x: 1}\n');
      expect(spec.preconditions, isEmpty);
    });

    test('rejects bad shapes, states and invalid reference names', () {
      expect(() => parse('''
name: t
agents:
  a1: {script: ''}
preconditions: {contacts: x}
steps: []
'''), throwsA(isA<FlowParseError>()));
      expect(() => parse('''
name: t
agents:
  a1: {script: ''}
preconditions:
  - contacts: {between: [a1], state: none}
steps: []
'''), throwsA(isA<FlowParseError>()));
      expect(() => parse('''
name: t
agents:
  a1: {script: ''}
preconditions:
  - contacts: {between: [a1, bad-name], state: none}
steps: []
'''), throwsA(isA<FlowParseError>()));
      expect(() => parse('''
name: t
agents:
  a1: {script: ''}
  a2: {script: ''}
preconditions:
  - contacts: {between: [a1, a2], state: maybe}
steps: []
'''), throwsA(isA<FlowParseError>()));
      expect(() => parse('''
name: t
agents:
  a1: {script: ''}
preconditions:
  - bananas: {between: [a1, a1], state: none}
steps: []
'''), throwsA(isA<FlowParseError>()));
    });
  });

  group('agents-file injection', () {
    test('endpoint and token from file override the YAML declaration', () {
      final spec = parse('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', token: 'yaml-token', script: ''}
steps: []
''');
      applyAgentsFile(
          spec,
          jsonEncode([
            {
              'role': 'a1',
              'endpoint': 'http://127.0.0.1:9999',
              'token': 'file-token',
            }
          ]));
      expect(spec.agents['a1']!.endpoint.toString(), 'http://127.0.0.1:9999');
      expect(spec.agents['a1']!.token, 'file-token');
    });

    test('YAML may omit endpoint when the file supplies it', () {
      final spec = parse('''
name: t
agents:
  a1: {script: ''}
steps: []
''');
      applyAgentsFile(
          spec,
          jsonEncode([
            {'role': 'a1', 'endpoint': 'http://127.0.0.1:7001'}
          ]));
      expect(spec.agents['a1']!.endpoint!.port, 7001);
      expect(spec.agents['a1']!.token, isNull);
    });

    test('env shallow-merges over the env-file content (file wins)', () {
      final tmp = Directory.systemTemp.createTempSync('fr_agentsfile');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final envFile = File('${tmp.path}/env.json')
        ..writeAsStringSync(jsonEncode({
          'userId': 'from-file-static',
          'appkey': 'static-key',
        }));
      final spec = parseFlow('''
name: t
agents:
  a1: {endpoint: 'http://127.0.0.1:8801', script: '', env: '${envFile.path}'}
steps: []
''', options: const ParseOptions(verifyCommandIds: false));
      applyAgentsFile(
          spec,
          jsonEncode([
            {
              'role': 'a1',
              'endpoint': 'http://127.0.0.1:7002',
              'env': {'userId': 'zuoyu01', 'userToken': 't1'},
            }
          ]));
      expect(spec.envs['a1'],
          {'userId': 'zuoyu01', 'appkey': 'static-key', 'userToken': 't1'});
    });

    test('entries for undeclared roles are skipped and reported', () {
      final spec = parse("name: t\nagents:\n  a1: {script: ''}\nsteps: []");
      final skipped = applyAgentsFile(
          spec,
          jsonEncode([
            {'role': 'a1', 'endpoint': 'http://127.0.0.1:7001'},
            {'role': 'nope', 'endpoint': 'http://127.0.0.1:7002'},
          ]));
      // The flow uses a device subset: extra entries are ignored, but the
      // declared agent still gets its credentials.
      expect(skipped, ['nope']);
      expect(spec.agents['a1']!.endpoint!.port, 7001);
    });

    test('no endpoint from either source is rejected', () {
      final spec = parse('''
name: t
agents:
  a1: {script: ''}
steps: []
''');
      expect(() => applyAgentsFile(spec, '[{"role": "a1"}]'),
          throwsA(isA<FlowParseError>()));
      // Empty endpoint string counts as absent.
      expect(() => applyAgentsFile(spec, '[{"role": "a1", "endpoint": ""}]'),
          throwsA(isA<FlowParseError>()));
    });

    test('roles without a file entry keep their declaration', () {
      final spec = parse(
          "name: t\nagents:\n  a1: {endpoint: 'http://127.0.0.1:8801', script: ''}\nsteps: []");
      final skipped = applyAgentsFile(spec, '[]');
      expect(skipped, isEmpty);
      expect(spec.agents['a1']!.endpoint.toString(), 'http://127.0.0.1:8801');
    });

    test('accepts the {"agents": [...]} wrapper form', () {
      final spec = parse('''
name: t
agents:
  a1: {script: ''}
steps: []
''');
      applyAgentsFile(
          spec,
          jsonEncode({
            'agents': [
              {'role': 'a1', 'endpoint': 'http://127.0.0.1:7003'}
            ]
          }));
      expect(spec.agents['a1']!.endpoint!.port, 7003);
    });

    test('invalid JSON and non-array roots are rejected', () {
      final spec = parse(
          "name: t\nagents:\n  a1: {endpoint: 'http://127.0.0.1:8801', script: ''}\nsteps: []");
      expect(() => applyAgentsFile(spec, 'not json'),
          throwsA(isA<FlowParseError>()));
      expect(() => applyAgentsFile(spec, '{"role": "a1"}'),
          throwsA(isA<FlowParseError>()));
    });
  });
}
