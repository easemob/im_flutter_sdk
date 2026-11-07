import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'contracts.dart';

class OperationContext {
  const OperationContext(
      {required this.runId,
      required this.operationId,
      required this.tmpDirectory,
      required this.redactor});
  final String? runId;
  final String operationId;
  final Directory tmpDirectory;
  final SecretRedactor redactor;
}

Future<String> hashPath(String path,
    {bool requireInternalLinks = false}) async {
  final root = p.normalize(p.absolute(path));
  final type = await FileSystemEntity.type(root, followLinks: false);
  if (type == FileSystemEntityType.file) {
    return (await sha256.bind(File(root).openRead()).first).toString();
  }
  if (type != FileSystemEntityType.directory) {
    throw FileSystemException('Expected regular file or directory', root);
  }
  final entries = <List<Object?>>[];
  await for (final entity
      in Directory(root).list(recursive: true, followLinks: false)) {
    final relative =
        p.relative(entity.path, from: root).split(p.separator).join('/');
    if (entity is File) {
      entries.add([relative, 'file', await hashPath(entity.path)]);
    } else if (entity is Directory) {
      entries.add([relative, 'directory', null]);
    } else if (entity is Link) {
      final target = await entity.target();
      if (requireInternalLinks) {
        final lexical = p.normalize(p.isAbsolute(target)
            ? target
            : p.join(p.dirname(entity.path), target));
        if (lexical != root && !p.isWithin(root, lexical)) {
          throw FileSystemException(
              'Build link escapes its artifact', entity.path);
        }
        final resolved = await entity.resolveSymbolicLinks();
        final resolvedRoot = await Directory(root).resolveSymbolicLinks();
        if (resolved != resolvedRoot && !p.isWithin(resolvedRoot, resolved)) {
          throw FileSystemException(
              'Build link resolves outside its artifact', entity.path);
        }
      }
      entries.add([relative, 'link', target]);
    } else {
      throw FileSystemException('Unsupported artifact entry', entity.path);
    }
  }
  entries.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  return sha256.convert(utf8.encode(jsonEncode(entries))).toString();
}

Future<FileRef> fileRef(String path,
        {bool requireInternalLinks = false}) async =>
    FileRef(
        path: p.normalize(p.absolute(path)),
        sha256:
            await hashPath(path, requireInternalLinks: requireInternalLinks));

Future<void> verifyFileRef(FileRef reference,
    {bool requireInternalLinks = false}) async {
  reference.validate();
  final actual = await hashPath(reference.path,
      requireInternalLinks: requireInternalLinks);
  if (actual != reference.sha256) {
    throw FileSystemException(
        'Artifact SHA-256 does not match registered delivery', reference.path);
  }
}

Future<void> _permissions(String path, String mode) async {
  if (Platform.isWindows)
    throw UnsupportedError('Private Unix permissions are required');
  final result = await Process.run('/bin/chmod', [mode, path]);
  if (result.exitCode != 0)
    throw FileSystemException('Cannot set private permissions', path);
}

Future<void> ensurePrivateDirectory(String path) async {
  final directory = Directory(p.normalize(p.absolute(path)));
  final type = await FileSystemEntity.type(directory.path, followLinks: false);
  if (type == FileSystemEntityType.link) {
    throw FileSystemException(
        'Private directory cannot be a symbolic link', directory.path);
  }
  if (type == FileSystemEntityType.notFound) {
    if (!await directory.parent.exists())
      await ensurePrivateDirectory(directory.parent.path);
    await directory.create();
  } else if (type != FileSystemEntityType.directory) {
    throw FileSystemException(
        'Private directory path is not a directory', directory.path);
  }
  await _permissions(directory.path, '700');
}

Future<void> writePrivateFile(String path, String content) async {
  final target = File(p.normalize(p.absolute(path)));
  await ensurePrivateDirectory(target.parent.path);
  if (await FileSystemEntity.type(target.path, followLinks: false) ==
      FileSystemEntityType.link) {
    throw FileSystemException(
        'Private file cannot replace a symbolic link', target.path);
  }
  final random = Random.secure();
  final temp = File(
      '${target.path}.tmp-${pid}-${random.nextInt(1 << 32).toRadixString(16)}');
  try {
    await temp.create(exclusive: true);
    await _permissions(temp.path, '600');
    await temp.writeAsString(content, flush: true);
    await temp.rename(target.path);
  } finally {
    if (await temp.exists()) await temp.delete();
  }
}

Future<void> writePrivateJson(String path, Object? value) => writePrivateFile(
    path,
    '${const JsonEncoder.withIndent('  ').convert(encodeContract(value))}\n');

class SecretRedactor {
  SecretRedactor([Iterable<String> secrets = const []]) {
    secrets.forEach(add);
  }
  final Set<String> _secrets = {};
  static final RegExp _sensitive = RegExp(
    r'^(token|usertoken|accesstoken|refreshtoken|apptoken|applicationtoken|password|passwd|secret|clientsecret|clientid|authorization|pairingtoken|controltoken|credential|credentials|apikey|privatekey)$',
    caseSensitive: false,
  );
  bool _secretKey(String key) =>
      _sensitive.hasMatch(key.replaceAll(RegExp(r'[_\-]'), ''));
  void add(String value) {
    if (value.isNotEmpty) _secrets.add(value);
  }

  void addFrom(Object? value) {
    if (value is Map<String, Object?>) {
      for (final entry in value.entries) {
        if (_secretKey(entry.key)) _learn(entry.value);
        addFrom(entry.value);
      }
    } else if (value is List<Object?>) {
      value.forEach(addFrom);
    }
  }

  void _learn(Object? value) {
    if (value is String) add(value);
    if (value is List<Object?>) value.forEach(_learn);
    if (value is Map<String, Object?>) value.values.forEach(_learn);
  }

  String text(String value) {
    var result = value;
    final ordered = _secrets.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final secret in ordered) {
      result = result.replaceAll(secret, '[REDACTED]');
    }
    result = result.replaceAllMapped(
        RegExp(r'(Bearer\s+)[^\s"\x27,}]+', caseSensitive: false),
        (match) => '${match[1]}[REDACTED]');
    result = result.replaceAllMapped(
        RegExp(
            r'''((?:"|')?(?:user_?token|access_?token|refresh_?token|app_?token|token|client_?secret|client_?id|password|secret|pairing_?token|control_?token)(?:"|')?\s*[:=]\s*)(?:"[^"\r\n]*"|'[^'\r\n]*'|[^\s,;}]+)''',
            caseSensitive: false),
        (match) => '${match[1]}[REDACTED]');
    return result;
  }

  Object? sanitize(Object? value) {
    final encoded = encodeContract(value);
    addFrom(encoded);
    return _sanitize(encoded);
  }

  Object? _sanitize(Object? value) {
    if (value is String) return text(value);
    if (value is List<Object?>) return value.map(_sanitize).toList();
    if (value is Map<String, Object?>) {
      return value.map((key, item) => MapEntry(key,
          _secretKey(key) && item != null ? '[REDACTED]' : _sanitize(item)));
    }
    if (value is JsonContract) return _sanitize(value.toJson());
    return value;
  }
}

class HostCommandResult {
  const HostCommandResult(
      {required this.exitCode,
      required this.stdout,
      required this.stderr,
      required this.timedOut});
  final int? exitCode;
  final String stdout;
  final String stderr;
  final bool timedOut;
}

abstract class HostProcess {
  int get pid;
  Stream<List<int>> get stdout;
  Stream<List<int>> get stderr;
  Future<int> get exitCode;
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]);
  Future<void> close({Duration timeout = const Duration(seconds: 2)}) async {
    kill();
    try {
      await exitCode.timeout(timeout);
    } on TimeoutException {
      kill(ProcessSignal.sigkill);
      try {
        await exitCode.timeout(timeout);
      } on TimeoutException {/* Still unknown. */}
    }
  }
}

abstract interface class HostCommandRunner {
  Future<HostCommandResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    required Duration timeout,
  });
  Future<HostProcess> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    ProcessStartMode mode = ProcessStartMode.normal,
  });
}

class IoHostCommandRunner implements HostCommandRunner {
  const IoHostCommandRunner();
  @override
  Future<HostProcess> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async =>
      _IoHostProcess(await Process.start(executable, arguments,
          workingDirectory: workingDirectory,
          environment: environment,
          runInShell: false,
          mode: mode));

  @override
  Future<HostCommandResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    required Duration timeout,
  }) async {
    if (timeout <= Duration.zero)
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    final process = await start(executable, arguments,
        workingDirectory: workingDirectory, environment: environment);
    final output = StringBuffer();
    final errors = StringBuffer();
    final stdoutDone = Completer<void>();
    final stderrDone = Completer<void>();
    final subscriptions = <StreamSubscription<String>>[
      process.stdout
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(output.write, onError: (Object error) {
        if (!stdoutDone.isCompleted) stdoutDone.completeError(error);
      }, onDone: () {
        if (!stdoutDone.isCompleted) stdoutDone.complete();
      }),
      process.stderr
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(errors.write, onError: (Object error) {
        if (!stderrDone.isCompleted) stderrDone.completeError(error);
      }, onDone: () {
        if (!stderrDone.isCompleted) stderrDone.complete();
      }),
    ];
    // Attach errors before awaiting the exit future.
    final drained = Future.wait([stdoutDone.future, stderrDone.future]);
    Object? streamError;
    final drainObserved = drained.catchError((Object error) {
      streamError = error;
      return <void>[];
    });
    int? code;
    var timedOut = false;
    try {
      code = await process.exitCode.timeout(timeout);
    } on TimeoutException {
      timedOut = true;
      await process.close();
      try {
        code =
            await process.exitCode.timeout(const Duration(milliseconds: 100));
      } on TimeoutException {/* A missing exit code remains null. */}
    } finally {
      try {
        await drainObserved.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        errors.writeln('Output collection did not close within its bound.');
      }
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    }
    if (streamError != null)
      errors.writeln('Output collection error: $streamError');
    return HostCommandResult(
        exitCode: code,
        stdout: output.toString(),
        stderr: errors.toString(),
        timedOut: timedOut);
  }
}

class _IoHostProcess extends HostProcess {
  _IoHostProcess(this.process);
  final Process process;
  @override
  int get pid => process.pid;
  @override
  Stream<List<int>> get stdout => process.stdout;
  @override
  Stream<List<int>> get stderr => process.stderr;
  @override
  Future<int> get exitCode => process.exitCode;
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) =>
      process.kill(signal);
}

// Shared by host-operation modules; it never interprets SDK or case data.
class CommandLog {
  CommandLog(this.context, this.runner, this.timeout)
      : deadline = DateTime.now().add(timeout);
  final OperationContext context;
  final HostCommandRunner runner;
  final Duration timeout;
  final DateTime deadline;
  int _sequence = 0;
  final List<Map<String, Object?>> _records = [];
  String get path =>
      p.join(context.tmpDirectory.path, '${context.operationId}-host.json');

  Future<void> note(String event, Map<String, Object?> fields) async {
    _records.add({
      'time': DateTime.now().toUtc().toIso8601String(),
      'runId': context.runId,
      'operationId': context.operationId,
      'event': event,
      ...fields
    });
    await writePrivateJson(path, context.redactor.sanitize(_records));
  }

  Future<HostCommandResult> run(String executable, List<String> arguments,
      {String? workingDirectory,
      bool allowFailure = false,
      Duration? limit}) async {
    final sequence = ++_sequence;
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero)
      throw TimeoutException('Host operation deadline exceeded');
    final requested = limit ?? timeout;
    final usedTimeout = requested < remaining ? requested : remaining;
    await note('start', {
      'sequence': sequence,
      'executable': executable,
      'arguments': arguments,
      'workingDirectory': workingDirectory,
      'timeoutMs': usedTimeout.inMilliseconds
    });
    final timer = Stopwatch()..start();
    HostCommandResult result;
    try {
      result = await runner.run(executable, arguments,
          workingDirectory: workingDirectory, timeout: usedTimeout);
    } catch (error, stack) {
      await note('end', {
        'sequence': sequence,
        'exitCode': null,
        'timedOut': error is TimeoutException,
        'elapsedMs': timer.elapsedMilliseconds,
        'error': '$error',
        'stack': '$stack',
        'result': 'notStartedOrUnknown'
      });
      rethrow;
    }
    await note('end', {
      'sequence': sequence,
      'exitCode': result.exitCode,
      'timedOut': result.timedOut,
      'elapsedMs': timer.elapsedMilliseconds,
      'stdout': result.stdout,
      'stderr': result.stderr
    });
    if (result.timedOut || (!allowFailure && result.exitCode != 0)) {
      throw StateError(
          '$executable failed: exit=${result.exitCode}, timeout=${result.timedOut}, ${context.redactor.text(result.stderr)}');
    }
    return result;
  }

  Future<List<EvidenceRef>> evidence() async => await File(path).exists()
      ? [EvidenceRef(path: p.absolute(path), location: context.operationId)]
      : [];
}
