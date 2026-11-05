/// Host-side expectation matcher: judges a command envelope against a
/// device-script step's `expect` block.
///
/// Ported (2026-11-05) from the example app's
/// `lib/auto/script_values.dart` + `lib/auto/step_expectation.dart` so the
/// interpreter package stays standalone. The two copies must stay in sync
/// semantically; this one is the authoritative judge for HTTP-driven runs,
/// the example one keeps serving the API_SCRIPT direct-run path and the
/// agent's compat channel (expect carried in a command).
///
/// Semantics (identical to AutoMode):
/// - absent/empty expect => assert `success == true`;
/// - `success` asserts the envelope success flag;
/// - `errorCode` asserts a failed call with that SDK error code;
/// - `checks` assert fields of `data` via path addressing and five
///   operators: equals | gte | notEmpty | containsItem | length;
/// - non-sdk failureKind or error.code <= 0 never passes (tool/timeout
///   faults are not SDK verdicts).
library;

class ExpectOutcome {
  const ExpectOutcome({required this.matched, this.checks = const []});

  final bool matched;

  /// Per-check details when the expect block carried `checks`
  /// ({expected, actual, passed, error?}).
  final List<Map<String, Object?>> checks;
}

// ---------------------------------------------------------------------------
// path addressing / equality (script_values.dart)
// ---------------------------------------------------------------------------

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

bool _matchesFields(Object? value, Map fields) =>
    fields.entries.every((entry) {
      try {
        return jsonEquals(valueAt(value, entry.key as String), entry.value);
      } on FormatException {
        return false;
      }
    });

// ---------------------------------------------------------------------------
// static validation (parse-time typo guards)
// ---------------------------------------------------------------------------

const _expectFields = {'success', 'errorCode', 'checks'};
const _checkOperators = {'equals', 'gte', 'notEmpty', 'containsItem', 'length'};

/// Validate an expect block; throws [FormatException] on unknown fields or
/// malformed checks. Called by the parser on every step of a loaded script.
void validateExpect(Object? raw, {required String where}) {
  if (raw == null) return;
  if (raw is! Map || raw.isEmpty) {
    throw FormatException('$where: expect must be a non-empty mapping');
  }
  final unknown =
      raw.keys.where((k) => !_expectFields.contains(k as String? ?? '')).toList();
  if (unknown.isNotEmpty) {
    throw FormatException('$where: unknown expect field(s): $unknown');
  }
  final checks = raw['checks'];
  if (checks == null) return;
  if (checks is! List || checks.isEmpty) {
    throw FormatException('$where: checks must be a nonempty list');
  }
  for (final check in checks) {
    if (check is! Map || check['path'] is! String || check.length != 2) {
      throw FormatException('$where: each check needs path and one operator');
    }
    final keys = check.keys.where((key) => key != 'path').toList();
    if (keys.length != 1 || !_checkOperators.contains(keys.single)) {
      throw FormatException('$where: unknown check operator in $check');
    }
    final op = keys.single;
    final operand = check[op];
    if ((op == 'notEmpty' && operand != true) ||
        (op == 'containsItem' && (operand is! Map || operand.isEmpty)) ||
        (op == 'length' && (operand is! int || operand < 0)) ||
        (op == 'gte' && operand is! num)) {
      throw FormatException('$where: invalid $op operand in $check');
    }
  }
}

// ---------------------------------------------------------------------------
// evaluation (step_expectation.dart)
// ---------------------------------------------------------------------------

List<Map<String, Object?>> evaluateChecks(Object? data, List checks) {
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
            actual.any((item) => _matchesFields(item, check['containsItem'] as Map));
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

/// Judge `result` (an envelope map: success/data/error/failureKind) against
/// `rawExpectation` (a device-script step's expect block, or null).
ExpectOutcome evaluateExpect(Map<String, Object?> result, Object? rawExpectation) {
  if (rawExpectation is! Map || rawExpectation.isEmpty) {
    return ExpectOutcome(matched: result['success'] == true);
  }
  final expectation = Map<String, dynamic>.from(rawExpectation);

  if (result['failureKind'] != null && result['failureKind'] != 'sdk') {
    return const ExpectOutcome(matched: false);
  }
  final rawError = result['error'];
  if (result['success'] == false &&
      rawError is Map &&
      rawError['code'] is num &&
      (rawError['code'] as num) <= 0) {
    return const ExpectOutcome(matched: false);
  }
  if (expectation.containsKey('success') &&
      result['success'] != expectation['success']) {
    return const ExpectOutcome(matched: false);
  }
  if (expectation.containsKey('errorCode')) {
    final error = result['error'];
    if (!(result['success'] == false &&
        error is Map &&
        error['code'] == expectation['errorCode'])) {
      return const ExpectOutcome(matched: false);
    }
  } else if (!expectation.containsKey('success') && result['success'] != true) {
    return const ExpectOutcome(matched: false);
  }
  if (expectation.containsKey('checks')) {
    final details = evaluateChecks(result['data'], expectation['checks'] as List);
    return ExpectOutcome(
      matched: details.every((check) => check['passed'] == true),
      checks: details,
    );
  }
  return const ExpectOutcome(matched: true);
}
