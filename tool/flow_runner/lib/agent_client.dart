/// Agent abstraction: the only interface between the interpreter and the
/// outside world. Implementations talk HTTP (phase-control protocol) in
/// production and mock in-process for tests.
///
/// Envelope contract (the single output interface, see spec §2):
/// `{success, status: ok|error|timeout, data, error}` — `data` internals
/// are opaque to the interpreter.
library;

/// Command execution result envelope.
class Envelope {
  const Envelope({
    required this.success,
    required this.status,
    this.data,
    this.error,
  });

  final bool success;

  /// ok | error | timeout
  final String status;

  final Object? data;
  final Map<String, Object?>? error;

  factory Envelope.timeout(int ms) => Envelope(
        success: false,
        status: 'timeout',
        error: {'code': -2, 'message': 'timeout after ${ms}ms'},
      );

  factory Envelope.error(Object e) => Envelope(
        success: false,
        status: 'error',
        error: {'code': -1, 'message': '$e'},
      );

  /// Map a phase-control command terminal state to the envelope.
  factory Envelope.fromCommandResult(Map<String, Object?> json) {
    final status = json['status'] as String? ?? 'failed';
    final failure = json['failure'] as Map<String, Object?>?;
    if (status == 'passed') {
      return Envelope(
        success: true,
        status: 'ok',
        data: json['outputs'],
      );
    }
    final kind = failure?['kind'] as String?;
    return Envelope(
      success: false,
      status: kind == 'timeout' ? 'timeout' : 'error',
      data: json['outputs'],
      error: failure == null
          ? {'code': -1, 'message': 'command $status'}
          : {
              'code': failure['code'] ?? -1,
              'message': failure['message'] ?? 'command $status',
              if (failure['stepId'] != null) 'stepId': failure['stepId'],
            },
    );
  }

  Map<String, Object?> toMap() => {
        'success': success,
        'status': status,
        if (data != null) 'data': data,
        if (error != null) 'error': error,
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
  /// Handshake info, e.g. `{sessionId, userId, state}`.
  Future<Map<String, Object?>> info();

  /// Bind the device script for this run.
  Future<void> bindSession(String runId, Map<String, Object?> scriptJson);

  /// Execute one command and resolve with the terminal envelope.
  /// Implementations should honor `timeoutMs` internally or let the
  /// interpreter's timeout guard produce a timeout envelope.
  Future<Envelope> runCommand(
      String cmdId, Map<String, Object?> inputs, int timeoutMs);

  /// Read events strictly after `afterSeq`. May return an empty list.
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000});

  /// Close the control session (best effort).
  Future<void> finish();
}
