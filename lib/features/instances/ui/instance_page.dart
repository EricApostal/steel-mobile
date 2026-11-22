import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:flutter/services.dart';

import '../../../core/ui/sheets.dart';
import '../../files/ui/file_browser.dart';
import '../../releases/application/releases_providers.dart';
import '../../releases/ui/install_control.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';
import '../application/network_providers.dart';
import 'instance_form_sheet.dart';
import 'instances_page.dart';

class InstancePage extends ConsumerWidget {
  const InstancePage({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(instanceProvider(instanceId));
    if (instance == null) {
      return const FScaffold(child: SizedBox.shrink()); // deleted
    }

    final status = ref.watch(
      serverControllerProvider(instanceId).select((s) => s.status),
    );
    final theme = context.theme;
    final mc = instance.version.minecraft;
    final port = ref.watch(instancePortProvider(instanceId));
    // Give the log the space while typing a command.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(instance.name),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.ellipsisVertical),
            onPress: () => _showMenu(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!keyboardOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  StatusBadge(status: status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        'Steel ${instance.version.steel}',
                        if (mc != null) 'Minecraft $mc',
                      ].join(' · '),
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!keyboardOpen) _ConnectRow(instanceId: instanceId, port: port),
          Expanded(
            child: FTabs(
              expands: true,
              contentPhysics: const NeverScrollableScrollPhysics(),
              children: [
                FTabEntry(
                  label: const Text('Console'),
                  child: Column(
                    children: [
                      Expanded(child: ConsoleView(instanceId: instanceId)),
                      _StartBar(instanceId: instanceId, hidden: keyboardOpen),
                    ],
                  ),
                ),
                FTabEntry(
                  label: const Text('Files'),
                  child: FileBrowser(instanceId: instanceId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final instance = ref.read(instanceProvider(instanceId));
    if (instance == null) return;
    showActionSheet(
      context,
      title: instance.name,
      actions: [
        SheetAction('Edit', FLucideIcons.pencil, () async {
          await showInstanceFormSheet(context, editing: instance);
        }),
        SheetAction('Delete', FLucideIcons.trash2, () async {
          final ok = await showConfirmSheet(
            context,
            title: 'Delete "${instance.name}"?',
            message: 'This permanently deletes its worlds and config.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (!ok || !context.mounted) return;
          Navigator.of(context).pop();
          ref.invalidate(
            serverControllerProvider(instanceId),
          ); // kills the process
          await ref
              .read(instancesControllerProvider.notifier)
              .remove(instanceId);
        }, destructive: true),
      ],
    );
  }
}

/// Start/Stop, or the download control when the version isn't on the device.
class _StartBar extends ConsumerWidget {
  const _StartBar({required this.instanceId, this.hidden = false});

  final String instanceId;

  /// Collapsed while the keyboard is open.
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(
      instanceProvider(instanceId).select((i) => i?.versionTag),
    );
    if (tag == null || hidden) return const SizedBox.shrink();

    final installed = ref.watch(
      installedTagsProvider.select((s) => s.contains(tag)),
    );
    final status = ref.watch(
      serverControllerProvider(instanceId).select((s) => s.status),
    );
    final server = ref.read(serverControllerProvider(instanceId).notifier);

    final Widget content;
    if (!installed) {
      content = ref
          .watch(buildForTagProvider(tag))
          .when(
            loading: () => const Center(child: FCircularProgress()),
            error: (e, _) => Text('$e'),
            data: (build) => build == null
                ? const Text('This version is no longer available.')
                : InstallControl(release: build),
          );
    } else {
      content = switch (status) {
        ServerStatus.idle => FButton(
          onPress: server.start,
          prefix: const Icon(FLucideIcons.play),
          child: const Text('Start'),
        ),
        ServerStatus.running => FButton(
          variant: FButtonVariant.secondary,
          onPress: server.stop,
          prefix: const Icon(FLucideIcons.square),
          child: const Text('Stop'),
        ),
        ServerStatus.starting || ServerStatus.stopping => FButton(
          onPress: null,
          child: Text(
            status == ServerStatus.starting ? 'Starting…' : 'Stopping…',
          ),
        ),
      };
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(width: double.infinity, child: content),
        ),
      ),
    );
  }
}

/// Shows the address other devices connect to; tap to copy.
class _ConnectRow extends ConsumerWidget {
  const _ConnectRow({required this.instanceId, required this.port});

  final String instanceId;
  final int port;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final addresses = ref.watch(networkAddressesProvider);
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showFToast(context: context, title: Text('Copied $text'));
      }
    }

    Widget row({
      required IconData icon,
      required Widget content,
      VoidCallback? onTap,
      Widget? trailing,
    }) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: FTappable(
          onPress: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: theme.colors.mutedForeground),
                  const SizedBox(width: 10),
                  Expanded(child: content),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return addresses.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          return row(
            icon: FLucideIcons.wifiOff,
            onTap: () => ref.invalidate(networkAddressesProvider),
            content: Text('Not on a network · Port $port', style: muted),
            trailing: Icon(
              FLucideIcons.refreshCw,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          );
        }
        final best = list.first;
        final address = '${best.ip}:$port';
        return row(
          icon: FLucideIcons.wifi,
          onTap: list.length == 1
              ? () => copy(address)
              : () => showActionSheet(
                  context,
                  title: 'Connect using',
                  actions: [
                    for (final a in list)
                      SheetAction(
                        '${a.ip}:$port  ·  ${a.label}',
                        FLucideIcons.copy,
                        () => copy('${a.ip}:$port'),
                      ),
                  ],
                ),
          content: Row(
            children: [
              Text(
                address,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Text(best.label, style: muted),
            ],
          ),
          trailing: Icon(
            list.length == 1 ? FLucideIcons.copy : FLucideIcons.chevronDown,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        );
      },
    );
  }
}
