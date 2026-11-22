import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
// The only Material usage: forui's documented host shell for navigation,
// localization and text selection. All UI is forui widgets.
import 'package:material_ui/material_ui.dart' show MaterialApp;

import 'features/home/home_page.dart';

class SteelApp extends StatelessWidget {
  const SteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = FTheme.neutral.light.touch;
    final dark = FTheme.neutral.dark.touch;

    return MaterialApp(
      title: 'Steel',
      debugShowCheckedModeBanner: false,
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
      home: const HomePage(),
    );
  }
}
