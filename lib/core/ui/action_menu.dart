import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class MenuAction {
  const MenuAction(
    this.label,
    this.icon,
    this.onSelect, {
    this.destructive = false,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelect;
  final bool destructive;

  /// Marks the current choice when the menu is used as a picker.
  final bool selected;
}

/// A dropdown anchored to its trigger. [builder] draws the trigger and gets a
/// callback that opens/closes the menu.
class ActionMenu extends StatelessWidget {
  const ActionMenu({
    super.key,
    required this.actions,
    required this.builder,
    this.menuAnchor = Alignment.topRight,
    this.childAnchor = Alignment.bottomRight,
    this.maxWidth,
  });

  final List<MenuAction> actions;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  /// Where on the menu / trigger the two attach. The default hangs the menu
  /// from the trigger's bottom-right corner.
  final Alignment menuAnchor;
  final Alignment childAnchor;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return FPopoverMenu(
      style: maxWidth == null ? const .context() : .delta(maxWidth: maxWidth),
      menuAnchor: menuAnchor,
      childAnchor: childAnchor,
      menuBuilder: (context, controller, _) => [
        FItemGroup(
          children: [
            for (final a in actions)
              FItem(
                variant: a.destructive ? FItemVariant.destructive : FItemVariant.primary,
                prefix: Icon(a.icon),
                title: Text(a.label),
                suffix: a.selected ? const Icon(FLucideIcons.check) : null,
                onPress: () {
                  controller.hide();
                  a.onSelect();
                },
              ),
          ],
        ),
      ],
      builder: (context, controller, _) => CloseOnBack(
        controller: controller,
        child: builder(context, controller.toggle),
      ),
    );
  }
}

/// Makes the system Back gesture close an open dropdown instead of leaving the
/// page.
class CloseOnBack extends StatefulWidget {
  const CloseOnBack({super.key, required this.controller, required this.child});

  final FPopoverController controller;
  final Widget child;

  @override
  State<CloseOnBack> createState() => _CloseOnBackState();
}

class _CloseOnBackState extends State<CloseOnBack> {
  bool get _open =>
      widget.controller.status == AnimationStatus.forward ||
      widget.controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(CloseOnBack old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.controller.hide();
      },
      child: widget.child,
    );
  }
}
