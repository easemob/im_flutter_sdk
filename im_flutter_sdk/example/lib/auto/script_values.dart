// Pure JSON helpers shared by the app executor and host-side validation.
Object? valueAt(Object? value, String path) {
  if (path.isEmpty) return value;
  for (final part in path.split('.')) {
    if (value is Map && value.containsKey(part)) {
      value = value[part];
    } else if (value is List && int.tryParse(part) != null) {
      final index = int.parse(part);
      if (index < 0 || index >= value.length) {
        throw FormatException('Missing list index in $path');
      }
      value = value[index];
    } else {
      throw FormatException('Missing path: $path');
    }
  }
  return value;
}

Object? resolveValue(Object? value, Map<String, Object?> context) {
  if (value is String && value.startsWith(r'$')) {
    return valueAt(context, value.substring(1));
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key, resolveValue(item, context)));
  }
  if (value is List) {
    return value.map((item) => resolveValue(item, context)).toList();
  }
  return value;
}

bool jsonEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((key) => b.containsKey(key) && jsonEquals(a[key], b[key]));
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        List.generate(a.length, (index) => index)
            .every((index) => jsonEquals(a[index], b[index]));
  }
  return a == b;
}

bool matchesFields(Object? value, Map fields) => fields.entries.every((entry) {
      try {
        return jsonEquals(valueAt(value, entry.key as String), entry.value);
      } on FormatException {
        return false;
      }
    });

void validateChecks(Object? raw) {
  if (raw is! List || raw.isEmpty) {
    throw const FormatException('checks must be a nonempty list');
  }
  const operators = {'equals', 'gte', 'notEmpty', 'containsItem', 'length'};
  for (final check in raw) {
    if (check is! Map || check['path'] is! String || check.length != 2) {
      throw const FormatException('Each check needs path and one operator');
    }
    final keys = check.keys.where((key) => key != 'path').toList();
    if (keys.length != 1 || !operators.contains(keys.single)) {
      throw const FormatException('Unknown check operator');
    }
    final op = keys.single;
    final operand = check[op];
    if ((op == 'notEmpty' && operand != true) ||
        (op == 'containsItem' && (operand is! Map || operand.isEmpty)) ||
        (op == 'length' && (operand is! int || operand < 0)) ||
        (op == 'gte' && operand is! num)) {
      throw FormatException('Invalid $op operand');
    }
  }
}

List<Map<String, Object?>> evaluateChecks(Object? data, List checks) {
  validateChecks(checks);
  return checks.map((raw) {
    final check = Map<String, dynamic>.from(raw as Map);
    Object? actual;
    var passed = false;
    String? error;
    try {
      actual = valueAt(data, check['path'] as String);
      if (check.containsKey('equals')) {
        passed = jsonEquals(actual, check['equals']);
      } else if (check.containsKey('gte')) {
        passed = actual is num && actual >= (check['gte'] as num);
      } else if (check.containsKey('notEmpty')) {
        passed = (actual is String && actual.isNotEmpty) ||
            (actual is List && actual.isNotEmpty) ||
            (actual is Map && actual.isNotEmpty);
      } else if (check.containsKey('containsItem')) {
        passed = actual is List &&
            actual.any(
                (item) => matchesFields(item, check['containsItem'] as Map));
      } else if (check.containsKey('length')) {
        passed = actual is List && actual.length == check['length'];
      }
    } on FormatException catch (e) {
      error = e.message;
    }
    return <String, Object?>{
      'expected': check,
      'actual': actual,
      'passed': passed,
      if (error != null) 'error': error,
    };
  }).toList();
}
