import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/action_menu.dart';
import '../../../core/ui/popups.dart';
import '../../releases/application/releases_providers.dart';
import '../../server/application/server_controller.dart';
import '../application/instances_controller.dart';
import '../application/network_providers.dart';
import 'instance_form_dialog.dart';

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

/// The ⋮ dropdown: network info, edit, delete.
class InstanceMenu extends ConsumerWidget {
  const InstanceMenu({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionMenu(
      actions: [
        MenuAction('Network info', FLucideIcons.wifi, () => _showNetworkInfo(context, ref)),
        MenuAction('Edit', FLucideIcons.pencil, () => _edit(context, ref)),
        MenuAction('Delete', FLucideIcons.trash2, () => _delete(context, ref), destructive: true),
      ],
      builder: (context, toggle) => FHeaderAction(
        icon: const Icon(FLucideIcons.ellipsisVertical),
        onPress: toggle,
      ),
    );
  }

  Future<void> _showNetworkInfo(BuildContext context, WidgetRef ref) {
    ref.invalidate(networkAddressesProvider); // pick up network changes
    return showPopup<void>(
      context,
      builder: (context, style) => Consumer(
        builder: (context, ref, _) {
          final port = ref.watch(instancePortProvider(instanceId));
          final addresses = ref.watch(networkAddressesProvider);
          final theme = context.theme;
          final muted = theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

          Future<void> copy(String text) async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) showFToast(context: context, title: Text('Copied $text'));
          }

          return PopupFrame(
            style: style,
            title: 'Network info',
            actions: [
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
            child: addresses.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: FCircularProgress()),
              ),
              error: (e, _) => Text('$e', style: style.bodyTextStyle),
              data: (list) => list.isEmpty
                  ? Text(
                      "This device isn't on a network. Connect to Wi-Fi to let others join.",
                      style: style.bodyTextStyle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Players on the same network can join using:', style: muted),
                        const SizedBox(height: 8),
                        for (final a in list)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${a.ip}:$port',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: theme.colors.foreground,
                                        ),
                                      ),
                                      Text(a.label, style: muted),
                                    ],
                                  ),
                                ),
                                FButton.icon(
                                  variant: FButtonVariant.ghost,
                                  onPress: () => copy('${a.ip}:$port'),
                                  child: const Icon(FLucideIcons.copy),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final instance = ref.read(instanceProvider(instanceId));
    if (instance != null) await showInstanceFormDialog(context, editing: instance);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final instance = ref.read(instanceProvider(instanceId));
    if (instance == null) return;
    final ok = await showConfirmDialog(
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
