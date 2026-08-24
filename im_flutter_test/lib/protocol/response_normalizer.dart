class ResponseNormalizer {
  const ResponseNormalizer._();

  static Map<String, dynamic> success(
    Map<String, dynamic> request,
    dynamic nativeResult,
  ) {
    final response = Map<String, dynamic>.from(request)..remove('info');
    if (request['type'] == 'request') {
      response['type'] = 'response';
      response['protocolVersion'] = request['protocolVersion'] ?? 1;
      response['requestId'] = request['requestId'] ?? request['id'];
      response['success'] = true;
    }
    if (nativeResult is Map) {
      final resultMap = Map<String, dynamic>.from(nativeResult);
      if (resultMap.containsKey('error')) {
        // 保留现有用例兼容格式：SDK 业务错误位于 result。
        response['result'] = _jsonSafe(resultMap['error']);
      } else if (resultMap.containsKey(request['cmd'])) {
        response['result'] = _jsonSafe(resultMap[request['cmd']]);
      } else {
        response['result'] = _jsonSafe(resultMap);
      }
    } else {
      response['result'] = _jsonSafe(nativeResult);
    }
    return response;
  }

  static Map<String, dynamic> frameworkError(
    Map<String, dynamic>? request,
    String description, {
    int code = -1,
    String kind = 'FrameworkError',
  }) {
    final response = <String, dynamic>{
      if (request?['id'] != null) 'id': request!['id'],
      if (request?['sequence'] != null) 'sequence': request!['sequence'],
      if (request?['manager'] != null) 'manager': request!['manager'],
      if (request?['cmd'] != null) 'cmd': request!['cmd'],
      if (request?['device'] != null) 'device': request!['device'],
      if (request?['runId'] != null) 'runId': request!['runId'],
      if (request?['caseId'] != null) 'caseId': request!['caseId'],
      if (request?['requestId'] != null) 'requestId': request!['requestId'],
      if (request?['type'] == 'request') 'type': 'response',
      if (request?['protocolVersion'] != null)
        'protocolVersion': request!['protocolVersion'],
      'success': false,
      'error': {
        'code': code,
        'description': description,
        'kind': kind,
      },
    };
    return response;
  }

  static dynamic jsonSafe(dynamic value) {
    return _jsonSafe(value);
  }

  static dynamic _jsonSafe(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), _jsonSafe(item)),
      );
    }
    if (value is Iterable) {
      return value.map(_jsonSafe).toList();
    }
    return value.toString();
  }
}
