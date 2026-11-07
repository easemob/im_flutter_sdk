import 'dart:convert';

import 'contracts.dart';

void validateExecutionDelivery(ExecutionResult execution, JsonObject report,
    {required String runId}) {
  execution.validate();
  validateRawReport(report, runId, execution.caseName);
  final steps = (report['steps'] as List).map(readObject).toList();
  final declared = execution.definition.requiredBindings.toSet();
  if (execution.required.length != declared.length ||
      execution.required.map((item) => item.binding).toSet().length !=
          declared.length ||
      execution.required
          .map((item) => item.binding)
          .toSet()
          .difference(declared)
          .isNotEmpty) {
    throw const FormatException(
        'Required checks do not cover fixed definition');
  }
  for (final check in execution.required) {
    final indices = <int>[];
    for (var i = 0; i < steps.length; i++) {
      final result = steps[i]['result'];
      if (result is Map && result['binding'] == check.binding) indices.add(i);
    }
    final passed =
        indices.length == 1 && steps[indices.single]['status'] == 'passed';
    if (jsonEncode(indices) != jsonEncode(check.recordIndices) ||
        passed != check.passed) {
      throw const FormatException(
          'Required check disagrees with original records');
    }
  }
  final failed = execution.required.any((item) => !item.passed) ||
      steps.any(
          (step) => step['status'] == 'failed' || step['status'] == 'timeout');
  final flowTimeout = steps
      .any((step) => step['kind'] == 'flow' && step['status'] == 'timeout');
  if (flowTimeout && execution.verdict != '未完成') {
    throw const FormatException('Flow timeout requires incomplete verdict');
  }
  if (execution.verdict == '否' && !failed) {
    throw const FormatException(
        'Failed verdict requires failed steps or required checks');
  }
  for (final check in execution.required.where((item) => item.passed)) {
    final step = steps[check.recordIndices.single];
    final result = readObject(step['result']);
    if (step['kind'] == 'cmd' &&
        (result['success'] is! bool ||
            result['status'] is! String ||
            result['expectMatched'] is! bool)) {
      throw const FormatException(
          'Required command result evidence is incomplete');
    }
    if (step['kind'] == 'wait_event' &&
        (result['seq'] is! int ||
            !result.containsKey('payload') ||
            step['agent'] is! String ||
            step['name'] is! String)) {
      throw const FormatException(
          'Required event result evidence is incomplete');
    }
  }
  if (execution.verdict == '是' &&
      (execution.required.any((item) => !item.passed) ||
          steps.any((step) =>
              step['status'] == 'failed' || step['status'] == 'timeout'))) {
    throw const FormatException('Pass verdict contradicts actual records');
  }
}

void validateRawReport(JsonObject report, String runId, String caseName) {
  if (report['runId'] != runId || report['flow'] != caseName)
    throw const FormatException('Report ownership mismatch');
  final start = report['startedAt'], end = report['finishedAt'];
  if (start is! String ||
      end is! String ||
      DateTime.tryParse(start) == null ||
      DateTime.tryParse(end) == null ||
      DateTime.parse(end).isBefore(DateTime.parse(start))) {
    throw const FormatException('Invalid report timestamps');
  }
  final raw = report['steps'];
  final summary = readObject(report['summary'], 'summary');
  if (raw is! List)
    throw const FormatException('Report steps must be an array');
  final counts = {'passed': 0, 'failed': 0, 'timeout': 0, 'skipped': 0};
  for (final value in raw) {
    final step = readObject(value, 'report step');
    final status = step['status'];
    if (!counts.containsKey(status) ||
        step['durationMs'] is! int ||
        (step['durationMs'] as int) < 0 ||
        !['cmd', 'wait_event', 'flow'].contains(step['kind']) ||
        step['context'] is! String) {
      throw const FormatException('Invalid report step');
    }
    counts[status as String] = counts[status]! + 1;
  }
  if (summary['total'] is! int ||
      summary['total'] != raw.length ||
      counts.entries
          .any((e) => summary[e.key] is! int || summary[e.key] != e.value)) {
    throw const FormatException('Report counts do not match steps');
  }
}
