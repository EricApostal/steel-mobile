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

String _$binaryStoreHash() => r'a89947032dd281ac5a363237b52a2a33173f1c45';

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

/// The downloadable build for [tag], or null if GitHub no longer lists it.

@ProviderFor(buildForTag)
final buildForTagProvider = BuildForTagFamily._();

/// The downloadable build for [tag], or null if GitHub no longer lists it.

final class BuildForTagProvider
    extends
        $FunctionalProvider<
          AsyncValue<SteelBuild?>,
          SteelBuild?,
          FutureOr<SteelBuild?>
        >
    with $FutureModifier<SteelBuild?>, $FutureProvider<SteelBuild?> {
  /// The downloadable build for [tag], or null if GitHub no longer lists it.
  BuildForTagProvider._({
    required BuildForTagFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'buildForTagProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$buildForTagHash();

  @override
  String toString() {
    return r'buildForTagProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SteelBuild?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SteelBuild?> create(Ref ref) {
    final argument = this.argument as String;
    return buildForTag(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BuildForTagProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$buildForTagHash() => r'9a27f92f76d8484bbd4d11d62884384b8280c574';

/// The downloadable build for [tag], or null if GitHub no longer lists it.

final class BuildForTagFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SteelBuild?>, String> {
  BuildForTagFamily._()
    : super(
        retry: null,
        name: r'buildForTagProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The downloadable build for [tag], or null if GitHub no longer lists it.

  BuildForTagProvider call(String tag) =>
      BuildForTagProvider._(argument: tag, from: this);

  @override
  String toString() => r'buildForTagProvider';
}

/// Tags of the builds currently downloaded. Updated by `InstallController`.

@ProviderFor(InstalledTags)
final installedTagsProvider = InstalledTagsProvider._();

/// Tags of the builds currently downloaded. Updated by `InstallController`.
final class InstalledTagsProvider
    extends $NotifierProvider<InstalledTags, Set<String>> {
  /// Tags of the builds currently downloaded. Updated by `InstallController`.
  InstalledTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedTagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedTagsHash();

  @$internal
  @override
  InstalledTags create() => InstalledTags();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$installedTagsHash() => r'c0bf0d9d46467e2aa804650cf5a5b070a2405aa3';

/// Tags of the builds currently downloaded. Updated by `InstallController`.

abstract class _$InstalledTags extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
