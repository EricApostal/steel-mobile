import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/action_menu.dart';
import '../../../core/ui/popups.dart';
import '../data/toml/field_spec.dart';
import '../data/toml/json_schema.dart';
import '../data/toml/toml_document.dart';
import '../data/toml/toml_value.dart';

/// A typed form over a TOML document. Every edit produces the new file text
/// via [onChanged]; comments and layout elsewhere are untouched.
class TomlForm extends StatelessWidget {
  const TomlForm({
    super.key,
    required this.document,
    required this.schema,
    required this.onChanged,
  });

  final TomlDocument document;
  final SchemaNode? schema;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final sections = [
      for (final table in document.tables)
        if (table.entries.isNotEmpty ||
            (!table.isRoot && FieldSpec.unsetProperties(table, schema?.at(table.path)).isNotEmpty))
          _Section(
            key: ValueKey(table.id),
            document: document,
            table: table,
            schema: schema?.at(table.path),
            onChanged: onChanged,
          ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => sections[i],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.document,
    required this.table,
    required this.schema,
    required this.onChanged,
  });

  final TomlDocument document;
  final TomlTable table;
  final SchemaNode? schema;
  final ValueChanged<String> onChanged;

  String get _title {
    if (table.isRoot) return 'General';
    final parts = [for (final p in table.path) FieldSpec.humanize(p)];
    if (table.isArrayElement) {
      final name = table.entry('name')?.value;
      parts[parts.length - 1] = name is String ? '${parts.last} · $name' : '${parts.last} #${table.index + 1}';
    }
    return parts.join(' › ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final unset = FieldSpec.unsetProperties(table, schema);
    final description = schema?.description;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_title, style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600)),
            if (description != null) ...[
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
              ),
            ],
            const SizedBox(height: 8),
            for (var i = 0; i < table.entries.length; i++) ...[
              if (i > 0) const Divider16(),
              _FieldRow(
                key: ValueKey('${table.id}.${table.entries[i].key}'),
                document: document,
                entry: table.entries[i],
                spec: FieldSpec.forEntry(table.entries[i], schema),
                onChanged: onChanged,
              ),
            ],
            if (unset.isNotEmpty) ...[
              const SizedBox(height: 8),
              FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                prefix: const Icon(FLucideIcons.plus),
                onPress: () => _addOption(context, unset),
                child: const Text('Add option'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addOption(BuildContext context, List<(String, SchemaNode)> unset) async {
    final key = await showPopup<String>(
      context,
      builder: (context, style) => PopupFrame(
        style: style,
        title: 'Add option',
        actions: [
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
        child: FTileGroup(
          children: [
            for (final (k, node) in unset)
              FTile(
                title: Text(FieldSpec.humanize(k)),
                subtitle: node.description == null
                    ? null
                    : Text(node.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
                prefix: const Icon(FLucideIcons.plus),
                onPress: () => Navigator.of(context).pop(k),
              ),
          ],
        ),
      ),
    );
    if (key == null) return;
    final node = unset.firstWhere((e) => e.$1 == key).$2;
    onChanged(document.add(table, key, FieldSpec.startingValue(node)));
  }
}

/// A thin spacer between field rows.
class Divider16 extends StatelessWidget {
  const Divider16({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ColoredBox(
          color: context.theme.colors.border,
          child: const SizedBox(height: 1, width: double.infinity),
        ),
      );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    super.key,
    required this.document,
    required this.entry,
    required this.spec,
    required this.onChanged,
  });

  final TomlDocument document;
  final TomlEntry entry;
  final FieldSpec spec;
  final ValueChanged<String> onChanged;

  void _set(Object? value) => onChanged(document.setValue(entry, value));

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);
    final value = entry.value;

    final canReset = spec.defaultValue != null && !_same(value, spec.defaultValue);
    final canRemove = !spec.required && spec.defaultValue == null;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: spec.title,
                style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w500),
              ),
              if (spec.unit != null && spec.kind != FieldKind.slider)
                TextSpan(text: '  ${spec.unit}', style: muted),
            ]),
          ),
        ),
        if (spec.kind == FieldKind.toggle)
          FSwitch(value: value == true, onChange: _set),
        if (canReset)
          _IconAction(icon: FLucideIcons.rotateCcw, onPress: () => _set(spec.defaultValue)),
        if (canRemove)
          _IconAction(icon: FLucideIcons.x, onPress: () => onChanged(document.unset(entry))),
      ],
    );

    final editor = switch (spec.kind) {
      FieldKind.toggle => null,
      FieldKind.slider => _SliderField(
          key: ValueKey('slider:${entry.value}:${spec.max}'),
          spec: spec,
          value: (value as int),
          onCommit: _set,
        ),
      FieldKind.integer => _TextValueField(
          initial: '$value',
          keyboard: const TextInputType.numberWithOptions(signed: true),
          validate: (t) => _validateInt(t, spec),
          onCommit: _set,
          hint: spec.zeroLabel,
        ),
      FieldKind.decimal => _TextValueField(
          initial: '$value',
          keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validate: (t) {
            final d = double.tryParse(t.trim());
            return d == null ? (null, 'Enter a number') : (d, null);
          },
          onCommit: _set,
        ),
      FieldKind.text => _TextValueField(
          initial: value as String,
          keyboard: spec.format == 'uri' ? TextInputType.url : TextInputType.text,
          validate: (t) => (t, null),
          onCommit: _set,
        ),
      FieldKind.choice => _ChoiceField(
          options: spec.options,
          value: value as String,
          title: spec.title,
          onSelect: _set,
        ),
      FieldKind.stringList => _StringListField(
          items: (value as List<Object?>).cast<String>(),
          title: spec.title,
          onCommit: _set,
        ),
      FieldKind.raw => _RawField(entry: entry, onCommit: _set),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (spec.description != null) ...[
          const SizedBox(height: 2),
          Text(spec.description!, style: muted),
        ],
        if (spec.zeroLabel != null && value == 0 && spec.kind == FieldKind.integer) ...[
          const SizedBox(height: 2),
          Text('0 means ${spec.zeroLabel!.toLowerCase()}', style: muted),
        ],
        if (editor != null) ...[const SizedBox(height: 10), editor],
      ],
    );
  }

  static bool _same(Object? a, Object? b) {
    if (a is List && b is List) return a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);
    return a == b;
  }

  static (Object?, String?) _validateInt(String text, FieldSpec spec) {
    final n = int.tryParse(text.trim());
    if (n == null) return (null, 'Enter a whole number');
    if (spec.min != null && n < spec.min!) return (null, 'At least ${spec.min}');
    if (spec.max != null && n > spec.max!) return (null, 'At most ${spec.max}');
    return (n, null);
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onPress});

  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        onPress: onPress,
        child: Icon(icon, size: 16),
      );
}

// ---------------------------------------------------------------------------
// Editors
// ---------------------------------------------------------------------------

/// Integer slider with a live value readout. Commits when the drag ends.
class _SliderField extends StatefulWidget {
  const _SliderField({super.key, required this.spec, required this.value, required this.onCommit});

  final FieldSpec spec;
  final int value;
  final ValueChanged<Object?> onCommit;

  @override
  State<_SliderField> createState() => _SliderFieldState();
}

class _SliderFieldState extends State<_SliderField> {
  late int _live = widget.value;

  num get _min => widget.spec.min!;
  num get _max => widget.spec.max!;
  double get _span => (_max - _min).toDouble();

  int _toValue(FSliderValue v) => (_min + v.max * _span).round();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spec = widget.spec;
    final muted = theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$_live',
              style: theme.typography.body.xl.copyWith(fontWeight: FontWeight.w600),
            ),
            if (spec.unit != null) ...[const SizedBox(width: 6), Text(spec.unit!, style: muted)],
          ],
        ),
        const SizedBox(height: 8),
        FSlider(
          control: FSliderControl.managedContinuous(
            initial: FSliderValue(max: _span == 0 ? 0 : (widget.value - _min) / _span),
            stepPercentage: _span == 0 ? 1 : 1 / _span,
            onChange: (v) => setState(() => _live = _toValue(v)),
          ),
          onEnd: (v) {
            final value = _toValue(v);
            if (value != widget.value) widget.onCommit(value);
          },
        ),
        if (spec.minLabel != null || spec.maxLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(spec.minLabel ?? '${spec.min}', style: muted), Text(spec.maxLabel ?? '${spec.max}', style: muted)],
            ),
          ),
      ],
    );
  }
}

/// Text/number input that applies each valid edit immediately.
class _TextValueField extends StatefulWidget {
  const _TextValueField({
    required this.initial,
    required this.keyboard,
    required this.validate,
    required this.onCommit,
    this.hint,
  });

  final String initial;
  final TextInputType keyboard;

  /// Returns the parsed value, or an error message.
  final (Object?, String?) Function(String text) validate;
  final ValueChanged<Object?> onCommit;
  final String? hint;

  @override
  State<_TextValueField> createState() => _TextValueFieldState();
}

class _TextValueFieldState extends State<_TextValueField> {
  late final _controller = TextEditingController(text: widget.initial);
  final _focus = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(_TextValueField old) {
    super.didUpdateWidget(old);
    // The value changed from outside (reset, raw edit): show it.
    if (widget.initial != old.initial && widget.initial != _controller.text && !_focus.hasFocus) {
      _controller.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onText() {
    if (_controller.text == widget.initial) return;
    final (value, error) = widget.validate(_controller.text);
    setState(() => _error = error);
    if (error == null) widget.onCommit(value);
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(controller: _controller),
      focusNode: _focus,
      keyboardType: widget.keyboard,
      hint: widget.hint,
      error: _error == null ? null : Text(_error!),
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

/// Pick one of a fixed set: buttons for a few options, a dropdown for many.
class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.options,
    required this.value,
    required this.title,
    required this.onSelect,
  });

  final List<String> options;
  final String value;
  final String title;
  final ValueChanged<Object?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (options.length <= 5) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            FButton(
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              variant: o == value ? FButtonVariant.primary : FButtonVariant.outline,
              onPress: () => onSelect(o),
              child: Text(o),
            ),
        ],
      );
    }
    return ActionMenu(
      menuAnchor: Alignment.topLeft,
      childAnchor: Alignment.bottomLeft,
      actions: [
        for (final o in options) MenuAction(o, FLucideIcons.circle, () => onSelect(o), selected: o == value),
      ],
      builder: (context, toggle) => FButton(
        variant: FButtonVariant.outline,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        suffix: const Icon(FLucideIcons.chevronsUpDown),
        onPress: toggle,
        child: Text(value),
      ),
    );
  }
}

/// A list of strings as removable chips plus an add button.
class _StringListField extends StatelessWidget {
  const _StringListField({required this.items, required this.title, required this.onCommit});

  final List<String> items;
  final String title;
  final ValueChanged<Object?> onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(items[i], style: theme.typography.body.sm),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.xs,
                    onPress: () => onCommit([...items]..removeAt(i)),
                    child: const Icon(FLucideIcons.x, size: 14),
                  ),
                ],
              ),
            ),
          ),
        if (items.isEmpty)
          Text('None', style: theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground)),
        FButton(
          size: FButtonSizeVariant.xs,
          variant: FButtonVariant.outline,
          mainAxisSize: MainAxisSize.min,
          prefix: const Icon(FLucideIcons.plus),
          onPress: () async {
            final item = await showPromptDialog(
              context,
              title: 'Add to ${title.toLowerCase()}',
              label: 'Value',
              confirmLabel: 'Add',
              validate: (v) => v.trim().isEmpty ? 'Enter a value' : null,
            );
            if (item != null) onCommit([...items, item]);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Fallback for values without a typed editor (inline tables, dates, ...).
class _RawField extends StatelessWidget {
  const _RawField({required this.entry, required this.onCommit});

  final TomlEntry entry;
  final ValueChanged<Object?> onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Expanded(
          child: Text(
            entry.rawValue,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: theme.colors.mutedForeground),
          ),
        ),
        FButton(
          size: FButtonSizeVariant.xs,
          variant: FButtonVariant.outline,
          mainAxisSize: MainAxisSize.min,
          onPress: () async {
            final text = await showPromptDialog(
              context,
              title: 'Edit value',
              label: 'TOML value',
              confirmLabel: 'Apply',
              initial: entry.rawValue,
              validate: (v) => parseRawValue(v) == null ? 'Not valid TOML' : null,
            );
            if (text != null) onCommit(TomlRaw(text));
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
