/// flow_runner CLI — generic YAML control-flow interpreter.
///
/// Usage:
///   dart run tool/flow_runner/bin/flow_runner.dart run <flow.yaml> \
///       [--report-dir <dir>] [--agents-file <agents.json>] [--no-verify-commands]
///
/// Device startup (simulators, app install, port forwarding) is out of
/// scope: agents must already be listening on their endpoints. Dynamic
/// per-run credentials (random ports, pairing tokens, account bindings)
/// come from an agents-file produced by the device-setup orchestration.
library;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/http_agent_client.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser();
  // Options must live on the *command* parser: with package:args everything
  // after "run" is parsed by the command's own ArgParser, so top-level
  // options would never see --report-dir etc. (and command rest args would
  // be read from the wrong results object).
  final runCmd = parser.addCommand('run');
  runCmd
    ..addOption('globals-file',
        help: 'JSON {initial, outputRoots} for strict run data')
    ..addOption('evidence-dir',
        help: 'private directory for runtime values and trace')
    ..addOption('report-dir',
        defaultsTo: 'reports/flow_runner', help: 'directory for run reports')
    ..addOption('agents-file',
        help: 'runtime agent credentials JSON (role/endpoint/token/env); '
            'overrides the YAML agent declarations (dynamic ports/tokens)')
    ..addFlag('no-verify-commands',
        negatable: false,
        help: 'skip the cmd-id-in-script static check (for drafts)');
  final results = parser.parse(argv);

  final cmd = results.command;
  if (cmd?.name != 'run' || cmd!.rest.length != 1) {
    stderr.writeln('usage: flow_runner run <flow.yaml> '
        '[--report-dir <dir>] [--agents-file <agents.json>] '
        '[--no-verify-commands]');
    exit(64);
  }
  final flowPath = cmd.rest.first;

  final spec = parseFlow(
    File(flowPath).readAsStringSync(),
    options: ParseOptions(verifyCommandIds: !cmd.flag('no-verify-commands')),
    sourcePath: flowPath,
  );

  final agentsFilePath = cmd.option('agents-file');
  if (agentsFilePath != null) {
    String jsonText;
    try {
      jsonText = File(agentsFilePath).readAsStringSync();
    } on FileSystemException catch (e) {
      stderr.writeln('agents-file not readable: $e');
      exit(64);
    }
    try {
      final skipped =
          applyAgentsFile(spec, jsonText, sourcePath: agentsFilePath);
      if (skipped.isNotEmpty) {
        stderr.writeln('agents-file roles not declared in this flow '
            '(ignored, the flow uses a device subset): ${skipped.join(', ')}');
      }
    } on FlowParseError catch (e) {
      stderr.writeln('$e');
      exit(64);
    }
  }

  // Every agent must end up with an endpoint (YAML and/or agents-file).
  for (final agent in spec.agents.values) {
    if (agent.endpoint == null) {
      stderr.writeln('agent "${agent.name}" has no endpoint: declare one in '
          'the YAML or provide it via --agents-file (a role-name typo '
          'between flow and agents-file also lands here)');
      exit(64);
    }
  }

  final runId = spec.runId ??
      'flow-${DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-')}';

  // Build clients. Device scripts and envs are loaded by the parser
  // (spec.scripts / spec.envs); commands carry full step content (v2).
  final clients = <String, AgentClient>{};
  for (final agent in spec.agents.values) {
    clients[agent.name] = HttpAgentClient(
      endpoint: agent.endpoint!,
      actor: agent.name,
      token: agent.token,
    );
  }

  final report = ReportCollector()
    ..flowName = spec.name
    ..runId = runId
    ..preconditions = spec.preconditions;
  GlobalData? global;
  final globalsPath = cmd.option('globals-file');
  if (globalsPath != null) {
    final document = jsonDecode(File(globalsPath).readAsStringSync()) as Map;
    global = GlobalData(Map<String, Object?>.from(document['initial'] as Map),
        outputRoots: List<String>.from(document['outputRoots'] as List));
  }
  final exitCode = await _run(spec, runId, clients, report,
      cmd.option('report-dir')!, global, cmd.option('evidence-dir'));

  for (final c in clients.values) {
    if (c is HttpAgentClient) c.close();
  }
  exit(exitCode);
}

Future<int> _run(
  FlowSpec spec,
  String runId,
  Map<String, AgentClient> clients,
  ReportCollector report,
  String reportDir,
  GlobalData? global,
  String? evidenceDir,
) async {
  File? trace;
  if (evidenceDir != null) {
    trace = File('$evidenceDir/trace.jsonl');
    trace.parent.createSync(recursive: true);
    trace.writeAsStringSync('');
    if (!Platform.isWindows) await Process.run('chmod', ['600', trace.path]);
  }
  // Reachability handshake (best effort per agent; a failure here is a
  // setup error, not a test failure).
  for (final e in clients.entries) {
    try {
      await e.value.info();
    } catch (err) {
      stderr.writeln('agent "${e.key}" not reachable at startup: $err');
      return 69; // EX_UNAVAILABLE
    }
  }

  final interp = Interpreter(
    spec: spec,
    agents: clients,
    report: report,
    global: global,
    onTrace: trace == null
        ? null
        : (record) {
            trace!.writeAsStringSync('${jsonEncode(record)}\n',
                mode: FileMode.append, flush: true);
          },
  );
  Object? interpError;
  try {
    final body = interp.run();
    if (spec.flowTimeoutMs != null) {
      await body.timeout(Duration(milliseconds: spec.flowTimeoutMs!),
          onTimeout: () {
        interp.stop();
        report.add(StepRecord(
          kind: 'flow',
          context: 'flow',
          name: 'flowTimeoutMs',
          status: 'timeout',
          durationMs: spec.flowTimeoutMs!,
          reason:
              'flow deadline exceeded; in-flight operations may still finish',
        ));
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
      await c.finish().timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  if (evidenceDir != null) {
    if (global != null) {
      for (final entry in {
        'global-final.json': global.snapshot(),
        'references.json': global.reads
      }.entries) {
        final file = File('$evidenceDir/${entry.key}');
        await file.writeAsString(
            const JsonEncoder.withIndent('  ').convert(entry.value));
        if (!Platform.isWindows) await Process.run('chmod', ['600', file.path]);
      }
    }
    // Agent history starts at App startup and survives /finish. Capture
    // every page, including unconsumed events and terminal command evidence.
    for (final entry in clients.entries) {
      try {
        final file = File('$evidenceDir/${entry.key}-events.jsonl');
        await file.writeAsString('');
        if (!Platform.isWindows) await Process.run('chmod', ['600', file.path]);
        var cursor = 0;
        final drainDeadline = DateTime.now().add(const Duration(seconds: 10));
        while (true) {
          if (DateTime.now().isAfter(drainDeadline)) {
            throw StateError('event evidence did not drain within 10 seconds');
          }
          final events = await entry.value
              .pollEvents(cursor, waitMs: 0)
              .timeout(const Duration(seconds: 5));
          if (events.isEmpty) break;
          for (final event in events) {
            await file.writeAsString(
                '${jsonEncode({
                      'seq': event.seq,
                      'source': event.source,
                      'payload': event.payload
                    })}\n',
                mode: FileMode.append);
          }
          cursor = events.last.seq;
        }
      } catch (error) {
        stderr.writeln('evidence collection failed for ${entry.key}: $error');
        interpError ??= error;
      }
    }
  }

  final reportPath = '$reportDir/$runId/flow-report.json';
  try {
    await report.writeToFile(reportPath);
    stdout.writeln('report written to $reportPath');
  } catch (e) {
    stderr.writeln('failed to write report: $e');
    interpError ??= e;
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
