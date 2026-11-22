import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application/server_controller.dart';
import 'server_page.dart';

/// Shown on the releases page while a server is running.
class RunningBanner extends ConsumerWidget {
  const RunningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final build = ref.watch(
      serverControllerProvider.select((s) => s.isActive ? s.build : null),
    );
    if (build == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      child: SafeArea(
        top: false,
        child: ListTile(
          leading: Icon(Icons.dns, color: scheme.onPrimaryContainer),
          title: Text(
            'Steel ${build.version} is running',
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ServerPage()),
          ),
        ),
      ),
    );
  }
}
