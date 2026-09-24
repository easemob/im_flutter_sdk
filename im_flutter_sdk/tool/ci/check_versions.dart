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
    'Versions are consistent: Flutter ${result.flutterVersion} (four packages identical, '
    'podspec on the same major.minor line), '
    'iOS Native ${result.iosNativeVersion} (podspec and Package.swift on the same major.minor line), '
    'Android Native ${result.androidNativeVersion} (independently released, patch digit ignored).',
  );
}
