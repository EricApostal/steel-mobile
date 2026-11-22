// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-private storage root. Overridden in `main()` once it has been resolved.

@ProviderFor(appDir)
final appDirProvider = AppDirProvider._();

/// App-private storage root. Overridden in `main()` once it has been resolved.

final class AppDirProvider
    extends $FunctionalProvider<Directory, Directory, Directory>
    with $Provider<Directory> {
  /// App-private storage root. Overridden in `main()` once it has been resolved.
  AppDirProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDirProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDirHash();

  @$internal
  @override
  $ProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Directory create(Ref ref) {
    return appDir(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Directory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Directory>(value),
    );
  }
}

String _$appDirHash() => r'f006a665e6c191b4dcc1cd4a8bfde4f614919400';

@ProviderFor(steelMcClient)
final steelMcClientProvider = SteelMcClientProvider._();

final class SteelMcClientProvider
    extends $FunctionalProvider<SteelMcClient, SteelMcClient, SteelMcClient>
    with $Provider<SteelMcClient> {
  SteelMcClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'steelMcClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$steelMcClientHash();

  @$internal
  @override
  $ProviderElement<SteelMcClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SteelMcClient create(Ref ref) {
    return steelMcClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SteelMcClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SteelMcClient>(value),
    );
  }
}

String _$steelMcClientHash() => r'8362bf75b71ea739c6c7a11d1723170e99d3c041';

/// null when no Steel build exists for this device.

@ProviderFor(hostPlatform)
final hostPlatformProvider = HostPlatformProvider._();

/// null when no Steel build exists for this device.

final class HostPlatformProvider
    extends $FunctionalProvider<HostPlatform?, HostPlatform?, HostPlatform?>
    with $Provider<HostPlatform?> {
  /// null when no Steel build exists for this device.
  HostPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostPlatformProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostPlatformHash();

  @$internal
  @override
  $ProviderElement<HostPlatform?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HostPlatform? create(Ref ref) {
    return hostPlatform(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostPlatform? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostPlatform?>(value),
    );
  }
}

String _$hostPlatformHash() => r'f6b8246543a3f021ace5920d949777e1cedd8b1f';

@ProviderFor(steelTarget)
final steelTargetProvider = SteelTargetProvider._();

final class SteelTargetProvider
    extends $FunctionalProvider<SteelTarget?, SteelTarget?, SteelTarget?>
    with $Provider<SteelTarget?> {
  SteelTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'steelTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$steelTargetHash();

  @$internal
  @override
  $ProviderElement<SteelTarget?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SteelTarget? create(Ref ref) {
    return steelTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SteelTarget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SteelTarget?>(value),
    );
  }
}

String _$steelTargetHash() => r'534c8c3107eb0817ea3e8b0d329c2e1f94417812';
