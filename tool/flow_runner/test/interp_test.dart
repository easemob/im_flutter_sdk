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
///
/// [scripts] injects explicit device-script steps (cmd id -> step map with
/// api/params/expect). Every cmd id without an explicit step gets an
/// auto-registered passthrough step (`api` = cmd id, empty params) so most
/// flows work without boilerplate; handlers are keyed by api name.
/// [envs] injects per-agent environments ($config / $agents source).
class Harness {
  Harness(
    String yaml, {
    Map<String, Map<String, Map<String, Object?>>> scripts = const {},
    Map<String, Map<String, Object?>> envs = const {},
  }) : spec = parseFlow(
          yaml,
          options: const ParseOptions(verifyCommandIds: false),
        ) {
    for (final role in spec.agents.keys) {
      final explicit = scripts[role] ?? const {};
      final steps = <String, Map<String, Object?>>{};
      void walk(List<Step> list) {
        for (final s in list) {
          switch (s) {
            case final CmdStep c:
              if (c.agent == role &&
                  !explicit.containsKey(c.cmd) &&
                  !steps.containsKey(c.cmd)) {
                steps[c.cmd] = {
                  'api': c.cmd,
                  'params': const <String, Object?>{},
                };
              }
            case final ParallelStep p:
              p.branches.values.forEach(walk);
            case final IfStep i:
              walk(i.thenSteps);
              walk(i.elseSteps);
            case final ForStep f:
              walk(f.doSteps);
            case final WhileStep w:
              walk(w.doSteps);
            case WaitEventStep():
            case BarrierStep():
            case SetStep():
            case DelayStep():
              break;
          }
        }
      }

      walk(spec.steps);
      explicit.forEach((k, v) => steps[k] = Map<String, Object?>.from(v));
      spec.scripts[role] = DeviceScript(steps: steps);
      mocks[role] = MockAgent();
    }
    spec.envs.addAll(envs);
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
    );
    await interp.run();
  }

  Map<String, int> summary() => report.summary();

  List<StepRecord> records(String kind) =>
      report.records.where((r) => r.kind == kind).toList();
}

void main() {
  group('sequential commands and data flow', () {
    test(r'inputs reach params through declared $inputs slots', () async {
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
''', scripts: {
        'a': {
          'create': {'api': 'X.create', 'params': {}},
          'use': {
            'api': 'X.use',
            'params': {'groupId': r'$inputs.groupId'}
          },
        }
      });
      String? seenGroupId;
      h.mocks['a']!
        ..onOk('X.create', {'groupId': 'g42'})
        ..on('X.use', (params) async {
          seenGroupId = params['groupId'] as String?;
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(seenGroupId, 'g42');
      expect(
          h.summary(), {'passed': 2, 'failed': 0, 'timeout': 0, 'skipped': 0});
    });

    test(r'built-in $agents carries the agent environment', () async {
      final h = Harness(
        '''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - cmd: invite
    agent: a
    inputs: {member: '\$agents.b.accounts.0.userId'}
''',
        scripts: {
          'a': {
            'invite': {
              'api': 'X.invite',
              'params': {'member': r'$inputs.member'}
            },
          },
        },
        envs: {
          'b': {
            'accounts': [
              {'userId': 'u-b-99'}
            ]
          },
        },
      );
      String? seenMember;
      h.mocks['a']!.on('X.invite', (params) async {
        seenMember = params['member'] as String?;
        return const Envelope(success: true, status: 'ok');
      });
      await h.run();
      expect(seenMember, 'u-b-99');
    });

    test(r'script params/expect resolve $agents.<role>.<path> directly', () async {
      // Regression: _resolveParams stripped '$agents' (7 chars) but left the
      // dot, so the first path segment became '' and every nested lookup
      // resolved to null. This path is used by device-script params and
      // expect checks (unlike YAML inputs, which use the env resolver).
      final h = Harness(
        '''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - cmd: poke
    agent: a
''',
        scripts: {
          'a': {
            'poke': {
              'api': 'X.poke',
              'params': {'peer': r'$agents.b.userId'},
              'expect': {
                'success': true,
                'checks': [
                  {'path': 'ids', 'contains': r'$agents.b.userId'},
                ],
              },
            },
          },
        },
        envs: {
          'b': {'userId': 'u-b-1'},
        },
      );
      String? seenPeer;
      h.mocks['a']!.on('X.poke', (params) async {
        seenPeer = params['peer'] as String?;
        return const Envelope(
            success: true, status: 'ok', data: {'ids': ['u-b-1']});
      });
      await h.run();
      expect(seenPeer, 'u-b-1');
      expect(
          h.summary(), {'passed': 1, 'failed': 0, 'timeout': 0, 'skipped': 0});
    });

    test(r'params resolve $config, $step and $prev references', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: create
    agent: a
  - cmd: use
    agent: a
    inputs: {extra: 'flow-value'}
''', scripts: {
        'a': {
          'create': {
            'api': 'X.create',
            'params': {'appKey': r'$config.appKey'}
          },
          'use': {
            'api': 'X.use',
            'params': {
              'fromStep': r'$step.create.id',
              'fromPrev': r'$prev.id',
              'fromInputs': r'$inputs.extra',
              'cfg': r'$config.tags.0',
            }
          },
        }
      }, envs: {
        'a': {
          'appKey': 'k1',
          'tags': ['t0', 't1']
        }
      });
      Map<String, Object?>? createParams;
      Map<String, Object?>? useParams;
      h.mocks['a']!
        ..on('X.create', (params) async {
          createParams = params;
          return Envelope(
              success: true, status: 'ok', data: {'id': 'i9'});
        })
        ..on('X.use', (params) async {
          useParams = params;
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(createParams!['appKey'], 'k1');
      expect(useParams!['fromStep'], 'i9');
      expect(useParams!['fromPrev'], 'i9');
      expect(useParams!['fromInputs'], 'flow-value');
      expect(useParams!['cfg'], 't0');
    });

    test('unused inputs are reported on the step record', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: use
    agent: a
    inputs: {typoKey: 'v'}
''', scripts: {
        'a': {
          'use': {
            'api': 'X.use',
            'params': {'real': r'$inputs.other'}
          },
        }
      });
      h.mocks['a']!.onOk('X.use', null);
      await h.run();
      final rec = h.records('cmd').single;
      expect((rec.result!['unusedInputs'] as List), ['typoKey']);
    });
  });

  group('control flow', () {
    test('if takes then / else branch', () async {
      String yaml(bool cond) => '''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - set: {ok: \$cond}
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
''', scripts: {
        'a': {
          'send': {
            'api': 'X.send',
            'params': {'name': r'$inputs.name'}
          },
          'tick': {
            'api': 'X.tick',
            'params': {'i': r'$inputs.i'}
          },
        }
      });
      final seen = <String>[];
      final ticks = <Object?>[];
      h.mocks['a']!
        ..on('X.send', (params) async {
          seen.add(params['name'] as String);
          return const Envelope(success: true, status: 'ok');
        })
        ..on('X.tick', (params) async {
          ticks.add(params['i']);
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
      h.mocks['a']!.on('bump', (params) async {
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
    test('matches cached events that arrived earlier in the same flow', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - cmd: poke
    agent: b
  - wait_event: onMessageReceived
    agent: b
    as: recv
  - cmd: ack
    agent: b
    inputs: {from: '\$recv.from'}
''');
      // The callback fires during the flow (before the wait_event step
      // runs) — cached events must still be matched.
      h.mocks['b']!
        ..on('poke', (params) async {
          h.mocks['b']!
              .emit('onMessageReceived', {'from': 'alice', 'msgId': 'm1'});
          return const Envelope(success: true, status: 'ok');
        })
        ..on('ack', (params) async {
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(h.summary()['passed'], 3);
    });

    test('events from before the flow started are never matched', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - wait_event: onMessageReceived
    agent: b
    timeoutMs: 150
''');
      // Leftover from a PREVIOUS run on the same app instance: the flow
      // must not match it (cross-run event isolation).
      h.mocks['b']!
          .emit('onMessageReceived', {'from': 'alice', 'msgId': 'stale'});
      await h.run();
      expect(h.summary()['timeout'], 1);
    });

    test('sequential waits cannot rematch the same event', () async {
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - cmd: poke
    agent: b
  - wait_event: onMessageReceived
    agent: b
    as: first
  - wait_event: onMessageReceived
    agent: b
    timeoutMs: 150
''');
      h.mocks['b']!.on('poke', (params) async {
        h.mocks['b']!
            .emit('onMessageReceived', {'from': 'alice', 'msgId': 'm1'});
        return const Envelope(success: true, status: 'ok');
      });
      await h.run();
      expect(h.summary()['passed'], 2);
      expect(h.summary()['timeout'], 1);
    });

    test('concurrent waits on one agent observe independently', () async {
      // The starvation bug: one branch scanning ahead used to consume the
      // other branch's event (shared cursor advanced past unseen events).
      final h = Harness('''
name: t
agents:
  b: {endpoint: 'http://127.0.0.1:8802', script: ''}
steps:
  - parallel:
      waiter_a:
        - wait_event: onMessageReadReceipts
          agent: b
          as: receipt
          timeoutMs: 3000
      waiter_b:
        - wait_event: onMessageReceived
          agent: b
          as: recv
          timeoutMs: 3000
''');
      // Give the parallel branches a chance to enter their waits, then
      // emit receipts first, received second: a naive shared cursor
      // consumed by the receipts waiter would starve the received waiter.
      unawaited(Future<void>.delayed(const Duration(milliseconds: 20)).then((_) {
        h.mocks['b']!
          ..emit('onMessageReadReceipts', {'msgId': 'm1'})
          ..emit('onMessageReceived', {'from': 'alice'});
      }));
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

    test(r'$step reference to a failed step skips and cascades', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: produce
    agent: a
  - cmd: consume
    agent: a
  - cmd: consume2
    agent: a
  - cmd: independent
    agent: a
''', scripts: {
        'a': {
          'produce': {'api': 'X.produce', 'params': {}},
          'consume': {
            'api': 'X.consume',
            'params': {'x': r'$step.produce.data.id'}
          },
          'consume2': {
            'api': 'X.consume2',
            'params': {'x': r'$step.consume.data.id'}
          },
          'independent': {'api': 'X.independent', 'params': {}},
        }
      });
      h.mocks['a']!
        ..onFail('X.produce', 'boom')
        ..onOk('X.consume', null)
        ..onOk('X.consume2', null)
        ..onOk('X.independent', null);
      await h.run();
      expect(h.mocks['a']!.calls, ['X.produce', 'X.independent']);
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
''', scripts: {
        'a': {
          'produce': {'api': 'X.produce', 'params': {}},
          'probe': {
            'api': 'X.probe',
            'params': {'x': r'$inputs.x'}
          },
        }
      });
      Object? seenX;
      h.mocks['a']!
        ..onFail('X.produce', 'boom')
        ..on('X.probe', (params) async {
          seenX = params['x'];
          return const Envelope(success: true, status: 'ok');
        });
      await h.run();
      expect(h.mocks['a']!.calls, ['X.produce', 'X.probe']);
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

  group('expect judgment (host-side)', () {
    test('absent expect asserts success', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: plain
    agent: a
''', scripts: {
        'a': {
          'plain': {'api': 'X.plain', 'params': {}},
        }
      });
      h.mocks['a']!.onFail('X.plain', 'boom');
      await h.run();
      expect(h.summary(), {'passed': 0, 'failed': 1, 'timeout': 0, 'skipped': 0});
    });

    test('errorCode expectation passes on a matching SDK error', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: missing
    agent: a
''', scripts: {
        'a': {
          'missing': {
            'api': 'X.missing',
            'params': {},
            'expect': {'errorCode': 110}
          },
        }
      });
      h.mocks['a']!.onFail('X.missing', 'no such message', code: 110);
      await h.run();
      expect(h.summary()['passed'], 1);
    });

    test('reverse case is an ok producer: downstream refs are NOT skipped',
        () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: bad_login
    agent: a
    as: err
  - cmd: after
    agent: a
    inputs: {code: '\$err.error.code'}
  - cmd: uses_step
    agent: a
''', scripts: {
        'a': {
          'bad_login': {
            'api': 'X.login',
            'params': {},
            'expect': {'errorCode': 110}
          },
          'after': {
            'api': 'X.after',
            'params': {'code': '\$inputs.code'},
          },
          'uses_step': {
            'api': 'X.uses_step',
            'params': {'code': '\$step.bad_login.error.code'},
          },
        }
      });
      final calls = <String>[];
      h.mocks['a']!
        ..on('X.login', (p) async {
          calls.add('login');
          return const Envelope(
            success: false,
            status: 'error',
            failureKind: 'sdk',
            error: {'code': 110, 'message': 'wrong password'},
          );
        })
        ..on('X.after', (p) {
          calls.add('after:${p['code']}');
          return Future.value(
              const Envelope(success: true, status: 'ok'));
        })
        ..on('X.uses_step', (p) {
          calls.add('uses_step:${p['code']}');
          return Future.value(
              const Envelope(success: true, status: 'ok'));
        });
      await h.run();
      // All three ran: the reverse case passed its expectation, so its
      // binding and $step entry are "ok" for dependency purposes.
      // $step.<id> addresses DATA (null on a failed call — AutoMode
      // semantics); the error details are reachable via the as binding.
      expect(h.summary(), {'passed': 3, 'failed': 0, 'timeout': 0, 'skipped': 0});
      expect(calls, ['login', 'after:110', 'uses_step:null']);
    });

    test('checks assert data fields and report per-check details', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: good
    agent: a
  - cmd: bad
    agent: a
''', scripts: {
        'a': {
          'good': {
            'api': 'X.send',
            'params': {},
            'expect': {
              'success': true,
              'checks': [
                {'path': 'msgId', 'notEmpty': true},
                {'path': 'readCount', 'gte': 2},
              ]
            }
          },
          'bad': {
            'api': 'X.send',
            'params': {},
            'expect': {
              'success': true,
              'checks': [
                {'path': 'msgId', 'notEmpty': true},
                {'path': 'readCount', 'gte': 2},
              ]
            }
          },
        }
      });
      // The same api returns different data per call order.
      var call = 0;
      h.mocks['a']!.on('X.send', (params) async {
        call++;
        return Envelope(
          success: true,
          status: 'ok',
          data: call == 1
              ? {'msgId': 'm1', 'readCount': 3}
              : {'msgId': 'm1', 'readCount': 1},
        );
      });
      await h.run();
      expect(h.summary(), {'passed': 1, 'failed': 1, 'timeout': 0, 'skipped': 0});
      final bad = h.records('cmd')[1];
      expect(bad.result!['expectMatched'], isFalse);
      final checks = bad.result!['checks'] as List;
      expect((checks[1] as Map)['passed'], isFalse);
      expect((checks[1] as Map)['actual'], 1);
    });

    test('expect mismatch triggers onFail', () async {
      final h = Harness('''
name: t
agents:
  a: {endpoint: 'http://127.0.0.1:8801', script: ''}
steps:
  - cmd: lying
    agent: a
    onFail: abort_flow
  - cmd: never
    agent: a
''', scripts: {
        'a': {
          'lying': {
            'api': 'X.lying',
            'params': {},
            'expect': {'success': true, 'checks': [{'path': 'n', 'equals': 7}]}
          },
        }
      });
      h.mocks['a']!
        ..onOk('X.lying', {'n': 1})
        ..onOk('never', null);
      await h.run();
      // API succeeded but the assertion failed: judgment, not execution.
      expect(h.mocks['a']!.calls, ['X.lying']);
      expect(h.summary()['failed'], 1);
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
      h.mocks['a']!.on('do_it', (params) async {
        h.mocks['a']!.emit('onMessageReceived', {'k': 'v'});
        return const Envelope(success: true, status: 'ok', data: {'k': 'v'});
      });
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
