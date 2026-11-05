import 'package:test/test.dart';

import 'package:flow_runner/expr.dart';

void main() {
  group('expression parsing and evaluation', () {
    Env env() {
      final e = Env();
      e.bind('a', {'success': true, 'data': {'msgId': 'm1', 'n': 2}},
          ok: true);
      e.bind('flag', false, ok: true);
      e.bind('missing', null, ok: false);
      e.bind('list', [10, 20, 30], ok: true);
      return e;
    }

    Object? eval(String src) => evalExpr(parseExpr(src), env());

    test('literals', () {
      expect(eval('true'), isTrue);
      expect(eval('false'), isFalse);
      expect(eval('null'), isNull);
      expect(eval('42'), 42);
      expect(eval("-1.5"), -1.5);
      expect(eval("'hello'"), 'hello');
    });

    test('references and path lookup', () {
      expect(eval(r'$a.success'), isTrue);
      expect(eval(r'$a.data.msgId'), 'm1');
      expect(eval(r'$a.data.n'), 2);
      expect(eval(r'$list.1'), 20);
    });

    test('missing path evaluates to null, not an error', () {
      expect(eval(r'$a.data.nothing'), isNull);
      expect(eval(r'$nonexistent.x'), isNull);
    });

    test('comparisons', () {
      expect(eval(r'$a.data.n == 2'), isTrue);
      expect(eval(r'$a.data.n != 3'), isTrue);
      expect(eval(r'$a.data.n > 1'), isTrue);
      expect(eval(r'$a.data.n >= 2'), isTrue);
      expect(eval(r'$a.data.n < 2'), isFalse);
      expect(eval(r"'abc' == 'abc'"), isTrue);
      expect(eval(r"'b' > 'a'"), isTrue);
    });

    test('loose semantics', () {
      // cross-type equality is false, not an error
      expect(eval(r"'2' == 2"), isFalse);
      expect(eval('2 == 2.0'), isTrue);
      // cross-type ordering is false
      expect(eval(r"'a' < 1"), isFalse);
      expect(eval('null == null'), isTrue);
    });

    test('logic operators and precedence', () {
      expect(eval(r'$a.success and $a.data.n == 2'), isTrue);
      expect(eval(r'$a.success or $flag'), isTrue);
      expect(eval(r'$flag or $a.success and $a.data.n == 2'), isTrue); // and binds tighter
      expect(eval(r'not $flag'), isTrue);
      expect(eval(r'not $a.data.n == 3'), isTrue); // not applies to the comparison
      expect(eval(r'($flag or true) and true'), isTrue);
    });

    test('parse errors', () {
      expect(() => parseExpr('\$a =='), throwsA(isA<ExprError>()));
      expect(() => parseExpr('and'), throwsA(isA<ExprError>()));
      expect(() => parseExpr('\$a extra'), throwsA(isA<ExprError>()));
      expect(() => parseExpr('(1 == 1'), throwsA(isA<ExprError>()));
    });
  });

  group('resolveValue (whole-string reference replacement)', () {
    test('replaces exact refs preserving type', () {
      final env = Env();
      env.bind('x', {'groupId': 'g1'}, ok: true);
      env.bind('n', 7, ok: true);

      expect(resolveValue(r'$x.groupId', env), 'g1');
      expect(resolveValue(r'$n', env), 7);
    });

    test('non-ref strings pass through untouched', () {
      final env = Env();
      expect(resolveValue(r'$x and more', env), r'$x and more');
      expect(resolveValue('plain', env), 'plain');
    });

    test('walks maps and lists', () {
      final env = Env();
      env.bind('g', {'groupId': 'g9'}, ok: true);
      final v = resolveValue({
        'to': r'$g.groupId',
        'nested': {'a': r'$g.groupId'},
        'list': [r'$g.groupId', 'keep'],
      }, env);
      expect(v, {
        'to': 'g9',
        'nested': {'a': 'g9'},
        'list': ['g9', 'keep'],
      });
    });

    test('collectRefs walks the tree', () {
      final refs = collectRefs({
        'a': r'$x.y',
        'b': [r'$z', {'c': r'$w'}],
        'd': 'not a ref',
      });
      expect(refs, {'x', 'z', 'w'});
    });
  });

  group('Env', () {
    test('isOk semantics', () {
      final env = Env();
      env.bind('ok1', 1, ok: true);
      env.bind('bad', null, ok: false);
      expect(env.isOk('ok1'), isTrue);
      expect(env.isOk('bad'), isFalse);
      expect(env.isOk('unknown'), isFalse); // cascading skips rely on this
    });

    test('loop shadowing restores the outer binding', () {
      final env = Env();
      env.bind('i', 'outer', ok: true);
      final token = env.pushShadow('i', 0);
      expect(env.value('i'), 0);
      env.popShadow(token);
      expect(env.value('i'), 'outer');

      // shadowing a fresh name removes it afterwards
      final t2 = env.pushShadow('j', 1);
      expect(env.isBound('j'), isTrue);
      env.popShadow(t2);
      expect(env.isBound('j'), isFalse);
    });
  });
}
