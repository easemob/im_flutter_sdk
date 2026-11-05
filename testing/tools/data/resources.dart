import 'dart:io';

import '../../../im_flutter_sdk/example/tool/rest_resource_client.dart';
import 'environment.dart';

bool ownsGroup(Map<String, dynamic> record, String runId) =>
    record['runId'] == runId &&
    record['kind'] == 'group' &&
    record['owned'] == true &&
    record['id'] is String &&
    (record['id'] as String).isNotEmpty;

Future<void> prepareGroup(Directory root, String runId) async {
  checkedId(runId);
  final directory = '${root.path}/testing/tmp/$runId/main';
  final journal = File('$directory/resources.json');
  final environmentFile = File('$directory/environment.json');
  final environment = await readObject(environmentFile);
  if (await journal.exists()) {
    throw StateError('Resource preparation already attempted; inspect journal');
  }
  final accounts = environment['accounts'] as List;
  if (accounts.length < 2) {
    throw const FormatException('Two configured test accounts are required');
  }
  final record = <String, dynamic>{
    'runId': runId,
    'kind': 'group',
    'owned': true,
    'status': 'creating',
    'name': 'example-test-$runId',
    'owner': (accounts[0] as Map)['id'],
    'members': [(accounts[1] as Map)['id']],
  };
  final config = await readObject(testingEnvPaths(root).localConfig);
  record['appKey'] = config['appKey'];
  final client = await RestResourceClient.fromConfig(config);
  try {
    // Persist intent before the side effect; an uncertain create is not retried.
    await writePrivateJson(journal, record);
    final id = await client.createGroup(
      owner: record['owner'] as String,
      name: record['name'] as String,
      members: (record['members'] as List).cast<String>(),
      allowInvites: true,
    );
    record.addAll({'id': id, 'status': 'created'});
    await writePrivateJson(journal, record);
    environment['resources'] = {'groupId': id};
    await writePrivateJson(environmentFile, environment);
    stdout.writeln('Prepared run-owned group; journal: ${journal.path}');
  } catch (_) {
    // Preserve a known id even when updating the environment file failed.
    record['status'] = record['id'] == null ? 'unknown' : 'created';
    await writePrivateJson(journal, record);
    rethrow;
  } finally {
    client.close();
  }
}

Future<void> cleanupGroup(Directory root, String runId) async {
  checkedId(runId);
  final journal = File('${root.path}/testing/tmp/$runId/main/resources.json');
  final record = await readObject(journal);
  if (!ownsGroup(record, runId)) {
    throw StateError(
      'No proven run-owned group id; cleanup requires inspection',
    );
  }
  if (record['status'] == 'deleted') {
    stdout.writeln('Group was already cleaned up');
    return;
  }
  final config = await readObject(testingEnvPaths(root).localConfig);
  if (config['appKey'] != record['appKey']) {
    throw StateError('Configuration changed; restore the resource environment');
  }
  final client = await RestResourceClient.fromConfig(config);
  try {
    await client.deleteGroup(record['id'] as String);
    record['status'] = 'deleted';
    await writePrivateJson(journal, record);
    stdout.writeln('Cleaned up run-owned group');
  } catch (_) {
    record['status'] = 'cleanup-failed';
    await writePrivateJson(journal, record);
    rethrow;
  } finally {
    client.close();
  }
}

Future<void> main(List<String> args) async {
  try {
    if (args.length != 2 ||
        !['prepare-group', 'cleanup-group'].contains(args[0])) {
      throw const FormatException(
        'resources.dart prepare-group|cleanup-group run-id',
      );
    }
    final root = File.fromUri(Platform.script).parent.parent.parent.parent;
    if (args[0] == 'prepare-group') {
      await prepareGroup(root, args[1]);
    } else {
      await cleanupGroup(root, args[1]);
    }
  } catch (error) {
    stderr.writeln('resources: $error');
    exitCode = 1;
  }
}
