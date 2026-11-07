import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/build.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';

import 'device_fakes.dart';

void main() {
  late Directory directory;
  late Directory root;
  late String apk;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('testing-v2-build-');
    root = Directory(p.join(directory.path, 'testing_v2', 'build'));
    apk = p.join(directory.path, 'im_flutter_sdk', 'example', 'build', 'app',
        'outputs', 'flutter-apk', 'app-debug.apk');
    await File(apk).parent.create(recursive: true);
    await File(apk).writeAsString('old-artifact');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  FakeHost host(
          {bool buildFails = false,
          String app = 'com.example.example',
          String arch = 'arm64-v8a'}) =>
      FakeHost((exe, args) async {
        if (exe == 'flutter' && args.contains('--version'))
          return ok('{"frameworkVersion":"3.47.0"}');
        if (exe == 'flutter' && args.first == 'build') {
          if (buildFails) return failed('Compilation failed');
          await File(apk).writeAsString('new-artifact');
          return ok();
        }
        if (p.basename(exe) == 'aapt')
          return ok(
              "package: name='$app' versionCode='1'\napplication-debuggable\nnative-code: '$arch'\n");
        if (exe == 'adb') return ok('arm64-v8a,armeabi-v7a');
        throw StateError('Unexpected $exe $args');
      });

  test('build returns owned hash-verified artifact consumable by validator',
      () async {
    final runner = host();
    final service =
        BuildService(repository: directory, buildRoot: root, runner: runner);
    final result =
        await service.build(context(directory), DevicePlatform.android);
    expect(result.isSuccess, isTrue);
    expect(result.data!.artifact.path, contains('/run-1/op-1/android/'));
    expect(
        await File(result.data!.artifact.path).readAsString(), 'new-artifact');
    final checked =
        await service.validate(context(directory, 'validate'), result.data!);
    expect(checked.isSuccess, isTrue);
  });

  test('failed build cannot return an old artifact', () async {
    final result = await BuildService(
            repository: directory,
            buildRoot: root,
            runner: host(buildFails: true))
        .build(context(directory), DevicePlatform.android);
    expect(result.isSuccess, isFalse);
    expect(result.data, isNull);
    expect(await File(apk).readAsString(), 'old-artifact');
    expect(await Directory(p.join(root.path, 'run-1')).exists(), isFalse);
  });

  test('changed artifact rejected before metadata or installation side effects',
      () async {
    final runner = host();
    final service =
        BuildService(repository: directory, buildRoot: root, runner: runner);
    final result =
        await service.build(context(directory), DevicePlatform.android);
    await File(result.data!.artifact.path).writeAsString('changed');
    runner.calls.clear();
    final checked =
        await service.validate(context(directory, 'validate'), result.data!);
    expect(checked.isSuccess, isFalse);
    expect(runner.calls, isEmpty);
    expect(checked.errors.single.field, 'artifact.sha256');
    expect(checked.errors.single.message, contains('build -> installation'));
    expect(checked.errors.single.expected, isNot(checked.errors.single.actual));
  });

  test('actual application metadata must equal delivery metadata', () async {
    final service =
        BuildService(repository: directory, buildRoot: root, runner: host());
    final result =
        await service.build(context(directory), DevicePlatform.android);
    final corrupt = BuildResult.fromJson(
        {...result.data!.toJson(), 'applicationId': 'other.app'});
    final checked =
        await service.validate(context(directory, 'validate'), corrupt);
    expect(checked.isSuccess, isFalse);
    expect(checked.errors.single.message, contains('metadata differs'));
  });

  test('noncontrol parameters rejected without reading or installing artifact',
      () async {
    final runner = host();
    final service =
        BuildService(repository: directory, buildRoot: root, runner: runner);
    final result =
        await service.build(context(directory), DevicePlatform.android);
    final corrupt = BuildResult(
        platform: DevicePlatform.android,
        architectures: result.data!.architectures,
        applicationId: result.data!.applicationId,
        mode: 'debug',
        arguments: ['build', 'apk', '--debug'],
        artifact: result.data!.artifact);
    runner.calls.clear();
    final checked =
        await service.validate(context(directory, 'validate'), corrupt);
    expect(checked.isSuccess, isFalse);
    expect(runner.calls, isEmpty);
  });

  test(
      'foreign artifact requires import then remains independent from original',
      () async {
    final service =
        BuildService(repository: directory, buildRoot: root, runner: host());
    final original = BuildResult(
        platform: DevicePlatform.android,
        architectures: ['arm64-v8a'],
        applicationId: 'com.example.example',
        mode: 'debug',
        arguments: buildArguments(DevicePlatform.android),
        artifact: await fileRef(apk));
    expect((await service.validate(context(directory), original)).isSuccess,
        isFalse);
    final imported =
        await service.importBuild(context(directory, 'import'), original);
    expect(imported.isSuccess, isTrue);
    await File(apk).delete();
    expect(
        (await service.validate(context(directory, 'check'), imported.data!))
            .isSuccess,
        isTrue);
  });

  test('build for incompatible device architecture is rejected', () async {
    final runner = host(arch: 'x86_64');
    final service =
        BuildService(repository: directory, buildRoot: root, runner: runner);
    final result =
        await service.build(context(directory), DevicePlatform.android);
    final device = DeviceResult(
        platform: DevicePlatform.android,
        instance: 'AVD',
        deviceId: 'emulator-5554',
        observedState: 'device',
        checkedAt: DateTime.now(),
        ready: true);
    final checked = await service
        .validate(context(directory, 'check'), result.data!, device: device);
    expect(checked.isSuccess, isFalse);
    expect(checked.errors.single.message, contains('incompatible'));
  });

  test('iOS artifact requires simulator platform from actual plist', () async {
    final app = Directory(p.join(directory.path, 'sample.app'));
    await app.create();
    final runner = FakeHost((_, __) => ok(
        '{"CFBundleIdentifier":"test.app","CFBundleExecutable":"Runner","CFBundleSupportedPlatforms":["iPhoneOS"]}'));
    await expectLater(
        inspectArtifact(app.path, DevicePlatform.ios,
            CommandLog(context(directory), runner, const Duration(seconds: 1))),
        throwsFormatException);
  });

  group('iOS signatures', () {
    late Directory app;
    late FakeHost runner;
    late BuildService service;
    String? signatureError;

    setUp(() async {
      app = Directory(p.join(directory.path, 'im_flutter_sdk', 'example',
          'build', 'ios', 'iphonesimulator', 'Runner.app'));
      await app.create(recursive: true);
      await File(p.join(app.path, 'Runner')).writeAsString('simulator-binary');
      signatureError = null;
      runner = FakeHost((exe, args) {
        if (exe == 'flutter' && args.contains('--version'))
          return ok('{"frameworkVersion":"3.47.0"}');
        if (exe == 'flutter' && args.first == 'build') return ok();
        if (exe == 'plutil')
          return ok(
              '{"CFBundleIdentifier":"test.app","CFBundleExecutable":"Runner","CFBundleSupportedPlatforms":["iPhoneSimulator"]}');
        if (exe == 'xcrun' && args.first == 'lipo') return ok('arm64');
        if (exe == 'codesign')
          return signatureError == null
              ? ok('valid on disk')
              : failed(signatureError!);
        throw StateError('Unexpected $exe $args');
      });
      service =
          BuildService(repository: directory, buildRoot: root, runner: runner);
    });

    Future<BuildResult> original({bool disableSigning = false}) async =>
        BuildResult(
            platform: DevicePlatform.ios,
            architectures: ['arm64'],
            applicationId: 'test.app',
            mode: 'debug',
            arguments: [
              ...buildArguments(DevicePlatform.ios),
              if (disableSigning) '--no-codesign'
            ],
            artifact: await fileRef(app.path));

    test('build preserves default signing and verifies nested code', () async {
      final result =
          await service.build(context(directory), DevicePlatform.ios);
      expect(result.isSuccess, isTrue);
      expect(result.data!.arguments, isNot(contains('--no-codesign')));
      expect(runner.calls.where((call) => call.first == 'codesign').single,
          ['codesign', '--verify', '--deep', '--verbose=2', app.path]);
      expect(
          (await service.validate(context(directory, 'validate'), result.data!))
              .isSuccess,
          isTrue);
      expect(runner.calls.last.last, result.data!.artifact.path);
    });

    test('build rejects unsigned nested code before registering a copy',
        () async {
      signatureError = 'code object is not signed at all: Nested.framework';
      final result =
          await service.build(context(directory), DevicePlatform.ios);
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.errors.single.message, contains(signatureError));
      expect(await Directory(p.join(root.path, 'run-1')).exists(), isFalse);
      expect(await File(result.evidence.single.path).readAsString(),
          contains(signatureError));
    });

    test('import rejects missing and invalid signatures before copying',
        () async {
      final build = await original();
      for (final error in [
        'code object is not signed at all',
        'a sealed resource is missing or invalid'
      ]) {
        signatureError = error;
        final result = await service.importBuild(context(directory), build);
        expect(result.isSuccess, isFalse);
        expect(result.data, isNull);
        expect(result.errors.single.message, contains(error));
        expect(await Directory(p.join(root.path, 'run-1')).exists(), isFalse);
      }
    });

    test('installation admission rechecks signatures of the owned artifact',
        () async {
      final imported =
          await service.importBuild(context(directory), await original());
      expect(imported.isSuccess, isTrue);
      runner.calls.clear();
      signatureError = 'invalid signature';
      final result = await service.validate(
          context(directory, 'validate'), imported.data!,
          device: DeviceResult(
              platform: DevicePlatform.ios,
              instance: 'simulator-id',
              deviceId: 'simulator-id',
              observedState: 'Booted',
              checkedAt: DateTime.now(),
              ready: true));
      expect(result.isSuccess, isFalse);
      expect(result.errors.single.message, contains(signatureError));
      expect(runner.calls.last, [
        'codesign',
        '--verify',
        '--deep',
        '--verbose=2',
        imported.data!.artifact.path
      ]);
      expect(runner.calls.where((call) => call.contains('simctl')), isEmpty);
    });

    test('explicitly disabled signing is rejected before inspecting an import',
        () async {
      final result = await service.importBuild(
          context(directory), await original(disableSigning: true));
      expect(result.isSuccess, isFalse);
      expect(result.errors.single.field, 'arguments');
      expect(runner.calls, isEmpty);
      expect(await Directory(p.join(root.path, 'run-1')).exists(), isFalse);
    });
  });

  group('iOS target architecture admission', () {
    Future<BuildResult> artifact(List<String> architectures) async {
      final app = Directory(p.join(root.path, 'run-1', 'ios', 'Runner.app'));
      await app.create(recursive: true);
      await File(p.join(app.path, 'Runner')).writeAsString('simulator-binary');
      return BuildResult(
          platform: DevicePlatform.ios,
          architectures: architectures,
          applicationId: 'test.app',
          mode: 'debug',
          arguments: buildArguments(DevicePlatform.ios),
          artifact: await fileRef(app.path));
    }

    FakeHost iosHost(List<String> artifactArchitectures, String target,
            {Set<String> runnable = const {'arm64', 'x86_64'}}) =>
        FakeHost((exe, args) {
          if (exe == 'plutil')
            return ok(
                '{"CFBundleIdentifier":"test.app","CFBundleExecutable":"Runner","CFBundleSupportedPlatforms":["iPhoneSimulator"]}');
          if (exe == 'xcrun' && args.first == 'lipo')
            return ok(artifactArchitectures.join(' '));
          if (exe == 'codesign') return ok();
          if (exe == 'xcrun' &&
              args.join(' ') == 'simctl getenv simulator-id SIMULATOR_ARCHS')
            return ok(target);
          if (exe == 'xcrun' &&
              args.length == 7 &&
              args[0] == 'simctl' &&
              args[1] == 'spawn' &&
              args[3] == 'simulator-id' &&
              args.sublist(4).join(' ') == 'launchctl print-disabled system') {
            final arch = args[2].substring('--arch='.length);
            return runnable.contains(arch)
                ? ok('disabled services = {}')
                : failed('Unsupported target execution architecture: $arch');
          }
          throw StateError('Unexpected $exe $args');
        });

    Future<OperationResult<BuildResult>> check(
            BuildResult build, FakeHost runner) =>
        BuildService(repository: directory, buildRoot: root, runner: runner)
            .validate(context(directory, 'check-ios'), build,
                device: DeviceResult(
                    platform: DevicePlatform.ios,
                    instance: 'simulator-id',
                    deviceId: 'simulator-id',
                    observedState: 'Booted',
                    checkedAt: DateTime.now(),
                    ready: true));

    test(
        'uses target architecture and a runnable simulator tool, without uname',
        () async {
      final build = await artifact(['arm64']);
      final runner = iosHost(build.architectures, 'arm64 x86_64');
      expect((await check(build, runner)).isSuccess, isTrue);
      expect(runner.calls.where((call) => call.contains('spawn')).single, [
        'xcrun',
        'simctl',
        'spawn',
        '--arch=arm64',
        'simulator-id',
        'launchctl',
        'print-disabled',
        'system'
      ]);
    });

    test('incompatible or missing target architectures reject before spawning',
        () async {
      final build = await artifact(['arm64']);
      for (final target in ['x86_64', '']) {
        final runner = iosHost(build.architectures, target);
        final result = await check(build, runner);
        expect(result.isSuccess, isFalse);
        expect(result.errors.single.field, 'architectures');
        expect(runner.calls.where((call) => call.contains('spawn')), isEmpty);
      }
    });

    test('tries only matching slices and retains failed probe evidence',
        () async {
      final build = await artifact(['arm64', 'x86_64']);
      final runner = iosHost(build.architectures, 'arm64 x86_64 armv7',
          runnable: {'x86_64'});
      final result = await check(build, runner);
      expect(result.isSuccess, isTrue);
      expect(
          runner.calls
              .where((call) => call.contains('spawn'))
              .map((call) => call[3]),
          ['--arch=arm64', '--arch=x86_64']);
      final log = await File(result.evidence.single.path).readAsString();
      expect(log, contains('Unsupported target execution architecture: arm64'));
    });

    test('advertised slices are insufficient when every execution probe fails',
        () async {
      final build = await artifact(['arm64', 'x86_64']);
      final runner = iosHost(build.architectures, 'arm64 x86_64', runnable: {});
      final result = await check(build, runner);
      expect(result.isSuccess, isFalse);
      expect(result.errors.single.field, 'architectures');
      expect(result.errors.single.message, contains('cannot execute'));
      expect(
          runner.calls.where((call) => call.contains('spawn')), hasLength(2));
    });
  });
}
