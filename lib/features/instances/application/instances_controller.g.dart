// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instances_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(instanceStore)
final instanceStoreProvider = InstanceStoreProvider._();

final class InstanceStoreProvider
    extends $FunctionalProvider<InstanceStore, InstanceStore, InstanceStore>
    with $Provider<InstanceStore> {
  InstanceStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instanceStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instanceStoreHash();

  @$internal
  @override
  $ProviderElement<InstanceStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InstanceStore create(Ref ref) {
    return instanceStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceStore>(value),
    );
  }
}

String _$instanceStoreHash() => r'265c39def0d1da032460c395f57c5282d6bd5a56';

@ProviderFor(InstancesController)
final instancesControllerProvider = InstancesControllerProvider._();

final class InstancesControllerProvider
    extends $NotifierProvider<InstancesController, List<Instance>> {
  InstancesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instancesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instancesControllerHash();

  @$internal
  @override
  InstancesController create() => InstancesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Instance> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Instance>>(value),
    );
  }
}

String _$instancesControllerHash() =>
    r'0518e3b91a47fd728e71d530811a0337ad5ef4e9';

abstract class _$InstancesController extends $Notifier<List<Instance>> {
  List<Instance> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Instance>, List<Instance>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Instance>, List<Instance>>,
              List<Instance>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(instance)
final instanceProvider = InstanceFamily._();

final class InstanceProvider
    extends $FunctionalProvider<Instance?, Instance?, Instance?>
    with $Provider<Instance?> {
  InstanceProvider._({
    required InstanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'instanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$instanceHash();

  @override
  String toString() {
    return r'instanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Instance?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Instance? create(Ref ref) {
    final argument = this.argument as String;
    return instance(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Instance? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Instance?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$instanceHash() => r'47d2a08cf6f7fb5efc048d1d422e9311ee27b1c7';

final class InstanceFamily extends $Family
    with $FunctionalFamilyOverride<Instance?, String> {
  InstanceFamily._()
    : super(
        retry: null,
        name: r'instanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InstanceProvider call(String id) =>
      InstanceProvider._(argument: id, from: this);

  @override
  String toString() => r'instanceProvider';
}
