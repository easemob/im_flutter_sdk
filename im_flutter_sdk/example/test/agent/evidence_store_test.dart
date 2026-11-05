import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:example/agent/evidence_store.dart';
import 'package:example/log/log_store.dart';

/// EvidenceStore unit tests: subscription, handler-prefix stripping, clear
/// isolation, cursor pagination, overflow/degraded, long-poll wake-up
/// (agent-service §10). Uses the real LogStore singleton.
void main() {
  late LogStore logs;

  setUp(() {
    logs = LogStore.instance;
  });

  test('subscribes to the log stream and keeps events with payload',
      () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    logs.log('api.ChatManager.sendMessage', {'success': true});
    await Future<void>.delayed(Duration.zero);

    expect(evidence.count, 1);
    final event = evidence.query(0).single;
    expect(event.source, 'api.ChatManager.sendMessage');
    expect(event.payload, {'success': true});
    expect(event.seq, greaterThan(0));
  });

  test('listener sources are stripped to the bare callback method name',
      () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    logs.log('ChatEventHandler.onMessageReceived', {'from': 'u1'});
    logs.log('ConnectionEventHandler.onConnected', {});
    logs.log('listeners.registered', {'handlerId': 'api_tester'});
    await Future<void>.delayed(Duration.zero);

    final sources = evidence.query(0).map((e) => e.source).toList();
    expect(sources, contains('onMessageReceived'));
    expect(sources, contains('onConnected'));
    // Non-handler sources pass through unchanged.
    expect(sources, contains('listeners.registered'));
  });

  test('LogStore.clear() only clears the UI view — evidence survives',
      () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    logs.log('api.ChatManager.sendMessage', {'success': true});
    await Future<void>.delayed(Duration.zero);
    final before = evidence.count;
    final lastSeq = evidence.lastSeq;

    logs.clear();
    await Future<void>.delayed(Duration.zero);

    expect(evidence.count, before);
    expect(evidence.lastSeq, lastSeq);
    expect(evidence.query(0).length, before);
  });

  test('exclusive cursor pagination with limit', () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    for (var i = 0; i < 5; i++) {
      logs.log('api.ChatManager.sendMessage', {'i': i});
    }
    await Future<void>.delayed(Duration.zero);

    final page1 = evidence.query(0, limit: 2);
    expect(page1.length, 2);
    final page2 = evidence.query(page1.last.seq, limit: 2);
    expect(page2.length, 2);
    expect(page2.first.seq, greaterThan(page1.last.seq));
    // Empty page keeps the cursor (nothing new after the last event).
    final empty = evidence.query(evidence.lastSeq);
    expect(empty, isEmpty);
  });

  test('overflow drops oldest, advances firstAvailableSeq, marks degraded',
      () async {
    final evidence = EvidenceStore(maxEntries: 3);
    addTearDown(evidence.dispose);

    for (var i = 0; i < 5; i++) {
      logs.log('api.ChatManager.sendMessage', {'i': i});
    }
    await Future<void>.delayed(Duration.zero);

    expect(evidence.count, 3);
    expect(evidence.degraded, isTrue);
    expect(evidence.firstAvailableSeq, evidence.query(0).first.seq);
    // Events before firstAvailableSeq are gone.
    expect(evidence.query(0).length, 3);
  });

  test('queryWithWait wakes up when a new event arrives', () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    logs.log('api.ChatManager.sendMessage', {'i': 0});
    await Future<void>.delayed(Duration.zero);
    final cursor = evidence.lastSeq;

    unawaited(Future<void>.delayed(const Duration(milliseconds: 20)).then((_) {
      logs.log('ConnectionEventHandler.onConnected', {});
    }));

    final events = await evidence.queryWithWait(cursor,
        timeout: const Duration(seconds: 2));
    expect(events, isNotEmpty);
    expect(events.last.source, 'onConnected');
  });

  test('queryWithWait returns an empty page after the timeout', () async {
    final evidence = EvidenceStore();
    addTearDown(evidence.dispose);

    logs.log('api.ChatManager.sendMessage', {'i': 0});
    await Future<void>.delayed(Duration.zero);

    final sw = Stopwatch()..start();
    final events = await evidence.queryWithWait(evidence.lastSeq,
        timeout: const Duration(milliseconds: 50));
    sw.stop();
    expect(events, isEmpty);
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(50));
  });
}
