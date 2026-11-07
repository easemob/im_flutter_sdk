import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/core.dart';

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-core-');
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('directory digest uses sorted entries without following links',
      () async {
    await Directory(p.join(root.path, 'z')).create();
    await File(p.join(root.path, 'z', 'b')).writeAsString('second');
    await File(p.join(root.path, 'a')).writeAsString('first');
    await Link(p.join(root.path, 'alias')).create('a');
    final expected = sha256
        .convert(utf8.encode(jsonEncode([
          ['a', 'file', sha256.convert(utf8.encode('first')).toString()],
          ['alias', 'link', 'a'],
          ['z', 'directory', null],
          ['z/b', 'file', sha256.convert(utf8.encode('second')).toString()],
        ])))
        .toString();
    expect(await hashPath(root.path, requireInternalLinks: true), expected);
    final registered = await fileRef(root.path);
    await verifyFileRef(registered);
    await File(p.join(root.path, 'a')).writeAsString('replaced');
    await expectLater(
        () => verifyFileRef(registered), throwsA(isA<FileSystemException>()));
  });

  test('build links cannot escape lexically or through an intermediate link',
      () async {
    final artifact = await Directory(p.join(root.path, 'app')).create();
    await File(p.join(root.path, 'outside')).writeAsString('outside');
    await Link(p.join(artifact.path, 'outside')).create('../outside');
    await hashPath(artifact.path);
    await expectLater(() => hashPath(artifact.path, requireInternalLinks: true),
        throwsA(isA<FileSystemException>()));
    await Link(p.join(artifact.path, 'outside')).delete();
    await Link(p.join(artifact.path, 'redirect')).create(root.path);
    await Link(p.join(artifact.path, 'chain')).create('redirect/outside');
    await expectLater(() => hashPath(artifact.path, requireInternalLinks: true),
        throwsA(isA<FileSystemException>()));
  });

  test('private writes replace atomically and retain Unix permissions',
      () async {
    final target = p.join(root.path, 'private', 'run.json');
    await writePrivateJson(target, {'generation': 1});
    await writePrivateJson(target, {'generation': 2});
    expect(jsonDecode(await File(target).readAsString()), {'generation': 2});
    expect((await File(target).stat()).mode & 0x1ff, 0x180);
    expect((await Directory(p.dirname(target)).stat()).mode & 0x1ff, 0x1c0);
    expect((await Directory(p.dirname(target)).list().toList()).length, 1);
  });

  test('private write rejects links without modifying their target', () async {
    final original = File(p.join(root.path, 'original'));
    await original.writeAsString('keep');
    final link = p.join(root.path, 'link');
    await Link(link).create(original.path);
    await expectLater(() => writePrivateFile(link, 'replace'),
        throwsA(isA<FileSystemException>()));
    expect(await original.readAsString(), 'keep');
  });

  test(
      'redaction removes secrets from nested data and free text without mutating input',
      () {
    final redact = SecretRedactor(['known-secret']);
    final input = <String, Object?>{
      'error': 'failed with access-value and known-secret',
      'nested': [
        {'access_token': 'access-value', 'clientSecret': 'secret-value'}
      ],
      'steps': [
        {'status': 'failed', 'actual': 'secret-value'}
      ],
    };
    final sanitized = jsonEncode(redact.sanitize(input));
    expect(sanitized, isNot(contains('access-value')));
    expect(sanitized, isNot(contains('known-secret')));
    expect(sanitized, isNot(contains('secret-value')));
    expect(sanitized, contains('failed'));
    expect(input['error'], contains('access-value'));
    expect(redact.text('Authorization: Bearer never-registered'),
        isNot(contains('never-registered')));
    expect(redact.text('token=fresh-value clientSecret="fresh secret"'),
        isNot(contains('fresh')));
  });

  test('host command preserves output, exit status and rejects invalid timeout',
      () async {
    const runner = IoHostCommandRunner();
    final result = await runner.run(
        '/bin/sh', ['-c', 'printf stdout; printf stderr >&2; exit 7'],
        timeout: const Duration(seconds: 5));
    expect(result.stdout, 'stdout');
    expect(result.stderr, 'stderr');
    expect(result.exitCode, 7);
    expect(result.timedOut, false);
    expect(() => runner.run('/bin/true', [], timeout: Duration.zero),
        throwsArgumentError);
  });

  test('host command timeout is bounded and not reported as success', () async {
    const runner = IoHostCommandRunner();
    final watch = Stopwatch()..start();
    final result = await runner.run('/bin/sleep', ['10'],
        timeout: const Duration(milliseconds: 50));
    expect(result.timedOut, true);
    expect(result.exitCode, isNot(0));
    expect(watch.elapsed, lessThan(const Duration(seconds: 6)));
  });
}
