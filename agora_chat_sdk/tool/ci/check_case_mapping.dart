import 'dart:io';

import 'case_mapping_checker.dart';

void main(List<String> arguments) {
  final packageRoot = arguments.isEmpty ? '.' : arguments.single;
  final errors = checkCaseMapping(packageRoot);
  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Native-to-Flutter case mapping is valid.');
}
