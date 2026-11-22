import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
// The only Material usage: forui's documented host shell for navigation,
// localization and text selection. All UI is forui widgets.
import 'package:material_ui/material_ui.dart' show MaterialApp;

import 'features/home/home_page.dart';

class SteelApp extends StatelessWidget {
  const SteelApp({super.key});

  /// The UI is built for a phone; on wide windows it stays this wide.
  static const _maxWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final desktop = const {
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows,
    }.contains(defaultTargetPlatform);
    final light = desktop ? FTheme.neutral.light.desktop : FTheme.neutral.light.touch;
    final dark = desktop ? FTheme.neutral.dark.desktop : FTheme.neutral.dark.touch;

    return MaterialApp(
      title: 'Steel',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      theme: light.toApproximateMaterialTheme(),
      darkTheme: dark.toApproximateMaterialTheme(),
      builder: (context, child) {
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final theme = isDark ? dark : light;
        return FTheme(
          data: theme,
          child: FToaster(
            child: ColoredBox(
              color: theme.colors.background,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
      home: const HomePage(),
    );
  }
}
