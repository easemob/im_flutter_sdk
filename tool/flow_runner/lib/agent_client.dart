/// Agent abstraction: the only interface between the interpreter and the
/// outside world. Implementations talk HTTP (phase-control protocol v2) in
/// production and mock in-process for tests.
///
/// Protocol v2 (2026-11-05): commands carry the full step content
/// (`api` + resolved `params`); the agent is a dumb executor that returns
/// the ACTUAL result envelope. Expectation judgment lives host-side
/// (the interpreter); an optional `expect` carried in a command is the
/// agent-side compat channel, not this interface's concern.
library;

/// Command execution result envelope — the actual API outcome.
class Envelope {
  const Envelope({
    required this.success,
    required this.status,
    this.data,
    this.error,
    this.failureKind,
  });

  final bool success;

  /// ok | error | timeout
  final String status;

  final Object? data;
  final Map<String, Object?>? error;

  /// sdk | timeout | tool (from the agent's runApi classification).
  final String? failureKind;

  factory Envelope.timeout(int ms) => Envelope(
        success: false,
        status: 'timeout',
        failureKind: 'timeout',
        error: {'code': -2, 'message': 'timeout after ${ms}ms'},
      );

  factory Envelope.error(Object e) => Envelope(
        success: false,
        status: 'error',
        failureKind: 'tool',
        error: {'code': -1, 'message': '$e'},
      );

  /// Map a protocol v2 command terminal result to the envelope.
  ///
  /// Wire shape: `{commandId, status: done|timeout, success, data?, error?,
  /// failureKind?, evidence: {fromSeq, toSeq}}` — execution state only,
  /// no judgment (passed/failed is decided by the host's expect matcher).
  factory Envelope.fromCommandResult(Map<String, Object?> json) {
    final status = json['status'] as String? ?? 'timeout';
    final success = json['success'] == true;
    if (status == 'timeout') {
      return Envelope(
        success: false,
        status: 'timeout',
        failureKind: 'timeout',
        error: _err(json) ??
            {'code': -2, 'message': 'command timed out on the agent'},
      );
    }
    return Envelope(
      success: success,
      status: success ? 'ok' : 'error',
      data: json['data'],
      error: _err(json),
      failureKind: json['failureKind'] as String?,
    );
  }

  static Map<String, Object?>? _err(Map<String, Object?> json) {
    final e = json['error'];
    return e is Map ? Map<String, Object?>.from(e) : null;
  }

  Map<String, Object?> toMap() => {
        'success': success,
        'status': status,
        if (data != null) 'data': data,
        if (error != null) 'error': error,
        if (failureKind != null) 'failureKind': failureKind,
      };
}

/// One event on an agent's event stream. `source` is the SDK callback
/// method name for SDK events (decision 2026-11-05).
class AgentEvent {
  const AgentEvent({required this.seq, required this.source, required this.payload});

  final int seq;
  final String source;
  final Map<String, Object?> payload;
}

/// Per-agent client. One instance maps to one agent role.
abstract class AgentClient {
  /// Handshake info: `{version, platform, instanceId, state}`.
  Future<Map<String, Object?>> info();

  /// Execute one command (api + already-resolved params) and resolve with
  /// the actual result envelope. Implementations should honor `timeoutMs`
  /// internally or let the interpreter's guard produce a timeout envelope.
  Future<Envelope> runCommand(
      String api, Map<String, Object?> params, int timeoutMs);

  /// Read events strictly after `afterSeq`. May return an empty list.
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000});

  /// Close the control service (best effort).
  Future<void> finish();
}
