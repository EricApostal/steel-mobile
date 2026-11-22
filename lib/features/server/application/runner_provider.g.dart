// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// null on a host Steel doesn't support.

@ProviderFor(steelRunner)
final steelRunnerProvider = SteelRunnerProvider._();

/// null on a host Steel doesn't support.

final class SteelRunnerProvider
    extends $FunctionalProvider<SteelRunner?, SteelRunner?, SteelRunner?>
    with $Provider<SteelRunner?> {
  /// null on a host Steel doesn't support.
  SteelRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'steelRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$steelRunnerHash();

  @$internal
  @override
  $ProviderElement<SteelRunner?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SteelRunner? create(Ref ref) {
    return steelRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SteelRunner? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SteelRunner?>(value),
    );
  }
}

String _$steelRunnerHash() => r'ff45806c7a58fc3de0d594b70e206dd9d1c71ad9';
