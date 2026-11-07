import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/http_agent_client.dart';

/// Keeps transport ownership without changing the runner's HTTP protocol.
class OwnedAgentClient implements AgentClient {
  OwnedAgentClient(
      {required Uri endpoint, required String actor, required String token}) {
    _transport = HttpClient()..findProxy = (_) => 'DIRECT';
    _client = HttpOverrides.runZoned(
      () => HttpAgentClient(endpoint: endpoint, actor: actor, token: token),
      createHttpClient: (_) => _transport,
    );
  }

  late final HttpClient _transport;
  late final HttpAgentClient _client;

  @override
  Future<Map<String, Object?>> info() => _client.info();
  @override
  Future<Envelope> runCommand(
          String api, Map<String, Object?> params, int timeoutMs) =>
      _client.runCommand(api, params, timeoutMs);
  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
          {int limit = 200, int waitMs = 1000}) =>
      _client.pollEvents(afterSeq, limit: limit, waitMs: waitMs);
  @override
  Future<void> finish() => _client.finish();

  void close() {
    // Future.timeout does not cancel a socket; force-close only our transport.
    _transport.close(force: true);
    _client.close();
  }
}
