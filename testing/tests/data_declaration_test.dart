import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/parser.dart';
import 'package:test/test.dart';

import '../tools/data/declaration.dart';

void main() {
  late Directory fixture;
  late File flow;
  late File script;

  File write(String name, Object? json) =>
      File('${fixture.path}/$name')..writeAsStringSync(jsonEncode(json));

  setUp(() {
    final tmp = Directory('testing/tmp')..createSync(recursive: true);
    fixture = tmp.createTempSync('data-declaration-').absolute;
    script = write('commands.json', {
      'steps': [
        {'id': 'ready', 'api': 'Example.ready', 'params': {}}
      ],
    });
    flow = File('${fixture.path}/case.yaml')..writeAsStringSync('''
name: fixture
agents:
  alice: {script: commands.json}
  bob: {script: ./commands.json}
steps:
  - cmd: ready
    agent: alice
''');
  });
  tearDown(() => fixture.deleteSync(recursive: true));

  test('shared command JSON is one data source, relative to the flow', () {
    write('commands.json', {
      'data': {
        'accounts': {'alice': 1, 'bob': 0}
      },
      'steps': [
        {'id': 'ready', 'api': 'Example.ready'}
      ],
    });
    expect(loadDataDeclaration(flow: flow), {
      'accounts': {'alice': 1, 'bob': 0}
    });
  });

  test('legacy steps, init and login work with arbitrary sibling data', () {
    final legacy = jsonDecode(script.readAsStringSync()) as Map;
    legacy['init'] = {'appKey': 'fixture'};
    legacy['login'] = {'userId': 'fixture'};
    write('commands.json', legacy);
    final before = parseFlow(flow.readAsStringSync(), sourcePath: flow.path)
        .scripts['alice']!;
    expect(loadDataDeclaration(flow: flow), isEmpty);
    write('commands.json', {
      ...legacy,
      'data': <String, dynamic>{},
      'description': 'fixture',
      'fixtures': [
        1,
        true,
        null,
        {'value': 'opaque'}
      ],
    });
    final after = parseFlow(flow.readAsStringSync(), sourcePath: flow.path)
        .scripts['alice']!;
    expect(after.stepsById, before.stepsById);
    expect(after.init, before.init);
    expect(after.login, before.login);
    expect(loadDataDeclaration(flow: flow), isEmpty);
  });

  test('legacy adjacent declaration remains supported', () {
    write('case.data.json', {'distinctAccounts': true});
    expect(loadDataDeclaration(flow: flow), {'distinctAccounts': true});
  });

  test('multiple declarations fail even when their contents are equal', () {
    final root = jsonDecode(script.readAsStringSync()) as Map;
    root['data'] = {'distinctAccounts': true};
    write('commands.json', root);
    write('other.json', root);
    flow.writeAsStringSync(
        flow.readAsStringSync().replaceFirst('./commands.json', 'other.json'));
    expect(
        () => loadDataDeclaration(flow: flow),
        throwsA(isA<FormatException>().having((e) => e.message, 'message',
            contains('Multiple data declarations'))));
  });

  test('embedded and adjacent declarations cannot silently shadow each other',
      () {
    final root = jsonDecode(script.readAsStringSync()) as Map;
    root['data'] = <String, dynamic>{};
    write('commands.json', root);
    write('case.data.json', {'distinctAccounts': true});
    expect(() => loadDataDeclaration(flow: flow), throwsFormatException);
  });

  test('explicit data overrides discovery and does not merge values', () {
    final root = jsonDecode(script.readAsStringSync()) as Map;
    root['data'] = {
      'unique': {'label': 'embedded-'}
    };
    write('commands.json', root);
    write('case.data.json', {'distinctAccounts': true});
    final explicit = write('override.json', {
      'accounts': {'alice': 0, 'bob': 0}
    });
    expect(loadDataDeclaration(flow: flow, explicitData: explicit), {
      'accounts': {'alice': 0, 'bob': 0}
    });
    expect(loadDataDeclaration(explicitData: explicit),
        loadDataDeclaration(flow: flow, explicitData: explicit));
  });

  test('present data must be an object, including explicit and legacy files',
      () {
    final root = jsonDecode(script.readAsStringSync()) as Map;
    for (final value in [null, [], 'invalid', false, 1]) {
      write('commands.json', {...root, 'data': value});
      expect(() => loadDataDeclaration(flow: flow), throwsFormatException);
      write('commands.json', root);
      final legacy = write('case.data.json', value);
      expect(() => loadDataDeclaration(flow: flow), throwsFormatException);
      expect(() => loadDataDeclaration(explicitData: legacy),
          throwsFormatException);
      legacy.deleteSync();
    }
    expect(loadDataDeclaration(), isEmpty);
  });

  test('existing contact flow needs no new top-level data', () {
    expect(
        loadDataDeclaration(
            flow: File('testing/flows/contact-add-positive.yaml')),
        isEmpty);
  });
}
