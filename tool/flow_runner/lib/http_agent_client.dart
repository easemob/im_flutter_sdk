/// HTTP AgentClient implementing the phase-control protocol v2
/// (../docs/2026-11-04-phase-control.md):
///
/// - `GET  /v1/info`                 handshake (version/platform/instanceId)
/// - `POST /v1/commands`             submit {commandId, api, params, timeoutMs}
///                                   -> 202, then poll to terminal state
/// - `GET  /v1/commands/<commandId>` poll until done | timeout
/// - `GET  /v1/events?afterSeq=`     incremental events (seq cursor)
/// - `POST /v1/finish`               close the control service
///
/// No session binding: the command carries everything; the agent returns
/// the actual result envelope and the host judges. The interpreter never
/// sees any of this; only Envelope/AgentEvent cross the boundary.
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

  /// Role name, used for command ids and diagnostics only.
  final String actor;

  /// Optional control pairing credential (Authorization: Bearer).
  final String? token;
  final int pollIntervalMs;

  int _cmdSeq = 0;
  // Agent endpoints are 127.0.0.1 loopback services; never route them
  // through an ambient proxy (Dart honors lowercase http_proxy by default,
  // which breaks local requests when a local proxy is configured).
  final HttpClient _http = HttpClient()..findProxy = (uri) => 'DIRECT';

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
  Future<Envelope> runCommand(
      String api, Map<String, Object?> params, int timeoutMs) async {
    final commandId = '$actor-${++_cmdSeq}';
    await _request('POST', '/v1/commands', {
      'commandId': commandId,
      'api': api,
      'params': params,
      'timeoutMs': timeoutMs,
    });

    // Poll until a terminal state. No client-side deadline here: the
    // interpreter's timeout guard converts overruns into timeout envelopes.
    const terminal = {'done', 'timeout'};
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
  Future<void> finish() =>
      _request('POST', '/v1/finish', const {}).then((_) {});

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
