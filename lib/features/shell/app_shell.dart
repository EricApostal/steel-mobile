import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../core/ui/layout.dart';
import '../instances/application/instances_controller.dart';
import '../instances/ui/instances_page.dart';
import '../server/application/server_controller.dart';

/// The frame around every page. A sidebar next to the content on wide
/// windows; bottom tabs on phones, hidden on detail pages so those get the
/// whole screen.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell, required this.location});

  final StatefulNavigationShell shell;
  final String location;

  /// `/instances/<id>/...` → id
  String? get _activeInstanceId {
    final segments = Uri.parse(location).pathSegments;
    return segments.length >= 2 && segments.first == 'instances' ? segments[1] : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDesktopWidth(context)) {
      return FScaffold(
        childPad: false,
        sidebar: _Sidebar(
          activeInstanceId: _activeInstanceId,
          onVersions: location.startsWith(AppRoutes.versions),
        ),
        child: shell,
      );
    }

    // Top-level pages (/instances, /versions) show the tabs; anything deeper
    // is a detail page and takes the full screen.
    final topLevel = Uri.parse(location).pathSegments.length <= 1;
    return FScaffold(
      childPad: false,
      footer: topLevel
          ? FBottomNavigationBar(
              index: shell.currentIndex,
              onChange: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              children: const [
                FBottomNavigationBarItem(icon: Icon(FLucideIcons.server), label: Text('Instances')),
                FBottomNavigationBarItem(icon: Icon(FLucideIcons.package), label: Text('Versions')),
              ],
            )
          : null,
      child: shell,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.activeInstanceId, required this.onVersions});

  final String? activeInstanceId;
  final bool onVersions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final instances = ref.watch(instancesControllerProvider);
    final target = ref.watch(steelTargetProvider);

    return FSidebar(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(FLucideIcons.server, size: 18, color: theme.colors.primaryForeground),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Steel', style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600)),
                  if (target != null)
                    Text(
                      target.label,
                      style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      children: [
        FSidebarGroup(
          label: const Text('Instances'),
          children: [
            for (final i in instances)
              FSidebarItem(
                icon: const Icon(FLucideIcons.server),
                label: _InstanceLabel(instanceId: i.id, name: i.name),
                selected: activeInstanceId == i.id,
                onPress: () => context.go(AppRoutes.instance(i.id)),
              ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.plus),
              label: const Text('New instance'),
              onPress: () => createInstance(context),
            ),
          ],
        ),
        FSidebarGroup(
          label: const Text('Library'),
          children: [
            FSidebarItem(
              icon: const Icon(FLucideIcons.package),
              label: const Text('Versions'),
              selected: onVersions,
              onPress: () => context.go(AppRoutes.versions),
            ),
          ],
        ),
      ],
    );
  }
}

/// An instance's name with a dot when its server is up.
class _InstanceLabel extends ConsumerWidget {
  const _InstanceLabel({required this.instanceId, required this.name});

  final String instanceId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    final color = switch (status) {
      ServerStatus.running => const Color(0xFF22C55E),
      ServerStatus.starting || ServerStatus.stopping => const Color(0xFFD97706),
      ServerStatus.idle => null,
    };

    return Row(
      children: [
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        if (color != null)
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox(width: 8, height: 8),
          ),
      ],
    );
  }
}
