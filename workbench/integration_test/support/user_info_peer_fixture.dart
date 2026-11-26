import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Owns one fresh, offline account; never accepts an existing account for deletion.
final class UserInfoPeerFixture {
  UserInfoPeerFixture({
    required String restApi,
    required String appKey,
    required String appToken,
  }) : _appToken = appToken {
    final parts = appKey.split('#');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      throw const FormatException('Invalid CI app key');
    }
    _base = '${restApi.replaceFirst(RegExp(r'/+$'), '')}/'
        '${Uri.encodeComponent(parts[0])}/${Uri.encodeComponent(parts[1])}';
  }

  final String userId = 'ci_userinfo_${DateTime.now().microsecondsSinceEpoch}_'
      '${Random.secure().nextInt(1 << 32).toRadixString(16)}';
  final String _appToken;
  late final String _base;
  final _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..findProxy = (_) => 'DIRECT';
  bool _created = false;

  Future<void> create() async {
    if (_created) throw StateError('Fixture account already created');
    final response = await _request('POST', 'users',
        body: {
          'username': userId,
          'password': '${Random.secure().nextInt(1 << 32)}'
              '${Random.secure().nextInt(1 << 32)}',
        },
        onSuccess: () => _created = true);
    _verifyEntity(response);
    _verifyEntity(await _request('GET', 'users/$userId'));
    final contacts = await _request('GET', 'users/$userId/contacts/users');
    if (contacts['data'] is! List || (contacts['data'] as List).isNotEmpty) {
      throw StateError('Fresh fixture account must have no contacts: $userId');
    }
  }

  Future<void> delete() async {
    if (!_created) return;
    _verifyEntity(await _request('DELETE', 'users/$userId'));
    await _request('GET', 'users/$userId', verifyDeletedUser: true);
    _created = false;
  }

  void _verifyEntity(Map<String, dynamic> response) {
    final entities = response['entities'];
    if (entities is! List ||
        entities.length != 1 ||
        entities.single is! Map ||
        (entities.single as Map)['username'] != userId) {
      throw FormatException('REST response must identify fixture user $userId');
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    void Function()? onSuccess,
    bool verifyDeletedUser = false,
  }) async {
    final request = await _http
        .openUrl(method, Uri.parse('$_base/$path'))
        .timeout(const Duration(seconds: 10));
    try {
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_appToken');
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response =
          await request.close().timeout(const Duration(seconds: 15));
      final succeeded = response.statusCode >= 200 && response.statusCode < 300;
      if (succeeded) onSuccess?.call();
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        throw FormatException('REST $method $path returned a non-object');
      }
      if (verifyDeletedUser &&
          response.statusCode == HttpStatus.notFound &&
          decoded['error'] == 'service_resource_not_found' &&
          decoded['error_description'] == 'Service resource not found') {
        return Map<String, dynamic>.from(decoded);
      }
      if (!succeeded) {
        throw HttpException('REST $method $path: HTTP ${response.statusCode} '
            '${decoded['error']} ${decoded['error_description']}');
      }
      if (verifyDeletedUser) {
        throw StateError('Deleted fixture account still exists: $userId');
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      request.abort();
      rethrow;
    }
  }

  void close() => _http.close(force: true);
}
