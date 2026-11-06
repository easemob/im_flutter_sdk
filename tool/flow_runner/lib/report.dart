/// Structured JSON run report.
///
/// Only leaf steps (cmd, wait_event) produce records; structural steps are
/// visible through the `context` path (e.g. `flow.alice_line`).
library;

import 'dart:convert';
import 'dart:io';

import 'ast.dart';

class StepRecord {
  StepRecord({
    required this.kind,
    required this.context,
    required this.status,
    required this.durationMs,
    this.agent,
    this.name,
    this.reason,
    this.result,
  });

  final String kind; // cmd | wait_event
  final String context;
  final String status; // passed | failed | timeout | skipped
  final int durationMs;
  final String? agent;
  final String? name;
  final String? reason;
  final Map<String, Object?>? result;

  Map<String, Object?> toJson() => {
        'kind': kind,
        'context': context,
        'status': status,
        'durationMs': durationMs,
        if (agent != null) 'agent': agent,
        if (name != null) 'name': name,
        if (reason != null) 'reason': reason,
        if (result != null) 'result': result,
      };
}

class ReportCollector {
  final DateTime startedAt = DateTime.now();
  final List<StepRecord> records = [];

  void add(StepRecord r) => records.add(r);

  Map<String, int> summary() {
    final s = {'passed': 0, 'failed': 0, 'timeout': 0, 'skipped': 0};
    for (final r in records) {
      s[r.status] = (s[r.status] ?? 0) + 1;
    }
    return s;
  }

  Map<String, Object?> toMap() => {
        'flow': flowName,
        'runId': runId,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': DateTime.now().toIso8601String(),
        if (preconditions.isNotEmpty)
          'preconditions': [for (final p in preconditions) p.toJson()],
        'steps': [for (final r in records) r.toJson()],
        'summary': {
          'total': records.length,
          ...summary(),
        },
      };

  /// Attach after construction (kept out of StepRecord for brevity).
  String flowName = '';
  String runId = '';

  /// Declared flow preconditions (traceability only; execution results
  /// live in the testing-side preconditions report).
  List<PreconditionDecl> preconditions = const [];

  Future<void> writeToFile(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(toMap()));
  }
}
