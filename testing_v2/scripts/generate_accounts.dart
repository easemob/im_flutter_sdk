import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/data.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    stdout.writeln(
        'Usage: dart run scripts/generate_accounts.dart --input <private.json>\n'
        'Fetch existing account tokens and atomically generate lib/accounts.g.dart.\n'
        'Input: appKey, accounts[{id}], restApi, clientId, clientSecret; optional SDK options and resources.\n'
        'Output: private lib/accounts.g.dart. Exit 0 on success, 1 on failure, 64 on invalid arguments.\n'
        'Example: dart run scripts/generate_accounts.dart --input tmp/accounts-input.json');
    return;
  }
  if (arguments.length != 2 || arguments.first != '--input') {
    stderr.writeln('Expected --input <private.json>. Use --help for details.');
    exitCode = 64;
    return;
  }
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));
  final operationId = 'generate-${DateTime.now().microsecondsSinceEpoch}';
  final result = await DataService().generate(
    context: OperationContext(
        runId: null,
        operationId: operationId,
        tmpDirectory: Directory(p.join(root, 'tmp')),
        redactor: SecretRedactor()),
    inputPath: p.absolute(arguments[1]),
    outputPath: p.join(root, 'lib', 'accounts.g.dart'),
  );
  if (result.status == OperationStatus.success) {
    stdout.writeln('Generated ${p.join(root, 'lib', 'accounts.g.dart')}');
  } else {
    for (final error in result.errors) {
      stderr.writeln(error.message);
    }
    exitCode = 1;
  }
}
