import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../scripts/generate_accounts_input.dart';

Map<String, Object?> exampleConfig() => {
      'appKey': 'org#app',
      'restApi': 'https://rest.example.invalid',
      'clientId': 'client-id',
      'clientSecret': 'client-secret',
      'accounts': [
        for (var i = 0; i < 4; i++) {'id': 'user-$i'}
      ],
      'chatOptions': {'debugMode': true, 'dataSyncType': 7},
      'enablePrivateConfig': false,
      'restServer': 'TODO',
      'msyncServer': 'TODO',
      'webSocketServer': 'TODO',
      'tokenTtl': 86400,
    };

void main() {
  test('imports all accounts and flattens SDK options without source mutation',
      () {
    final source = exampleConfig();
    final before = jsonEncode(source);
    final result = accountsInputFromExample(source);
    expect(result['accounts'], hasLength(4));
    expect(result['debugMode'], isTrue);
    expect(result['dataSyncType'], 7);
    expect(result['clientSecret'], 'client-secret');
    expect(result['groups'], isEmpty);
    expect(result, isNot(contains('tokenTtl')));
    expect(result, isNot(contains('restServer')));
    expect(result, isNot(contains('chatOptions')));
    expect(jsonEncode(source), before);
  });

  test('imports private server aliases and ports', () {
    final result = accountsInputFromExample({
      ...exampleConfig(),
      'enablePrivateConfig': true,
      'restServer': 'https://private.example.invalid',
      'msyncServer': 'im.example.invalid',
      'webSocketServer': 'ws.example.invalid',
      'imPort': 6717,
      'webSocketPort': 443,
    });
    expect(result['enableDNSConfig'], isFalse);
    expect(result['imServer'], 'im.example.invalid');
    expect(result['imPort'], 6717);
    expect(result['webSocketPort'], 443);
    expect(result, isNot(contains('msyncServer')));
  });

  test('rejects duplicate accounts and incomplete private configuration', () {
    expect(
        () => accountsInputFromExample({
              ...exampleConfig(),
              'accounts': [
                {'id': 'same'},
                {'id': 'same'}
              ],
            }),
        throwsA(isA<Exception>()));
    expect(
        () => accountsInputFromExample({
              ...exampleConfig(),
              'enablePrivateConfig': true,
            }),
        throwsFormatException);
  });

  late Directory temporary;
  late File source;
  late File output;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('accounts-input-test-');
    source = File('${temporary.path}/example.json');
    output = File('${temporary.path}/config/accounts-input.json');
  });
  tearDown(() async => temporary.delete(recursive: true));

  test('missing source creates a template without fixing the account count',
      () async {
    expect(await generateAccountsInput(source: source, output: output), isTrue);
    final result = jsonDecode(await output.readAsString()) as Map;
    expect(result['accounts'], isEmpty);
    expect(result.keys,
        containsAll(['appKey', 'restApi', 'clientId', 'clientSecret']));
    expect(result, isNot(contains('token')));
  });

  test('preserves manual edits by default and replaces only with force',
      () async {
    await source.writeAsString(jsonEncode(exampleConfig()));
    await generateAccountsInput(source: source, output: output);
    const manual = '{"manual": true}\n';
    await output.writeAsString(manual);
    expect(
        await generateAccountsInput(source: source, output: output), isFalse);
    expect(await output.readAsString(), manual);
    expect(
        await generateAccountsInput(
            source: source, output: output, overwrite: true),
        isTrue);
    expect(jsonDecode(await output.readAsString())['accounts'], hasLength(4));
  });

  test('invalid source cannot replace a previous usable file', () async {
    await source.writeAsString(jsonEncode(exampleConfig()));
    await generateAccountsInput(source: source, output: output);
    final before = await output.readAsString();
    await source.writeAsString('{"clientSecret": "do-not-print-me",');
    await expectLater(
      generateAccountsInput(source: source, output: output, overwrite: true),
      throwsFormatException,
    );
    expect(await output.readAsString(), before);
  });
}
