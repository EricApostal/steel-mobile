import 'json_schema.dart';
import 'toml_document.dart';
import 'toml_value.dart';

/// Which editor a field gets.
enum FieldKind { toggle, slider, integer, decimal, text, choice, stringList, raw }

/// Hand-tuned presentation for specific settings, keyed by dotted path
/// (`server.view_distance`). Everything else is derived from the schema.
class FieldOverride {
  const FieldOverride({
    this.title,
    this.unit,
    this.min,
    this.max,
    this.maxFor,
    this.zeroLabel,
    this.minLabel,
    this.maxLabel,
  });

  final String? title;
  final String? unit;
  final num? min;
  final num? max;

  /// Upper bound that depends on other settings in the same table.
  final num? Function(TomlTable table)? maxFor;

  /// Shown instead of "0" (e.g. "Auto").
  final String? zeroLabel;

  /// Captions at the slider's ends.
  final String? minLabel;
  final String? maxLabel;
}

num? _extendedViewDistanceMax(TomlTable t, {required num vanilla}) =>
    t.entry('allow_extended_view_distance')?.value == true ? 128 : vanilla;

final fieldOverrides = <String, FieldOverride>{
  // Steel allows 1-128 chunks only when the extended-distance switch is on;
  // vanilla's cap is 32. A slider that follows that switch.
  'server.view_distance': FieldOverride(
    title: 'Render distance',
    unit: 'chunks',
    min: 2,
    maxFor: (t) => _extendedViewDistanceMax(t, vanilla: 32),
    minLabel: 'Near',
    maxLabel: 'Far',
  ),
  'server.simulation_distance': FieldOverride(
    title: 'Simulation distance',
    unit: 'chunks',
    min: 0,
    maxFor: (t) => _extendedViewDistanceMax(t, vanilla: 32),
  ),
  'server.server_port': const FieldOverride(title: 'Port'),
  'server.motd': const FieldOverride(title: 'MOTD'),
  'server.chat_spam_threshold_seconds': const FieldOverride(unit: 'seconds'),
  'server.command_spam_threshold_seconds': const FieldOverride(unit: 'seconds'),
  'server.compression.threshold': const FieldOverride(unit: 'bytes'),
  'server.compression.level': const FieldOverride(minLabel: 'Fastest', maxLabel: 'Smallest'),
  'server.threads.main_runtime': const FieldOverride(zeroLabel: 'Auto'),
  'server.threads.chunk_runtime': const FieldOverride(zeroLabel: 'Auto'),
  'server.threads.packet_workers': const FieldOverride(zeroLabel: 'Auto'),
  'server.threads.chunk_generation': const FieldOverride(zeroLabel: 'Auto'),
  'server.threads.chunk_encoding': const FieldOverride(zeroLabel: 'Auto'),
  'log.max_history': const FieldOverride(unit: 'commands'),
};

class FieldSpec {
  const FieldSpec({
    required this.key,
    required this.title,
    required this.kind,
    this.description,
    this.min,
    this.max,
    this.options = const [],
    this.defaultValue,
    this.unit,
    this.zeroLabel,
    this.minLabel,
    this.maxLabel,
    this.required = false,
    this.format,
  });

  final String key;
  final String title;
  final FieldKind kind;
  final String? description;
  final num? min;
  final num? max;
  final List<String> options;
  final Object? defaultValue;
  final String? unit;
  final String? zeroLabel;
  final String? minLabel;
  final String? maxLabel;
  final bool required;
  final String? format;

  /// Sliders are for small integer ranges; anything wider is a number field.
  static const _maxSliderSpan = 128;

  static FieldOverride? overrideFor(TomlTable table, String key) =>
      fieldOverrides[[...table.path, key].join('.')];

  /// Builds the editor description for an existing [entry].
  factory FieldSpec.forEntry(TomlEntry entry, SchemaNode? tableSchema) {
    final node = tableSchema?.child(entry.key);
    final ov = overrideFor(entry.table, entry.key);
    final value = entry.value;

    final enumOptions = node?.enumValues?.map((o) => '$o').toList() ?? const <String>[];
    final type = node?.type ?? _inferType(value);

    var min = ov?.min ?? node?.minimum;
    var max = ov?.maxFor?.call(entry.table) ?? ov?.max ?? node?.maximum;
    if (value is int) {
      // Never offer a range that excludes what is already there.
      if (max != null && value > max) max = value;
      if (min != null && value < min) min = value;
    }

    final kind = switch ((type, value)) {
      ('string', String()) when enumOptions.isNotEmpty => FieldKind.choice,
      ('boolean', bool()) => FieldKind.toggle,
      ('integer', int()) when min != null && max != null && max - min <= _maxSliderSpan => FieldKind.slider,
      ('integer', int()) => FieldKind.integer,
      ('number', num()) => FieldKind.decimal,
      ('string', String()) => FieldKind.text,
      ('array', final List<Object?> list) when list.every((v) => v is String) => FieldKind.stringList,
      _ => FieldKind.raw,
    };

    final options = [...enumOptions];
    if (kind == FieldKind.choice && !options.contains(value)) options.add(value as String);

    return FieldSpec(
      key: entry.key,
      title: ov?.title ?? humanize(entry.key),
      kind: kind,
      description: node?.description ?? entry.comment,
      min: min,
      max: max,
      options: options,
      defaultValue: node?.defaultValue,
      unit: ov?.unit,
      zeroLabel: ov?.zeroLabel,
      minLabel: ov?.minLabel,
      maxLabel: ov?.maxLabel,
      required: tableSchema?.required.contains(entry.key) ?? false,
      format: node?.format,
    );
  }

  static String _inferType(Object? v) => switch (v) {
        bool() => 'boolean',
        int() => 'integer',
        double() => 'number',
        String() => 'string',
        List() => 'array',
        _ => 'object',
      };

  /// A value to start from when the user enables an unset [node].
  static Object? startingValue(SchemaNode node) {
    if (node.defaultValue != null) return node.defaultValue;
    final options = node.enumValues;
    if (options != null && options.isNotEmpty) return options.first;
    return switch (node.type) {
      'boolean' => false,
      'integer' => node.minimum?.toInt() ?? 0,
      'number' => (node.minimum ?? 0).toDouble(),
      'array' => <Object?>[],
      'object' => <String, Object?>{},
      _ => '',
    };
  }

  /// Settings the schema knows about that [table] doesn't set yet. Nested
  /// tables are skipped; they are their own sections.
  static List<(String, SchemaNode)> unsetProperties(TomlTable table, SchemaNode? tableSchema) {
    if (tableSchema == null) return const [];
    final present = {for (final e in table.entries) e.key};
    return [
      for (final MapEntry(:key, :value) in tableSchema.properties.entries)
        if (!present.contains(key) && value.type != 'object' && !_isTableArray(value)) (key, value),
    ];
  }

  static bool _isTableArray(SchemaNode n) => n.type == 'array' && n.items?.type == 'object';

  static const _acronyms = {'url': 'URL', 'uri': 'URI', 'motd': 'MOTD', 'ip': 'IP', 'tps': 'TPS', 'id': 'ID'};

  /// `server_port` → "Server port"
  static String humanize(String key) {
    final words = key.split(RegExp(r'[_\-\s]+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return key;
    return [
      for (var i = 0; i < words.length; i++)
        _acronyms[words[i]] ?? (i == 0 ? words[i][0].toUpperCase() + words[i].substring(1) : words[i]),
    ].join(' ');
  }
}

/// Raw-text editing of a value we have no typed editor for.
Object? parseRawValue(String source) {
  try {
    return parseTomlValue(source);
  } on TomlFormatException {
    return null;
  }
}
