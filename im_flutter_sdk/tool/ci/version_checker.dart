import 'dart:io';

const _packagePaths = <String>[
  'im_flutter_sdk',
  'im_flutter_sdk_ohos',
];

class VersionCheckResult {
  const VersionCheckResult({
    required this.errors,
    required this.flutterVersion,
    required this.androidNativeVersion,
    required this.iosNativeVersion,
    required this.ohosNativeVersion,
  });

  final List<String> errors;
  final String flutterVersion;
  final String androidNativeVersion;
  final String iosNativeVersion;
  final String ohosNativeVersion;
}

/// Checks the version invariants of the HarmonyOS-line release packages:
///
/// 1. the two release packages stay identical (strict equality): `im_flutter_sdk` and
///    `im_flutter_sdk_ohos`. The reused `im_flutter_sdk_interface` / `im_flutter_sdk_android` /
///    `im_flutter_sdk_ios` packages keep their published 4.25.0 releases and are deliberately not
///    part of this check, and the iOS podspec `s.version` is the reused package version, so it is
///    not compared with the release line either;
/// 2. the two iOS native dependency declarations (CocoaPods podspec and SPM `Package.swift`) stay on
///    the same major.minor line, because both integrate the same native SDK;
/// 3. native dependency versions are released independently of this repository, so **the patch
///    digit is never compared**: the release packages at `1.15.0-ohos` may depend on native
///    `4.25.x`, and the two iOS integration paths may differ in the patch digit (`4.25.0` against
///    `4.25.1`), while a different major.minor line (4.24.1 against 4.25.0) is an error;
/// 4. the HarmonyOS chatsdk dependency in `im_flutter_sdk_ohos/ohos/oh-package.json5` stays on the
///    release line's major.minor; before the ohpm release it may be a temporary local har
///    (`file:./libs/chatsdk-x.y.z.har`), which carries the version in the file name.
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

  // Both iOS integration paths link the same native SDK, so they must not drift to another
  // major.minor line. The patch digit is not compared anywhere.
  final iosSpmNativeVersion = _readMatch(
    '$repositoryRoot/im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
    RegExp(r'''\.package\([^)]*exact:\s*"([^"]+)"'''),
    'iOS SPM Native SDK version',
    errors,
  );
  if (!_sameMajorMinor(iosNativeVersion, iosSpmNativeVersion)) {
    errors.add(
      'iOS native dependency mismatch: podspec HyphenateChat $iosNativeVersion '
      'and Package.swift HyphenateChat_iOS $iosSpmNativeVersion are not on the '
      'same major.minor line',
    );
  }

  // The HarmonyOS chatsdk dependency stays on the release line's major.minor. It is either a
  // versioned ohpm dependency ("1.16.0") or, before the ohpm release, a temporary local har
  // ("file:./libs/chatsdk-1.16.0.har"); both forms carry the version used for the comparison.
  final ohosNativeVersion = _readMatch(
    '$repositoryRoot/im_flutter_sdk_ohos/ohos/oh-package.json5',
    RegExp(r'''"@easemob/chatsdk"\s*:\s*"[^"]*?(\d+\.\d+\.\d+)'''),
    'HarmonyOS chatsdk version',
    errors,
  );
  if (!_sameMajorMinor(flutterVersion, ohosNativeVersion)) {
    errors.add(
      'HarmonyOS chatsdk dependency mismatch: oh-package.json5 @easemob/chatsdk '
      '$ohosNativeVersion is not on the same major.minor line as the release '
      'packages $flutterVersion',
    );
  }

  return VersionCheckResult(
    errors: errors,
    flutterVersion: flutterVersion,
    androidNativeVersion: androidNativeVersion,
    iosNativeVersion: iosNativeVersion,
    ohosNativeVersion: ohosNativeVersion,
  );
}

/// Compares only the `major.minor` part, ignoring the patch digit. Empty inputs are ignored so that
/// a missing declaration is reported by [_readMatch] instead of here.
bool _sameMajorMinor(String a, String b) {
  if (a.isEmpty || b.isEmpty) {
    return true;
  }
  return _majorMinor(a) == _majorMinor(b);
}

String _majorMinor(String version) {
  final parts = version.split('.');
  return parts.length >= 2 ? '${parts[0]}.${parts[1]}' : version;
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
