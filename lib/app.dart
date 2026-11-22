import 'package:material_ui/material_ui.dart';

import 'features/releases/ui/releases_page.dart';

class SteelApp extends StatelessWidget {
  const SteelApp({super.key});

  static const _seed = Color(0xFF5B7C99);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: _seed),
      darkTheme: ThemeData(colorSchemeSeed: _seed, brightness: Brightness.dark),
      home: const ReleasesPage(),
    );
  }
}
