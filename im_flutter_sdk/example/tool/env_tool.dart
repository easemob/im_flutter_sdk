import 'dart:convert';
import 'dart:io';

const _placeholderPrefix = 'TODO';

class EnvPaths {
  EnvPaths(this.exampleDir);

  factory EnvPaths.fromScript() {
    return EnvPaths(File.fromUri(Platform.script).parent.parent);
  }

  final Directory exampleDir;

  File get configTemplate =>
      File('${exampleDir.path}/templates/config.local.example.json');
  File get envTemplate => File('${exampleDir.path}/templates/env.example.dart');
  File get localConfig => File('${exampleDir.path}/config.local.json');
  Directory get cacheDir => Directory('${exampleDir.path}/.env');
  File get activeEnv => File('${exampleDir.path}/lib/env.dart');
  File cachedEnv(String cluster) => File('${cacheDir.path}/env.$cluster.dart');
}

Future<void> main(List<String> args) async {
  final paths = EnvPaths.fromScript();
  final command = args.isEmpty ? 'help' : args.first;
  try {
    switch (command) {
      case 'ensure':
        await ensureLocalFiles(paths);
        break;
      case 'gettoken':
        await ensureLocalFiles(paths);
        final failures = await generateClusterEnvironments(paths);
        if (failures > 0) exitCode = 1;
        break;
      case 'use':
        if (args.length != 2) {
          throw const FormatException('Usage: env_tool.dart use <cluster>');
        }
        await ensureLocalFiles(paths);
        await activateCluster(paths, args[1]);
        break;
      case 'help':
      case '--help':
      case '-h':
        stdout.writeln('''
Usage:
  dart run tool/env_tool.dart ensure
  dart run tool/env_tool.dart gettoken
  dart run tool/env_tool.dart use <cluster>
''');
        break;
      default:
        throw FormatException('Unknown command: $command');
    }
  } catch (error) {
    stderr.writeln('env_tool: $error');
    exitCode = 1;
  }
}

Future<void> ensureLocalFiles(EnvPaths paths) async {
  await paths.cacheDir.create(recursive: true);
  await _copyIfMissing(paths.configTemplate, paths.localConfig);
  await _copyIfMissing(paths.envTemplate, paths.activeEnv);
}

Future<void> _copyIfMissing(File source, File target) async {
  if (await target.exists()) {
    stdout.writeln('Skip: ${target.path} already exists');
    return;
  }
  await target.parent.create(recursive: true);
  await target.writeAsString(await source.readAsString(), flush: true);
  await _restrictPermissions(target);
  stdout.writeln('Created: ${target.path}');
}

Future<int> generateClusterEnvironments(EnvPaths paths) async {
  final config = await _readJsonObject(paths.localConfig);
  final clusters = _asMap(config['clusters'], 'clusters');
  _validateConfigShape(config, clusters);
  final configuredDefaultCluster = config['defaultCluster'] as String?;
  final defaultCluster = _resolveDefaultCluster(
    configuredDefaultCluster,
    clusters,
  );
  _validateClusterAssignments(
    config,
    clusters,
    configuredDefaultCluster: configuredDefaultCluster,
    defaultCluster: defaultCluster,
  );
  final privateMode = config['enablePrivateConfig'] == true;
  final clustersToGenerate = privateMode
      ? <MapEntry<String, dynamic>>[
          MapEntry<String, dynamic>(defaultCluster, clusters[defaultCluster]),
        ]
      : clusters.entries.toList();
  final activeEnvironment = privateMode ? 'private' : defaultCluster;

  final tokenClient = TokenClient();
  var failures = 0;
  var defaultGenerated = false;
  try {
    for (final entry in clustersToGenerate) {
      final clusterName = entry.key;
      final environmentName = privateMode ? 'private' : clusterName;
      _validateClusterName(clusterName);
      final cluster = _asMap(entry.value, 'clusters.$clusterName');
      final missing = <String>[
        for (final key in const [
          'restApi',
          'appKey',
          'clientId',
          'clientSecret',
        ])
          if (_isPlaceholder(cluster[key])) key,
      ];
      if (missing.isNotEmpty) {
        stdout.writeln(
          '[$clusterName] skipped: missing ${missing.join(', ')}',
        );
        if (clusterName == defaultCluster) failures++;
        continue;
      }

      try {
        final appToken = await tokenClient.fetchAppToken(cluster);
        final accounts = await tokenClient.fetchUserTokens(
          clusterName: clusterName,
          defaultCluster: defaultCluster,
          configuredDefaultCluster: configuredDefaultCluster,
          cluster: cluster,
          config: config,
          appToken: appToken,
        );
        final environment = buildEnvironment(
          clusterName: clusterName,
          environmentName: environmentName,
          defaultCluster: defaultCluster,
          configuredDefaultCluster: configuredDefaultCluster,
          cluster: cluster,
          config: config,
          accounts: accounts,
        );
        final target = paths.cachedEnv(environmentName);
        await _atomicWrite(
          target,
          renderEnvironmentDart(environmentName, environment),
        );
        stdout.writeln(
          '[$environmentName] generated ${target.path} (${accounts.length} accounts)',
        );
        if (environmentName == activeEnvironment) defaultGenerated = true;
      } catch (error) {
        stderr.writeln('[$clusterName] failed: $error');
        failures++;
      }
    }
  } finally {
    tokenClient.close();
  }

  if (defaultGenerated) {
    await activateCluster(paths, activeEnvironment);
  }
  return failures;
}

Future<void> activateCluster(EnvPaths paths, String cluster) async {
  _validateClusterName(cluster);
  final source = paths.cachedEnv(cluster);
  if (!await source.exists()) {
    final available = await paths.cacheDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .map((entity) => entity.uri.pathSegments.last)
        .toList();
    throw FileSystemException(
      'No generated environment for "$cluster". Available: ${available.join(', ')}',
      source.path,
    );
  }
  final header =
      '// Active cluster: $cluster (${DateTime.now().toUtc().toIso8601String()})\n';
  await _atomicWrite(paths.activeEnv, '$header${await source.readAsString()}');
  stdout.writeln('Activated: $cluster -> ${paths.activeEnv.path}');
}

Map<String, Object?> buildEnvironment({
  required String clusterName,
  String? environmentName,
  required String defaultCluster,
  String? configuredDefaultCluster,
  required Map<String, dynamic> cluster,
  required Map<String, dynamic> config,
  required List<Map<String, Object?>> accounts,
}) {
  final environment = <String, Object?>{};
  environment.addAll(_optionalMap(config['chatOptions']));
  environment.addAll(_optionalMap(cluster['chatOptions']));
  environment.addAll({
    'cluster': environmentName ?? clusterName,
    'appKey': cluster['appKey'],
    'accounts': accounts,
    'groups': _resourcesForCluster(
      config['groups'],
      clusterName,
      defaultCluster,
      configuredDefaultCluster,
    ),
    'rooms': _resourcesForCluster(
      config['rooms'],
      clusterName,
      defaultCluster,
      configuredDefaultCluster,
    ),
  });

  if (config['enablePrivateConfig'] == true) {
    final imServer = config['imServer'] ?? config['msyncServer'];
    final requiredServers = <String, Object?>{
      'webSocketServer': config['webSocketServer'],
      'restServer': config['restServer'],
      'imServer': imServer,
    };
    final missing = requiredServers.entries
        .where((entry) => _isPlaceholder(entry.value))
        .map((entry) => entry.key)
        .toList();
    if (missing.isNotEmpty) {
      throw FormatException(
        'top-level private deployment configuration is missing ${missing.join(', ')}',
      );
    }
    environment['enableDNSConfig'] = false;
    environment.addAll(requiredServers);
    for (final key in const ['imPort', 'webSocketPort']) {
      final value = config[key];
      if (value is int && value > 0) environment[key] = value;
    }
  }
  return environment;
}

List<Map<String, Object?>> _resourcesForCluster(
  Object? raw,
  String clusterName,
  String defaultCluster,
  String? configuredDefaultCluster,
) {
  final values = raw is List ? raw : const [];
  return [
    for (final value in values)
      if (value is Map &&
          _itemCluster(
                value,
                configuredDefaultCluster: configuredDefaultCluster,
                defaultCluster: defaultCluster,
              ) ==
              clusterName)
        <String, Object?>{
          for (final entry in value.entries)
            if (entry.key != 'cluster') entry.key.toString(): entry.value,
        },
  ];
}

String renderEnvironmentDart(
  String clusterName,
  Map<String, Object?> environment,
) {
  return '''// Generated by tool/env_tool.dart from config.local.json.
// Cluster: $clusterName
// DO NOT EDIT. Run `make env-gettoken` or `make env-use CLUSTER=$clusterName`.
const Map<String, Object?> environment = ${_dartLiteral(environment)};
''';
}

String _dartLiteral(Object? value, [int depth = 0]) {
  final indent = '  ' * depth;
  final childIndent = '  ' * (depth + 1);
  if (value == null || value is num || value is bool) return '$value';
  if (value is String) return jsonEncode(value).replaceAll(r'$', r'\$');
  if (value is List) {
    if (value.isEmpty) return '<Object?>[]';
    return '<Object?>[\n$childIndent${value.map((item) => _dartLiteral(item, depth + 1)).join(',\n$childIndent')},\n$indent]';
  }
  if (value is Map) {
    if (value.isEmpty) return '<String, Object?>{}';
    final entries = value.entries.map(
      (entry) =>
          '${_dartLiteral(entry.key.toString())}: ${_dartLiteral(entry.value, depth + 1)}',
    );
    return '<String, Object?>{\n$childIndent${entries.join(',\n$childIndent')},\n$indent}';
  }
  throw ArgumentError('Unsupported environment value: ${value.runtimeType}');
}

class TokenClient {
  TokenClient({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<String> fetchAppToken(Map<String, dynamic> cluster) async {
    final response = await _postToken(
      cluster,
      <String, Object?>{
        'grant_type': 'client_credentials',
        'client_id': cluster['clientId'],
        'client_secret': cluster['clientSecret'],
      },
    );
    return _accessToken(response, 'app token');
  }

  Future<List<Map<String, Object?>>> fetchUserTokens({
    required String clusterName,
    required String defaultCluster,
    String? configuredDefaultCluster,
    required Map<String, dynamic> cluster,
    required Map<String, dynamic> config,
    required String appToken,
  }) async {
    final ttl = config['tokenTtl'];
    final rawAccounts =
        config['accounts'] is List ? config['accounts'] as List : const [];
    final accounts = <Map<String, Object?>>[];
    for (final rawAccount in rawAccounts) {
      if (rawAccount is! Map ||
          _itemCluster(
                rawAccount,
                configuredDefaultCluster: configuredDefaultCluster,
                defaultCluster: defaultCluster,
              ) !=
              clusterName) {
        continue;
      }
      final userId = rawAccount['id'];
      if (_isPlaceholder(userId)) {
        throw FormatException('invalid account id in cluster $clusterName');
      }
      final body = <String, Object?>{
        'username': userId,
        'grant_type': 'inherit',
        'autoCreateUser': true,
        if (ttl is int) 'ttl': ttl,
      };
      final response = await _postToken(cluster, body, bearer: appToken);
      accounts.add({
        for (final entry in rawAccount.entries)
          if (entry.key != 'cluster') entry.key.toString(): entry.value,
        'token': _accessToken(response, 'user token for $userId'),
      });
      stdout.writeln('[$clusterName] $userId token ok');
    }
    return accounts;
  }

  Future<Map<String, dynamic>> _postToken(
    Map<String, dynamic> cluster,
    Map<String, Object?> body, {
    String? bearer,
  }) async {
    final appKey = cluster['appKey'].toString().split('#');
    if (appKey.length != 2 || appKey.any((part) => part.isEmpty)) {
      throw FormatException(
        'invalid appKey, expected orgName#appName: ${cluster['appKey']}',
      );
    }
    final base = cluster['restApi'].toString().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/${appKey[0]}/${appKey[1]}/token');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    if (bearer != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }
    request.write(jsonEncode(body));
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw HttpException(
        'HTTP ${response.statusCode}: ${text.substring(0, text.length.clamp(0, 200).toInt())}',
        uri: uri,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map
          ? '${decoded['error'] ?? ''} ${decoded['error_description'] ?? ''}'
              .trim()
          : decoded.toString();
      throw HttpException('HTTP ${response.statusCode}: $error', uri: uri);
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  String _accessToken(Map<String, dynamic> response, String label) {
    final token = response['access_token'];
    if (token is! String || token.isEmpty) {
      throw FormatException('$label response missing access_token');
    }
    return token;
  }

  void close() => _httpClient.close(force: true);
}

Future<Map<String, dynamic>> _readJsonObject(File file) async {
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) {
    throw FormatException('${file.path} must contain a JSON object');
  }
  return Map<String, dynamic>.from(decoded);
}

Map<String, dynamic> _asMap(Object? value, String label) {
  if (value is! Map) throw FormatException('$label must be an object');
  return Map<String, dynamic>.from(value);
}

Map<String, Object?> _optionalMap(Object? value) {
  if (value is! Map) return <String, Object?>{};
  return <String, Object?>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
}

void _validateConfigShape(
  Map<String, dynamic> config,
  Map<String, dynamic> clusters,
) {
  if (config.containsKey('privateConfig')) {
    throw const FormatException(
      'privateConfig must not be nested; use top-level enablePrivateConfig and server fields',
    );
  }
  for (final entry in clusters.entries) {
    final cluster = _asMap(entry.value, 'clusters.${entry.key}');
    if (cluster.containsKey('privateConfig') ||
        cluster.containsKey('enablePrivateConfig')) {
      throw FormatException(
        'clusters.${entry.key} must not contain private configuration; '
        'use top-level enablePrivateConfig and server fields',
      );
    }
  }
}

String _resolveDefaultCluster(
  String? configuredDefaultCluster,
  Map<String, dynamic> clusters,
) {
  if (configuredDefaultCluster != null &&
      clusters.containsKey(configuredDefaultCluster)) {
    return configuredDefaultCluster;
  }
  if (clusters.length == 1) {
    final selected = clusters.keys.single;
    final reason = configuredDefaultCluster == null
        ? 'defaultCluster is not set'
        : 'defaultCluster "$configuredDefaultCluster" is not configured';
    stdout.writeln('[$selected] selected automatically: $reason');
    return selected;
  }
  if (clusters.isEmpty) {
    throw const FormatException('clusters must contain at least one entry');
  }
  throw const FormatException(
    'defaultCluster must name an entry in clusters when multiple clusters are configured',
  );
}

void _validateClusterAssignments(
  Map<String, dynamic> config,
  Map<String, dynamic> clusters, {
  required String? configuredDefaultCluster,
  required String defaultCluster,
}) {
  for (final field in const ['accounts', 'groups', 'rooms']) {
    final values = config[field];
    if (values is! List) continue;
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value is! Map) continue;
      final cluster = _itemCluster(
        value,
        configuredDefaultCluster: configuredDefaultCluster,
        defaultCluster: defaultCluster,
      );
      if (!clusters.containsKey(cluster)) {
        throw FormatException(
          '$field[$index].cluster must name an entry in clusters',
        );
      }
    }
  }
}

String _itemCluster(
  Map value, {
  required String? configuredDefaultCluster,
  required String defaultCluster,
}) {
  final raw = value['cluster'];
  if (raw == null) return defaultCluster;
  if (raw is! String || raw.isEmpty) {
    throw const FormatException(
        'cluster assignment must be a non-empty string');
  }
  if (configuredDefaultCluster != null &&
      configuredDefaultCluster != defaultCluster &&
      raw == configuredDefaultCluster) {
    return defaultCluster;
  }
  return raw;
}

bool _isPlaceholder(Object? value) {
  return value is! String ||
      value.isEmpty ||
      value.startsWith(_placeholderPrefix);
}

void _validateClusterName(String cluster) {
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(cluster)) {
    throw FormatException('Invalid cluster name: $cluster');
  }
}

Future<void> _atomicWrite(File target, String content) async {
  await target.parent.create(recursive: true);
  final temporary = File('${target.path}.tmp');
  await temporary.writeAsString(content, flush: true);
  await temporary.rename(target.path);
  await _restrictPermissions(target);
}

Future<void> _restrictPermissions(File file) async {
  if (!Platform.isWindows) {
    await Process.run('chmod', ['600', file.path]);
  }
}
