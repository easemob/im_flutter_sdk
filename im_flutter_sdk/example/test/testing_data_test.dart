import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../testing/tools/data/environment.dart';
import '../../../testing/tools/data/resources.dart';

void main() {
  test('imports existing credentials once without overwriting either file',
      () async {
    final root = await Directory.systemTemp.createTemp('testing-paths-');
    try {
      final paths = testingEnvPaths(root);
      final legacy = File('${paths.exampleDir.path}/config.local.json');
      await legacy.parent.create(recursive: true);
      await legacy.writeAsString('{"appKey":"existing"}');
      await paths.envTemplate.parent.create(recursive: true);
      await paths.envTemplate.writeAsString('placeholder');
      await paths.activeEnv.parent.create(recursive: true);
      await paths.activeEnv.writeAsString('manual environment');
      await ensureTestingEnvironment(root);
      expect((await readObject(paths.localConfig))['appKey'], 'existing');
      expect(await paths.activeEnv.readAsString(), 'manual environment');
      await paths.localConfig.writeAsString('{"appKey":"new"}');
      await ensureTestingEnvironment(root);
      expect((await readObject(paths.localConfig))['appKey'], 'new');
      expect(jsonDecode(await legacy.readAsString())['appKey'], 'existing');
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('cleanup rejects borrowed resources, other runs and uncertain creates',
      () {
    final owned = <String, dynamic>{
      'runId': 'run-1',
      'kind': 'group',
      'owned': true,
      'id': 'g1',
    };
    expect(ownsGroup(owned, 'run-1'), isTrue);
    expect(ownsGroup(owned, 'run-2'), isFalse);
    expect(ownsGroup({...owned, 'owned': false}, 'run-1'), isFalse);
    expect(ownsGroup({...owned, 'id': null}, 'run-1'), isFalse);
    expect(() => checkedId('../outside'), throwsFormatException);
  });
}
