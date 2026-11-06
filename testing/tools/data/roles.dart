import 'dart:io';
import 'dart:math';

import 'environment.dart';

/// The data layer owns account selection and business values, never devices.
List<Map<String, dynamic>> buildRoleData(
  Map<String, dynamic> environment,
  List<String> roles,
  Map<String, dynamic> declaration,
) {
  if (roles.isEmpty || roles.toSet().length != roles.length) {
    throw const FormatException('Expected nonempty, unique roles');
  }
  for (final role in roles) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,31}$').hasMatch(role)) {
      throw FormatException('Invalid role: $role');
    }
  }
  if (declaration.keys
      .any((k) => !['accounts', 'unique', 'distinctAccounts'].contains(k))) {
    throw const FormatException(
        'Data declaration supports accounts, unique and distinctAccounts');
  }
  final selection =
      Map<String, dynamic>.from(declaration['accounts'] as Map? ?? {});
  if (selection.isNotEmpty &&
      (selection.length != roles.length ||
          roles.any((r) => !selection.containsKey(r)))) {
    throw const FormatException(
        'accounts must map every flow role exactly once');
  }
  final accounts = environment['accounts'] as List;
  final init = Map<String, dynamic>.from(environment)
    ..removeWhere(
        (key, _) => ['accounts', 'groups', 'rooms', 'resources'].contains(key));
  final shared = <String, dynamic>{};
  final random = Random.secure();
  final unique = Map<String, dynamic>.from(declaration['unique'] as Map? ?? {});
  for (final entry in unique.entries) {
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(entry.key) ||
        ['userId', 'userToken', 'initConfig', 'groups', 'rooms', 'resources']
            .contains(entry.key) ||
        entry.value is! String) {
      throw FormatException('Invalid unique field: ${entry.key}');
    }
    shared[entry.key] =
        '${entry.value}${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
  }
  final result = [
    for (var index = 0; index < roles.length; index++)
      _role(roles[index], selection[roles[index]] ?? index, accounts, init,
          environment, shared),
  ];
  if (declaration['distinctAccounts'] == true &&
      result.map((r) => (r['env'] as Map)['userId']).toSet().length !=
          roles.length) {
    throw const FormatException('This case requires distinct accounts');
  }
  if (declaration.containsKey('distinctAccounts') &&
      declaration['distinctAccounts'] is! bool) {
    throw const FormatException('distinctAccounts must be a boolean');
  }
  return result;
}

/// Domain layout belongs to testing, not to the generic interpreter.
Map<String, Object?> globalDataFromRoles(List<Map<String, dynamic>> roles) {
  final first = roles.first['env'] as Map;
  return {
    'account': {
      for (final role in roles)
        role['role'] as String: {
          'userId': (role['env'] as Map)['userId'],
          'userToken': (role['env'] as Map)['userToken'],
        },
    },
    'biz': {
      'config': {'initConfig': first['initConfig']},
      'input': {
        for (final entry in first.entries)
          if (!['userId', 'userToken', 'initConfig'].contains(entry.key))
            entry.key as String: entry.value,
      },
      'result': <String, Object?>{},
      'event': <String, Object?>{},
    },
  };
}

Map<String, dynamic> _role(String role, Object selected, List accounts,
    Map init, Map environment, Map shared) {
  if (selected is! int || selected < 0 || selected >= accounts.length) {
    throw FormatException('Account index out of range for $role');
  }
  final account = accounts[selected] as Map;
  if (account['id'] is! String ||
      (account['id'] as String).isEmpty ||
      account['token'] is! String ||
      (account['token'] as String).isEmpty) {
    throw FormatException('Missing account ID/token for $role');
  }
  return {
    'role': role,
    'env': {
      'userId': account['id'],
      'userToken': account['token'],
      'initConfig': Map<String, dynamic>.from(init),
      for (final key in ['groups', 'rooms', 'resources'])
        if (environment.containsKey(key)) key: environment[key],
      ...shared,
    },
  };
}

Future<void> main(List<String> args) async {
  try {
    if (args.length < 2 || args.length > 3) {
      throw const FormatException(
          'roles.dart <run-id> <roles-csv> [data.json]');
    }
    final root = File.fromUri(Platform.script).parent.parent.parent.parent;
    final id = checkedId(args[0]);
    final file = File('${root.path}/testing/tmp/$id/role-data.json');
    if (await file.exists())
      throw StateError('Role data already prepared: $id');
    final environment = await readObject(
        File('${root.path}/testing/tmp/$id/main/environment.json'));
    final declaration = args.length == 3
        ? await readObject(File(args[2]))
        : <String, dynamic>{};
    final roles = buildRoleData(environment, args[1].split(','), declaration);
    await writePrivateJson(file, roles);
    await writePrivateJson(
        File('${file.parent.path}/data.json'), globalDataFromRoles(roles));
    stdout.writeln('OK role-data=${file.path}');
  } catch (error) {
    stderr.writeln('roles: $error');
    exitCode = 65;
  }
}
