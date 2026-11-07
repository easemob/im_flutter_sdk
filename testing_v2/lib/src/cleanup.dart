import 'dart:io';

import 'package:path/path.dart' as p;

import 'contracts.dart';
import 'core.dart';

class CleanupService {
  CleanupService({required this.root});
  final Directory root;

  Future<OperationResult<CleanupResult>> clean(
      OperationContext context, JsonObject snapshot, Set<String> types) async {
    final deleted = <String>[];
    final kept = <PathReason>[];
    final failed = <PathReason>[];
    final errors = <OperationError>[];
    final selectedTypes =
        types.contains('all') ? {'cache', 'logs', 'build', 'reports'} : types;
    try {
      if (types.isEmpty ||
          types.difference(
              {'cache', 'logs', 'build', 'reports', 'all'}).isNotEmpty) {
        throw const FormatException(
            'Explicit valid cleanup types are required');
      }
      if (snapshot['runId'] != context.runId)
        throw const FormatException('Cleanup run ownership mismatch');
      final artifacts = _objects(snapshot, 'artifacts');
      final selected = artifacts
          .where((item) => selectedTypes.contains(item['type']))
          .toList();
      final identities = artifacts.map((item) => item['path']).toList();
      if (identities.toSet().length != identities.length)
        throw const FormatException(
            'Artifact paths overlap or have conflicting types');
      final protected = <String, String>{};
      var dependencies = <ReportDependency>[];
      String? globalProtection;
      if (snapshot['status'] != 'stopped') globalProtection = '任务未确认停止，保留运行产物';
      try {
        for (final issue in _objects(snapshot, 'issues')) {
          if (issue['status'] == 'resolved') continue;
          if (issue['status'] != 'unresolved')
            throw const FormatException('Unknown issue state');
          _protect(protected, issue['detail'], '未解决故障记录');
          for (final evidence in _objects(issue, 'evidence')) {
            _protect(protected, EvidenceRef.fromJson(evidence).path, '未解决故障证据');
          }
          for (final artifact in artifacts) {
            if (issue['caseName'] == null ||
                (artifact['caseName'] == issue['caseName'] &&
                    (issue['attempt'] == null ||
                        artifact['attempt'] == issue['attempt']))) {
              _protect(protected, artifact['path'], '未解决故障的复现输入或产物');
            }
          }
          for (final entry in _objects(snapshot, 'cases')) {
            final definition = CaseDefinition.fromJson(entry['definition']);
            if (issue['caseName'] == null ||
                issue['caseName'] == definition.name) {
              _protect(protected, definition.yaml.path, '未解决故障的固定用例');
              _protect(protected, definition.json.path, '未解决故障的固定命令');
            }
          }
        }
        dependencies = _objects(snapshot, 'reportDependencies')
            .map(ReportDependency.fromJson)
            .toList();
        final registered = identities.whereType<String>().toSet();
        for (final dependency in dependencies) {
          if (!registered.contains(dependency.report))
            throw const FormatException('Unknown report dependency owner');
          final owner = artifacts
              .singleWhere((item) => item['path'] == dependency.report);
          if (owner['type'] != 'reports')
            throw const FormatException('Dependency owner is not a report');
        }
        // A retained report protects dependencies transitively, even if they are absent.
        var changed = true;
        while (changed) {
          changed = false;
          for (final dependency in dependencies) {
            final reportSelected =
                selected.any((item) => item['path'] == dependency.report);
            if (!reportSelected ||
                _overlapProtected(dependency.report, protected) != null) {
              if (!protected.containsKey(dependency.evidence.path)) {
                protected[dependency.evidence.path] = '保留报告依赖的证据';
                changed = true;
              }
            }
          }
        }
      } catch (error) {
        globalProtection = '保护索引不完整：$error';
      }
      selected.sort((a, b) {
        final first = a['type'] == 'reports' ? 0 : 1;
        final second = b['type'] == 'reports' ? 0 : 1;
        return first != second
            ? first.compareTo(second)
            : (b['path'] as String)
                .length
                .compareTo((a['path'] as String).length);
      });
      void retainDependencies(String reportPath) {
        var changed = true;
        protected[reportPath] = '删除失败或保留的产物';
        while (changed) {
          changed = false;
          for (final dependency in dependencies) {
            if (_overlapProtected(dependency.report, protected) != null &&
                !protected.containsKey(dependency.evidence.path)) {
              protected[dependency.evidence.path] = '保留报告依赖的证据';
              changed = true;
            }
          }
        }
      }

      final pending = List<JsonObject>.from(selected);
      while (pending.isNotEmpty) {
        final index = pending.indexWhere((candidate) => !dependencies.any(
            (dependency) =>
                (dependency.evidence.path == candidate['path'] ||
                    p.isWithin(candidate['path'] as String,
                        dependency.evidence.path)) &&
                pending.any((owner) =>
                    owner['path'] != candidate['path'] &&
                    (owner['path'] == dependency.report ||
                        p.isWithin(
                            owner['path'] as String, dependency.report)))));
        if (index < 0) {
          for (final candidate in pending) {
            kept.add(PathReason(
                path: candidate['path'] as String, reason: '报告依赖形成循环，保留待查证'));
          }
          break;
        }
        final artifact = pending.removeAt(index);
        final path = artifact['path'];
        if (path is! String || !p.isAbsolute(path))
          throw const FormatException('Artifact path must be absolute');
        final reason = globalProtection ?? _overlapProtected(path, protected);
        if (reason != null) {
          kept.add(PathReason(path: path, reason: reason));
          retainDependencies(path);
          continue;
        }
        try {
          await _checkRange(path, artifact['type'] as String, context.runId!);
          final retainedChild = artifacts.where((entry) =>
              entry['path'] is String &&
              p.isWithin(path, entry['path'] as String) &&
              !selectedTypes.contains(entry['type']));
          if (retainedChild.isNotEmpty) {
            kept.add(PathReason(path: path, reason: '目录包含未选择类型的登记产物'));
            retainDependencies(path);
            continue;
          }
          final type = await FileSystemEntity.type(path, followLinks: false);
          if (type == FileSystemEntityType.directory)
            await Directory(path).delete(recursive: true);
          else if (type == FileSystemEntityType.file)
            await File(path).delete();
          else if (type == FileSystemEntityType.link)
            throw const FileSystemException(
                'Cleanup does not follow artifact links');
          else if (type != FileSystemEntityType.notFound)
            throw const FileSystemException('Unknown artifact file type');
          if (await FileSystemEntity.type(path, followLinks: false) !=
              FileSystemEntityType.notFound) {
            throw const FileSystemException('Path still exists after deletion');
          }
          deleted.add(path);
        } catch (error) {
          final message = context.redactor.text('$error');
          failed.add(PathReason(path: path, reason: message));
          retainDependencies(path);
          errors.add(OperationError(
              message: message,
              field: path,
              expected: 'allowed path deleted',
              actual: 'retained'));
        }
      }
      final payload =
          CleanupResult(deleted: deleted, kept: kept, failed: failed);
      await validate(
          payload, selected.map((item) => item['path'] as String).toSet());
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: errors.isEmpty
              ? OperationStatus.success
              : OperationStatus.failure,
          data: payload,
          errors: errors,
          evidence: []);
    } catch (error) {
      errors.add(OperationError(
          message: context.redactor.text('Cleanup refused: $error'),
          field: 'cleanup',
          expected: 'valid ownership and protection index',
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

  Future<void> validate(CleanupResult result, Set<String> selected) async {
    result.validate();
    final paths = {
      ...result.deleted,
      ...result.kept.map((item) => item.path),
      ...result.failed.map((item) => item.path)
    };
    if (paths.length != selected.length ||
        paths.difference(selected).isNotEmpty) {
      throw const FormatException(
          'Cleanup result does not cover selected paths');
    }
    for (final path in result.deleted) {
      if (await FileSystemEntity.type(path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw const FormatException('Deleted path still exists');
      }
    }
  }

  Future<void> _checkRange(String path, String type, String runId) async {
    final normalized = p.normalize(path);
    final relativeRoot = switch (type) {
      'cache' || 'logs' => 'tmp',
      'build' => 'build',
      'reports' => 'reports',
      _ => throw const FormatException('Unknown cleanup type')
    };
    final boundary =
        p.normalize(p.absolute(p.join(root.path, relativeRoot, runId)));
    if (!p.isWithin(boundary, normalized) ||
        normalized == p.join(boundary, 'run.json')) {
      throw FileSystemException(
          'Path is outside selected owned artifacts', path);
    }
    var cursor = normalized;
    while (p.isWithin(p.absolute(root.path), cursor)) {
      if (await FileSystemEntity.type(cursor, followLinks: false) ==
          FileSystemEntityType.link) {
        throw FileSystemException(
            'Cleanup path has symbolic link component', cursor);
      }
      cursor = p.dirname(cursor);
    }
    // Git remains authoritative: ignored status alone never authorizes deletion.
    final tracked = await Process.run(
        'git', ['ls-files', '--error-unmatch', '--', normalized],
        workingDirectory: root.path);
    if (tracked.exitCode == 0)
      throw FileSystemException('Tracked files cannot be cleaned', path);
    final ignored = await Process.run(
        'git', ['check-ignore', '--quiet', '--', normalized],
        workingDirectory: root.path);
    if (ignored.exitCode != 0)
      throw FileSystemException('Artifact is not Git ignored', path);
  }
}

List<JsonObject> _objects(JsonObject object, String field) {
  final value = object[field];
  if (value is! List<Object?>) throw FormatException('$field must be an array');
  return value.map(readObject).toList();
}

void _protect(Map<String, String> protection, Object? path, String reason) {
  if (path is! String || !p.isAbsolute(path))
    throw const FormatException('Invalid protected path');
  protection[path] = reason;
}

String? _overlapProtected(String path, Map<String, String> protection) {
  for (final entry in protection.entries) {
    if (path == entry.key ||
        p.isWithin(path, entry.key) ||
        p.isWithin(entry.key, path)) return entry.value;
  }
  return null;
}
