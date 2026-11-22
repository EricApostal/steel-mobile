// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'releases_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(releasesRepository)
final releasesRepositoryProvider = ReleasesRepositoryProvider._();

final class ReleasesRepositoryProvider
    extends
        $FunctionalProvider<
          ReleasesRepository,
          ReleasesRepository,
          ReleasesRepository
        >
    with $Provider<ReleasesRepository> {
  ReleasesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releasesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releasesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReleasesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReleasesRepository create(Ref ref) {
    return releasesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReleasesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReleasesRepository>(value),
    );
  }
}

String _$releasesRepositoryHash() =>
    r'532e34eb6f67a416648c039e42eca33d0dd6bb6d';

@ProviderFor(binaryStore)
final binaryStoreProvider = BinaryStoreProvider._();

final class BinaryStoreProvider
    extends $FunctionalProvider<BinaryStore, BinaryStore, BinaryStore>
    with $Provider<BinaryStore> {
  BinaryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'binaryStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$binaryStoreHash();

  @$internal
  @override
  $ProviderElement<BinaryStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BinaryStore create(Ref ref) {
    return binaryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BinaryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BinaryStore>(value),
    );
  }
}

String _$binaryStoreHash() => r'c168ee5ec4b09516b696dbb6fb6f81dc4e4f5fbc';

@ProviderFor(binaryInstaller)
final binaryInstallerProvider = BinaryInstallerProvider._();

final class BinaryInstallerProvider
    extends
        $FunctionalProvider<BinaryInstaller, BinaryInstaller, BinaryInstaller>
    with $Provider<BinaryInstaller> {
  BinaryInstallerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'binaryInstallerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$binaryInstallerHash();

  @$internal
  @override
  $ProviderElement<BinaryInstaller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BinaryInstaller create(Ref ref) {
    return binaryInstaller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BinaryInstaller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BinaryInstaller>(value),
    );
  }
}

String _$binaryInstallerHash() => r'0b35fd2603739babe4ebebd26dc77a87f01fc9b1';

/// Releases with a build for this device. Kept alive so we don't burn
/// through GitHub's unauthenticated rate limit; refresh explicitly.

@ProviderFor(builds)
final buildsProvider = BuildsProvider._();

/// Releases with a build for this device. Kept alive so we don't burn
/// through GitHub's unauthenticated rate limit; refresh explicitly.

final class BuildsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SteelBuild>>,
          List<SteelBuild>,
          FutureOr<List<SteelBuild>>
        >
    with $FutureModifier<List<SteelBuild>>, $FutureProvider<List<SteelBuild>> {
  /// Releases with a build for this device. Kept alive so we don't burn
  /// through GitHub's unauthenticated rate limit; refresh explicitly.
  BuildsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buildsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buildsHash();

  @$internal
  @override
  $FutureProviderElement<List<SteelBuild>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SteelBuild>> create(Ref ref) {
    return builds(ref);
  }
}

String _$buildsHash() => r'b1a8ed5e8f8fae9fd060d037545cc468fac9cef0';
