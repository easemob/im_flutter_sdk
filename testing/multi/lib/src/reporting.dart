import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flow_runner/ast.dart';

import 'contracts.dart';
import 'core.dart';
import 'execution.dart';
import 'execution_validation.dart' as validation;

const statisticsColumns = [
  '轮次',
  '执行序号',
  '用例编号',
  '用例文件',
  '平台',
  '设备分类',
  '测试方向',
  '预期',
  '实际',
  '是否通过',
  '原因',
  '证据',
];

class ReportingService {
  ReportingService({required this.loader});
  final CaseLoader loader;

  Future<OperationResult<ReportingResult>> generate(OperationContext context,
      JsonObject snapshot, Directory reportDirectory) async {
    final errors = <OperationError>[];
    try {
      context.redactor.addFrom(snapshot);
      if (snapshot['runId'] != context.runId)
        throw const FormatException('Reporting run ownership mismatch');
      final rows = await _rows(snapshot, errors);
      final dependencies = <ReportDependency>[];
      final summaryPath = p.join(reportDirectory.path, 'summary.md');
      final statisticsPath = p.join(reportDirectory.path, 'statistics.csv');
      final processPath = p.join(reportDirectory.path, 'process.json');
      for (final row in rows) {
        for (final reference in row.evidence) {
          for (final report in [summaryPath, statisticsPath, processPath]) {
            dependencies.add(ReportDependency(
                report: p.absolute(report), evidence: reference));
          }
        }
      }
      final sanitizedRows = rows
          .map((row) => row.cells.map(context.redactor.text).toList())
          .toList();
      final csv = [statisticsColumns, ...sanitizedRows]
          .map((row) => row.map(_quote).join(','))
          .join('\r\n');
      final counts = _counts(rows.map((row) => row.cells));
      final faults = _taskFaults(snapshot);
      final summary = '''# 测试汇总

- 轮次：${context.runId}
- 用例数：${rows.map((row) => row.cells[2]).toSet().length}
- 执行次数：${rows.length}
- 是：${counts['是']}；否：${counts['否']}；未执行：${counts['未执行']}；未完成：${counts['未完成']}
- 任务故障：${faults.length + errors.length}

${faults.isEmpty && errors.isEmpty ? '无任务故障。' : [
              ...faults,
              ...errors.map((error) => error.message)
            ].map((message) => '- $message').join('\n')}

${rows.any((row) => row.cells[9] != '是') ? '未通过的正式执行须结合过程证据显式复验，首次结果保留。' : ''}
''';
      await writePrivateFile(summaryPath, context.redactor.text(summary));
      await writePrivateFile(statisticsPath, '$csv\r\n');
      await writePrivateJson(
          processPath,
          context.redactor.sanitize({
            'runId': context.runId,
            'operationId': context.operationId,
            'selection': [
              for (final raw in _list(snapshot, 'cases'))
                {
                  'caseName':
                      CaseDefinition.fromJson(readObject(raw)['definition'])
                          .name,
                  'roles': _reportRoles(
                      readObject(raw)['devices'] ?? readObject(raw)['roles']),
                },
            ],
            'attempts': [
              for (final row in rows)
                {
                  'caseName': row.reference.caseName,
                  'attempt': row.reference.attempt,
                  'verdict': row.cells[9],
                  'reason': row.cells[10],
                  'roles': _reportRoles(_attempts(snapshot).firstWhere((item) =>
                      item['caseName'] == row.reference.caseName &&
                      item['attempt'] == row.reference.attempt)['roles']),
                  'configuration': await _reportConfiguration(
                      _attempts(snapshot).firstWhere((item) =>
                          item['caseName'] == row.reference.caseName &&
                          item['attempt'] == row.reference.attempt)),
                  'evidence':
                      row.evidence.map((item) => item.toJson()).toList(),
                }
            ],
            'operations': snapshot['operations'],
            'issues': snapshot['issues'],
            'gaps': errors.map((item) => item.toJson()).toList(),
          }));
      final payload = ReportingResult(
          summary: await fileRef(summaryPath),
          statistics: await fileRef(statisticsPath),
          process: [await fileRef(processPath)],
          attempts: rows.map((row) => row.reference).toList(),
          dependencies: dependencies);
      final result = OperationResult<ReportingResult>(
          runId: context.runId,
          operationId: context.operationId,
          status: errors.isEmpty
              ? OperationStatus.success
              : OperationStatus.failure,
          data: payload,
          errors: errors,
          evidence: [
            EvidenceRef(path: p.absolute(summaryPath)),
            EvidenceRef(path: p.absolute(statisticsPath)),
            EvidenceRef(path: p.absolute(processPath)),
          ]);
      await validate(payload, snapshot, verifyEvidence: errors.isEmpty);
      return result;
    } catch (error) {
      errors.add(OperationError(
          message: context.redactor.text('Reporting failed: $error'),
          field: 'reporting',
          expected: 'complete reconciled reports',
          actual: null));
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.failure,
          data: null,
          errors: errors,
          evidence: []);
    }
  }

  Future<void> validate(ReportingResult payload, JsonObject snapshot,
      {bool verifyEvidence = true}) async {
    payload.validate();
    for (final file in [
      payload.summary,
      payload.statistics,
      ...payload.process
    ]) {
      await verifyFileRef(file);
    }
    final registered = _attempts(snapshot);
    final wanted = registered
        .map((value) =>
            _key(value['caseName'] as String, value['attempt'] as int))
        .toSet();
    final delivered = payload.attempts
        .map((value) => _key(value.caseName, value.attempt))
        .toList();
    if (delivered.length != wanted.length ||
        delivered.toSet().length != delivered.length ||
        delivered.toSet().difference(wanted).isNotEmpty) {
      throw const FormatException('Report attempt delivery does not reconcile');
    }
    final records =
        parseStatistics(await File(payload.statistics.path).readAsString());
    if (records.isEmpty ||
        jsonEncode(records.first) != jsonEncode(statisticsColumns)) {
      throw const FormatException('Invalid statistics columns');
    }
    final rows = records.skip(1).toList();
    final actual = <String>{};
    for (final row in rows) {
      if (row.length != statisticsColumns.length ||
          row[0] != snapshot['runId'] ||
          !const ['是', '否', '未执行', '未完成'].contains(row[9])) {
        throw const FormatException('Invalid statistics row');
      }
      final number = int.tryParse(row[1]);
      if (number == null || number < 1 || !actual.add(_key(row[2], number))) {
        throw const FormatException('Duplicate or invalid statistics attempt');
      }
    }
    if (actual.length != wanted.length ||
        actual.difference(wanted).isNotEmpty) {
      throw const FormatException('Statistics has missing or extra attempts');
    }
    final replayErrors = <OperationError>[];
    final expectedRows = await _rows(snapshot, replayErrors);
    final redactor = SecretRedactor()..addFrom(snapshot);
    final expectedCells = {
      for (final row in expectedRows)
        _key(row.reference.caseName, row.reference.attempt):
            row.cells.map(redactor.text).toList()
    };
    for (final row in rows) {
      if (jsonEncode(row) !=
          jsonEncode(expectedCells[_key(row[2], int.parse(row[1]))])) {
        throw const FormatException(
            'Statistics content disagrees with fixed inputs or execution evidence');
      }
    }
    if (verifyEvidence && replayErrors.isNotEmpty) {
      throw const FormatException('Reporting input evidence is incomplete');
    }
    final summary = await File(payload.summary.path).readAsString();
    final counts = _counts(rows);
    if (!summary
            .contains('- 用例数：${rows.map((row) => row[2]).toSet().length}\n') ||
        !summary.contains('- 执行次数：${rows.length}\n') ||
        !summary.contains(
            '- 是：${counts['是']}；否：${counts['否']}；未执行：${counts['未执行']}；未完成：${counts['未完成']}\n')) {
      throw const FormatException(
          'Summary counts do not reconcile with statistics');
    }
    final reports = {
      payload.summary.path,
      payload.statistics.path,
      ...payload.process.map((item) => item.path)
    };
    for (final dependency in payload.dependencies) {
      if (!reports.contains(dependency.report))
        throw const FormatException('Dependency has unregistered report');
      if (verifyEvidence) await validateEvidence(dependency.evidence);
    }
  }

  Future<List<_ReportRow>> _rows(
      JsonObject snapshot, List<OperationError> errors) async {
    final rows = <_ReportRow>[];
    for (final attempt in _attempts(snapshot)) {
      final name = attempt['caseName'] as String;
      final number = attempt['attempt'] as int;
      final definition = CaseDefinition.fromJson(attempt['definition']);
      final references = <EvidenceRef>[
        EvidenceRef(path: definition.yaml.path),
        EvidenceRef(path: definition.json.path),
      ];
      var expected = '定义证据缺失';
      var actual = '未产生可验收的执行报告';
      var verdict = attempt['state'] == 'started' ? '未完成' : '未执行';
      final reasons = <String>[];
      try {
        final loaded = await loader.load(definition);
        expected = jsonEncode(_expectationSummary(loaded));
      } catch (error) {
        reasons.add('固定用例不可用：$error');
        errors.add(OperationError(
            message: reasons.last,
            field: 'definition',
            expected: 'registered fixed case',
            actual: null));
      }
      final rawResult = attempt['result'];
      if (rawResult != null) {
        try {
          final operation = OperationResult<ExecutionResult>.fromJson(
              rawResult, ExecutionResult.fromJson);
          final execution = acceptOperation(operation,
              runId: snapshot['runId'] as String,
              producer: 'execution',
              consumer: 'reporting',
              rework: 'execution',
              requireSuccess: false);
          if (execution.caseName != name ||
              execution.attempt != number ||
              execution.launchOperationId != attempt['launchOperationId'] ||
              jsonEncode(execution.definition.toJson()) !=
                  jsonEncode(definition.toJson())) {
            throw const FormatException(
                'Execution identity does not match registered attempt');
          }
          verdict = execution.verdict;
          references.addAll(operation.evidence);
          for (final check in execution.required) {
            references.addAll(check.evidence);
          }
          reasons.addAll(operation.errors.map((item) => item.message));
          if (execution.report != null) {
            references.add(EvidenceRef(path: execution.report!.path));
            final reportPath = execution.report!.path;
            if (p.basename(reportPath) != 'flow-report.json' ||
                p.basename(p.dirname(reportPath)) != '$number' ||
                p.basename(p.dirname(p.dirname(reportPath))) !=
                    p.basenameWithoutExtension(definition.sourceYaml) ||
                p.basename(p.dirname(p.dirname(p.dirname(reportPath)))) !=
                    snapshot['runId']) {
              throw const FormatException(
                  'Report is not in this registered attempt directory');
            }
            await verifyFileRef(execution.report!);
            final report = readObject(
                jsonDecode(await File(execution.report!.path).readAsString()));
            validateRawReport(report, snapshot['runId'] as String, name);
            validation.validateExecutionDelivery(execution, report,
                runId: snapshot['runId'] as String);
            await _validateRequiredEvidence(execution, report);
            actual = jsonEncode({
              'summary': report['summary'],
              'failures': [
                for (final step in (report['steps'] as List).map(readObject))
                  if (step['status'] == 'failed' || step['status'] == 'timeout')
                    {
                      'name': step['name'] ?? step['context'],
                      if (step['agent'] != null) 'role': step['agent'],
                      'status': step['status'],
                      'reason': _shortReason(step['reason']),
                    }
              ],
            });
          } else if (verdict == '是' || verdict == '否') {
            throw const FormatException('Verdict requires an actual report');
          }
          for (final entry in execution.finish.entries) {
            if (!entry.value.success)
              reasons.add('${entry.key} finish 失败：${entry.value.error}');
          }
          if (reasons.isEmpty && verdict != '是')
            reasons.add('实际结果未满足必要验证，见报告。');
        } catch (error) {
          verdict = '未完成';
          reasons.add('执行交付不可用：$error');
          errors.add(OperationError(
              message: reasons.last,
              field: 'attempts.$name.$number.result',
              expected: 'valid execution delivery',
              actual: null));
        }
      } else {
        reasons.add('只有开始记录或缺少终态，原操作结果待查证。');
      }
      for (final rawIssue in _list(snapshot, 'issues')) {
        final issue = readObject(rawIssue);
        if (issue['caseName'] == name && issue['attempt'] == number) {
          if (issue['detail'] is String)
            references.add(EvidenceRef(path: issue['detail'] as String));
          for (final evidence in _list(issue, 'evidence')) {
            references.add(EvidenceRef.fromJson(evidence));
          }
        }
      }
      final unique = <String, EvidenceRef>{
        for (final ref in references) '${ref.path}|${ref.location}': ref
      }.values.toList();
      for (final reference in unique) {
        try {
          await validateEvidence(reference);
        } catch (error) {
          reasons
              .add('证据缺口：${reference.path} ${reference.location ?? ''}：$error');
          errors.add(OperationError(
              message: reasons.last,
              field: 'evidence',
              expected: 'locatable record',
              actual: reference.toJson()));
          if (reference.path == definition.yaml.path ||
              reference.path == definition.json.path) verdict = '未完成';
        }
      }
      final roles = readObject(attempt['roles']);
      final platforms = roles.values
          .map((role) => readObject(role)['platform'])
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
      final direction =
          p.basenameWithoutExtension(definition.sourceYaml).split('-').last;
      rows.add(_ReportRow(
          AttemptRef(caseName: name, attempt: number),
          [
            snapshot['runId'] as String,
            '$number',
            name,
            definition.sourceYaml,
            platforms.join('+'),
            'multi',
            direction,
            expected,
            actual,
            verdict,
            reasons.join('; '),
            unique
                .map((ref) =>
                    '${ref.path}${ref.location == null ? '' : '#${ref.location}'}')
                .join('; '),
          ],
          unique));
    }
    return rows;
  }
}

JsonObject _reportRoles(Object? raw) => {
      if (raw is Map<String, Object?>)
        for (final entry in raw.entries)
          if (entry.value is Map<String, Object?>)
            entry.key: {
              for (final field in ['platform', 'instance'])
                if ((entry.value as Map<String, Object?>)[field] is String)
                  field: (entry.value as Map<String, Object?>)[field],
            },
    };

JsonObject _reportOptions(Object? raw) => {
      if (raw is Map<String, Object?>)
        for (final entry in raw.entries)
          if (const [
                'dataSyncType',
                'debugMode',
                'enableUserInfo',
                'autoLoadConversations',
                'enableChatroomConversation',
                'autoAcceptGroupInvitation',
                'autoAcceptFriendInvitation'
              ].contains(entry.key) &&
              (entry.value is bool || entry.value is int))
            entry.key: entry.value,
    };

Future<JsonObject> _reportConfiguration(JsonObject attempt) async {
  final definition = CaseDefinition.fromJson(attempt['definition']);
  final caseData = attempt['caseData'];
  final result = <String, Object?>{
    'definitionSha256': definition.json.sha256,
    'baseOptions': _reportOptions(
        caseData is Map<String, Object?> ? caseData['initConfig'] : null),
  };
  try {
    final metadata =
        readObject(jsonDecode(await File(definition.json.path).readAsString()));
    result['initCommands'] = {
      for (final raw in (metadata['steps'] as List? ?? const []))
        if (raw is Map<String, Object?> && raw['api'] == 'ChatClient.init')
          raw['id'] as String: _reportOptions(
              raw['params'] is Map<String, Object?>
                  ? (raw['params'] as Map<String, Object?>)['overrides']
                  : null),
    };
  } catch (_) {
    result['optionsRecorded'] = false;
  }
  return result;
}

Future<void> validateEvidence(EvidenceRef reference) async {
  reference.validate();
  if (await FileSystemEntity.type(reference.path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw FileSystemException(
        'Evidence is not an existing regular file', reference.path);
  }
  final location = reference.location;
  if (location == null) return;
  final line = RegExp(r'^(?:line\s*|L)([0-9]+)$').firstMatch(location);
  if (line != null) {
    final lines = await File(reference.path).readAsLines();
    final number = int.parse(line[1]!);
    if (number < 1 || number > lines.length)
      throw const FormatException('Evidence line does not exist');
    return;
  }
  final step = RegExp(r'^steps\[([0-9]+)\]$').firstMatch(location);
  if (step != null) {
    final document =
        readObject(jsonDecode(await File(reference.path).readAsString()));
    final steps = document['steps'];
    if (steps is! List || int.parse(step[1]!) >= steps.length)
      throw const FormatException('Evidence record does not exist');
    return;
  }
  final sequence = RegExp(r'^seq=([0-9]+)$').firstMatch(location);
  if (sequence != null) {
    final matches = await _eventsAt(reference.path, int.parse(sequence[1]!));
    if (matches.length != 1)
      throw const FormatException(
          'Evidence event sequence is missing or duplicated');
    return;
  }
  final text = await File(reference.path).readAsString();
  final records = <Object?>[];
  try {
    final decoded = jsonDecode(text);
    if (decoded is List<Object?>)
      records.addAll(decoded);
    else if (decoded is Map<String, Object?>) records.add(decoded);
  } on FormatException {
    for (final line
        in text.split('\n').where((line) => line.trim().isNotEmpty)) {
      try {
        records.add(jsonDecode(line));
      } on FormatException {
        /* Non-JSON text cannot prove an operation identity. */
      }
    }
  }
  if (records.any((record) =>
      record is Map<String, Object?> && record['operationId'] == location))
    return;
  throw FormatException(
      'Evidence operation or supported location does not exist: $location');
}

List<JsonObject> _attempts(JsonObject snapshot) {
  final result = _list(snapshot, 'attempts').map(readObject).toList();
  final keys = <String>{};
  for (final attempt in result) {
    final reference = AttemptRef.fromJson(
        {'caseName': attempt['caseName'], 'attempt': attempt['attempt']});
    if (!keys.add(_key(reference.caseName, reference.attempt)))
      throw const FormatException('Duplicate registered attempt');
    if (!const ['started', 'completed'].contains(attempt['state']))
      throw const FormatException('Unknown attempt state');
  }
  return result;
}

List<Object?> _list(JsonObject object, String field) {
  final value = object[field];
  if (value is! List<Object?>) throw FormatException('$field must be a list');
  return value;
}

String _key(String caseName, int attempt) => '$caseName/$attempt';
String _quote(String value) => '"${value.replaceAll('"', '""')}"';
Map<String, int> _counts(Iterable<List<String>> rows) {
  final counts = {'是': 0, '否': 0, '未执行': 0, '未完成': 0};
  for (final row in rows) {
    counts[row[9]] = counts[row[9]]! + 1;
  }
  return counts;
}

List<String> _taskFaults(JsonObject snapshot) => [
      for (final raw in _list(snapshot, 'operations'))
        if (readObject(raw)['result'] case final Map<String, Object?> result)
          if (result['status'] == 'failure')
            '${readObject(raw)['stage']}: ${jsonEncode(result['errors'])}',
      for (final raw in _list(snapshot, 'issues'))
        if (readObject(raw)['status'] != 'resolved')
          '待处理故障 ${readObject(raw)['id']}：${readObject(raw)['detail']}',
    ];

List<List<String>> parseStatistics(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  var cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < input.length; i++) {
    final character = input[i];
    if (character == '"') {
      if (quoted && i + 1 < input.length && input[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (character == ',' && !quoted) {
      row.add(cell.toString());
      cell = StringBuffer();
    } else if ((character == '\n' || character == '\r') && !quoted) {
      if (character == '\r' && i + 1 < input.length && input[i + 1] == '\n')
        i++;
      row.add(cell.toString());
      rows.add(row);
      row = [];
      cell = StringBuffer();
    } else {
      cell.write(character);
    }
  }
  if (quoted) throw const FormatException('Unclosed CSV cell');
  if (row.isNotEmpty || cell.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows;
}

class _ReportRow {
  _ReportRow(this.reference, this.cells, this.evidence);
  final AttemptRef reference;
  final List<String> cells;
  final List<EvidenceRef> evidence;
}

Future<List<JsonObject>> _eventsAt(String path, int sequence) async {
  final events = <JsonObject>[];
  for (final line in await File(path).readAsLines()) {
    if (line.trim().isEmpty) continue;
    final event = readObject(jsonDecode(line));
    if (event['seq'] == sequence) events.add(event);
  }
  return events;
}

Future<void> _validateRequiredEvidence(
    ExecutionResult execution, JsonObject report) async {
  final steps = (report['steps'] as List).map(readObject).toList();
  for (final check in execution.required.where((item) => item.passed)) {
    if (check.evidence.isEmpty)
      throw const FormatException('Required assertion has no evidence');
    for (final reference in check.evidence) {
      await validateEvidence(reference);
    }
    final step = steps[check.recordIndices.single];
    if (step['kind'] != 'wait_event') continue;
    final result = readObject(step['result']);
    final eventRefs = check.evidence
        .where((item) => item.location == 'seq=${result['seq']}')
        .toList();
    if (eventRefs.length != 1)
      throw const FormatException(
          'Required event has no unique raw evidence reference');
    final matches =
        await _eventsAt(eventRefs.single.path, result['seq'] as int);
    if (matches.length != 1 ||
        matches.single['source'] != step['name'] ||
        jsonEncode(matches.single['payload']) !=
            jsonEncode(result['payload']) ||
        matches.single['instanceId'] is! String) {
      throw const FormatException(
          'Raw event does not match required assertion');
    }
  }
}

JsonObject _expectationSummary(LoadedCase loaded) {
  final commands = <String>{};
  final events = <JsonObject>[];
  final required = loaded.definition.requiredBindings.toSet();
  void walk(List<Step> steps) {
    for (final step in steps) {
      switch (step) {
        case CmdStep s:
          commands.add(s.cmd);
        case WaitEventStep s:
          if (required.contains(s.as)) {
            events.add({
              'event': s.event,
              'role': s.agent,
              'binding': s.as,
              'match': s.match,
              'checks': s.checks
            });
          }
        case ParallelStep s:
          for (final branch in s.branches.values) {
            walk(branch);
          }
        case IfStep s:
          walk(s.thenSteps);
          walk(s.elseSteps);
        case ForStep s:
          walk(s.doSteps);
        case WhileStep s:
          walk(s.doSteps);
        default:
          break;
      }
    }
  }

  walk(loaded.flow.steps);
  return {
    'requiredBindings': loaded.definition.requiredBindings,
    'commands': [
      for (final command in (loaded.metadata['steps'] as List).map(readObject))
        if (commands.contains(command['id']))
          {'id': command['id'], 'expect': command['expect']},
    ],
    'events': events,
  };
}

String? _shortReason(Object? value) {
  if (value is! String) return null;
  final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return compact.length <= 160 ? compact : '${compact.substring(0, 159)}…';
}
