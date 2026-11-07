import 'package:path/path.dart' as p;

typedef JsonObject = Map<String, Object?>;

enum OperationStatus { success, failure }

enum DevicePlatform { android, ios }

enum ContactState { none, friends }

abstract interface class JsonContract {
  JsonObject toJson();
  void validate();
}

Object? encodeContract(Object? value) {
  if (value is JsonContract) return value.toJson();
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Enum) return value.name;
  if (value is List) return value.map(encodeContract).toList();
  if (value is Map<String, Object?>) {
    return value.map((key, value) => MapEntry(key, encodeContract(value)));
  }
  return value;
}

Never _bad(String field, String expected, Object? actual) =>
    throw FormatException(
        'Invalid $field: expected $expected; got ${actual.runtimeType}');

JsonObject readObject(Object? value, [String field = 'object']) {
  if (value is! Map<String, Object?>) _bad(field, 'JSON object', value);
  for (final entry in value.entries) {
    _json(entry.value, '$field.${entry.key}');
  }
  return Map<String, Object?>.from(value);
}

Object? _json(Object? value, String field) {
  if (value == null || value is String || value is bool || value is int)
    return value;
  if (value is double && value.isFinite) return value;
  if (value is List<Object?>) {
    for (var i = 0; i < value.length; i++) {
      _json(value[i], '$field[$i]');
    }
    return value;
  }
  if (value is Map<String, Object?>) {
    for (final entry in value.entries) {
      _json(entry.value, '$field.${entry.key}');
    }
    return value;
  }
  _bad(field, 'JSON value', value);
}

class ContractReader {
  ContractReader(Object? value, this.type) : value = readObject(value, type);
  final JsonObject value;
  final String type;
  Object? get(String key) {
    if (!value.containsKey(key)) throw FormatException('Missing $type.$key');
    return value[key];
  }

  String string(String key, {bool nonempty = true}) {
    final item = get(key);
    if (item is! String || (nonempty && item.trim().isEmpty))
      _bad('$type.$key', 'nonempty string', item);
    return item;
  }

  String? nullableString(String key) => get(key) == null ? null : string(key);
  int integer(String key, {int? min, int? max}) {
    final item = get(key);
    if (item is! int ||
        (min != null && item < min) ||
        (max != null && item > max))
      _bad('$type.$key', 'integer within bounds', item);
    return item;
  }

  int? nullableInt(String key) => get(key) == null ? null : integer(key);
  bool boolean(String key) {
    final item = get(key);
    if (item is! bool) _bad('$type.$key', 'boolean', item);
    return item;
  }

  JsonObject object(String key) => readObject(get(key), '$type.$key');
  List<T> list<T>(String key, T Function(Object?) decode) {
    final item = get(key);
    if (item is! List<Object?>) _bad('$type.$key', 'list', item);
    return item.map(decode).toList(growable: false);
  }

  List<String> strings(String key, {bool nonempty = false}) {
    final result = list<String>(key, (item) {
      if (item is! String || item.trim().isEmpty)
        _bad('$type.$key', 'nonempty string items', item);
      return item;
    });
    if (nonempty && result.isEmpty) _bad('$type.$key', 'nonempty list', result);
    return result;
  }

  T enumeration<T extends Enum>(String key, List<T> values) {
    final item = string(key);
    for (final candidate in values) {
      if (candidate.name == item) return candidate;
    }
    _bad('$type.$key', 'one of ${values.map((value) => value.name).join(',')}',
        item);
  }

  DateTime date(String key) {
    final item = string(key);
    if (!RegExp(r'(Z|[+-][0-9]{2}:[0-9]{2})$').hasMatch(item))
      _bad('$type.$key', 'ISO 8601 with timezone', item);
    final result = DateTime.tryParse(item);
    if (result == null) _bad('$type.$key', 'ISO 8601 date', item);
    return result;
  }

  DateTime? nullableDate(String key) => get(key) == null ? null : date(key);
  String absolutePath(String key) {
    final result = string(key);
    if (!p.isAbsolute(result)) _bad('$type.$key', 'absolute path', result);
    return result;
  }
}

String _identifier(Object? value) {
  if (value is! String || value.trim().isEmpty)
    _bad('identifier', 'nonempty string', value);
  return value;
}

Map<String, T> _typedMap<T>(Object? value, T Function(Object?) decode) =>
    readObject(value).map((key, value) {
      _identifier(key);
      return MapEntry(key, decode(value));
    });

class OperationError implements JsonContract {
  const OperationError({
    required this.message,
    this.field,
    this.expected,
    this.actual,
  });
  final String message;
  final String? field;
  final Object? expected;
  final Object? actual;
  factory OperationError.fromJson(Object? value) {
    final r = ContractReader(value, 'OperationError');
    final result = OperationError(
      message: r.string('message'),
      field: r.nullableString('field'),
      expected: r.get('expected'),
      actual: r.get('actual'),
    );
    return result;
  }
  @override
  void validate() {
    OperationError.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'message': encodeContract(message),
        'field': encodeContract(field),
        'expected': encodeContract(expected),
        'actual': encodeContract(actual),
      };
}

class EvidenceRef implements JsonContract {
  const EvidenceRef({
    required this.path,
    this.location,
  });
  final String path;
  final String? location;
  factory EvidenceRef.fromJson(Object? value) {
    final r = ContractReader(value, 'EvidenceRef');
    final result = EvidenceRef(
      path: r.absolutePath('path'),
      location: r.nullableString('location'),
    );
    return result;
  }
  @override
  void validate() {
    EvidenceRef.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'path': encodeContract(path),
        'location': encodeContract(location),
      };
}

class FileRef implements JsonContract {
  const FileRef({
    required this.path,
    required this.sha256,
  });
  final String path;
  final String sha256;
  factory FileRef.fromJson(Object? value) {
    final r = ContractReader(value, 'FileRef');
    final result = FileRef(
      path: r.absolutePath('path'),
      sha256: r.string('sha256'),
    );
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(result.sha256))
      _bad('FileRef.sha256', 'lowercase SHA-256', result.sha256);
    return result;
  }
  @override
  void validate() {
    FileRef.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'path': encodeContract(path),
        'sha256': encodeContract(sha256),
      };
}

class AccountData implements JsonContract {
  const AccountData({
    required this.environment,
  });
  final JsonObject environment;
  factory AccountData.fromJson(Object? value) {
    final r = ContractReader(value, 'AccountData');
    final result = AccountData(
      environment: r.object('environment'),
    );
    return result;
  }
  @override
  void validate() {
    AccountData.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'environment': encodeContract(environment),
      };
}

class CaseDefinition implements JsonContract {
  const CaseDefinition({
    required this.name,
    required this.sourceYaml,
    required this.sourceJson,
    required this.yaml,
    required this.json,
    required this.requiredBindings,
  });
  final String name;
  final String sourceYaml;
  final String sourceJson;
  final FileRef yaml;
  final FileRef json;
  final List<String> requiredBindings;
  factory CaseDefinition.fromJson(Object? value) {
    final r = ContractReader(value, 'CaseDefinition');
    final result = CaseDefinition(
      name: r.string('name'),
      sourceYaml: r.absolutePath('sourceYaml'),
      sourceJson: r.absolutePath('sourceJson'),
      yaml: FileRef.fromJson(r.get('yaml')),
      json: FileRef.fromJson(r.get('json')),
      requiredBindings: r.strings('requiredBindings', nonempty: true),
    );
    if (result.requiredBindings.toSet().length !=
        result.requiredBindings.length)
      _bad('CaseDefinition.requiredBindings', 'unique bindings',
          result.requiredBindings);
    return result;
  }
  @override
  void validate() {
    CaseDefinition.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'name': encodeContract(name),
        'sourceYaml': encodeContract(sourceYaml),
        'sourceJson': encodeContract(sourceJson),
        'yaml': encodeContract(yaml),
        'json': encodeContract(json),
        'requiredBindings': encodeContract(requiredBindings),
      };
}

class CaseData implements JsonContract {
  const CaseData({
    required this.caseName,
    required this.attempt,
    required this.accounts,
    required this.initConfig,
    required this.input,
  });
  final String caseName;
  final int attempt;
  final Map<String, JsonObject> accounts;
  final JsonObject initConfig;
  final JsonObject input;
  factory CaseData.fromJson(Object? value) {
    final r = ContractReader(value, 'CaseData');
    final result = CaseData(
      caseName: r.string('caseName'),
      attempt: r.integer('attempt', min: 1),
      accounts: _typedMap(r.get('accounts'), readObject),
      initConfig: r.object('initConfig'),
      input: r.object('input'),
    );
    for (final account in result.accounts.values) {
      final a = ContractReader(account, 'CaseData.accounts');
      a.string('userId');
      a.string('userToken');
    }
    return result;
  }
  @override
  void validate() {
    CaseData.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'caseName': encodeContract(caseName),
        'attempt': encodeContract(attempt),
        'accounts': encodeContract(accounts),
        'initConfig': encodeContract(initConfig),
        'input': encodeContract(input),
      };
}

class PreconditionCheck implements JsonContract {
  const PreconditionCheck({
    required this.users,
    required this.expected,
    required this.actual,
    required this.satisfied,
    required this.checkedAt,
  });
  final List<String> users;
  final ContactState expected;
  final Map<String, bool>? actual;
  final bool satisfied;
  final DateTime checkedAt;
  factory PreconditionCheck.fromJson(Object? value) {
    final r = ContractReader(value, 'PreconditionCheck');
    final result = PreconditionCheck(
      users: r.strings('users'),
      expected: r.enumeration('expected', ContactState.values),
      actual: r.get('actual') == null
          ? null
          : _typedMap<bool>(r.get('actual'), (v) {
              if (v is! bool) _bad('actual', 'boolean', v);
              return v;
            }),
      satisfied: r.boolean('satisfied'),
      checkedAt: r.date('checkedAt'),
    );
    if (result.users.length != 2 || result.users.toSet().length != 2)
      _bad('PreconditionCheck.users', 'two distinct users', result.users);
    if (result.actual == null && result.satisfied)
      _bad('PreconditionCheck.satisfied', 'false when observation is absent',
          true);
    if (result.actual != null &&
        (result.actual!.keys
                .toSet()
                .difference(result.users.toSet())
                .isNotEmpty ||
            result.actual!.length != 2))
      _bad('PreconditionCheck.actual', 'both declared users', result.actual);
    return result;
  }
  @override
  void validate() {
    PreconditionCheck.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'users': encodeContract(users),
        'expected': encodeContract(expected),
        'actual': encodeContract(actual),
        'satisfied': encodeContract(satisfied),
        'checkedAt': encodeContract(checkedAt),
      };
}

class PreconditionResult implements JsonContract {
  const PreconditionResult({
    required this.caseName,
    required this.appKey,
    required this.checks,
    required this.setup,
    required this.check,
  });
  final String caseName;
  final String appKey;
  final List<PreconditionCheck> checks;
  final FileRef? setup;
  final FileRef check;
  factory PreconditionResult.fromJson(Object? value) {
    final r = ContractReader(value, 'PreconditionResult');
    final result = PreconditionResult(
      caseName: r.string('caseName'),
      appKey: r.string('appKey'),
      checks: r.list('checks', PreconditionCheck.fromJson),
      setup: r.get('setup') == null ? null : FileRef.fromJson(r.get('setup')),
      check: FileRef.fromJson(r.get('check')),
    );
    return result;
  }
  @override
  void validate() {
    PreconditionResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'caseName': encodeContract(caseName),
        'appKey': encodeContract(appKey),
        'checks': encodeContract(checks),
        'setup': encodeContract(setup),
        'check': encodeContract(check),
      };
}

class DeviceResult implements JsonContract {
  const DeviceResult({
    required this.platform,
    required this.instance,
    required this.deviceId,
    required this.observedState,
    required this.checkedAt,
    required this.ready,
  });
  final DevicePlatform platform;
  final String instance;
  final String? deviceId;
  final String observedState;
  final DateTime checkedAt;
  final bool ready;
  factory DeviceResult.fromJson(Object? value) {
    final r = ContractReader(value, 'DeviceResult');
    final result = DeviceResult(
      platform: r.enumeration('platform', DevicePlatform.values),
      instance: r.string('instance'),
      deviceId: r.nullableString('deviceId'),
      observedState: r.string('observedState'),
      checkedAt: r.date('checkedAt'),
      ready: r.boolean('ready'),
    );
    if (result.ready && result.deviceId == null)
      _bad('DeviceResult.deviceId', 'runtime ID for ready device', null);
    return result;
  }
  @override
  void validate() {
    DeviceResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'platform': encodeContract(platform),
        'instance': encodeContract(instance),
        'deviceId': encodeContract(deviceId),
        'observedState': encodeContract(observedState),
        'checkedAt': encodeContract(checkedAt),
        'ready': encodeContract(ready),
      };
}

class BuildResult implements JsonContract {
  const BuildResult({
    required this.platform,
    required this.architectures,
    required this.applicationId,
    required this.mode,
    required this.arguments,
    required this.artifact,
  });
  final DevicePlatform platform;
  final List<String> architectures;
  final String applicationId;
  final String mode;
  final List<String> arguments;
  final FileRef artifact;
  factory BuildResult.fromJson(Object? value) {
    final r = ContractReader(value, 'BuildResult');
    final result = BuildResult(
      platform: r.enumeration('platform', DevicePlatform.values),
      architectures: r.strings('architectures', nonempty: true),
      applicationId: r.string('applicationId'),
      mode: r.string('mode'),
      arguments: r.strings('arguments'),
      artifact: FileRef.fromJson(r.get('artifact')),
    );
    if (result.mode != 'debug') _bad('BuildResult.mode', 'debug', result.mode);
    return result;
  }
  @override
  void validate() {
    BuildResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'platform': encodeContract(platform),
        'architectures': encodeContract(architectures),
        'applicationId': encodeContract(applicationId),
        'mode': encodeContract(mode),
        'arguments': encodeContract(arguments),
        'artifact': encodeContract(artifact),
      };
}

class ForwardMapping implements JsonContract {
  const ForwardMapping({
    required this.serial,
    required this.hostPort,
    required this.devicePort,
  });
  final String serial;
  final int hostPort;
  final int devicePort;
  factory ForwardMapping.fromJson(Object? value) {
    final r = ContractReader(value, 'ForwardMapping');
    final result = ForwardMapping(
      serial: r.string('serial'),
      hostPort: r.integer('hostPort', min: 1, max: 65535),
      devicePort: r.integer('devicePort', min: 1, max: 65535),
    );
    return result;
  }
  @override
  void validate() {
    ForwardMapping.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'serial': encodeContract(serial),
        'hostPort': encodeContract(hostPort),
        'devicePort': encodeContract(devicePort),
      };
}

class Connection implements JsonContract {
  const Connection({
    required this.deviceId,
    required this.applicationId,
    required this.platform,
    required this.buildOperationId,
    required this.artifact,
    required this.endpoint,
    required this.token,
    required this.instanceId,
    required this.version,
    required this.state,
    required this.checkedAt,
    required this.startedAt,
    required this.processId,
    required this.forward,
    required this.usedBy,
    required this.invalidatedAt,
    required this.invalidatedReason,
  });
  final String deviceId;
  final String applicationId;
  final DevicePlatform platform;
  final String buildOperationId;
  final FileRef artifact;
  final String endpoint;
  final String token;
  final String instanceId;
  final int version;
  final String state;
  final DateTime checkedAt;
  final DateTime startedAt;
  final int? processId;
  final ForwardMapping? forward;
  final AttemptRef? usedBy;
  final DateTime? invalidatedAt;
  final String? invalidatedReason;
  factory Connection.fromJson(Object? value) {
    final r = ContractReader(value, 'Connection');
    final result = Connection(
      deviceId: r.string('deviceId'),
      applicationId: r.string('applicationId'),
      platform: r.enumeration('platform', DevicePlatform.values),
      buildOperationId: r.string('buildOperationId'),
      artifact: FileRef.fromJson(r.get('artifact')),
      endpoint: r.string('endpoint'),
      token: r.string('token'),
      instanceId: r.string('instanceId'),
      version: r.integer('version'),
      state: r.string('state'),
      checkedAt: r.date('checkedAt'),
      startedAt: r.date('startedAt'),
      processId: r.nullableInt('processId'),
      forward: r.get('forward') == null
          ? null
          : ForwardMapping.fromJson(r.get('forward')),
      usedBy:
          r.get('usedBy') == null ? null : AttemptRef.fromJson(r.get('usedBy')),
      invalidatedAt: r.nullableDate('invalidatedAt'),
      invalidatedReason: r.nullableString('invalidatedReason'),
    );
    if ((result.invalidatedAt == null) != (result.invalidatedReason == null))
      _bad('Connection.invalidatedReason',
          'paired invalidation time and reason', result.invalidatedReason);
    if ((result.platform == DevicePlatform.android) != (result.forward != null))
      _bad('Connection.forward', 'Android forward / iOS null', result.forward);
    final endpoint = Uri.tryParse(result.endpoint);
    if (endpoint == null || endpoint.scheme != 'http' || endpoint.host.isEmpty)
      _bad('Connection.endpoint', 'HTTP endpoint', result.endpoint);
    if (result.processId != null && result.processId! <= 0)
      _bad('Connection.processId', 'positive process ID', result.processId);
    return result;
  }
  @override
  void validate() {
    Connection.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'deviceId': encodeContract(deviceId),
        'applicationId': encodeContract(applicationId),
        'platform': encodeContract(platform),
        'buildOperationId': encodeContract(buildOperationId),
        'artifact': encodeContract(artifact),
        'endpoint': encodeContract(endpoint),
        'token': encodeContract(token),
        'instanceId': encodeContract(instanceId),
        'version': encodeContract(version),
        'state': encodeContract(state),
        'checkedAt': encodeContract(checkedAt),
        'startedAt': encodeContract(startedAt),
        'processId': encodeContract(processId),
        'forward': encodeContract(forward),
        'usedBy': encodeContract(usedBy),
        'invalidatedAt': encodeContract(invalidatedAt),
        'invalidatedReason': encodeContract(invalidatedReason),
      };
}

class LaunchResult implements JsonContract {
  const LaunchResult({
    required this.caseName,
    required this.roles,
  });
  final String caseName;
  final Map<String, Connection> roles;
  factory LaunchResult.fromJson(Object? value) {
    final r = ContractReader(value, 'LaunchResult');
    final result = LaunchResult(
      caseName: r.string('caseName'),
      roles: _typedMap(r.get('roles'), Connection.fromJson),
    );
    return result;
  }
  @override
  void validate() {
    LaunchResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'caseName': encodeContract(caseName),
        'roles': encodeContract(roles),
      };
}

class RequiredCheck implements JsonContract {
  const RequiredCheck({
    required this.binding,
    required this.recordIndices,
    required this.passed,
    required this.evidence,
  });
  final String binding;
  final List<int> recordIndices;
  final bool passed;
  final List<EvidenceRef> evidence;
  factory RequiredCheck.fromJson(Object? value) {
    final r = ContractReader(value, 'RequiredCheck');
    final result = RequiredCheck(
      binding: r.string('binding'),
      recordIndices: r.list<int>('recordIndices', (v) {
        if (v is! int || v < 0)
          _bad('recordIndices', 'nonnegative integers', v);
        return v;
      }),
      passed: r.boolean('passed'),
      evidence: r.list('evidence', EvidenceRef.fromJson),
    );
    return result;
  }
  @override
  void validate() {
    RequiredCheck.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'binding': encodeContract(binding),
        'recordIndices': encodeContract(recordIndices),
        'passed': encodeContract(passed),
        'evidence': encodeContract(evidence),
      };
}

class FinishResult implements JsonContract {
  const FinishResult({
    required this.success,
    required this.error,
  });
  final bool success;
  final String? error;
  factory FinishResult.fromJson(Object? value) {
    final r = ContractReader(value, 'FinishResult');
    final result = FinishResult(
      success: r.boolean('success'),
      error: r.nullableString('error'),
    );
    if (!result.success && result.error == null)
      _bad('FinishResult.error', 'failure reason', null);
    return result;
  }
  @override
  void validate() {
    FinishResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'success': encodeContract(success),
        'error': encodeContract(error),
      };
}

class AttemptRef implements JsonContract {
  const AttemptRef({
    required this.caseName,
    required this.attempt,
  });
  final String caseName;
  final int attempt;
  factory AttemptRef.fromJson(Object? value) {
    final r = ContractReader(value, 'AttemptRef');
    final result = AttemptRef(
      caseName: r.string('caseName'),
      attempt: r.integer('attempt', min: 1),
    );
    return result;
  }
  @override
  void validate() {
    AttemptRef.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'caseName': encodeContract(caseName),
        'attempt': encodeContract(attempt),
      };
}

class ExecutionResult implements JsonContract {
  const ExecutionResult({
    required this.caseName,
    required this.attempt,
    required this.definition,
    required this.launchOperationId,
    required this.verdict,
    required this.report,
    required this.required,
    required this.finish,
  });
  final String caseName;
  final int attempt;
  final CaseDefinition definition;
  final String? launchOperationId;
  final String verdict;
  final FileRef? report;
  final List<RequiredCheck> required;
  final Map<String, FinishResult> finish;
  factory ExecutionResult.fromJson(Object? value) {
    final r = ContractReader(value, 'ExecutionResult');
    final result = ExecutionResult(
      caseName: r.string('caseName'),
      attempt: r.integer('attempt', min: 1),
      definition: CaseDefinition.fromJson(r.get('definition')),
      launchOperationId: r.nullableString('launchOperationId'),
      verdict: r.string('verdict'),
      report:
          r.get('report') == null ? null : FileRef.fromJson(r.get('report')),
      required: r.list('required', RequiredCheck.fromJson),
      finish: _typedMap(r.get('finish'), FinishResult.fromJson),
    );
    if (!const ['是', '否', '未执行', '未完成'].contains(result.verdict))
      _bad('ExecutionResult.verdict', 'specified verdict', result.verdict);
    if (result.definition.name != result.caseName)
      _bad('ExecutionResult.caseName', 'definition name', result.caseName);
    if (result.verdict == '未执行' && result.report != null)
      _bad('ExecutionResult.report', 'null before interpreter starts',
          result.report);
    return result;
  }
  @override
  void validate() {
    ExecutionResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'caseName': encodeContract(caseName),
        'attempt': encodeContract(attempt),
        'definition': encodeContract(definition),
        'launchOperationId': encodeContract(launchOperationId),
        'verdict': encodeContract(verdict),
        'report': encodeContract(report),
        'required': encodeContract(required),
        'finish': encodeContract(finish),
      };
}

class ReportDependency implements JsonContract {
  const ReportDependency({
    required this.report,
    required this.evidence,
  });
  final String report;
  final EvidenceRef evidence;
  factory ReportDependency.fromJson(Object? value) {
    final r = ContractReader(value, 'ReportDependency');
    final result = ReportDependency(
      report: r.absolutePath('report'),
      evidence: EvidenceRef.fromJson(r.get('evidence')),
    );
    return result;
  }
  @override
  void validate() {
    ReportDependency.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'report': encodeContract(report),
        'evidence': encodeContract(evidence),
      };
}

class ReportingResult implements JsonContract {
  const ReportingResult({
    required this.summary,
    required this.statistics,
    required this.process,
    required this.attempts,
    required this.dependencies,
  });
  final FileRef summary;
  final FileRef statistics;
  final List<FileRef> process;
  final List<AttemptRef> attempts;
  final List<ReportDependency> dependencies;
  factory ReportingResult.fromJson(Object? value) {
    final r = ContractReader(value, 'ReportingResult');
    final result = ReportingResult(
      summary: FileRef.fromJson(r.get('summary')),
      statistics: FileRef.fromJson(r.get('statistics')),
      process: r.list('process', FileRef.fromJson),
      attempts: r.list('attempts', AttemptRef.fromJson),
      dependencies: r.list('dependencies', ReportDependency.fromJson),
    );
    return result;
  }
  @override
  void validate() {
    ReportingResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'summary': encodeContract(summary),
        'statistics': encodeContract(statistics),
        'process': encodeContract(process),
        'attempts': encodeContract(attempts),
        'dependencies': encodeContract(dependencies),
      };
}

class PathReason implements JsonContract {
  const PathReason({
    required this.path,
    required this.reason,
  });
  final String path;
  final String reason;
  factory PathReason.fromJson(Object? value) {
    final r = ContractReader(value, 'PathReason');
    final result = PathReason(
      path: r.absolutePath('path'),
      reason: r.string('reason'),
    );
    return result;
  }
  @override
  void validate() {
    PathReason.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'path': encodeContract(path),
        'reason': encodeContract(reason),
      };
}

class CleanupResult implements JsonContract {
  const CleanupResult({
    required this.deleted,
    required this.kept,
    required this.failed,
  });
  final List<String> deleted;
  final List<PathReason> kept;
  final List<PathReason> failed;
  factory CleanupResult.fromJson(Object? value) {
    final r = ContractReader(value, 'CleanupResult');
    final result = CleanupResult(
      deleted: r.strings('deleted'),
      kept: r.list('kept', PathReason.fromJson),
      failed: r.list('failed', PathReason.fromJson),
    );
    final paths = [
      ...result.deleted,
      ...result.kept.map((v) => v.path),
      ...result.failed.map((v) => v.path)
    ];
    if (paths.any((v) => !p.isAbsolute(v)) ||
        paths.toSet().length != paths.length)
      _bad('CleanupResult.paths', 'nonoverlapping absolute paths', paths);
    return result;
  }
  @override
  void validate() {
    CleanupResult.fromJson(toJson());
  }

  @override
  JsonObject toJson() => {
        'deleted': encodeContract(deleted),
        'kept': encodeContract(kept),
        'failed': encodeContract(failed),
      };
}

class OperationResult<T> implements JsonContract {
  const OperationResult(
      {required this.runId,
      required this.operationId,
      required this.status,
      required this.data,
      required this.errors,
      required this.evidence});
  final String? runId;
  final String operationId;
  final OperationStatus status;
  final T? data;
  final List<OperationError> errors;
  final List<EvidenceRef> evidence;
  bool get isSuccess => status == OperationStatus.success;

  factory OperationResult.fromJson(Object? value, T Function(Object?) decode) {
    final r = ContractReader(value, 'OperationResult');
    final result = OperationResult<T>(
      runId: r.nullableString('runId'),
      operationId: r.string('operationId'),
      status: r.enumeration('status', OperationStatus.values),
      data: r.get('data') == null ? null : decode(r.get('data')),
      errors: r.list('errors', OperationError.fromJson),
      evidence: r.list('evidence', EvidenceRef.fromJson),
    );
    result.validate();
    return result;
  }

  @override
  void validate() {
    _identifier(operationId);
    if (runId != null) _identifier(runId);
    if (isSuccess && (data == null || errors.isNotEmpty)) {
      _bad('OperationResult', 'success with data and no errors', status.name);
    }
    if (!isSuccess && errors.isEmpty) {
      _bad('OperationResult.errors', 'nonempty failure reasons', errors);
    }
    for (final error in errors) {
      error.validate();
    }
    for (final item in evidence) {
      item.validate();
    }
    final payload = data;
    if (payload is JsonContract) payload.validate();
    if (payload is List) {
      for (final item in payload) {
        if (item is JsonContract) item.validate();
      }
    }
  }

  @override
  JsonObject toJson() => {
        'runId': runId,
        'operationId': operationId,
        'status': status.name,
        'data': encodeContract(data),
        'errors': errors.map((v) => v.toJson()).toList(),
        'evidence': evidence.map((v) => v.toJson()).toList(),
      };
}

class ContractViolation implements Exception {
  const ContractViolation(
      {required this.producer,
      required this.consumer,
      required this.operationId,
      required this.field,
      required this.expected,
      required this.actual,
      required this.rework,
      required this.message,
      this.evidence = const []});
  final String producer;
  final String consumer;
  final String operationId;
  final String field;
  final Object? expected;
  final Object? actual;
  final String rework;
  final String message;
  final List<EvidenceRef> evidence;

  OperationError toOperationError() => OperationError(
      message: '$producer -> $consumer ($operationId): $message; redo $rework',
      field: field,
      expected: expected,
      actual: actual);
  JsonObject toJson() => {
        'producer': producer,
        'consumer': consumer,
        'operationId': operationId,
        'field': field,
        'expected': expected,
        'actual': actual,
        'rework': rework,
        'message': message,
        'evidence': evidence.map((v) => v.toJson()).toList(),
      };
  @override
  String toString() =>
      '$producer -> $consumer ($operationId): $field: $message; redo $rework';
}

T acceptOperation<T>(
  OperationResult<T> result, {
  required String runId,
  required String producer,
  required String consumer,
  required String rework,
  bool requireSuccess = true,
}) {
  void reject(String field, Object? expected, Object? actual, String message) {
    throw ContractViolation(
        producer: producer,
        consumer: consumer,
        operationId: result.operationId,
        field: field,
        expected: expected,
        actual: actual,
        rework: rework,
        message: message,
        evidence: result.evidence);
  }

  try {
    result.validate();
  } on FormatException catch (error) {
    reject('OperationResult', 'valid delivery contract', null, error.message);
  }
  if (result.runId != runId)
    reject('runId', runId, result.runId, 'Wrong run ownership');
  if (requireSuccess && !result.isSuccess) {
    reject('status', 'success', result.status.name, 'Producer did not succeed');
  }
  if (result.data == null)
    reject('data', 'delivery payload', null, 'No usable payload');
  return result.data as T;
}
