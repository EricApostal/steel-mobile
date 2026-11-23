// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keep_awake.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the screen on while any server is running, since the app can't yet
/// keep a server alive in the background. Returns whether the lock is held.

@ProviderFor(keepAwake)
final keepAwakeProvider = KeepAwakeProvider._();

/// Keeps the screen on while any server is running, since the app can't yet
/// keep a server alive in the background. Returns whether the lock is held.

final class KeepAwakeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Keeps the screen on while any server is running, since the app can't yet
  /// keep a server alive in the background. Returns whether the lock is held.
  KeepAwakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keepAwakeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keepAwakeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return keepAwake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$keepAwakeHash() => r'e74da84c749407299d8c270ee0455510a09e837d';
