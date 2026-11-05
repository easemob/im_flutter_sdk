/// HTTP AgentClient implementing the phase-control protocol
/// (testing/spec/2026-11-04-phase-control.md):
///
/// - `GET  /v1/info`
/// - `POST /v1/session`            bind script
/// - `POST /v1/commands`           submit, then poll `GET /v1/commands/<id>`
/// - `GET  /v1/events?afterSeq=`   incremental events
/// - `POST /v1/session/finish`
///
/// The interpreter never sees any of this; only Envelope/AgentEvent cross
/// the boundary.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'agent_client.dart';

class HttpAgentClient implements AgentClient {
  HttpAgentClient({
    required this.endpoint,
    required this.actor,
    this.token,
    this.pollIntervalMs = 200,
  });

  final Uri endpoint;
  final String actor;

  /// Optional control pairing credential (Authorization: Bearer).
  final String? token;
  final int pollIntervalMs;

  late final String sessionId = '$actor-${DateTime.now().millisecondsSinceEpoch}';
  int _cmdSeq = 0;
  final HttpClient _http = HttpClient();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, Object?>> _request(
      String method, String path, Object? body) async {
    final uri = endpoint.resolve(path);
    final req = await _http.openUrl(method, uri)
      ..followRedirects = false;
    _headers.forEach(req.headers.set);
    if (body != null) {
      final bytes = utf8.encode(jsonEncode(body));
      req.contentLength = bytes.length;
      req.add(bytes);
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode >= 400) {
      throw AgentHttpException(method, path, res.statusCode, text);
    }
    if (text.isEmpty) return {};
    return Map<String, Object?>.from(jsonDecode(text) as Map);
  }

  @override
  Future<Map<String, Object?>> info() => _request('GET', '/v1/info', null);

  @override
  Future<void> bindSession(String runId, Map<String, Object?> scriptJson) =>
      _request('POST', '/v1/session', {
        'sessionId': sessionId,
        'runId': runId,
        'actor': actor,
        'script': scriptJson,
      }).then((_) {});

  @override
  Future<Envelope> runCommand(
      String cmdId, Map<String, Object?> inputs, int timeoutMs) async {
    final commandId = 'cmd-${++_cmdSeq}';
    await _request('POST', '/v1/commands', {
      'sessionId': sessionId,
      'commandId': commandId,
      'actor': actor,
      'stage': cmdId,
      'inputs': inputs,
      'timeoutMs': timeoutMs,
    });

    // Poll until a terminal state. No client-side deadline here: the
    // interpreter's timeout guard converts overruns into timeout envelopes.
    const terminal = {'passed', 'failed', 'blocked', 'skipped'};
    while (true) {
      await Future.delayed(Duration(milliseconds: pollIntervalMs));
      final res = await _request('GET', '/v1/commands/$commandId', null);
      if (terminal.contains(res['status'])) {
        return Envelope.fromCommandResult(res);
      }
    }
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    final res = await _request(
      'GET',
      '/v1/events?afterSeq=$afterSeq&limit=$limit&waitMs=$waitMs',
      null,
    );
    final events = res['events'];
    if (events is! List) return const [];
    return [
      for (final e in events)
        if (e is Map)
          AgentEvent(
            seq: e['seq'] as int,
            source: e['source'] as String? ?? '',
            payload:
                Map<String, Object?>.from(e['payload'] as Map? ?? const {}),
          ),
    ];
  }

  @override
  Future<void> finish() => _request('POST', '/v1/session/finish', {
        'sessionId': sessionId,
      }).then((_) {});

  void close() => _http.close();
}

class AgentHttpException implements Exception {
  AgentHttpException(this.method, this.path, this.statusCode, this.body);

  final String method;
  final String path;
  final int statusCode;
  final String body;

  @override
  String toString() =>
      'agent http $method $path -> $statusCode: ${body.length > 300 ? '${body.substring(0, 300)}...' : body}';
}
