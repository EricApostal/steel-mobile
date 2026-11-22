import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/format.dart';
import '../../../core/ui/empty_state.dart';
import '../application/files_providers.dart';
import '../data/file_service.dart';

/// View a text file (editable) or image, or explain why it can't be opened.
class FileEditorPage extends ConsumerStatefulWidget {
  const FileEditorPage({super.key, required this.instanceId, required this.path});

  final String instanceId;
  final String path;

  @override
  ConsumerState<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends ConsumerState<FileEditorPage> {
  late final Future<FilePreview> _preview =
      ref.read(fileServiceProvider(widget.instanceId)).preview(widget.path);
  final _text = TextEditingController();
  var _saved = '';
  var _isText = false;

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
      await ref.read(fileServiceProvider(widget.instanceId)).writeText(widget.path, _text.text);
      _saved = _text.text;
      if (mounted) {
        setState(() {});
        showFToast(context: context, title: const Text('Saved'));
      }
    } catch (e) {
      if (mounted) {
        showFToast(context: context, variant: FToastVariant.destructive, title: Text('$e'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final name = widget.path.split('/').last;

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(name, overflow: TextOverflow.ellipsis),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
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
            return EmptyState(icon: FLucideIcons.triangleAlert, message: '${snapshot.error}');
          }
          return switch (snapshot.data) {
            null => const Center(child: FCircularProgress()),
            TextPreview() => Padding(
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
              ),
            ImagePreview(:final file) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Image.file(file, filterQuality: FilterQuality.none)),
                      const SizedBox(height: 12),
                      Text(
                        formatBytes(file.lengthSync()),
                        style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
            UnsupportedPreview(:final reason) => EmptyState(icon: FLucideIcons.fileX, message: reason),
          };
        },
      ),
    );
  }
}
