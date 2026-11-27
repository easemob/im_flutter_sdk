import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/ci/case_mapping_checker.dart';

void main() {
  late Directory fixture;

  setUp(() {
    fixture = Directory.systemTemp.createTempSync('flutter-case-mapping-');
    final testFile = File('${fixture.path}/integration_test/smoke_test.dart');
    testFile.parent.createSync(recursive: true);
    testFile
        .writeAsStringSync("testWidgets('FL-APP-001 initializes', (_) {});");
  });

  tearDown(() {
    fixture.deleteSync(recursive: true);
  });

  void writeMapping(Map<String, Object> item) {
    final file = File('${fixture.path}/docs/ci/native-case-mapping.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(<String, Object>{
      'schemaVersion': 1,
      'nativeBaseline': 'easemob/im-auto-test@commit',
      'cases': <Map<String, Object>>[item],
    }));
  }

  Map<String, Object> validCase() => <String, Object>{
        'id': 'FL-APP-001',
        'priority': 'P0',
        'origin': 'flutter-only',
        'sourceCases': <String>[],
        'flutterApis': <String>['EMClient.init'],
        'platforms': <String>['android', 'ios'],
        'assertions': <String>['SDK initialization succeeds'],
        'testFile': 'integration_test/smoke_test.dart',
      };

  test('accepts a traceable case whose implementation exists', () {
    writeMapping(validCase());

    expect(checkCaseMapping(fixture.path), isEmpty);
  });

  test('requires Native sources for native-shared cases', () {
    writeMapping(<String, Object>{
      ...validCase(),
      'origin': 'native-shared',
    });

    expect(
      checkCaseMapping(fixture.path),
      contains('FL-APP-001: native-shared requires sourceCases'),
    );
  });

  test('requires every mapped id to appear in its test file', () {
    writeMapping(<String, Object>{
      ...validCase(),
      'id': 'FL-APP-002',
    });

    expect(
      checkCaseMapping(fixture.path),
      contains(
        'FL-APP-002: id not found in integration_test/smoke_test.dart',
      ),
    );
  });
}
