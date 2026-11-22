// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Download/verify/delete lifecycle of one build. Kept alive so a download
/// continues while its card is scrolled off screen.

@ProviderFor(InstallController)
final installControllerProvider = InstallControllerFamily._();

/// Download/verify/delete lifecycle of one build. Kept alive so a download
/// continues while its card is scrolled off screen.
final class InstallControllerProvider
    extends $NotifierProvider<InstallController, InstallState> {
  /// Download/verify/delete lifecycle of one build. Kept alive so a download
  /// continues while its card is scrolled off screen.
  InstallControllerProvider._({
    required InstallControllerFamily super.from,
    required SteelBuild super.argument,
  }) : super(
         retry: null,
         name: r'installControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$installControllerHash();

  @override
  String toString() {
    return r'installControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InstallController create() => InstallController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstallState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstallControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$installControllerHash() => r'e5a67fd416cb20f4a69e58055bfa6e9769d2dff3';

/// Download/verify/delete lifecycle of one build. Kept alive so a download
/// continues while its card is scrolled off screen.

final class InstallControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          InstallController,
          InstallState,
          InstallState,
          InstallState,
          SteelBuild
        > {
  InstallControllerFamily._()
    : super(
        retry: null,
        name: r'installControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Download/verify/delete lifecycle of one build. Kept alive so a download
  /// continues while its card is scrolled off screen.

  InstallControllerProvider call(SteelBuild release) =>
      InstallControllerProvider._(argument: release, from: this);

  @override
  String toString() => r'installControllerProvider';
}

/// Download/verify/delete lifecycle of one build. Kept alive so a download
/// continues while its card is scrolled off screen.

abstract class _$InstallController extends $Notifier<InstallState> {
  late final _$args = ref.$arg as SteelBuild;
  SteelBuild get release => _$args;

  InstallState build(SteelBuild release);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InstallState, InstallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InstallState, InstallState>,
              InstallState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
