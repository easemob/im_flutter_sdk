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

  void writeValidFixture() {
    for (final package in <String>[
      'im_flutter_sdk',
      'im_flutter_sdk_android',
      'im_flutter_sdk_ios',
      'im_flutter_sdk_interface',
    ]) {
      write('$package/pubspec.yaml', 'name: $package\nversion: 4.19.2\n');
    }
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.19.2'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.19.1"),\n'
          '  .package(name: "FlutterFramework", path: "../FlutterFramework")\n'
          ']\n',
    );
    write(
      'im_flutter_sdk_android/android/build.gradle',
      "implementation 'io.hyphenate:hyphenate-chat:4.19.3.1'\n",
    );
  }

  test('accepts aligned federated and podspec versions', () {
    writeValidFixture();

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.flutterVersion, '4.19.2');
    expect(result.androidNativeVersion, '4.19.3.1');
    expect(result.iosNativeVersion, '4.19.1');
  });

  test('accepts an Android native version independent of the Flutter version',
      () {
    writeValidFixture();
    write(
      'im_flutter_sdk_android/android/build.gradle',
      "implementation 'io.hyphenate:hyphenate-chat:4.25.1'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.androidNativeVersion, '4.25.1');
  });

  test('ignores the patch digit of both iOS integration paths', () {
    writeValidFixture();
    // The four packages stay at 4.19.2 while both iOS paths moved to 4.19.4.
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.19.2'\ns.dependency 'HyphenateChat','4.19.4'\n",
    );
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.19.4"),\n'
          ']\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
    expect(result.iosNativeVersion, '4.19.4');
  });

  test(
      'accepts a podspec version on the same major.minor line with another patch',
      () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.19.7'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, isEmpty);
  });

  test('reports the two iOS integration paths drifting aside', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift',
      'dependencies: [\n'
          '  .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", exact: "4.18.1"),\n'
          ']\n',
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('iOS native dependency mismatch'));
    expect(result.errors.single, contains('major.minor'));
    expect(result.errors.single, contains('4.19.1'));
    expect(result.errors.single, contains('4.18.1'));
  });

  test('reports a podspec version on another major.minor line', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.18.9'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('major.minor'));
    expect(result.errors.single, contains('4.18.9'));
  });

  test('reports every package and podspec mismatch', () {
    writeValidFixture();
    write(
      'im_flutter_sdk_android/pubspec.yaml',
      'name: im_flutter_sdk_android\nversion: 4.19.3\n',
    );
    write(
      'im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec',
      "s.version = '4.18.2'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(2));
    expect(result.errors.join('\n'), contains('im_flutter_sdk_android'));
    expect(result.errors.join('\n'), contains('podspec'));
  });
}
