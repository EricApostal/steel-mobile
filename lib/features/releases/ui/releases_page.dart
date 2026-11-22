import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../server/ui/running_banner.dart';
import '../application/releases_providers.dart';
import 'build_card.dart';

class ReleasesPage extends ConsumerWidget {
  const ReleasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(steelTargetProvider);
    final builds = ref.watch(buildsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steel'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: target == null
                ? null
                : () => ref.invalidate(buildsProvider),
          ),
        ],
      ),
      bottomNavigationBar: const RunningBanner(),
      body: target == null
          ? const _Message(
              icon: Icons.phonelink_erase,
              text: 'SteelMC has no build for this device\'s architecture.',
            )
          : builds.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Message(
                icon: Icons.cloud_off,
                text: '$e',
                action: FilledButton.tonal(
                  onPressed: () => ref.invalidate(buildsProvider),
                  child: const Text('Retry'),
                ),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => ref.refresh(buildsProvider.future),
                child: items.isEmpty
                    ? ListView(children: [
                        _Message(
                          icon: Icons.inbox_outlined,
                          text: 'No releases for ${target.label} yet.',
                        ),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => i == 0
                            ? Text(
                                'Builds for ${target.label}',
                                style: Theme.of(context).textTheme.labelLarge,
                              )
                            : BuildCard(
                                release: items[i - 1],
                                isLatest: i == 1,
                              ),
                      ),
              ),
            ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
