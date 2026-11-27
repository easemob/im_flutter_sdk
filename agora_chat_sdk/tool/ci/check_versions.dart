import 'dart:io';

import 'version_checker.dart';

void main(List<String> arguments) {
  final repositoryRoot = arguments.isEmpty ? '..' : arguments.single;
  final result = checkVersions(repositoryRoot);

  if (result.errors.isNotEmpty) {
    for (final error in result.errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Versions are consistent: Flutter ${result.flutterVersion}, '
    'Android Native ${result.androidNativeVersion}, '
    'iOS Native ${result.iosNativeVersion}.',
  );
}
