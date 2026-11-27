import 'dart:io';

import 'contract_checker.dart';

void main(List<String> arguments) {
  final repositoryRoot = arguments.isEmpty
      ? Directory.current.parent.path
      : Directory(arguments.single).absolute.path;
  final errors = checkContracts(repositoryRoot);
  if (errors.isEmpty) {
    stdout.writeln('MethodChannel contracts are consistent.');
    return;
  }

  for (final error in errors) {
    stderr.writeln(error);
  }
  exitCode = 1;
}
