import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Shows a centered popup. [builder] lays out the content inside the dialog's
/// decorated surface; [PopupFrame] is the usual layout.
Future<T?> showPopup<T>(
  BuildContext context, {
  required Widget Function(BuildContext context, FDialogStyle style) builder,
}) {
  return showFDialog<T>(
    context: context,
    useRootNavigator: true, // cover the whole window, sidebar included
    builder: (context, style, animation) => FDialog(animation: animation, builder: builder),
  );
}

/// Title, scrolling content and a row of equal-width action buttons.
class PopupFrame extends StatelessWidget {
  const PopupFrame({
    super.key,
    required this.style,
    required this.title,
    this.child,
    this.actions = const [],
  });

  final FDialogStyle style;
  final String title;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: style.titleTextStyle),
          if (child != null) ...[
            const SizedBox(height: 12),
            Flexible(child: SingleChildScrollView(child: child!)),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Yes/no question. Resolves to true only when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showPopup<bool>(
    context,
    builder: (context, style) => PopupFrame(
      style: style,
      title: title,
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FButton(
          variant: destructive ? FButtonVariant.destructive : FButtonVariant.primary,
          onPress: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
      child: Text(message, style: style.bodyTextStyle),
    ),
  );
  return confirmed ?? false;
}

/// Asks for a line of text. [validate] returns an error message or null.
Future<String?> showPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initial = '',
  String? Function(String value)? validate,
}) {
  return showPopup<String>(
    context,
    builder: (context, style) => _PromptDialog(
      style: style,
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      initial: initial,
      validate: validate,
    ),
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.style,
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initial,
    this.validate,
  });

  final FDialogStyle style;
  final String title;
  final String label;
  final String confirmLabel;
  final String initial;
  final String? Function(String value)? validate;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
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
    return PopupFrame(
      style: widget.style,
      title: widget.title,
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FButton(onPress: _submit, child: Text(widget.confirmLabel)),
      ],
      child: FTextField(
        control: FTextFieldControl.managed(controller: _controller),
        label: Text(widget.label),
        error: _error == null ? null : Text(_error!),
        autofocus: true,
        onSubmit: (_) => _submit(),
      ),
    );
  }
}
