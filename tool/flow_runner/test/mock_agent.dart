/// In-process AgentClient mock for interpreter tests.
library;

import 'dart:async';

import 'package:flow_runner/agent_client.dart';

typedef CmdHandler = Future<Envelope> Function(Map<String, Object?> inputs);

class MockAgent implements AgentClient {
  final Map<String, CmdHandler> handlers = {};
  final List<AgentEvent> events = [];
  final List<String> calls = [];
  final Map<String, Object?> infoData;

  MockAgent({this.infoData = const {}});

  void on(String cmdId, CmdHandler handler) => handlers[cmdId] = handler;

  /// Convenience: succeed with data.
  void onOk(String cmdId, Object? data, {Duration delay = Duration.zero}) {
    handlers[cmdId] = (inputs) async {
      if (delay > Duration.zero) await Future.delayed(delay);
      return Envelope(success: true, status: 'ok', data: data);
    };
  }

  /// Convenience: fail with an error.
  void onFail(String cmdId, String message,
      {Duration delay = Duration.zero}) {
    handlers[cmdId] = (inputs) async {
      if (delay > Duration.zero) await Future.delayed(delay);
      return Envelope(
        success: false,
        status: 'error',
        error: {'code': 500, 'message': message},
      );
    };
  }

  /// Never-complete command (for timeout tests).
  void hang(String cmdId) {
    handlers[cmdId] = (inputs) => Completer<Envelope>().future;
  }

  /// Emit an event into the stream (source = SDK callback method name).
  void emit(String source, Map<String, Object?> payload) {
    events.add(AgentEvent(
      seq: events.length + 1,
      source: source,
      payload: payload,
    ));
  }

  @override
  Future<Map<String, Object?>> info() async => infoData;

  @override
  Future<void> bindSession(String runId, Map<String, Object?> scriptJson) async {}

  @override
  Future<Envelope> runCommand(
      String cmdId, Map<String, Object?> inputs, int timeoutMs) async {
    calls.add(cmdId);
    final h = handlers[cmdId];
    if (h == null) {
      return Envelope(
        success: false,
        status: 'error',
        error: {'code': -1, 'message': 'no handler for $cmdId'},
      );
    }
    return h(inputs);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    return events.where((e) => e.seq > afterSeq).toList();
  }

  @override
  Future<void> finish() async {}
}
