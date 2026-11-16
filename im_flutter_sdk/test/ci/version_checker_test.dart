import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/ci/version_checker.dart';

void main() {
  late Directory fixture;

  setUp(() {
    fixture = Directory.systemTemp.createTempSync('flutter-version-checker-');
  });

  tearDown(() {
    fixture.deleteSync(recursive: true);
  });

  void write(String relativePath, String content) {
    final file = File('${fixture.path}/$relativePath');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  /// HarmonyOS line release version; the two release packages must match exactly.
  const releaseVersion = '1.15.0-ohos';

  void writeValidFixture() {
    // Release packages: main package plus the HarmonyOS implementation.
    for (final package in <String>['im_flutter_sdk', 'im_flutter_sdk_ohos']) {
      write('$package/pubspec.yaml',
          'name: $package\nversion: $releaseVersion\n');
    }
    // Reused packages: published 4.25.0 releases, excluded from the release line.
    for (final package in <String>[
      'im_flutter_sdk_interface',
      'im_flutter_sdk_android',
      'im_flutter_sdk_ios',
    ]) {
      write('$package/pubspec.yaml', 'name: $package\nversion: 4.25.0\n');
    }
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.25.0'\ns.dependency 'HyphenateChat','4.25.0'\n",
    );
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.25.0"),\n'
          '  .package(name: "FlutterFramework", path: "../FlutterFramework")\n'
          ']\n',
    );
    write(
      'im_flutter_sdk_android/android/build.gradle',
      "implementation 'io.hyphenate:hyphenate-chat:4.25.1'\n",
    );
    write(
      'im_flutter_sdk_ohos/ohos/oh-package.json5',
      '{\n  "dependencies": {\n    "@easemob/chatsdk": "1.15.0"\n  }\n}\n',
    );
  }

  test('accepts aligned release versions with reused packages at 4.25.0', () {
    writeValidFixture();

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.flutterVersion, releaseVersion);
    expect(result.androidNativeVersion, '4.25.1');
    expect(result.iosNativeVersion, '4.25.0');
  });

  test('does not compare the reused package versions with the release line',
      () {
    writeValidFixture();
    // The reused packages stay on their published 4.25.0 releases: the checker must
    // never require them to match 1.15.0-ohos nor report them as leaving the 1.x line.
    write(
      'im_flutter_sdk_interface/pubspec.yaml',
      'name: im_flutter_sdk_interface\nversion: 4.25.0\n',
    );
    write(
      'im_flutter_sdk_android/pubspec.yaml',
      'name: im_flutter_sdk_android\nversion: 4.25.0\n',
    );
    write(
      'im_flutter_sdk_ios/pubspec.yaml',
      'name: im_flutter_sdk_ios\nversion: 4.25.0\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
  });

  test('accepts an Android native version independent of the Flutter version',
      () {
    writeValidFixture();
    write(
      'im_flutter_sdk_android/android/build.gradle',
      "implementation 'io.hyphenate:hyphenate-chat:4.25.2'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.androidNativeVersion, '4.25.2');
  });

  test('ignores the patch digit of both iOS integration paths', () {
    writeValidFixture();
    // Both iOS paths move to 4.25.4 while the release packages stay on 1.15.0-ohos.
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.25.0'\ns.dependency 'HyphenateChat','4.25.4'\n",
    );
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.25.4"),\n'
          ']\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.iosNativeVersion, '4.25.4');
  });

  test('accepts a podspec version decoupled from the release package version',
      () {
    writeValidFixture();
    // The reused iOS package keeps its published podspec version 4.25.0 while the
    // release packages are on 1.15.0-ohos: the checker no longer compares them.
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.25.0'\ns.dependency 'HyphenateChat','4.25.0'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
  });

  test('reports the two iOS integration paths drifting aside', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.24.1"),\n'
          ']\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('iOS native dependency mismatch'));
    expect(result.errors.single, contains('major.minor'));
    expect(result.errors.single, contains('4.25.0'));
    expect(result.errors.single, contains('4.24.1'));
  });

  test('reports the HarmonyOS implementation package out of line', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ohos/pubspec.yaml',
      'name: im_flutter_sdk_ohos\nversion: 1.14.0-ohos\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('im_flutter_sdk_ohos'));
    expect(
      result.errors.single,
      contains('does not match im_flutter_sdk $releaseVersion'),
    );
  });

  test('reports a release package on a different version', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ohos/pubspec.yaml',
      'name: im_flutter_sdk_ohos\nversion: 2.0.0-ohos\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(
      result.errors.single,
      contains('does not match im_flutter_sdk $releaseVersion'),
    );
  });

  test('reports a missing release package pubspec', () {
    writeValidFixture();
    File('${fixture.path}/im_flutter_sdk_ohos/pubspec.yaml').deleteSync();

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('Missing file for version'));
  });

  test('does not require the reused package pubspec files', () {
    writeValidFixture();
    for (final package in <String>[
      'im_flutter_sdk_interface',
      'im_flutter_sdk_android',
      'im_flutter_sdk_ios',
    ]) {
      File('${fixture.path}/$package/pubspec.yaml').deleteSync();
    }

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
  });

  test('accepts a temporary local har chatsdk dependency', () {
    writeValidFixture();
    // Before the ohpm release the chatsdk dependency is a local har file; the
    // version in the file name stays on the release line's major.minor.
    write(
      'im_flutter_sdk_ohos/ohos/oh-package.json5',
      '{\n  "dependencies": {\n'
          '    "@easemob/chatsdk": "file:./libs/chatsdk-1.15.0.har"\n  }\n}\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.ohosNativeVersion, '1.15.0');
  });

  test('ignores the patch digit of the chatsdk dependency', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ohos/ohos/oh-package.json5',
      '{\n  "dependencies": {\n    "@easemob/chatsdk": "1.15.2"\n  }\n}\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.ohosNativeVersion, '1.15.2');
  });

  test('reports the chatsdk dependency drifting off the release line', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ohos/ohos/oh-package.json5',
      '{\n  "dependencies": {\n    "@easemob/chatsdk": "1.16.0"\n  }\n}\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(
      result.errors.single,
      contains('HarmonyOS chatsdk dependency mismatch'),
    );
    expect(result.errors.single, contains('1.16.0'));
    expect(result.errors.single, contains(releaseVersion));
  });
}
