import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'contracts.dart';
import 'core.dart';

class BuildService {
  BuildService(
      {required this.repository,
      required this.buildRoot,
      HostCommandRunner? runner,
      this.timeout = const Duration(minutes: 15)})
      : runner = runner ?? IoHostCommandRunner();

  final Directory repository;
  final Directory buildRoot;
  final HostCommandRunner runner;
  final Duration timeout;
  static final Set<String> _activeBuilds = {};

  Future<OperationResult<BuildResult>> build(
          OperationContext context, DevicePlatform platform) =>
      _operation(context, (log) async {
        final runId = context.runId;
        if (runId == null) throw ArgumentError('Build requires a run ID');
        final example = p.join(repository.path, 'im_flutter_sdk', 'example');
        final identity = p.normalize(p.absolute(example));
        if (!_activeBuilds.add(identity))
          throw StateError('Example build output is already in use');
        RandomAccessFile? lock;
        try {
          await ensurePrivateDirectory(buildRoot.path);
          final lockFile = File(p.join(buildRoot.path, '.example-build.lock'));
          lock = await lockFile.open(mode: FileMode.append);
          // Non-blocking exclusive locking prevents two owned builds from sharing
          // the example output while it is being built, inspected, and copied.
          await lock.lock(FileLock.exclusive);
          final version = await log.run('flutter', ['--version', '--machine'],
              workingDirectory: example);
          final versionInfo = jsonDecode(version.stdout);
          if (versionInfo is! Map ||
              versionInfo['frameworkVersion'] != '3.47.0') {
            throw StateError('Flutter 3.47.0 is required');
          }
          final arguments = buildArguments(platform);
          await log.run('flutter', arguments, workingDirectory: example);
          final String artifact;
          if (platform == DevicePlatform.android) {
            artifact = p.join(example, 'build', 'app', 'outputs', 'flutter-apk',
                'app-debug.apk');
          } else {
            final output =
                Directory(p.join(example, 'build', 'ios', 'iphonesimulator'));
            if (!await output.exists())
              throw StateError('No simulator build output');
            final apps = await output
                .list(followLinks: false)
                .where((e) => e is Directory && p.extension(e.path) == '.app')
                .toList();
            if (apps.length != 1)
              throw StateError(
                  'Simulator build must produce one .app; found ${apps.length}');
            artifact = apps.single.path;
          }
          final source = await fileRef(artifact, requireInternalLinks: true);
          final metadata = await inspectArtifact(source.path, platform, log);
          final owned = await _copy(context, source, platform);
          return BuildResult(
              platform: platform,
              architectures: metadata.architectures,
              applicationId: metadata.applicationId,
              mode: 'debug',
              arguments: arguments,
              artifact: owned);
        } finally {
          await lock?.close();
          _activeBuilds.remove(identity);
        }
      });

  Future<OperationResult<BuildResult>> importBuild(
          OperationContext context, BuildResult original) =>
      _operation(context, (log) async {
        await validateArtifact(original, log);
        final owned =
            await _copy(context, original.artifact, original.platform);
        return BuildResult(
            platform: original.platform,
            architectures: original.architectures,
            applicationId: original.applicationId,
            mode: original.mode,
            arguments: original.arguments,
            artifact: owned);
      });

  Future<OperationResult<BuildResult>> validate(
          OperationContext context, BuildResult build,
          {DeviceResult? device}) =>
      _operation(context, (log) async {
        final root = p.join(p.absolute(buildRoot.path), context.runId ?? '');
        if (context.runId == null ||
            !p.isWithin(root, p.absolute(build.artifact.path))) {
          throw StateError('Build artifact does not belong to this run');
        }
        await validateArtifact(build, log, device: device);
        return build;
      });

  Future<FileRef> _copy(
      OperationContext context, FileRef source, DevicePlatform platform) async {
    final runId = context.runId;
    if (runId == null) throw ArgumentError('Build copy requires a run ID');
    final root =
        p.join(buildRoot.path, runId, context.operationId, platform.name);
    final destination = p.join(root, p.basename(source.path));
    if (await FileSystemEntity.type(destination, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Build destination already exists');
    }
    await ensurePrivateDirectory(root);
    await _copyEntity(source.path, destination);
    final copied = await fileRef(destination, requireInternalLinks: true);
    await verifyFileRef(source, requireInternalLinks: true);
    if (copied.sha256 != source.sha256)
      throw StateError('Build copy hash differs from source');
    return copied;
  }

  Future<OperationResult<BuildResult>> _operation(OperationContext context,
      Future<BuildResult> Function(CommandLog) action) async {
    final log = CommandLog(context, runner, timeout);
    try {
      final data = await action(log);
      await log.note('artifact', data.toJson());
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.success,
          data: data,
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
                  field: 'build',
                  expected: 'valid owned control-mode artifact',
                  actual: null)
          ],
          evidence: await log.evidence());
    }
  }
}

List<String> buildArguments(DevicePlatform platform) =>
    platform == DevicePlatform.android
        ? ['build', 'apk', '--debug', '--dart-define=API_CONTROL=true']
        : [
            'build',
            'ios',
            '--simulator',
            '--debug',
            '--dart-define=API_CONTROL=true'
          ];

class ArtifactMetadata {
  ArtifactMetadata(this.applicationId, this.architectures);
  final String applicationId;
  final List<String> architectures;
}

Future<ArtifactMetadata> inspectArtifact(
    String artifact, DevicePlatform platform, CommandLog log) async {
  if (platform == DevicePlatform.android) {
    if (await FileSystemEntity.type(artifact, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Android artifact must be an APK file');
    }
    final output =
        await log.run(androidSdkTool('aapt'), ['dump', 'badging', artifact]);
    final package = RegExp(r"^package: name='([^']+)'", multiLine: true)
        .firstMatch(output.stdout)
        ?.group(1);
    final native = RegExp(r'^native-code:\s*(.*)$', multiLine: true)
        .firstMatch(output.stdout)
        ?.group(1);
    final arch = native == null
        ? <String>[]
        : RegExp(r"'([^']+)'")
            .allMatches(native)
            .map((e) => e.group(1)!)
            .toList();
    if (package == null || package.isEmpty || arch.isEmpty)
      throw const FormatException('APK package or architectures missing');
    if (!output.stdout.contains('application-debuggable'))
      throw StateError('APK is not debuggable');
    return ArtifactMetadata(package, arch);
  }
  if (await FileSystemEntity.type(artifact, followLinks: false) !=
      FileSystemEntityType.directory) {
    throw StateError('iOS artifact must be an app directory');
  }
  final output = await log.run('plutil',
      ['-convert', 'json', '-o', '-', p.join(artifact, 'Info.plist')]);
  final plist = jsonDecode(output.stdout);
  if (plist is! Map ||
      plist['CFBundleIdentifier'] is! String ||
      plist['CFBundleExecutable'] is! String ||
      plist['CFBundleSupportedPlatforms'] is! List ||
      !(plist['CFBundleSupportedPlatforms'] as List)
          .contains('iPhoneSimulator')) {
    throw const FormatException(
        'Artifact is not an identified iOS simulator app');
  }
  final executable = plist['CFBundleExecutable'] as String;
  if (executable.isEmpty || p.basename(executable) != executable)
    throw const FormatException('Invalid app executable');
  final archResult =
      await log.run('xcrun', ['lipo', '-archs', p.join(artifact, executable)]);
  final architectures = archResult.stdout
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (architectures.isEmpty)
    throw const FormatException('iOS executable architectures missing');
  final applicationId = plist['CFBundleIdentifier'] as String;
  if (applicationId.isEmpty)
    throw const FormatException('iOS application ID missing');
  await log.run('codesign', ['--verify', '--deep', '--verbose=2', artifact]);
  return ArtifactMetadata(applicationId, architectures);
}

Future<void> validateArtifact(BuildResult build, CommandLog log,
    {DeviceResult? device}) async {
  Never reject(
          String field, Object? expected, Object? actual, String message) =>
      throw ContractViolation(
          producer: 'build',
          consumer: 'installation',
          operationId: log.context.operationId,
          field: field,
          expected: expected,
          actual: actual,
          rework: 'build',
          message: message);
  BuildResult.fromJson(build.toJson());
  if (build.mode != 'debug' ||
      !build.arguments.contains('--debug') ||
      !build.arguments.contains('--dart-define=API_CONTROL=true') ||
      build.arguments.any((e) => e.contains('API_SCRIPT')) ||
      build.arguments.where((e) => e.contains('API_CONTROL')).length != 1 ||
      build.arguments.length < 2 ||
      build.arguments[0] != 'build' ||
      build.arguments[1] !=
          (build.platform == DevicePlatform.android ? 'apk' : 'ios') ||
      (build.platform == DevicePlatform.ios &&
          (!build.arguments.contains('--simulator') ||
              build.arguments.contains('--no-codesign')))) {
    reject('arguments', buildArguments(build.platform), build.arguments,
        'Build parameters do not enable exclusive debug control mode');
  }
  final String actualHash;
  try {
    actualHash =
        await hashPath(build.artifact.path, requireInternalLinks: true);
  } catch (error) {
    reject('artifact.path', build.artifact.path, null,
        'Artifact is missing or invalid: $error');
  }
  if (actualHash != build.artifact.sha256) {
    reject('artifact.sha256', build.artifact.sha256, actualHash,
        'Artifact hash differs from registered build');
  }
  final metadata =
      await inspectArtifact(build.artifact.path, build.platform, log);
  final declared = build.architectures.toSet();
  final actual = metadata.architectures.toSet();
  if (metadata.applicationId != build.applicationId ||
      declared.length != actual.length ||
      !declared.containsAll(actual))
    reject(
        'applicationId/architectures',
        {
          'applicationId': build.applicationId,
          'architectures': build.architectures
        },
        {
          'applicationId': metadata.applicationId,
          'architectures': metadata.architectures
        },
        'Artifact metadata differs from registered build');
  if (device != null) {
    if (!device.ready ||
        device.deviceId == null ||
        device.platform != build.platform) {
      reject('platform', device.platform.name, build.platform.name,
          'Build platform and ready device do not match');
    }
    final HostCommandResult architecture;
    if (device.platform == DevicePlatform.android) {
      architecture = await log.run('adb', [
        '-s',
        device.deviceId!,
        'shell',
        'getprop',
        'ro.product.cpu.abilist'
      ]);
    } else {
      architecture = await log.run(
          'xcrun', ['simctl', 'getenv', device.deviceId!, 'SIMULATOR_ARCHS']);
    }
    final supported =
        architecture.stdout.trim().split(RegExp(r'[,\s]+')).toSet();
    final candidates = supported.intersection(actual);
    if (candidates.isEmpty)
      reject('architectures', supported.toList(), actual.toList(),
          'Artifact architecture is incompatible with target device');
    if (device.platform == DevicePlatform.ios) {
      // Runtime slices alone do not prove the host can execute them. Probe a
      // read-only simulator tool with the same explicit architecture instead of
      // relying on a host binary such as uname (absent from the runtime PATH).
      var executable = false;
      for (final candidate in candidates) {
        final probe = await log.run(
            'xcrun',
            [
              'simctl',
              'spawn',
              '--arch=$candidate',
              device.deviceId!,
              'launchctl',
              'print-disabled',
              'system'
            ],
            allowFailure: true);
        if (probe.exitCode == 0) {
          executable = true;
          break;
        }
      }
      if (!executable)
        reject('architectures', candidates.toList(), <String>[],
            'Target cannot execute any matching simulator architecture');
    }
  }
}

Future<void> _copyEntity(String source, String destination) async {
  final type = await FileSystemEntity.type(source, followLinks: false);
  if (type == FileSystemEntityType.file) {
    await File(source).copy(destination);
  } else if (type == FileSystemEntityType.link) {
    await Link(destination).create(await Link(source).target());
  } else if (type == FileSystemEntityType.directory) {
    await Directory(destination).create();
    await for (final entity in Directory(source).list(followLinks: false)) {
      await _copyEntity(
          entity.path, p.join(destination, p.basename(entity.path)));
    }
  } else {
    throw StateError('Unsupported artifact entity $source');
  }
}

String androidSdkTool(String name) {
  final root = Platform.environment['ANDROID_SDK_ROOT'] ??
      Platform.environment['ANDROID_HOME'] ??
      p.join(Platform.environment['HOME'] ?? '', 'Library', 'Android', 'sdk');
  if (name == 'avdmanager') {
    final path = p.join(root, 'cmdline-tools', 'latest', 'bin', name);
    return File(path).existsSync() ? path : name;
  }
  final directory = Directory(p.join(root, 'build-tools'));
  if (directory.existsSync()) {
    final paths = directory
        .listSync()
        .whereType<Directory>()
        .map((d) => p.join(d.path, name))
        .where((path) => File(path).existsSync())
        .toList()
      ..sort();
    if (paths.isNotEmpty) return paths.last;
  }
  return name;
}
