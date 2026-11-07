import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/ast.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';

JsonObject environment() => {
      'appKey': 'org#app',
      'debugMode': true,
      'dataSyncType': 7,
      'accounts': [
        {'id': 'alice', 'token': 'alice-secret'},
        {'id': 'bob', 'token': 'bob-secret'},
      ],
      'groups': <Object?>[],
      'rooms': <Object?>[],
    };

JsonObject input() => {
      ...environment(),
      'accounts': [
        {'id': 'alice'},
        {'id': 'bob'}
      ],
      'restApi': 'https://management.example.invalid',
      'clientId': 'client-secret-id',
      'clientSecret': 'client-secret',
    };

Map<String, JsonObject> roles() => {
      'alice': {
        'accountId': 'alice',
        'platform': 'ios',
        'instance': 'device-a'
      },
      'bob': {'accountId': 'bob', 'platform': 'ios', 'instance': 'device-b'},
    };

const none = PreconditionDecl(
    kind: 'contacts', between: ['alice', 'bob'], state: 'none');
const friends = PreconditionDecl(
    kind: 'contacts', between: ['alice', 'bob'], state: 'friends');

class Request {
  Request(this.method, this.uri, this.body, this.bearer);
  final String method;
  final Uri uri;
  final JsonObject? body;
  final String? bearer;
}

class FakeTransport implements DataTransport {
  FakeTransport(this.handler);
  final FutureOr<DataHttpResponse> Function(Request request) handler;
  final calls = <Request>[];

  @override
  Future<DataHttpResponse> request(String method, Uri uri,
      {JsonObject? body,
      String? bearerToken,
      required Duration timeout}) async {
    final request = Request(method, uri, body, bearerToken);
    calls.add(request);
    return handler(request);
  }
}

DataHttpResponse json(Object? value, {int status = 200}) =>
    DataHttpResponse(status, jsonEncode(value));

void main() {
  late Directory root;
  late OperationContext context;
  late String inputPath;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-data-');
    context = OperationContext(
        runId: 'run-1',
        operationId: 'data-1',
        tmpDirectory: root,
        redactor: SecretRedactor());
    inputPath = p.join(root.path, 'input.json');
    await File(inputPath).writeAsString(jsonEncode(input()));
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  OperationContext generation() => OperationContext(
      runId: null,
      operationId: 'generate-1',
      tmpDirectory: root,
      redactor: SecretRedactor());

  CaseData create(DataService service,
      {JsonObject? metadata,
      Map<String, JsonObject>? mapping,
      int attempt = 1}) {
    final result = service.createCaseData(
        context: context,
        environment: environment(),
        caseName: 'presence',
        caseBasename: '5.0.0-multi-presence-positive',
        attempt: attempt,
        roles: mapping ?? roles(),
        agentRoles: ['alice', 'bob'],
        metadata: metadata ?? {});
    expect(result.status, OperationStatus.success,
        reason: result.errors.map((e) => e.message).join('; '));
    return result.data!;
  }

  group('account data validation', () {
    test(
        'retains SDK types and rejects coercion, duplicate accounts, management data and unknown fields',
        () {
      final service = DataService();
      final valid = environment()
        ..addAll({
          'imPort': 8888,
          'imServer': 'host',
          'enableDNSConfig': false,
          'ntpServers': ['time.example'],
          'apnsCertName': 'cert',
          'pushKitCertName': null
        });
      expect(service.validateEnvironment(valid), valid);
      for (final patch in <JsonObject>[
        {'debugMode': 'true'},
        {'dataSyncType': 7.0},
        {
          'ntpServers': [1]
        },
        {'appKey': 'bad'},
        {
          'groups': [
            {'id': 12}
          ]
        },
        {'rooms': null},
        {'clientSecret': 'hidden'},
        {'deviceId': 'device'},
        {'results': {}},
        {
          'accounts': [
            {'id': 'a', 'token': 'one'},
            {'id': 'a', 'token': 'two'}
          ]
        },
        {
          'accounts': [
            {'id': 'a', 'token': ''}
          ]
        },
      ]) {
        expect(() => service.validateEnvironment({...environment(), ...patch}),
            throwsA(isA<DataValidationException>()),
            reason: '$patch');
      }
    });

    test(
        'generation obtains all tokens without creating users and round-trips Dart escaping through isolated loader',
        () async {
      final transport = FakeTransport((request) {
        if (request.body!['grant_type'] == 'client_credentials')
          return json({'access_token': 'app-token'});
        expect(request.bearer, 'app-token');
        expect(request.body!['autoCreateUser'], false);
        return json({
          'access_token':
              'tok-${request.body!['username']}-\$quoted\\text\n"line"'
        });
      });
      final service = DataService(transport: transport);
      final output = p.join(root.path, 'accounts.g.dart');
      final generated = await service.generate(
          context: generation(), inputPath: inputPath, outputPath: output);
      expect(generated.status, OperationStatus.success);
      expect(transport.calls.length, 3);
      expect(transport.calls.every((call) => call.uri.path == '/org/app/token'),
          isTrue);
      expect(
          await File(output).readAsString(), isNot(contains('clientSecret')));
      expect((await File(output).stat()).mode & 0x1ff, 0x180);
      final loaded = await service.load(context: context, sourcePath: output);
      expect(loaded.status, OperationStatus.success,
          reason: loaded.errors.map((e) => e.message).join(';'));
      expect(loaded.data!.environment, generated.data!.environment);
      expect(
          await File(p.join(root.path, 'load-data-1.dart')).exists(), isFalse);
      expect(context.redactor.text('tok-alice-\$quoted\\text\n"line"'),
          isNot(contains('tok-alice')));
    });

    test('one failed token leaves prior source untouched and does not retry',
        () async {
      final transport = FakeTransport((request) {
        if (request.body!['grant_type'] == 'client_credentials')
          return json({'access_token': 'app-token'});
        if (request.body!['username'] == 'alice')
          return json({'access_token': 'alice-new'});
        return json({'error': 'hidden-token'}, status: 403);
      });
      final output = File(p.join(root.path, 'accounts.g.dart'));
      await output.writeAsString('old valid source');
      final result = await DataService(transport: transport).generate(
          context: generation(), inputPath: inputPath, outputPath: output.path);
      expect(result.status, OperationStatus.failure);
      expect(await output.readAsString(), 'old valid source');
      expect(transport.calls.length, 3);
      expect(result.errors.single.message, contains('permission'));
      expect(result.errors.single.message, isNot(contains('hidden-token')));
    });

    test(
        'invalid configuration has no HTTP side effect; invalid token response cannot publish source',
        () async {
      final transport = FakeTransport((request) => json({'access_token': ''}));
      final service = DataService(transport: transport);
      await File(inputPath)
          .writeAsString(jsonEncode({...input(), 'debugMode': 1}));
      final output = p.join(root.path, 'accounts.g.dart');
      var result = await service.generate(
          context: generation(), inputPath: inputPath, outputPath: output);
      expect(result.status, OperationStatus.failure);
      expect(transport.calls, isEmpty);
      await File(inputPath).writeAsString(jsonEncode(input()));
      result = await service.generate(
          context: generation(), inputPath: inputPath, outputPath: output);
      expect(result.status, OperationStatus.failure);
      expect(await File(output).exists(), isFalse);
      expect(transport.calls.length, 1);
    });

    test(
        'missing, uncompilable and loadable-but-invalid generated data return sanitized failures',
        () async {
      final service = DataService();
      final source = File(p.join(root.path, 'accounts.g.dart'));
      expect(
          (await service.load(context: context, sourcePath: source.path))
              .status,
          OperationStatus.failure);
      await source.writeAsString('secretCompilerToken broken syntax');
      final broken =
          await service.load(context: context, sourcePath: source.path);
      expect(broken.status, OperationStatus.failure);
      expect(broken.errors.map((e) => e.message).join(),
          isNot(contains('secretCompilerToken')));
      await source.writeAsString(
          "const environment = {'appKey': 'org#app', 'accounts': [], 'groups': [], 'rooms': []};");
      final invalid =
          await service.load(context: context, sourcePath: source.path);
      expect(invalid.status, OperationStatus.failure);
      expect(invalid.errors.single.field, 'environment.accounts');
    });
  });

  group('case data', () {
    test(
        'maps explicit accounts and keeps init data, resources and per-attempt unique values separate',
        () {
      final service = DataService();
      final metadata = <String, Object?>{
        'data': {
          'input': {'expiry': 120},
          'unique': {'presenceDescription': 'presence-'}
        }
      };
      final first = create(service, metadata: metadata);
      final second = create(service, metadata: metadata, attempt: 2);
      expect(first.accounts['alice'],
          {'userId': 'alice', 'userToken': 'alice-secret'});
      expect(first.initConfig,
          {'appKey': 'org#app', 'debugMode': true, 'dataSyncType': 7});
      expect(first.input['expiry'], 120);
      expect(
          first.input['presenceDescription'],
          contains(
              'run-1-5.0.0-multi-presence-positive-1-presenceDescription'));
      expect(first.input['presenceDescription'],
          isNot(second.input['presenceDescription']));
      expect(first.input['groups'], isEmpty);
      expect(metadata['data'], {
        'input': {'expiry': 120},
        'unique': {'presenceDescription': 'presence-'}
      });
      expect(() => service.validateCaseData(first, first), returnsNormally);
      expect(() => service.validateCaseData(second, first),
          throwsA(isA<DataValidationException>()));
    });

    test(
        'rejects role mismatch, missing account and repeated device without guessing',
        () {
      final service = DataService();
      for (final mapping in <Map<String, JsonObject>>[
        {'alice': roles()['alice']!},
        {
          ...roles(),
          'alice': {...roles()['alice']!, 'accountId': 'missing'}
        },
        {
          ...roles(),
          'bob': {...roles()['bob']!, 'instance': 'device-a'}
        },
      ]) {
        final result = service.createCaseData(
            context: context,
            environment: environment(),
            caseName: 'test',
            caseBasename: 'test',
            attempt: 1,
            roles: mapping,
            agentRoles: ['alice', 'bob'],
            metadata: {});
        expect(result.status, OperationStatus.failure);
      }
    });

    test('reserved inputs, conflicting values and invalid names are rejected',
        () {
      final service = DataService();
      for (final data in <JsonObject>[
        {
          'input': {'groups': <Object?>[]}
        },
        {
          'unique': {'rooms': 'room-'}
        },
        {
          'input': {'id': 1},
          'unique': {'id': 'id-'}
        },
        {
          'input': {
            'nested': {'bad-key': 1}
          }
        },
        {
          'unique': {'key': 123}
        },
      ]) {
        expect(
            () => service
                .validateCaseMetadata({'data': data}, [], ['alice', 'bob']),
            throwsA(isA<DataValidationException>()));
      }
    });
  });

  group('preconditions', () {
    test(
        'no declaration needs no management configuration and writes empty run check',
        () async {
      final transport =
          FakeTransport((_) => throw StateError('must not request'));
      final service = DataService(transport: transport);
      final checkPath = p.join(root.path, 'attempt', 'preconditions.json');
      final result = await service.preconditions(
          context: context,
          caseName: 'presence',
          environment: environment(),
          caseData: create(service),
          declarations: [],
          metadata: {},
          checkOutputPath: checkPath);
      expect(result.status, OperationStatus.success);
      expect(transport.calls, isEmpty);
      expect(jsonDecode(await File(checkPath).readAsString()), <Object?>[]);
      await verifyFileRef(result.data!.check);
    });

    test(
        'read-only run checks both sides and never performs allowed preparation',
        () async {
      final transport = FakeTransport((request) {
        if (request.uri.path.endsWith('/token'))
          return json({'access_token': 'app-secret'});
        return json({
          'data': request.uri.path.contains('/alice/') ? ['bob'] : ['alice']
        });
      });
      final service = DataService(transport: transport);
      final result = await service.preconditions(
          context: context,
          caseName: 'presence',
          environment: environment(),
          caseData: create(service),
          declarations: [none],
          metadata: {
            'data': {
              'prepare': [none.toJson()]
            }
          },
          dataInputPath: inputPath);
      expect(result.status, OperationStatus.failure);
      expect(result.data!.checks.single.actual, {'alice': true, 'bob': true});
      expect(
          transport.calls.map((call) => call.method), ['POST', 'GET', 'GET']);
      expect(result.data!.setup, isNull);
    });

    test(
        'preparing friends queries before and after; a successful write alone does not pass',
        () async {
      final transport = FakeTransport((request) {
        if (request.uri.path.endsWith('/token'))
          return json({'access_token': 'app-secret'});
        if (request.method == 'GET') return json({'data': <Object?>[]});
        return json({});
      });
      final service = DataService(transport: transport);
      final result = await service.preconditions(
          context: context,
          caseName: 'presence',
          environment: environment(),
          caseData: create(service),
          declarations: [friends],
          metadata: {
            'data': {
              'prepare': [friends.toJson()]
            }
          },
          dataInputPath: inputPath,
          prepare: true);
      expect(result.status, OperationStatus.failure);
      expect(transport.calls.map((call) => call.method),
          ['POST', 'GET', 'GET', 'POST', 'GET', 'GET']);
      expect(result.data!.checks.single.satisfied, isFalse);
      await verifyFileRef(result.data!.setup!);
    });

    test(
        'already satisfied prepare makes no write; bilateral removal avoids stale second deletion',
        () async {
      var linked = false;
      final transport = FakeTransport((request) {
        if (request.uri.path.endsWith('/token'))
          return json({'access_token': 'app-secret'});
        if (request.method == 'GET')
          return json({
            'data': linked
                ? [
                    request.uri.path.contains('/alice/') ? 'bob' : 'alice',
                    'unrelated'
                  ]
                : ['unrelated']
          });
        expect(request.method, 'DELETE');
        linked = false;
        return json({});
      });
      final service = DataService(transport: transport);
      Future<OperationResult<PreconditionResult>> prepare() =>
          service.preconditions(
              context: context,
              caseName: 'presence',
              environment: environment(),
              caseData: create(service),
              declarations: [none],
              metadata: {
                'data': {
                  'prepare': [none.toJson()]
                }
              },
              dataInputPath: inputPath,
              prepare: true);
      expect((await prepare()).status, OperationStatus.success);
      expect(transport.calls.where((call) => call.method == 'DELETE'), isEmpty);
      linked = true;
      expect((await prepare()).status, OperationStatus.success);
      final deletes =
          transport.calls.where((call) => call.method == 'DELETE').toList();
      expect(deletes.length, 1);
      expect(
          deletes.single.uri.path, '/org/app/users/alice/contacts/users/bob');
      expect(
          transport.calls.every((call) => !call.uri.path.contains('unrelated')),
          isTrue);
    });

    test(
        'unknown write outcome stops preparation without retry and persists started action',
        () async {
      final transport = FakeTransport((request) {
        if (request.uri.path.endsWith('/token'))
          return json({'access_token': 'app-secret'});
        if (request.method == 'GET') return json({'data': <Object?>[]});
        throw TimeoutException('secret response must not leak');
      });
      final service = DataService(transport: transport);
      final result = await service.preconditions(
          context: context,
          caseName: 'presence',
          environment: environment(),
          caseData: create(service),
          declarations: [friends],
          metadata: {
            'data': {
              'prepare': [friends.toJson()]
            }
          },
          dataInputPath: inputPath,
          prepare: true);
      expect(result.status, OperationStatus.failure);
      expect(result.errors.single.message, contains('outcome unknown'));
      expect(result.errors.single.field, 'management.writeOutcome');
      expect(result.errors.single.expected, 'known');
      expect(result.errors.single.actual, 'unknown');
      expect(result.errors.single.message, isNot(contains('secret response')));
      expect(transport.calls.length, 4);
      expect(result.data!.checks.single.actual, isNull);
      final setup =
          jsonDecode(await File(result.data!.setup!.path).readAsString())
              as Map<String, dynamic>;
      expect((setup['actions'] as List).single['status'], 'started');
      expect(await File(result.data!.setup!.path).readAsString(),
          isNot(contains('app-secret')));
    });

    test(
        'invalid response, permission failure and wrong app cannot become empty contact success',
        () async {
      for (final response in [
        json({}, status: 403),
        json({'data': 'not-list'}),
        const DataHttpResponse(200, 'not-json')
      ]) {
        final transport = FakeTransport((request) =>
            request.uri.path.endsWith('/token')
                ? json({'access_token': 'app-secret'})
                : response);
        final service = DataService(transport: transport);
        final result = await service.preconditions(
            context: context,
            caseName: 'presence',
            environment: environment(),
            caseData: create(service),
            declarations: [none],
            metadata: {},
            dataInputPath: inputPath);
        expect(result.status, OperationStatus.failure);
        expect(result.data!.checks.single.actual, isNull);
        expect(transport.calls.length, 2);
      }
      await File(inputPath)
          .writeAsString(jsonEncode({...input(), 'appKey': 'other#app'}));
      final transport = FakeTransport((_) => throw StateError('not reached'));
      final service = DataService(transport: transport);
      final result = await service.preconditions(
          context: context,
          caseName: 'presence',
          environment: environment(),
          caseData: create(service),
          declarations: [none],
          metadata: {},
          dataInputPath: inputPath);
      expect(result.status, OperationStatus.failure);
      expect(transport.calls, isEmpty);
    });

    test(
        'duplicate/conflicting declaration and preparation mismatch rejected before management HTTP',
        () async {
      final transport = FakeTransport((_) => throw StateError('not reached'));
      final service = DataService(transport: transport);
      for (final entry in [
        ([none, friends], <String, Object?>{}),
        (
          [none],
          <String, Object?>{
            'data': {
              'prepare': [friends.toJson()]
            }
          }
        ),
        (
          [none],
          <String, Object?>{
            'data': {
              'prepare': [none.toJson(), none.toJson()]
            }
          }
        ),
      ]) {
        final result = await service.preconditions(
            context: context,
            caseName: 'presence',
            environment: environment(),
            caseData: create(service),
            declarations: entry.$1,
            metadata: entry.$2,
            dataInputPath: inputPath,
            prepare: true);
        expect(result.status, OperationStatus.failure);
      }
      expect(transport.calls, isEmpty);
    });
  });

  test(
      'HTTP transport sends JSON, encoded user path, auth and rejects redirect',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<void>();
    final subscription = server.listen((request) async {
      expect(request.uri.pathSegments.last, 'user /?#');
      expect(request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-token');
      expect(
          jsonDecode(await utf8.decoder.bind(request).join()), {'value': true});
      request.response.statusCode = 302;
      request.response.headers.set('location', '/redirected');
      await request.response.close();
      received.complete();
    });
    try {
      final response = await IoDataTransport().request(
          'POST',
          Uri(
              scheme: 'http',
              host: '127.0.0.1',
              port: server.port,
              pathSegments: ['users', 'user /?#']),
          body: {'value': true},
          bearerToken: 'test-token',
          timeout: const Duration(seconds: 2));
      expect(response.statusCode, 302);
      await received.future;
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  });
}
