import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/parser.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/global_data.dart';
import 'package:yaml/yaml.dart';

import '../data/environment.dart';

const outputRoots = ['global.biz.result', 'global.biz.event'];

/// Enforce this testing project's domain contract outside the interpreter.
void validateGlobalContract(FlowSpec spec, Map<String, Object?> initial) {
  final globals = GlobalData(initial, outputRoots: outputRoots);
  final bindings = <String>{};
  final values = <Object?>[];
  var usesGlobal = false;
  void walk(List<Step> steps) {
    for (final step in steps) {
      String? name;
      String? prefix;
      if (step is CmdStep) {
        name = step.as;
        prefix = 'global.biz.result.';
        values.addAll(
            [step.inputs, spec.scripts[step.agent]!.stepsById[step.cmd]]);
      } else if (step is WaitEventStep) {
        name = step.as;
        prefix = 'global.biz.event.';
        values.addAll([step.match, step.checks]);
      } else if (step is ParallelStep) {
        step.branches.values.forEach(walk);
      } else if (step is IfStep) {
        walk(step.thenSteps);
        walk(step.elseSteps);
      } else if (step is ForStep) {
        walk(step.doSteps);
      } else if (step is WhileStep) {
        walk(step.doSteps);
      }
      if (name != null && name.startsWith('global.')) {
        usesGlobal = true;
        if (!name.startsWith(prefix!))
          throw FormatException('Wrong output domain: $name');
        globals.claim(name);
        bindings.add(name);
      }
    }
  }

  walk(spec.steps);
  if (!usesGlobal)
    return; // Existing contact/legacy flows retain their contract.
  void check(Object? v) {
    if (v is String && v.startsWith(r'$')) {
      if (!v.startsWith(r'$global.')) {
        throw FormatException('Use global data in migrated command values: $v');
      }
      final path = v.substring(1);
      if (!bindings.any((b) => path == b || path.startsWith('$b.')))
        globals.read(path);
    }
    if (v is Map) v.values.forEach(check);
    if (v is List) v.forEach(check);
  }

  values.forEach(check);
}

/// Join by role only. Neither device position nor business-field names matter.
List<Map<String, dynamic>> joinAgents(
    List<dynamic> devices, List<dynamic> data, List<String> roles) {
  Map<String, Map<String, dynamic>> indexed(List<dynamic> items) {
    final result = <String, Map<String, dynamic>>{};
    for (final raw in items) {
      final item = Map<String, dynamic>.from(raw as Map);
      final role = item['role'];
      if (role is! String || result.containsKey(role)) {
        throw const FormatException('Missing or duplicate role');
      }
      result[role] = item;
    }
    if (result.length != roles.length ||
        roles.any((r) => !result.containsKey(r))) {
      throw const FormatException(
          'Device/data roles must exactly match the flow');
    }
    return result;
  }

  final d = indexed(devices);
  final e = indexed(data);
  return [
    for (final role in roles)
      {...d[role]!, 'env': Map<String, dynamic>.from(e[role]!['env'] as Map)},
  ];
}

Future<void> main(List<String> args) async {
  try {
    if (args.length < 2 ||
        !['roles', 'bind'].contains(args[0]) ||
        (args[0] == 'bind' && args.length != 3)) {
      throw const FormatException(
          'context.dart roles <flow> [single] | bind <run-id> <flow>');
    }
    final source = File(args[0] == 'roles' ? args[1] : args[2]).absolute;
    final text = await source.readAsString();
    final spec = parseFlow(text, sourcePath: source.path);
    final roles = spec.agents.keys.toList();
    for (final role in roles) {
      if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,31}$').hasMatch(role)) {
        throw FormatException('Invalid device role: $role');
      }
    }
    if (args[0] == 'roles') {
      if (args.length == 3 && args[2] == 'single' && roles.length != 1) {
        throw const FormatException('run_single requires exactly one agent');
      }
      stdout.writeln(roles.join(','));
      return;
    }
    final id = checkedId(args[1]);
    final root = File.fromUri(Platform.script).parent.parent.parent.parent;
    final run = Directory('${root.path}/testing/tmp/$id');
    if (await File('${run.path}/flow.yaml').exists()) {
      throw const FormatException('Context already bound; use a fresh run ID');
    }
    final devices =
        jsonDecode(await File('${run.path}/devices.json').readAsString())
            as List;
    final data =
        jsonDecode(await File('${run.path}/role-data.json').readAsString())
            as List;
    final agents = joinAgents(devices, data, roles);
    final initial = Map<String, Object?>.from(
        await readObject(File('${run.path}/data.json')));
    initial['device'] = {
      for (final device in agents)
        device['role'] as String: {
          for (final key in ['platform', 'udid', 'endpoint', 'instanceId'])
            key: device[key],
        },
    };
    validateGlobalContract(spec, initial);
    await writePrivateJson(File('${run.path}/global.json'), {
      'initial': initial,
      'outputRoots': outputRoots,
    });
    await writePrivateJson(File('${run.path}/agents.json'), agents);

    // Keep the source files untouched; runtime report IDs and paths are explicit.
    final doc = jsonDecode(jsonEncode(loadYaml(text))) as Map<String, dynamic>;
    doc['runId'] = id;
    await Directory('${run.path}/scripts').create(recursive: true);
    for (final role in roles) {
      final agent = (doc['agents'] as Map)[role] as Map;
      final script =
          File.fromUri(source.parent.uri.resolve(agent['script'] as String));
      final snapshot = await script.copy('${run.path}/scripts/$role.json');
      agent['script'] = snapshot.absolute.path;
      if (agent['env'] is String) {
        agent['env'] =
            source.parent.uri.resolve(agent['env'] as String).toFilePath();
      }
      agent.remove('endpoint');
      agent.remove('token');
    }
    await writePrivateJson(File('${run.path}/flow.yaml'), doc);
    stdout.writeln('OK agents=${run.path}/agents.json');
  } catch (error) {
    stderr.writeln('context: $error');
    exitCode = 65;
  }
}
