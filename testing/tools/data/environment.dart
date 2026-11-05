import 'dart:convert';
import 'dart:io';

import '../../../im_flutter_sdk/example/tool/env_tool.dart';

EnvPaths testingEnvPaths(Directory root) => EnvPaths(
  Directory('${root.path}/im_flutter_sdk/example'),
  config: File('${root.path}/testing/config/environment.local.json'),
  template: File('${root.path}/testing/config/environment.example.json'),
);

Future<void> ensureTestingEnvironment(Directory root) async {
  final paths = testingEnvPaths(root);
  final legacy = File('${paths.exampleDir.path}/config.local.json');
  if (!await paths.localConfig.exists() && await legacy.exists()) {
    await paths.localConfig.parent.create(recursive: true);
    await paths.localConfig.writeAsBytes(
      await legacy.readAsBytes(),
      flush: true,
    );
    await restrictFile(paths.localConfig);
    stdout.writeln('Imported existing local config; original kept.');
  }
  await ensureLocalFiles(paths);
}

Future<void> restrictFile(File file) async {
  if (!Platform.isWindows) {
    final result = await Process.run('chmod', ['600', file.path]);
    if (result.exitCode != 0) throw StateError('Cannot protect ${file.path}');
  }
}

String checkedId(String value) {
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,100}$').hasMatch(value)) {
    throw const FormatException('Use a short alphanumeric run/actor ID');
  }
  return value;
}

Future<Map<String, dynamic>> readObject(File file) async =>
    Map<String, dynamic>.from(jsonDecode(await file.readAsString()) as Map);

Future<void> writePrivateJson(File file, Object? value) async {
  await file.parent.create(recursive: true);
  final temporary = File('${file.path}.pending');
  await temporary.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
    flush: true,
  );
  await restrictFile(temporary);
  await temporary.rename(file.path);
}

Future<void> main(List<String> args) async {
  try {
    final root = File.fromUri(Platform.script).parent.parent.parent.parent;
    if (args.isEmpty || args.contains('--help')) {
      stdout.writeln('environment.dart ensure|gettoken [run-id]');
      return;
    }
    if (args.length > 2 || !['ensure', 'gettoken'].contains(args.first)) {
      throw const FormatException('Expected ensure|gettoken [run-id]');
    }
    await ensureTestingEnvironment(root);
    if (args.first == 'gettoken') {
      final runId = args.length == 2 ? checkedId(args[1]) : null;
      final output = runId == null
          ? null
          : File('${root.path}/testing/tmp/$runId/main/environment.json');
      if (output != null && await output.exists()) {
        throw StateError('Run already prepared; use a new run ID');
      }
      await generateEnvironment(testingEnvPaths(root), runtimeConfig: output);
    }
  } catch (error) {
    stderr.writeln('environment: $error');
    exitCode = 1;
  }
}
