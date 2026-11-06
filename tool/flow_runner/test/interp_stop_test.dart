import 'dart:async';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:test/test.dart';

import 'mock_agent.dart';

class GatedEvents extends MockAgent {
  final entered = Completer<void>();
  final response = Completer<List<AgentEvent>>();

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) {
    if (waitMs == 0) return Future.value([]);
    entered.complete();
    return response.future;
  }
}

void main() {
  test(
      'host stop discards late command results and prevents dependent dispatch',
      () async {
    final spec = parseFlow('''
name: stop-command
agents: {a: {script: ''}}
steps:
  - cmd: slow
    agent: a
  - cmd: later
    agent: a
''', options: const ParseOptions(verifyCommandIds: false));
    spec.scripts['a'] = DeviceScript(steps: {
      for (final name in ['slow', 'later']) name: {'api': name, 'params': {}}
    });
    final entered = Completer<void>();
    final response = Completer<Envelope>();
    final agent = MockAgent()
      ..on('slow', (_) {
        entered.complete();
        return response.future;
      });
    final report = ReportCollector();
    final interpreter =
        Interpreter(spec: spec, agents: {'a': agent}, report: report);
    final running = interpreter.run();
    await entered.future;
    interpreter.stop();
    response.complete(const Envelope(success: true, status: 'ok'));
    await running;
    expect(agent.calls, ['slow']);
    expect(report.records, isEmpty);
  });

  test('host stop discards a matching event returned by an in-flight poll',
      () async {
    final spec = parseFlow('''
name: stop-event
agents: {a: {script: ''}}
steps:
  - wait_event: arrived
    agent: a
    as: result
''', options: const ParseOptions(verifyCommandIds: false));
    final agent = GatedEvents();
    final report = ReportCollector();
    final interpreter =
        Interpreter(spec: spec, agents: {'a': agent}, report: report);
    final running = interpreter.run();
    await agent.entered.future;
    interpreter.stop();
    agent.response
        .complete([const AgentEvent(seq: 1, source: 'arrived', payload: {})]);
    await running;
    expect(report.records, isEmpty);
    expect(interpreter.env.isOk('result'), isFalse);
  });
}
