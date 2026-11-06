/// Expression parsing, loose evaluation and reference resolution.
///
/// Grammar (deliberately minimal, not Turing-complete):
///
/// ```text
/// or      := and ('or' and)*
/// and     := cmp ('and' cmp)*
/// cmp     := 'not' cmp | '(' or ')' | operand [op operand]
/// operand := number | 'string' | true | false | null | $ref.path
/// op      := == != > >= < <=
/// ```
///
/// Loose semantics: a missing reference path evaluates to null (no error);
/// cross-type `==` is false; ordering operators only work within num or
/// within String, otherwise false. Truthiness: null and false are falsy,
/// everything else is truthy.
library;

import 'global_data.dart';

// ---------------------------------------------------------------------------
// Expression AST
// ---------------------------------------------------------------------------

sealed class Expr {
  const Expr();
}

class Literal extends Expr {
  const Literal(this.value);

  final Object? value;
}

/// Reference like `$msg_a.data.msgId` or `$agents.bob.userId`.
class Ref extends Expr {
  const Ref(this.path);

  final List<String> path;
}

class NotExpr extends Expr {
  const NotExpr(this.inner);

  final Expr inner;
}

class AndExpr extends Expr {
  const AndExpr(this.operands);

  final List<Expr> operands;
}

class OrExpr extends Expr {
  const OrExpr(this.operands);

  final List<Expr> operands;
}

class CompareExpr extends Expr {
  const CompareExpr(this.op, this.left, this.right);

  final String op;
  final Expr left;
  final Expr right;
}

class ExprError implements Exception {
  ExprError(this.message, [this.source]);

  final String message;
  final String? source;

  @override
  String toString() =>
      'expression error: $message${source == null ? '' : ' in "$source"'}';
}

// ---------------------------------------------------------------------------
// Tokenizer
// ---------------------------------------------------------------------------

const _keywords = {'and', 'or', 'not', 'true', 'false', 'null'};
const _ops = {'==', '!=', '>=', '<=', '>', '<', '(', ')'};

class _Tok {
  _Tok(this.kind, this.text, this.value);

  final String kind; // num | str | ref | ident | op | eof
  final String text;
  final Object? value;
}

List<_Tok> _tokenize(String src) {
  final toks = <_Tok>[];
  var i = 0;
  while (i < src.length) {
    final c = src[i];
    if (c == ' ' || c == '\t') {
      i++;
      continue;
    }
    // $ref.path — no '^' anchor: matchAsPrefix already anchors at [i],
    // and '^' would only ever match the absolute start of the string.
    if (c == r'$') {
      final m = RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)*')
          .matchAsPrefix(src, i)!;
      toks.add(_Tok('ref', m[0]!, null));
      i = m.end;
      continue;
    }
    // number (no leading sign here; '-' handled as part of number start)
    if (c == '-' || (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39)) {
      final m = RegExp(r'-?\d+(\.\d+)?').matchAsPrefix(src, i)!;
      final v = num.tryParse(m[0]!);
      if (v == null) throw ExprError('bad number "$m"', src);
      toks.add(_Tok('num', m[0]!, v));
      i = m.end;
      continue;
    }
    // 'string'
    if (c == "'") {
      final close = src.indexOf("'", i + 1);
      if (close < 0) throw ExprError('unterminated string', src);
      final s = src.substring(i + 1, close);
      toks.add(_Tok('str', s, s));
      i = close + 1;
      continue;
    }
    // identifier / keyword
    if (RegExp(r'[A-Za-z_]').hasMatch(c)) {
      final m = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').matchAsPrefix(src, i)!;
      final w = m[0]!;
      toks.add(_Tok(_keywords.contains(w) ? w : 'ident', w, null));
      i = m.end;
      continue;
    }
    // operators
    var matched = false;
    for (final op in _ops) {
      if (src.startsWith(op, i)) {
        toks.add(_Tok('op', op, null));
        i += op.length;
        matched = true;
        break;
      }
    }
    if (matched) continue;
    throw ExprError('unexpected character "$c"', src);
  }
  toks.add(_Tok('eof', '', null));
  return toks;
}

// ---------------------------------------------------------------------------
// Parser (recursive descent)
// ---------------------------------------------------------------------------

class _Parser {
  _Parser(this.src) : _toks = _tokenize(src);

  final String src;
  final List<_Tok> _toks;
  int _pos = 0;

  _Tok get _cur => _toks[_pos];

  void _advance() => _pos++;

  Expr parse() {
    final e = _or();
    if (_cur.kind != 'eof') {
      throw ExprError('unexpected trailing input "${_cur.text}"', src);
    }
    return e;
  }

  Expr _or() {
    final first = _and();
    final ops = [first];
    while (_cur.kind == 'or') {
      _advance();
      ops.add(_and());
    }
    return ops.length == 1 ? first : OrExpr(ops);
  }

  Expr _and() {
    final first = _cmp();
    final ops = [first];
    while (_cur.kind == 'and') {
      _advance();
      ops.add(_cmp());
    }
    return ops.length == 1 ? first : AndExpr(ops);
  }

  Expr _cmp() {
    if (_cur.kind == 'not') {
      _advance();
      return NotExpr(_cmp());
    }
    if (_cur.kind == 'op' && _cur.text == '(') {
      _advance();
      final inner = _or();
      if (!(_cur.kind == 'op' && _cur.text == ')')) {
        throw ExprError('missing )', src);
      }
      _advance();
      return inner;
    }
    final left = _operand();
    if (_cur.kind == 'op' &&
        _ops.contains(_cur.text) &&
        _cur.text != '(' &&
        _cur.text != ')') {
      final op = _cur.text;
      _advance();
      final right = _operand();
      return CompareExpr(op, left, right);
    }
    return left;
  }

  Expr _operand() {
    final t = _cur;
    switch (t.kind) {
      case 'num':
      case 'str':
        _advance();
        return Literal(t.value);
      case 'true':
        _advance();
        return const Literal(true);
      case 'false':
        _advance();
        return const Literal(false);
      case 'null':
        _advance();
        return const Literal(null);
      case 'ref':
        _advance();
        return Ref(refPath(t.text));
      default:
        throw ExprError(
            'unexpected token "${t.text.isEmpty ? "<eof>" : t.text}"', src);
    }
  }
}

/// Parse `$name.a.b.0` into `['name', 'a', 'b', '0']` (without `$`).
List<String> refPath(String ref) {
  if (!ref.startsWith(r'$')) throw ExprError('not a reference: $ref', ref);
  return ref.substring(1).split('.');
}

/// Parse an expression string, e.g. `$msg_a.success == true`.
Expr parseExpr(String src) => _Parser(src).parse();

// ---------------------------------------------------------------------------
// Variable environment
// ---------------------------------------------------------------------------

/// Flow variable table. Also tracks, per binding, whether the producing
/// step succeeded — the basis of the skip-on-failed-deps semantics.
class Env {
  GlobalData? global;
  final Map<String, Object?> _vars = {};
  final Map<String, bool> _ok = {};

  static Object? dig(Object? v, List<String> path) {
    var cur = v;
    for (final key in path) {
      if (cur is Map) {
        cur = cur[key];
      } else if (cur is List) {
        final i = int.tryParse(key);
        if (i == null || i < 0 || i >= cur.length) return null;
        cur = cur[i];
      } else {
        return null;
      }
    }
    return cur;
  }

  /// Look up `$a.b.0` given the full path including the variable name.
  Object? lookup(List<String> path) {
    if (path.first == 'global') {
      if (global == null) {
        throw const FormatException('Global data was not supplied');
      }
      return global!.read(path.join('.'));
    }
    return dig(_vars[path.first], path.sublist(1));
  }

  /// True when the variable is bound by a successful producer (or is a
  /// built-in). Unknown variables are NOT ok: cascading skips rely on this.
  bool isOk(String name) =>
      name == 'global' ? global != null : _ok[name] ?? false;

  bool isBound(String name) => _vars.containsKey(name);

  Object? value(String name) => _vars[name];

  void bind(String name, Object? value, {required bool ok}) {
    if (name == 'global' || GlobalData.isPath(name)) {
      throw const FormatException(
          'global is reserved for runtime data and output bindings');
    }
    _vars[name] = value;
    _ok[name] = ok;
  }

  /// Bind a built-in variable (always considered successful).
  void bindBuiltin(String name, Object? value) {
    _vars[name] = value;
    _ok[name] = true;
  }

  /// Save the current binding so a loop variable can shadow it; returns
  /// the restore token (null when the name was unbound).
  Object? pushShadow(String name, Object? value) {
    if (name == 'global') throw const FormatException('global is reserved');
    final old = _Shadow(name, _vars.containsKey(name), _vars[name], _ok[name]);
    _vars[name] = value;
    _ok[name] = true;
    return old;
  }

  void popShadow(Object? token) {
    if (token is! _Shadow) return;
    if (token.wasBound) {
      _vars[token.name] = token.oldValue;
      _ok[token.name] = token.oldOk ?? false;
    } else {
      _vars.remove(token.name);
      _ok.remove(token.name);
    }
  }
}

class _Shadow {
  const _Shadow(this.name, this.wasBound, this.oldValue, this.oldOk);

  final String name;
  final bool wasBound;
  final Object? oldValue;
  final bool? oldOk;
}

// ---------------------------------------------------------------------------
// Evaluation
// ---------------------------------------------------------------------------

/// Loose truthiness: null and false are falsy; everything else is truthy.
bool truthy(Object? v) => v != null && v != false;

/// Evaluate an expression against the environment. Returns bool for
/// comparisons; raw values for bare references/literals.
Object? evalExpr(Expr e, Env env) {
  switch (e) {
    case final Literal l:
      return l.value;
    case final Ref r:
      return env.lookup(r.path);
    case final NotExpr n:
      return !truthy(evalExpr(n.inner, env));
    case final AndExpr a:
      for (final op in a.operands) {
        if (!truthy(evalExpr(op, env))) return false;
      }
      return true;
    case final OrExpr o:
      for (final op in o.operands) {
        if (truthy(evalExpr(op, env))) return true;
      }
      return false;
    case final CompareExpr c:
      return _compare(c.op, evalExpr(c.left, env), evalExpr(c.right, env));
  }
}

bool _compare(String op, Object? l, Object? r) {
  switch (op) {
    case '==':
      return deepEq(l, r);
    case '!=':
      return !deepEq(l, r);
  }
  if (l is num && r is num) {
    return switch (op) {
      '>' => l > r,
      '>=' => l >= r,
      '<' => l < r,
      '<=' => l <= r,
      _ => throw ExprError('unknown operator $op'),
    };
  }
  if (l is String && r is String) {
    final c = l.compareTo(r);
    return switch (op) {
      '>' => c > 0,
      '>=' => c >= 0,
      '<' => c < 0,
      '<=' => c <= 0,
      _ => throw ExprError('unknown operator $op'),
    };
  }
  // Cross-type ordering is false, not an error.
  return false;
}

/// Deep equality with loose number handling (1 == 1.0) and structural
/// comparison for maps/lists. Used by expressions and event matching.
bool deepEq(Object? l, Object? r) {
  if (l is num && r is num) return l == r;
  if (l is Map && r is Map) {
    if (l.length != r.length) return false;
    for (final k in l.keys) {
      if (!r.containsKey(k) || !deepEq(l[k], r[k])) return false;
    }
    return true;
  }
  if (l is List && r is List) {
    if (l.length != r.length) return false;
    for (var i = 0; i < l.length; i++) {
      if (!deepEq(l[i], r[i])) return false;
    }
    return true;
  }
  return l == r;
}

// ---------------------------------------------------------------------------
// Reference resolution inside command inputs / set values
// ---------------------------------------------------------------------------

final _refPattern = RegExp(r'^\$[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)*$');

/// Whether [s] is a syntactically valid whole-string reference (`$a.b.0`).
bool isRef(String s) => _refPattern.hasMatch(s);

/// Recursively resolve whole-string references, preserving value types.
/// Matches the AutoMode convention: only an exact full-string `$ref` is
/// replaced; partial interpolation is intentionally not supported.
Object? resolveValue(Object? v, Env env) {
  if (v is String) {
    if (_refPattern.hasMatch(v)) {
      return env.lookup(refPath(v));
    }
    return v;
  }
  if (v is Map) {
    return v.map((k, val) => MapEntry(k as String, resolveValue(val, env)));
  }
  if (v is List) {
    return v.map((e) => resolveValue(e, env)).toList();
  }
  return v;
}

/// Collect the variable names referenced anywhere inside a value tree —
/// used to decide whether a command depends on failed producers.
Set<String> collectRefs(Object? v) {
  final names = <String>{};
  void walk(Object? x) {
    if (x is String) {
      if (_refPattern.hasMatch(x)) names.add(refPath(x).first);
      return;
    }
    if (x is Map) {
      x.values.forEach(walk);
      return;
    }
    if (x is List) x.forEach(walk);
  }

  walk(v);
  return names;
}
