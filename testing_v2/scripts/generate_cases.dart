import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flow_runner/parser.dart';
import 'package:path/path.dart' as p;
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/devices.dart';
import 'package:testing_v2/src/execution.dart';

List<String> _uniqueStrings(Iterable<Object?> values, String field) {
  final result = <String>[];
  for (final value in values) {
    if (value is! String || value.trim().isEmpty || result.contains(value)) {
      throw FormatException('$field must contain distinct nonempty strings.');
    }
    result.add(value);
  }
  return result;
}

List<String> _choose(
    List<String> available, List<String> requested, String field) {
  _uniqueStrings(requested, field);
  for (final item in requested) {
    if (!available.contains(item)) {
      throw FormatException('Unknown $field: $item');
    }
  }
  return requested.isEmpty ? available : requested;
}

/// Discovers resources and publishes the existing CLI selection format.
/// No tokens are fetched, devices started, or SDK operations executed.
Future<JsonObject> generateCases({
  required Directory root,
  required DevicePlatform platform,
  List<String> caseNames = const [],
  List<String> accountIds = const [],
  List<String> instances = const [],
  DeviceService? devices,
  void Function(String) output = print,
}) async {
  final config = Directory(p.join(root.path, 'config'));
  final input = readObject(jsonDecode(
      await File(p.join(config.path, 'accounts-input.json')).readAsString()));
  final rawAccounts = input['accounts'];
  if (rawAccounts is! List || rawAccounts.isEmpty) {
    throw const FormatException(
        'accounts-input.json needs a nonempty accounts list.');
  }
  final accounts = _choose(
      _uniqueStrings(rawAccounts.map((v) => readObject(v)['id']), 'accounts'),
      accountIds,
      'account');

  final sources = <String, File>{};
  await for (final entity in Directory(p.join(root.path, 'data'))
      .list(recursive: true, followLinks: false)) {
    if (entity is! File || p.extension(entity.path) != '.yaml') continue;
    final name = p.basenameWithoutExtension(entity.path);
    if (sources.containsKey(name)) {
      throw FormatException('Duplicate case basename: $name');
    }
    sources[name] = entity;
  }
  final names = _choose(sources.keys.toList()..sort(), caseNames, 'case');
  final candidates = <File>[];
  for (final name in names) {
    final file = sources[name]!;
    final metadata = readObject(jsonDecode(
        await File(p.setExtension(file.path, '.json')).readAsString()));
    final reason = caseDisabledReason(metadata);
    if (reason != null) {
      if (caseNames.isNotEmpty) {
        throw FormatException('Case is disabled: $name ($reason)');
      }
      output('Skipped $name: $reason');
      continue;
    }
    candidates.add(file);
  }
  if (candidates.isEmpty)
    throw const FormatException('No enabled cases selected.');

  await ensurePrivateDirectory(p.join(root.path, 'tmp'));
  final work = await Directory(p.join(root.path, 'tmp')).createTemp('cases-');
  final context = OperationContext(
      runId: null,
      operationId: 'list-devices',
      tmpDirectory: work,
      redactor: SecretRedactor());
  final validation = Directory(p.join(work.path, 'validation'));
  try {
    final listed = await (devices ?? DeviceService()).list(context, platform);
    listed.validate();
    if (!listed.isSuccess) {
      throw StateError('Device discovery failed: '
          '${listed.errors.map((e) => e.message).join('; ')}; logs: ${work.path}');
    }
    if (listed.data!.any((d) => d.platform != platform)) {
      throw const FormatException(
          'Device discovery returned the wrong platform.');
    }
    final available = _uniqueStrings(
        listed.data!.map((d) => d.instance), 'discovered devices')
      ..sort();
    final selectedDevices = _choose(available, instances, 'instance');
    final loader = CaseLoader(DataService());
    final rows = <JsonObject>[];
    final flowNames = <String>{};
    for (final candidate in candidates) {
      final name = p.basenameWithoutExtension(candidate.path);
      final loaded = await loader.freeze(candidate.path, validation);
      if (!flowNames.add(loaded.flow.name)) {
        throw FormatException('Duplicate flow name: ${loaded.flow.name}');
      }
      final roles = loaded.flow.agents.keys.toList();
      if (selectedDevices.length < roles.length) {
        throw FormatException('$name needs ${roles.length} distinct devices; '
            'found ${selectedDevices.length}.');
      }
      final accountMapping = {
        for (var i = 0; i < accounts.length; i++) 'account${i + 1}': accounts[i]
      };
      final bindings = <String, JsonObject>{
        for (var i = 0; i < roles.length; i++)
          roles[i]: {'platform': platform.name, 'instance': selectedDevices[i]}
      };
      readAccountSelection(accountMapping);
      readDeviceSelection(bindings, roles);
      loader.data.validateCaseMetadata(
          loaded.metadata, loaded.flow.preconditions, accountMapping.keys);
      rows.add({
        'yaml': p.relative(candidate.absolute.path, from: config.path),
        'accounts': accountMapping,
        'devices': bindings,
      });
    }
    final result = <String, Object?>{'cases': rows};
    final destination = p.join(config.path, 'cases.json');
    await writePrivateJson(destination, result);
    output('Generated $destination (${rows.length} cases, ${platform.name})');
    return result;
  } finally {
    if (await validation.exists()) await validation.delete(recursive: true);
  }
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('platform',
        allowed: ['android', 'ios'], help: 'Required target platform.')
    ..addMultiOption('case',
        help:
            'Case basename without .yaml; repeat to select in order. Default: all enabled cases.')
    ..addMultiOption('account',
        help:
            'Account ID from accounts-input.json; repeat to set the account pool order.')
    ..addMultiOption('instance',
        help:
            'Discovered AVD name or iOS UDID; repeat to set YAML role/device order.');
  try {
    final args = parser.parse(arguments);
    if (args['help'] == true) {
      stdout.writeln(
          'Usage: dart run scripts/generate_cases.dart --platform <android|ios> [options]\n'
          'Writes config/cases.json after validation; never changes accounts-input.json.\n${parser.usage}');
      return;
    }
    if (args.rest.isNotEmpty || args['platform'] == null) {
      throw const FormatException(
          '--platform is required; positional arguments are not supported.');
    }
    await generateCases(
        root: File.fromUri(Platform.script).parent.parent,
        platform: DevicePlatform.values.byName(args['platform'] as String),
        caseNames: args['case'] as List<String>,
        accountIds: args['account'] as List<String>,
        instances: args['instance'] as List<String>);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('${error.message}: ${error.path}');
    exitCode = 1;
  } on FlowParseError catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } catch (error) {
    stderr.writeln(
        'Case configuration generation failed (${error.runtimeType}).');
    exitCode = 1;
  }
}
