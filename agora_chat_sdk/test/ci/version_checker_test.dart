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
      'agora_chat_sdk',
      'agora_chat_sdk_android',
      'agora_chat_sdk_ios',
      'agora_chat_sdk_interface',
    ]) {
      write('$package/pubspec.yaml', 'name: $package\nversion: 4.19.2\n');
    }
    write(
      'agora_chat_sdk_ios/ios/agora_chat_sdk_ios.podspec',
      "s.version = '4.19.2'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );
    write(
      'agora_chat_sdk_android/android/build.gradle',
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

  test('reports every package and podspec mismatch', () {
    writeValidFixture();
    write(
      'agora_chat_sdk_android/pubspec.yaml',
      'name: agora_chat_sdk_android\nversion: 4.19.3\n',
    );
    write(
      'agora_chat_sdk_ios/ios/agora_chat_sdk_ios.podspec',
      "s.version = '4.15.2'\ns.dependency 'HyphenateChat','4.19.1'\n",
    );

    final result = checkVersions(fixture.path);

    expect(result.errors, hasLength(2));
    expect(result.errors.join('\n'), contains('agora_chat_sdk_android'));
    expect(result.errors.join('\n'), contains('podspec'));
  });
}
