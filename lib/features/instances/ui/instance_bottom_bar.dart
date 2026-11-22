import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../releases/application/releases_providers.dart';
import '../../releases/ui/install_control.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';

/// Always-visible controls under the scrolling page: Start/Stop, plus the
/// command input on the Console tab. Shows the download control instead while
/// the instance's version isn't on the device.
class InstanceBottomBar extends ConsumerWidget {
  const InstanceBottomBar({
    super.key,
    required this.instanceId,
    required this.showCommands,
    required this.onOutputExpected,
  });

  final String instanceId;
  final bool showCommands;

  /// Called when the user does something that produces log output (start,
  /// send a command), so the page can follow it.
  final VoidCallback onOutputExpected;

  static const _buttonWidth = 108.0;

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
      final button = switch (status) {
        ServerStatus.idle => FButton(
            onPress: () {
              server.start();
              onOutputExpected();
            },
            prefix: const Icon(FLucideIcons.play),
            child: const Text('Start'),
          ),
        ServerStatus.running => FButton(
            variant: FButtonVariant.secondary,
            onPress: server.stop,
            prefix: const Icon(FLucideIcons.square),
            child: const Text('Stop'),
          ),
        ServerStatus.starting => FButton(onPress: null, child: const Text('Starting')),
        ServerStatus.stopping => FButton(onPress: null, child: const Text('Stopping')),
      };

      content = showCommands
          ? Row(
              children: [
                SizedBox(width: _buttonWidth, child: button),
                const SizedBox(width: 4),
                Expanded(
                  child: CommandField(instanceId: instanceId, onSent: onOutputExpected),
                ),
              ],
            )
          : SizedBox(width: double.infinity, child: button);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: content,
        ),
      ),
    );
  }
}
