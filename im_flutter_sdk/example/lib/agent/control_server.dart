import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'command_service.dart';
import 'evidence_store.dart';

/// HTTP control server implementing phase-control v2 (§2-§6):
///
/// | route | behavior |
/// |---|---|
/// | `GET /v1/info` | handshake: version/platform/instanceId/state |
/// | `POST /v1/commands` | validate + start execution, answer 202 |
/// | `GET /v1/commands/<id>` | poll record until done \| timeout |
/// | `GET /v1/events?afterSeq=&limit=&waitMs=` | cursor pagination, long poll ≤1s |
/// | `POST /v1/finish` | close (no in-flight command) |
///
/// Bearer-token auth on everything; request bodies capped at 1 MiB (413).
/// Loopback only, port assigned by the system; the pairing credential is
/// printed once as `[AGENT_CONTROL] {port, token, instanceId}` via plain
/// print so it never enters the structured log / evidence stream.
class ControlServer {
  ControlServer._(
    this._server,
    this.service,
    this.evidence,
    this.token,
    this.instanceId,
  );

  static const int maxBodyBytes = 1024 * 1024; // 1 MiB
  static const int maxEventsPerPage = 200;
  static const int maxWaitMs = 1000;

  final HttpServer _server;
  final CommandService service;
  final EvidenceStore evidence;
  final String token;
  final String instanceId;

  int get port => _server.port;

  static String _hex(int bytes) {
    final rng = Random.secure();
    return List.generate(bytes, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Bind loopback:0 and start serving. Prints the pairing credential.
  static Future<ControlServer> start({
    required CommandService service,
    required EvidenceStore evidence,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final control = ControlServer._(
      server,
      service,
      evidence,
      _hex(32), // 64 hex chars
      _hex(16),
    );
    server.listen(control._handle, onError: (Object e) {
      debugPrint('agent control server error: $e');
    });
    // ignore: avoid_print
    print('[AGENT_CONTROL] ${jsonEncode({
          'port': control.port,
          'token': control.token,
          'instanceId': control.instanceId,
        })}');
    return control;
  }

  Future<void> stop() async {
    await _server.close(force: true);
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      final res = req.response;
      if (!req.uri.path.startsWith('/v1/')) {
        return _json(res, 404, _err('not_found', '未知路径 ${req.uri.path}'));
      }
      if (req.headers.value(HttpHeaders.authorizationHeader) != 'Bearer $token') {
        return _json(res, 401, _err('unauthorized', '缺少或错误的控制凭据'));
      }

      switch (req.method) {
        case 'GET':
          if (req.uri.path == '/v1/info') return _info(res);
          if (req.uri.path.startsWith('/v1/commands/')) {
            return _commandStatus(req, res);
          }
          if (req.uri.path == '/v1/events') {
            await _events(req, res);
            return;
          }
          return _json(res, 404, _err('not_found', '未知路径 ${req.uri.path}'));

        case 'POST':
          if (req.uri.path == '/v1/commands') {
            await _submit(req, res);
            return;
          }
          if (req.uri.path == '/v1/finish') return _finish(res);
          return _json(res, 405, _err('method_not_allowed', '方法不支持'));

        default:
          return _json(res, 405, _err('method_not_allowed', '方法不支持'));
      }
    } catch (e) {
      if (e is AgentCommandError) {
        return _json(
            req.response, e.statusCode, _err(e.code, e.message));
      }
      try {
        return _json(req.response, 500,
            _err('internal', '内部错误：$e'));
      } catch (_) {
        // response already closed; nothing more we can do
      }
    }
  }

  void _info(HttpResponse res) {
    _json(res, 200, {
      ...service.info(),
      'platform': Platform.operatingSystem,
    });
  }

  Future<void> _submit(HttpRequest req, HttpResponse res) async {
    final body = await _readBody(req, res);
    if (body == null) return; // 413 already answered
    Map<String, dynamic> command;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) throw const FormatException('not an object');
      command = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return _json(res, 400, _err('bad_request', '请求体不是 JSON 对象'));
    }
    // Unknown fields (id/expect/future extensions) are tolerated (§4).
    final record = await service.submit(command);
    _json(res, 202, {
      'commandId': record.commandId,
      'status': 'accepted',
    });
  }

  void _commandStatus(HttpRequest req, HttpResponse res) {
    final id = req.uri.path.substring('/v1/commands/'.length);
    if (id.isEmpty || id.contains('/')) {
      return _json(res, 404, _err('not_found', '命令不存在'));
    }
    final record = service.lookup(id);
    if (record == null) {
      return _json(res, 404, _err('not_found', '命令不存在'));
    }
    _json(res, 200, service.recordJson(record));
  }

  Future<void> _events(HttpRequest req, HttpResponse res) async {
    final q = req.uri.queryParameters;
    final afterSeq = int.tryParse(q['afterSeq'] ?? '0') ?? 0;
    final limit = (int.tryParse(q['limit'] ?? '') ?? maxEventsPerPage)
        .clamp(1, maxEventsPerPage);
    final waitMs = (int.tryParse(q['waitMs'] ?? '0') ?? 0).clamp(0, maxWaitMs);

    if (evidence.degraded && afterSeq < evidence.firstAvailableSeq) {
      return _json(res, 410, _err('evidence_gap',
          '证据缓冲已溢出：firstAvailableSeq=${evidence.firstAvailableSeq}'));
    }

    final events = await evidence.queryWithWait(
      afterSeq,
      limit: limit,
      timeout: Duration(milliseconds: waitMs),
    );
    _json(res, 200, {
      'firstAvailableSeq': evidence.firstAvailableSeq,
      'lastSeq': evidence.lastSeq,
      // Empty page keeps the cursor unchanged (exclusive cursor semantics).
      'nextAfterSeq': events.isEmpty ? afterSeq : events.last.seq,
      'events': [for (final e in events) e.toJson()],
    });
  }

  void _finish(HttpResponse res) {
    service.finish();
    _json(res, 200, {});
  }

  /// Read the request body with the 1 MiB cap; answers 413 and returns null
  /// when exceeded.
  Future<String?> _readBody(HttpRequest req, HttpResponse res) async {
    if (req.contentLength > maxBodyBytes) {
      // Drain so the connection can be reused, then reject.
      await req.drain<void>().catchError((_) {});
      _json(res, 413, _err('payload_too_large', '请求体超过 1 MiB 上限'));
      return null;
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in req) {
      builder.add(chunk);
      if (builder.length > maxBodyBytes) {
        _json(res, 413, _err('payload_too_large', '请求体超过 1 MiB 上限'));
        return null;
      }
    }
    return utf8.decode(builder.takeBytes());
  }

  static Map<String, Object?> _err(String code, String message) =>
      {'error': {'code': code, 'message': message}};

  static void _json(HttpResponse res, int status, Object? body) {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    // ignore: avoid_print
    res.write(jsonEncode(body ?? const {}));
    res.close();
  }
}
