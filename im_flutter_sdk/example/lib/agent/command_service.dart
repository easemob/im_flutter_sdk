import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../auto/step_expectation.dart';
import '../log/log_store.dart';
import '../registry/api_entry.dart';
import '../registry/registry.dart';

/// Control-service state (phase-control v2 §2; the v1 session state machine
/// is dissolved — one process, one run).
enum AgentServiceState { accepting, uncertain, closed }

/// Error carrying the HTTP status the control server should answer with.
class AgentCommandError implements Exception {
  AgentCommandError(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

/// Business API executor: `(api, params) -> envelope map`. Production wires
/// [runApi]; tests inject fakes. The envelope shape is the runApi contract:
/// `{success: bool, data?: ...}` or `{success: false, failureKind, error}`.
typedef AgentExecutor =
    Future<Map<String, dynamic>> Function(String api, Map<String, dynamic> params);

/// ChatClient.init is the single agent-side special case (agent-service §6):
/// config/overrides are merged by the app's options assembly, then listeners
/// are registered and the SDK state marked initialized.
typedef AgentInitHandler =
    Future<Map<String, dynamic>> Function(Map<String, dynamic> params);

class CommandRecord {
  CommandRecord(this.commandId, this.api, this.canonical);

  final String commandId;
  final String api;
  final String canonical; // canonical JSON of {api, params, timeoutMs}
  String status = 'running'; // running | done | timeout
  Map<String, Object?>? result;
}

/// Command execution core: validation, dedup, single in-flight, timeout
/// guard, three-state lifecycle. SDK-free on purpose — production wiring is
/// [CommandService.production], unit tests inject executors.
class CommandService extends ChangeNotifier {
  CommandService({
    required this.executeApi,
    required this.initHandler,
    required this.logger,
    required this.instanceId,
    this.defaultTimeoutMs = 30000,
  });

  /// Production wiring: registry runApi + LogStore logging. The init
  /// special case (options assembly + listener registration) is SDK-heavy
  /// and therefore injected from agent_wiring.dart.
  factory CommandService.production({
    required AgentInitHandler initHandler,
    required String instanceId,
  }) {
    return CommandService(
      executeApi: (api, params) async {
        final entry = findApi(api);
        if (entry == null) {
          // Defensive: submit() already rejects unregistered apis with 422.
          throw AgentCommandError(422, 'unknown_api', '未注册的 API：$api');
        }
        return runApi(entry, params);
      },
      initHandler: initHandler,
      logger: (source, payload) => LogStore.instance.log(source, payload),
      instanceId: instanceId,
    );
  }

  final AgentExecutor executeApi;
  final AgentInitHandler initHandler;
  final void Function(String source, Object? payload) logger;
  final String instanceId;
  final int defaultTimeoutMs;

  AgentServiceState _state = AgentServiceState.accepting;
  final Map<String, CommandRecord> _records = {};
  CommandRecord? _inFlight;

  AgentServiceState get state => _state;
  bool get busy => _inFlight != null;

  /// Submit one command (phase-control v2 §4). Validates, registers the
  /// record, starts execution detached (the caller answers 202 immediately)
  /// and returns the record snapshot.
  ///
  /// Throws [AgentCommandError] with the HTTP status to answer.
  Future<CommandRecord> submit(Map<String, dynamic> command) async {
    if (_state == AgentServiceState.closed) {
      throw AgentCommandError(410, 'closed', '控制服务已关闭（finish）');
    }
    if (_state == AgentServiceState.uncertain) {
      throw AgentCommandError(503, 'uncertain',
          '上一命令超时后底层状态未知；显式 finish 放弃，或重启 App');
    }

    final commandId = command['commandId'];
    if (commandId is! String || commandId.isEmpty) {
      throw AgentCommandError(400, 'bad_command', 'commandId 必须是非空字符串');
    }
    final api = command['api'];
    if (api is! String || api.isEmpty) {
      throw AgentCommandError(400, 'bad_command', 'api 必须是非空字符串');
    }
    final params = command['params'] is Map
        ? Map<String, dynamic>.from(command['params'] as Map)
        : <String, dynamic>{};
    final timeoutMs = command['timeoutMs'] is int
        ? command['timeoutMs'] as int
        : defaultTimeoutMs;

    // Dedup: same id + same resolved content returns the existing record
    // (response-loss replay); same id + different content is rejected.
    final canonical = jsonEncode({
      'api': api,
      'params': params,
      'timeoutMs': timeoutMs,
    });
    final existing = _records[commandId];
    if (existing != null) {
      if (existing.canonical != canonical) {
        throw AgentCommandError(
            409, 'command_conflict', '同一 commandId 已用于不同内容');
      }
      return existing;
    }
    if (busy) {
      throw AgentCommandError(409, 'busy', '同一时刻仅允许一个在途命令');
    }

    // Registry check. ChatClient.init is the single special case; unknown
    // fields (id/expect/future extensions) are tolerated per protocol v2.
    final isInit = api == 'ChatClient.init';
    if (!isInit && findApi(api) == null) {
      throw AgentCommandError(422, 'unknown_api', '未注册的 API：$api');
    }

    final record = CommandRecord(commandId, api, canonical);
    _records[commandId] = record;
    _inFlight = record;
    logger('agent.command', {'event': 'accepted', 'commandId': commandId, 'api': api});

    // Detached execution: the HTTP layer already answered 202.
    unawaited(_execute(record, params, timeoutMs, isInit,
        expect: command['expect']));
    return record;
  }

  Future<void> _execute(
    CommandRecord record,
    Map<String, dynamic> params,
    int timeoutMs,
    bool isInit, {
    Object? expect,
  }) async {
    final fromSeq = _currentSeq();
    var timedOut = false;
    final future = isInit ? initHandler(params) : executeApi(record.api, params);

    // Late completion after a timeout stays visible in the evidence stream
    // as an ordinary event; it never overwrites the first terminal state.
    unawaited(future.then((late) {
      if (timedOut) {
        logger('api.${record.api}', {...late, 'late': true});
      }
    }));

    Map<String, dynamic> result;
    try {
      result = await future.timeout(
        Duration(milliseconds: timeoutMs),
        onTimeout: () {
          timedOut = true;
          return {
            'success': false,
            'failureKind': 'timeout',
            'error': {'code': -2, 'message': 'timeout after ${timeoutMs}ms'},
          };
        },
      );
    } catch (e) {
      if (e is TimeoutException) {
        timedOut = true;
        result = {
          'success': false,
          'failureKind': 'timeout',
          'error': {'code': -2, 'message': 'timeout after ${timeoutMs}ms'},
        };
      } else {
        result = {
          'success': false,
          'failureKind': 'tool',
          'error': errorToJson(e),
        };
      }
    }

    // The api.* event mirrors AutoMode's log channel so the evidence stream
    // shows both commands and SDK callbacks.
    logger('api.${record.api}', result);

    final terminal = <String, Object?>{
      'commandId': record.commandId,
      'status': timedOut ? 'timeout' : 'done',
      ...result,
      'evidence': {'fromSeq': fromSeq, 'toSeq': _currentSeq()},
    };

    // Compat channel: a command that carried an expect block gets an
    // agent-side evaluation appended (the host's judgment stays
    // authoritative; unknown expect fields must not crash the agent).
    if (expect != null) {
      bool matched;
      try {
        matched = stepResultMatchesExpectation(result, expect);
      } catch (_) {
        matched = false;
      }
      terminal['expectMatched'] = matched;
    }

    record.status = terminal['status'] as String;
    record.result = terminal;
    _inFlight = null;
    if (timedOut) {
      _state = AgentServiceState.uncertain;
    }
    logger('agent.command', {
      'event': 'finished',
      'commandId': record.commandId,
      'status': record.status,
    });
    notifyListeners();
  }

  /// Current evidence seq — LogStore feeds EvidenceStore synchronously, so
  /// reading the singleton's last line gives the up-to-date cursor.
  int _currentSeq() {
    final lines = LogStore.instance.lines;
    if (lines.isEmpty) return 0;
    try {
      final seq = (jsonDecode(lines.last) as Map)['seq'];
      return seq is int ? seq : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Lookup for `GET /v1/commands/<id>` polling.
  CommandRecord? lookup(String commandId) => _records[commandId];

  /// Snapshot for the HTTP layer (running or terminal).
  Map<String, Object?> recordJson(CommandRecord record) => record.result ??
      {
        'commandId': record.commandId,
        'status': 'running',
      };

  /// Handshake info (GET /v1/info).
  Map<String, Object?> info() => {
        'version': 2,
        'instanceId': instanceId,
        'state': state.name,
      };

  /// Close the control service (POST /v1/finish). No in-flight command
  /// allowed; later business commands answer 410.
  void finish() {
    if (busy) {
      throw AgentCommandError(409, 'busy', '存在在途命令，不能 finish');
    }
    if (_state != AgentServiceState.closed) {
      _state = AgentServiceState.closed;
      notifyListeners();
    }
  }
}
