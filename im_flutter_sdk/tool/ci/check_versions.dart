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
    'Versions are consistent: HarmonyOS release line ${result.flutterVersion} '
    '(im_flutter_sdk and im_flutter_sdk_ohos identical; interface/android/ios stay on their '
    'published 4.25.0 releases), '
    'iOS Native ${result.iosNativeVersion} (podspec and Package.swift on the same major.minor line), '
    'Android Native ${result.androidNativeVersion} (independently released, patch digit ignored), '
    'HarmonyOS chatsdk ${result.ohosNativeVersion} (ohpm version or local har, patch digit ignored).',
  );
}
