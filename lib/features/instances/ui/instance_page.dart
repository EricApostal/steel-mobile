import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/sheets.dart';
import '../../files/ui/file_browser.dart';
import '../../releases/application/releases_providers.dart';
import '../../releases/ui/install_control.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';
import 'instance_form_sheet.dart';
import 'instances_page.dart';

class InstancePage extends ConsumerWidget {
  const InstancePage({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(instanceProvider(instanceId));
    if (instance == null) return const FScaffold(child: SizedBox.shrink()); // deleted

    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    final theme = context.theme;
    final mc = instance.version.minecraft;

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(instance.name),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
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
                      'Port ${instance.port}',
                    ].join(' · '),
                    style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
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
                      _StartBar(instanceId: instanceId),
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
          ref.invalidate(serverControllerProvider(instanceId)); // kills the process
          await ref.read(instancesControllerProvider.notifier).remove(instanceId);
        }, destructive: true),
      ],
    );
  }
}

/// Start/Stop, or the download control when the version isn't on the device.
class _StartBar extends ConsumerWidget {
  const _StartBar({required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(instanceProvider(instanceId).select((i) => i?.versionTag));
    if (tag == null) return const SizedBox.shrink();

    final installed = ref.watch(installedTagsProvider.select((s) => s.contains(tag)));
    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    final server = ref.read(serverControllerProvider(instanceId).notifier);

    final Widget content;
    if (!installed) {
      content = ref.watch(buildForTagProvider(tag)).when(
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
            child: Text(status == ServerStatus.starting ? 'Starting…' : 'Stopping…'),
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
