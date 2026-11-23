// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Two branches (Instances, Versions), each with its own navigation stack, so
/// a tab or sidebar entry remembers where you were. Instance pages are routes
/// inside the Instances branch: on a phone they stack over the list, on
/// desktop they fill the pane next to the sidebar.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// Two branches (Instances, Versions), each with its own navigation stack, so
/// a tab or sidebar entry remembers where you were. Instance pages are routes
/// inside the Instances branch: on a phone they stack over the list, on
/// desktop they fill the pane next to the sidebar.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Two branches (Instances, Versions), each with its own navigation stack, so
  /// a tab or sidebar entry remembers where you were. Instance pages are routes
  /// inside the Instances branch: on a phone they stack over the list, on
  /// desktop they fill the pane next to the sidebar.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'28af55cad4e9e89d420b98a959d5a22b0c35580b';
