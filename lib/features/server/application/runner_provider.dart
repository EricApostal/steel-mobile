import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../data/steel_runner.dart';

part 'runner_provider.g.dart';

/// null on a host Steel doesn't support.
@Riverpod(keepAlive: true)
SteelRunner? steelRunner(Ref ref) {
  final host = ref.watch(hostPlatformProvider);
  return host == null ? null : SteelRunner(host.launcher);
}
