import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/sheets.dart';
import '../../releases/application/releases_providers.dart';
import '../../server/application/server_controller.dart';
import '../application/instances_controller.dart';
import '../application/network_providers.dart';
import 'instance_form_sheet.dart';

/// Start / Stop for the header. Disabled while the version isn't downloaded or
/// while the server is changing state.
class StartStopButton extends ConsumerWidget {
  const StartStopButton({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(instanceProvider(instanceId).select((i) => i?.versionTag));
    final installed = tag != null && ref.watch(installedTagsProvider.select((s) => s.contains(tag)));
    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    final server = ref.read(serverControllerProvider(instanceId).notifier);

    return switch (status) {
      ServerStatus.running => FButton(
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          variant: FButtonVariant.secondary,
          prefix: const Icon(FLucideIcons.square),
          onPress: server.stop,
          child: const Text('Stop'),
        ),
      ServerStatus.starting || ServerStatus.stopping => FButton(
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          variant: FButtonVariant.secondary,
          onPress: null,
          child: Text(status == ServerStatus.starting ? 'Starting' : 'Stopping'),
        ),
      ServerStatus.idle => FButton(
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          prefix: const Icon(FLucideIcons.play),
          onPress: installed ? server.start : null,
          child: const Text('Start'),
        ),
    };
  }
}

/// The ⋮ dropdown: the addresses other devices can connect to (tap to copy),
/// then edit and delete.
class InstanceMenu extends ConsumerWidget {
  const InstanceMenu({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final port = ref.watch(instancePortProvider(instanceId));
    final addresses = ref.watch(networkAddressesProvider).value ?? const [];

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) showFToast(context: context, title: Text('Copied $text'));
    }

    return FPopoverMenu(
      style: .delta(maxWidth: 360), // room for "255.255.255.255:25565"
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menuBuilder: (menuContext, controller, _) => [
        FItemGroup(
          children: [
            if (addresses.isEmpty)
              FItem(
                prefix: const Icon(FLucideIcons.wifiOff),
                title: const Text('Not on a network'),
                subtitle: Text('Port $port'),
              ),
            for (final a in addresses)
              FItem(
                prefix: const Icon(FLucideIcons.wifi),
                title: Text(
                  '${a.ip}:$port',
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600),
                ),
                subtitle: Text(a.label),
                suffix: const Icon(FLucideIcons.copy),
                onPress: () {
                  controller.hide();
                  copy('${a.ip}:$port');
                },
              ),
          ],
        ),
        FItemGroup(
          children: [
            FItem(
              prefix: const Icon(FLucideIcons.pencil),
              title: const Text('Edit'),
              onPress: () {
                controller.hide();
                _edit(context, ref);
              },
            ),
            FItem(
              variant: FItemVariant.destructive,
              prefix: const Icon(FLucideIcons.trash2),
              title: const Text('Delete'),
              onPress: () {
                controller.hide();
                _delete(context, ref);
              },
            ),
          ],
        ),
      ],
      builder: (context, controller, _) => _CloseOnBack(
        controller: controller,
        child: FHeaderAction(
          icon: const Icon(FLucideIcons.ellipsisVertical),
          onPress: () {
            ref.invalidate(networkAddressesProvider); // pick up network changes
            controller.toggle();
          },
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final instance = ref.read(instanceProvider(instanceId));
    if (instance != null) await showInstanceFormSheet(context, editing: instance);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final instance = ref.read(instanceProvider(instanceId));
    if (instance == null) return;
    final ok = await showConfirmSheet(
      context,
      title: 'Delete "${instance.name}"?',
      message: 'This permanently deletes its worlds and config.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    Navigator.of(context).pop();
    ref.invalidate(serverControllerProvider(instanceId)); // kills the process
    await ref.read(instancesControllerProvider.notifier).remove(instanceId);
  }
}

/// Makes the system Back gesture close an open dropdown instead of leaving the
/// page.
class _CloseOnBack extends StatefulWidget {
  const _CloseOnBack({required this.controller, required this.child});

  final FPopoverController controller;
  final Widget child;

  @override
  State<_CloseOnBack> createState() => _CloseOnBackState();
}

class _CloseOnBackState extends State<_CloseOnBack> {
  bool get _open =>
      widget.controller.status == AnimationStatus.forward ||
      widget.controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(_CloseOnBack old) {
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
