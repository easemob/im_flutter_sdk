import 'dart:io';

const _packagePaths = <String>[
  'im_flutter_sdk',
  'im_flutter_sdk_android',
  'im_flutter_sdk_ios',
  'im_flutter_sdk_interface',
];

class VersionCheckResult {
  const VersionCheckResult({
    required this.errors,
    required this.flutterVersion,
    required this.androidNativeVersion,
    required this.iosNativeVersion,
  });

  final List<String> errors;
  final String flutterVersion;
  final String androidNativeVersion;
  final String iosNativeVersion;
}

VersionCheckResult checkVersions(String repositoryRoot) {
  final errors = <String>[];
  final packageVersions = <String, String>{};

  for (final packagePath in _packagePaths) {
    final path = '$repositoryRoot/$packagePath/pubspec.yaml';
    packageVersions[packagePath] = _readMatch(
      path,
      RegExp(r'^version:\s*([^\s]+)\s*$', multiLine: true),
      'version',
      errors,
    );
  }

  final flutterVersion = packageVersions['im_flutter_sdk'] ?? '';
  for (final entry in packageVersions.entries) {
    if (entry.value.isNotEmpty && entry.value != flutterVersion) {
      errors.add(
        '${entry.key}/pubspec.yaml version ${entry.value} '
        'does not match im_flutter_sdk $flutterVersion',
      );
    }
  }

  final podspecVersion = _readMatch(
    '$repositoryRoot/im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
    RegExp(r'''s\.version\s*=\s*['"]([^'"]+)['"]'''),
    'podspec version',
    errors,
  );
  if (podspecVersion.isNotEmpty && podspecVersion != flutterVersion) {
    errors.add(
      'iOS podspec version $podspecVersion does not match '
      'im_flutter_sdk $flutterVersion',
    );
  }

  final androidNativeVersion = _readMatch(
    '$repositoryRoot/im_flutter_sdk_android/android/build.gradle',
    RegExp(r'''io\.hyphenate:hyphenate-chat:([^'"]+)'''),
    'Android Native SDK version',
    errors,
  );
  final iosNativeVersion = _readMatch(
    '$repositoryRoot/im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
    RegExp(r'''s\.dependency\s+['"]HyphenateChat['"]\s*,\s*['"]([^'"]+)'''),
    'iOS Native SDK version',
    errors,
  );

  return VersionCheckResult(
    errors: errors,
    flutterVersion: flutterVersion,
    androidNativeVersion: androidNativeVersion,
    iosNativeVersion: iosNativeVersion,
  );
}

String _readMatch(
  String path,
  RegExp pattern,
  String field,
  List<String> errors,
) {
  final file = File(path);
  if (!file.existsSync()) {
    errors.add('Missing file for $field: $path');
    return '';
  }

  final match = pattern.firstMatch(file.readAsStringSync());
  if (match == null) {
    errors.add('Could not find $field in $path');
    return '';
  }
  return match.group(1)!;
}
