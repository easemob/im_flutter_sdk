import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/ci/contract_checker.dart';

void main() {
  group('MethodChannel contract checker', () {
    late Directory fixture;

    setUp(() {
      fixture = Directory.systemTemp.createTempSync('flutter-contracts-');
      _writeFixture(fixture);
    });

    tearDown(() {
      fixture.deleteSync(recursive: true);
    });

    test('accepts matching constants and registered routes', () {
      expect(checkContracts(fixture.path), isEmpty);
    });

    test('reports a platform value mismatch with all three values', () {
      File('${fixture.path}/android/MethodKey.java').writeAsStringSync('''
public final class MethodKey {
  public static final String login = "loginV2";
  public static final String logout = "logout";
}
''');

      expect(
        checkContracts(fixture.path),
        contains(
          'Method key mismatch: login '
          'dart=login android=loginV2 ios=login',
        ),
      );
    });

    test('reports a method missing from an Android route', () {
      File('${fixture.path}/android/ClientWrapper.java').writeAsStringSync('''
switch (call.method) {
  case MethodKey.login:
    login(call);
    break;
}
''');

      expect(
        checkContracts(fixture.path),
        contains('Android route missing: logout'),
      );
    });

    test('reports a method missing from an iOS route', () {
      File('${fixture.path}/ios/ClientWrapper.m').writeAsStringSync('''
if ([call.method isEqualToString:EMMethodKeyLogin]) {
  [self login:call];
}
''');

      expect(
        checkContracts(fixture.path),
        contains('iOS route missing: logout'),
      );
    });

    test('matches platform constant names by their wire value', () {
      File('${fixture.path}/dart/chat_method_keys.dart').writeAsStringSync(
        "  static const String fetchSupportLanguages = "
        "'fetchSupportLanguages';\n",
        mode: FileMode.append,
      );
      File('${fixture.path}/dart/client.dart').writeAsStringSync(
        'channel.callNativeMethod(ChatMethodKeys.fetchSupportLanguages);\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/android/MethodKey.java').writeAsStringSync(
        'static final String fetchSupportedLanguages = '
        '"fetchSupportLanguages";\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/android/ClientWrapper.java').writeAsStringSync(
        'case MethodKey.fetchSupportedLanguages: break;\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/ios/MethodKeys.h').writeAsStringSync(
        'static NSString *const ChatFetchSupportedLanguages = '
        '@"fetchSupportLanguages";\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/ios/ClientWrapper.m').writeAsStringSync(
        'if ([ChatFetchSupportedLanguages isEqualToString:call.method]) {}\n',
        mode: FileMode.append,
      );

      expect(checkContracts(fixture.path), isEmpty);
    });

    test('allows APNs and HMS routes only on their supported platform', () {
      File('${fixture.path}/dart/chat_method_keys.dart').writeAsStringSync('''
  static const String updateAPNsPushToken = 'updateAPNsPushToken';
  static const String updateHMSPushToken = 'updateHMSPushToken';
''', mode: FileMode.append);
      File('${fixture.path}/dart/client.dart').writeAsStringSync('''
channel.callNativeMethod(ChatMethodKeys.updateAPNsPushToken);
channel.callNativeMethod(ChatMethodKeys.updateHMSPushToken);
''', mode: FileMode.append);
      File('${fixture.path}/android/MethodKey.java').writeAsStringSync(
        'static final String updateHMSPushToken = "updateHMSPushToken";\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/android/ClientWrapper.java').writeAsStringSync(
        'case MethodKey.updateHMSPushToken: break;\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/ios/MethodKeys.h').writeAsStringSync(
        'static NSString *const ChatBindDeviceToken = '
        '@"updateAPNsPushToken";\n',
        mode: FileMode.append,
      );
      File('${fixture.path}/ios/ClientWrapper.m').writeAsStringSync(
        'if ([ChatBindDeviceToken isEqualToString:call.method]) {}\n',
        mode: FileMode.append,
      );

      expect(checkContracts(fixture.path), isEmpty);
    });
  });
}

void _writeFixture(Directory fixture) {
  Directory('${fixture.path}/dart').createSync(recursive: true);
  Directory('${fixture.path}/android').createSync(recursive: true);
  Directory('${fixture.path}/ios').createSync(recursive: true);

  File('${fixture.path}/dart/chat_method_keys.dart').writeAsStringSync('''
abstract final class ChatMethodKeys {
  static const String login = 'login';
  static const String logout = 'logout';
}
''');
  File('${fixture.path}/dart/client.dart').writeAsStringSync('''
Future<void> login() => channel.callNativeMethod(ChatMethodKeys.login);
Future<void> logout() => channel.callNativeMethod(ChatMethodKeys.logout);
''');
  File('${fixture.path}/android/MethodKey.java').writeAsStringSync('''
public final class MethodKey {
  public static final String login = "login";
  public static final String logout = "logout";
}
''');
  File('${fixture.path}/android/ClientWrapper.java').writeAsStringSync('''
switch (call.method) {
  case MethodKey.login:
    login(call);
    break;
  case MethodKey.logout:
    logout(call);
    break;
}
''');
  File('${fixture.path}/ios/MethodKeys.h').writeAsStringSync('''
static NSString *const EMMethodKeyLogin = @"login";
static NSString *const EMMethodKeyLogout = @"logout";
''');
  File('${fixture.path}/ios/ClientWrapper.m').writeAsStringSync('''
if ([call.method isEqualToString:EMMethodKeyLogin]) {
  [self login:call];
} else if ([call.method isEqualToString:EMMethodKeyLogout]) {
  [self logout:call];
}
''');
}
