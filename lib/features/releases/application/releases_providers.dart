import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../data/binary_installer.dart';
import '../data/binary_store.dart';
import '../data/releases_repository.dart';
import '../data/steel_build.dart';

part 'releases_providers.g.dart';

@Riverpod(keepAlive: true)
ReleasesRepository releasesRepository(Ref ref) =>
    ReleasesRepository(ref.watch(steelMcClientProvider));

@Riverpod(keepAlive: true)
BinaryStore binaryStore(Ref ref) => BinaryStore(ref.watch(appDirProvider));

@Riverpod(keepAlive: true)
BinaryInstaller binaryInstaller(Ref ref) => BinaryInstaller(
      ref.watch(steelMcClientProvider),
      ref.watch(binaryStoreProvider),
    );

/// Releases with a build for this device. Kept alive so we don't burn
/// through GitHub's unauthenticated rate limit; refresh explicitly.
@Riverpod(keepAlive: true)
Future<List<SteelBuild>> builds(Ref ref) async {
  final target = ref.watch(steelTargetProvider);
  if (target == null) return const [];
  return ref.watch(releasesRepositoryProvider).compatibleBuilds(target);
}
