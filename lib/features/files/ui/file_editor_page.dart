import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/format.dart';
import '../../../core/ui/empty_state.dart';
import '../../../core/ui/header_title.dart';
import '../../../core/ui/popups.dart';
import '../../instances/application/instances_controller.dart';
import '../../instances/application/network_providers.dart';
import '../application/files_providers.dart';
import '../application/schema_providers.dart';
import '../data/file_service.dart';
import '../data/toml/toml_document.dart';
import 'toml_form.dart';

/// View a text file (editable) or image, or explain why it can't be opened.
class FileEditorPage extends ConsumerStatefulWidget {
  const FileEditorPage({
    super.key,
    required this.instanceId,
    required this.path,
  });

  final String instanceId;
  final String path;

  @override
  ConsumerState<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends ConsumerState<FileEditorPage> {
  late final Future<FilePreview> _preview = ref
      .read(fileServiceProvider(widget.instanceId))
      .preview(widget.path);
  final _text = TextEditingController();
  var _saved = '';
  var _isText = false;
  var _formMode = true; // .toml files open as a typed form

  bool get _isToml => widget.path.endsWith('.toml');

  bool get _dirty => _isText && _text.text != _saved;

  @override
  void initState() {
    super.initState();
    _preview.then((p) {
      if (p is TextPreview && mounted) {
        _saved = p.text;
        _text.text = p.text;
        setState(() => _isText = true);
      }
    });
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await ref
          .read(fileServiceProvider(widget.instanceId))
          .writeText(widget.path, _text.text);
      _saved = _text.text;
      ref.invalidate(
        instancePortProvider(widget.instanceId),
      ); // config may have changed
      if (mounted) {
        setState(() {});
        showFToast(context: context, title: const Text('Saved'));
      }
    } catch (e) {
      if (mounted) {
        showFToast(
          context: context,
          variant: FToastVariant.destructive,
          title: Text('$e'),
        );
      }
    }
  }

  /// "Survival · config": which instance and folder the file is in.
  String _subtitle() {
    final instance = ref.read(instanceProvider(widget.instanceId))?.name ?? 'Instance';
    final parts = widget.path.split('/')..removeLast();
    return parts.isEmpty ? instance : '$instance · ${parts.join('/')}';
  }

  Widget _textEditor() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: FTextField(
      control: FTextFieldControl.managed(controller: _text),
      style: .delta(
        contentTextStyle: .delta([
          .base(.delta(fontFamily: 'monospace', fontSize: 12.5, height: 1.4)),
        ]),
      ),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.multiline,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final name = widget.path.split('/').last;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showConfirmDialog(
          context,
          title: 'Discard changes?',
          message: 'You have unsaved changes to $name.',
          confirmLabel: 'Discard',
          destructive: true,
        );
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          titleAlignment: Alignment.centerLeft,
        title: HeaderTitle(title: name, subtitle: _subtitle()),
          prefixes: [
            FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
          ],
          suffixes: [
            if (_isText)
              FHeaderAction(
                icon: const Icon(FLucideIcons.save),
                onPress: _dirty ? _save : null,
              ),
          ],
        ),
        child: FutureBuilder<FilePreview>(
          future: _preview,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                icon: FLucideIcons.triangleAlert,
                message: '${snapshot.error}',
              );
            }
            return switch (snapshot.data) {
              null => const Center(child: FCircularProgress()),
              TextPreview() =>
                _isToml
                    ? Column(
                        children: [
                          _ModeToggle(
                            form: _formMode,
                            onChange: (form) =>
                                setState(() => _formMode = form),
                          ),
                          Expanded(
                            child: _formMode
                                ? _TomlView(
                                    text: _text.text,
                                    fileName: name,
                                    onChanged: (t) => _text.text = t,
                                    onEditAsText: () =>
                                        setState(() => _formMode = false),
                                  )
                                : _textEditor(),
                          ),
                        ],
                      )
                    : _textEditor(),
              ImagePreview(:final file) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Image.file(
                          file,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatBytes(file.lengthSync()),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              UnsupportedPreview(:final reason) => EmptyState(
                icon: FLucideIcons.fileX,
                message: reason,
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Form | Text switch shown above TOML files.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.form, required this.onChange});

  final bool form;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    Widget button(
      String label,
      IconData icon,
      bool selected,
      VoidCallback onPress,
    ) => Expanded(
      child: FButton(
        size: FButtonSizeVariant.sm,
        variant: selected ? FButtonVariant.secondary : FButtonVariant.ghost,
        prefix: Icon(icon),
        onPress: onPress,
        child: Text(label),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          button(
            'Form',
            FLucideIcons.slidersHorizontal,
            form,
            () => onChange(true),
          ),
          const SizedBox(width: 8),
          button('Text', FLucideIcons.fileCode, !form, () => onChange(false)),
        ],
      ),
    );
  }
}

/// Parses [text] and shows it as a typed form, using the bundled schema.
class _TomlView extends ConsumerWidget {
  const _TomlView({
    required this.text,
    required this.fileName,
    required this.onChanged,
    required this.onEditAsText,
  });

  final String text;
  final String fileName;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditAsText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = TomlDocument.tryParse(text);
    if (document == null) {
      return EmptyState(
        icon: FLucideIcons.triangleAlert,
        message: "This file isn't valid TOML, so it can't be shown as a form.",
        action: FButton(
          variant: FButtonVariant.secondary,
          onPress: onEditAsText,
          child: const Text('Edit as text'),
        ),
      );
    }
    final schema = ref
        .watch(tomlSchemaProvider(schemaNameFor(document, fileName)))
        .value;
    return TomlForm(document: document, schema: schema, onChanged: onChanged);
  }
}
