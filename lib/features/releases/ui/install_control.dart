import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../application/install_controller.dart';
import '../data/steel_build.dart';

/// Download / progress / retry for one build. Shows nothing once installed
/// unless [whenInstalled] is given.
class InstallControl extends ConsumerWidget {
  const InstallControl({super.key, required this.release, this.whenInstalled});

  final SteelBuild release;
  final Widget Function(BuildContext context)? whenInstalled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(installControllerProvider(release));
    final install = ref.read(installControllerProvider(release).notifier);
    final theme = context.theme;

    return switch (state) {
      NotInstalled() => FButton(
          onPress: install.install,
          prefix: const Icon(FLucideIcons.download),
          child: const Text('Download'),
        ),
      Installing(:final progress, :final verifying) => Row(
          children: [
            Expanded(
              child: verifying || progress == null
                  ? const FProgress()
                  : FDeterminateProgress(value: progress.clamp(0, 1)),
            ),
            const SizedBox(width: 12),
            Text(
              verifying ? 'Verifying…' : '${((progress ?? 0) * 100).round()}%',
              style: theme.typography.body.sm,
            ),
            const SizedBox(width: 4),
            FButton.icon(
              variant: FButtonVariant.ghost,
              onPress: verifying ? null : install.cancel,
              child: const Icon(FLucideIcons.x),
            ),
          ],
        ),
      InstallFailed(:final message) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: theme.typography.body.sm.copyWith(color: theme.colors.destructive),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: FButtonVariant.secondary,
              onPress: install.install,
              child: const Text('Retry'),
            ),
          ],
        ),
      Installed() => whenInstalled?.call(context) ?? const SizedBox.shrink(),
    };
  }
}
