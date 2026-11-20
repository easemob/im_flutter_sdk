Set<String> stepReferenceIds(Object? value) {
  final result = <String>{};

  void visit(Object? current) {
    if (current is String && current.startsWith(r'$step.')) {
      final path = current.substring(6).split('.');
      if (path.first.isNotEmpty) result.add(path.first);
      return;
    }
    if (current is Map) {
      for (final item in current.values) {
        visit(item);
      }
      return;
    }
    if (current is Iterable) {
      for (final item in current) {
        visit(item);
      }
    }
  }

  visit(value);
  return result;
}

String? failedStepDependency(
  Object? params,
  Map<String, bool> stepSucceeded,
) {
  for (final id in stepReferenceIds(params)) {
    if (stepSucceeded[id] == false) return id;
  }
  return null;
}

Map<String, dynamic> skippedStepResult(String dependencyId) => {
      'success': false,
      'skipped': true,
      'blockedBy': dependencyId,
      'error': {
        'code': -3,
        'message': 'Skipped because step "$dependencyId" did not succeed',
      },
    };
