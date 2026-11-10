import 'dart:io';

import 'package:testing_v2/src/cli.dart';

Future<void> main(List<String> arguments) async {
  final root = File.fromUri(Platform.script).parent.parent;
  exitCode = await TestingCli(
      root: root,
      upgradeReporter: (directory) async {
        final result = await Process.run('python3', [
          '${root.parent.path}/report_upgrade.py',
          '--multi',
          directory.path,
          '--output',
          directory.path,
        ]);
        stdout.write(result.stdout);
        stderr.write(result.stderr);
        if (result.exitCode != 0) {
          throw StateError('Renderer exited with ${result.exitCode}');
        }
        return [
          '${directory.path}/upgrade-report.md',
          '${directory.path}/upgrade-report.json',
        ];
      }).run(arguments);
}
