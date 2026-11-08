import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/ast.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/http_agent_client.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'contracts.dart';
import 'core.dart';
import 'data.dart';
import 'execution_validation.dart';
import 'http_client.dart';

export 'execution_validation.dart';

String? caseDisabledReason(JsonObject metadata) {
  if (!metadata.containsKey('selection')) return null;
  final selection = readObject(metadata['selection'], 'selection');
  if (selection.keys.any((key) => key != 'disabledReason')) {
    throw const FormatException(
        'selection only supports disabledReason; account declarations are not supported');
  }
  if (!selection.containsKey('disabledReason')) return null;
  final reason = selection['disabledReason'];
  if (reason is! String || reason.trim().isEmpty) {
    throw const FormatException('selection.disabledReason must be nonempty');
  }
  return reason;
}

class LoadedCase {
  LoadedCase(this.definition, this.flow, this.metadata);
  final CaseDefinition definition;
  final FlowSpec flow;
  final JsonObject metadata;
}

/// Owns static case validation; consumers use the same fixed definition.
class CaseLoader {
  CaseLoader(this.data);
  final DataService data;

  Future<LoadedCase> freeze(String sourceYaml, Directory directory) async {
    final source = p.normalize(p.absolute(sourceYaml));
    final basename = p.basenameWithoutExtension(source);
    if (!RegExp(r'^.+-multi-[a-z0-9]+(?:-[a-z0-9]+)*-(positive|negative)$')
        .hasMatch(basename)) {
      throw const FormatException(
          'Expected <version>-multi-<scene>-positive|negative.yaml');
    }
    final sourceJson = p.setExtension(source, '.json');
    final yamlText = await File(source).readAsString();
    final jsonText = await File(sourceJson).readAsString();
    final metadata = _object(jsonDecode(jsonText), 'case JSON');
    final doc = _document(yamlText, source, sourceJson);
    // Validate before publishing any fixed input.
    _validateCommands(metadata);
    final destination = Directory(p.join(directory.path, basename));
    if (await destination.exists()) {
      throw const FormatException('Fixed case destination already exists');
    }
    final yamlPath = p.join(destination.path, p.basename(source));
    final jsonPath = p.join(destination.path, p.basename(sourceJson));
    await writePrivateFile(yamlPath, yamlText);
    await writePrivateFile(jsonPath, jsonText);
    final flow = _parse(doc, jsonPath, yamlPath, metadata);
    final definition = CaseDefinition(
      name: flow.name,
      sourceYaml: source,
      sourceJson: sourceJson,
      yaml: await fileRef(yamlPath),
      json: await fileRef(jsonPath),
      requiredBindings: _required(metadata),
    );
    return LoadedCase(definition, flow, metadata);
  }

  Future<LoadedCase> load(CaseDefinition definition) async {
    await verifyFileRef(definition.yaml);
    await verifyFileRef(definition.json);
    final metadata = _object(
        jsonDecode(await File(definition.json.path).readAsString()),
        'case JSON');
    _validateCommands(metadata);
    final doc = _document(await File(definition.yaml.path).readAsString(),
        definition.sourceYaml, definition.sourceJson);
    final flow =
        _parse(doc, definition.json.path, definition.yaml.path, metadata);
    if (flow.name != definition.name ||
        jsonEncode(_required(metadata)) !=
            jsonEncode(definition.requiredBindings)) {
      throw const FormatException(
          'Fixed case identity or required bindings changed');
    }
    return LoadedCase(definition, flow, metadata);
  }

  JsonObject _document(String text, String source, String companion) {
    final doc = _object(_plain(loadYaml(text)), 'flow');
    if (doc.containsKey('runId')) {
      throw const FormatException('Static case must not contain runId');
    }
    final agents = _object(doc['agents'], 'agents');
    if (agents.length < 2)
      throw const FormatException('Multi-device case needs at least two roles');
    for (final entry in agents.entries) {
      if (!_identifier.hasMatch(entry.key))
        throw const FormatException('Invalid role identifier');
      final agent = _object(entry.value, 'agent');
      final script = agent['script'];
      if (script is! String ||
          script.isEmpty ||
          p.normalize(p.isAbsolute(script)
                  ? script
                  : p.join(p.dirname(source), script)) !=
              companion) {
        throw const FormatException(
            'Every role must use the same-name companion JSON');
      }
      if (agent.containsKey('env') ||
          agent.containsKey('token') ||
          agent.containsKey('endpoint')) {
        throw const FormatException(
            'Runtime environments and connections do not belong in static cases');
      }
    }
    return doc;
  }

  FlowSpec _parse(
      JsonObject doc, String jsonPath, String yamlPath, JsonObject metadata) {
    final agents = _object(doc['agents'], 'agents');
    doc['agents'] = {
      for (final entry in agents.entries)
        entry.key: {..._object(entry.value, 'agent'), 'script': jsonPath},
    };
    final flow = parseFlow(jsonEncode(doc), sourcePath: yamlPath);
    if (flow.flowTimeoutMs != null && flow.flowTimeoutMs! <= 0) {
      throw const FormatException('flowTimeoutMs must be a positive integer');
    }
    caseDisabledReason(metadata);
    data.validateCaseMetadata(metadata, flow.preconditions);
    final bindings = <String, List<bool>>{};
    void walk(List<Step> steps, bool inLoop) {
      for (final step in steps) {
        final binding = switch (step) {
          CmdStep s => s.as,
          WaitEventStep s => s.as,
          _ => null,
        };
        if (binding != null) {
          if (!_binding.hasMatch(binding))
            throw const FormatException('Invalid binding path');
          if (binding == 'global' ||
              (binding.startsWith('global.') &&
                  !binding.startsWith('global.biz.result.') &&
                  !binding.startsWith('global.biz.event.'))) {
            throw const FormatException(
                'Attempt to write a read-only global region');
          }
          bindings.putIfAbsent(binding, () => []).add(inLoop);
        }
        switch (step) {
          case ParallelStep s:
            for (final branch in s.branches.values) {
              walk(branch, inLoop);
            }
          case IfStep s:
            walk(s.thenSteps, inLoop);
            walk(s.elseSteps, inLoop);
          case ForStep s:
            walk(s.doSteps, true);
          case WhileStep s:
            walk(s.doSteps, true);
          case SetStep s:
            if (s.assignments.keys
                .any((key) => key == 'global' || key.startsWith('global.'))) {
              throw const FormatException('set cannot replace global data');
            }
          default:
            break;
        }
      }
    }

    walk(flow.steps, false);
    for (final name in _required(metadata)) {
      final nodes = bindings[name];
      if (nodes == null || nodes.length != 1 || nodes.single) {
        throw FormatException(
            'Required binding must identify one non-loop node: $name');
      }
    }
    return flow;
  }

  void _validateCommands(JsonObject metadata) {
    final steps = metadata['steps'];
    if (steps is! List) throw const FormatException('steps must be an array');
    final ids = <String>{};
    for (final raw in steps) {
      final step = _object(raw, 'command');
      if (step['id'] is! String ||
          (step['id'] as String).isEmpty ||
          !ids.add(step['id'] as String)) {
        throw const FormatException('Command IDs must be nonempty and unique');
      }
      if (step['api'] is! String ||
          (step['api'] as String).isEmpty ||
          (step['params'] != null && step['params'] is! Map)) {
        throw const FormatException(
            'Command needs api and optional object params');
      }
      if (step.containsKey('delayAfterMs'))
        throw const FormatException('Delay belongs in YAML');
    }
    _required(metadata);
  }

  List<String> _required(JsonObject metadata) {
    final raw = metadata['requiredBindings'];
    if (raw is! List ||
        raw.isEmpty ||
        raw.any((v) => v is! String || !_binding.hasMatch(v))) {
      throw const FormatException(
          'requiredBindings must be nonempty binding paths');
    }
    final values = raw.cast<String>();
    if (values.toSet().length != values.length)
      throw const FormatException('Duplicate required binding');
    return values;
  }
}

final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final _binding =
    RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(?:\.(?:[A-Za-z_][A-Za-z0-9_]*|[0-9]+))*$');

JsonObject _object(Object? value, String field) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw FormatException('$field must be an object');
  }
  return Map<String, Object?>.from(value);
}

Object? _plain(Object? value) => switch (value) {
      Map<Object?, Object?> m => {
          for (final e in m.entries) _yamlKey(e.key): _plain(e.value)
        },
      List<Object?> l => l.map(_plain).toList(),
      _ => value,
    };

String _yamlKey(Object? key) {
  if (key is! String) throw const FormatException('YAML keys must be strings');
  return key;
}

typedef ClientFactory = AgentClient Function(
    String role, Connection connection);
typedef AdmissionCheck = Future<OperationResult<PreconditionResult>> Function();

/// Owns execution lifecycle, while the interpreter owns flow semantics.
class ExecutionService {
  ExecutionService(
      {required this.loader,
      ClientFactory? clients,
      this.stopTimeout = const Duration(seconds: 3),
      this.finishTimeout = const Duration(seconds: 5),
      this.evidenceTimeout = const Duration(seconds: 10),
      void Function(AgentClient)? release})
      : clients = clients ??
            ((role, connection) => OwnedAgentClient(
                endpoint: Uri.parse(connection.endpoint),
                actor: role,
                token: connection.token)),
        release = release ??
            ((client) {
              if (client is OwnedAgentClient)
                client.close();
              else if (client is HttpAgentClient) client.close();
            }) {
    if (stopTimeout <= Duration.zero ||
        finishTimeout <= Duration.zero ||
        evidenceTimeout <= Duration.zero) {
      throw ArgumentError('Lifecycle timeouts must be positive');
    }
  }

  final CaseLoader loader;
  final ClientFactory clients;
  final void Function(AgentClient) release;
  final Duration stopTimeout, finishTimeout, evidenceTimeout;

  Future<OperationResult<ExecutionResult>> execute({
    required OperationContext context,
    required CaseDefinition definition,
    required CaseData caseData,
    required CaseData expectedCaseData,
    required Map<String, String> sourceOperations,
    required Map<String, DeviceResult> devices,
    required OperationResult<LaunchResult> launch,
    required Directory attemptDirectory,
    required String reportPath,
    required AdmissionCheck admission,
    required Future<void> Function() claimConnections,
    int? flowTimeoutMs,
  }) async {
    final errors = <OperationError>[];
    final evidence = <EvidenceRef>[];
    final finishes = <String, FinishResult>{};
    final handles = <String, AgentClient>{};
    final captured = <String, List<AgentEvent>>{};
    final requiredChecks = <RequiredCheck>[];
    FileRef? reportFile;
    var verdict = '未执行';
    var started = false, interrupted = false;
    ReportCollector? collector;
    GlobalData? global;
    Interpreter? interpreter;
    var acceptingTrace = true;
    final tracePath = p.join(attemptDirectory.path, 'trace.jsonl');
    Future<void> writes = Future.value();
    Object? traceFailure;
    var acceptingProducer = 'orchestration';
    var acceptingSource = context.operationId;
    var acceptingField = 'sourceOperations';
    var acceptingRework = 'inputs';
    Object? acceptingExpected = 'complete upstream operation identities';
    Object? acceptingActual;
    void accepting(String producer, String sourceKey, String field,
        Object? expected, Object? actual, String rework) {
      acceptingProducer = producer;
      acceptingSource = sourceOperations[sourceKey] ?? context.operationId;
      acceptingField = field;
      acceptingExpected = expected;
      acceptingActual = actual;
      acceptingRework = rework;
    }

    void error(Object e, {String? field}) {
      final detail = e is ContractViolation
          ? e.toOperationError()
          : e is DataValidationException
              ? e.error
              : OperationError(
                  message: '$e', field: field, expected: null, actual: null);
      errors.add(
          OperationError.fromJson(context.redactor.sanitize(detail.toJson())));
    }

    void trace(JsonObject record) {
      if (!acceptingTrace) return;
      final value = <String, Object?>{
        'runId': context.runId,
        'caseName': definition.name,
        'attempt': caseData.attempt,
        'operationId': context.operationId,
        ...record
      };
      final encoded = jsonEncode(context.redactor.sanitize(value));
      writes = writes.then((_) async {
        await File(tracePath)
            .writeAsString('$encoded\n', mode: FileMode.append, flush: true);
      }).catchError((Object e) {
        traceFailure = e;
      });
    }

    try {
      context.redactor.addFrom(caseData.toJson());
      context.redactor.addFrom(expectedCaseData.toJson());
      context.redactor.addFrom(launch.toJson());
      for (final key in [
        'caseData',
        'definition',
        'launch',
        ...devices.keys.map((role) => 'device.$role')
      ]) {
        if (sourceOperations[key]?.trim().isNotEmpty != true) {
          acceptingField = 'sourceOperations.$key';
          throw const FormatException('Missing upstream operation identity');
        }
      }
      if (sourceOperations['launch'] != launch.operationId) {
        acceptingField = 'sourceOperations.launch';
        acceptingExpected = launch.operationId;
        acceptingActual = sourceOperations['launch'];
        throw const FormatException(
            'Launch source operation identity mismatch');
      }
      accepting(
          'execution',
          'definition',
          'definition',
          'valid fixed definition and matching digests',
          null,
          'case definition');
      definition.validate();
      final basename = p.basenameWithoutExtension(definition.sourceYaml);
      final fixedDirectory =
          p.join(context.tmpDirectory.path, 'cases', basename);
      if (p.normalize(definition.yaml.path) !=
              p.normalize(
                  p.join(fixedDirectory, p.basename(definition.sourceYaml))) ||
          p.normalize(definition.json.path) !=
              p.normalize(
                  p.join(fixedDirectory, p.basename(definition.sourceJson)))) {
        acceptingField = 'definition.files';
        acceptingExpected = fixedDirectory;
        acceptingActual = [definition.yaml.path, definition.json.path];
        throw const FormatException(
            'Fixed definition belongs to another run or location');
      }
      final loaded = await loader.load(definition);
      final disabled = caseDisabledReason(loaded.metadata);
      if (disabled != null)
        throw FormatException('Case is disabled: $disabled');
      accepting('data', 'caseData', 'caseData',
          'fixed inputs for this case and attempt', null, 'data');
      loader.data.validateCaseData(caseData, expectedCaseData);
      accepting('launch', 'launch', 'launch',
          'same-run successful complete launch', launch.runId, 'launch');
      acceptOperation(launch,
          runId: context.runId ?? '',
          producer: 'launch',
          consumer: 'execution',
          rework: 'launch');
      if (context.runId == null ||
          caseData.caseName != definition.name ||
          caseData.attempt <= 0 ||
          launch.runId != context.runId ||
          launch.status != OperationStatus.success ||
          launch.data == null ||
          launch.data!.caseName != definition.name) {
        acceptingField = 'launch.caseName';
        acceptingExpected = definition.name;
        acceptingActual = launch.data?.caseName;
        throw const FormatException('Execution input ownership mismatch');
      }
      final roles = loaded.flow.agents.keys.toSet();
      for (final entry in <(String, String, Iterable<String>)>[
        ('orchestration', 'definition', devices.keys),
        ('launch', 'launch', launch.data!.roles.keys),
      ]) {
        final keys = entry.$3;
        accepting(entry.$1, entry.$2, 'roles', roles.toList(), keys.toList(),
            entry.$1);
        if (keys.toSet().difference(roles).isNotEmpty ||
            roles.difference(keys.toSet()).isNotEmpty) {
          throw const FormatException('Execution role set mismatch');
        }
      }
      accepting(
          'orchestration',
          'definition',
          'flowTimeoutMs',
          'positive integer milliseconds',
          flowTimeoutMs ?? loaded.flow.flowTimeoutMs,
          'inputs');
      if (flowTimeoutMs != null && flowTimeoutMs <= 0)
        throw const FormatException('Invalid timeout override');
      final timeout = flowTimeoutMs ?? loaded.flow.flowTimeoutMs;
      if (timeout == null || timeout <= 0)
        throw const FormatException('A positive flow timeout is required');
      for (final role in roles) {
        final c = launch.data!.roles[role]!;
        accepting('devices', 'device.$role', 'devices.$role',
            'valid ready device result', devices[role]!.toJson(), 'devices');
        devices[role]!.validate();
        if (!devices[role]!.ready)
          throw const FormatException('Device is not ready');
        accepting(
            'launch',
            'launch',
            'connections.$role',
            'unused accepting connection matching device',
            c.toJson(),
            'launch');
        c.validate();
        if (c.version != 2 || c.state != 'accepting') {
          throw FormatException(
              'Connection handshake is not accepting protocol 2: $role');
        }
        if (c.usedBy != null ||
            c.invalidatedAt != null ||
            c.deviceId != devices[role]!.deviceId ||
            c.platform != devices[role]!.platform ||
            !devices[role]!.ready) {
          throw FormatException('Connection unavailable or mismatched: $role');
        }
      }
      accepting(
          'orchestration',
          'definition',
          'devices',
          'distinct device per role',
          devices.values.map((value) => value.deviceId).toList(),
          'role mapping');
      if (devices.values
              .map((device) => '${device.platform.name}:${device.deviceId}')
              .toSet()
              .length !=
          roles.length) {
        throw const FormatException('Each role requires a different device');
      }
      accepting(
          'orchestration',
          'definition',
          'admission',
          'successful current state revalidation',
          null,
          'reported failing module');
      final admissionStartedAt = DateTime.now();
      final checkedPreconditions = await admission();
      final preconditions = acceptOperation(checkedPreconditions,
          runId: context.runId!,
          producer: 'data',
          consumer: 'execution',
          rework: 'preconditions');
      accepting('data', 'caseData', 'preconditions',
          'fresh valid precondition evidence', null, 'preconditions');
      acceptingSource = checkedPreconditions.operationId;
      await loader.data.validatePreconditions(preconditions,
          caseName: definition.name,
          caseData: caseData,
          declarations: loaded.flow.preconditions,
          checkPath: p.join(attemptDirectory.path, 'preconditions.json'),
          notBefore: admissionStartedAt);
      evidence.addAll(checkedPreconditions.evidence);
      evidence.add(EvidenceRef(path: preconditions.check.path, location: null));
      accepting('execution', 'definition', 'evidence',
          'writable private attempt evidence', tracePath, 'execution');
      await writePrivateFile(tracePath, '');
      evidence.add(EvidenceRef(path: tracePath, location: null));
      global = GlobalData({
        'device': {
          for (final role in roles)
            role: {
              'platform': devices[role]!.platform.name,
              'instance': devices[role]!.instance,
              'deviceId': devices[role]!.deviceId,
              'instanceId': launch.data!.roles[role]!.instanceId
            }
        },
        'account': caseData.accounts,
        'biz': {
          'config': {'initConfig': caseData.initConfig},
          'input': caseData.input,
          'result': <String, Object?>{},
          'event': <String, Object?>{}
        },
      }, outputRoots: const [
        'global.biz.result',
        'global.biz.event'
      ]);
      for (final role in roles) {
        handles[role] = clients(role, launch.data!.roles[role]!);
      }
      collector = ReportCollector()
        ..runId = context.runId!
        ..flowName = definition.name
        ..preconditions = loaded.flow.preconditions;
      interpreter = Interpreter(
          spec: loaded.flow,
          agents: handles,
          report: collector,
          global: global,
          onTrace: trace);
      // Claim only after all static and external checks, before the first call.
      await claimConnections();
      started = true;
      trace({
        'kind': 'execution_start',
        'flowTimeoutMs': timeout,
        'timeoutSource': flowTimeoutMs == null ? 'yaml' : 'cli',
        'stopTimeoutMs': stopTimeout.inMilliseconds,
        'finishTimeoutMs': finishTimeout.inMilliseconds,
        'evidenceTimeoutMs': evidenceTimeout.inMilliseconds
      });
      final running = interpreter.run();
      // Attach an error listener immediately, including after bounded waiting.
      final completion = running.then<Object?>((_) => null,
          onError: (Object e, StackTrace s) => e);
      final deadline = Object();
      final outcome = await completion.timeout(Duration(milliseconds: timeout),
          onTimeout: () => deadline);
      if (identical(outcome, deadline)) {
        interrupted = true;
        interpreter.stop();
        collector.add(StepRecord(
            kind: 'flow',
            context: 'flow',
            status: 'timeout',
            durationMs: timeout,
            reason:
                'Whole-flow deadline reached; external effects may continue'));
        error('Whole-flow timeout; external effects may continue');
        final afterStop =
            await completion.timeout(stopTimeout, onTimeout: () => deadline);
        if (identical(afterStop, deadline))
          error('Interpreter Future still pending after stop deadline');
        else if (afterStop != null) error(afterStop);
      } else if (outcome != null) {
        interrupted = true;
        interpreter.stop();
        error(outcome);
      }
    } catch (e) {
      if (!started) {
        final violation = e is ContractViolation
            ? e
            : ContractViolation(
                producer: acceptingProducer,
                consumer: 'execution',
                operationId: acceptingSource,
                field: e is DataValidationException
                    ? e.error.field ?? acceptingField
                    : acceptingField,
                expected: e is DataValidationException
                    ? e.error.expected
                    : acceptingExpected,
                actual: e is DataValidationException
                    ? e.error.actual
                    : acceptingActual,
                rework: acceptingRework,
                message: '$e',
                evidence: List.of(evidence));
        error(violation);
        try {
          final path = p.join(
              attemptDirectory.path, '${context.operationId}-acceptance.json');
          await writePrivateJson(
              path, context.redactor.sanitize(violation.toJson()));
          evidence.add(EvidenceRef(path: path, location: null));
        } catch (saveError) {
          error('Acceptance record could not be saved: $saveError');
        }
      } else {
        error(e);
      }
      interrupted = started;
      interpreter?.stop();
    } finally {
      if (started) {
        for (final entry in handles.entries) {
          try {
            await entry.value.finish().timeout(finishTimeout);
            finishes[entry.key] = FinishResult(success: true, error: null);
          } catch (e) {
            finishes[entry.key] = FinishResult(
                success: false, error: context.redactor.text('$e'));
            error('finish ${entry.key}: $e');
          }
        }
        for (final entry in handles.entries) {
          final events = <AgentEvent>[];
          captured[entry.key] = events;
          var collecting = true;
          try {
            await (() async {
              var cursor = 0;
              while (true) {
                final page =
                    await entry.value.pollEvents(cursor, limit: 200, waitMs: 0);
                if (!collecting || page.isEmpty) break;
                for (final event in page) {
                  if (event.seq <= cursor)
                    throw const FormatException('Non-increasing event cursor');
                  if (event.seq != cursor + 1) {
                    trace({
                      'kind': 'event_gap',
                      'role': entry.key,
                      'afterSeq': cursor,
                      'nextSeq': event.seq
                    });
                  }
                  cursor = event.seq;
                  events.add(event);
                }
                if (page.length < 200) break;
              }
            })()
                .timeout(evidenceTimeout);
          } catch (e) {
            error('event collection ${entry.key}: $e');
          } finally {
            collecting = false;
          }
          final eventPath =
              p.join(attemptDirectory.path, '${entry.key}-events.jsonl');
          try {
            final content = events
                .map((event) => jsonEncode(context.redactor.sanitize({
                      'instanceId': launch.data!.roles[entry.key]!.instanceId,
                      'seq': event.seq,
                      'source': event.source,
                      'payload': event.payload,
                    })))
                .join('\n');
            await writePrivateFile(
                eventPath, content.isEmpty ? '' : '$content\n');
            evidence.add(EvidenceRef(path: eventPath, location: null));
          } catch (e) {
            error('event evidence write ${entry.key}: $e');
          }
        }
        if (global != null)
          trace({'kind': 'data_reads', 'reads': global.reads});
        acceptingTrace = false;
        await writes;
        if (traceFailure != null) error('trace save: $traceFailure');
        try {
          final report =
              _object(jsonDecode(jsonEncode(collector!.toMap())), 'report');
          validateRawReport(report, context.runId!, definition.name);
          final steps = (report['steps'] as List).cast<JsonObject>();
          var evidenceComplete = true;
          for (final binding in definition.requiredBindings) {
            final indices = <int>[];
            final refs = <EvidenceRef>[];
            for (var i = 0; i < steps.length; i++) {
              if ((steps[i]['result'] as Map?)?['binding'] == binding)
                indices.add(i);
            }
            final passed = indices.length == 1 &&
                steps[indices.single]['status'] == 'passed';
            if (indices.isNotEmpty)
              refs.add(EvidenceRef(
                  path: reportPath, location: 'steps[${indices.first}]'));
            if (passed && steps[indices.single]['kind'] == 'cmd') {
              final actualResult = steps[indices.single]['result'];
              if (actualResult is! Map<String, Object?> ||
                  actualResult['success'] is! bool ||
                  actualResult['status'] is! String ||
                  actualResult['expectMatched'] is! bool) {
                evidenceComplete = false;
                error('Missing command result evidence for $binding');
              }
            }
            if (passed && steps[indices.single]['kind'] == 'wait_event') {
              final step = steps[indices.single];
              final result = step['result'] as Map;
              final role = step['agent'] as String;
              final matches = (captured[role] ?? []).where((e) =>
                  e.seq == result['seq'] &&
                  e.source == step['name'] &&
                  _deepEqual(e.payload, result['payload']));
              final eventPath =
                  p.join(attemptDirectory.path, '$role-events.jsonl');
              if (matches.length != 1 || !await File(eventPath).exists()) {
                evidenceComplete = false;
                error('Missing raw event evidence for $binding');
              } else {
                refs.add(EvidenceRef(
                    path: eventPath, location: 'seq=${result['seq']}'));
              }
            }
            requiredChecks.add(RequiredCheck(
                binding: binding,
                recordIndices: indices,
                passed: passed,
                evidence: refs));
          }
          if (await File(reportPath).exists())
            throw const FormatException(
                'Original report cannot be overwritten');
          await writePrivateJson(reportPath, context.redactor.sanitize(report));
          reportFile = await fileRef(reportPath);
          evidence.add(EvidenceRef(path: reportPath, location: null));
          verdict = interrupted || !evidenceComplete
              ? '未完成'
              : steps.any((s) =>
                          s['status'] == 'failed' ||
                          s['status'] == 'timeout') ||
                      requiredChecks.any((check) => !check.passed)
                  ? '否'
                  : '是';
          validateExecutionDelivery(
              ExecutionResult(
                  caseName: definition.name,
                  attempt: caseData.attempt,
                  definition: definition,
                  launchOperationId: launch.operationId,
                  verdict: verdict,
                  report: reportFile,
                  required: requiredChecks,
                  finish: finishes),
              report,
              runId: context.runId!);
        } catch (e) {
          error('report publication: $e');
          verdict = '未完成';
        }
      }
      for (final client in handles.values) {
        try {
          release(client);
        } catch (e) {
          error('client release: $e');
        }
      }
    }
    if ((verdict == '未执行' || verdict == '未完成') && errors.isEmpty)
      error('Case verdict: $verdict; see step and required-binding evidence');
    ExecutionResult? result = ExecutionResult(
        caseName: definition.name,
        attempt: caseData.attempt,
        definition: definition,
        launchOperationId: started ? launch.operationId : null,
        verdict: verdict,
        report: reportFile,
        required: requiredChecks,
        finish: finishes);
    try {
      result.validate();
    } catch (e) {
      error('Invalid input prevents a schema-valid execution payload: $e');
      result = null;
    }
    return OperationResult<ExecutionResult>(
        runId: context.runId,
        operationId: context.operationId,
        status:
            errors.isEmpty ? OperationStatus.success : OperationStatus.failure,
        data: result,
        errors: errors,
        evidence: evidence);
  }
}

bool _deepEqual(Object? left, Object? right) {
  if (left is Map<String, Object?> && right is Map<String, Object?>) {
    return left.length == right.length &&
        left.keys.every((key) =>
            right.containsKey(key) && _deepEqual(left[key], right[key]));
  }
  if (left is List<Object?> && right is List<Object?>) {
    return left.length == right.length &&
        Iterable<int>.generate(left.length)
            .every((i) => _deepEqual(left[i], right[i]));
  }
  return left == right;
}
