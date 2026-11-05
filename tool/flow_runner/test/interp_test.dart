import 'dart:async';

import 'package:test/test.dart';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';

import 'mock_agent.dart';

/// Test harness: builds mock agents per declared role up front so tests can
/// register handlers and events BEFORE running the flow.
class Harness {
  Harness(String yaml, {Map<String, Map<String, Object?>> agentInfo = const {}})
      : spec = parseFlow(
          yaml,
          options: const ParseOptions(verifyCommandIds: false),
        ) {
    for (final role in spec.agents.keys) {
      mocks[role] = MockAgent(infoData: agentInfo[role] ?? const {});
    }
  }

  final FlowSpec spec;
  final Map<String, MockAgent> mocks = {};
  late ReportCollector report;

  Future<void> run() async {
    report = ReportCollector()..flowName = spec.name;
    final interp = Interpreter(
      spec: spec,
      agents: mocks,
      report: report,
      agentInfo: {
        for (final e in mocks.entries) e.key: e.value.infoData,
      },
    );
    await interp.run();
  }

  Map<String, int> summary() => report.summary();

  List<StepRecord> records(String kind) =>
      report.records.where((r) => r.kind == kind).toList();
}

void main() {
  group('sequential commands and data flow', () {
    test('inputs receive resolved references from earlier steps', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: create
    agent: a
    as: group
  - cmd: use
    agent: a
    inputs: {groupId: '\$group.data.groupId'}
''');
      String? seenGroupId;
      h.mocks['a']!
        ..onOk('create', {'groupId': 'g42'})
        ..on('use', (inputs) async {
          seenGroupId = inputs['groupId'] as String?;
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(seenGroupId, 'g42');
      expect(
          h.summary(), {'passed': 2, 'failed': 0, 'timeout': 0, 'skipped': 0});
    });

    test(r'built-in $agents carries handshake info', () async {
      final h = Harness(
        '''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - cmd: invite
    agent: a
    inputs: {member: '\$agents.b.userId'}
''',
        agentInfo: {
          'b': {'userId': 'u-b-99'},
        },
      );
      String? seenMember;
      h.mocks['a']!.on('invite', (inputs) async {
        seenMember = inputs['member'] as String?;
        return const Envelope(success: true, status: 'ok');
      });
      await h.run();
      expect(seenMember, 'u-b-99');
    });
  });

  group('control flow', () {
    test('if takes then / else branch', () async {
      String yaml(bool cond) => '''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - set: {ok: $cond}
  - if: \$ok == true
    then:
      - cmd: then_cmd
        agent: a
    else:
      - cmd: else_cmd
        agent: a
'''.replaceFirst(r'$cond', cond ? 'true' : 'false');

      final h1 = Harness(yaml(true));
      h1.mocks['a']!.onOk('then_cmd', null);
      await h1.run();
      expect(h1.mocks['a']!.calls, ['then_cmd']);

      final h2 = Harness(yaml(false));
      h2.mocks['a']!.onOk('else_cmd', null);
      await h2.run();
      expect(h2.mocks['a']!.calls, ['else_cmd']);
    });

    test('for over list and range with loop variable', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - set: {names: ['x', 'y', 'z']}
  - for: n in \$names
    do:
      - cmd: send
        agent: a
        inputs: {name: '\$n'}
  - for: i in 1..3
    do:
      - cmd: tick
        agent: a
        inputs: {i: '\$i'}
''');
      final seen = <String>[];
      final ticks = <Object?>[];
      h.mocks['a']!
        ..on('send', (inputs) async {
          seen.add(inputs['name'] as String);
          return const Envelope(success: true, status: 'ok');
        })
        ..on('tick', (inputs) async {
          ticks.add(inputs['i']);
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(seen, ['x', 'y', 'z']);
      expect(ticks, [1, 2, 3]);
    });

    test('while loops until condition flips', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - set: {n: 0}
  - while: \$n < 3
    do:
      - cmd: bump
        agent: a
        as: r
      - set: {n: '\$r.data.n'}
''');
      var n = 0;
      h.mocks['a']!.on('bump', (inputs) async {
        n++;
        return Envelope(success: true, status: 'ok', data: {'n': n});
      });
      await h.run();
      expect(h.mocks['a']!.calls.length, 3);
    });

    test('delay does not fail the flow', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - delay: 10
''');
      await h.run();
      expect(h.summary(), {'passed': 0, 'failed': 0, 'timeout': 0, 'skipped': 0});
    });
  });

  group('parallel and barrier', () {
    test('branches run concurrently and join before the next step', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - parallel:
      slow:
        - cmd: slow_cmd
          agent: a
      fast:
        - cmd: fast_cmd
          agent: a
  - cmd: after_join
    agent: a
''');
      final order = <String>[];
      h.mocks['a']!
        ..on('slow_cmd', (i) async {
          await Future.delayed(const Duration(milliseconds: 80));
          order.add('slow');
          return const Envelope(success: true, status: 'ok');
        })
        ..on('fast_cmd', (i) async {
          order.add('fast');
          return const Envelope(success: true, status: 'ok');
        })
        ..on('after_join', (i) async {
          order.add('join');
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      // fast finished before slow (concurrency), join happened last.
      expect(order, ['fast', 'slow', 'join']);
    });

    test('barrier holds a branch until the sibling arrives', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - parallel:
      early:
        - barrier: sync
        - cmd: after_barrier
          agent: a
      late:
        - cmd: before_barrier
          agent: a
        - barrier: sync
''');
      final order = <String>[];
      h.mocks['a']!
        ..on('after_barrier', (i) async {
          order.add('after_barrier');
          return const Envelope(success: true, status: 'ok');
        })
        ..on('before_barrier', (i) async {
          await Future.delayed(const Duration(milliseconds: 60));
          order.add('before_barrier');
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      // "early" cannot pass the barrier until "late" arrives.
      expect(order, ['before_barrier', 'after_barrier']);
    });

    test('early branch exit releases the barrier instead of hanging',
        () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
defaults: {onFail: continue}
steps:
  - parallel:
      doomed:
        - cmd: boom
          agent: a
          onFail: abort_flow
        - barrier: sync
      waiter:
        - barrier: sync
        - cmd: after_barrier
          agent: a
''');
      h.mocks['a']!
        ..onFail('boom', 'dead')
        ..onOk('after_barrier', null);
      await h.run();
      expect(h.mocks['a']!.calls, ['boom', 'after_barrier']);
    });
  });

  group('wait_event', () {
    test('matches cached events that arrived before the wait', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - wait_event: onMessageReceived
    agent: b
    as: recv
  - cmd: ack
    agent: b
    inputs: {from: '\$recv.from'}
''');
      // Event fires BEFORE the flow even starts.
      h.mocks['b']!
        ..emit('onMessageReceived', {'from': 'alice', 'msgId': 'm1'})
        ..on('ack', (inputs) async {
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(h.summary()['passed'], 2);
    });

    test('ignores non-matching source and payload', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - wait_event: onMessageReceived
    agent: b
    match: {from: 'alice'}
    as: recv
    timeoutMs: 300
''');
      h.mocks['b']!
        ..emit('onTyping', {'from': 'alice'})
        ..emit('onMessageReceived', {'from': 'bob'})
        ..emit('onMessageReceived', {'from': 'carol'});
      await h.run();
      expect(h.summary()['timeout'], 1);
    });

    test('match values are lazily evaluated against later variables',
        () async {
      // The receipt race: an early event with the wrong id must not be
      // consumed while $msg is unbound; once the parallel branch binds it,
      // the matching event is picked up.
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - parallel:
      sender:
        - cmd: send
          agent: b
          as: msg
      waiter:
        - wait_event: onMessageReadReceipts
          agent: b
          match: {msgId: '\$msg.data.msgId'}
          as: receipt
          timeoutMs: 5000
''');
      h.mocks['b']!
        ..on('send', (i) async {
          await Future.delayed(const Duration(milliseconds: 100));
          // Early wrong-id receipt arrives while $msg is still unbound.
          h.mocks['b']!.emit('onMessageReadReceipts', {'msgId': 'wrong'});
          await Future.delayed(const Duration(milliseconds: 50));
          h.mocks['b']!.emit('onMessageReadReceipts', {'msgId': 'right'});
          return const Envelope(
              success: true, status: 'ok', data: {'msgId': 'right'});
        })
        ..on('waiter', (i) async => const Envelope(success: true, status: 'ok'));
      await h.run();
      expect(h.summary()['passed'], 2);
      // The waiter consumed the event matching the eventually-bound value.
      final rec = h.records('wait_event').single;
      expect((rec.result!['payload'] as Map)['msgId'], 'right');
    });

    test('wait_event failure honors onFail continue', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - wait_event: onMessageReceived
    agent: b
    timeoutMs: 100
  - cmd: still_runs
    agent: b
''');
      h.mocks['b']!.onOk('still_runs', null);
      await h.run();
      expect(h.summary()['timeout'], 1);
      expect(h.mocks['b']!.calls, ['still_runs']);
    });
  });

  group('timeout', () {
    test('cmd timeout produces a timeout envelope and continues', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
defaults: {stepTimeoutMs: 4000}
steps:
  - cmd: hang_cmd
    agent: a
    timeoutMs: 80
    as: h
  - cmd: next
    agent: a
''');
      h.mocks['a']!
        ..hang('hang_cmd')
        ..onOk('next', null);
      await h.run();
      expect(h.summary()['timeout'], 1);
      expect(h.summary()['passed'], 1);
    });
  });

  group('failure semantics', () {
    test('failed step defaults to continue', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: bad
    agent: a
    as: b
  - cmd: good
    agent: a
''');
      h.mocks['a']!
        ..onFail('bad', 'boom')
        ..onOk('good', null);
      await h.run();
      expect(h.summary(), {'passed': 1, 'failed': 1, 'timeout': 0, 'skipped': 0});
    });

    test('onFail abort_flow ends only its branch', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - parallel:
      doomed:
        - cmd: bad
          agent: a
          onFail: abort_flow
        - cmd: never
          agent: a
      survivor:
        - cmd: fine
          agent: a
  - cmd: after
    agent: a
''');
      h.mocks['a']!
        ..onFail('bad', 'boom')
        ..onOk('fine', null)
        ..onOk('after', null);
      await h.run();
      expect(h.mocks['a']!.calls, ['bad', 'fine', 'after']);
    });

    test('onFail abort_all winds down sibling branches', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - parallel:
      doomed:
        - cmd: bad
          agent: a
          onFail: abort_all
      sibling:
        - cmd: first
          agent: a
        - cmd: second
          agent: a
  - cmd: never_reached
    agent: a
''');
      h.mocks['a']!
        ..onFail('bad', 'boom')
        ..on('first', (i) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return const Envelope(success: true, status: 'ok');
        })
        ..onOk('second', null);
      await h.run();
      // "second" runs only if it was already in flight when the abort
      // landed; "first" is awaited so it completes; the step after the
      // parallel block must never run.
      expect(h.mocks['a']!.calls, containsAll(['bad', 'first']));
      expect(h.mocks['a']!.calls, isNot(contains('never_reached')));
    });
  });

  group('skip on failed deps', () {
    test('failed producer cascades skips downstream', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: produce
    agent: a
    as: p
  - cmd: consume
    agent: a
    inputs: {x: '\$p.data.x'}
    as: c
  - cmd: consume2
    agent: a
    inputs: {x: '\$c.data.y'}
  - cmd: independent
    agent: a
''');
      h.mocks['a']!
        ..onFail('produce', 'boom')
        ..onOk('consume', {'ok': 1})
        ..onOk('consume2', {'ok': 1})
        ..onOk('independent', null);
      await h.run();
      expect(h.mocks['a']!.calls, ['produce', 'independent']);
      expect(
          h.summary(), {'passed': 1, 'failed': 1, 'timeout': 0, 'skipped': 2});
    });

    test('per-step override executes with resolved null', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: produce
    agent: a
    as: p
  - cmd: probe
    agent: a
    inputs: {x: '\$p.data.x'}
    skipOnFailedDeps: false
''');
      Object? seenX;
      h.mocks['a']!
        ..onFail('produce', 'boom')
        ..on('probe', (inputs) async {
          seenX = inputs['x'];
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(h.mocks['a']!.calls, ['produce', 'probe']);
      expect(seenX, isNull);
    });

    test('global disable executes everything', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
defaults: {skipOnFailedDeps: false}
steps:
  - cmd: produce
    agent: a
    as: p
  - cmd: consume
    agent: a
    inputs: {x: '\$p.data.x'}
''');
      h.mocks['a']!
        ..onFail('produce', 'boom')
        ..onOk('consume', null);
      await h.run();
      expect(h.mocks['a']!.calls, ['produce', 'consume']);
    });
  });

  group('report', () {
    test('records carry context, agent and status', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - parallel:
      line1:
        - cmd: do_it
          agent: a
          as: r
        - wait_event: onMessageReceived
          agent: a
          match: {k: '\$r.data.k'}
''');
      h.mocks['a']!
        ..onOk('do_it', {'k': 'v'})
        ..emit('onMessageReceived', {'k': 'v'});
      await h.run();
      expect(h.records('cmd').single.context, 'flow.line1');
      expect(h.records('cmd').single.agent, 'a');
      expect(h.records('wait_event').single.status, 'passed');
      final map = h.report.toMap();
      expect((map['summary'] as Map)['total'], 2);
      expect((map['steps'] as List).length, 2);
    });
  });
}
