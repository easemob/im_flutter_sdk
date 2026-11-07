import 'dart:io';

import 'package:testing_v2/src/cli.dart';

Future<void> main(List<String> arguments) async {
  final root = File.fromUri(Platform.script).parent.parent;
  exitCode = await TestingCli(root: root).run(arguments);
}
