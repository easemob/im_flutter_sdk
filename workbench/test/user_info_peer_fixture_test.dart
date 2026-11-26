import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/user_info_peer_fixture.dart';

void main() {
  late HttpServer server;
  late Future<void> done;
  late UserInfoPeerFixture fixture;
  final requests = <String>[];
  var conflict = false;
  var deleted = false;
  var missingError = 'service_resource_not_found';

  setUp(() async {
    requests.clear();
    conflict = false;
    deleted = false;
    missingError = 'service_resource_not_found';
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    fixture = UserInfoPeerFixture(
        restApi: 'http://${server.address.host}:${server.port}',
        appKey: 'test#app',
        appToken: 'test-token');
    done = server.forEach((request) async {
      await request.drain<void>();
      requests.add('${request.method} ${request.uri.path}');
      final response = request.response;
      response.headers.contentType = ContentType.json;
      Object body = {
        'entities': [
          {'username': fixture.userId}
        ]
      };
      if (request.method == 'POST' && conflict) {
        response.statusCode = HttpStatus.badRequest;
        body = {'error': 'duplicate_unique_property_exists'};
      } else if (request.uri.path.endsWith('/contacts/users')) {
        body = {'data': <String>[]};
      } else if (request.method == 'DELETE') {
        deleted = true;
      } else if (request.method == 'GET' && deleted) {
        response.statusCode = HttpStatus.notFound;
        body = {
          'error': missingError,
          'error_description': 'Service resource not found',
        };
      }
      response.write(jsonEncode(body));
      await response.close();
    });
  });

  tearDown(() async {
    fixture.close();
    await server.close(force: true);
    await done;
  });

  test('fresh account cleanup verifies the exact deleted account is absent',
      () async {
    await fixture.create();
    await fixture.delete();
    final path = '/test/app/users/${fixture.userId}';
    expect(requests, [
      'POST /test/app/users',
      'GET $path',
      'GET $path/contacts/users',
      'DELETE $path',
      'GET $path',
    ]);
  });

  test('a creation conflict never authorizes deleting an existing account',
      () async {
    conflict = true;
    await expectLater(fixture.create(), throwsA(isA<HttpException>()));
    await fixture.delete();
    expect(requests, ['POST /test/app/users']);
  });

  test('an unrelated 404 does not prove fixture account cleanup succeeded',
      () async {
    await fixture.create();
    missingError = 'route_not_found';
    await expectLater(fixture.delete(), throwsA(isA<HttpException>()));
  });
}
