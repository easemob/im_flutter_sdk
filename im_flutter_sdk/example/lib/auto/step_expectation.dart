import 'script_values.dart';

bool stepResultMatchesExpectation(
  Map<String, dynamic> result,
  Object? rawExpectation,
) {
  if (rawExpectation is! Map) return result['success'] == true;
  final expectation = Map<String, dynamic>.from(rawExpectation);
  if (expectation.isEmpty) return result['success'] == true;
  if (expectation.keys
      .any((key) => !const {'success', 'errorCode', 'checks'}.contains(key))) {
    throw const FormatException('Unknown expectation field');
  }
  if (result['failureKind'] != null && result['failureKind'] != 'sdk') {
    return false;
  }
  final rawError = result['error'];
  if (result['success'] == false &&
      rawError is Map &&
      rawError['code'] is num &&
      (rawError['code'] as num) <= 0) {
    return false;
  }
  if (expectation.containsKey('success') &&
      result['success'] != expectation['success']) {
    return false;
  }
  if (expectation.containsKey('errorCode')) {
    final error = result['error'];
    if (!(result['success'] == false &&
        error is Map &&
        error['code'] == expectation['errorCode'])) {
      return false;
    }
  } else if (!expectation.containsKey('success') && result['success'] != true) {
    return false;
  }
  if (expectation.containsKey('checks')) {
    return evaluateChecks(result['data'], expectation['checks'] as List)
        .every((check) => check['passed'] == true);
  }
  return true;
}
