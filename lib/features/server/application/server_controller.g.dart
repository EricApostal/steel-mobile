// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the single running server process and its log.

@ProviderFor(ServerController)
final serverControllerProvider = ServerControllerProvider._();

/// Owns the single running server process and its log.
final class ServerControllerProvider
    extends $NotifierProvider<ServerController, ServerState> {
  /// Owns the single running server process and its log.
  ServerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverControllerHash();

  @$internal
  @override
  ServerController create() => ServerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerState>(value),
    );
  }
}

String _$serverControllerHash() => r'a6f0971d078c014757d94588d3bc792418f00316';

/// Owns the single running server process and its log.

abstract class _$ServerController extends $Notifier<ServerState> {
  ServerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ServerState, ServerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServerState, ServerState>,
              ServerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
