import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('flow deadline fails the report and stops later command dispatch',
      () async {
    final directory = await Directory.systemTemp.createTemp('flow-timeout-');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var commands = 0;
    server.listen((request) async {
      Object response = {};
      if (request.uri.path == '/v1/events') response = {'events': []};
      if (request.uri.path == '/v1/finish') {
        // Leave time for an uncancelled interpreter to dispatch its next command.
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      if (request.method == 'POST' && request.uri.path == '/v1/commands') {
        commands++;
        response = {'status': 'accepted'};
      }
      if (request.uri.path.startsWith('/v1/commands/')) {
        response = {'status': 'done', 'success': true};
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      await request.response.close();
    });
    try {
      await File('${directory.path}/commands.json').writeAsString(jsonEncode({
        'steps': [
          {'id': 'later', 'api': 'opaque.operation', 'params': {}}
        ],
      }));
      final flow = File('${directory.path}/flow.yaml');
      await flow.writeAsString('''
name: timeout-regression
flowTimeoutMs: 30
agents:
  a: {endpoint: 'http://127.0.0.1:${server.port}', script: commands.json}
steps:
  - delay: 150
  - cmd: later
    agent: a
''');
      final result = await Process.run(Platform.resolvedExecutable, [
        'run',
        'bin/flow_runner.dart',
        'run',
        flow.path,
        '--report-dir',
        '${directory.path}/reports',
      ]);
      final file = Directory('${directory.path}/reports')
          .listSync(recursive: true)
          .whereType<File>()
          .single;
      final report = jsonDecode(await file.readAsString()) as Map;
      expect(result.exitCode, 1, reason: '${result.stdout}\n${result.stderr}');
      expect(report['summary']['timeout'], 1);
      expect(commands, 0, reason: 'logical timeout must stop later dispatch');
    } finally {
      await server.close(force: true);
      await directory.delete(recursive: true);
    }
  });
}
