// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'console_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The selected log filter for an instance, kept while you switch tabs.

@ProviderFor(ConsoleFilterController)
final consoleFilterControllerProvider = ConsoleFilterControllerFamily._();

/// The selected log filter for an instance, kept while you switch tabs.
final class ConsoleFilterControllerProvider
    extends $NotifierProvider<ConsoleFilterController, ConsoleFilter> {
  /// The selected log filter for an instance, kept while you switch tabs.
  ConsoleFilterControllerProvider._({
    required ConsoleFilterControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'consoleFilterControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$consoleFilterControllerHash();

  @override
  String toString() {
    return r'consoleFilterControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConsoleFilterController create() => ConsoleFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsoleFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsoleFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConsoleFilterControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$consoleFilterControllerHash() =>
    r'cb24ced56047e65de3dddcb8e3f81d9496a55770';

/// The selected log filter for an instance, kept while you switch tabs.

final class ConsoleFilterControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ConsoleFilterController,
          ConsoleFilter,
          ConsoleFilter,
          ConsoleFilter,
          String
        > {
  ConsoleFilterControllerFamily._()
    : super(
        retry: null,
        name: r'consoleFilterControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The selected log filter for an instance, kept while you switch tabs.

  ConsoleFilterControllerProvider call(String instanceId) =>
      ConsoleFilterControllerProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'consoleFilterControllerProvider';
}

/// The selected log filter for an instance, kept while you switch tabs.

abstract class _$ConsoleFilterController extends $Notifier<ConsoleFilter> {
  late final _$args = ref.$arg as String;
  String get instanceId => _$args;

  ConsoleFilter build(String instanceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConsoleFilter, ConsoleFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConsoleFilter, ConsoleFilter>,
              ConsoleFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
