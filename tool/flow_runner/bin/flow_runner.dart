/// flow_runner CLI — generic YAML control-flow interpreter.
///
/// Usage:
///   dart run tool/flow_runner/bin/flow_runner.dart run <flow.yaml> \
///       [--report-dir <dir>] [--no-verify-commands]
///
/// Device startup (simulators, app install, port forwarding) is out of
/// scope: agents must already be listening on their endpoints.
library;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/http_agent_client.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addCommand('run')
    ..addOption('report-dir',
        defaultsTo: 'testing/reports', help: 'directory for run reports')
    ..addFlag('no-verify-commands',
        negatable: false,
        help: 'skip the cmd-id-in-script static check (for drafts)');
  final results = parser.parse(argv);

  if (results.command?.name != 'run' || results.rest.length != 1) {
    stderr.writeln(
        'usage: flow_runner run <flow.yaml> [--report-dir <dir>] [--no-verify-commands]');
    exit(64);
  }
  final flowPath = results.rest.first;

  final spec = parseFlow(
    File(flowPath).readAsStringSync(),
    options:
        ParseOptions(verifyCommandIds: !results.flag('no-verify-commands')),
  );
  final runId =
      spec.runId ?? 'flow-${DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-')}';

  // Build clients + bind sessions.
  final clients = <String, AgentClient>{};
  final scripts = <String, Map<String, Object?>>{};
  for (final agent in spec.agents.values) {
    if (agent.scriptPath.isNotEmpty) {
      try {
        scripts[agent.name] = Map<String, Object?>.from(
            jsonDecode(File(agent.scriptPath).readAsStringSync()) as Map);
      } catch (e) {
        stderr.writeln('failed to load script for ${agent.name}: $e');
        exit(65);
      }
    }
    clients[agent.name] = HttpAgentClient(
      endpoint: agent.endpoint,
      actor: agent.name,
    );
  }

  final report = ReportCollector()
    ..flowName = spec.name
    ..runId = runId;
  final exitCode = await _run(spec, runId, clients, scripts, report,
      results.option('report-dir')!);

  for (final c in clients.values) {
    if (c is HttpAgentClient) c.close();
  }
  exit(exitCode);
}

Future<int> _run(
  FlowSpec spec,
  String runId,
  Map<String, AgentClient> clients,
  Map<String, Map<String, Object?>> scripts,
  ReportCollector report,
  String reportDir,
) async {
  // Handshake + bind sessions (best effort per agent; a failure here is
  // a setup error, not a test failure).
  final agentInfo = <String, Map<String, Object?>>{};
  for (final e in clients.entries) {
    try {
      agentInfo[e.key] = await e.value.info();
      if (scripts[e.key] != null) {
        await e.value.bindSession(runId, scripts[e.key]!);
      }
    } catch (err) {
      stderr.writeln('agent "${e.key}" not reachable at startup: $err');
      return 69; // EX_UNAVAILABLE
    }
  }

  final interp = Interpreter(
    spec: spec,
    agents: clients,
    report: report,
    agentInfo: agentInfo,
  );
  Object? interpError;
  try {
    final body = interp.run();
    if (spec.flowTimeoutMs != null) {
      await body.timeout(Duration(milliseconds: spec.flowTimeoutMs!),
          onTimeout: () {
        stderr.writeln(
            'flow timeout after ${spec.flowTimeoutMs}ms (flowTimeoutMs)');
      });
    } else {
      await body;
    }
  } catch (e) {
    interpError = e;
  }

  // Finish sessions best effort.
  for (final c in clients.values) {
    try {
      await c.finish();
    } catch (_) {}
  }

  final reportPath = '$reportDir/$runId/flow-report.json';
  try {
    await report.writeToFile(reportPath);
    stdout.writeln('report written to $reportPath');
  } catch (e) {
    stderr.writeln('failed to write report: $e');
  }
  final summary = report.summary();
  stdout.writeln('summary: ${jsonEncode(summary)}');
  if (interpError != null) {
    stderr.writeln('interpreter error: $interpError');
    return 70;
  }
  final bad = (summary['failed'] ?? 0) + (summary['timeout'] ?? 0);
  return bad > 0 ? 1 : 0;
}
