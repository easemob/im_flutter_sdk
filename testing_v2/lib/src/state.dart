import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'contracts.dart';
import 'core.dart';

/// The sole owner of run snapshots and artifact registration.
class RunStore {
  RunStore(this.root);
  final Directory root;
  static final Set<String> _heldResources = {};
  Directory directory(String runId) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]*$').hasMatch(runId)) {
      throw const FormatException('Invalid run ID');
    }
    return Directory(p.join(root.path, 'tmp', runId));
  }

  Future<RunState> create(String scene) async {
    final time = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${time.year}${pad(time.month)}${pad(time.day)}-${pad(time.hour)}${pad(time.minute)}${pad(time.second)}';
    final suffix =
        Random.secure().nextInt(0x100000000).toRadixString(16).padLeft(8, '0');
    final id = '$stamp-$scene-$suffix';
    final target = directory(id);
    if (await target.exists())
      throw const FileSystemException('Run ID collision');
    final state = RunState(this, {
      'runId': id,
      'status': 'stopped',
      'observedAt': DateTime.now().toUtc().toIso8601String(),
      'environment': null,
      'cases': <Object?>[],
      'operations': <Object?>[],
      'devices': <String, Object?>{},
      'builds': <String, Object?>{},
      'connections': <String, Object?>{},
      'attempts': <Object?>[],
      'artifacts': <Object?>[],
      'issues': <Object?>[],
      'reportDependencies': <Object?>[],
      'reporting': null,
    });
    await state.save();
    return state;
  }

  Future<RunState> load(String id) async {
    final file = File(p.join(directory(id).path, 'run.json'));
    if (!await file.exists())
      throw const FormatException('Requested run does not exist');
    final snapshot = readObject(jsonDecode(await file.readAsString()), 'run');
    if (snapshot['runId'] != id)
      throw const FormatException('Snapshot identity mismatch');
    for (final key in [
      'cases',
      'operations',
      'attempts',
      'artifacts',
      'issues',
      'reportDependencies'
    ]) {
      if (snapshot[key] is! List)
        throw FormatException('Invalid snapshot $key');
    }
    for (final key in ['devices', 'builds', 'connections']) {
      if (snapshot[key] is! Map<String, Object?>)
        throw FormatException('Invalid snapshot $key');
    }
    if (!['running', 'stopped', 'unknown'].contains(snapshot['status'])) {
      throw const FormatException('Invalid run state');
    }
    return RunState(this, snapshot);
  }

  Future<RunLease> lock(String resource) async {
    final path = p.join(root.path, 'tmp', '.locks',
        '${sha256.convert(utf8.encode(resource))}.lock');
    if (!_heldResources.add(path))
      throw StateError('Resource already in use: $resource');
    RandomAccessFile? handle;
    try {
      await File(path).parent.create(recursive: true);
      handle = await File(path).open(mode: FileMode.append);
      await handle.lock(FileLock.exclusive);
      return RunLease(handle, () => _heldResources.remove(path));
    } catch (_) {
      await handle?.close();
      _heldResources.remove(path);
      throw StateError('Resource already in use: $resource');
    }
  }
}

class RunLease {
  RunLease(this.handle, this.onRelease);
  final RandomAccessFile handle;
  final void Function() onRelease;
  Future<void> release() async {
    try {
      await handle.unlock();
      await handle.close();
    } finally {
      onRelease();
    }
  }
}

class RunState {
  RunState(this.store, this.json);
  final RunStore store;
  final JsonObject json;
  String get id => json['runId'] as String;
  Directory get directory => store.directory(id);
  String get path => p.join(directory.path, 'run.json');
  List<JsonObject> get cases => (json['cases'] as List).cast<JsonObject>();
  List<JsonObject> get attempts =>
      (json['attempts'] as List).cast<JsonObject>();
  List<JsonObject> get operations =>
      (json['operations'] as List).cast<JsonObject>();
  List<JsonObject> get issues => (json['issues'] as List).cast<JsonObject>();
  List<JsonObject> get artifacts =>
      (json['artifacts'] as List).cast<JsonObject>();
  JsonObject get devices => json['devices'] as JsonObject;
  JsonObject get builds => json['builds'] as JsonObject;
  JsonObject get connections => json['connections'] as JsonObject;

  Future<void> save() async {
    json['observedAt'] = DateTime.now().toUtc().toIso8601String();
    await writePrivateJson(path, json);
  }

  Future<void> log(String stage, String operationId, String event,
      SecretRedactor redactor, JsonObject fields) async {
    final logPath = p.join(directory.path, 'run.log');
    if (!await File(logPath).exists()) await writePrivateFile(logPath, '');
    await File(logPath).writeAsString(
        '${jsonEncode(redactor.sanitize({
              'time': DateTime.now().toUtc().toIso8601String(),
              'runId': id,
              'stage': stage,
              'operationId': operationId,
              'event': event,
              ...fields,
            }))}\n',
        mode: FileMode.append,
        flush: true);
    register(logPath, 'logs', 'orchestration', 'run-log');
  }

  String allocateOperation(String stage) => '$stage-${operations.length + 1}';

  Future<void> begin(String operationId, String stage) async {
    if (operations.any((item) => item['operationId'] == operationId))
      throw StateError('Duplicate operation ID');
    operations.add({
      'operationId': operationId,
      'stage': stage,
      'state': 'started',
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'result': null
    });
    await save();
  }

  Future<void> complete<T>(OperationResult<T> result, String stage) async {
    result.validate();
    if (result.runId != id)
      throw const FormatException('Operation belongs to another run');
    final record = operations
        .singleWhere((item) => item['operationId'] == result.operationId);
    record['state'] = 'completed';
    record['finishedAt'] = DateTime.now().toUtc().toIso8601String();
    record['result'] = result.toJson();
    for (final ref in result.evidence) {
      if (await File(ref.path).exists() &&
          p.isWithin(store.root.path, ref.path)) {
        final type = p.isWithin(p.join(store.root.path, 'reports'), ref.path)
            ? 'reports'
            : p.isWithin(p.join(store.root.path, 'build'), ref.path)
                ? 'build'
                : 'logs';
        if (p.isWithin(directory.path, ref.path) || type != 'logs') {
          register(ref.path, type, stage, result.operationId);
        }
      }
    }
    await save();
  }

  void register(String path, String type, String stage, String operationId,
      {String? caseName, int? attempt}) {
    final canonical = p.normalize(p.absolute(path));
    final existing = artifacts.where((item) => item['path'] == canonical);
    if (existing.isNotEmpty) {
      if (existing.single['type'] != type)
        throw const FormatException('Artifact has conflicting cleanup types');
      return;
    }
    artifacts.add({
      'path': canonical,
      'type': type,
      'stage': stage,
      'operationId': operationId,
      'caseName': caseName,
      'attempt': attempt
    });
  }

  JsonObject caseBySource(String source) {
    final canonical = p.normalize(p.absolute(source));
    final matches = cases.where(
        (entry) => (entry['definition'] as Map)['sourceYaml'] == canonical);
    if (matches.length != 1)
      throw const FormatException(
          'Case is not uniquely registered in this run');
    return matches.single;
  }

  Future<JsonObject> newAttempt(JsonObject entry) async {
    final definition = CaseDefinition.fromJson(entry['definition']);
    final prior = attempts.where((a) => a['caseName'] == definition.name);
    final number = prior.isEmpty
        ? 1
        : prior.map((a) => a['attempt'] as int).reduce(max) + 1;
    final attempt = <String, Object?>{
      'caseName': definition.name,
      'attempt': number,
      'definition': definition.toJson(),
      'roles': entry['roles'],
      'caseData': null,
      'launchOperationId': null,
      'state': 'started',
      'result': null
    };
    attempts.add(attempt);
    await save();
    return attempt;
  }

  Future<void> invalidateDevices(
      Iterable<String> deviceIds, String reason) async {
    final now = DateTime.now().toUtc().toIso8601String();
    for (final raw in connections.values) {
      final operation = readObject(raw);
      final data = operation['data'];
      if (data is! Map) continue;
      final roles = data['roles'];
      if (roles is! Map) continue;
      for (final value in roles.values) {
        if (value is Map && deviceIds.contains(value['deviceId'])) {
          value['invalidatedAt'] = now;
          value['invalidatedReason'] = reason;
        }
      }
    }
    await save();
  }

  Future<void> claimLaunch(
      String launchId, String caseName, int attempt) async {
    final raw = readObject(connections[launchId], 'launch');
    final launch =
        OperationResult<LaunchResult>.fromJson(raw, LaunchResult.fromJson);
    if (launch.data == null ||
        launch.data!.caseName != caseName ||
        launch.status != OperationStatus.success) {
      throw const FormatException(
          'Launch is incomplete or belongs to another case');
    }
    final roles = readObject(readObject(raw['data'])['roles']);
    for (final connection in roles.values) {
      final value = readObject(connection);
      if (value['usedBy'] != null || value['invalidatedAt'] != null)
        throw const FormatException('Launch already used or invalidated');
    }
    for (final connection in roles.values) {
      (connection as JsonObject)['usedBy'] =
          AttemptRef(caseName: caseName, attempt: attempt).toJson();
    }
    (raw['data'] as JsonObject)['roles'] = roles;
    connections[launchId] = raw;
    await save();
  }

  Future<void> issue(String stage, String message, SecretRedactor redactor,
      {String? caseName,
      int? attempt,
      Iterable<EvidenceRef> evidence = const [],
      Iterable<String> resources = const []}) async {
    final issueId = 'issue-${issues.length + 1}';
    final issuePath = p.join(directory.path, '$issueId.md');
    final refs = evidence.toList();
    final body = '''# $issueId

- 轮次：$id
- 阶段：$stage
- 用例／执行序号：${caseName ?? '不涉及'} / ${attempt ?? '不涉及'}
- 状态：未解决${caseName == null ? '' : '；待复验'}
- 责任模块：待定位（发生阶段：$stage）
- 输入快照：$path（私有文件）
- 事实：${redactor.text(message)}
- 预期：阶段交付满足执行规格；具体差异见操作记录。
- 影响：阻断依赖相关资源的操作，其他用例独立核验。
- 证据：${refs.isEmpty ? '缺少证据，需补充' : refs.map((r) => '${r.path} ${r.location ?? ''}').join('; ')}
- 已尝试／修复／复验：尚未执行；不自动重放业务操作。
- 下一步：核对操作原始错误与上下游交付，按责任模块修复并显式复验。
''';
    await writePrivateFile(issuePath, body);
    issues.add({
      'id': issueId,
      'status': 'unresolved',
      'detail': issuePath,
      'caseName': caseName,
      'attempt': attempt,
      'evidence': refs.map((r) => r.toJson()).toList(),
      'resources': resources.toList()
    });
    register(issuePath, 'logs', stage, issueId,
        caseName: caseName, attempt: attempt);
    await save();
  }

  Future<void> resolveIssue(String issueId,
      {required String conclusion,
      required List<EvidenceRef> verification,
      required SecretRedactor redactor}) async {
    if (conclusion.trim().isEmpty || verification.isEmpty) {
      throw const FormatException(
          'Explicit conclusion and verification evidence are required');
    }
    final issue = issues.singleWhere((item) => item['id'] == issueId);
    for (final ref in verification) {
      ref.validate();
      if (!await File(ref.path).exists())
        throw const FormatException('Resolution evidence is missing');
    }
    final detail = File(issue['detail'] as String);
    await detail.writeAsString(
        '\n## 明确解决\n\n${redactor.text(conclusion)}\n\n'
        '${verification.map((ref) => '${ref.path} ${ref.location ?? ''}').join('\n')}\n',
        mode: FileMode.append,
        flush: true);
    issue['status'] = 'resolved';
    issue['conclusion'] = redactor.text(conclusion);
    issue['verification'] = verification.map((ref) => ref.toJson()).toList();
    await save();
  }
}
