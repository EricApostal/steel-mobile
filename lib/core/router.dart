import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show MaterialPage;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/files/ui/file_editor_page.dart';
import '../features/instances/ui/instance_page.dart';
import '../features/instances/ui/instances_page.dart';
import '../features/releases/ui/versions_page.dart';
import '../features/shell/app_shell.dart';
import 'ui/layout.dart';

part 'router.g.dart';

/// Every location in the app, in one place.
abstract final class AppRoutes {
  static const instances = '/instances';
  static const versions = '/versions';

  static String instance(String id) => '$instances/$id';

  static String file(String id, String path) =>
      Uri(path: '$instances/$id/file', queryParameters: {'path': path}).toString();
}

/// Phones get the platform's slide; on desktop, switching between instances
/// and tabs shouldn't animate like a page push.
Page<void> _page(BuildContext context, GoRouterState state, Widget child) =>
    isDesktopWidth(context)
        ? NoTransitionPage(key: state.pageKey, child: child)
        : MaterialPage(key: state.pageKey, child: child);

/// Two branches (Instances, Versions), each with its own navigation stack, so
/// a tab or sidebar entry remembers where you were. Instance pages are routes
/// inside the Instances branch: on a phone they stack over the list, on
/// desktop they fill the pane next to the sidebar.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.instances,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell, location: state.uri.path),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.instances,
                pageBuilder: (context, state) => _page(context, state, const InstancesPage()),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _page(
                      context,
                      state,
                      InstancePage(instanceId: state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'file',
                        pageBuilder: (context, state) => _page(
                          context,
                          state,
                          FileEditorPage(
                            instanceId: state.pathParameters['id']!,
                            path: state.uri.queryParameters['path'] ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.versions,
                pageBuilder: (context, state) => _page(context, state, const VersionsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
