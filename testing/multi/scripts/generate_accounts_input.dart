import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';

/// Imports example configuration without fetching tokens or changing its source.
Map<String, Object?> accountsInputFromExample(Map<String, Object?> source) {
  final rawOptions = source['chatOptions'];
  if (rawOptions != null && rawOptions is! Map<String, Object?>) {
    throw const FormatException('chatOptions must be an object.');
  }
  final rawAccounts = source['accounts'];
  if (rawAccounts is! List || rawAccounts.isEmpty) {
    throw const FormatException('accounts must be a nonempty list.');
  }
  final accounts = <Map<String, Object?>>[];
  for (var i = 0; i < rawAccounts.length; i++) {
    final account = rawAccounts[i];
    if (account is! Map || account['id'] is! String) {
      throw FormatException('accounts[$i].id must be a string.');
    }
    accounts.add({'id': account['id']});
  }
  final result = <String, Object?>{
    ...?rawOptions as Map<String, Object?>?,
    'appKey': source['appKey'],
    'accounts': accounts,
    'groups': source['groups'] ?? <Object?>[],
    'rooms': source['rooms'] ?? <Object?>[],
  };
  if (source.containsKey('enablePrivateConfig') &&
      source['enablePrivateConfig'] is! bool) {
    throw const FormatException('enablePrivateConfig must be a boolean.');
  }
  if (source['enablePrivateConfig'] == true) {
    result.addAll({
      'enableDNSConfig': false,
      'restServer': source['restServer'],
      'imServer': source['imServer'] ?? source['msyncServer'],
      'webSocketServer': source['webSocketServer'],
    });
    for (final key in ['restServer', 'imServer', 'webSocketServer']) {
      _requiredString(result[key], key);
    }
    for (final key in ['imPort', 'webSocketPort']) {
      if (source.containsKey(key)) result[key] = source[key];
    }
  }
  DataService().validateEnvironment({
    ...result,
    'accounts': [
      for (final account in accounts) {...account, 'token': 'validation-only'},
    ],
  });
  for (final key in ['restApi', 'clientId', 'clientSecret']) {
    _requiredString(source[key], key);
    result[key] = source[key];
  }
  final uri = Uri.tryParse(result['restApi'] as String);
  if (uri == null ||
      !['https', 'http'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const FormatException('restApi must be an HTTP(S) base URL.');
  }
  return result;
}

void _requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty || value.startsWith('TODO')) {
    throw FormatException('$field must contain a configured value.');
  }
}

Future<bool> generateAccountsInput({
  required File source,
  required File output,
  bool overwrite = false,
}) async {
  if (p.equals(p.absolute(source.path), p.absolute(output.path))) {
    throw const FormatException('Source and output must be different files.');
  }
  if (await output.exists() && !overwrite) return false;
  final Map<String, Object?> input;
  if (await source.exists()) {
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Example configuration must be an object.');
    }
    input = accountsInputFromExample(decoded);
  } else {
    input = {
      'appKey': 'TODO-org#TODO-app',
      'restApi': 'https://TODO-rest-host',
      'clientId': 'TODO-client-id',
      'clientSecret': 'TODO-client-secret',
      'accounts': <Object?>[],
      'groups': <Object?>[],
      'rooms': <Object?>[],
    };
  }
  await writePrivateJson(output.path, input);
  return true;
}

Future<void> main(List<String> arguments) async {
  final root = File.fromUri(Platform.script).parent.parent;
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('source',
        defaultsTo: p.join(root.parent.parent.path, 'im_flutter_sdk', 'example',
            'config.local.json'),
        help:
            'Example configuration to import; missing source creates a template.')
    ..addFlag('force',
        negatable: false,
        help: 'Explicitly replace the existing generated input.');
  try {
    final args = parser.parse(arguments);
    if (args['help'] == true) {
      stdout.writeln(
          'Usage: dart run scripts/generate_accounts_input.dart [options]\n'
          'Writes config/accounts-input.json; existing files are kept by default.\n'
          '${parser.usage}');
      return;
    }
    if (args.rest.isNotEmpty) {
      throw const FormatException('Unexpected positional arguments.');
    }
    final source = File(args['source'] as String);
    final output = File(p.join(root.path, 'config', 'accounts-input.json'));
    final template = !await source.exists();
    final written = await generateAccountsInput(
        source: source, output: output, overwrite: args['force'] as bool);
    stdout.writeln('${written ? 'Generated' : 'Kept'} ${output.path}');
    if (written && template) {
      stdout.writeln(
          'Template only: fill application credentials and existing account IDs before generating tokens.');
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on DataValidationException catch (error) {
    stderr.writeln(error.error.message);
    exitCode = 1;
  } catch (error) {
    stderr.writeln('Configuration generation failed (${error.runtimeType}).');
    exitCode = 1;
  }
}
