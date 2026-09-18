bool stepResultMatchesExpectation(
  Map<String, dynamic> result,
  Object? rawExpectation,
) {
  if (rawExpectation is! Map) return result['success'] == true;
  final expectation = Map<String, dynamic>.from(rawExpectation);
  if (expectation.isEmpty) return result['success'] == true;
  if (expectation.containsKey('success') &&
      result['success'] != expectation['success']) {
    return false;
  }
  if (expectation.containsKey('errorCode')) {
    final error = result['error'];
    return result['success'] == false &&
        error is Map &&
        error['code'] == expectation['errorCode'];
  }
  return true;
}
