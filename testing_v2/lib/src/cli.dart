import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'build.dart';
import 'contracts.dart';
import 'core.dart';
import 'data.dart';
import 'devices.dart';
import 'execution.dart';
import 'launch.dart';
import 'reporting.dart';
import 'cleanup.dart';
import 'state.dart';

class TestingCli {
  TestingCli(
      {required this.root,
      DataService? data,
      DeviceService? devices,
      BuildService? builds,
      LaunchService? launches,
      this.output = print})
      : data = data ?? DataService(),
        devices = devices ?? DeviceService() {
    this.builds = builds ??
        BuildService(
            repository: root.parent,
            buildRoot: Directory(p.join(root.path, 'build')));
    this.launches =
        launches ?? LaunchService(devices: this.devices, builds: this.builds);
    loader = CaseLoader(this.data);
    store = RunStore(root);
  }
  final Directory root;
  final DataService data;
  final DeviceService devices;
  final void Function(String) output;
  late final BuildService builds;
  late final LaunchService launches;
  late final CaseLoader loader;
  late final RunStore store;
  final redactor = SecretRedactor();
  final _leases = <RunLease>[];
  String? _activeRunId;

  ArgParser get parser {
    final parser = ArgParser()..addFlag('help', abbr: 'h', negatable: false);
    for (final name in [
      'prepare',
      'devices',
      'build',
      'launch',
      'run',
      'report',
      'clean',
      'all'
    ]) {
      final command = ArgParser()
        ..addFlag('help', abbr: 'h', negatable: false)
        ..addOption('run-id',
            help: 'Use this existing run; never select the latest run.')
        ..addOption('cases',
            help: 'Private ordered case-selection JSON; creates a new run.')
        ..addOption('data-input',
            help: 'Private management input JSON for declared preconditions.')
        ..addOption('platform', allowed: ['android', 'ios'])
        ..addOption('instance', help: 'Explicit AVD name or iOS UDID.')
        ..addOption('application-id',
            help: 'Application identifier for uninstall.')
        ..addOption('build',
            help:
                'Registered build operation ID; mandatory if selection is ambiguous.')
        ..addOption('build-result',
            help:
                'External build result JSON to verify and copy into this run.')
        ..addOption('launch',
            help: 'Complete launch operation ID; mandatory for run.')
        ..addOption('flow-timeout-ms',
            help: 'Positive whole-flow timeout override.')
        ..addMultiOption('type',
            allowed: ['cache', 'logs', 'build', 'reports', 'all'],
            help: 'Explicit cleanup types; default is no cleanup.');
      parser.addCommand(name, command);
    }
    return parser;
  }

  Future<int> run(List<String> args) async {
    RunState? state;
    var success = false;
    try {
      final parsed = parser.parse(args);
      final command = parsed.command;
      if (parsed['help'] == true ||
          command == null ||
          command['help'] == true) {
        _help(command?.name);
        return 0;
      }
      _validateOptions(command);
      final name = command.name!;
      final runId = command['run-id'] as String?;
      final casesFile = command['cases'] as String?;
      if (runId != null && casesFile != null)
        throw const FormatException(
            '--cases and --run-id are mutually exclusive');
      if (name == 'all' && (casesFile == null || runId != null))
        throw const FormatException(
            'all requires --cases and creates a new run');
      if (name == 'prepare' && runId == null && casesFile == null)
        throw const FormatException('prepare requires --cases or --run-id');
      if (!['all', 'prepare', 'devices', 'build'].contains(name) &&
          runId == null) throw const FormatException('--run-id is required');
      if (runId != null) {
        _leases.add(await store.lock('run:$runId'));
        state = await store.load(runId);
        redactor.addFrom(state.json);
        if (state.json['status'] != 'stopped' &&
            !['report', 'clean'].contains(name)) {
          throw const FormatException(
              'Run has an unconfirmed interrupted operation; inspect evidence before continuing');
        }
      } else {
        state = await store.create(name == 'devices' || name == 'build'
            ? name
            : await _selectionScene(casesFile!));
        _leases.add(await store.lock('run:${state.id}'));
        output('runId=${state.id}');
      }
      if (!['report', 'clean'].contains(name)) {
        for (final entry in state.cases) {
          final loaded =
              await loader.load(CaseDefinition.fromJson(entry['definition']));
          readAccountSelection(entry['accounts']);
          readDeviceSelection(entry['devices'], loaded.flow.agents.keys);
          final disabled = caseDisabledReason(loaded.metadata);
          if (disabled != null)
            throw FormatException('Case is disabled: $disabled');
        }
      }
      _activeRunId = state.id;
      // Reporting and cleanup must retain uncertainty left by interrupted work.
      final previousState = state.json['status'];
      if (previousState == 'stopped') {
        state.json['status'] = 'running';
        await state.save();
      }
      if (casesFile != null) await _establish(state, p.absolute(casesFile));
      switch (name) {
        case 'prepare':
          final entry = state.caseBySource(_caseArgument(command));
          final prepared = await _prepare(state, entry, command);
          success = prepared.isSuccess;
          if (!success)
            await _recordFailure(state, 'prepare', prepared,
                caseName: CaseDefinition.fromJson(entry['definition']).name);
        case 'devices':
          success = await _devices(state, command);
        case 'build':
          final built = await _build(state, _platform(command), command);
          success = built.isSuccess;
          if (!success) await _recordFailure(state, 'build', built);
        case 'launch':
          final entry = state.caseBySource(_caseArgument(command));
          await _lockRoles(entry);
          final launched = await _launch(state, entry, command);
          success = launched.isSuccess;
          if (!success)
            await _recordFailure(state, 'launch', launched,
                caseName: CaseDefinition.fromJson(entry['definition']).name);
        case 'run':
          final entry = state.caseBySource(_caseArgument(command));
          final launchId = command['launch'] as String?;
          if (launchId == null)
            throw const FormatException('run requires --launch');
          await _lockRoles(entry);
          final attempt = await state.newAttempt(entry);
          final result =
              await _execute(state, entry, attempt, launchId, command);
          success = result.isSuccess && result.data?.verdict == '是';
        case 'report':
          success = await _report(state);
        case 'clean':
          success = await _clean(state, command, previousState);
        case 'all':
          success = await _all(state, command);
      }
      if (await File(state.path).exists() && previousState == 'stopped') {
        state.json['status'] = 'stopped';
        await state.save();
      }
      return success ? 0 : 1;
    } catch (e) {
      output(redactor.text('error: $e'));
      if (state != null && await File(state.path).exists()) {
        try {
          await state.issue('orchestration', '$e', redactor);
          // Unknown side effects remain represented by started operations.
          state.json['status'] =
              state.operations.any((op) => op['state'] == 'started')
                  ? 'unknown'
                  : 'stopped';
          await state.save();
        } catch (saveError) {
          output(redactor.text('Failed to persist diagnostics: $saveError'));
        }
      }
      return 1;
    } finally {
      for (final lease in _leases.reversed) {
        await lease.release();
      }
      _leases.clear();
      _activeRunId = null;
    }
  }

  void _help(String? name) {
    output('Dart multi-device test CLI${name == null ? '' : ': $name'}');
    output('Usage: dart run bin/cli.dart ${name ?? '<operation>'} [options]');
    output(
        'Operations: prepare, devices, build, launch, run, report, clean, all.');
    output(
        'Accounts: generate with scripts/generate_accounts.dart before creating a test run.');
    output(
        'prepare <case.yaml> --cases <selection.json> creates inputs; --run-id uses fixed inputs.');
    output(
        'devices list --platform ios; devices <inspect|start|stop|destroy> --platform ios --instance <UDID>.');
    output('devices install needs --build; uninstall needs --application-id.');
    output(
        'build --platform ios [--run-id ID]; launch <case.yaml> --run-id ID [--build BUILD_ID].');
    output(
        'run <case.yaml> --run-id ID --launch LAUNCH_ID; each attempt needs a fresh launch.');
    output(
        'all --cases <selection.json>; report --run-id ID; clean --run-id ID --type logs.');
    output(
        'Inputs are explicit; results: tmp/<runId>/run.json, build/<runId>/, reports/<runId>/.');
    output(
        'Exit 0: selected operation succeeded and any test passed; nonzero: failure, rejection or incomplete finalization.');
    output(name == null ? parser.usage : parser.commands[name]!.usage);
  }

  void _validateOptions(ArgResults args) {
    if (args['build'] != null && args['build-result'] != null) {
      throw const FormatException(
          '--build and --build-result are mutually exclusive');
    }
    final common = {'help', 'run-id'};
    final allowed = <String, Set<String>>{
      'prepare': {'cases', 'data-input'},
      'devices': {
        'platform',
        'instance',
        'application-id',
        'build',
        'build-result'
      },
      'build': {'platform', 'build-result'},
      'launch': {'build', 'build-result'},
      'run': {'launch', 'data-input', 'flow-timeout-ms'},
      'report': {},
      'clean': {'type'},
      'all': {
        'cases',
        'data-input',
        'flow-timeout-ms',
        'type',
        'build',
        'build-result'
      },
    };
    for (final option in args.options) {
      if (args.wasParsed(option) &&
          !common.contains(option) &&
          !allowed[args.name]!.contains(option)) {
        throw FormatException('--$option is not valid for ${args.name}');
      }
    }
    if (['prepare', 'launch', 'run', 'devices'].contains(args.name)) {
      if (args.rest.length != 1)
        throw const FormatException(
            'Exactly one case path or device action is required');
    } else if (args.rest.isNotEmpty) {
      throw const FormatException('Unexpected positional arguments');
    }
    final timeout = args['flow-timeout-ms'] as String?;
    if (timeout != null &&
        (int.tryParse(timeout) == null || int.parse(timeout) <= 0)) {
      throw const FormatException(
          '--flow-timeout-ms must be a positive integer');
    }
    if (args.name == 'clean' && (args['type'] as List).isEmpty)
      throw const FormatException('clean requires --type');
  }

  String _caseArgument(ArgResults args) =>
      p.normalize(p.absolute(args.rest.single));
  DevicePlatform _platform(ArgResults args) {
    final value = args['platform'] as String?;
    if (value == null) throw const FormatException('--platform is required');
    return DevicePlatform.values.byName(value);
  }

  Map<String, JsonObject> _roles(JsonObject entry) =>
      readObject(entry['devices'], 'devices')
          .map((k, v) => MapEntry(k, readObject(v)));
  String _key(JsonObject role) => '${role['platform']}:${role['instance']}';
  Set<String> _resources(JsonObject entry) => {
        ..._roles(entry).values.map(_key),
        ...readAccountSelection(entry['accounts'])
            .values
            .map((id) => 'account:$id'),
      };
  void _ensureResourcesKnown(RunState state, JsonObject entry) {
    final resources = _resources(entry);
    if (state.issues.any((issue) =>
        issue['status'] != 'resolved' &&
        (issue['resources'] as List).any(resources.contains))) {
      throw const FormatException(
          'Shared resources have unresolved external outcomes; verify and explicitly resolve the issue first');
    }
  }

  DeviceResult _selectedDevice(RunState state, JsonObject selection) {
    final device = DeviceResult.fromJson(state.devices[_key(selection)]);
    if (device.platform.name != selection['platform'] ||
        device.instance != selection['instance']) {
      throw const FormatException(
          'Registered device does not match explicit role selection');
    }
    return device;
  }

  OperationContext _context(RunState state, String id) => OperationContext(
      runId: state.id,
      operationId: id,
      tmpDirectory: state.directory,
      redactor: redactor);

  Future<OperationResult<T>> _operation<T>(RunState state, String stage,
      FutureOr<OperationResult<T>> Function(OperationContext) action) async {
    final id = state.allocateOperation(stage);
    await state.begin(id, stage);
    await state.log(stage, id, 'start', redactor, {});
    final timer = Stopwatch()..start();
    OperationResult<T> result;
    try {
      result = await action(_context(state, id));
    } catch (e, stack) {
      await state.log(
          stage, id, 'exception', redactor, {'error': '$e', 'stack': '$stack'});
      result = OperationResult<T>(
          runId: state.id,
          operationId: id,
          status: OperationStatus.failure,
          data: null,
          errors: [
            OperationError(
                message: redactor.text('$e'),
                field: e is ContractViolation ? e.field : stage,
                expected:
                    e is ContractViolation ? e.expected : 'valid delivery',
                actual: e is ContractViolation ? e.actual : null)
          ],
          evidence: e is ContractViolation ? e.evidence : []);
      if (e is ContractViolation) {
        state.operations
                .singleWhere((op) => op['operationId'] == id)['acceptance'] =
            redactor.sanitize(e.toJson());
      }
    }
    result.validate();
    if (result.runId != state.id || result.operationId != id) {
      throw ContractViolation(
          producer: stage,
          consumer: 'orchestration',
          operationId: result.operationId,
          field: 'runId/operationId',
          expected: {'runId': state.id, 'operationId': id},
          actual: {'runId': result.runId, 'operationId': result.operationId},
          rework: stage,
          message: 'Operation delivery ownership mismatch',
          evidence: result.evidence);
    }
    await state.complete(result, stage);
    if (stage != 'clean' ||
        await File(p.join(state.directory.path, 'run.log')).exists()) {
      await state.log(stage, id, 'end', redactor, {
        'status': result.status.name,
        if (result.data is ExecutionResult)
          'verdict': (result.data as ExecutionResult).verdict,
        'elapsedMs': timer.elapsedMilliseconds,
        'errors': result.errors.map((e) => e.toJson()).toList()
      });
    }
    await state.save();
    return result;
  }

  T _accepted<T>(OperationResult<T> result, String producer, String consumer) =>
      acceptOperation(result,
          runId: _activeRunId!,
          producer: producer,
          consumer: consumer,
          rework: producer);

  Future<void> _recordFailure<T>(
          RunState state, String stage, OperationResult<T> result,
          {String? caseName}) =>
      state.issue(
          stage, result.errors.map((e) => e.message).join('; '), redactor,
          caseName: caseName, evidence: result.evidence);

  Future<String> _selectionScene(String path) async {
    final selection =
        readObject(jsonDecode(await File(p.absolute(path)).readAsString()));
    if (selection.keys.any((key) => key != 'cases'))
      throw const FormatException('Selection only supports cases');
    final rows = selection['cases'];
    if (rows is! List || rows.isEmpty)
      throw const FormatException('Selection must contain cases');
    if (rows.length > 1) return 'batch';
    final yaml = readObject(rows.single)['yaml'];
    if (yaml is! String)
      throw const FormatException('Case yaml must be a path');
    final match = RegExp(r'^.+-multi-(.+)-(positive|negative)$')
        .firstMatch(p.basenameWithoutExtension(yaml));
    if (match == null) throw const FormatException('Invalid case filename');
    return match.group(1)!;
  }

  Future<void> _establish(RunState state, String selectionPath) async {
    final selection =
        readObject(jsonDecode(await File(selectionPath).readAsString()));
    if (selection.keys.any((key) => key != 'cases'))
      throw const FormatException('Selection only supports cases');
    final rows = selection['cases'];
    if (rows is! List || rows.isEmpty)
      throw const FormatException(
          'Selection must contain a nonempty cases array');
    final accountResult = await _operation(
        state,
        'accounts',
        (context) => data.load(
            context: context,
            sourcePath: p.join(root.path, 'lib', 'accounts.g.dart')));
    final environment =
        _accepted(accountResult, 'accounts', 'orchestration').environment;
    redactor.addFrom(environment);
    final names = <String>{}, basenames = <String>{};
    final pendingCases = <JsonObject>[];
    for (final raw in rows) {
      final row = readObject(raw);
      if (row.keys
          .any((key) => !{'yaml', 'accounts', 'devices'}.contains(key))) {
        throw const FormatException(
            'Each case must use yaml/accounts/devices; regenerate the selection');
      }
      final yaml = row['yaml'];
      if (yaml is! String || yaml.isEmpty)
        throw const FormatException('Case yaml must be a path');
      final source = p.normalize(
          p.isAbsolute(yaml) ? yaml : p.join(p.dirname(selectionPath), yaml));
      LoadedCase? fixed;
      final fixedResult = await _operation(state, 'inputs', (ctx) async {
        fixed = await loader.freeze(
            source, Directory(p.join(state.directory.path, 'cases')));
        return OperationResult(
            runId: state.id,
            operationId: ctx.operationId,
            status: OperationStatus.success,
            data: fixed!.definition,
            errors: [],
            evidence: []);
      });
      _accepted(fixedResult, 'execution-static', 'orchestration');
      final loaded = fixed!;
      final disabled = caseDisabledReason(loaded.metadata);
      if (disabled != null)
        throw FormatException('Case is disabled: $disabled');
      final accounts = readAccountSelection(row['accounts']);
      final roles =
          readDeviceSelection(row['devices'], loaded.flow.agents.keys);
      data.validateCaseMetadata(
          loaded.metadata, loaded.flow.preconditions, accounts.keys);
      final basename = p.basenameWithoutExtension(source);
      if (!names.add(loaded.definition.name) || !basenames.add(basename))
        throw const FormatException('Duplicate case name or basename');
      final validated = data.createCaseData(
          context: _context(state, 'validate-input'),
          environment: environment,
          caseName: loaded.definition.name,
          caseBasename: basename,
          attempt: 1,
          accounts: accounts,
          metadata: loaded.metadata);
      _accepted(validated, 'data', 'orchestration');
      pendingCases.add({
        'definition': loaded.definition.toJson(),
        'accounts': accounts,
        'devices': roles,
        'definitionOperationId': fixedResult.operationId
      });
      state.register(loaded.definition.yaml.path, 'cache', 'inputs',
          fixedResult.operationId);
      state.register(loaded.definition.json.path, 'cache', 'inputs',
          fixedResult.operationId);
    }
    state.json['environment'] = environment;
    state.cases.addAll(pendingCases);
    await state.save();
  }

  Future<void> _lockRoles(JsonObject entry) async {
    final resources = _roles(entry).values.map(_key).toSet().toList()..sort();
    for (final key in resources) {
      _leases.add(await store.lock('device:$key'));
    }
  }

  Future<CaseData> _caseData(
      RunState state, JsonObject entry, int attempt) async {
    final definition = CaseDefinition.fromJson(entry['definition']);
    final loaded = await loader.load(definition);
    final result = await _operation(
        state,
        'data',
        (ctx) => data.createCaseData(
            context: ctx,
            environment: readObject(state.json['environment']),
            caseName: definition.name,
            caseBasename: p.basenameWithoutExtension(definition.sourceYaml),
            attempt: attempt,
            accounts: readAccountSelection(entry['accounts']),
            metadata: loaded.metadata));
    return _accepted(result, 'data', 'execution');
  }

  Future<OperationResult<PreconditionResult>> _prepare(
      RunState state, JsonObject entry, ArgResults args,
      {CaseData? caseData, bool prepare = true, String? checkPath}) async {
    final loaded =
        await loader.load(CaseDefinition.fromJson(entry['definition']));
    final actualData = caseData ?? await _caseData(state, entry, 1);
    return _operation(
        state,
        prepare ? 'prepare' : 'preconditions',
        (ctx) => data.preconditions(
            context: ctx,
            caseName: loaded.definition.name,
            environment: readObject(state.json['environment']),
            caseData: actualData,
            declarations: loaded.flow.preconditions,
            metadata: loaded.metadata,
            dataInputPath: args['data-input'] as String?,
            prepare: prepare,
            checkOutputPath: checkPath));
  }

  Future<OperationResult<BuildResult>> _build(
      RunState state, DevicePlatform platform, ArgResults args) async {
    final external = args['build-result'] as String?;
    final result = await _operation(state, 'build', (ctx) async {
      if (external == null) return builds.build(ctx, platform);
      final raw = readObject(
          jsonDecode(await File(p.absolute(external)).readAsString()));
      BuildResult original;
      if (raw.containsKey('data')) {
        final external =
            OperationResult<BuildResult>.fromJson(raw, BuildResult.fromJson);
        if (external.runId == null)
          throw const FormatException(
              'External build must identify its originating run');
        original = acceptOperation(external,
            runId: external.runId!,
            producer: 'build',
            consumer: 'build-import',
            rework: 'build');
      } else {
        original = BuildResult.fromJson(raw);
      }
      if (original.platform != platform)
        throw const FormatException('Imported build platform mismatch');
      return builds.importBuild(ctx, original);
    });
    state.builds[result.operationId] = result.toJson();
    if (result.data != null)
      state.register(
          result.data!.artifact.path, 'build', 'build', result.operationId);
    await state.save();
    output(
        'build=${result.operationId} status=${result.status.name}${result.data == null ? '' : ' artifact=${result.data!.artifact.path}'}');
    return result;
  }

  OperationResult<BuildResult> _selectBuild(
      RunState state, DevicePlatform platform, ArgResults args) {
    final explicit = args['build'] as String?;
    final candidates = state.builds.entries
        .where((entry) => explicit == null || entry.key == explicit)
        .map((entry) => OperationResult<BuildResult>.fromJson(
            entry.value, BuildResult.fromJson))
        .where((build) =>
            build.status == OperationStatus.success &&
            build.data?.platform == platform)
        .toList();
    if (candidates.length != 1)
      throw const FormatException(
          'Select exactly one compatible registered build with --build');
    return candidates.single;
  }

  Future<OperationResult<LaunchResult>> _launch(
      RunState state, JsonObject entry, ArgResults args,
      {bool importExternal = true}) async {
    _ensureResourcesKnown(state, entry);
    final definition = CaseDefinition.fromJson(entry['definition']);
    final loaded = await loader.load(definition);
    final roleNames = _roles(entry).keys.toSet();
    if (roleNames.length != loaded.flow.agents.length ||
        roleNames.difference(loaded.flow.agents.keys.toSet()).isNotEmpty) {
      throw const FormatException(
          'Launch role mapping does not match fixed case');
    }
    final roleDevices = <String, DeviceResult>{};
    final roleBuilds = <String, OperationResult<BuildResult>>{};
    final imported = <DevicePlatform, OperationResult<BuildResult>>{};
    final previous = <String, String>{};
    for (final platform
        in _roles(entry).values.map((r) => r['platform'] as String).toSet()) {
      if (importExternal && args['build-result'] != null) {
        final target = DevicePlatform.values.byName(platform);
        final result = await _build(state, target, args);
        _accepted(result, 'build', 'launch');
        imported[target] = result;
      }
    }
    for (final role in _roles(entry).entries) {
      final device = _selectedDevice(state, role.value);
      roleDevices[role.key] = device;
      roleBuilds[role.key] = imported[device.platform] ??
          _selectBuild(state, device.platform, args);
      for (final raw in state.connections.values) {
        final old =
            OperationResult<LaunchResult>.fromJson(raw, LaunchResult.fromJson);
        for (final c in old.data?.roles.values ?? <Connection>[]) {
          if (c.deviceId == device.deviceId)
            previous[device.deviceId!] = c.instanceId;
        }
      }
    }
    await state.invalidateDevices(
        roleDevices.values.map((d) => d.deviceId!).toList(),
        'New launch requested');
    final result = await _operation(
        state,
        'launch',
        (ctx) => launches.launch(ctx,
            caseName: definition.name,
            roles: roleDevices,
            builds: roleBuilds,
            previousInstanceIds: previous));
    state.connections[result.operationId] = result.toJson();
    redactor.addFrom(result.toJson());
    await state.save();
    output('launch=${result.operationId} status=${result.status.name}');
    return result;
  }

  Future<bool> _devices(RunState state, ArgResults args) async {
    final action = args.rest.single, platform = _platform(args);
    if (action == 'list') {
      final result = await _operation(
          state, 'devices', (ctx) => devices.list(ctx, platform));
      for (final device in result.data ?? <DeviceResult>[]) {
        state.devices['${device.platform.name}:${device.instance}'] =
            device.toJson();
        output(jsonEncode(device.toJson()));
      }
      await _deviceFile(state);
      if (!result.isSuccess) await _recordFailure(state, 'devices', result);
      return result.isSuccess;
    }
    if (!['inspect', 'start', 'stop', 'destroy', 'install', 'uninstall']
        .contains(action)) throw const FormatException('Unknown device action');
    final instance = args['instance'] as String?;
    if (instance == null || instance.isEmpty)
      throw const FormatException('--instance is required');
    _leases.add(await store.lock('device:${platform.name}:$instance'));
    final key = '${platform.name}:$instance';
    final imported = action == 'install' && args['build-result'] != null
        ? await _build(state, platform, args)
        : null;
    if (['stop', 'destroy', 'install', 'uninstall'].contains(action)) {
      final old = state.devices[key];
      if (old != null)
        await state.invalidateDevices(
            [DeviceResult.fromJson(old).deviceId ?? ''],
            'Device operation: $action');
    }
    final result = await _operation(state, 'devices', (ctx) async {
      switch (action) {
        case 'inspect':
          return devices.inspect(ctx, platform, instance);
        case 'start':
          return devices.start(ctx, platform, instance);
        case 'stop':
          return devices.stop(ctx, platform, instance);
        case 'destroy':
          return devices.destroy(ctx, platform, instance);
        case 'install':
          final current = _accepted(
              await devices.inspect(ctx, platform, instance,
                  requireReady: true),
              'devices',
              'install');
          final build = _accepted(
              imported ?? _selectBuild(state, platform, args),
              'build',
              'install');
          return devices.install(ctx, current, build);
        default:
          final app = args['application-id'] as String?;
          if (app == null || app.isEmpty)
            throw const FormatException('--application-id required');
          final current = _accepted(
              await devices.inspect(ctx, platform, instance,
                  requireReady: true),
              'devices',
              'uninstall');
          return devices.uninstall(ctx, current, app);
      }
    });
    if (result.data != null) {
      state.devices[key] = result.data!.toJson();
      output(jsonEncode(result.data!.toJson()));
    }
    await _deviceFile(state);
    if (!result.isSuccess) await _recordFailure(state, 'devices', result);
    return result.isSuccess;
  }

  Future<void> _deviceFile(RunState state) async {
    final path = p.join(state.directory.path, 'devices.json');
    await writePrivateJson(path, {'runId': state.id, 'devices': state.devices});
    state.register(path, 'cache', 'devices', 'devices');
    await state.save();
  }

  Future<OperationResult<ExecutionResult>> _execute(
      RunState state,
      JsonObject entry,
      JsonObject attempt,
      String launchId,
      ArgResults args) async {
    final definition = CaseDefinition.fromJson(entry['definition']);
    final number = attempt['attempt'] as int;
    final basename = p.basenameWithoutExtension(definition.sourceYaml);
    final directory =
        Directory(p.join(state.directory.path, basename, '$number'));
    final reportPath = p.join(root.path, 'reports', state.id, basename,
        '$number', 'flow-report.json');
    final captures = <DeviceLogCapture>[];
    final captureErrors = <OperationError>[];
    final admissionEvidence = <EvidenceRef>[];
    OperationResult<ExecutionResult> result;
    try {
      _ensureResourcesKnown(state, entry);
      final caseData = await _caseData(state, entry, number);
      attempt['caseData'] = caseData.toJson();
      attempt['launchOperationId'] = launchId;
      await state.save();
      final launch = OperationResult<LaunchResult>.fromJson(
          state.connections[launchId], LaunchResult.fromJson);
      final roleDevices = {
        for (final role in _roles(entry).entries)
          role.key: _selectedDevice(state, role.value)
      };
      result = await _operation(
          state,
          'execute',
          (ctx) => ExecutionService(loader: loader).execute(
              context: ctx,
              definition: definition,
              caseData: CaseData.fromJson(attempt['caseData']),
              expectedCaseData: caseData,
              devices: roleDevices,
              sourceOperations: {
                'definition': entry['definitionOperationId'] as String,
                'caseData': state.operations
                        .lastWhere((op) => op['stage'] == 'data')['operationId']
                    as String,
                'launch': launchId,
                for (final role in roleDevices.entries)
                  'device.${role.key}': _deviceOperationId(state, role.value),
              },
              launch: launch,
              attemptDirectory: directory,
              reportPath: reportPath,
              flowTimeoutMs:
                  int.tryParse(args['flow-timeout-ms'] as String? ?? ''),
              admission: () async {
                final checkPath = p.join(directory.path, 'preconditions.json');
                final preconditions = await _prepare(state, entry, args,
                    caseData: caseData, prepare: false, checkPath: checkPath);
                admissionEvidence.addAll(preconditions.evidence);
                if (preconditions.data != null)
                  admissionEvidence.add(EvidenceRef(
                      path: preconditions.data!.check.path, location: null));
                _accepted(preconditions, 'data', 'execute');
                for (final role in launch.data!.roles.entries) {
                  final build = OperationResult<BuildResult>.fromJson(
                      state.builds[role.value.buildOperationId],
                      BuildResult.fromJson);
                  final checked = await launches.recheck(ctx,
                      connection: role.value,
                      device: roleDevices[role.key]!,
                      build: build);
                  admissionEvidence.addAll(checked.evidence);
                  if (!checked.isSuccess)
                    await state.invalidateDevices(
                        [role.value.deviceId], 'Connection admission failed');
                  _accepted(checked, 'launch', 'execute');
                  final capture = await launches.startCapture(ctx,
                      role: role.key,
                      device: roleDevices[role.key]!,
                      applicationId: role.value.applicationId,
                      processId: role.value.processId);
                  captures.add(capture);
                  await capture.ready.timeout(launches.timeout);
                }
                return preconditions;
              },
              claimConnections: () =>
                  state.claimLaunch(launchId, definition.name, number)));
    } catch (e) {
      result = await _notExecuted(state, definition, number, '$e');
    } finally {
      for (final capture in captures) {
        try {
          await capture.close();
        } catch (e) {
          captureErrors.add(OperationError(
              message: redactor.text('Device log finalization: $e'),
              field: 'deviceLog',
              expected: 'collected and closed',
              actual: null));
        }
      }
    }
    result = OperationResult(
        runId: result.runId,
        operationId: result.operationId,
        status: captureErrors.isEmpty ? result.status : OperationStatus.failure,
        data: result.data,
        errors: [
          ...result.errors,
          ...captureErrors
        ],
        evidence: [
          ...result.evidence,
          ...admissionEvidence,
          for (final capture in captures) ...capture.evidence
        ]);
    await state.complete(result, 'execute');
    attempt['result'] = result.toJson();
    attempt['state'] = 'completed';
    attempt['launchOperationId'] = result.data?.launchOperationId;
    if (result.data?.report != null)
      state.register(
          result.data!.report!.path, 'reports', 'execute', result.operationId,
          caseName: definition.name, attempt: number);
    for (final capture in captures) {
      for (final ref in capture.evidence) {
        state.register(ref.path, 'logs', 'execute', result.operationId,
            caseName: definition.name, attempt: number);
      }
    }
    await state.save();
    if (!result.isSuccess || result.data?.verdict != '是') {
      await state.issue(
          'execute',
          result.errors.isEmpty
              ? '用例结论：${result.data?.verdict}；实际步骤或必要验证未通过，详见执行报告。'
              : result.errors.map((e) => e.message).join('; '),
          redactor,
          caseName: definition.name,
          attempt: number,
          evidence: result.evidence,
          resources: result.data?.verdict == '未完成' ||
                  result.data?.finish.values.any((f) => !f.success) == true
              ? _resources(entry)
              : const []);
    }
    output(
        'case=${definition.name} attempt=$number verdict=${result.data?.verdict ?? '未完成'}');
    return result;
  }

  String _deviceOperationId(RunState state, DeviceResult device) {
    for (final op in state.operations.reversed) {
      if (op['stage'] != 'devices') continue;
      final raw = readObject(op['result']);
      final value = raw['data'];
      final entries = value is List ? value : [value];
      if (entries.any((value) =>
          value is Map &&
          value['platform'] == device.platform.name &&
          value['instance'] == device.instance)) {
        return op['operationId'] as String;
      }
    }
    throw const FormatException('Device has no registered producing operation');
  }

  Future<OperationResult<ExecutionResult>> _notExecuted(RunState state,
          CaseDefinition definition, int number, String reason) =>
      _operation(
          state,
          'execute',
          (ctx) => OperationResult(
                  runId: state.id,
                  operationId: ctx.operationId,
                  status: OperationStatus.failure,
                  data: ExecutionResult(
                      caseName: definition.name,
                      attempt: number,
                      definition: definition,
                      launchOperationId: null,
                      verdict: '未执行',
                      report: null,
                      required: [],
                      finish: {}),
                  errors: [
                    OperationError(
                        message: redactor.text(reason),
                        field: 'admission',
                        expected: 'accepted inputs',
                        actual: null)
                  ],
                  evidence: []));

  Future<bool> _all(RunState state, ArgResults args) async {
    var success = true;
    final roleSelections = <String, JsonObject>{};
    for (final entry in state.cases) {
      for (final role in _roles(entry).values) {
        roleSelections[_key(role)] = role;
      }
    }
    final keys = roleSelections.keys.toList()..sort();
    for (final key in keys) {
      _leases.add(await store.lock('device:$key'));
    }
    for (final entry in roleSelections.entries) {
      final role = entry.value;
      final result = await _operation(
          state,
          'devices',
          (ctx) => devices.start(
              ctx,
              DevicePlatform.values.byName(role['platform'] as String),
              role['instance'] as String));
      if (result.data != null) state.devices[entry.key] = result.data!.toJson();
      if (!result.isSuccess) success = false;
    }
    await _deviceFile(state);
    final platforms =
        roleSelections.values.map((r) => r['platform'] as String).toSet();
    for (final platform in platforms) {
      if (!(await _build(state, DevicePlatform.values.byName(platform), args))
          .isSuccess) success = false;
    }
    for (final entry in state.cases) {
      final definition = CaseDefinition.fromJson(entry['definition']);
      final attempt = await state.newAttempt(entry);
      var externalOutcomeUnknown = false;
      try {
        _ensureResourcesKnown(state, entry);
        final caseData =
            await _caseData(state, entry, attempt['attempt'] as int);
        final prepared = await _prepare(state, entry, args, caseData: caseData);
        externalOutcomeUnknown = prepared.errors.any((error) =>
            error.field == 'management.writeOutcome' &&
            error.actual == 'unknown');
        _accepted(prepared, 'data', 'launch');
        final launch = await _launch(state, entry, args, importExternal: false);
        _accepted(launch, 'launch', 'execute');
        final result =
            await _execute(state, entry, attempt, launch.operationId, args);
        if (!result.isSuccess || result.data?.verdict != '是') success = false;
      } catch (e) {
        success = false;
        final result = await _notExecuted(
            state, definition, attempt['attempt'] as int, '$e');
        attempt['result'] = result.toJson();
        attempt['state'] = 'completed';
        await state.save();
        await state.issue('admission', '$e', redactor,
            caseName: definition.name,
            attempt: attempt['attempt'] as int,
            resources: externalOutcomeUnknown ? _resources(entry) : const []);
      }
    }
    if (!await _report(state)) success = false;
    if ((args['type'] as List).isNotEmpty &&
        !await _clean(state, args, 'stopped')) success = false;
    return success;
  }

  Future<bool> _report(RunState state) async {
    final service = ReportingService(loader: loader);
    final result = await _operation(
        state,
        'report',
        (ctx) => service.generate(ctx, state.json,
            Directory(p.join(root.path, 'reports', state.id))));
    if (result.data != null) {
      await service.validate(result.data!, state.json,
          verifyEvidence: result.isSuccess);
      final report = result.data!;
      final references = {
        if (!result.isSuccess)
          for (final raw in state.json['reportDependencies'] as List)
            jsonEncode(raw): raw,
        for (final dependency in report.dependencies)
          jsonEncode(dependency.toJson()): dependency.toJson(),
      };
      state.json['reportDependencies'] = references.values.toList();
      for (final ref in [
        report.summary,
        report.statistics,
        ...report.process
      ]) {
        state.register(ref.path, 'reports', 'report', result.operationId);
      }
    }
    state.json['reporting'] = result.toJson();
    await state.save();
    if (!result.isSuccess) await _recordFailure(state, 'report', result);
    return result.isSuccess;
  }

  Future<bool> _clean(
      RunState state, ArgResults args, Object? originalState) async {
    final snapshot = readObject(jsonDecode(jsonEncode(state.json)))
      ..['status'] = originalState;
    final service = CleanupService(root: root);
    final types = (args['type'] as List<String>).toSet();
    final result = await _operation(
        state, 'clean', (ctx) => service.clean(ctx, snapshot, types));
    if (result.data != null) {
      final selected = (snapshot['artifacts'] as List)
          .cast<JsonObject>()
          .where(
              (item) => types.contains('all') || types.contains(item['type']))
          .map((item) => item['path'] as String)
          .toSet();
      await service.validate(result.data!, selected);
      for (final path in result.data!.deleted) {
        if (await FileSystemEntity.type(path, followLinks: false) !=
            FileSystemEntityType.notFound) {
          throw const FormatException(
              'Cleanup claimed deletion but path still exists');
        }
      }
      state.artifacts
          .removeWhere((ref) => result.data!.deleted.contains(ref['path']));
      final removedReports = result.data!.deleted.toSet();
      (state.json['reportDependencies'] as List).removeWhere((Object? ref) =>
          ref is Map && removedReports.contains(ref['report']));
    }
    await state.save();
    output(jsonEncode(result.data?.toJson()));
    if (!result.isSuccess) await _recordFailure(state, 'clean', result);
    if (result.isSuccess &&
        state.artifacts.isEmpty &&
        (state.json['reportDependencies'] as List).isEmpty &&
        state.issues.every((issue) => issue['status'] == 'resolved') &&
        originalState == 'stopped') {
      await File(state.path).delete();
    }
    return result.isSuccess;
  }
}
