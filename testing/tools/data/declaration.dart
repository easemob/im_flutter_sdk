import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/parser.dart';

import 'environment.dart';

Map<String, dynamic> _object(Object? value, String source) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Data declaration must be an object: $source');
  }
  return value;
}

/// Select one preparation declaration; never merge independent sources.
/// An explicit legacy --data file overrides discovery, as before.
Map<String, dynamic> loadDataDeclaration({File? flow, File? explicitData}) {
  if (explicitData != null) {
    return _object(
        jsonDecode(explicitData.readAsStringSync()), explicitData.path);
  }
  if (flow == null) return {};

  final spec = parseFlow(flow.readAsStringSync(), sourcePath: flow.path);
  final visited = <String>{};
  final declarations = <String, Map<String, dynamic>>{};
  for (final agent in spec.agents.values) {
    final script = File(agent.scriptPath);
    // Different roles (or path spellings) can share the same command library.
    if (!visited.add(script.resolveSymbolicLinksSync())) continue;
    final root = _object(jsonDecode(script.readAsStringSync()), script.path);
    if (root.containsKey('data')) {
      declarations['${script.path}#data'] =
          _object(root['data'], '${script.path}#data');
    }
  }

  // Preserve the previous adjacent-file format for unmigrated flows.
  final legacy =
      File(flow.path.replaceFirst(RegExp(r'\.[^./]+$'), '') + '.data.json');
  if (legacy.existsSync()) {
    declarations[legacy.path] =
        _object(jsonDecode(legacy.readAsStringSync()), legacy.path);
  }
  if (declarations.length > 1) {
    throw FormatException(
        'Multiple data declarations; keep one source or use --data explicitly: '
        '${declarations.keys.join(', ')}');
  }
  return declarations.isEmpty ? {} : declarations.values.single;
}

Future<void> main(List<String> args) async {
  try {
    if (args.isEmpty || args.length.isEven) {
      throw const FormatException(
          'declaration.dart <output.json> [--flow <yaml>] [--data <json>]');
    }
    final options = <String, String>{};
    for (var i = 1; i < args.length; i += 2) {
      if (!['--flow', '--data'].contains(args[i]) ||
          options.containsKey(args[i])) {
        throw FormatException('Invalid or duplicate option: ${args[i]}');
      }
      options[args[i]] = args[i + 1];
    }
    final output = File(args.first);
    if (output.existsSync()) {
      throw StateError('Data declaration already prepared; use a fresh run ID');
    }
    final declaration = loadDataDeclaration(
      flow: options['--flow'] == null ? null : File(options['--flow']!),
      explicitData: options['--data'] == null ? null : File(options['--data']!),
    );
    await writePrivateJson(output, declaration);
  } catch (error) {
    stderr.writeln('declaration: $error');
    exitCode = 65;
  }
}
