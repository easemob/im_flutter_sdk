import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/env_tool.dart';

void main() {
  group('environment generation', () {
    test('builds a public cluster without private server options', () {
      final environment = buildEnvironment(
        clusterName: 'ebs',
        defaultCluster: 'ebs',
        cluster: <String, dynamic>{
          'appKey': 'org#app',
          'chatOptions': <String, Object?>{'debugMode': true},
        },
        config: <String, dynamic>{
          'enablePrivateConfig': false,
          'chatOptions': <String, Object?>{'dataSyncType': 7},
          'groups': <Object?>[
            <String, Object?>{'id': 'g1', 'cluster': 'ebs'},
          ],
        },
        accounts: <Map<String, Object?>>[
          <String, Object?>{'id': 'u1', 'token': 'token-1'},
        ],
      );

      expect(environment['appKey'], 'org#app');
      expect(environment['debugMode'], isTrue);
      expect(environment['dataSyncType'], 7);
      expect(environment, isNot(contains('restServer')));
      expect(environment['groups'], <Object?>[
        <String, Object?>{'id': 'g1'},
      ]);
    });

    test('maps private msyncServer to Flutter imServer', () {
      final environment = buildEnvironment(
        clusterName: 'ebs',
        environmentName: 'private',
        defaultCluster: 'ebs',
        cluster: <String, dynamic>{
          'appKey': 'org#app',
        },
        config: <String, dynamic>{
          'enablePrivateConfig': true,
          'webSocketServer': 'wss.example.test',
          'restServer': 'https://rest.example.test',
          'msyncServer': 'im.example.test',
          'imPort': 6717,
        },
        accounts: <Map<String, Object?>>[],
      );

      expect(environment['enableDNSConfig'], isFalse);
      expect(environment['cluster'], 'private');
      expect(environment['imServer'], 'im.example.test');
      expect(environment['imPort'], 6717);
    });

    test('renders a Dart map without credential-source fields', () {
      final output = renderEnvironmentDart('ebs', <String, Object?>{
        'appKey': r'org$app',
        'accounts': <Object?>[
          <String, Object?>{'id': 'u1', 'token': 'token-1'},
        ],
      });

      expect(output, contains(r'org\$app'));
      expect(output, contains('token-1'));
      expect(output, isNot(contains('clientSecret')));
    });

    test('fetches app and user tokens with the REST token flow', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requests = <Map<String, Object?>>[];
      final serving = server.listen((request) async {
        final body = Map<String, dynamic>.from(
          jsonDecode(await utf8.decoder.bind(request).join()) as Map,
        );
        requests.add(<String, Object?>{
          'authorization': request.headers.value(
            HttpHeaders.authorizationHeader,
          ),
          'body': body,
        });
        request.response.headers.contentType = ContentType.json;
        final token = body['grant_type'] == 'client_credentials'
            ? 'app-token'
            : 'user-token-${body['username']}';
        request.response.write(jsonEncode(<String, Object?>{
          'access_token': token,
        }));
        await request.response.close();
      });
      final client = TokenClient();
      try {
        final cluster = <String, dynamic>{
          'restApi': 'http://${server.address.host}:${server.port}',
          'appKey': 'org#app',
          'clientId': 'client-id',
          'clientSecret': 'client-secret',
        };
        final appToken = await client.fetchAppToken(cluster);
        final accounts = await client.fetchUserTokens(
          clusterName: 'local',
          defaultCluster: 'local',
          cluster: cluster,
          config: <String, dynamic>{
            'tokenTtl': 60,
            'accounts': <Object?>[
              <String, Object?>{'id': 'u1'},
              <String, Object?>{'id': 'u2'},
            ],
          },
          appToken: appToken,
        );

        expect(appToken, 'app-token');
        expect(accounts, <Object?>[
          <String, Object?>{'id': 'u1', 'token': 'user-token-u1'},
          <String, Object?>{'id': 'u2', 'token': 'user-token-u2'},
        ]);
        expect(requests, hasLength(3));
        expect(requests.first['authorization'], isNull);
        expect(requests[1]['authorization'], 'Bearer app-token');
        expect(
          (requests[1]['body'] as Map)['autoCreateUser'],
          isTrue,
        );
      } finally {
        client.close();
        await server.close(force: true);
        await serving.cancel();
      }
    });

    test('uses the only configured cluster when ebs is omitted', () async {
      final temporary = await Directory.systemTemp.createTemp('env-tool-ngi-');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requestCount = 0;
      final serving = server.listen((request) async {
        requestCount++;
        final body = Map<String, dynamic>.from(
          jsonDecode(await utf8.decoder.bind(request).join()) as Map,
        );
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(<String, Object?>{
          'access_token': body['grant_type'] == 'client_credentials'
              ? 'app-token'
              : 'user-token',
        }));
        await request.response.close();
      });
      try {
        final paths = EnvPaths(temporary);
        await paths.localConfig.writeAsString(jsonEncode(<String, Object?>{
          'defaultCluster': 'ebs',
          'clusters': <String, Object?>{
            'ngi': <String, Object?>{
              'restApi': 'http://${server.address.host}:${server.port}',
              'appKey': 'org#app',
              'clientId': 'client-id',
              'clientSecret': 'client-secret',
            },
          },
          'accounts': <Object?>[
            <String, Object?>{'id': 'u1', 'cluster': 'ebs'},
          ],
          'groups': <Object?>[
            <String, Object?>{'id': 'g1', 'cluster': 'ebs'},
          ],
        }));

        expect(await generateClusterEnvironments(paths), 0);
        final generated = await paths.cachedEnv('ngi').readAsString();
        expect(generated, contains('"cluster": "ngi"'));
        expect(generated, contains('"id": "u1"'));
        expect(generated, contains('"id": "g1"'));
        expect(await paths.activeEnv.readAsString(),
            contains('Active cluster: ngi'));
        expect(requestCount, 2);
      } finally {
        await server.close(force: true);
        await serving.cancel();
        await temporary.delete(recursive: true);
      }
    });

    test('requires a valid default when multiple clusters are configured',
        () async {
      final temporary =
          await Directory.systemTemp.createTemp('env-tool-default-');
      try {
        final paths = EnvPaths(temporary);
        await paths.localConfig.writeAsString(jsonEncode(<String, Object?>{
          'defaultCluster': 'missing',
          'clusters': <String, Object?>{
            'ebs': <String, Object?>{},
            'ngi': <String, Object?>{},
          },
        }));

        await expectLater(
          generateClusterEnvironments(paths),
          throwsA(isA<FormatException>()),
        );
      } finally {
        await temporary.delete(recursive: true);
      }
    });

    test('activates a previously generated cluster environment', () async {
      final temporary = await Directory.systemTemp.createTemp('env-tool-test-');
      try {
        final paths = EnvPaths(temporary);
        await paths.cacheDir.create(recursive: true);
        await paths.cachedEnv('ngi').writeAsString(
              'const Map<String, Object?> environment = '
              '<String, Object?>{"cluster": "ngi"};\n',
            );

        await activateCluster(paths, 'ngi');

        final active = await paths.activeEnv.readAsString();
        expect(active, contains('Active cluster: ngi'));
        expect(active, contains('"cluster": "ngi"'));
      } finally {
        await temporary.delete(recursive: true);
      }
    });

    test('private mode generates and activates only env.private.dart',
        () async {
      final temporary =
          await Directory.systemTemp.createTemp('env-tool-private-');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requestCount = 0;
      final serving = server.listen((request) async {
        requestCount++;
        final body = Map<String, dynamic>.from(
          jsonDecode(await utf8.decoder.bind(request).join()) as Map,
        );
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(<String, Object?>{
          'access_token': body['grant_type'] == 'client_credentials'
              ? 'app-token'
              : 'user-token',
        }));
        await request.response.close();
      });
      try {
        final paths = EnvPaths(temporary);
        await paths.localConfig.writeAsString(jsonEncode(<String, Object?>{
          'defaultCluster': 'ebs',
          'enablePrivateConfig': true,
          'webSocketServer': 'wss.private.test',
          'restServer': 'https://rest.private.test',
          'msyncServer': 'im.private.test',
          'clusters': <String, Object?>{
            'ebs': <String, Object?>{
              'restApi': 'http://${server.address.host}:${server.port}',
              'appKey': 'org#app',
              'clientId': 'client-id',
              'clientSecret': 'client-secret',
            },
            'ngi': <String, Object?>{
              'restApi': 'http://unused.invalid',
              'appKey': 'unused#app',
              'clientId': 'unused',
              'clientSecret': 'unused',
            },
          },
          'accounts': <Object?>[
            <String, Object?>{'id': 'u1', 'cluster': 'ebs'},
          ],
        }));

        expect(await generateClusterEnvironments(paths), 0);
        expect(await paths.cachedEnv('private').exists(), isTrue);
        expect(await paths.cachedEnv('ebs').exists(), isFalse);
        expect(await paths.cachedEnv('ngi').exists(), isFalse);
        expect(await paths.activeEnv.readAsString(), contains('"private"'));
        expect(requestCount, 2);
      } finally {
        await server.close(force: true);
        await serving.cancel();
        await temporary.delete(recursive: true);
      }
    });
  });
}
