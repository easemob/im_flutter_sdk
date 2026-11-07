import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'build.dart';
import 'contracts.dart';
import 'core.dart';

class DeviceService {
  DeviceService(
      {HostCommandRunner? runner,
      this.timeout = const Duration(minutes: 2),
      this.pollInterval = const Duration(seconds: 1)})
      : runner = runner ?? IoHostCommandRunner();

  final HostCommandRunner runner;
  final Duration timeout;
  final Duration pollInterval;

  Future<OperationResult<List<DeviceResult>>> list(
          OperationContext context, DevicePlatform platform) =>
      _operation(context, (log) async {
        if (platform == DevicePlatform.ios) {
          final entries = await _iosEntries(log);
          return [for (final entry in entries) _iosResult(entry)];
        }
        final names = await log.run('emulator', ['-list-avds']);
        final active = await _androidActive(log);
        return [
          for (final name in const LineSplitter()
              .convert(names.stdout)
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty))
            DeviceResult(
                platform: platform,
                instance: name,
                deviceId: _uniqueSerial(active, name),
                observedState: _uniqueSerial(active, name) == null
                    ? 'Stopped'
                    : 'running-unchecked',
                checkedAt: DateTime.now(),
                ready: false)
        ];
      });

  Future<OperationResult<DeviceResult>> inspect(
          OperationContext context, DevicePlatform platform, String instance,
          {bool requireReady = false}) =>
      _operation(
          context,
          (log) =>
              _inspect(log, platform, instance, requireReady: requireReady));

  Future<OperationResult<DeviceResult>> start(
          OperationContext context, DevicePlatform platform, String instance) =>
      _operation(context, (log) async {
        final before = await _inspect(log, platform, instance);
        if (platform == DevicePlatform.ios) {
          if (before.observedState != 'Booted') {
            await log.run('xcrun', ['simctl', 'boot', instance]);
          }
        } else if (before.deviceId == null) {
          // The emulator belongs to the selected device, not the CLI process.
          // Readiness is independently established through adb and Flutter.
          final process = await runner.start('emulator', ['-avd', instance],
              mode: ProcessStartMode.detached);
          await log.note('emulator-start', {
            'arguments': ['-avd', instance],
            'processId': process.pid,
            'mode': 'detached',
            'terminalOutcome': 'not-observed'
          });
        }
        final deadline = DateTime.now().add(timeout);
        Object? last;
        while (DateTime.now().isBefore(deadline)) {
          try {
            return await _inspect(log, platform, instance, requireReady: true);
          } catch (error) {
            last = error;
          }
          await Future<void>.delayed(pollInterval);
        }
        throw StateError(
            'Device did not become ready within ${timeout.inMilliseconds}ms: $last');
      });

  Future<OperationResult<DeviceResult>> stop(
          OperationContext context, DevicePlatform platform, String instance) =>
      _operation(context, (log) async {
        final device = await _inspect(log, platform, instance);
        if (platform == DevicePlatform.ios) {
          if (device.observedState != 'Shutdown') {
            await log.run('xcrun', ['simctl', 'shutdown', instance]);
          }
        } else if (device.deviceId != null) {
          await log.run('adb', ['-s', device.deviceId!, 'emu', 'kill']);
        }
        final deadline = DateTime.now().add(timeout);
        while (DateTime.now().isBefore(deadline)) {
          final current = await _inspect(log, platform, instance);
          if (current.deviceId == null || current.observedState == 'Shutdown') {
            return current;
          }
          await Future<void>.delayed(pollInterval);
        }
        throw StateError('Device shutdown remains unconfirmed');
      });

  Future<OperationResult<DeviceResult>> destroy(
          OperationContext context, DevicePlatform platform, String instance) =>
      _operation(context, (log) async {
        final device = await _inspect(log, platform, instance);
        if (platform == DevicePlatform.ios) {
          if (device.observedState == 'Booted') {
            await log.run('xcrun', ['simctl', 'shutdown', instance]);
          }
          await log.run('xcrun', ['simctl', 'delete', instance]);
          if ((await _iosEntries(log)).any((e) => e['udid'] == instance)) {
            throw StateError('Deleted simulator still exists');
          }
        } else {
          if (device.deviceId != null) {
            throw StateError('Stop the selected AVD before destroying it');
          }
          await log.run(
              androidSdkTool('avdmanager'), ['delete', 'avd', '-n', instance]);
          final names = await log.run('emulator', ['-list-avds']);
          if (const LineSplitter().convert(names.stdout).contains(instance)) {
            throw StateError('Deleted AVD still exists');
          }
        }
        return DeviceResult(
            platform: platform,
            instance: instance,
            deviceId: null,
            observedState: 'deleted',
            checkedAt: DateTime.now(),
            ready: false);
      });

  Future<OperationResult<DeviceResult>> install(
          OperationContext context, DeviceResult device, BuildResult build) =>
      _operation(context, (log) async {
        final ready = await _inspect(log, device.platform, device.instance,
            requireReady: true);
        _sameDevice(device, ready);
        await validateArtifact(build, log, device: ready);
        if (ready.platform == DevicePlatform.android) {
          await log.run('adb',
              ['-s', ready.deviceId!, 'install', '-r', build.artifact.path]);
          final installed = await log.run('adb', [
            '-s',
            ready.deviceId!,
            'shell',
            'pm',
            'path',
            build.applicationId
          ]);
          if (!installed.stdout.trim().startsWith('package:')) {
            throw StateError('Installed application cannot be found');
          }
        } else {
          await log.run('xcrun',
              ['simctl', 'install', ready.deviceId!, build.artifact.path]);
          final installed = await log.run('xcrun', [
            'simctl',
            'get_app_container',
            ready.deviceId!,
            build.applicationId,
            'app'
          ]);
          if (installed.stdout.trim().isEmpty)
            throw StateError('Installed application cannot be found');
        }
        return ready;
      });

  Future<OperationResult<DeviceResult>> uninstall(OperationContext context,
          DeviceResult device, String applicationId) =>
      _operation(context, (log) async {
        if (applicationId.trim().isEmpty)
          throw ArgumentError('applicationId is required');
        final ready = await _inspect(log, device.platform, device.instance,
            requireReady: true);
        _sameDevice(device, ready);
        if (ready.platform == DevicePlatform.android) {
          await log
              .run('adb', ['-s', ready.deviceId!, 'uninstall', applicationId]);
          final result = await log.run('adb',
              ['-s', ready.deviceId!, 'shell', 'pm', 'path', applicationId],
              allowFailure: true);
          if (result.stdout.trim().startsWith('package:'))
            throw StateError('Application is still installed');
        } else {
          await log.run(
              'xcrun', ['simctl', 'uninstall', ready.deviceId!, applicationId]);
          final result = await log.run(
              'xcrun',
              [
                'simctl',
                'get_app_container',
                ready.deviceId!,
                applicationId,
                'app'
              ],
              allowFailure: true);
          if (result.exitCode == 0)
            throw StateError('Application is still installed');
        }
        return ready;
      });

  Future<DeviceResult> _inspect(
      CommandLog log, DevicePlatform platform, String instance,
      {bool requireReady = false}) async {
    if (instance.trim().isEmpty) throw ArgumentError('instance is required');
    String? deviceId;
    String state;
    if (platform == DevicePlatform.ios) {
      final entries =
          (await _iosEntries(log)).where((e) => e['udid'] == instance).toList();
      if (entries.length != 1)
        throw StateError(
            'Expected exactly one simulator with UDID $instance; found ${entries.length}');
      state = entries.single['state'] as String;
      deviceId = state == 'Booted' ? instance : null;
      if (requireReady) {
        if (state != 'Booted')
          throw StateError('Simulator is $state, not Booted');
        await log.run('xcrun', ['simctl', 'bootstatus', instance, '-b']);
      }
    } else {
      final names = await log.run('emulator', ['-list-avds']);
      if (!const LineSplitter()
          .convert(names.stdout)
          .map((e) => e.trim())
          .contains(instance)) {
        throw StateError('Unknown AVD $instance');
      }
      deviceId = _uniqueSerial(await _androidActive(log), instance);
      state = deviceId == null ? 'Stopped' : 'running-unchecked';
      if (requireReady) {
        if (deviceId == null) throw StateError('AVD $instance is not running');
        final observed = await log.run('adb', ['-s', deviceId, 'get-state']);
        state = observed.stdout.trim();
        if (state != 'device') throw StateError('adb state is $state');
        final boot = await log.run(
            'adb', ['-s', deviceId, 'shell', 'getprop', 'sys.boot_completed']);
        if (boot.stdout.trim() != '1')
          throw StateError('Android boot is incomplete');
      }
    }
    if (requireReady) {
      final result = await log.run('flutter', ['devices', '--machine']);
      final decoded = jsonDecode(result.stdout);
      if (decoded is! List ||
          decoded
                  .whereType<Map<Object?, Object?>>()
                  .where((e) => e['id'] == deviceId)
                  .length !=
              1) {
        throw StateError('Flutter does not uniquely expose $deviceId');
      }
    }
    return DeviceResult(
        platform: platform,
        instance: instance,
        deviceId: deviceId,
        observedState: state,
        checkedAt: DateTime.now(),
        ready: requireReady);
  }

  Future<List<Map<String, Object?>>> _iosEntries(CommandLog log) async {
    final result = await log
        .run('xcrun', ['simctl', 'list', 'devices', 'available', '--json']);
    final value = jsonDecode(result.stdout);
    if (value is! Map || value['devices'] is! Map)
      throw const FormatException('Invalid simctl device list');
    final entries = <Map<String, Object?>>[];
    for (final group in (value['devices'] as Map).values) {
      if (group is! List)
        throw const FormatException('Invalid simctl runtime group');
      for (final entry in group) {
        if (entry is! Map ||
            entry['udid'] is! String ||
            entry['state'] is! String) {
          throw const FormatException('Invalid simctl device');
        }
        entries.add(Map<String, Object?>.from(entry));
      }
    }
    return entries;
  }

  DeviceResult _iosResult(Map<String, Object?> value) => DeviceResult(
      platform: DevicePlatform.ios,
      instance: value['udid'] as String,
      deviceId: value['state'] == 'Booted' ? value['udid'] as String : null,
      observedState: value['state'] as String,
      checkedAt: DateTime.now(),
      ready: false);

  Future<Map<String, List<String>>> _androidActive(CommandLog log) async {
    final result = await log.run('adb', ['devices']);
    final active = <String, List<String>>{};
    for (final line in const LineSplitter().convert(result.stdout)) {
      final fields = line.trim().split(RegExp(r'\s+'));
      if (fields.length < 2 || !fields[0].startsWith('emulator-')) continue;
      final name =
          await log.run('adb', ['-s', fields[0], 'emu', 'avd', 'name']);
      final names = const LineSplitter()
          .convert(name.stdout)
          .where((e) => e.trim().isNotEmpty && e.trim() != 'OK')
          .toList();
      if (names.length != 1)
        throw StateError('Cannot identify AVD for ${fields[0]}');
      active.putIfAbsent(names.single.trim(), () => []).add(fields[0]);
    }
    return active;
  }

  String? _uniqueSerial(Map<String, List<String>> active, String instance) {
    final matches = active[instance] ?? const [];
    if (matches.length > 1)
      throw StateError('AVD $instance has multiple active serials');
    return matches.isEmpty ? null : matches.single;
  }

  void _sameDevice(DeviceResult expected, DeviceResult actual) {
    if (expected.platform != actual.platform ||
        expected.instance != actual.instance ||
        expected.deviceId != actual.deviceId ||
        !expected.ready) {
      throw StateError('Device handoff is stale or not ready');
    }
  }

  Future<OperationResult<T>> _operation<T>(
      OperationContext context, Future<T> Function(CommandLog) action) async {
    final log = CommandLog(context, runner, timeout);
    try {
      final value = await action(log);
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.success,
          data: value,
          errors: [],
          evidence: await log.evidence());
    } catch (error) {
      await log.note('failure', {
        'error': context.redactor.text('$error'),
        if (error is ContractViolation) 'acceptance': error.toJson()
      });
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.failure,
          data: null,
          errors: [
            if (error is ContractViolation)
              error.toOperationError()
            else
              OperationError(
                  message: context.redactor.text('$error'),
                  field: 'device',
                  expected: 'specified simulator and valid operation',
                  actual: null)
          ],
          evidence: await log.evidence());
    }
  }
}
