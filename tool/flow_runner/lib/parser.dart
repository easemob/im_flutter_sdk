/// YAML → FlowSpec parsing with static checks.
///
/// Static checks are deliberately shallow: agent references must be declared,
/// parallel blocks must not nest, and (unless disabled) every `cmd` id must
/// be a step id in the target agent's device script. Loaded scripts become
/// the runtime command library (protocol v2: the interpreter looks commands
/// up host-side and dispatches full content; agents never see the library).
library;

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'ast.dart';
import 'expect.dart';
import 'expr.dart';

class FlowParseError implements Exception {
  FlowParseError(this.message);

  final String message;

  @override
  String toString() => 'flow parse error: $message';
}

/// Options controlling static verification.
class ParseOptions {
  const ParseOptions({this.verifyCommandIds = true});

  /// When true, every cmd id must appear as a key in the target agent's
  /// device script. Disable for flows whose scripts are still drafts.
  final bool verifyCommandIds;
}

/// Parse a flow YAML document.
///
/// [sourcePath] is the YAML file's own location: relative `script:`/`env:`
/// paths inside the document resolve against its directory (so a flow and
/// its companion files move together); without it they resolve against the
/// process working directory. Absolute paths always pass through.
FlowSpec parseFlow(String yamlText,
    {ParseOptions options = const ParseOptions(), String? sourcePath}) {
  final Object? doc;
  try {
    doc = loadYaml(yamlText);
  } catch (e) {
    throw FlowParseError('invalid YAML: $e');
  }
  if (doc is! YamlMap) throw FlowParseError('top level must be a mapping');

  final version = _int(doc, 'version', fallback: 1);
  if (version != 1) throw FlowParseError('unsupported version: $version');

  final name = doc['name'] as String?;
  if (name == null || name.isEmpty) throw FlowParseError('missing "name"');

  final runId = doc['runId'] as String?;
  final flowTimeoutMs = doc['flowTimeoutMs'] as int?;

  final agents = <String, AgentDecl>{};
  final agentsNode = doc['agents'];
  if (agentsNode is! YamlMap || agentsNode.isEmpty) {
    throw FlowParseError('"agents" must be a non-empty mapping');
  }
  for (final entry in agentsNode.entries) {
    final role = entry.key as String;
    final a = entry.value;
    if (a is! YamlMap) throw FlowParseError('agent "$role" must be a mapping');
    // endpoint is optional in the YAML: a runtime --agents-file may supply
    // it (per-run dynamic credentials). The bin layer enforces that one of
    // the two sources provides it.
    Uri? endpoint;
    final endpointStr = a['endpoint'] as String?;
    if (endpointStr != null) {
      endpoint = Uri.tryParse(endpointStr);
      if (endpoint == null || !endpoint.hasScheme) {
        throw FlowParseError('agent "$role" has invalid endpoint "$endpointStr"');
      }
    }
    final token = a['token'] as String?;
    final scriptPath = a['script'] as String? ?? '';
    if (options.verifyCommandIds && scriptPath.isEmpty) {
      throw FlowParseError(
          'agent "$role" missing "script" (required for command id verification)');
    }
    final envPath = a['env'] as String?;
    agents[role] = AgentDecl(
      name: role,
      endpoint: endpoint,
      token: token,
      scriptPath: _resolvePath(scriptPath, sourcePath),
      envPath: envPath == null ? null : _resolvePath(envPath, sourcePath),
      meta: _plain(a['meta']) as Map<String, Object?>? ?? const {},
    );
  }

  final defaults = _parseDefaults(doc['defaults']);

  final preconditions = _parsePreconditions(doc['preconditions'], agents);

  final stepsNode = doc['steps'];
  if (stepsNode is! YamlList) throw FlowParseError('"steps" must be a list');
  final steps = parseSteps(stepsNode);

  final spec = FlowSpec(
    name: name,
    runId: runId,
    flowTimeoutMs: flowTimeoutMs,
    agents: agents,
    defaults: defaults,
    steps: steps,
    preconditions: preconditions,
  );

  _checkAgents(spec);
  _loadScriptsAndEnvs(spec);
  if (options.verifyCommandIds) {
    _verifyCommandIds(spec);
  }
  return spec;
}

Defaults _parseDefaults(Object? node) {
  if (node == null) return const Defaults();
  if (node is! YamlMap) throw FlowParseError('"defaults" must be a mapping');
  return Defaults(
    stepTimeoutMs: _int(node, 'stepTimeoutMs', fallback: 30000),
    onFail: node['onFail'] == null
        ? OnFail.continue_
        : OnFail.parse(node['onFail'] as String),
    skipOnFailedDeps: node['skipOnFailedDeps'] as bool? ?? true,
  );
}

/// Parse the optional top-level `preconditions` declaration list.
///
/// Shape (each entry is a single-key mapping):
///
///     preconditions:
///       - contacts: {between: [alice, bob], state: none}
///
/// The interpreter only parses/validates and reports these; execution is
/// the testing orchestration's job (flow_runner stays business-agnostic).
List<PreconditionDecl> _parsePreconditions(
    Object? node, Map<String, AgentDecl> agents) {
  if (node == null) return const [];
  if (node is! YamlList) {
    throw FlowParseError('"preconditions" must be a list');
  }
  final result = <PreconditionDecl>[];
  for (final raw in node) {
    if (raw is! YamlMap || raw.length != 1) {
      throw FlowParseError(
          'each precondition must be a single-key mapping (e.g. '
          '{contacts: {between: [a, b], state: none}})');
    }
    final kind = raw.keys.first as String;
    final value = raw[kind];
    if (kind != 'contacts') {
      throw FlowParseError('unknown precondition kind "$kind" '
          '(supported: contacts)');
    }
    if (value is! YamlMap) {
      throw FlowParseError('precondition "$kind" value must be a mapping');
    }
    final between = _plain(value['between']);
    if (between is! List || between.length != 2 ||
        between.any((r) => r is! String)) {
      throw FlowParseError(
          'precondition "contacts.between" must be exactly two role names');
    }
    for (final role in between) {
      if (!agents.containsKey(role)) {
        throw FlowParseError(
            'precondition references undeclared agent "$role"');
      }
    }
    final state = value['state'] as String?;
    if (state != 'none' && state != 'friends') {
      throw FlowParseError(
          'precondition "contacts.state" must be none|friends, got "$state"');
    }
    result.add(PreconditionDecl(
      kind: kind,
      between: List<String>.from(between),
      state: state!,
    ));
  }
  return result;
}

/// Parse a step list. [inParallel] guards the no-nesting rule.
List<Step> parseSteps(YamlList node, {bool inParallel = false}) {
  final steps = <Step>[];
  for (final raw in node) {
    steps.add(_parseStep(raw, inParallel: inParallel));
  }
  return steps;
}

Step _parseStep(Object? raw, {required bool inParallel}) {
  if (raw is! YamlMap) throw FlowParseError('each step must be a mapping');
  if (raw.isEmpty) throw FlowParseError('empty step');
  final kind = raw.keys.first as String;
  final value = raw[kind];

  switch (kind) {
    case 'cmd':
      if (value is! String) throw FlowParseError('cmd value must be a string');
      final agent = raw['agent'] as String?;
      if (agent == null) throw FlowParseError('cmd "$value" missing "agent"');
      final inputs = _plain(raw['inputs']);
      if (inputs != null && inputs is! Map<String, Object?>) {
        throw FlowParseError('cmd "$value" inputs must be a mapping');
      }
      return CmdStep(
        cmd: value,
        agent: agent,
        inputs: inputs as Map<String, Object?>?,
        as: raw['as'] as String?,
        timeoutMs: raw['timeoutMs'] as int?,
        onFail: raw['onFail'] == null
            ? null
            : OnFail.parse(raw['onFail'] as String),
        skipOnFailedDeps: raw['skipOnFailedDeps'] as bool?,
      );

    case 'wait_event':
      if (value is! String) {
        throw FlowParseError('wait_event value must be the event name string');
      }
      final agent = raw['agent'] as String?;
      if (agent == null) {
        throw FlowParseError('wait_event "$value" missing "agent"');
      }
      final match = _plain(raw['match']);
      if (match != null && match is! Map<String, Object?>) {
        throw FlowParseError('wait_event "$value" match must be a mapping');
      }
      return WaitEventStep(
        event: value,
        agent: agent,
        match: match as Map<String, Object?>? ?? const {},
        as: raw['as'] as String?,
        timeoutMs: raw['timeoutMs'] as int?,
        onFail: raw['onFail'] == null
            ? null
            : OnFail.parse(raw['onFail'] as String),
      );

    case 'parallel':
      if (inParallel) {
        throw FlowParseError('parallel blocks must not nest (first version)');
      }
      if (value is! YamlMap || value.isEmpty) {
        throw FlowParseError('parallel value must be a non-empty branch map');
      }
      final branches = <String, List<Step>>{};
      for (final entry in value.entries) {
        final branchName = entry.key as String;
        final branchSteps = entry.value;
        if (branchSteps is! YamlList) {
          throw FlowParseError(
              'parallel branch "$branchName" must be a step list');
        }
        branches[branchName] = parseSteps(branchSteps, inParallel: true);
      }
      return ParallelStep(branches: branches);

    case 'barrier':
      if (value is! String || value.isEmpty) {
        throw FlowParseError('barrier value must be a non-empty name');
      }
      return BarrierStep(value);

    case 'if':
      if (value is! String) throw FlowParseError('if value must be a string');
      final cond = parseExpr(value);
      final thenNode = raw['then'];
      if (thenNode is! YamlList) throw FlowParseError('if missing "then" list');
      final elseNode = raw['else'];
      if (elseNode != null && elseNode is! YamlList) {
        throw FlowParseError('if "else" must be a step list');
      }
      return IfStep(
        cond: cond,
        thenSteps: parseSteps(thenNode, inParallel: inParallel),
        elseSteps:
            elseNode == null ? const [] : parseSteps(elseNode, inParallel: inParallel),
      );

    case 'for':
      if (value is! String) throw FlowParseError('for value must be a string');
      final spec = _parseForSpec(value);
      final doNode = raw['do'];
      if (doNode is! YamlList) throw FlowParseError('for missing "do" list');
      return ForStep(
        varName: spec.$1,
        listRef: spec.$2,
        rangeStart: spec.$3,
        rangeEnd: spec.$4,
        doSteps: parseSteps(doNode, inParallel: inParallel),
      );

    case 'while':
      if (value is! String) throw FlowParseError('while value must be a string');
      final doNode = raw['do'];
      if (doNode is! YamlList) throw FlowParseError('while missing "do" list');
      return WhileStep(
        cond: parseExpr(value),
        doSteps: parseSteps(doNode, inParallel: inParallel),
      );

    case 'set':
      final assignments = _plain(value);
      if (assignments is! Map<String, Object?>) {
        throw FlowParseError('set value must be a mapping');
      }
      return SetStep(assignments);

    case 'delay':
      if (value is! int || value < 0) {
        throw FlowParseError('delay value must be a non-negative int (ms)');
      }
      return DelayStep(value);

    default:
      throw FlowParseError('unknown step kind "$kind"');
  }
}

/// Parse `x in $list` or `i in 1..5` into (varName, listRef, start, end).
(String, String?, int?, int?) _parseForSpec(String s) {
  final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.+)$').firstMatch(s);
  if (m == null) throw FlowParseError('bad for spec "$s"');
  final varName = m[1]!;
  final source = m[2]!.trim();
  final range = RegExp(r'^(\d+)\.\.(\d+)$').firstMatch(source);
  if (range != null) {
    final start = int.parse(range[1]!);
    final end = int.parse(range[2]!);
    if (end < start) {
      throw FlowParseError('bad range in "$s" (end < start)');
    }
    return (varName, null, start, end);
  }
  if (!isRef(source)) {
    throw FlowParseError(
        'for source "$source" must be a \$list reference');
  }
  return (varName, source, null, null);
}

void _checkAgents(FlowSpec spec) {
  void check(List<Step> steps) {
    for (final s in steps) {
      switch (s) {
        case final CmdStep c:
          if (!spec.agents.containsKey(c.agent)) {
            throw FlowParseError(
                'cmd "${c.cmd}" references undeclared agent "${c.agent}"');
          }
        case final WaitEventStep w:
          if (!spec.agents.containsKey(w.agent)) {
            throw FlowParseError(
                'wait_event "${w.event}" references undeclared agent "${w.agent}"');
          }
        case final ParallelStep p:
          for (final b in p.branches.values) {
            check(b);
          }
        case final IfStep i:
          check(i.thenSteps);
          check(i.elseSteps);
        case final ForStep f:
          check(f.doSteps);
        case final WhileStep w:
          check(w.doSteps);
        case BarrierStep():
        case SetStep():
        case DelayStep():
          break;
      }
    }
  }

  check(spec.steps);
}

/// Load every agent's device script (command library) and environment into
/// the spec. Script loading happens whenever a path is given (the
/// interpreter needs the content at runtime); expect blocks are statically
/// validated here so typos fail before any device is touched.
void _loadScriptsAndEnvs(FlowSpec spec) {
  for (final agent in spec.agents.values) {
    if (agent.scriptPath.isNotEmpty) {
      spec.scripts[agent.name] = _loadDeviceScript(agent);
    }
    final envPath = agent.envPath;
    if (envPath != null && envPath.isNotEmpty) {
      Object? json;
      try {
        json = jsonDecode(File(envPath).readAsStringSync());
      } on FileSystemException {
        throw FlowParseError(
            'agent "${agent.name}" env file not found: $envPath');
      } catch (e) {
        throw FlowParseError(
            'agent "${agent.name}" env file is not valid JSON: $e');
      }
      if (json is! Map) {
        throw FlowParseError(
            'agent "${agent.name}" env file must contain a JSON object');
      }
      spec.envs[agent.name] = Map<String, Object?>.from(json);
    }
  }
}

DeviceScript _loadDeviceScript(AgentDecl agent) {
  Object? json;
  try {
    json = jsonDecode(File(agent.scriptPath).readAsStringSync());
  } on FileSystemException {
    throw FlowParseError(
        'agent "${agent.name}" script not found: ${agent.scriptPath}');
  } catch (e) {
    throw FlowParseError(
        'agent "${agent.name}" script is not valid JSON: $e');
  }
  if (json is! Map) {
    throw FlowParseError(
        'agent "${agent.name}" script must contain a JSON object');
  }
  // Capture the promoted type: closures below do not inherit promotion.
  final Map<String, Object?> root = Map<String, Object?>.from(json);

  final stepsById = <String, Map<String, Object?>>{};
  final rawSteps = root['steps'];
  if (rawSteps is List) {
    for (final raw in rawSteps) {
      if (raw is! Map) {
        throw FlowParseError(
            'agent "${agent.name}" script: every step must be an object');
      }
      final id = raw['id'];
      if (id == null) continue; // unreferencable steps are allowed (AutoMode runs them)
      if (id is! String || id.isEmpty) {
        throw FlowParseError(
            'agent "${agent.name}" script: step id must be a non-empty string');
      }
      if (stepsById.containsKey(id)) {
        throw FlowParseError(
            'agent "${agent.name}" script: duplicate step id "$id"');
      }
      final step = Map<String, Object?>.from(raw);
      final api = step['api'];
      if (api is! String || api.isEmpty) {
        throw FlowParseError(
            'agent "${agent.name}" script: step "$id" missing "api"');
      }
      try {
        validateExpect(step['expect'], where: 'agent "${agent.name}" step "$id"');
      } on FormatException catch (e) {
        throw FlowParseError(e.message);
      }
      stepsById[id] = step;
    }
  }

  Map<String, Object?>? block(String key) => root[key] is Map
      ? Map<String, Object?>.from(root[key] as Map)
      : null;
  return DeviceScript(
    init: block('init'),
    login: block('login'),
    steps: stepsById,
  );
}

/// Verify every cmd id is a step id in the target agent's loaded device
/// script (typo guard; the interpreter would fail the same way at runtime).
void _verifyCommandIds(FlowSpec spec) {
  void check(List<Step> steps) {
    for (final s in steps) {
      switch (s) {
        case final CmdStep c:
          final script = spec.scripts[c.agent];
          if (script == null || !script.stepsById.containsKey(c.cmd)) {
            throw FlowParseError(
                'cmd "${c.cmd}" not found in agent "${c.agent}" script '
                '(${spec.agents[c.agent]!.scriptPath}); use --no-verify-commands '
                'to skip this check for drafts');
          }
        case final ParallelStep p:
          p.branches.values.forEach(check);
        case final IfStep i:
          check(i.thenSteps);
          check(i.elseSteps);
        case final ForStep f:
          check(f.doSteps);
        case final WhileStep w:
          check(w.doSteps);
        case WaitEventStep():
        case BarrierStep():
        case SetStep():
        case DelayStep():
          break;
      }
    }
  }

  check(spec.steps);
}

// ---------------------------------------------------------------------------
// Runtime agents-file injection (--agents-file)
// ---------------------------------------------------------------------------

/// Apply a runtime agents-file (per-run dynamic credentials) onto a parsed
/// flow spec, in place.
///
/// File format (produced by `testing/scripts/setup_devices`):
///
///     [ {"role": "alice", "endpoint": "http://127.0.0.1:62001",
///        "token": "…", "env": {"userId": "…", "userToken": "…"}, …} ]
///
/// Semantics per role (matched by name against the YAML `agents` mapping):
/// - `endpoint`: file wins over the YAML declaration; error if neither has one.
/// - `token`: file wins over the YAML declaration.
/// - `env`: shallow-merged over the agent's env-file content (file wins).
/// - YAML roles with no matching entry keep their declarations untouched
///   (endpoints that came from the YAML remain valid).
/// - File entries whose role is not declared in the YAML are **ignored**:
///   an agents-file describes every started device, while a single flow may
///   use only a subset. The skipped role names are returned so the caller
///   can surface a hint (a typo'd role shows up as the declared agent
///   missing its endpoint instead).
Set<String> applyAgentsFile(FlowSpec spec, String jsonText,
    {String? sourcePath}) {
  final Object? json;
  try {
    json = jsonDecode(jsonText);
  } catch (e) {
    throw FlowParseError('agents-file is not valid JSON: $e');
  }
  final List entries;
  if (json is List) {
    entries = json;
  } else if (json is Map && json['agents'] is List) {
    entries = json['agents'] as List;
  } else {
    throw FlowParseError(
        'agents-file must be a JSON array (or {"agents": [...]})');
  }

  final skipped = <String>{};
  for (final raw in entries) {
    if (raw is! Map) {
      throw FlowParseError('agents-file: every entry must be an object');
    }
    final role = raw['role'];
    if (role is! String || role.isEmpty) {
      throw FlowParseError('agents-file: entry missing "role"');
    }
    final decl = spec.agents[role];
    if (decl == null) {
      // The file describes every started device; the flow may use a subset.
      skipped.add(role);
      continue;
    }

    Uri? endpoint = decl.endpoint;
    final endpointStr = raw['endpoint'] as String?;
    if (endpointStr != null && endpointStr.isNotEmpty) {
      endpoint = Uri.tryParse(endpointStr);
      if (endpoint == null || !endpoint.hasScheme) {
        throw FlowParseError(
            'agents-file role "$role" has invalid endpoint "$endpointStr"');
      }
    }
    if (endpoint == null) {
      throw FlowParseError(
          'agent "$role" has no endpoint (neither in the YAML nor in the '
          'agents-file)');
    }
    final token = (raw['token'] as String?) ?? decl.token;

    final fileEnv = raw['env'];
    if (fileEnv != null && fileEnv is! Map) {
      throw FlowParseError('agents-file role "$role": "env" must be an object');
    }
    final mergedEnv = <String, Object?>{}
      ..addAll(spec.envs[role] ?? const {})
      ..addAll(fileEnv == null
          ? const <String, Object?>{}
          : Map<String, Object?>.from(fileEnv));

    spec.agents[role] = AgentDecl(
      name: decl.name,
      endpoint: endpoint,
      token: token,
      scriptPath: decl.scriptPath,
      envPath: decl.envPath,
      meta: decl.meta,
    );
    if (mergedEnv.isNotEmpty) spec.envs[role] = mergedEnv;
  }
  return skipped;
}

// ---------------------------------------------------------------------------
// YAML → plain Dart helpers
// ---------------------------------------------------------------------------

int _int(YamlMap node, String key, {required int fallback}) {
  final v = node[key];
  return v is int ? v : fallback;
}

/// Resolve a possibly-relative path against the flow file's directory.
String _resolvePath(String path, String? sourcePath) {
  if (path.isEmpty || path.startsWith('/') || sourcePath == null) {
    return path;
  }
  final base = File(sourcePath).parent.path;
  return base.isEmpty ? path : '$base/$path';
}

/// Convert a YAML node into plain Dart objects (YamlMap/YamlList are views).
Object? _plain(Object? node) {
  if (node is YamlMap) {
    return node.map((k, v) => MapEntry(k as String, _plain(v)));
  }
  if (node is YamlList) {
    return node.map(_plain).toList();
  }
  return node;
}
