import 'dart:convert';
import 'dart:io';

import 'env_tool.dart';

/// Small REST client for preparing and cleaning reusable test resources.
final class RestResourceClient {
  RestResourceClient({
    required String restApi,
    required String appKey,
    required String appToken,
    HttpClient? httpClient,
  })  : _restApi = restApi.replaceFirst(RegExp(r'/+$'), ''),
        _appKey = _parseAppKey(appKey),
        _appToken = appToken,
        _httpClient = httpClient ?? HttpClient();

  static Future<RestResourceClient> fromConfig(
    Map<String, dynamic> config,
  ) async {
    final tokenClient = TokenClient();
    try {
      final appToken = await tokenClient.fetchAppToken(config);
      return RestResourceClient(
        restApi: config['restApi'] as String,
        appKey: config['appKey'] as String,
        appToken: appToken,
      );
    } finally {
      tokenClient.close();
    }
  }

  final String _restApi;
  final List<String> _appKey;
  final String _appToken;
  final HttpClient _httpClient;

  Future<String> createGroup({
    required String owner,
    required String name,
    String description = '',
    List<String> members = const [],
    int maxUsers = 200,
    bool isPublic = false,
    bool allowInvites = false,
    bool membersOnly = false,
    bool inviteNeedConfirm = false,
    String? custom,
  }) async {
    final response = await _request(
      'POST',
      'chatgroups',
      body: {
        'groupname': name,
        'description': description,
        'public': isPublic,
        'maxusers': maxUsers,
        'allowinvites': allowInvites,
        'membersonly': membersOnly,
        'invite_need_confirm': inviteNeedConfirm,
        'owner': owner,
        if (members.isNotEmpty) 'members': members,
        if (custom != null) 'custom': custom,
      },
    );
    return _requiredString(response, ['data', 'groupid']);
  }

  Future<void> deleteGroup(String groupId) async {
    await _request(
      'DELETE',
      'chatgroups/${Uri.encodeComponent(groupId)}',
      ignoreNotFound: true,
    );
  }

  Future<String> createChatRoom({
    required String owner,
    required String name,
    required String description,
    List<String> members = const [],
    int maxUsers = 1000,
    String? custom,
  }) async {
    final response = await _request(
      'POST',
      'chatrooms',
      body: {
        'name': name,
        'description': description,
        'maxusers': maxUsers,
        'owner': owner,
        if (members.isNotEmpty) 'members': members,
        if (custom != null) 'custom': custom,
      },
    );
    return _requiredString(response, ['data', 'id']);
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    await _request(
      'DELETE',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}',
      ignoreNotFound: true,
    );
  }

  Future<String> sendGroupTextMessage({
    required String from,
    required String groupId,
    required String text,
  }) async {
    final response = await _request(
      'POST',
      'messages/chatgroups',
      body: {
        'from': from,
        'to': [groupId],
        'type': 'txt',
        'body': {'msg': text},
      },
    );
    return _requiredString(response, ['data', groupId]);
  }

  Future<String> createThread({
    required String groupId,
    required String name,
    required String owner,
    required String messageId,
  }) async {
    final response = await _request(
      'POST',
      'thread',
      body: {
        'group_id': groupId,
        'name': name,
        'owner': owner,
        'msg_id': messageId,
      },
    );
    return _requiredString(response, ['data', 'thread_id']);
  }

  Future<void> addThreadMembers(
    String threadId,
    List<String> userIds,
  ) async {
    if (userIds.isEmpty || userIds.length > 10) {
      throw ArgumentError.value(
        userIds,
        'userIds',
        'must contain between 1 and 10 users',
      );
    }
    await _request(
      'POST',
      'thread/${Uri.encodeComponent(threadId)}/users',
      body: {'usernames': userIds},
    );
  }

  Future<void> deleteThread(String threadId) async {
    await _request(
      'DELETE',
      'thread/${Uri.encodeComponent(threadId)}',
      ignoreNotFound: true,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool ignoreNotFound = false,
  }) async {
    final uri = Uri.parse(
      '$_restApi/${Uri.encodeComponent(_appKey[0])}/'
      '${Uri.encodeComponent(_appKey[1])}/$path',
    );
    final request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer $_appToken',
    );
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    Object? decoded;
    if (text.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(text);
      } on FormatException {
        throw HttpException(
          'HTTP ${response.statusCode}: invalid JSON response',
          uri: uri,
        );
      }
    }
    if (response.statusCode == HttpStatus.notFound && ignoreNotFound) {
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map
          ? [decoded['error'], decoded['error_description']]
              .whereType<Object>()
              .join(' ')
          : decoded.toString();
      throw HttpException(
        'HTTP ${response.statusCode}: $error',
        uri: uri,
      );
    }
    if (decoded is! Map) {
      throw FormatException('$method $path response must be a JSON object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  void close() => _httpClient.close(force: true);
}

List<String> _parseAppKey(String appKey) {
  final parts = appKey.split('#');
  if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
    throw FormatException('invalid appKey, expected orgName#appName: $appKey');
  }
  return parts;
}

String _requiredString(Map<String, dynamic> response, List<String> path) {
  Object? value = response;
  for (final key in path) {
    value = value is Map ? value[key] : null;
  }
  if (value is! String || value.isEmpty) {
    throw FormatException('REST response missing ${path.join('.')}');
  }
  return value;
}
