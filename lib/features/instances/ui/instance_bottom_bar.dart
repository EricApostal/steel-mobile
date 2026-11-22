import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../releases/application/releases_providers.dart';
import '../../releases/ui/install_control.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';

/// Fixed under the page: the command input on the Console tab, or the
/// download control while the instance's version isn't on the device. Nothing
/// at all otherwise, so the content gets the room.
class InstanceBottomBar extends ConsumerWidget {
  const InstanceBottomBar({super.key, required this.instanceId, required this.showCommands});

  final String instanceId;
  final bool showCommands;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(instanceProvider(instanceId).select((i) => i?.versionTag));
    if (tag == null) return const SizedBox.shrink();

    final installed = ref.watch(installedTagsProvider.select((s) => s.contains(tag)));

    final Widget content;
    if (!installed) {
      content = ref.watch(buildForTagProvider(tag)).when(
            loading: () => const Center(child: FCircularProgress()),
            error: (e, _) => Text('$e'),
            data: (build) => build == null
                ? const Text('This version is no longer available.')
                : InstallControl(release: build),
          );
    } else if (showCommands) {
      content = CommandField(instanceId: instanceId);
    } else {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: content,
        ),
      ),
    );
  }
}
