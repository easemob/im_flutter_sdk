import 'dart:async';
import 'dart:io';

import 'package:testing_v2/src/core.dart';

typedef CommandHandler = FutureOr<HostCommandResult> Function(
    String, List<String>);

class FakeHost implements HostCommandRunner {
  FakeHost(this.handler, {this.onStart});
  final CommandHandler handler;
  final FutureOr<HostProcess> Function(String, List<String>)? onStart;
  final List<List<String>> calls = [];
  final List<ProcessStartMode> startModes = [];
  @override
  Future<HostCommandResult> run(String executable, List<String> arguments,
      {String? workingDirectory,
      Map<String, String>? environment,
      required Duration timeout}) async {
    calls.add([executable, ...arguments]);
    return handler(executable, arguments);
  }

  @override
  Future<HostProcess> start(String executable, List<String> arguments,
      {String? workingDirectory,
      Map<String, String>? environment,
      ProcessStartMode mode = ProcessStartMode.normal}) async {
    calls.add([executable, ...arguments]);
    startModes.add(mode);
    if (onStart == null)
      throw StateError('Unexpected process: $executable $arguments');
    return onStart!(executable, arguments);
  }
}

HostCommandResult ok([String output = '']) =>
    HostCommandResult(exitCode: 0, stdout: output, stderr: '', timedOut: false);
HostCommandResult failed([String error = 'failure']) =>
    HostCommandResult(exitCode: 1, stdout: '', stderr: error, timedOut: false);

class FakeProcess extends HostProcess {
  final out = StreamController<List<int>>();
  final err = StreamController<List<int>>();
  final done = Completer<int>();
  bool killed = false;
  @override
  int get pid => 123;
  @override
  Stream<List<int>> get stdout => out.stream;
  @override
  Stream<List<int>> get stderr => err.stream;
  @override
  Future<int> get exitCode => done.future;
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    if (!done.isCompleted) done.complete(0);
    out.close();
    err.close();
    return true;
  }
}

OperationContext context(Directory directory, [String operation = 'op-1']) =>
    OperationContext(
        runId: 'run-1',
        operationId: operation,
        tmpDirectory: directory,
        redactor: SecretRedactor(['sensitive-token']));
