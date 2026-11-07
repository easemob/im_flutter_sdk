import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../tool/rest_resource_client.dart';

/// REST observations are independent of the SDK being tested.
final class CiRestFixture {
  CiRestFixture({
    required String restApi,
    required String appKey,
    required String appToken,
  }) : _appToken = appToken {
    final parts = appKey.split('#');
    if (parts.length != 2 || parts.any((value) => value.isEmpty)) {
      throw const FormatException('Invalid CI app key');
    }
    _base = '${restApi.replaceFirst(RegExp(r'/+$'), '')}/'
        '${Uri.encodeComponent(parts[0])}/${Uri.encodeComponent(parts[1])}';
    _resources = RestResourceClient(
      restApi: restApi,
      appKey: appKey,
      appToken: appToken,
      httpClient: HttpClient()
        ..connectionTimeout = const Duration(seconds: 10)
        ..findProxy = (_) => 'DIRECT',
    );
  }

  final String _appToken;
  late final String _base;
  late final RestResourceClient _resources;
  final _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..findProxy = ((_) => 'DIRECT');

  Future<List<String>> contactIds(String userId) =>
      _resources.fetchContactIds(userId).timeout(const Duration(seconds: 15));

  Future<ContactRelationSnapshot> snapshotContacts(
      String user, String peer) async {
    final userIds = await contactIds(user);
    final peerIds = await contactIds(peer);
    final snapshot = ContactRelationSnapshot(userIds, peerIds);
    if (userIds.contains(peer) != peerIds.contains(user)) {
      throw StateError('Asymmetric original friendship: $user / $peer; '
          'no fixture mutation was made');
    }
    return snapshot;
  }

  Future<void> setContacts(String user, String peer, bool present) async {
    if (present) {
      await _resources
          .addContacts(user, peer)
          .timeout(const Duration(seconds: 15));
    } else {
      await _resources
          .removeContacts(user, peer)
          .timeout(const Duration(seconds: 15));
    }
    await verifyContacts(user, peer, present);
  }

  Future<void> verifyContacts(String user, String peer, bool present) async {
    await waitForCi(
      'REST bilateral friendship $user / $peer = $present',
      () async => [
        (await contactIds(user)).contains(peer),
        (await contactIds(peer)).contains(user),
      ],
      (values) => values.every((value) => value == present),
    );
  }

  Future<void> restoreContacts(
    String user,
    String peer,
    ContactRelationSnapshot snapshot,
  ) async {
    await setContacts(user, peer, snapshot.userIds.contains(peer));
    final actualUser = (await contactIds(user)).toSet();
    final actualPeer = (await contactIds(peer)).toSet();
    if (!_sameSet(actualUser, snapshot.userIds.toSet()) ||
        !_sameSet(actualPeer, snapshot.peerIds.toSet())) {
      throw StateError('Friendship restoration differs from original lists '
          'for $user / $peer');
    }
  }

  Future<List<String>> blockIds(String user) async {
    final response = await _request('GET', 'users/${_path(user)}/blocks/users');
    return _stringList(response['data'], 'REST blacklist');
  }

  Future<void> setBlocked(String user, String peer, bool present) async {
    final current = await blockIds(user);
    if (current.contains(peer) != present) {
      if (present) {
        await _request('POST', 'users/${_path(user)}/blocks/users', body: {
          'usernames': [peer],
        });
      } else {
        await _request(
          'DELETE',
          'users/${_path(user)}/blocks/users/${_path(peer)}',
        );
      }
    }
    await waitForCi('REST blacklist $user / $peer = $present',
        () => blockIds(user), (ids) => ids.contains(peer) == present);
  }

  Future<void> deleteGroup(String groupId) =>
      _resources.deleteGroup(groupId).timeout(const Duration(seconds: 15));

  Future<List<String>> groupIdsNamed({
    required String owner,
    required String name,
  }) async {
    final response =
        await _request('GET', 'users/${_path(owner)}/joined_chatgroups');
    final data = response['data'];
    if (data is! List || data.any((item) => item is! Map)) {
      throw const FormatException(
          'REST joined groups must be a list of objects');
    }
    final ids = <String>[];
    for (final item in data.cast<Map>()) {
      if (item['groupname'] != name) continue;
      final id = item['groupid'];
      if (id is! String || id.isEmpty) {
        throw const FormatException('REST joined group missing groupid');
      }
      ids.add(id);
    }
    return ids;
  }

  /// A missing group must be an explicit resource response, not a transport error.
  Future<Map<String, dynamic>?> group(String groupId) async {
    Map<String, dynamic> response;
    try {
      response = await _request('GET', 'chatgroups/${_path(groupId)}');
    } on _RestFailure catch (error) {
      if (error.status == HttpStatus.notFound &&
          (error.code == 'group_not_found' ||
              (error.code == 'service_resource_not_found' &&
                  error.description == 'do not find this group:$groupId'))) {
        return null;
      }
      rethrow;
    }
    final data = response['data'];
    if (data is! List || data.length != 1 || data.single is! Map) {
      throw const FormatException('REST group detail must contain one object');
    }
    final value = Map<String, dynamic>.from(data.single as Map);
    final id = value['id'] ?? value['groupid'];
    if (id != groupId) {
      throw FormatException(
          'REST group ID mismatch: expected $groupId, got $id');
    }
    if (value['error'] == "group id doesn't exist") return null;
    if (value.containsKey('error')) {
      throw StateError('REST group $groupId: ${value['error']}');
    }
    if (value['name'] is! String || value['owner'] is! String) {
      throw const FormatException('REST group detail missing name or owner');
    }
    return value;
  }

  Future<Set<String>> groupMembers(String groupId) async {
    final response = await _request(
      'GET',
      'chatgroups/${_path(groupId)}/users?limit=1000',
    );
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('REST group members must be a list');
    }
    final members = <String>{};
    for (final item in data) {
      if (item is! Map || item.length != 1) {
        throw const FormatException(
            'REST member must contain one role/user pair');
      }
      final role = item.keys.single;
      final user = item.values.single;
      if (!const ['owner', 'member', 'admin'].contains(role) ||
          user is! String ||
          user.isEmpty ||
          !members.add(user)) {
        throw const FormatException('Invalid or duplicate REST group member');
      }
    }
    if (response['cursor'] != null && response['cursor'] != '') {
      throw StateError(
          'Unexpected extra member page for owned CI group $groupId');
    }
    return members;
  }

  Future<void> verifyGroupAbsent(String groupId) async {
    await waitForCi(
      'REST group $groupId absent',
      () => group(groupId),
      (value) => value == null,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
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
      final bodyText = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(bodyText);
      if (decoded is! Map) {
        throw FormatException('REST $method $path returned a non-object');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _RestFailure(
          response.statusCode,
          decoded['error']?.toString() ?? '',
          decoded['error_description']?.toString() ?? '',
          '$method $path',
        );
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      request.abort();
      rethrow;
    }
  }

  void close() {
    _resources.close();
    _http.close(force: true);
  }
}

final class ContactRelationSnapshot {
  ContactRelationSnapshot(this.userIds, this.peerIds);
  final List<String> userIds;
  final List<String> peerIds;
}

final class _RestFailure implements Exception {
  _RestFailure(this.status, this.code, this.description, this.operation);
  final int status;
  final String code;
  final String description;
  final String operation;

  @override
  String toString() => 'REST $operation: HTTP $status $code $description';
}

Future<T> waitForCi<T>(
  String description,
  Future<T> Function() read,
  bool Function(T) matches, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final watch = Stopwatch()..start();
  Object? lastObservation;
  while (true) {
    final remaining = timeout - watch.elapsed;
    if (remaining <= Duration.zero) {
      throw TimeoutException(
          '$description; last observation: $lastObservation', timeout);
    }
    final observed = await read().timeout(remaining);
    lastObservation = observed;
    if (matches(observed)) return observed;
    if (watch.elapsed >= timeout) {
      throw TimeoutException(
          '$description; last observation: $observed', timeout);
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

String _path(String value) => Uri.encodeComponent(value);

List<String> _stringList(Object? data, String description) {
  if (data is! List || data.any((value) => value is! String)) {
    throw FormatException('$description must be a list of strings');
  }
  return data.cast<String>();
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);
