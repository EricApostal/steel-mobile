import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
// The only Material usage: forui's documented host shell for navigation,
// localization and text selection. All UI is forui widgets.
import 'package:material_ui/material_ui.dart' show MaterialApp;

import 'core/router.dart';

class SteelApp extends ConsumerWidget {
  const SteelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktop = const {
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows,
    }.contains(defaultTargetPlatform);
    final light = desktop ? FTheme.neutral.light.desktop : FTheme.neutral.light.touch;
    final dark = desktop ? FTheme.neutral.dark.desktop : FTheme.neutral.dark.touch;

    return MaterialApp.router(
      title: 'Steel',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      theme: light.toApproximateMaterialTheme(),
      darkTheme: dark.toApproximateMaterialTheme(),
      builder: (context, child) {
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        return FTheme(
          data: isDark ? dark : light,
          child: FToaster(child: child!),
        );
      },
    );
  }
}
