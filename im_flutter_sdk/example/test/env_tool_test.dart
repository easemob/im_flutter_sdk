import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/env_tool.dart';

void main() {
  group('environment generation', () {
    test('builds the environment without private server options', () {
      final environment = buildEnvironment(
        config: <String, dynamic>{
          'appKey': 'org#app',
          'enablePrivateConfig': false,
          'chatOptions': <String, Object?>{'dataSyncType': 7},
          'groups': <Object?>[
            <String, Object?>{'id': 'g1'},
          ],
        },
        accounts: <Map<String, Object?>>[
          <String, Object?>{'id': 'u1', 'token': 'token-1'},
        ],
      );

      expect(environment['appKey'], 'org#app');
      expect(environment['dataSyncType'], 7);
      expect(environment, isNot(contains('restServer')));
      expect(environment, isNot(contains('enableDNSConfig')));
      expect(environment['groups'], <Object?>[
        <String, Object?>{'id': 'g1'},
      ]);
    });

    test('maps private msyncServer to Flutter imServer', () {
      final environment = buildEnvironment(
        config: <String, dynamic>{
          'appKey': 'org#app',
          'enablePrivateConfig': true,
          'webSocketServer': 'wss.example.test',
          'restServer': 'https://rest.example.test',
          'msyncServer': 'im.example.test',
          'imPort': 6717,
        },
        accounts: <Map<String, Object?>>[],
      );

      expect(environment['enableDNSConfig'], isFalse);
      expect(environment['imServer'], 'im.example.test');
      expect(environment['imPort'], 6717);
      expect(environment, isNot(contains('msyncServer')));
    });

    test('rejects private mode without the server fields', () {
      expect(
        () => buildEnvironment(
          config: <String, dynamic>{
            'appKey': 'org#app',
            'enablePrivateConfig': true,
          },
          accounts: <Map<String, Object?>>[],
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('webSocketServer, restServer, imServer'),
          ),
        ),
      );
    });

    test('renders a Dart map without credential-source fields', () {
      final output = renderEnvironmentDart(<String, Object?>{
        'appKey': r'org$app',
        'accounts': <Object?>[
          <String, Object?>{'id': 'u1', 'token': 'token-1'},
        ],
      });

      expect(output, contains(r'org\$app'));
      expect(output, contains('token-1'));
      expect(output, contains('config.local.json'));
      expect(output, isNot(contains('cluster')));
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
        final config = <String, dynamic>{
          'restApi': 'http://${server.address.host}:${server.port}',
          'appKey': 'org#app',
          'clientId': 'client-id',
          'clientSecret': 'client-secret',
        };
        final appToken = await client.fetchAppToken(config);
        final accounts = await client.fetchUserTokens(
          config: <String, dynamic>{
            ...config,
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

    test('requires every account to have a user id', () async {
      final client = TokenClient();
      try {
        await expectLater(
          client.fetchUserTokens(
            config: <String, dynamic>{
              'accounts': <Object?>[
                <String, Object?>{'id': 'TODO-user1'},
              ],
            },
            appToken: 'app-token',
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('accounts[0].id'),
            ),
          ),
        );
      } finally {
        client.close();
      }
    });

    test('generates lib/env.dart from a flat config', () async {
      final temporary = await Directory.systemTemp.createTemp('env-tool-');
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
          'restApi': 'http://${server.address.host}:${server.port}',
          'appKey': 'org#app',
          'clientId': 'client-id',
          'clientSecret': 'client-secret',
          'accounts': <Object?>[
            <String, Object?>{'id': 'u1'},
          ],
          'groups': <Object?>[
            <String, Object?>{'id': 'g1', 'cluster': 'ngi'},
          ],
        }));

        await generateEnvironment(paths);

        final generated = await paths.activeEnv.readAsString();
        expect(generated, contains('"appKey": "org#app"'));
        expect(generated, contains('"id": "u1"'));
        expect(generated, contains('"id": "g1"'));
        expect(generated, isNot(contains('cluster')));
        expect(generated, isNot(contains('client-secret')));
        expect(requestCount, 2);
      } finally {
        await server.close(force: true);
        await serving.cancel();
        await temporary.delete(recursive: true);
      }
    });

    test('rejects the removed multi-cluster shape', () async {
      final temporary =
          await Directory.systemTemp.createTemp('env-tool-legacy-');
      try {
        final paths = EnvPaths(temporary);
        await paths.localConfig.writeAsString(jsonEncode(<String, Object?>{
          'defaultCluster': 'ebs',
          'clusters': <String, Object?>{
            'ngi': <String, Object?>{'appKey': 'org#app'},
          },
        }));

        await expectLater(
          generateEnvironment(paths),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('multi-cluster shape'),
            ),
          ),
        );
      } finally {
        await temporary.delete(recursive: true);
      }
    });

    test('requires the public credentials before fetching tokens', () async {
      final temporary =
          await Directory.systemTemp.createTemp('env-tool-missing-');
      try {
        final paths = EnvPaths(temporary);
        await paths.localConfig.writeAsString(jsonEncode(<String, Object?>{
          'restApi': 'TODO',
          'appKey': 'org#app',
        }));

        await expectLater(
          generateEnvironment(paths),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('missing restApi, clientId, clientSecret'),
            ),
          ),
        );
      } finally {
        await temporary.delete(recursive: true);
      }
    });

    test('copies the local files only when they are missing', () async {
      final temporary =
          await Directory.systemTemp.createTemp('env-tool-files-');
      try {
        final paths = EnvPaths(temporary);
        await Directory('${temporary.path}/templates').create(recursive: true);
        await paths.configTemplate.writeAsString('{"restApi": "TODO"}');
        await paths.envTemplate.writeAsString(
          'const Map<String, Object?> environment = <String, Object?>{};\n',
        );

        await ensureLocalFiles(paths);
        expect(await paths.localConfig.exists(), isTrue);
        expect(await paths.activeEnv.exists(), isTrue);

        await paths.activeEnv.writeAsString(
          'const Map<String, Object?> environment = '
          '<String, Object?>{"appKey": "mine"};\n',
        );
        await ensureLocalFiles(paths);

        expect(
          await paths.activeEnv.readAsString(),
          contains('"appKey": "mine"'),
        );
      } finally {
        await temporary.delete(recursive: true);
      }
    });
  });
}
