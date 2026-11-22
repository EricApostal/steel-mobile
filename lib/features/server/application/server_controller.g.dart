// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns one instance's server process and its parsed log.

@ProviderFor(ServerController)
final serverControllerProvider = ServerControllerFamily._();

/// Owns one instance's server process and its parsed log.
final class ServerControllerProvider
    extends $NotifierProvider<ServerController, ServerState> {
  /// Owns one instance's server process and its parsed log.
  ServerControllerProvider._({
    required ServerControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverControllerHash();

  @override
  String toString() {
    return r'serverControllerProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is ServerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverControllerHash() => r'8e7c2d6d8d7540b8e640752f3d59fb77b9a6d466';

/// Owns one instance's server process and its parsed log.

final class ServerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ServerController,
          ServerState,
          ServerState,
          ServerState,
          String
        > {
  ServerControllerFamily._()
    : super(
        retry: null,
        name: r'serverControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Owns one instance's server process and its parsed log.

  ServerControllerProvider call(String instanceId) =>
      ServerControllerProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'serverControllerProvider';
}

/// Owns one instance's server process and its parsed log.

abstract class _$ServerController extends $Notifier<ServerState> {
  late final _$args = ref.$arg as String;
  String get instanceId => _$args;

  ServerState build(String instanceId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
