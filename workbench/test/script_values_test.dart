import 'package:example/auto/script_values.dart';
import 'package:example/auto/step_expectation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing reference is distinct from an explicit null', () {
    expect(
        resolveValue(r'$input.value', {
          'input': {'value': null}
        }),
        isNull);
    expect(() => resolveValue(r'$input.missing', {'input': {}}),
        throwsFormatException);
    expect(() => resolveValue(r'$step.foo.msgId', {'step': {}}),
        throwsFormatException);
  });

  test('collection fields must match the same element', () {
    final checks = [
      {
        'path': '',
        'containsItem': {'msgId': 'm1', 'from.userId': 'b'}
      },
    ];
    expect(
        evaluateChecks([
          {
            'msgId': 'm1',
            'from': {'userId': 'a'}
          },
          {
            'msgId': 'm2',
            'from': {'userId': 'b'}
          },
        ], checks)
            .single['passed'],
        isFalse);
    expect(
        evaluateChecks([
          {
            'msgId': 'm1',
            'from': {'userId': 'b'}
          },
        ], checks)
            .single['passed'],
        isTrue);
  });

  test('typos and missing fields cannot silently pass assertions', () {
    expect(
        () => stepResultMatchesExpectation({'success': true}, {'succes': true}),
        throwsFormatException);
    expect(
        evaluateChecks({}, [
          {'path': 'missing', 'equals': null}
        ]).single['passed'],
        isFalse);
    expect(
        () => validateChecks([
              {'path': '', 'equal': 0}
            ]),
        throwsFormatException);
  });

  test('an expected SDK error cannot mask a tool failure or timeout', () {
    for (final kind in ['tool', 'timeout', 'crash']) {
      expect(
          stepResultMatchesExpectation({
            'success': false,
            'error': {'code': 500},
            'failureKind': kind,
          }, {
            'errorCode': 500
          }),
          isFalse);
    }
    expect(
        stepResultMatchesExpectation({
          'success': false,
          'error': {'code': 500},
          'failureKind': 'sdk',
        }, {
          'errorCode': 500
        }),
        isTrue);
  });
}
