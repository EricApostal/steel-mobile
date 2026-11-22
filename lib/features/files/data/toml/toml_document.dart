import 'toml_value.dart';

/// One `key = value` pair in a document.
class TomlEntry {
  const TomlEntry({
    required this.table,
    required this.key,
    required this.startLine,
    required this.endLine,
    required this.prefix,
    required this.rawValue,
    required this.value,
    this.trailingComment,
    this.comment,
  });

  final TomlTable table;
  final String key;
  final int startLine;
  final int endLine;

  /// Source text before the value on its first line (`  key = `).
  final String prefix;
  final String rawValue;
  final Object? value;

  /// `# ...` after the value on its last line.
  final String? trailingComment;

  /// The comment block directly above the entry.
  final String? comment;
}

/// A `[table]`, `[[array.of.tables]]` element, or the root.
class TomlTable {
  TomlTable({
    required this.path,
    required this.isArrayElement,
    required this.index,
    required this.headerLine,
  });

  /// Segments without array indices, e.g. `[domains, minecraft, worlds]`.
  final List<String> path;
  final bool isArrayElement;

  /// Position among elements of the same `[[...]]` array.
  final int index;

  /// -1 for the root table.
  final int headerLine;
  final entries = <TomlEntry>[];

  /// Commented-out `# key = value` lines, by key → line index.
  final disabled = <String, int>{};

  /// Last line that belongs to this table (before the next header).
  int lastLine = -1;

  bool get isRoot => headerLine < 0;
  String get id => '${path.join('.')}${isArrayElement ? '[$index]' : ''}';

  TomlEntry? entry(String key) {
    for (final e in entries) {
      if (e.key == key) return e;
    }
    return null;
  }
}

/// A TOML file that can be edited value-by-value without disturbing comments,
/// ordering or formatting elsewhere. Edits return the new document text.
class TomlDocument {
  TomlDocument._(this._lines, this._eol, this.tables, this.schemaUrl);

  final List<String> _lines;
  final String _eol;
  final List<TomlTable> tables;

  /// From a leading `#:schema <url>` line.
  final String? schemaUrl;

  String get text => _lines.join(_eol);

  TomlTable? table(List<String> path, {int index = 0}) {
    for (final t in tables) {
      if (t.path.join('\u0000') == path.join('\u0000') && (!t.isArrayElement || t.index == index)) {
        return t;
      }
    }
    return null;
  }

  /// Parses [text], or returns null if it isn't TOML this layer understands.
  static TomlDocument? tryParse(String text) {
    try {
      return _parse(text);
    } on TomlFormatException {
      return null;
    }
  }

  // ---- edits -------------------------------------------------------------

  /// Replaces [entry]'s value, keeping its key, spacing and trailing comment.
  String setValue(TomlEntry entry, Object? value) {
    final line = '${entry.prefix}${tomlLiteral(value)}'
        '${entry.trailingComment == null ? '' : ' ${entry.trailingComment}'}';
    return _replace(entry.startLine, entry.endLine, [line]);
  }

  /// Comments the entry out (`# key = value`), Steel's own convention for
  /// unset optional settings. Its description comment stays.
  String unset(TomlEntry entry) {
    final lines = [
      for (var i = entry.startLine; i <= entry.endLine; i++) '# ${_lines[i].trimLeft()}',
    ];
    return _replace(entry.startLine, entry.endLine, lines);
  }

  /// Sets [key] in [table]: revives a commented-out `# key = ...` line if there
  /// is one, otherwise appends after the table's last entry.
  String add(TomlTable table, String key, Object? value) {
    final literal = '$key = ${tomlLiteral(value)}';
    final disabledLine = table.disabled[key];
    if (disabledLine != null) {
      final indent = RegExp(r'^\s*').stringMatch(_lines[disabledLine]) ?? '';
      return _replace(disabledLine, disabledLine, ['$indent$literal']);
    }
    final after = table.entries.isNotEmpty
        ? table.entries.last.endLine
        : table.headerLine; // root with no entries: top of file
    final copy = [..._lines]..insert(after + 1, literal);
    return copy.join(_eol);
  }

  String _replace(int start, int end, List<String> replacement) {
    final copy = [..._lines]..replaceRange(start, end + 1, replacement);
    return copy.join(_eol);
  }

  // ---- parsing -----------------------------------------------------------

  static final _header = RegExp(r'^\s*(\[\[?)\s*(.+?)\s*\]\]?\s*(#.*)?$');
  static final _disabledKey = RegExp(r'^\s*#\s*([A-Za-z0-9_-]+)\s*=');

  static TomlDocument _parse(String text) {
    final eol = text.contains('\r\n') ? '\r\n' : '\n';
    final lines = text.split(RegExp(r'\r?\n'));

    final root = TomlTable(path: const [], isArrayElement: false, index: 0, headerLine: -1);
    final tables = <TomlTable>[root];
    final arrayCounts = <String, int>{};
    var current = root;
    String? schemaUrl;
    var comment = <String>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        comment = [];
        i++;
        continue;
      }

      if (trimmed.startsWith('#')) {
        if (trimmed.startsWith('#:schema')) {
          schemaUrl = trimmed.substring('#:schema'.length).trim();
        } else if (_disabledKey.firstMatch(line) case final m?) {
          // A commented-out setting: remember it, and start a fresh comment block.
          current.disabled[m.group(1)!] = i;
          comment = [];
        } else {
          comment.add(trimmed.replaceFirst(RegExp(r'^#+\s?'), ''));
        }
        i++;
        continue;
      }

      final header = _header.firstMatch(line);
      if (header != null && trimmed.startsWith('[')) {
        final isArray = header.group(1) == '[[';
        final path = _splitKey(header.group(2)!);
        final key = path.join('\u0000');
        final index = isArray ? (arrayCounts[key] = (arrayCounts[key] ?? -1) + 1) : 0;
        current.lastLine = _lastContentLine(lines, current.headerLine, i - 1);
        current = TomlTable(path: path, isArrayElement: isArray, index: index, headerLine: i);
        tables.add(current);
        comment = [];
        i++;
        continue;
      }

      // key = value
      final kv = _readKey(line);
      if (kv == null) throw TomlFormatException('Line ${i + 1}: expected key = value');
      final (key, valueStart) = kv;
      final end = _scanValue(lines, i, valueStart);
      final raw = _slice(lines, i, valueStart, end.line, end.col).trim();
      final tail = lines[end.line].substring(end.col).trim();
      Object? value;
      try {
        value = parseTomlValue(raw);
      } on TomlFormatException {
        value = TomlRaw(raw);
      }
      current.entries.add(TomlEntry(
        table: current,
        key: key,
        startLine: i,
        endLine: end.line,
        prefix: line.substring(0, valueStart),
        rawValue: raw,
        value: value,
        trailingComment: tail.startsWith('#') ? tail : null,
        comment: comment.isEmpty ? null : comment.join(' '),
      ));
      comment = [];
      i = end.line + 1;
    }
    current.lastLine = _lastContentLine(lines, current.headerLine, lines.length - 1);
    return TomlDocument._(lines, eol, tables, schemaUrl);
  }

  static int _lastContentLine(List<String> lines, int from, int to) {
    var l = to;
    while (l > from && lines[l].trim().isEmpty) {
      l--;
    }
    return l;
  }

  /// `a.b."c d"` → [a, b, c d]
  static List<String> _splitKey(String s) {
    final parts = <String>[];
    var i = 0;
    while (i < s.length) {
      while (i < s.length && s[i] == ' ') {
        i++;
      }
      if (i >= s.length) break;
      if (s[i] == '"' || s[i] == "'") {
        final q = s[i];
        final end = s.indexOf(q, i + 1);
        if (end < 0) throw const TomlFormatException('Unterminated key');
        parts.add(s.substring(i + 1, end));
        i = end + 1;
      } else {
        final start = i;
        while (i < s.length && s[i] != '.' && s[i] != ' ') {
          i++;
        }
        parts.add(s.substring(start, i));
      }
      while (i < s.length && (s[i] == ' ' || s[i] == '.')) {
        i++;
      }
    }
    return parts;
  }

  /// Reads `key =` and returns the key and the column where the value starts.
  static (String, int)? _readKey(String line) {
    final eq = _findEquals(line);
    if (eq < 0) return null;
    final keyText = line.substring(0, eq).trim();
    if (keyText.isEmpty) return null;
    final parts = _splitKey(keyText);
    var col = eq + 1;
    while (col < line.length && (line[col] == ' ' || line[col] == '\t')) {
      col++;
    }
    return (parts.join('.'), col);
  }

  static int _findEquals(String line) {
    String? quote;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (quote != null) {
        if (c == quote) quote = null;
      } else if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '=') {
        return i;
      } else if (c == '#') {
        return -1;
      }
    }
    return -1;
  }

  /// Finds where the value starting at ([line], [col]) ends, following
  /// multi-line arrays, tables and strings. Returns the position after it.
  static ({int line, int col}) _scanValue(List<String> lines, int line, int col) {
    var i = line;
    var j = col;
    var depth = 0;

    while (true) {
      final text = lines[i];
      if (j >= text.length) {
        if (depth == 0) return (line: i, col: text.length);
        if (++i >= lines.length) throw const TomlFormatException('Unterminated value');
        j = 0;
        continue;
      }
      final c = text[j];

      if (text.startsWith('"""', j) || text.startsWith("'''", j)) {
        final q = text.substring(j, j + 3);
        var k = j + 3;
        var l = i;
        while (true) {
          final idx = lines[l].indexOf(q, k);
          if (idx >= 0) {
            i = l;
            j = idx + 3;
            break;
          }
          if (++l >= lines.length) throw const TomlFormatException('Unterminated string');
          k = 0;
        }
        continue;
      }
      if (c == '"') {
        j++;
        while (j < text.length && text[j] != '"') {
          if (text[j] == r'\') j++;
          j++;
        }
        j++;
        continue;
      }
      if (c == "'") {
        final end = text.indexOf("'", j + 1);
        if (end < 0) throw const TomlFormatException('Unterminated string');
        j = end + 1;
        continue;
      }
      if (c == '#') {
        if (depth == 0) return (line: i, col: j);
        j = text.length; // comment inside a multi-line array
        continue;
      }
      if (c == '[' || c == '{') depth++;
      if (c == ']' || c == '}') depth--;
      j++;
    }
  }

  static String _slice(List<String> lines, int l1, int c1, int l2, int c2) {
    if (l1 == l2) return lines[l1].substring(c1, c2);
    return [
      lines[l1].substring(c1),
      for (var l = l1 + 1; l < l2; l++) lines[l],
      lines[l2].substring(0, c2),
    ].join('\n');
  }
}
