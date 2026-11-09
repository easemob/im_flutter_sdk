import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/ast.dart';
import 'package:path/path.dart' as p;

import 'contracts.dart';
import 'core.dart';

const _booleanOptions = <String>{
  'debugMode',
  'acceptInvitationAlways',
  'autoAcceptGroupInvitation',
  'requireDeliveryAck',
  'deleteMessagesAsExitGroup',
  'deleteMessagesAsExitChatRoom',
  'isChatRoomOwnerLeaveAllowed',
  'sortMessageByServerTime',
  'usingHttpsOnly',
  'serverTransfer',
  'isAutoDownloadThumbnail',
  'enableDNSConfig',
  'enableEmptyConversation',
  'useReplacedMessageContents',
  'enableTLS',
  'messagesReceiveCallbackIncludeSend',
  'regardImportMessagesAsRead',
  'workPathCopiable',
  'enableUserInfo',
};
const _stringOptions = <String>{
  'dnsUrl',
  'restServer',
  'imServer',
  'webSocketServer',
  'deviceName',
  'loginExtension',
  'apnsCertName',
  'pushKitCertName',
};
const _integerOptions = <String>{
  'imPort',
  'webSocketPort',
  'chatAreaCode',
  'osType',
  'dataSyncType',
};
const _managementKeys = <String>{'restApi', 'clientId', 'clientSecret'};
final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

class DataValidationException implements Exception {
  DataValidationException(this.error);

  final OperationError error;

  @override
  String toString() => error.message;
}

Never _invalid(String field, String expected, Object? actual) {
  throw DataValidationException(OperationError(
    message: 'Invalid data at $field; expected $expected.',
    field: field,
    expected: expected,
    actual: actual == null ? null : actual.runtimeType.toString(),
  ));
}

JsonObject _object(Object? value, String field) {
  if (value is! Map<String, Object?>) _invalid(field, 'JSON object', value);
  return value;
}

String _string(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    _invalid(field, 'nonempty string', value);
  }
  return value;
}

List<Object?> _list(Object? value, String field) {
  if (value is! List<Object?>) _invalid(field, 'list', value);
  return value;
}

JsonObject _copy(JsonObject value) =>
    jsonDecode(jsonEncode(value)) as Map<String, Object?>;

void _onlyKeys(JsonObject value, Set<String> keys, String field) {
  for (final key in value.keys) {
    if (!keys.contains(key))
      _invalid('$field.$key', 'supported field', value[key]);
  }
}

void _json(Object? value, String field, {bool identifiers = false}) {
  if (value == null || value is String || value is bool || value is int) return;
  if (value is double && value.isFinite) return;
  if (value is List<Object?>) {
    for (var i = 0; i < value.length; i++) {
      _json(value[i], '$field.$i', identifiers: identifiers);
    }
    return;
  }
  if (value is Map<String, Object?>) {
    for (final entry in value.entries) {
      if (identifiers && !_identifier.hasMatch(entry.key)) {
        _invalid('$field.${entry.key}', 'identifier object key', entry.key);
      }
      _json(entry.value, '$field.${entry.key}', identifiers: identifiers);
    }
    return;
  }
  _invalid(field, 'JSON value', value);
}

void _appKey(Object? value) {
  final parts = _string(value, 'environment.appKey').split('#');
  if (parts.length != 2 || parts.any((part) => part.trim().isEmpty)) {
    _invalid('environment.appKey', 'org#app', value);
  }
}

void _resources(JsonObject value, String key, Set<String> optional) {
  final resources = _list(value[key], 'environment.$key');
  for (var i = 0; i < resources.length; i++) {
    final resource = _object(resources[i], 'environment.$key.$i');
    _onlyKeys(resource, {'id', ...optional}, 'environment.$key.$i');
    _string(resource['id'], 'environment.$key.$i.id');
    for (final field in optional) {
      if (resource.containsKey(field) && resource[field] is! String) {
        _invalid('environment.$key.$i.$field', 'string', resource[field]);
      }
    }
  }
}

class DataHttpResponse {
  const DataHttpResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

abstract interface class DataTransport {
  Future<DataHttpResponse> request(
    String method,
    Uri uri, {
    JsonObject? body,
    String? bearerToken,
    required Duration timeout,
  });
}

class IoDataTransport implements DataTransport {
  @override
  Future<DataHttpResponse> request(
    String method,
    Uri uri, {
    JsonObject? body,
    String? bearerToken,
    required Duration timeout,
  }) async {
    final client = HttpClient()..findProxy = (_) => 'DIRECT';
    try {
      return await (() async {
        final request = await client.openUrl(method, uri);
        request.followRedirects = false;
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        if (bearerToken != null) {
          request.headers
              .set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
        }
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        final response = await request.close();
        return DataHttpResponse(
          response.statusCode,
          await utf8.decoder.bind(response).join(),
        );
      })()
          .timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }
}

class _Management {
  const _Management(this.input, this.base, this.org, this.app);

  final JsonObject input;
  final Uri base;
  final String org;
  final String app;

  Uri uri(List<String> parts) => base.replace(pathSegments: [
        ...base.pathSegments.where((segment) => segment.isNotEmpty),
        org,
        app,
        ...parts,
      ]);
}

class DataService {
  DataService(
      {DataTransport? transport,
      this.requestTimeout = const Duration(seconds: 20)})
      : transport = transport ?? IoDataTransport() {
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
          requestTimeout, 'requestTimeout', 'must be positive');
    }
  }

  final DataTransport transport;
  final Duration requestTimeout;

  JsonObject validateEnvironment(Object? value) {
    final environment = _object(value, 'environment');
    _json(environment, 'environment');
    _onlyKeys(
        environment,
        {
          'appKey',
          'accounts',
          'groups',
          'rooms',
          'ntpServers',
          ..._booleanOptions,
          ..._stringOptions,
          ..._integerOptions,
        },
        'environment');
    _appKey(environment['appKey']);
    for (final field in _booleanOptions) {
      if (environment.containsKey(field) && environment[field] is! bool) {
        _invalid('environment.$field', 'bool', environment[field]);
      }
    }
    for (final field in _stringOptions) {
      if (environment.containsKey(field) &&
          environment[field] != null &&
          environment[field] is! String) {
        _invalid('environment.$field', 'string or null', environment[field]);
      }
    }
    for (final field in _integerOptions) {
      if (environment.containsKey(field) &&
          environment[field] != null &&
          environment[field] is! int) {
        _invalid('environment.$field', 'int or null', environment[field]);
      }
    }
    if (environment['ntpServers'] != null) {
      final servers =
          _list(environment['ntpServers'], 'environment.ntpServers');
      for (var i = 0; i < servers.length; i++) {
        if (servers[i] is! String)
          _invalid('environment.ntpServers.$i', 'string', servers[i]);
      }
    }
    final accounts = _list(environment['accounts'], 'environment.accounts');
    if (accounts.isEmpty)
      _invalid('environment.accounts', 'nonempty account list', accounts);
    final ids = <String>{};
    for (var i = 0; i < accounts.length; i++) {
      final account = _object(accounts[i], 'environment.accounts.$i');
      _onlyKeys(account, {'id', 'token'}, 'environment.accounts.$i');
      final id = _string(account['id'], 'environment.accounts.$i.id');
      _string(account['token'], 'environment.accounts.$i.token');
      if (!ids.add(id))
        _invalid('environment.accounts.$i.id', 'unique account ID', id);
    }
    _resources(environment, 'groups', {'owner', 'name'});
    _resources(environment, 'rooms', {'name'});
    return _copy(environment);
  }

  _Management _management(JsonObject input) {
    _appKey(input['appKey']);
    for (final key in _managementKeys) {
      _string(input[key], 'dataInput.$key');
    }
    final rawUri = input['restApi'] as String;
    final uri = Uri.tryParse(rawUri);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      _invalid('dataInput.restApi',
          'HTTP(S) base URL without credentials, query or fragment', rawUri);
    }
    final parts = (input['appKey'] as String).split('#');
    return _Management(input, uri, parts[0], parts[1]);
  }

  Future<JsonObject> _readInput(String path, OperationContext context) async {
    final file = File(p.absolute(path));
    if (!await file.exists()) _invalid('dataInput', 'existing JSON file', null);
    // Private inputs must not be exposed to other local users.
    final chmod = await Process.run('chmod', ['600', file.path]);
    if (chmod.exitCode != 0)
      throw StateError('Cannot restrict data input permissions.');
    Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException {
      throw DataValidationException(OperationError(
        message: 'Data input is not valid JSON.',
        field: 'dataInput',
        expected: 'JSON object',
        actual: 'invalid JSON',
      ));
    }
    context.redactor.addFrom(decoded);
    return _object(decoded, 'dataInput');
  }

  Future<JsonObject> _request(
    OperationContext context,
    String method,
    Uri uri, {
    JsonObject? body,
    String? bearer,
    bool write = false,
  }) async {
    DataHttpResponse response;
    try {
      response = await transport
          .request(method, uri,
              body: body, bearerToken: bearer, timeout: requestTimeout)
          .timeout(requestTimeout);
    } catch (error) {
      throw DataValidationException(OperationError(
        message:
            '${write ? 'Management write outcome unknown; investigate before retrying' : 'Management request failed'} '
            '(${error is TimeoutException ? 'timeout' : error.runtimeType}).',
        field: write ? 'management.writeOutcome' : 'management.$method',
        expected: write ? 'known' : 'completed HTTP response',
        actual: write ? 'unknown' : null,
      ));
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final category = switch (response.statusCode) {
        401 => 'authentication',
        403 => 'permission',
        _ => 'HTTP'
      };
      throw DataValidationException(OperationError(
        message: 'Management $category failure: HTTP ${response.statusCode}.',
        field: write && response.statusCode >= 500
            ? 'management.writeOutcome'
            : 'management.$method.statusCode',
        expected: write && response.statusCode >= 500 ? 'known' : '2xx',
        actual: write && response.statusCode >= 500
            ? 'unknown'
            : response.statusCode,
      ));
    }
    if (write && response.statusCode == 204 && response.body.trim().isEmpty) {
      return <String, Object?>{};
    }
    try {
      final decoded = jsonDecode(response.body);
      context.redactor.addFrom(decoded);
      return _object(decoded, 'management.response');
    } on FormatException {
      throw DataValidationException(OperationError(
        message:
            'Management response is not valid JSON${write ? '; write outcome requires investigation' : ''}.',
        field: write ? 'management.writeOutcome' : 'management.response',
        expected: write ? 'known' : 'JSON object',
        actual: write ? 'unknown' : 'invalid JSON',
      ));
    } on DataValidationException {
      if (!write) rethrow;
      throw DataValidationException(OperationError(
        message:
            'Management write returned an invalid response; investigate before retrying.',
        field: 'management.writeOutcome',
        expected: 'known',
        actual: 'unknown',
      ));
    }
  }

  Future<String> _appToken(
      OperationContext context, _Management management) async {
    final response =
        await _request(context, 'POST', management.uri(['token']), body: {
      'grant_type': 'client_credentials',
      'client_id': management.input['clientId'],
      'client_secret': management.input['clientSecret'],
    });
    final token = _string(response['access_token'], 'management.access_token');
    context.redactor.add(token);
    return token;
  }

  Future<OperationResult<AccountData>> generate({
    required OperationContext context,
    required String inputPath,
    required String outputPath,
  }) async {
    final evidence = <EvidenceRef>[];
    try {
      if (context.runId != null)
        _invalid('runId', 'null for pre-CLI generation', context.runId);
      final input = await _readInput(inputPath, context);
      evidence.add(EvidenceRef(path: p.absolute(inputPath), location: null));
      final management = _management(input);
      final environment = <String, Object?>{
        for (final entry in input.entries)
          if (!_managementKeys.contains(entry.key)) entry.key: entry.value,
        'groups': input['groups'] ?? <Object?>[],
        'rooms': input['rooms'] ?? <Object?>[],
      };
      final accounts = _list(input['accounts'], 'dataInput.accounts');
      final provisional = <JsonObject>[];
      for (var i = 0; i < accounts.length; i++) {
        final account = _object(accounts[i], 'dataInput.accounts.$i');
        _onlyKeys(account, {'id'}, 'dataInput.accounts.$i');
        provisional.add({
          'id': _string(account['id'], 'dataInput.accounts.$i.id'),
          'token': 'validation-only'
        });
      }
      environment['accounts'] = provisional;
      validateEnvironment(environment);
      final appToken = await _appToken(context, management);
      final generated = <JsonObject>[];
      for (final account in provisional) {
        final response = await _request(
            context, 'POST', management.uri(['token']),
            bearer: appToken,
            body: {
              'grant_type': 'inherit',
              'username': account['id'],
              'autoCreateUser': false,
            });
        final token =
            _string(response['access_token'], 'management.access_token');
        context.redactor.add(token);
        generated.add({'id': account['id'], 'token': token});
      }
      environment['accounts'] = generated;
      final verified = validateEnvironment(environment);
      final source =
          'const Map<String, Object?> environment = ${_dartLiteral(verified)};\n';
      await writePrivateFile(p.absolute(outputPath), source);
      evidence.add(EvidenceRef(path: p.absolute(outputPath), location: null));
      return _success(context, AccountData(environment: verified), evidence);
    } catch (error) {
      return _failure<AccountData>(context, error, evidence);
    }
  }

  Future<OperationResult<AccountData>> load({
    required OperationContext context,
    required String sourcePath,
  }) async {
    final evidence = <EvidenceRef>[];
    File? loader;
    Process? process;
    try {
      final source = File(p.absolute(sourcePath));
      if (!await source.exists())
        _invalid('accounts.g.dart', 'generated data source', null);
      evidence.add(EvidenceRef(path: source.path, location: null));
      final chmod = await Process.run('chmod', ['600', source.path]);
      if (chmod.exitCode != 0)
        throw StateError('Cannot restrict generated source permissions.');
      await ensurePrivateDirectory(context.tmpDirectory.path);
      loader = File(p.join(
          context.tmpDirectory.path, 'load-${context.operationId}.dart'));
      await writePrivateFile(
          loader.path,
          "import 'dart:convert';\nimport '${source.uri}' as generated;\n"
          'void main() { print(jsonEncode(generated.environment)); }\n');
      process = await Process.start(Platform.resolvedExecutable, [loader.path]);
      final stdoutFuture = utf8.decoder.bind(process.stdout).join();
      final stderrFuture = utf8.decoder.bind(process.stderr).join();
      final loaded = await (() async {
        final code = await process!.exitCode;
        final output = await stdoutFuture;
        await stderrFuture;
        return (code, output);
      })()
          .timeout(const Duration(seconds: 20));
      final code = loaded.$1;
      final captured = loaded.$2;
      if (code != 0) {
        throw DataValidationException(OperationError(
            message:
                'Generated data source cannot be loaded (exit $code); source output suppressed.',
            field: 'accounts.g.dart',
            expected: 'loadable environment constant',
            actual: 'loader failure'));
      }
      Object? raw;
      try {
        raw = jsonDecode(captured);
      } on FormatException {
        throw DataValidationException(OperationError(
            message:
                'Generated data loader did not return one JSON object; output suppressed.',
            field: 'accounts.g.dart',
            expected: 'environment object',
            actual: 'invalid loader output'));
      }
      context.redactor.addFrom(raw);
      return _success(context,
          AccountData(environment: validateEnvironment(raw)), evidence);
    } catch (error) {
      return _failure<AccountData>(context, error, evidence);
    } finally {
      process?.kill(ProcessSignal.sigkill);
      if (loader != null && await loader.exists()) await loader.delete();
    }
  }

  void validateCaseMetadata(
      JsonObject metadata, List<PreconditionDecl> declarations,
      [Iterable<String>? accountSlots]) {
    final data = metadata.containsKey('data')
        ? _object(metadata['data'], 'data')
        : <String, Object?>{};
    final input = data.containsKey('input')
        ? _object(data['input'], 'data.input')
        : <String, Object?>{};
    final unique = data.containsKey('unique')
        ? _object(data['unique'], 'data.unique')
        : <String, Object?>{};
    _json(input, 'data.input', identifiers: true);
    for (final key in {...input.keys, ...unique.keys}) {
      if (!_identifier.hasMatch(key)) _invalid('data.$key', 'identifier', key);
      if (key == 'groups' || key == 'rooms')
        _invalid('data.$key', 'non-reserved business key', key);
      if (input.containsKey(key) && unique.containsKey(key))
        _invalid('data.unique.$key', 'key absent from data.input', key);
    }
    for (final entry in unique.entries) {
      if (entry.value is! String)
        _invalid('data.unique.${entry.key}', 'string prefix', entry.value);
    }
    final accounts = accountSlots?.toSet();
    final declared =
        _validateDeclarations(declarations, accounts, 'preconditions');
    final prepare = _prepareDeclarations(data, accounts);
    for (final condition in prepare) {
      final match = declared[_pair(condition.between)];
      if (match == null || match.state != condition.state) {
        _invalid('data.prepare', 'state matching a YAML precondition',
            condition.toJson());
      }
    }
  }

  void validateCaseData(CaseData actual, CaseData expected) {
    actual.validate();
    expected.validate();
    for (final key in expected.toJson().keys) {
      if (!_sameJson(actual.toJson()[key], expected.toJson()[key])) {
        _invalid('caseData.$key', 'same value as fixed inputs for this attempt',
            actual.toJson()[key]);
      }
    }
  }

  Future<void> validatePreconditions(
    PreconditionResult actual, {
    required String caseName,
    required CaseData caseData,
    required List<PreconditionDecl> declarations,
    required String checkPath,
    required DateTime notBefore,
  }) async {
    actual.validate();
    if (actual.caseName != caseName ||
        actual.appKey != caseData.initConfig['appKey']) {
      _invalid('preconditions.identity', 'current case and application',
          actual.toJson());
    }
    if (actual.setup != null || actual.checks.length != declarations.length) {
      _invalid('preconditions.checks',
          'fresh read-only check for every declaration', actual.toJson());
    }
    if (p.normalize(actual.check.path) != p.normalize(p.absolute(checkPath))) {
      _invalid('preconditions.check.path', 'current attempt check path',
          actual.check.path);
    }
    await verifyFileRef(actual.check);
    final stored = jsonDecode(await File(actual.check.path).readAsString());
    if (!_sameJson(
        stored, actual.checks.map((check) => check.toJson()).toList())) {
      _invalid('preconditions.check', 'file matching delivered checks', stored);
    }
    for (var i = 0; i < declarations.length; i++) {
      final declaration = declarations[i];
      final check = actual.checks[i];
      final users = declaration.between
          .map((role) => caseData.accounts[role]!['userId'] as String)
          .toList();
      final expected = declaration.state == 'none'
          ? ContactState.none
          : ContactState.friends;
      if (_pair(check.users) != _pair(users) ||
          check.expected != expected ||
          check.actual == null ||
          check.actual!.length != users.length ||
          !check.actual!.keys.toSet().containsAll(users) ||
          !_satisfied(check.actual!, expected) ||
          !check.satisfied ||
          check.checkedAt.isBefore(notBefore)) {
        _invalid(
            'preconditions.checks.$i',
            'fresh satisfied observation for the declared account pair',
            check.toJson());
      }
    }
  }

  OperationResult<CaseData> createCaseData({
    required OperationContext context,
    required JsonObject environment,
    required String caseName,
    required String caseBasename,
    required int attempt,
    required Map<String, String> accounts,
    required JsonObject metadata,
  }) {
    try {
      _string(context.runId, 'runId');
      _string(caseName, 'caseName');
      _string(caseBasename, 'caseBasename');
      if (attempt <= 0) _invalid('attempt', 'positive integer', attempt);
      final verified = validateEnvironment(environment);
      final mapping = readAccountSelection(accounts);
      final accountsById = <String, JsonObject>{
        for (final value in verified['accounts'] as List<Object?>)
          (_object(value, 'accounts')['id'] as String):
              _object(value, 'accounts'),
      };
      final selected = <String, JsonObject>{};
      for (final entry in mapping.entries) {
        final account = accountsById[entry.value];
        if (account == null) {
          _invalid('accounts.${entry.key}', 'account in fixed environment',
              entry.value);
        }
        selected[entry.key] = {
          'userId': account['id'],
          'userToken': account['token']
        };
      }
      // Declaration matching is checked during static parsing; input layout is
      // checked again here because restored snapshots remain untrusted input.
      final data = metadata.containsKey('data')
          ? _object(metadata['data'], 'data')
          : <String, Object?>{};
      final forInput = <String, Object?>{
        ...metadata,
        'data': {...data}..remove('prepare')
      };
      validateCaseMetadata(forInput, const [], mapping.keys);
      final input = data.containsKey('input')
          ? _copy(_object(data['input'], 'data.input'))
          : <String, Object?>{};
      final unique = data.containsKey('unique')
          ? _object(data['unique'], 'data.unique')
          : <String, Object?>{};
      for (final entry in unique.entries) {
        input[entry.key] =
            '${entry.value}${context.runId}-$caseBasename-$attempt-${entry.key}';
      }
      input['groups'] = verified['groups'];
      input['rooms'] = verified['rooms'];
      final initConfig = <String, Object?>{
        for (final entry in verified.entries)
          if (!{'accounts', 'groups', 'rooms'}.contains(entry.key))
            entry.key: entry.value,
      };
      return _success(
          context,
          CaseData(
              caseName: caseName,
              attempt: attempt,
              accounts: selected,
              initConfig: initConfig,
              input: input),
          const []);
    } catch (error) {
      return _failure<CaseData>(context, error, const []);
    }
  }

  Future<OperationResult<PreconditionResult>> preconditions({
    required OperationContext context,
    required String caseName,
    required JsonObject environment,
    required CaseData caseData,
    required List<PreconditionDecl> declarations,
    required JsonObject metadata,
    String? dataInputPath,
    bool prepare = false,
    String? checkOutputPath,
  }) async {
    final checks = <PreconditionCheck>[];
    final actions = <JsonObject>[];
    final observations = <JsonObject>[];
    final errors = <OperationError>[];
    final evidence = <EvidenceRef>[];
    final setupPath = p.join(context.tmpDirectory.path,
        'preconditions-setup-${context.operationId}.json');
    final checkPath = checkOutputPath ??
        p.join(context.tmpDirectory.path,
            'preconditions-check-${context.operationId}.json');
    String? appKey;
    bool validated = false;
    try {
      _string(context.runId, 'runId');
      final verified = validateEnvironment(environment);
      appKey = verified['appKey'] as String;
      if (caseData.caseName != caseName)
        _invalid('caseData.caseName', caseName, caseData.caseName);
      validateCaseMetadata(metadata, declarations, caseData.accounts.keys);
      final fixedAccounts = <String, Object?>{
        for (final account in verified['accounts'] as List<Object?>)
          (_object(account, 'accounts')['id'] as String):
              _object(account, 'accounts')['token'],
      };
      for (final entry in caseData.accounts.entries) {
        final userId = _string(
            entry.value['userId'], 'caseData.accounts.${entry.key}.userId');
        if (!fixedAccounts.containsKey(userId))
          _invalid(
              'caseData.accounts.${entry.key}.userId', 'fixed account', userId);
        if (entry.value['userToken'] != fixedAccounts[userId]) {
          _invalid('caseData.accounts.${entry.key}.userToken',
              'fixed account token', entry.value['userToken']);
        }
      }
      final accountPairs = <String>{};
      for (final declaration in declarations) {
        final users = declaration.between
            .map((role) => caseData.accounts[role]!['userId'] as String)
            .toList();
        if (users.toSet().length != 2)
          _invalid('preconditions.contacts.between', 'two different accounts',
              users);
        if (!accountPairs.add(_pair(users)))
          _invalid('preconditions.contacts.between',
              'one declaration per account pair', users);
      }
      validated = true;
      if (declarations.isNotEmpty) {
        if (dataInputPath == null)
          _invalid('dataInputPath',
              'management input for declared preconditions', null);
        final input = await _readInput(dataInputPath, context);
        final management = _management(input);
        if (input['appKey'] != appKey)
          _invalid('dataInput.appKey', 'same appKey as fixed environment',
              input['appKey']);
        final token = await _appToken(context, management);
        final data = metadata.containsKey('data')
            ? _object(metadata['data'], 'data')
            : <String, Object?>{};
        final allowed =
            _prepareDeclarations(data, caseData.accounts.keys.toSet());
        for (final declaration in declarations) {
          final users = declaration.between
              .map((role) => caseData.accounts[role]!['userId'] as String)
              .toList();
          final expected = declaration.state == 'none'
              ? ContactState.none
              : ContactState.friends;
          Map<String, bool>? actual;
          try {
            actual = await _observe(context, management, token, users);
            final before = Map<String, bool>.of(actual);
            observations.add({
              'users': users,
              'actual': before,
              'checkedAt': DateTime.now().toUtc().toIso8601String()
            });
            final canPrepare = prepare &&
                allowed.any((item) =>
                    _pair(item.between) == _pair(declaration.between));
            if (!_satisfied(actual, expected) && canPrepare) {
              if (expected == ContactState.friends) {
                actions.add({
                  'users': users,
                  'action': 'POST',
                  'before': before,
                  'status': 'started'
                });
                await _request(
                    context,
                    'POST',
                    management.uri(
                        ['users', users[0], 'contacts', 'users', users[1]]),
                    bearer: token,
                    write: true);
                actions.last['status'] = 'response_received';
              } else {
                for (var i = 0; i < users.length; i++) {
                  if (!actual![users[i]]!) continue;
                  actions.add({
                    'users': [users[i], users[1 - i]],
                    'action': 'DELETE',
                    'before': Map<String, bool>.of(actual),
                    'status': 'started'
                  });
                  await _request(
                      context,
                      'DELETE',
                      management.uri([
                        'users',
                        users[i],
                        'contacts',
                        'users',
                        users[1 - i]
                      ]),
                      bearer: token,
                      write: true);
                  actions.last['status'] = 'response_received';
                  actual = await _observe(context, management, token, users);
                }
              }
              actual = await _observe(context, management, token, users);
            }
            final satisfied = _satisfied(actual, expected);
            checks.add(PreconditionCheck(
                users: users,
                expected: expected,
                actual: actual,
                satisfied: satisfied,
                checkedAt: DateTime.now().toUtc()));
            if (!satisfied) {
              errors.add(OperationError(
                  message: 'Contact precondition is not satisfied.',
                  field: 'preconditions.contacts',
                  expected: declaration.state,
                  actual: actual));
            }
          } catch (error) {
            checks.add(PreconditionCheck(
                users: users,
                expected: expected,
                actual: null,
                satisfied: false,
                checkedAt: DateTime.now().toUtc()));
            errors.add(_error(context, error));
            // Unknown writes and failed observations must not trigger retries
            // or additional mutations through this preparation call.
            break;
          }
        }
      }
    } catch (error) {
      errors.add(_error(context, error));
    }
    FileRef? setupRef;
    FileRef? checkRef;
    try {
      if (prepare) {
        await writePrivateJson(
            setupPath,
            context.redactor.sanitize({
              'runId': context.runId,
              'operationId': context.operationId,
              'caseName': caseName,
              'declarations':
                  declarations.map((value) => value.toJson()).toList(),
              'observations': observations,
              'actions': actions,
              'checks': checks.map((value) => value.toJson()).toList(),
              'errors': errors.map((value) => value.toJson()).toList(),
            }));
        setupRef = await fileRef(setupPath);
        evidence.add(EvidenceRef(path: setupRef.path, location: null));
      }
      final serializedChecks = checks.map((value) => value.toJson()).toList();
      await writePrivateJson(
          checkPath,
          context.redactor.sanitize(checkOutputPath != null
              ? serializedChecks
              : {
                  'runId': context.runId,
                  'operationId': context.operationId,
                  'caseName': caseName,
                  'appKey': appKey,
                  'checks': serializedChecks,
                  'errors': errors.map((value) => value.toJson()).toList(),
                }));
      checkRef = await fileRef(checkPath);
      evidence.add(EvidenceRef(path: checkRef.path, location: null));
    } catch (error) {
      errors.add(_error(context, error));
      errors.add(OperationError(
          message: 'Precondition evidence could not be saved.',
          field: 'evidence',
          expected: 'readable evidence files',
          actual: null));
    }
    final result = validated &&
            appKey != null &&
            checkRef != null &&
            (!prepare || setupRef != null)
        ? PreconditionResult(
            caseName: caseName,
            appKey: appKey,
            checks: checks,
            setup: setupRef,
            check: checkRef)
        : null;
    return OperationResult(
        runId: context.runId,
        operationId: context.operationId,
        status:
            errors.isEmpty ? OperationStatus.success : OperationStatus.failure,
        data: result,
        errors: errors,
        evidence: evidence);
  }

  Future<Map<String, bool>> _observe(OperationContext context,
      _Management management, String token, List<String> users) async {
    final actual = <String, bool>{};
    for (var i = 0; i < users.length; i++) {
      final response = await _request(context, 'GET',
          management.uri(['users', users[i], 'contacts', 'users']),
          bearer: token);
      final contacts = _list(response['data'], 'management.contacts.data');
      for (var j = 0; j < contacts.length; j++) {
        _string(contacts[j], 'management.contacts.data.$j');
      }
      actual[users[i]] = contacts.contains(users[1 - i]);
    }
    return actual;
  }

  bool _satisfied(Map<String, bool> actual, ContactState expected) =>
      actual.values
          .every((value) => value == (expected == ContactState.friends));

  Map<String, PreconditionDecl> _validateDeclarations(
      List<PreconditionDecl> declarations,
      Set<String>? accounts,
      String field) {
    final pairs = <String, PreconditionDecl>{};
    for (final declaration in declarations) {
      if (declaration.kind != 'contacts' ||
          !{'none', 'friends'}.contains(declaration.state) ||
          declaration.between.length != 2 ||
          declaration.between.toSet().length != 2 ||
          declaration.between
              .any((slot) => !RegExp(r'^account[1-9][0-9]*$').hasMatch(slot)) ||
          (accounts != null && !accounts.containsAll(declaration.between))) {
        _invalid(
            field,
            'contacts between two available account slots, state none/friends',
            declaration.toJson());
      }
      final pair = _pair(declaration.between);
      if (pairs.containsKey(pair))
        _invalid(
            field, 'one declaration per account pair', declaration.toJson());
      pairs[pair] = declaration;
    }
    return pairs;
  }

  List<PreconditionDecl> _prepareDeclarations(
      JsonObject data, Set<String>? accounts) {
    final raw = data.containsKey('prepare')
        ? _list(data['prepare'], 'data.prepare')
        : const <Object?>[];
    final declarations = <PreconditionDecl>[];
    for (var i = 0; i < raw.length; i++) {
      final item = _object(raw[i], 'data.prepare.$i');
      _onlyKeys(item, {'contacts'}, 'data.prepare.$i');
      final contacts = _object(item['contacts'], 'data.prepare.$i.contacts');
      _onlyKeys(contacts, {'between', 'state'}, 'data.prepare.$i.contacts');
      final between =
          _list(contacts['between'], 'data.prepare.$i.contacts.between');
      declarations.add(PreconditionDecl(
          kind: 'contacts',
          between: [
            for (var j = 0; j < between.length; j++)
              _string(between[j], 'data.prepare.$i.contacts.between.$j')
          ],
          state: _string(contacts['state'], 'data.prepare.$i.contacts.state')));
    }
    _validateDeclarations(declarations, accounts, 'data.prepare');
    return declarations;
  }

  String _pair(List<String> roles) => jsonEncode(roles.toList()..sort());

  OperationResult<T> _success<T>(
          OperationContext context, T data, List<EvidenceRef> evidence) =>
      OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.success,
          data: data,
          errors: const [],
          evidence: evidence);

  OperationResult<T> _failure<T>(
          OperationContext context, Object error, List<EvidenceRef> evidence) =>
      OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.failure,
          data: null,
          errors: [_error(context, error)],
          evidence: evidence);

  OperationError _error(OperationContext context, Object error) {
    if (error is DataValidationException) {
      return OperationError.fromJson(
          context.redactor.sanitize(error.error.toJson()));
    }
    return OperationError(
        message: context.redactor
            .text('Data operation failed (${error.runtimeType}): $error'),
        field: 'data',
        expected: 'completed data operation',
        actual: error.runtimeType.toString());
  }
}

String _dartLiteral(Object? value) {
  if (value is String) return jsonEncode(value).replaceAll(r'$', r'\$');
  if (value == null || value is bool || value is num) return '$value';
  if (value is List<Object?>)
    return '<Object?>[${value.map(_dartLiteral).join(', ')}]';
  if (value is Map<String, Object?>) {
    return '<String, Object?>{${value.entries.map((entry) => '${_dartLiteral(entry.key)}: ${_dartLiteral(entry.value)}').join(', ')}}';
  }
  throw ArgumentError('Unsupported generated data value type.');
}

bool _sameJson(Object? left, Object? right) {
  if (left is Map<String, Object?> && right is Map<String, Object?>) {
    return left.length == right.length &&
        left.keys.every((key) =>
            right.containsKey(key) && _sameJson(left[key], right[key]));
  }
  if (left is List<Object?> && right is List<Object?>) {
    return left.length == right.length &&
        Iterable<int>.generate(left.length)
            .every((i) => _sameJson(left[i], right[i]));
  }
  return left == right;
}
