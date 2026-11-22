/// A TOML value we can't (or don't want to) interpret, kept verbatim:
/// datetimes, anything the mini parser doesn't understand.
class TomlRaw {
  const TomlRaw(this.text);
  final String text;

  @override
  String toString() => text;
}

class TomlFormatException implements Exception {
  const TomlFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Parses a single TOML value into `String`, `int`, `double`, `bool`,
/// `List<Object?>`, `Map<String, Object?>` or [TomlRaw].
Object? parseTomlValue(String source) {
  final p = _ValueParser(source);
  final v = p.parseValue();
  p.skipTrivia();
  if (!p.atEnd) throw TomlFormatException('Unexpected "${p.peek}"');
  return v;
}

/// Serializes [value] as a single-line TOML literal.
String tomlLiteral(Object? value) {
  return switch (value) {
    null => '""',
    bool b => '$b',
    int i => '$i',
    double d => d.isFinite
        ? (d == d.roundToDouble() && !d.toString().contains('e') ? d.toStringAsFixed(1) : '$d')
        : (d.isNaN ? 'nan' : (d > 0 ? 'inf' : '-inf')),
    String s => _quote(s),
    List<Object?> l => l.isEmpty ? '[]' : '[${l.map(tomlLiteral).join(', ')}]',
    Map<String, Object?> m => m.isEmpty
        ? '{}'
        : '{ ${m.entries.map((e) => '${_key(e.key)} = ${tomlLiteral(e.value)}').join(', ')} }',
    TomlRaw r => r.text,
    _ => _quote('$value'),
  };
}

String _key(String k) => RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(k) ? k : _quote(k);

String _quote(String s) {
  final b = StringBuffer('"');
  for (final r in s.runes) {
    switch (r) {
      case 0x22:
        b.write(r'\"');
      case 0x5C:
        b.write(r'\\');
      case 0x0A:
        b.write(r'\n');
      case 0x0D:
        b.write(r'\r');
      case 0x09:
        b.write(r'\t');
      default:
        if (r < 0x20 || r == 0x7F) {
          b.write('\\u${r.toRadixString(16).padLeft(4, '0')}');
        } else {
          b.writeCharCode(r);
        }
    }
  }
  return (b..write('"')).toString();
}

class _ValueParser {
  _ValueParser(this.s);

  final String s;
  var i = 0;

  bool get atEnd => i >= s.length;
  String get peek => s[i];

  /// Whitespace, newlines and comments (the latter two only appear inside
  /// multi-line arrays/inline tables, which is where this is used).
  void skipTrivia() {
    while (!atEnd) {
      final c = s[i];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        i++;
      } else if (c == '#') {
        while (!atEnd && s[i] != '\n') {
          i++;
        }
      } else {
        break;
      }
    }
  }

  Object? parseValue() {
    skipTrivia();
    if (atEnd) throw const TomlFormatException('Missing value');
    final c = s[i];
    if (s.startsWith('"""', i) || s.startsWith("'''", i)) return _multiline();
    if (c == '"') return _basicString();
    if (c == "'") return _literalString();
    if (c == '[') return _array();
    if (c == '{') return _inlineTable();
    return _scalar();
  }

  String _basicString() {
    i++; // opening quote
    final b = StringBuffer();
    while (true) {
      if (atEnd) throw const TomlFormatException('Unterminated string');
      final c = s[i++];
      if (c == '"') return b.toString();
      if (c == r'\') {
        b.write(_escape());
      } else {
        b.write(c);
      }
    }
  }

  String _escape() {
    if (atEnd) throw const TomlFormatException('Bad escape');
    final c = s[i++];
    switch (c) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      case 'r':
        return '\r';
      case 'b':
        return '\b';
      case 'f':
        return '\f';
      case '"':
        return '"';
      case r'\':
        return r'\';
      case 'u' || 'U':
        final len = c == 'u' ? 4 : 8;
        if (i + len > s.length) throw const TomlFormatException('Bad unicode escape');
        final code = int.tryParse(s.substring(i, i + len), radix: 16);
        if (code == null) throw const TomlFormatException('Bad unicode escape');
        i += len;
        return String.fromCharCode(code);
      default:
        throw TomlFormatException('Unknown escape \\$c');
    }
  }

  String _literalString() {
    final end = s.indexOf("'", i + 1);
    if (end < 0) throw const TomlFormatException('Unterminated string');
    final v = s.substring(i + 1, end);
    i = end + 1;
    return v;
  }

  String _multiline() {
    final basic = s[i] == '"';
    final quote = basic ? '"""' : "'''";
    i += 3;
    if (!atEnd && s[i] == '\r') i++;
    if (!atEnd && s[i] == '\n') i++;
    final b = StringBuffer();
    while (true) {
      if (atEnd) throw const TomlFormatException('Unterminated string');
      if (s.startsWith(quote, i)) {
        i += 3;
        return b.toString();
      }
      final c = s[i++];
      if (basic && c == r'\') {
        if (!atEnd && (s[i] == '\n' || s[i] == '\r' || s[i] == ' ')) {
          // line-ending backslash: trim following whitespace
          while (!atEnd && (s[i] == '\n' || s[i] == '\r' || s[i] == ' ' || s[i] == '\t')) {
            i++;
          }
        } else {
          b.write(_escape());
        }
      } else {
        b.write(c);
      }
    }
  }

  List<Object?> _array() {
    i++; // [
    final out = <Object?>[];
    while (true) {
      skipTrivia();
      if (atEnd) throw const TomlFormatException('Unterminated array');
      if (s[i] == ']') {
        i++;
        return out;
      }
      out.add(parseValue());
      skipTrivia();
      if (!atEnd && s[i] == ',') i++;
    }
  }

  Map<String, Object?> _inlineTable() {
    i++; // {
    final out = <String, Object?>{};
    while (true) {
      skipTrivia();
      if (atEnd) throw const TomlFormatException('Unterminated table');
      if (s[i] == '}') {
        i++;
        return out;
      }
      final key = _key_();
      skipTrivia();
      if (atEnd || s[i] != '=') throw const TomlFormatException('Expected =');
      i++;
      out[key] = parseValue();
      skipTrivia();
      if (!atEnd && s[i] == ',') i++;
    }
  }

  String _key_() {
    if (s[i] == '"') return _basicString();
    if (s[i] == "'") return _literalString();
    final start = i;
    while (!atEnd && RegExp(r'[A-Za-z0-9_-]').hasMatch(s[i])) {
      i++;
    }
    if (i == start) throw const TomlFormatException('Expected key');
    return s.substring(start, i);
  }

  Object? _scalar() {
    final start = i;
    while (!atEnd && !',]}#\n'.contains(s[i])) {
      i++;
    }
    final t = s.substring(start, i).trim();
    if (t == 'true') return true;
    if (t == 'false') return false;
    final clean = t.replaceAll('_', '');
    if (RegExp(r'^[+-]?\d+$').hasMatch(clean)) return int.parse(clean);
    if (RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(clean)) return int.parse(clean.substring(2), radix: 16);
    if (RegExp(r'^[+-]?(\d+\.\d+|\d+(\.\d+)?[eE][+-]?\d+)$').hasMatch(clean)) {
      return double.parse(clean);
    }
    if (clean == 'inf' || clean == '+inf') return double.infinity;
    if (clean == '-inf') return double.negativeInfinity;
    if (clean == 'nan') return double.nan;
    if (t.isEmpty) throw const TomlFormatException('Missing value');
    return TomlRaw(t); // datetimes etc.
  }
}
