import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/server_page.dart';
import '../application/install_controller.dart';
import '../data/steel_build.dart';

class BuildCard extends ConsumerWidget {
  const BuildCard({super.key, required this.release, this.isLatest = false});

  final SteelBuild release;
  final bool isLatest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = release.publishedAt;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Steel ${release.version}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isLatest) const Chip(label: Text('Latest')),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (release.minecraftVersion != null)
                  'Minecraft ${release.minecraftVersion}',
                if (date != null) formatDate(date),
                formatBytes(release.size),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _Actions(release: release),
          ],
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.release});

  final SteelBuild release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(installControllerProvider(release));
    final install = ref.read(installControllerProvider(release).notifier);

    return switch (state) {
      NotInstalled() => Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: install.install,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ),
      Installing(:final progress, :final verifying) => Row(
          children: [
            Expanded(child: LinearProgressIndicator(value: verifying ? null : progress)),
            const SizedBox(width: 12),
            Text(
              verifying
                  ? 'Verifying…'
                  : progress == null
                      ? ''
                      : '${(progress * 100).round()}%',
            ),
            IconButton(
              tooltip: 'Cancel',
              icon: const Icon(Icons.close),
              onPressed: verifying ? null : install.cancel,
            ),
          ],
        ),
      InstallFailed(:final message) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: install.install,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      Installed() => _InstalledActions(release: release),
    };
  }
}

class _InstalledActions extends ConsumerWidget {
  const _InstalledActions({required this.release});

  final SteelBuild release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      serverControllerProvider.select((s) => s.isActive ? s.build : null),
    );
    final isThis = active == release;
    final otherRunning = active != null && !isThis;

    return Row(
      children: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: isThis
              ? null
              : ref.read(installControllerProvider(release).notifier).uninstall,
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: otherRunning
              ? null
              : () {
                  if (!isThis) {
                    ref.read(serverControllerProvider.notifier).start(release);
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ServerPage()),
                  );
                },
          icon: Icon(isThis ? Icons.terminal : Icons.play_arrow),
          label: Text(isThis ? 'Open' : 'Run'),
        ),
      ],
    );
  }
}
