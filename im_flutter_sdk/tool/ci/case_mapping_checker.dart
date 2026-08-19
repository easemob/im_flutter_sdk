import 'dart:convert';
import 'dart:io';

List<String> checkCaseMapping(String packageRoot) {
  final errors = <String>[];
  final mappingFile = File('$packageRoot/docs/ci/native-case-mapping.json');
  if (!mappingFile.existsSync()) {
    return <String>['Missing mapping: ${mappingFile.path}'];
  }

  Object? decoded;
  try {
    decoded = jsonDecode(mappingFile.readAsStringSync());
  } on FormatException catch (error) {
    return <String>['Invalid mapping JSON: ${error.message}'];
  }
  if (decoded is! Map<String, dynamic>) {
    return <String>['Mapping root must be an object'];
  }
  if (decoded['schemaVersion'] != 1) {
    errors.add('schemaVersion must be 1');
  }
  if ((decoded['nativeBaseline'] as String?)?.isEmpty ?? true) {
    errors.add('nativeBaseline must not be empty');
  }

  final cases = decoded['cases'];
  if (cases is! List) {
    errors.add('cases must be a list');
    return errors;
  }

  final ids = <String>{};
  for (final rawCase in cases) {
    if (rawCase is! Map<String, dynamic>) {
      errors.add('Every case must be an object');
      continue;
    }
    final id = rawCase['id'] as String? ?? '<missing-id>';
    if (!RegExp(r'^FL-[A-Z]+-\d{3}$').hasMatch(id)) {
      errors.add('$id: invalid case id');
    } else if (!ids.add(id)) {
      errors.add('$id: duplicate case id');
    }

    if (!const <String>{'P0', 'P1', 'P2'}.contains(rawCase['priority'])) {
      errors.add('$id: priority must be P0, P1, or P2');
    }
    final origin = rawCase['origin'];
    if (!const <String>{'flutter-only', 'native-shared'}.contains(origin)) {
      errors.add('$id: invalid origin');
    }

    final sourceCases = _stringList(rawCase['sourceCases']);
    if (origin == 'native-shared' && sourceCases.isEmpty) {
      errors.add('$id: native-shared requires sourceCases');
    }
    if (origin == 'flutter-only' && sourceCases.isNotEmpty) {
      errors.add('$id: flutter-only sourceCases must be empty');
    }

    for (final field in <String>['flutterApis', 'platforms', 'assertions']) {
      if (_stringList(rawCase[field]).isEmpty) {
        errors.add('$id: $field must not be empty');
      }
    }

    final platforms = _stringList(rawCase['platforms']).toSet();
    if (platforms.difference(const <String>{'android', 'ios'}).isNotEmpty) {
      errors.add('$id: platforms may only contain android and ios');
    }

    final testFile = rawCase['testFile'] as String? ?? '';
    final implementation = File('$packageRoot/$testFile');
    if (!implementation.existsSync()) {
      errors.add('$id: missing test file $testFile');
    } else if (!implementation.readAsStringSync().contains(id)) {
      errors.add('$id: id not found in $testFile');
    }
  }

  return errors;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value.whereType<String>().where((item) => item.isNotEmpty).toList();
}
