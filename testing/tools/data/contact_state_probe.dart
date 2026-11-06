// Temporary probe: server-side contact state between two accounts.
import 'dart:convert';
import 'dart:io';

import '../../../im_flutter_sdk/example/tool/rest_resource_client.dart';

Future<void> main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent.parent.parent;
  final config = Map<String, dynamic>.from(
      jsonDecode(await File('${root.path}/testing/config/environment.local.json')
          .readAsString()) as Map);
  final client = await RestResourceClient.fromConfig(config);
  try {
    final a = args[0];
    final b = args[1];
    final aFriends = await client.fetchContactIds(a);
    final bFriends = await client.fetchContactIds(b);
    print('server-side $a contacts: $aFriends');
    print('server-side $b contacts: $bFriends');
  } finally {
    client.close();
  }
}
