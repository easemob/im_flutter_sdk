import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/devices.dart';

import 'device_fakes.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('testing-v2-devices-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  FakeHost android(
          {String boot = '1',
          bool flutterVisible = true,
          bool duplicate = false}) =>
      FakeHost((exe, args) {
        if (exe == 'emulator') return ok('Pixel_A\nPixel_B\n');
        if (exe == 'flutter')
          return ok(jsonEncode([
            if (flutterVisible) {'id': 'emulator-5556'}
          ]));
        if (args.join(' ') == 'devices')
          return ok(
              'List of devices attached\nemulator-5554 device\nemulator-5556 device\n');
        if (args.contains('name'))
          return ok(
              '${args.contains('emulator-5554') && !duplicate ? 'Pixel_B' : 'Pixel_A'}\nOK\n');
        if (args.contains('get-state')) return ok('device\n');
        if (args.contains('sys.boot_completed')) return ok('$boot\n');
        throw StateError('Unexpected $exe $args');
      });

  test(
      'Android resolves exact AVD rather than list position and delivers valid result',
      () async {
    final host = android();
    final result = await DeviceService(runner: host).inspect(
        context(directory), DevicePlatform.android, 'Pixel_A',
        requireReady: true);
    expect(result.status, OperationStatus.success);
    expect(result.data!.deviceId, 'emulator-5556');
    expect(result.data!.ready, isTrue);
    expect(() => result.validate(), returnsNormally);
    expect(await File(result.evidence.single.path).readAsString(),
        contains('sys.boot_completed'));
  });

  test(
      'boot command status cannot replace boot-completed and Flutter visibility',
      () async {
    for (final host in [android(boot: '0'), android(flutterVisible: false)]) {
      final result = await DeviceService(runner: host).inspect(
          context(directory), DevicePlatform.android, 'Pixel_A',
          requireReady: true);
      expect(result.status, OperationStatus.failure);
      expect(result.data, isNull);
      expect(host.calls.any((call) => call.contains('install')), isFalse);
    }
  });

  test('ambiguous AVD is rejected before dependent operations', () async {
    final host = android(duplicate: true);
    final result = await DeviceService(runner: host).inspect(
        context(directory), DevicePlatform.android, 'Pixel_A',
        requireReady: true);
    expect(result.status, OperationStatus.failure);
    expect(result.errors.single.message, contains('multiple active serials'));
    expect(host.calls.any((call) => call.contains('get-state')), isFalse);
  });

  test('list may deliver stopped simulators without claiming readiness',
      () async {
    final host = FakeHost((exe, args) =>
        exe == 'emulator' ? ok('Pixel_A\n') : ok('List of devices attached\n'));
    final result = await DeviceService(runner: host)
        .list(context(directory), DevicePlatform.android);
    expect(result.status, OperationStatus.success);
    expect(result.data!.single.ready, isFalse);
    expect(result.data!.single.deviceId, isNull);
  });

  test('iOS readiness requires bootstatus and Flutter visibility', () async {
    final host = FakeHost((exe, args) {
      if (exe == 'flutter') return ok('[{"id":"udid-a"}]');
      if (args.contains('list'))
        return ok(
            '{"devices":{"runtime":[{"udid":"udid-a","state":"Booted"}]}}');
      if (args.contains('bootstatus')) return ok();
      throw StateError('Unexpected $args');
    });
    final result = await DeviceService(runner: host).inspect(
        context(directory), DevicePlatform.ios, 'udid-a',
        requireReady: true);
    expect(result.isSuccess, isTrue);
    expect(host.calls.map((call) => call.join(' ')),
        contains('xcrun simctl bootstatus udid-a -b'));
  });

  test('iOS wrong UDID rejected without selecting another device', () async {
    final host = FakeHost((_, __) =>
        ok('{"devices":{"runtime":[{"udid":"other","state":"Booted"}]}}'));
    final result = await DeviceService(runner: host).inspect(
        context(directory), DevicePlatform.ios, 'udid-a',
        requireReady: true);
    expect(result.isSuccess, isFalse);
    expect(host.calls, hasLength(1));
  });

  test('host command evidence is sanitized before saving', () async {
    final host = FakeHost((_, __) => failed('token=sensitive-token'));
    final result = await DeviceService(runner: host)
        .list(context(directory), DevicePlatform.android);
    expect(result.isSuccess, isFalse);
    expect(jsonEncode(result.toJson()), isNot(contains('sensitive-token')));
    expect(await File(result.evidence.single.path).readAsString(),
        isNot(contains('sensitive-token')));
  });

  test('AVD startup detaches emulator and independently verifies readiness',
      () async {
    var running = false;
    final process = FakeProcess();
    final host = FakeHost((exe, args) {
      if (exe == 'emulator') return ok('Pixel_A\n');
      if (exe == 'flutter') return ok('[{"id":"emulator-5554"}]');
      if (args.join(' ') == 'devices')
        return ok(
            'List of devices attached\n${running ? 'emulator-5554 device\n' : ''}');
      if (args.contains('name')) return ok('Pixel_A\nOK\n');
      if (args.contains('get-state')) return ok('device');
      if (args.contains('sys.boot_completed')) return ok('1');
      throw StateError('Unexpected $exe $args');
    }, onStart: (_, __) {
      running = true;
      return process;
    });
    try {
      final result = await DeviceService(runner: host)
          .start(context(directory), DevicePlatform.android, 'Pixel_A');
      expect(result.isSuccess, isTrue);
      expect(result.data!.ready, isTrue);
      expect(host.startModes, [ProcessStartMode.detached]);
      expect(process.killed, isFalse);
    } finally {
      process.kill();
    }
  });

  test('AVD stop preserves instance and confirms it is no longer active',
      () async {
    var running = true;
    final host = FakeHost((exe, args) {
      if (exe == 'emulator') return ok('Pixel_A\n');
      if (args.join(' ') == 'devices')
        return ok(
            'List of devices attached\n${running ? 'emulator-5554 device\n' : ''}');
      if (args.contains('name')) return ok('Pixel_A\nOK\n');
      if (args.contains('kill')) {
        running = false;
        return ok();
      }
      throw StateError('Unexpected $exe $args');
    });
    final result = await DeviceService(runner: host)
        .stop(context(directory), DevicePlatform.android, 'Pixel_A');
    expect(result.isSuccess, isTrue);
    expect(result.data!.observedState, 'Stopped');
    expect(host.calls.any((call) => call.contains('delete')), isFalse);
  });

  test(
      'destroy addresses only stopped specified instance and verifies deletion',
      () async {
    var exists = true;
    final host = FakeHost((exe, args) {
      if (exe == 'emulator') return ok('${exists ? 'Pixel_A\n' : ''}Pixel_B\n');
      if (args.join(' ') == 'devices') return ok('List of devices attached\n');
      if (args.join(' ') == 'delete avd -n Pixel_A') {
        exists = false;
        return ok();
      }
      throw StateError('Unexpected $exe $args');
    });
    final result = await DeviceService(runner: host)
        .destroy(context(directory), DevicePlatform.android, 'Pixel_A');
    expect(result.isSuccess, isTrue);
    expect(result.data!.observedState, 'deleted');
    expect(host.calls.where((call) => call.contains('delete')).single.last,
        'Pixel_A');
  });
}
