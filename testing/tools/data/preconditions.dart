import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/parser.dart';

import '../../../im_flutter_sdk/example/tool/rest_resource_client.dart';

/// Per-flow precondition executor (example-testing-spec: the "case-level
/// arrange" layer).
///
/// Reads the flow YAML's `preconditions` declaration and enforces the
/// required state server-side over REST, *before* any device runs the flow.
/// A failure here is a blocked run (environment), never a test failure.
///
/// Usage:
///   dart run testing/tools/data/preconditions.dart <flow.yaml> \
///       --run-id <id> [--report-dir testing/reports/<runId>]
///
/// - Agent roles resolve to accounts via testing/tmp/<run-id>/agents.json
///   (produced by setup_devices; the role's env.userId is the account).
/// - REST contacts ops bypass the invite flow and are idempotent
///   (probe-verified 2026-11-05); the SDK invite/accept path stays the
///   system under test.
/// - Writes <report-dir>/preconditions.json and prints one line per
///   condition. Exit 0 = all satisfied; 65 = blocked.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    stdout.writeln(
        'usage: preconditions.dart <flow.yaml> --run-id <id> [--report-dir <dir>]');
    return;
  }
  final flowPath = args.first;
  String? runId;
  String reportDir = '';
  for (var i = 1; i < args.length - 1; i++) {
    if (args[i] == '--run-id') runId = args[i + 1];
    if (args[i] == '--report-dir') reportDir = args[i + 1];
  }
  final root = File.fromUri(Platform.script).parent.parent.parent.parent;

  final spec = parseFlow(
    File(flowPath).readAsStringSync(),
    options: const ParseOptions(verifyCommandIds: false),
    sourcePath: flowPath,
  );
  if (spec.preconditions.isEmpty) {
    stdout.writeln('preconditions: none declared');
    return;
  }

  // Role -> account via the run's agents.json.
  final agentsFile = File('${root.path}/testing/tmp/$runId/agents.json');
  if (runId == null || !await agentsFile.exists()) {
    stderr.writeln('preconditions: $agentsFile not found '
        '(run setup_devices --mode control --run-id <id> first)');
    exitCode = 65;
    return;
  }
  final entries = (jsonDecode(await agentsFile.readAsString()) as List)
      .whereType<Map>()
      .map((m) => Map<String, dynamic>.from(m))
      .toList();
  String? accountOf(String role) {
    for (final e in entries) {
      if (e['role'] == role) {
        final env = e['env'];
        if (env is Map && env['userId'] is String) return env['userId'] as String;
      }
    }
    return null;
  }

  final config = Map<String, dynamic>.from(
      jsonDecode(await File('${root.path}/testing/config/environment.local.json')
          .readAsString()) as Map);
  final client = await RestResourceClient.fromConfig(config);

  final results = <Map<String, Object?>>[];
  var blocked = false;
  try {
    for (final p in spec.preconditions) {
      if (p.kind != 'contacts') {
        results.add({'declared': p.toJson(), 'status': 'unsupported'});
        blocked = true;
        continue;
      }
      final a = accountOf(p.between.first);
      final b = accountOf(p.between[1]);
      if (a == null || b == null) {
        results.add({
          'declared': p.toJson(),
          'status': 'blocked',
          'reason': 'no account bound for roles ${p.between} in agents.json',
        });
        blocked = true;
        continue;
      }
      try {
        switch (p.state) {
          case 'friends':
            await client.addContacts(a, b);
          case 'none':
            await client.removeContacts(a, b);
          default:
            throw StateError('unreachable state ${p.state}');
        }
        results.add({
          'declared': p.toJson(),
          'users': [a, b],
          'status': 'satisfied',
        });
        stdout.writeln('precondition ok: ${p.between.join('-')} '
            '${p.state == 'friends' ? '已是好友' : '非好友'} ($a, $b)');
      } catch (e) {
        results.add({
          'declared': p.toJson(),
          'users': [a, b],
          'status': 'blocked',
          'reason': e.toString(),
        });
        blocked = true;
        stderr.writeln('precondition blocked: ${p.toJson()} -> $e');
      }
    }
  } finally {
    client.close();
  }

  if (reportDir.isEmpty) {
    reportDir = '${root.path}/testing/reports/$runId';
  }
  if (reportDir.isNotEmpty) {
    final out = File('$reportDir/preconditions.json');
    await out.parent.create(recursive: true);
    await out.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(results)}\n');
    stdout.writeln('preconditions report: ${out.path}');
  }
  exitCode = blocked ? 65 : 0;
}
