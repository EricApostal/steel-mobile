import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationSupportDirectory();

  runApp(
    ProviderScope(
      // Surface errors immediately instead of silently retrying with backoff.
      retry: (_, _) => null,
      overrides: [appDirProvider.overrideWithValue(appDir)],
      child: const SteelApp(),
    ),
  );
}
