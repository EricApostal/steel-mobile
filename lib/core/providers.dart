import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:steelmc_api/steelmc_api.dart';

import 'device_target.dart';

part 'providers.g.dart';

/// App-private storage root. Overridden in `main()` once it has been resolved.
@Riverpod(keepAlive: true)
Directory appDir(Ref ref) => throw UnimplementedError('appDir not overridden');

@Riverpod(keepAlive: true)
SteelMcClient steelMcClient(Ref ref) => SteelMcClient();

@Riverpod(keepAlive: true)
SteelTarget? steelTarget(Ref ref) => detectSteelTarget();
