import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Shows [builder] in a modal bottom sheet.
Future<T?> showSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showFSheet<T>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
      builder: builder,
    );

/// Standard look for sheet content: background, rounded top, optional title.
class SheetFrame extends StatelessWidget {
  const SheetFrame({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class SheetAction {
  const SheetAction(this.label, this.icon, this.onSelect, {this.destructive = false});

  final String label;
  final IconData icon;
  final VoidCallback onSelect;
  final bool destructive;
}

/// A list of tappable actions in a bottom sheet.
Future<void> showActionSheet(
  BuildContext context, {
  String? title,
  required List<SheetAction> actions,
}) {
  return showSheet<void>(
    context,
    (sheet) => SheetFrame(
      title: title,
      child: FTileGroup(
        children: [
          for (final a in actions)
            FTile(
              prefix: Icon(
                a.icon,
                color: a.destructive ? sheet.theme.colors.destructive : null,
              ),
              title: Text(
                a.label,
                style: a.destructive ? TextStyle(color: sheet.theme.colors.destructive) : null,
              ),
              onPress: () {
                Navigator.of(sheet).pop();
                a.onSelect();
              },
            ),
        ],
      ),
    ),
  );
}

Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showSheet<bool>(
    context,
    (sheet) => SheetFrame(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: sheet.theme.typography.body.sm.copyWith(
              color: sheet.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: destructive ? FButtonVariant.destructive : FButtonVariant.primary,
            onPress: () => Navigator.of(sheet).pop(true),
            child: Text(confirmLabel),
          ),
          const SizedBox(height: 8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(sheet).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}

/// Asks for a line of text. [validate] returns an error message or null.
Future<String?> showPromptSheet(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initial = '',
  String? Function(String value)? validate,
}) {
  return showSheet<String>(
    context,
    (sheet) => SheetFrame(
      title: title,
      child: _PromptForm(
        label: label,
        confirmLabel: confirmLabel,
        initial: initial,
        validate: validate,
      ),
    ),
  );
}

class _PromptForm extends StatefulWidget {
  const _PromptForm({
    required this.label,
    required this.confirmLabel,
    required this.initial,
    this.validate,
  });

  final String label;
  final String confirmLabel;
  final String initial;
  final String? Function(String value)? validate;

  @override
  State<_PromptForm> createState() => _PromptFormState();
}

class _PromptFormState extends State<_PromptForm> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  void _submit() {
    final error = widget.validate?.call(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(controller: _controller),
          label: Text(widget.label),
          error: _error == null ? null : Text(_error!),
          autofocus: true,
          onSubmit: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        FButton(onPress: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
