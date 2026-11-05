/// In-process AgentClient mock for interpreter tests.
///
/// Handlers are keyed by API name (protocol v2: the interpreter dispatches
/// `{api, params}` after host-side library lookup and reference resolution;
/// handlers receive the fully resolved params).
library;

import 'dart:async';

import 'package:flow_runner/agent_client.dart';

typedef CmdHandler = Future<Envelope> Function(Map<String, Object?> params);

class MockAgent implements AgentClient {
  final Map<String, CmdHandler> handlers = {};
  final List<AgentEvent> events = [];

  /// Executed api names, in order.
  final List<String> calls = [];

  final Map<String, Object?> infoData;

  MockAgent({this.infoData = const {}});

  void on(String api, CmdHandler handler) => handlers[api] = handler;

  /// Convenience: succeed with data.
  void onOk(String api, Object? data, {Duration delay = Duration.zero}) {
    handlers[api] = (params) async {
      if (delay > Duration.zero) await Future.delayed(delay);
      return Envelope(success: true, status: 'ok', data: data);
    };
  }

  /// Convenience: fail with an SDK-style error.
  void onFail(String api, String message,
      {Duration delay = Duration.zero, int code = 500}) {
    handlers[api] = (params) async {
      if (delay > Duration.zero) await Future.delayed(delay);
      return Envelope(
        success: false,
        status: 'error',
        failureKind: 'sdk',
        error: {'code': code, 'message': message},
      );
    };
  }

  /// Never-complete command (for timeout tests).
  void hang(String api) {
    handlers[api] = (params) => Completer<Envelope>().future;
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
  Future<Envelope> runCommand(
      String api, Map<String, Object?> params, int timeoutMs) async {
    calls.add(api);
    final h = handlers[api];
    if (h == null) {
      return Envelope(
        success: false,
        status: 'error',
        failureKind: 'tool',
        error: {'code': -1, 'message': 'no handler for $api'},
      );
    }
    return h(params);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    return events.where((e) => e.seq > afterSeq).toList();
  }

  @override
  Future<void> finish() async {}
}
