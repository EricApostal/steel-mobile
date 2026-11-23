import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/format.dart';
import '../../../core/providers.dart';
import '../../../core/ui/empty_state.dart';
import '../../instances/application/instances_controller.dart';
import '../application/install_controller.dart';
import '../application/releases_providers.dart';
import '../data/steel_build.dart';
import 'install_control.dart';

/// Downloadable Steel builds for this device.
class VersionsPage extends ConsumerWidget {
  const VersionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FScaffold(
      childPad: false,
      header: FHeader(title: const Text('Versions')),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _content(context, ref),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final target = ref.watch(steelTargetProvider);
    final builds = ref.watch(buildsProvider);

    if (target == null) {
      return const EmptyState(
        icon: FLucideIcons.smartphone,
        message: "SteelMC has no build for this device's architecture.",
      );
    }

    return builds.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, _) => EmptyState(
        icon: FLucideIcons.cloudOff,
        message: '$e',
        action: FButton(
          variant: FButtonVariant.secondary,
          onPress: () => ref.invalidate(buildsProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: FLucideIcons.inbox,
              message: 'No releases for ${target.label} yet.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => i == 0
                  ? Text(
                      'Builds for ${target.label}',
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    )
                  : _VersionCard(release: items[i - 1], isLatest: i == 1),
            ),
    );
  }
}

class _VersionCard extends ConsumerWidget {
  const _VersionCard({required this.release, required this.isLatest});

  final SteelBuild release;
  final bool isLatest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final date = release.publishedAt;
    final usedBy = ref.watch(
      instancesControllerProvider.select(
        (list) => list.where((i) => i.versionTag == release.tag).length,
      ),
    );

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Steel ${release.version}',
                    style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (isLatest) FBadge(child: const Text('Latest')),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (release.minecraftVersion != null) 'Minecraft ${release.minecraftVersion}',
                if (date != null) formatDate(date),
                formatBytes(release.size),
                if (usedBy > 0) 'Used by $usedBy',
              ].join(' · '),
              style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
            ),
            const SizedBox(height: 12),
            InstallControl(
              release: release,
              whenInstalled: (context) => Row(
                children: [
                  FBadge(variant: FBadgeVariant.secondary, child: const Text('Downloaded')),
                  const Spacer(),
                  FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: usedBy > 0
                        ? null
                        : ref.read(installControllerProvider(release).notifier).uninstall,
                    prefix: const Icon(FLucideIcons.trash2),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
