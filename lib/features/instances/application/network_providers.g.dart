// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Addresses other devices can connect to. Re-read by invalidating.

@ProviderFor(networkAddresses)
final networkAddressesProvider = NetworkAddressesProvider._();

/// Addresses other devices can connect to. Re-read by invalidating.

final class NetworkAddressesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NetworkAddress>>,
          List<NetworkAddress>,
          FutureOr<List<NetworkAddress>>
        >
    with
        $FutureModifier<List<NetworkAddress>>,
        $FutureProvider<List<NetworkAddress>> {
  /// Addresses other devices can connect to. Re-read by invalidating.
  NetworkAddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkAddressesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkAddressesHash();

  @$internal
  @override
  $FutureProviderElement<List<NetworkAddress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NetworkAddress>> create(Ref ref) {
    return networkAddresses(ref);
  }
}

String _$networkAddressesHash() => r'd2ffac1c830c97963a8c3616572175992bb3c45d';

/// The port the instance actually listens on: `server_port` from its
/// `config/config.toml` once that exists, else the port assigned at creation.
/// Invalidate after the config changes.

@ProviderFor(instancePort)
final instancePortProvider = InstancePortFamily._();

/// The port the instance actually listens on: `server_port` from its
/// `config/config.toml` once that exists, else the port assigned at creation.
/// Invalidate after the config changes.

final class InstancePortProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The port the instance actually listens on: `server_port` from its
  /// `config/config.toml` once that exists, else the port assigned at creation.
  /// Invalidate after the config changes.
  InstancePortProvider._({
    required InstancePortFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'instancePortProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$instancePortHash();

  @override
  String toString() {
    return r'instancePortProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return instancePort(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstancePortProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$instancePortHash() => r'132c098c9ec5e2ff6683176efbed1bb6e394783c';

/// The port the instance actually listens on: `server_port` from its
/// `config/config.toml` once that exists, else the port assigned at creation.
/// Invalidate after the config changes.

final class InstancePortFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  InstancePortFamily._()
    : super(
        retry: null,
        name: r'instancePortProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The port the instance actually listens on: `server_port` from its
  /// `config/config.toml` once that exists, else the port assigned at creation.
  /// Invalidate after the config changes.

  InstancePortProvider call(String instanceId) =>
      InstancePortProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'instancePortProvider';
}
